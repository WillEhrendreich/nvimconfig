-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
local utils = require("config.util")
vim.o.cmdheight = 1
vim.g.highlighturl_enabled = true -- highlight URLs by default

local debugCodeium = utils.getEnvVariableOrDefault("DEBUG_CODEIUM", "info")
if debugCodeium and debugCodeium ~= "warn" and debugCodeium ~= "info" then
  opt.cmdheight = 1
else
  opt.cmdheight = 0
end
opt.shortmess = "TtlFfOoCcIiWsxnq"

opt.commentstring = "// %s"
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldcolumn = "auto"
vim.o.fillchars = [[eob: ,fold:,foldopen:,foldsep:│,foldclose:]]

-- vim.o.listchars = [[ tab = "│→", extends = "⟩", precedes = "⟨", trail = "·", nbsp = "␣" ]]
-- opt.completeopt = { "menu", "menuone", "preview" }

opt.kp = ""
if vim.uv.os_uname().sysname ~= "Linux" then
  opt.shell = "pwsh"
  opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  -- opt.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
  opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  opt.shellquote = ""
  opt.shellxquote = ""
end

vim.o.pumblend = 0

if vim.opt.diff:get() == true then
  opt.wrap = true
  vim.cmd.colorscheme("tokyonight-night")
  vim.cmd("tokyonight-night")
end

opt.winborder = "rounded"
