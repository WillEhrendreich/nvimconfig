local diag = require("vim.diagnostic")
local sampleDiagnostic = {
  bufnr = 11,
  code = "20",
  col = 6,
  end_col = 44,
  end_lnum = 237,
  lnum = 237,
  message = "The result of this expression has type 'IXLWorksheet option' and is implicitly ignored. Consider using 'ignore' to discard this value explicitly, e.g. 'expr |> ignore', or 'let' to bind the result to a name, e.g. 'let result = expr'.",
  namespace = 49,
  severity = 2,
  source = "F# Compiler",
  user_data = {
    lsp = {
      code = "20",
      codeDescription = {
        href = "https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/compiler-messages/fs0020",
      },
      relatedInformation = {},
    },
  },
}
-- Default diagnostic highlights
local diagnostic_severities = {
  [diag.severity.ERROR] = "ERROR",
  [diag.severity.WARN] = "WARN",
  [diag.severity.INFO] = "INFO",
  [diag.severity.HINT] = "HINT",
}

local ansi_diagnostic_severities = {
  [diag.severity.ERROR] = "\x1b[31m",
  [diag.severity.WARN] = "\x1b[33m",
  [diag.severity.INFO] = "\x1b[36m",
  [diag.severity.HINT] = "\x1b[37m",
}
-- Make a map from DiagnosticSeverity -> Highlight Name
---@private
local function make_highlight_map(base_name)
  local result = {}
  for k in pairs(diagnostic_severities) do
    local name = vim.diagnostic.severity[k]
    name = name:sub(1, 1) .. name:sub(2):lower()
    result[k] = "Diagnostic" .. base_name .. name
  end

  return result
end

local helpSource = {

  name = "help",
  priority = 800,
  enabled = function()
    return true
  end,

  execute = function(done)
    local word = vim.fn.expand("<cword>")
    -- local stdout = vim.loop.new_pipe(false)
    -- vim.api.nvim_buf_call()
    -- require("hover.async.job").job({":help","popd"})
    --
    --
    local job = require("hover.async.job").job

    ---@type string[]
    local output = job({
      "help",
      word,
    })

    -- local results = process(output)
    -- if not results then
    --   results = { "no definition for " .. word }
    -- end
    done(output and { lines = output, filetype = "markdown" })
  end,
}

-- local function parse_string(input_string)
--   local link_pattern = "<a href='command:(.-)%?(.-)'>"
--   local function_capture, json_capture = input_string:match(link_pattern)
--   if function_capture and json_capture then
--     local function_name = function_capture:match("^(.-)%s"):gsub(".", "/")
--     local unHtmlify = json_capture:gsub("%%%x%x", function(entity)
--       return string.char(tonumber(entity:sub(2), 16))
--     end)
--     -- print("unHtmlify :", unHtmlify)
--     unHtmlify = unHtmlify
--     -- print("unHtmlify :", unHtmlify)
--     ---@table
--     local decoded_json = vim.json.decode(unHtmlify)
--     local label_text = input_string:match(">(.-)<")
--     return function_name, unHtmlify, decoded_json, label_text
--   else
--     return input_string, "", "", ""
--   end
-- end
--
-- local function parselinesForfsharpDocs(lines)
--   -- value = string.gsub(value, "\r\n?", "\n")
--   -- <a href='command:fsharp.showDocumentation?%5B%7B%20%22XmlDocSig%22%3A%20%22%22%2C%20%22AssemblyName%22%3A%20%22excel%22%20%7D%5D'>Open the documentation</a>
--   -- local lines = vim.split(value, "\n", { trimempty = true })
--   for _, line in pairs(lines) do
--     -- value = string.gsub(line, "<a href='command:", "\n")
--     local parsedOrFunctionName, escapedHtml, decodedJsonTable, labelText = parse_string(line)
--     if parsedOrFunctionName then
--       if not line == parsedOrFunctionName then
--         vim.lsp.buf_request(0, parsedOrFunctionName, (decodedJsonTable or {}), function(e, r, c, con)
--           if r then
--             if r.result then
--               if r.result.contents then
--                 line = "['" .. labelText .. "'](" .. vim.inspect(r.result.contents) .. ")"
--               end
--             end
--           end
--         end)
--       end
--     end
--   end
--
--   return lines
-- end
--
local function makeGlowForRepos()
  local hover = require("hover")
  local Job = require("plenary.job")
  -- local baleia = require("baleia").setup({})

  local repo_pattern = "[^%s]+/[^%s]+"

  vim.api.nvim_create_autocmd("Syntax", {
    pattern = "glow",
    callback = function(ctx)
      vim.schedule(function()
        vim.api.nvim_buf_set_option(ctx.buf, "modifiable", true)
        -- baleia.once(ctx.buf)
        vim.api.nvim_buf_set_option(ctx.buf, "modifiable", false)
      end)
    end,
  })

  local function enabled()
    return vim.fn.expand("<cfile>"):match(repo_pattern) ~= nil
  end

  local function execute(done)
    local repo = vim.fn.expand("<cfile>"):match(repo_pattern)

    Job:new({
      command = "glow",
      args = { "github.com/" .. repo, "-s", "dark" },
      on_exit = function(job)
        done({ lines = job:result(), filetype = "glow" })
      end,
    }):start()
  end

  hover.register({
    name = "GitHub repos",
    priority = 1050,
    enabled = enabled,
    execute = execute,
  })
end

--- Splits a string into a table of strings.
---@param toSplit string String to be split.
---@param separator string|nil The separator. If not defined, the separator is set to "%S+".
---@return table Table of strings split by the separator.
local split = function(toSplit, separator)
  if separator == nil then
    separator = "%S+"
  end

  if toSplit == nil then
    return {}
  end

  local chunks = {}
  if type(toSplit) == "table" then
    for _, val in ipairs(toSplit) do
      for substring in string.gmatch(vim.inspect(val), separator) do
        vim.notify("chunk \n" .. substring .. " \n being added to table")
        chunks = vim.tbl_deep_extend("force", chunks, { substring })
      end
    end
  else
    for substring in string.gmatch(vim.inspect(toSplit), separator) do
      -- vim.notify("chunk \n" .. substring .. " \n being added to table")
      chunks = vim.tbl_deep_extend("force", chunks, { substring })
    end
  end
  return chunks
end

--- Join the elemnets of a table into a string with a delimiter.
---@param tbl table Table to be joined.
---@param delim string Delimiter to be used.
---@return string Joined string.
local joint_table = function(tbl, delim)
  local result = ""
  for idx, chunk in pairs(tbl) do
    result = result .. chunk
    if idx ~= #tbl then
      result = result .. delim
    end
  end
  return result
end

--- Check if a table contains desired element. vim.tbl_contains does not work for all cases.
---@param tbl table Table to be checked.
---@param el string Element to be checked.
---@return boolean True if the table contains the element, false otherwise.
local tbl_contains = function(tbl, el)
  if not el then
    return false
  end
  if not tbl then
    return false
  end

  for _, v in pairs(tbl) do
    if el:find(v) then
      return true
    end
  end
  return false
end
---Converts a string returned by response.result.contents.value from vim.lsp[textDocument/hover] to markdown.
---@param toConvert string|table Documentation of the string to be converted.
---@param opts table? Table of options to be used for the conversion to the markdown language.
---@return table Converted table of strings from doxygen to markdown.
local convert_to_markdown = function(toConvert, opts)
  opts = vim.tbl_deep_extend("force", opts or {}, {
    line = {
      "@brief",
    },
    word = {
      "@param",
      "@tparam",
      "@see",
    },
    header = {
      "@class",
    },
    stylers = {
      line = "**",
      word = "`",
      header = "###",
    },
    border = "rounded",
  })
  local result = {}
  local firstParam = true
  local firstSee = true
  local chunks = {}

  if type(toConvert) == "table" then
    for _, chunk in ipairs(toConvert) do
      table.insert(chunks, chunk)
    end
  else
    chunks = split(toConvert, "([^\n]*)\n?")
  end

  if #chunks == 0 then
    return result
  end

  for _, chunk in pairs(chunks) do
    local tbl = split(chunk)
    local el = tbl[1]

    if tbl_contains(opts.line, el) then
      table.remove(tbl, 1)
      chunk = joint_table(tbl, " ")
      table.insert(result, opts.stylers.line .. chunk .. opts.stylers.line)
      table.insert(result, "")
    elseif tbl_contains(opts.header, el) then
      table.remove(tbl, 1)
      chunk = joint_table(tbl, " ")
      table.insert(result, opts.stylers.header .. " " .. chunk)
      table.insert(result, "")
    elseif tbl_contains(opts.word, el) then
      tbl[2] = opts.stylers.word .. tbl[2] .. opts.stylers.word
      table.remove(tbl, 1)
      chunk = joint_table(tbl, " ")

      if firstParam and el == "@param" then
        firstParam = false
        table.insert(result, "---")
      elseif firstSee and el == "@see" then
        firstSee = false
        table.insert(result, "---")
        table.insert(result, "**See**")
      end

      table.insert(result, chunk)
    else
      table.insert(result, chunk)
    end
  end
  return result
end
--
-- local function split_lines(value)
--   value = string.gsub(value, "\r\n?", "\n")
--   return vim.split(value, "\n", { trimempty = true })
-- end
--
-- local function convert_input_to_lines(input, contents)
--   contents = contents or {}
--   -- MarkedString variation 1
--   if type(input) == "string" then
--     vim.list_extend(contents, split_lines(input))
--   else
--     if input.kind then
--       local value = input.value or ""
--       vim.list_extend(contents, split_lines(value))
--     elseif input.language then
--       -- Some servers send input.value as empty, so let's ignore this :(
--       -- assert(type(input.value) == 'string')
--       table.insert(contents, input.language)
--       vim.list_extend(contents, split_lines(input.value or ""))
--       -- By deduction, this must be MarkedString[]
--     else
--       -- Use our existing logic to handle MarkedString
--       for _, marked_string in ipairs(input) do
--         convert_input_to_lines(marked_string, contents)
--       end
--     end
--   end
--   if (contents[1] == "" or contents[1] == nil) and #contents == 1 then
--     return {}
--   end
--   return contents
-- end

local LSPWithDiagSource = {
  name = "LSPWithDiag",
  priority = 1000,
  enabled = function()
    return true
  end,
  execute = function(done)
    local util = require("vim.lsp.util")

    local params = util.make_position_params()
    ---@type table<string>
    local lines = {}

    vim.lsp.buf_request_all(0, "textDocument/hover", params, function(responses)
      -- vim.notify("responses for hover request " .. vim.inspect(responses))
      local lang = "markdown"
      for _, response in pairs(responses) do
        if response.result and response.result.contents then
          lang = response.result.contents.language or "markdown"
          local contents = response.result.contents

          -- if vim.lsp.get_active_clients({ bufnr = 0, name = "ionide" })[1] then
          --   -- if lang == "fsharp" then
          --   lines = util.convert_input_to_markdown_lines(
          --     convert_to_markdown(
          --       require("ionide").ParseAndReformatShowDocumentationFromHoverResponseContentLines(contents or { "" })
          --     )
          --   )
          -- end
          -- else
          -- vim.notify("responses for hover request " .. vim.inspect(contents))
          lines = convert_to_markdown(util.convert_input_to_markdown_lines(contents) or {}, nil)
          -- end
          -- lines = parselinesForfsharpDocs(lines)
          lines = util.trim_empty_lines(lines or {})
        end
      end

      local unused
      local _, row = unpack(vim.fn.getpos("."))
      row = row - 1
      -- vim.notify("row " .. row)
      ---@type Diagnostic[]
      local lineDiag = vim.diagnostic.get(0, { lnum = row })
      -- vim.notify("curently " .. #lineDiag .. " diagnostics")
      if #lineDiag > 0 then
        for _, d in pairs(lineDiag) do
          if d.message then
            lines = util.trim_empty_lines(util.convert_input_to_markdown_lines({
              language = lang,
              value = string.format("[%s] - %s:%s", d.source, diagnostic_severities[d.severity], d.message),
            }, lines or {}))
          end
        end
      end
      -- for _, l in pairs(lines) do
      --   l = l:gsub("\r", "")
      -- end

      if not vim.tbl_isempty(lines) then
        done({ lines = lines, filetype = "markdown" })
        return
      end
      -- no results
      done()
    end)
  end,
}
return {
  "lewis6991/hover.nvim",
  opts = {
    init = function()
      require("hover").register(LSPWithDiagSource)
      require("hover.providers.gh")
    end,
    preview_opts = {
      border = nil,
    },
    -- Whether the contents of a currently open hover window should be moved
    -- to a :h preview-window when pressing the hover keymap.
    preview_window = false,
    title = true,
    -- Setup keymaps
    -- vim.keymap.set("n", "K", function()
    -- require("hover").hover()
    -- end, { desc = "hover.nvim" }),
    -- vim.keymap.set("n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
  },
}
