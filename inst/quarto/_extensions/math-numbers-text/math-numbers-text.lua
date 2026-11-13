--[[
math-numbers-text.lua

Wraps the numbers inside math in {\mnum{...}}, so that MathJax typesets them in
the *page* font (e.g. UCLSans) rather than in its own TeX font. Letters, symbols
and operators are left untouched.

\mnum must be defined as a MathJax macro, e.g. in assets/latex_macros.html:
  mnum: ["{\\style{font-family:inherit; font-size: 105%;}{\\text{#1}}}",1],
so the actual styling (font, size) lives in one place, with the other macros.

Things that are NOT changed (so that the TeX stays valid):
  - numbers followed by a TeX unit (2pt, 1.5em, 3mu, ...), e.g. in \hspace{2pt},
    \\[4pt], \kern2pt, \rule{1em}{2pt}
  - hex colours (#ff0000)
  - the argument of \text, \textrm, \textbf, \textit, \mbox, \tag, \label,
    \ref, \eqref, \unicode, \href, \class, \cssId, \style, \operatorname
  - after ^, _ or a control word without braces (x^23, \frac12, \sqrt2) only the
    *first* digit is wrapped, which is what TeX would take as the argument

Also applied to math written as \\( ... \\) or \\[ ... \\] inside raw HTML (e.g. tables
from tinytable/kable), which Pandoc does not parse as Math.

Only applied to HTML-based formats (incl. revealjs); LaTeX/beamer untouched.
--]]

--[[ ==========================================================================
 HOW A PANDOC LUA FILTER WORKS (the minimum needed to read this file)

 Pandoc first reads the .qmd/.md into an internal tree of "elements" (the AST):
 paragraphs, headers, text, *Math* (anything written as $...$ or $$...$$),
 *RawBlock*/*RawInline* (raw HTML/LaTeX passed through untouched, e.g. the HTML
 of a tinytable table), plus the document's YAML as *Meta*.

 A filter is a Lua file that, at the end, returns one or more tables of
 functions named after element types (Math = function(m) ... end, etc.).
 Pandoc walks the tree and calls the matching function on every element of
 that type. The function can:
   - return the (modified) element  -> it replaces the original
   - return nil (or nothing)        -> the element is left as it is

 When a *list* of such tables is returned, Pandoc runs them one after the other,
 each over the whole document. Here the first pass only reads the YAML (Meta),
 the second does the actual work; this guarantees the YAML switch is known
 before any maths is touched.

 A FEW LUA BASICS USED BELOW
   local x = ...         a variable visible only in this file/function
   s:sub(i, j)           characters i..j of string s (Lua counts from 1, not 0)
   s:match(pattern, i)   finds `pattern` in s starting at position i (a "^" at
                         the start of the pattern means "exactly at position i")
   #s, #t                length of string s / number of items in table t
   t[#t+1] = v           append v at the end of table (list) t
   table.concat(t)       glue all the strings in t into a single string
   ..                    string concatenation ("a" .. "b" is "ab")
   ~=                    "not equal" (like != in R)
   Lua patterns are like (simpler) regular expressions:
     %d digit, %a letter, %w letter or digit, %x hex digit, %s space,
     + one or more, * zero or more, ? optional, . any character,
     % escapes a special character (so %. is a literal dot, %( a literal "(")
========================================================================== --]]


--[[ --------------------------------------------------------------------------
 PROTECTED COMMANDS
 A lookup table ("set"): protected["text"] is true, protected["frac"] is nil.
 If one of these commands is followed by {...}, the whole braced argument is
 copied unchanged, so e.g. \tag{1} or \text{Table 2} keep their digits as they
 are. \mnum and \txt are included so that the filter never wraps numbers that
 are already wrapped (or set in the page font on purpose).
-------------------------------------------------------------------------- --]]
local protected = {
  text=true, textrm=true, textbf=true, textit=true, textsf=true, texttt=true,
  mbox=true, tag=true, label=true, ref=true, eqref=true, unicode=true,
  href=true, class=true, cssId=true, style=true, operatorname=true,
  mnum=true, txt=true
}

--[[ --------------------------------------------------------------------------
 TEX UNITS
 A number immediately followed by one of these is a *length* (e.g. 2pt, 1.5em),
 not a number to display: wrapping it would break commands like \hspace{2pt}.
-------------------------------------------------------------------------- --]]
local units = { "pt","em","ex","mu","px","mm","cm","in","pc","bp","dd","cc","sp" }

--[[ --------------------------------------------------------------------------
 followed_by_unit(s, j)
 Returns true if, at position j of string s (i.e. right after a number), there
 is a TeX unit, possibly after some spaces.
   - the `while` loop skips spaces (so "2 pt" also counts)
   - the `for` loop tries each unit: s:sub(k, k + #u - 1) are the next #u
     characters; they must equal the unit...
   - ...and the character after the unit must NOT be a letter, so that e.g.
     "2 \infty" or "3 inches" do not wrongly match "in"
-------------------------------------------------------------------------- --]]
local function followed_by_unit(s, j)
  -- j = position just after the number; skip spaces
  local k = j
  while s:sub(k,k) == " " do k = k + 1 end
  for _,u in ipairs(units) do
    if s:sub(k, k + #u - 1) == u and not s:sub(k + #u, k + #u):match("%a") then
      return true
    end
  end
  return false
end

--[[ --------------------------------------------------------------------------
 skip_group(s, i)
 s:sub(i,i) is an opening "{". Returns the position just after the matching
 closing "}", taking nested braces into account: e.g. for "{a{b}c}d" it
 returns the position of "d".
   - depth counts how many braces are currently open: +1 at "{", -1 at "}";
     when it goes back to 0 we are at the matching "}"
   - a backslash skips 2 characters, so escaped braces \{ and \} are not
     counted as real braces
   - if the braces are unbalanced it returns the end of the string (n + 1)
-------------------------------------------------------------------------- --]]
local function skip_group(s, i)
  local depth = 0
  local n = #s
  while i <= n do
    local c = s:sub(i,i)
    if c == "\\" then
      i = i + 2
    else
      if c == "{" then depth = depth + 1
      elseif c == "}" then depth = depth - 1
        if depth == 0 then return i + 1 end
      end
      i = i + 1
    end
  end
  return n + 1
end

--[[ --------------------------------------------------------------------------
 convert(s, raw)
 THE MAIN FUNCTION. Takes the TeX source of one formula (string s, e.g.
 "x^2 + 0.5") and returns it with the numbers wrapped (e.g.
 "x^{\mnum{2}} + {\mnum{0.5}}").

 It reads s one character at a time, left to right (i is the current
 position), and builds the result as a list of pieces in `out`, which are
 glued together at the end with table.concat. Each branch of the big
 if/elseif decides what to do with the character at position i, appends the
 corresponding piece to `out` and moves i forward.

 `raw` is true when the formula comes from raw HTML (e.g. a tinytable table);
 only then HTML entities like &gt; need protecting (see below).

 `prev` remembers what kind of token came just before (ignoring spaces):
   "script" -> the previous character was ^ or _
   "cw"     -> the previous token was a control word like \frac or \sqrt
   ""       -> anything else
 This matters because in TeX, x^23 means x^{2}3 and \frac12 means
 \frac{1}{2}: after ^, _ or a command WITHOUT braces, TeX takes only ONE
 character as the argument. So in those cases only the first digit is
 wrapped, to keep the meaning of the formula unchanged.
-------------------------------------------------------------------------- --]]
local function convert(s, raw)
  local out = {}
  local i, n = 1, #s
  local prev = ""          -- kind of previous significant token: "script", "cw" or ""
  while i <= n do
    local c = s:sub(i,i)   -- the current character

    -- ---- CASE 1: a backslash, i.e. the start of a TeX command ---------------
    if c == "\\" then
      -- "^%a+" = one or more letters right after the backslash: the command
      -- name, e.g. "frac" in \frac. It is nil for control symbols like \, or \\
      local name = s:match("^%a+", i + 1)
      if name then
        -- j = position just after the command name
        local j = i + 1 + #name
        -- copy the backslash + name as they are
        out[#out+1] = s:sub(i, j - 1)
        -- protected command followed by a braced argument: copy verbatim
        -- (k skips any spaces between the command and its "{")
        local k = j
        while s:sub(k,k) == " " do k = k + 1 end
        if protected[name] and s:sub(k,k) == "{" then
          -- copy everything up to the matching "}" untouched and jump past it
          local e = skip_group(s, k)
          out[#out+1] = s:sub(j, e - 1)
          i = e
          prev = ""
        else
          -- an ordinary command (\frac, \mu, \sqrt, ...): just move on, but
          -- remember that a command came last (see `prev` above)
          i = j
          prev = "cw"
        end
      else
        -- control symbol (\, \; \\ \{ ...)
        -- (backslash + one non-letter): copy both characters as they are
        out[#out+1] = s:sub(i, i + 1)
        i = i + 2
        prev = ""
      end

    -- ---- CASE 2: an HTML entity (only in raw HTML) ---------------------------
    -- In raw HTML, "<" is written as &lt;, ">" as &gt;, a minus sign may be
    -- &#8722; and so on. "^&#?%w+;" matches "&", an optional "#", letters or
    -- digits, then ";". The entity is copied whole, so that the digits in
    -- &#8722; are not wrapped (which would break the entity).
    elseif raw and c == "&" and s:match("^&#?%w+;", i) then
      -- HTML entity inside raw HTML (e.g. &gt; or &#8722;): copy verbatim
      local e = s:match("^&#?%w+;", i)
      out[#out+1] = e
      i = i + #e
      prev = ""

    -- ---- CASE 3: "#", e.g. a hex colour like #ff0000 -------------------------
    -- "^#%x+" matches "#" followed by hex digits; it is copied whole, so the
    -- digits in a colour are not wrapped. A lone "#" is copied as it is.
    elseif c == "#" then
      local h = s:match("^#%x+", i) or "#"
      out[#out+1] = h
      i = i + #h
      prev = ""

    -- ---- CASE 4: a digit, i.e. the start of a number --------------------------
    elseif c:match("%d") then
      -- "^%d+%.?%d*" = digits, an optional dot, more optional digits: this
      -- grabs the whole number, e.g. "2345" or "0.56"
      local num = s:match("^%d+%.?%d*", i)
      -- a trailing dot ("3." at the end of a sentence) is not part of the number
      if num:sub(-1) == "." then num = num:sub(1, -2) end
      if followed_by_unit(s, i + #num) then
        -- a length such as 2pt: leave it alone
        out[#out+1] = num
        i = i + #num
      elseif prev == "script" or prev == "cw" then
        -- TeX would only take one digit as the argument here
        -- (x^23, \frac12): wrap just that single digit c and move on by one;
        -- the following digits are dealt with in the next rounds of the loop
        out[#out+1] = "{\\mnum{" .. c .. "}}"
        i = i + 1
      else
        -- the normal case: wrap the whole number, e.g. 2345 -> {\mnum{2345}}
        -- (the outer braces make it a single "unit" for TeX, so that e.g.
        -- x^{\mnum{2}} or 10^{-3} keep working)
        out[#out+1] = "{\\mnum{" .. num .. "}}"
        i = i + #num
      end
      prev = ""

    -- ---- CASE 5: a space --------------------------------------------------------
    elseif c == " " then
      out[#out+1] = c
      i = i + 1
      -- keep `prev` (spaces don't change what TeX takes as the argument)
      -- (x^ 2 is still x^{2} in TeX, so a space must not "reset" prev)

    -- ---- CASE 6: anything else (letters, + - = ( ) { } ^ _ ...) -------------------
    -- copied as it is; if it is ^ or _ we remember it, because then the next
    -- number must be treated as a one-character superscript/subscript
    else
      out[#out+1] = c
      i = i + 1
      prev = (c == "^" or c == "_") and "script" or ""
    end
  end
  -- glue all the pieces back into one string
  return table.concat(out)
end

--[[ --------------------------------------------------------------------------
 convert_raw_html(t)
 Raw HTML (e.g. a tinytable table) is not parsed by Pandoc, so the maths in it
 is not a Math element: it is just text like "\(\hat{S}(20)\)" inside the HTML.
 gsub ("global substitute") finds every match of a pattern and replaces it
 with what the function returns:
   - "\\%((.-)\\%)" matches a literal \( , then (.-) captures as FEW characters
     as possible (so that two formulas on the same line are not merged into
     one), then a literal \) ; the captured TeX m goes through convert() and
     is put back between \( and \)
   - the second line does the same for display maths \[ ... \]
 convert() is called with raw = true, so HTML entities are protected.
-------------------------------------------------------------------------- --]]
-- Math written as \( ... \) or \[ ... \] inside raw HTML, e.g. tables made by
-- tinytable/kable/gt, which Pandoc does not parse as Math
local function convert_raw_html(t)
  t = t:gsub("\\%((.-)\\%)", function(m) return "\\(" .. convert(m, true) .. "\\)" end)
  t = t:gsub("\\%[(.-)\\%]", function(m) return "\\[" .. convert(m, true) .. "\\]" end)
  return t
end

--[[ --------------------------------------------------------------------------
 ON/OFF SWITCH
 `enabled` is the default used when the YAML does not mention
 math-numbers-font. It is a variable *outside* the functions below, so that
 the first pass (Meta) can set it and the second pass (Math, ...) can read it.
-------------------------------------------------------------------------- --]]
-- Default when the YAML does not say; `math-numbers-font: true/false` overrides it
local enabled = false

--[[ --------------------------------------------------------------------------
 THE FILTER ITSELF
 FORMAT is set by Pandoc to the output format ("html", "revealjs", "latex",
 "beamer", ...). For non-HTML formats nothing is returned, so the filter does
 nothing at all (LaTeX/beamer are untouched).
-------------------------------------------------------------------------- --]]
if FORMAT:match("html") or FORMAT:match("revealjs") then
  return {

    -- ---- PASS 1: read the YAML ------------------------------------------------
    -- meta is the document's metadata; meta["math-numbers-font"] is the value
    -- of that key, or nil if the key is not there (then the default is kept)
    {
      Meta = function(meta)
        local v = meta["math-numbers-font"]
        if v ~= nil then
          -- YAML true/false arrive as booleans; quoted "true"/"false" as strings
          if type(v) == "boolean" then
            enabled = v
          else
            -- pandoc.utils.stringify turns Pandoc's metadata object into plain
            -- text, so "true" (as a string) can be compared
            enabled = (pandoc.utils.stringify(v) == "true")
          end
        end
      end
    },

    -- ---- PASS 2: change the maths ---------------------------------------------
    {
      -- every $...$ / $$...$$ in the document; m.text is its TeX source.
      -- If the switch is off, return nil = leave the formula as it is
      Math = function(m)
        if not enabled then return nil end
        m.text = convert(m.text)
        return m
      end,
      -- raw HTML blocks (e.g. a whole table) and raw HTML inline snippets.
      -- r.format says what kind of raw content it is: only "html" is touched
      -- (raw LaTeX, if any, is left alone). When nothing is returned (switch
      -- off or not HTML) the element stays as it is
      RawBlock = function(r)
        if enabled and r.format:match("html") then
          r.text = convert_raw_html(r.text)
          return r
        end
      end,
      RawInline = function(r)
        if enabled and r.format:match("html") then
          r.text = convert_raw_html(r.text)
          return r
        end
      end
    }
  }
end
