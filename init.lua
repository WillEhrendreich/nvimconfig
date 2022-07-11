return {
  updater = { skip_prompts = true },
  colorscheme = "terafox",
  lsp = require "user.lsp",
  polish = function()
    vim.g["test#csharp#runner"] = "dotnettest"
    vim.g["test#fsharp#runner"] = "dotnettest"
    vim.g["test#strategy"] = "neovim"
    require "user.globalCommands"
    require "user.autocmds"
  end,
}
