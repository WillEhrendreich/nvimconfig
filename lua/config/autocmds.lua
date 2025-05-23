-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

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

autocmd({ "BufNewFile", "BufReadPre", "BufReadPost", "FileType" }, {
  pattern = { "csproj", "*.fsproj", "cs_project", "fsharp_project" },
  group = grp("ProjAutocommand", { clear = true }),
  callback = function()
    vim.cmd("set commentstring=<!--%s-->")
    vim.bo.syntax = "xml"
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

autocmd("FileType", {
  desc = "odin load overseer",
  group = grp("OdinLoadOverseer", { clear = true }),
  pattern = { "odin" },
  callback = function(event)

    -- vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, nowait = true })
  end,
})

autocmd({ "BufNewFile", "BufReadPre", "FileType" }, {
  desc = "changes comment style, folding for xaml",
  pattern = "*.axaml",
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

-- autocmd("BufReadPost", {
--   desc = "Make sure the filetype automatically is set to include comments.",
--   group = grp("MakeJsonFTJsonC", { clear = true }),
--   pattern = { "json", "*.json" },
--   callback = function(_)
--     -- vim.notify("im totally going to set this filetype to jsonc. dawg")
--     vim.schedule_wrap(function()
--       -- vim.notify("im totally going to set this filetype to jsonc. dawg")
--       vim.cmd("set filetype=jsonc")
--       vim.cmd("set syntax=jsonc")
--       -- vim.b[0].filetype("jsonc")
--       -- vim.notify(
--       --   "im totally going to set this filetype to " .. vim.opt.filetype .. " which by this point i hope is jsonc. dawg"
--       -- )
--     end)
--   end,
-- })

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

autocmd({ "BufReadPost", "FileType" }, {
  group = grp("workspace-diagnostics", { clear = true }),
  pattern = { "*" },
  desc = "Populate workspace diagnostics",
  callback = function()
    if LazyHas("workspace_diagnostics") then
      require("workspace-diagnostics").populate_workspace_diagnostic()
    end
  end,
})

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
