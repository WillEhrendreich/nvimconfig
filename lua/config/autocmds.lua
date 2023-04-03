-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
local grp = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
grp("xamlCommands", { clear = true })
autocmd({ "BufNewFile", "BufReadPre", "FileType" }, {
  desc = "changes comment style, folding for xaml",
  pattern = "*.xaml",
  group = "xamlCommands",
  callback = function()
    vim.cmd("set filetype=xml")
    vim.cmd("set commentstring=<!--%s-->")
    vim.cmd("let g:xml_syntax_folding=1")
    vim.cmd("set foldmethod=syntax")
    vim.cmd("set foldlevelstart=999  foldminlines=0")
  end,
})

grp("CppCommands", { clear = true })
autocmd({ "BufNewFile", "BufReadPre", "FileType" }, {
  desc = "changes comment style, folding for xaml",
  pattern = { "c", "cpp", "proto", "h", "objc", "cuda" },
  group = "CppCommands",
  callback = function()
    -- vim.cmd("set filetype=xml")
    vim.cmd("set commentstring=" .. "//" .. "%s")
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
