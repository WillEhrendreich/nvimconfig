-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt
local o = vim.o
local utils = require("config.util")
vim.o.cmdheight = 1
if utils.hasReposEnvironmentVarSet() then
  local odinrepo = utils.getRepoWithName("tree-sitter-odin")
  if odinrepo == "" then
    vim.notify("no odin repo found, cannot add treesitter queries to runtimepath")
  else
    opt.runtimepath:append(odinrepo .. "/queries")
  end
end
vim.g.highlighturl_enabled = true -- highlight URLs by default
-- vim.cmd([[colorscheme  kanagawa]])
-- opt.font

local debugCodeium = utils.getEnvVariableOrDefault("DEBUG_CODEIUM", "info")
if debugCodeium and debugCodeium ~= "warn" and debugCodeium ~= "info" then
  o.cmdheight = 1
else
  o.cmdheight = 0
end
opt.shortmess = "TtlFfOoCcIiWsxnq"
-- opt.guifont = { "JetBrainsMono NF", "h14" }
-- opt.guifontwide = { "JetBrainsMono NF", "h14" }
-- opt.guifont = { "cascadia code", "h14" }
-- opt.guifont = { "Iosevka NF", "h14" }

-- opt.guifont =*
o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
o.foldlevelstart = 99
o.foldenable = true
o.foldcolumn = "auto"
vim.o.fillchars = [[eob: ,fold:,foldopen:,foldsep:│,foldclose:]]
-- vim.o.listchars = [[ tab = "│→", extends = "⟩", precedes = "⟨", trail = "·", nbsp = "␣" ]]
-- opt.completeopt = { "menu", "menuone", "preview" }
opt.kp = ""
opt.shell = "pwsh"
opt.shellcmdflag =
  "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
opt.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
opt.shellquote = ""
opt.shellxquote = ""
vim.o.pumblend = 0
-- vim.o.lazyredraw = false
-- vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
