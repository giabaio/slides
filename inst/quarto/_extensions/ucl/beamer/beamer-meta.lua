-- beamer-meta.lua
-- Reshapes YAML metadata so the UCL beamer template renders correctly:
--   * flattens institute list-of-{uni:} maps into a proper \institute{}
--     (this fixes the stray "true" pandoc emits when it stringifies a map)
--   * folds date-as-string + conference.name/location/session into \date{}
--   * builds \uclfootertext from author, shorttitle, shortconference,
--     shortdate, so the same YAML that drives the revealjs footer also
--     produces a clean beamer footer
--
-- The strategy is: build the raw \-commands in the filter, inject them
-- via header-includes (which is emitted after pandoc's default \title,
-- \date, \institute calls, so it wins), and null out the corresponding
-- meta fields so pandoc's default template does not emit noise.
--
-- Non-beamer/non-latex outputs are passed through untouched.

local function is_latex()
  return FORMAT:match("beamer") or FORMAT:match("latex")
end

-- Stringify a metadata value; convert HTML &nbsp; (U+00A0) to LaTeX ~
local function to_text(x)
  if x == nil then return "" end
  local s = pandoc.utils.stringify(x)
  s = s:gsub("\194\160", "~")
  return s
end

-- Escape LaTeX specials that would otherwise blow up outside math mode.
-- Deliberately narrow: only %, &, # — leaving \, {, }, ^, ~, $, _ alone
-- so users can still put LaTeX macros in titles/footers if they want.
local function tex_escape(s)
  return (s:gsub("([%%&#])", "\\%1"))
end

-- Extract a list of institute texts from various YAML shapes
local function institute_texts(m)
  local out = {}
  if m == nil then return out end
  if m.t == "MetaList" then
    for _, item in ipairs(m) do
      local text
      if item.t == "MetaMap" and item.uni then
        text = to_text(item.uni)
      elseif item.t == "MetaMap" and item.name then
        text = to_text(item.name)
      else
        text = to_text(item)
      end
      if text ~= "" and text ~= "true" then
        table.insert(out, text)
      end
    end
  elseif m.t == "MetaMap" and m.uni then
    local text = to_text(m.uni)
    if text ~= "" then table.insert(out, text) end
  else
    local text = to_text(m)
    if text ~= "" and text ~= "true" then
      table.insert(out, text)
    end
  end
  return out
end

-- Author name(s) as plain text, handling {name: ...} maps and strings
local function author_name(m)
  if m == nil then return "" end
  if m.t == "MetaList" then
    local names = {}
    for _, item in ipairs(m) do
      if item.t == "MetaMap" and item.name then
        table.insert(names, to_text(item.name))
      else
        local s = to_text(item)
        if s ~= "" and s ~= "true" then table.insert(names, s) end
      end
    end
    return table.concat(names, ", ")
  end
  return to_text(m)
end

function Meta(meta)
  if not is_latex() then return nil end

  local header_extras = {}
  -- FIX: Force LuaLaTeX to load an Emoji font fallback engine
  table.insert(header_extras, "\\usepackage{fontspec}")
  table.insert(header_extras, "\\newfontfamily\\emojifont{Noto Color Emoji}[Renderer=HarfBuzz]")
  table.insert(header_extras, "\\DeclareTextFontCommand{\\textemoji}{\\emojifont}")

  ------------------------------------------------------------------
  -- Institute
  ------------------------------------------------------------------
  local inst_texts = institute_texts(meta.institute)
  if #inst_texts > 0 then
    table.insert(header_extras,
      "\\institute{" .. table.concat(inst_texts, " \\and ") .. "}")
    meta.institute = nil
  end

  ------------------------------------------------------------------
  -- Fallback raw YAML file parser to bypass Quarto's table stripping
  ------------------------------------------------------------------
  local function get_raw_yaml_field(key)
    local file_path = quarto.doc.input_file
    if not file_path then return nil end

    local f = io.open(file_path, "r")
    if not f then return nil end

    local in_yaml = false
    local values = {}
    local capture = false

    for line in f:lines() do
      if line:match("^---") then
        if not in_yaml then
          in_yaml = true
        else
          break
        end
      elseif in_yaml then
        -- Skip commented lines immediately so they do not break our capture logic
        if not line:match("^%s*#") then
          if line:match("^" .. key .. "%s*:") then
            capture = true
          -- FIX: Do not kill capture on a comment; only stop if we hit a new root key
          elseif line:match("^%s*[^%s%-]+%s*:") and not line:match("^%s*text%s*:") and not line:match("^%s*icon%s*:") then
            capture = false
          elseif capture then
            local text_val = line:match("^%s*-%s*text%s*:%s*['\"]?(.-)['\"]?%s*$") or line:match("^%s*text%s*:%s*['\"]?(.-)['\"]?%s*$")
            if text_val then
              table.insert(values, text_val)
            end
          end
        end
      end
    end
    f:close()
    return #values > 0 and values or nil
  end

  -- Robust line string data layout splitter
  local function parse_markdown_link(txt)
    if not txt or txt == "" then return "", "" end
    txt = txt:gsub("\\", "")
    local disp, target = txt:match("%[([^%]]+)%]%(([^%)]+)%)")
    if not target or target == "" then
      target = txt:match("https?://[^%s]+") or txt:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+")
      disp = txt
    end
    if not disp or disp == "" then disp = txt end
    disp = disp:gsub("^https?://", ""):gsub("^mailto:", ""):gsub("^www%.", "")
    return target or "", disp or ""
  end

  local email_parts = {}
  local url_parts = {}
  local gh_parts = {}
  local social_parts = {}

  -- 1. Parse Email
  local raw_email = get_raw_yaml_field("email")
  if raw_email then
    local target, disp = parse_markdown_link(raw_email[1])
    if target ~= "" then
      if not target:match("^mailto:") and target:match("@") then target = "mailto:" .. target end
      table.insert(email_parts, "\\faEnvelope~\\href{" .. target .. "}{\\texttt{" .. disp .. "}}")
    end
  end

  -- 2. Parse Website URLs
  local raw_urls = get_raw_yaml_field("url")
  if raw_urls then
    for _, item in ipairs(raw_urls) do
      local target, disp = parse_markdown_link(item)
      if target ~= "" then
        table.insert(url_parts, "\\faGlobe~\\href{" .. target .. "}{\\texttt{" .. disp .. "}}")
      end
    end
  end

  -- 3. Parse GitHub profiles
  local raw_github = get_raw_yaml_field("github")
  if raw_github then
    for _, item in ipairs(raw_github) do
      local target, disp = parse_markdown_link(item)
      if target ~= "" then
        table.insert(gh_parts, "\\faGithub~\\href{" .. target .. "}{\\texttt{" .. disp .. "}}")
      end
    end
  end

  -- 4. Parse Social accounts (Mastodon, LinkedIn)
  local raw_social = get_raw_yaml_field("social")
  if raw_social then
    for _, item in ipairs(raw_social) do
      local target, disp = parse_markdown_link(item)
      if target ~= "" then
        local icon = "\\faLink"
        if target:match("mas%.to") or disp:match("@") then
          icon = "\\faMastodon"
        elseif target:match("linkedin%.com") then
          icon = "\\faLinkedinIn"
        end
        table.insert(social_parts, icon .. "~\\href{" .. target .. "}{\\texttt{" .. disp .. "}}")
      end
    end
  end

  -- Group them into four clean stacked rows separated by vertical bars (|)
  local rows = {}
  local sep = " \\,\\textbar\\, "
  if #email_parts > 0 then table.insert(rows, table.concat(email_parts, sep)) end
  if #url_parts > 0 then table.insert(rows, table.concat(url_parts, sep)) end
  if #gh_parts > 0 then table.insert(rows, table.concat(gh_parts, sep)) end

  -- FIX: Inject extra vertical space (\\\\[0.05cm]) specifically before the social row
  -- to give it breathing room and separate it from the GitHub links.
  if #social_parts > 0 then
    local social_row = table.concat(social_parts, sep)
    if #rows > 0 then
      table.insert(rows, "[0.05cm] " .. social_row)
    else
      table.insert(rows, social_row)
    end
  end

  -- Inject rows cleanly into our dedicated macro register
  if #rows > 0 then
    local social_tex = "{\\setlength{\\baselineskip}{9pt}" .. table.concat(rows, " \\\\ ") .. "}"
    table.insert(header_extras, "\\providecommand{\\insertsocials}{" .. social_tex .. "}")
    table.insert(header_extras, "\\gdef\\insertsocials{" .. social_tex .. "}")
  end

  ------------------------------------------------------------------
  -- Date + conference
  ------------------------------------------------------------------
  local date_parts = {}
  local ds = to_text(meta["date-as-string"])
  if ds == "" then ds = to_text(meta.date) end
  if ds ~= "" then table.insert(date_parts, ds) end

  if meta.conference then
    local conf = meta.conference
    if conf.t == "MetaMap" or type(conf) == "table" then
      local nm = ""
      if conf.name then nm = to_text(conf.name) end

      if nm ~= "" then
        local loc = ""
        if conf.location then loc = to_text(conf.location) end
        if loc ~= "" then nm = nm .. ", " .. loc end
        table.insert(date_parts, nm)
      end

      local sess = ""
      if conf.session then sess = to_text(conf.session) end
      if sess ~= "" then table.insert(date_parts, sess) end
    end
  end

  meta.date = nil

  if #date_parts > 0 then
    local date_tex = table.concat(date_parts, " \\\\ ")
    meta.date = pandoc.MetaInlines{pandoc.RawInline("latex", date_tex)}
  end

  ------------------------------------------------------------------
  -- Footer
  ------------------------------------------------------------------
  local fparts = {}
  local a = author_name(meta.author)
  if a ~= "" then
    table.insert(fparts, "\\textcopyright{} " .. tex_escape(a))
  end
  for _, key in ipairs({"shorttitle", "shortconference", "shortdate"}) do
    local s = to_text(meta[key])
    if s ~= "" then table.insert(fparts, tex_escape(s)) end
  end

  if #fparts > 0 then
    local footer_tex = table.concat(fparts, " \\textbar{} ")
    table.insert(header_extras,
      "\\def\\uclfootertext{" .. footer_tex .. "}")
  end

  ------------------------------------------------------------------
  -- Inject
  ------------------------------------------------------------------
  if #header_extras > 0 then
    local hi = meta["header-includes"]
    if hi == nil then
      hi = pandoc.MetaList{}
    elseif hi.t ~= "MetaList" then
      hi = pandoc.MetaList{hi}
    end
    for _, raw in ipairs(header_extras) do
      hi:insert(pandoc.MetaBlocks{pandoc.RawBlock("latex", raw)})
    end
    meta["header-includes"] = hi
  end

  return meta
end

-- FIX: Automatically intercept ALL Unicode emojis and wrap them in the fallback font
function Str(el)
  if FORMAT:match("beamer") or FORMAT:match("latex") then
    -- Matches the universal 4-byte Unicode sequence where almost all modern emojis reside
    if el.text:match("\240\159[\128-\191]") then
      return pandoc.RawInline("latex", "\\textemoji{" .. el.text .. "}")
    end
  end
  return el
end

