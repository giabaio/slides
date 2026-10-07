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

local protected = {
  text=true, textrm=true, textbf=true, textit=true, textsf=true, texttt=true,
  mbox=true, tag=true, label=true, ref=true, eqref=true, unicode=true,
  href=true, class=true, cssId=true, style=true, operatorname=true,
  mnum=true, txt=true
}

local units = { "pt","em","ex","mu","px","mm","cm","in","pc","bp","dd","cc","sp" }

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

-- returns the index just after the balanced {...} group starting at i (s[i]=="{")
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

local function convert(s, raw)
  local out = {}
  local i, n = 1, #s
  local prev = ""          -- kind of previous significant token: "script", "cw" or ""
  while i <= n do
    local c = s:sub(i,i)
    if c == "\\" then
      local name = s:match("^%a+", i + 1)
      if name then
        local j = i + 1 + #name
        out[#out+1] = s:sub(i, j - 1)
        -- protected command followed by a braced argument: copy verbatim
        local k = j
        while s:sub(k,k) == " " do k = k + 1 end
        if protected[name] and s:sub(k,k) == "{" then
          local e = skip_group(s, k)
          out[#out+1] = s:sub(j, e - 1)
          i = e
          prev = ""
        else
          i = j
          prev = "cw"
        end
      else
        -- control symbol (\, \; \\ \{ ...)
        out[#out+1] = s:sub(i, i + 1)
        i = i + 2
        prev = ""
      end
    elseif raw and c == "&" and s:match("^&#?%w+;", i) then
      -- HTML entity inside raw HTML (e.g. &gt; or &#8722;): copy verbatim
      local e = s:match("^&#?%w+;", i)
      out[#out+1] = e
      i = i + #e
      prev = ""
    elseif c == "#" then
      local h = s:match("^#%x+", i) or "#"
      out[#out+1] = h
      i = i + #h
      prev = ""
    elseif c:match("%d") then
      local num = s:match("^%d+%.?%d*", i)
      if num:sub(-1) == "." then num = num:sub(1, -2) end
      if followed_by_unit(s, i + #num) then
        out[#out+1] = num
        i = i + #num
      elseif prev == "script" or prev == "cw" then
        -- TeX would only take one digit as the argument here
        out[#out+1] = "{\\mnum{" .. c .. "}}"
        i = i + 1
      else
        out[#out+1] = "{\\mnum{" .. num .. "}}"
        i = i + #num
      end
      prev = ""
    elseif c == " " then
      out[#out+1] = c
      i = i + 1
      -- keep `prev` (spaces don't change what TeX takes as the argument)
    else
      out[#out+1] = c
      i = i + 1
      prev = (c == "^" or c == "_") and "script" or ""
    end
  end
  return table.concat(out)
end

-- Math written as \( ... \) or \[ ... \] inside raw HTML, e.g. tables made by
-- tinytable/kable/gt, which Pandoc does not parse as Math
local function convert_raw_html(t)
  t = t:gsub("\\%((.-)\\%)", function(m) return "\\(" .. convert(m, true) .. "\\)" end)
  t = t:gsub("\\%[(.-)\\%]", function(m) return "\\[" .. convert(m, true) .. "\\]" end)
  return t
end

-- Default when the YAML does not say; `math-numbers-font: true/false` overrides it
local enabled = false

if FORMAT:match("html") or FORMAT:match("revealjs") then
  return {
    {
      Meta = function(meta)
        local v = meta["math-numbers-font"]
        if v ~= nil then
          -- YAML true/false arrive as booleans; quoted "true"/"false" as strings
          if type(v) == "boolean" then
            enabled = v
          else
            enabled = (pandoc.utils.stringify(v) == "true")
          end
        end
      end
    },
    {
      Math = function(m)
        if not enabled then return nil end
        m.text = convert(m.text)
        return m
      end,
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
