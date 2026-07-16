-- colour-spans.lua
-- Maps [text]{.classname} spans to LaTeX \textcolor{classname}{text}
-- (and handles a few non-colour utility classes) when the output
-- is beamer/latex. All other formats are passed through unchanged.

local colour_classes = {
  -- basics
  ["red"]              = "red",
  ["blue"]             = "blue",
  ["magenta"]          = "magenta",
  ["orange"]           = "orange",
  ["olive"]            = "olive",
  ["lightgray"]        = "lightgray",
  -- named UCL palette
  ["myred"]            = "myred",
  ["myblue"]           = "myblue",
  ["uclblue"]          = "uclblue",
  ["ubuntublue"]       = "ubuntublue",
  ["navbargrey"]       = "navbargrey",
  -- flags / mixes
  ["spanish-red"]      = "spanish-red",
  ["spanish-yellow"]   = "spanish-yellow",
  ["italian-green"]    = "italian-green",
  ["italian-red"]      = "italian-red",
  ["blue90red60"]      = "blue90red60",
  ["blue60red90"]      = "blue60red90",
  -- app-specific
  ["beamer-yellow"]    = "beamer-yellow",
  ["samp-blue"]        = "samp-blue",
  ["samp-red"]         = "samp-red",
  -- can add more if necessary using the same structure. The actual definition
  -- of the named colours is in the ucl-beamer.tex file
}

-- Non-colour utilities: map class -> LaTeX command name.
-- The commands are defined at the end of ucl-beamer.tex.
local util_classes = {
  ["faded"]         = "faded",
  ["faded-small"]   = "fadedsmall",
  ["magic-marker"]  = "magicmarker",
  ["monospace"]     = "uclmonospace",
  ["imitate-title"] = "imitatetitle",
  ["no-link"]       = "nolink",
}

local function is_latex()
  return FORMAT:match("beamer") or FORMAT:match("latex")
end

local function wrap(cmd, content)
  local out = { pandoc.RawInline("latex", "\\" .. cmd .. "{") }
  for _, x in ipairs(content) do table.insert(out, x) end
  table.insert(out, pandoc.RawInline("latex", "}"))
  return out
end

-- colour-spans.lua (Replace the Span function at the bottom with this version)

-- colour-spans.lua (Replace the Span function at the bottom with this version)

function Span(el)
  if not is_latex() then return nil end

  for _, cls in ipairs(el.classes) do
    if colour_classes[cls] then
      local cname = colour_classes[cls]

      -- FIX: Intercept BOTH DisplayMath ($$..$$) and InlineMath ($..$) inside spans
      if #el.content > 0 then
        for _, item in ipairs(el.content) do
          if item.t == "Math" then
            -- Safely apply math-mode coloring directly to the formula payload string
            item.text = "\\mathcolor{" .. cname .. "}{" .. item.text .. "}"

            -- Return the clean math object directly, stripping the broken text \textcolor wrapper completely
            return item
          end
        end
      end

      -- Standard text inline fallback loop (unchanged for normal paragraphs)
      local out = { pandoc.RawInline("latex", "\\textcolor{" .. cname .. "}{") }
      for _, x in ipairs(el.content) do table.insert(out, x) end
      table.insert(out, pandoc.RawInline("latex", "}"))
      return out

    elseif util_classes[cls] then
      return wrap(util_classes[cls], el.content)
    end
  end
  return nil
end

