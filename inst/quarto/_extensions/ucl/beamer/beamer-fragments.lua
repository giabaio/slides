-- beamer-fragments.lua
-- Maps revealjs classes, normalizes inline script tokens, and fixes code block headers for Beamer

local function is_latex()
  return FORMAT:match("beamer") or FORMAT:match("latex")
end

-- 1. Keep headers clean so math slides remain safe from verbatim parsing
function Header(el)
  if not is_latex() then return nil end
  return el
end

-- 2. Intercept and safely sanitize math color macros for Beamer
function Math(el)
  if not is_latex() then return nil end
  local math_txt = el.text
  if math_txt:match("\\color%b{}%b{}") then
    local color_name, math_content = math_txt:match("\\color{(.-)}{(.-)}")
    if color_name and math_content then
      el.text = "\\mathcolor{" .. color_name .. "}{" .. math_content .. "}"
      return el
    end
  end
  return el
end

-- 3. FIX: Render CodeBlocks cleanly while erasing conflicting revealjs animation attributes
function CodeBlock(el)
  if not is_latex() then return nil end

  -- Clear any attributes from the block attributes list table so they don't leak strings into LaTeX
  if el.attributes then
    el.attributes["code-line-numbers"] = nil
  end

  local code = el.text

  -- If the code block text still contains the raw chunk configuration line, erase it
  if code:match("^{css%s.-}") or code:match("^{r%s.-}") then
    code = code:gsub("^{.-}\n", "")
  end

  -- Escape hash characters (#) so hex colors and comments don't trigger macro parameter errors
  code = code:gsub("#", "\\#")

  -- Escape literal dollar sign characters ($) to protect R operations
  code = code:gsub("%$", "\\$")

  -- Escape single quotes (') with literal quote text commands (\textquotesingle)
  code = code:gsub("'", "{\\textquotesingle}")

  -- If the code block is printing literal math environment code strings,
  -- escape the structural backslashes so unicode-math skips scanning them safely.
  if code:match("\\begin") or code:match("gather") or code:match("align") then
    code = code:gsub("\\", "\\textbackslash ")
    code = code:gsub("{", "\\{")
    code = code:gsub("}", "\\}")
    code = code:gsub("&", "\\&")
    code = code:gsub("_", "\\_")
    code = code:gsub("\n", " \\\\ \n")

    local safe_latex = "{\\ttfamily\\footnotesize\\setlength{\\baselineskip}{9pt}\n"
                       .. code .. "\n}"
    return pandoc.RawBlock("latex", safe_latex)
  end

  -- Convert linebreaks to clean LaTeX newline blocks safely
  code = code:gsub("\n", " \\\\ ")

  -- Fallback layout style for standard programming code boxes
  local latex_code = "\\begin{tcolorbox}[colback=lightgray!40, colframe=navbargrey, arc=2pt, boxrule=0.5pt, fontupper=\\ttfamily\\footnotesize]\n"
                     .. code .. "\n\\end{tcolorbox}"

  return pandoc.RawBlock("latex", latex_code)
end

-- 4. Safely parse inline code tokens (`r vspace(...)`) to stop character traps
function Code(el)
  if not is_latex() then return nil end
  if el.text:match("^r%s+") or el.text:match("vspace") then
    return pandoc.RawInline("latex", "\\relax")
  end
  return el
end

-- 5. Handle Slide Layout Divs (.small frames and revealjs fragments) safely
function Div(el)
  if not is_latex() then return nil end

  if el.classes:includes("small") then
    for i, class in ipairs(el.classes) do
      if class == "small" then
        table.remove(el.classes, i)
        break
      end
    end
    table.insert(el.content, 1, pandoc.RawBlock("latex", "\\small"))
    return el.content
  end

  if el.classes:includes("fragment") then
    table.insert(el.content, 1, pandoc.RawBlock("latex", "\\uncover<+->{"))
    table.insert(el.content, pandoc.RawBlock("latex", "}"))
    return el.content
  end
end

function Span(el)
  if not is_latex() then return nil end
  if el.classes:includes("fragment") then
    table.insert(el.content, 1, pandoc.RawInline("latex", "\\uncover<+->{"))
    table.insert(el.content, pandoc.RawInline("latex", "}"))
    return el.content
  end
end
