-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
local grp = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd({ "BufNewFile", "BufReadPost", "FileType" }, {
  pattern = { "cs" },
  group = grp("csFTAutocommand", { clear = true }),
  callback = function(event)
    vim.opt.commentstring = "// %s"
    vim.bo.commentstring = "// %s"
  end,
  desc = "sets commentstring for cs files",
})

autocmd({ "FileType" }, {
  pattern = { "fsharp" },
  group = grp("fsharpAutoFormatAutoCommand", { clear = true }),
  callback = function(event)
    vim.b.autoformat = false -- buffer-local
  end,
  desc = "stops autoformat for fsharp buffers",
})
autocmd({ "BufNewFile", "BufReadPre", "BufReadPost", "FileType" }, {
  pattern = { "markdown" },
  group = grp("mdAutoCommand", { clear = true }),
  callback = function(event)
    -- vim.notify("I opened a markdown file and the autocommand saw it")
    -- vim.g.autoformat = false -- globally
    vim.b.autoformat = false -- buffer-local
  end,
  desc = "stops autoformat for md buffers",
})

autocmd({ "BufNewFile", "BufReadPost", "FileType" }, {
  desc = "changes comment style, folding for xaml",
  pattern = "xaml",
  group = grp("xamlCommands", { clear = true }),
  callback = function()
    vim.schedule_wrap(function()
      vim.cmd("set filetype=xml")
      -- vim.cmd("set commentstring=<!--%s-->")
      vim.cmd("let g:xml_syntax_folding=1")
      vim.cmd("set foldmethod=syntax")
      vim.cmd("set foldlevelstart=999  foldminlines=0")
      vim.cmd("set syntax=xml")
    end)
  end,
})

autocmd({ "FileType" }, {
  pattern = { "csproj", "fsproj", "cs_project", "fsharp_project" },
  group = grp("ProjAutocommand", { clear = true }),
  callback = function()
    vim.cmd("set commentstring=<!--%s-->")
    vim.bo.syntax = "xml"
    -- Disable autoformat for project/solution files to avoid LSP formatting attempts
    vim.b.autoformat = false
  end,
  desc = "",
})

-- autocmd({ "BufNewFile", "BufReadPre", "FileType" }, {
--   pattern = { "razor" },
--   group = grp("razorFTAutocommand", { clear = true }),
--   callback = function()
--     -- vim.notify("I opened a razor page")
--
--     vim.bo.filetype = "razor"
--     vim.bo.syntax = "xml"
--
--     vim.bo.commentstring = "<!-- %s -->"
--   end,
--   desc = "",
-- })

autocmd("BufWritePost", {
  desc = "odin build on save",
  group = grp("OdinBuildOnSave", { clear = true }),
  pattern = { "*.odin" },
  callback = function(event)
    local name = vim.api.nvim_buf_get_name(event.buf)
    vim.notify("Building odin file: " .. name)
    vim.cmd("!./build_hot_reload.bat")

    -- vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, nowait = true })
  end,
})

autocmd("FileType", {
  desc = "odin load overseer",
  group = grp("OdinLoadOverseer", { clear = true }),
  pattern = { "odin" },
  callback = function(event)

    -- vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, nowait = true })
  end,
})

autocmd({ "FileType" }, {
  desc = "changes comment style, folding for xaml",
  pattern = "axaml",
  group = grp("axamlCommands", { clear = true }),
  callback = function()
    vim.schedule_wrap(function()
      vim.cmd("set filetype=xml")
      -- vim.cmd("set commentstring=<!--%s-->")
      vim.cmd("let g:xml_syntax_folding=1")
      vim.cmd("set foldmethod=syntax")
      vim.cmd("set foldlevelstart=999  foldminlines=0")
      vim.cmd("set syntax=xml")
    end)
  end,
})

autocmd({ "FileType" }, {
  desc = "Make sure the filetype automatically is set to include comments.",
  group = grp("MakeJsonFTJsonC", { clear = true }),
  pattern = "json",
  callback = function(_)
    -- vim.notify("im totally going to set this filetype to jsonc. dawg")
    vim.schedule_wrap(function()
      vim.notify("im totally going to set this filetype to jsonc. dawg")
      vim.cmd("set filetype=jsonc")
      vim.cmd("set syntax=jsonc")
      -- vim.b[0].filetype("jsonc")
      -- vim.notify(
      --   "im totally going to set this filetype to " .. vim.opt.filetype .. " which by this point i hope is jsonc. dawg"
      -- )
    end)
  end,
})

autocmd({ "BufNewFile", "BufRead" }, {
  desc = "Make sure tex type automatically compiles ",
  group = grp("TexCompileGroup", { clear = true }),
  pattern = "*.tex",
  callback = function(ev)
    vim.cmd("VimtexCompile")

    -- print(string.format("event fired: %s", vim.inspect(ev)))
  end,
})
autocmd("FileType", {
  desc = "Make sure the moon type automatically compiles on save ",
  group = grp("MoonAutoCompile", { clear = true }),
  pattern = "moon",
  callback = function(ev)
    vim.schedule_wrap(function()
      vim.cmd("set syntax=moon")
      print(string.format("event fired: %s", vim.inspect(ev)))
    end)
  end,
})

autocmd({ "BufReadPost", "FileType" }, {
  desc = "Make sure the lua transpiled from moon type automatically re-reads on moon change",
  pattern = "moon",
  group = grp("MoonDerivedAutoRead", { clear = true }),
  callback = function(ev)
    vim.schedule(function()
      local thisActualBufnum = vim.api.nvim_get_current_buf()
      local luaBuffer = (vim.fn.filter(vim.api.nvim_list_bufs(), function(x)
        local basename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(thisActualBufnum), ":p:r")
        local moonfileName = basename .. ".moon"
        local otherName = basename .. ".lua"
        return otherName == vim.fn.fnamemodify(vim.api.nvim_buf_get_name(x), ":p")
      end))[1]
      if luaBuffer and vim.api.nvim_buf_is_loaded(luaBuffer) then
        vim.cmd.buffer(luaBuffer)
        vim.cmd("e!")
        vim.cmd.buffer(thisActualBufnum)
      end
    end)
  end,
})

-- autocmd({ "BufReadPost", "FileType" }, {
--   group = grp("workspace-diagnostics", { clear = true }),
--   pattern = { "*" },
--   desc = "Populate workspace diagnostics",
--   callback = function()
--     if LazyHas("workspace_diagnostics") then
--       require("workspace-diagnostics").populate_workspace_diagnostic()
--     end
--   end,
-- })
--
grp("CppCommands", { clear = true })
autocmd({ "BufNewFile", "BufReadPre", "FileType" }, {
  desc = "changes comment string for cpp and similar files ",
  pattern = { "c", "cpp", "proto", "h", "objc", "cuda" },
  group = "CppCommands",
  callback = function()
    -- vim.cmd("set filetype=xml")
    vim.bo.commentstring = "// %s"
    -- vim.cmd("let g:xml_syntax_folding=1")
    -- vim.cmd("set foldmethod=syntax")
    -- vim.cmd("set foldlevelstart=999  foldminlines=0")
  end,
})
-- vim.bo[bufnr].commentstring = "<!--%s-->"
autocmd("FileType", {
  desc = "Make q close help, man, quickfix, dap floats",
  group = grp("q_close_windows", { clear = true }),
  pattern = { "qf", "help", "man", "dap-float" },
  callback = function(event)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, nowait = true })
  end,
})

-- Strip ANSI escape codes and terminal control sequences from buffer content.
-- Handles: color codes (\x1b[...m), cursor movement (\x1b[1000D, \x1b[?25h),
-- and replaces common UTF-8 arrow sequences (→) with readable text.
vim.api.nvim_create_user_command("StripAnsi", function(opts)
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local cleaned = {}
  for _, line in ipairs(lines) do
    -- Strip all ANSI CSI sequences: ESC[ ... (any params) final byte
    line = line:gsub("\27%[%??[%d;]*[A-Za-z]", "")
    -- Strip bare ESC followed by other patterns
    line = line:gsub("\27%][^\27]*\27\\", "")
    -- Strip any remaining lone ESC chars
    line = line:gsub("\27", "")
    -- Replace UTF-8 arrow → (U+2192, encoded as \xe2\x86\x92 but sometimes
    -- appears as multi-byte \xce\x93\xc3\xa5\xc3\x86 from encoding issues)
    line = line:gsub("\xce\x93\xc3\xa5\xc3\x86", " -> ")
    line = line:gsub("\xe2\x86\x92", " -> ")
    -- Collapse runs of spaces into single space
    line = line:gsub("  +", " ")
    -- Trim leading/trailing whitespace
    line = line:gsub("^%s+", ""):gsub("%s+$", "")
    table.insert(cleaned, line)
  end
  -- Remove consecutive duplicate blank lines
  local result = {}
  local prev_blank = false
  for _, line in ipairs(cleaned) do
    local is_blank = line == ""
    if not (is_blank and prev_blank) then
      table.insert(result, line)
    end
    prev_blank = is_blank
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
  vim.notify(("Stripped ANSI from %d lines -> %d lines"):format(#lines, #result))
end, { desc = "Strip ANSI escape codes and terminal junk from current buffer" })
