-- local async = require('hover.async')

-- local function enabled()
--   local word = vim.fn.expand('<cword>')
--   return #vim.spell.check(word) == 0
-- end

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
-- string.format('%%#%s# %s ', hl, p.name)
local source = {
  name = "LSPWithDiag",
  priority = 1000,
  enabled = function()
    -- for _, client in pairs(vim.lsp.get_active_clients()) do
    --   if client then
    --     if
    --       client.supports_method("textDocument/hover") or client.supports_method("textDocument/publishDiagnostics")
    --     then
    return true
    --     end
    --   end
    -- end
    -- return false
  end,
  execute = function(done)
    local util = require("vim.lsp.util")
    -- local baleia = require("baleia").setup({})

    -- vim.api.nvim_create_autocmd("Syntax", {
    --   pattern = "LSPWithDiag",
    --   callback = function(ctx)
    --     vim.schedule(function()
    --       vim.api.nvim_buf_set_option(ctx.buf, "modifiable", true)
    --       baleia.once(ctx.buf)
    --       -- vim.api.nvim
    --
    --       vim.api.nvim_buf_set_option(ctx.buf, "filetype", "markdown")
    --       vim.api.nvim_buf_set_option(ctx.buf, "syntax", "markdown")
    --       vim.api.nvim_buf_set_option(ctx.buf, "modifiable", false)
    --     end)
    --   end,
    -- })

    local params = util.make_position_params()
    ---@type table<string>
    local lines = {}
    vim.lsp.buf_request_all(0, "textDocument/hover", params, function(responses)
      -- vim.notify("responses for hover request " .. vim.inspect(responses))
      local lang = "markdown"
      for _, response in pairs(responses) do
        if response.result and response.result.contents then
          lang = response.result.contents.language or "markdown"
          -- vim.notify("LspResponse Before Conversion to md: \n" .. vim.inspect(response.result.contents))
          lines = util.convert_input_to_markdown_lines(response.result.contents or { kind = "markdown", value = "" })
          lines = util.trim_empty_lines(lines or {})
          -- vim.notify("LspResponse After Conversion to md: \n" .. vim.inspect(lines))
        end
      end

      -- vim.notify("lines before diag")
      -- vim.notify(vim.inspect(lines))
      -- local row, col = unpack(vim.api.nvim_win_get_cursor(0) or {-1,-1})

      local unused
      local _, row = unpack(vim.fn.getpos("."))
      row = row - 1
      -- vim.notify("row " .. row)
      ---@type Diagnostic[]
      local lineDiag = vim.diagnostic.get(0, { lnum = row })
      -- vim.notify("curently " .. #lineDiag .. " diagnostics")
      if #lineDiag > 0 then
        -- table.insert(lines, "<style></style>")
        -- lines = util.convert_input_to_markdown_lines("Diag: ", lines or {})
        -- print("curently " .. #lineDiag .. " diag lines")
        for _, d in pairs(lineDiag) do
          local map = make_highlight_map("")
          if d.message then
            lines = util.trim_empty_lines(util.convert_input_to_markdown_lines({
              language = lang,
              value = string.format("[%s] - %s:%s", d.source, diagnostic_severities[d.severity], d.message),
              -- value = string.format("%s%s - %s", ansi_diagnostic_severities[d.severity], d.source, d.message),
            }, lines or {}))
            -- diaglines = util.convert_input_to_markdown_lines({ d.message })
          end
        end
      end
      for _, l in pairs(lines) do
        l = StringReplace(l, "\r", "")
      end
      -- vim.notify("lines after diag")
      -- vim.notify(vim.inspect(lines))

      if not vim.tbl_isempty(lines) then
        done({ lines = lines, filetype = "markdown" })
        return
      end
      -- no results
      done()
    end)
  end,
}
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
return {
  "lewis6991/hover.nvim",
  opts = {
    init = function()
      -- re providers
      -- require("hover.providers.lsp")

      -- makeGlowForRepos()
      -- require("hover.providers.lsp")
      require("hover").register(source)
      -- require("hover").register(helpSource)
      require("hover.providers.gh")

      -- re('hover.providers.jira')
      -- re "hover.providers.man"
      -- require("hover.providers.dictionary")
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
