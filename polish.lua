return function()
    vim.g["test#csharp#runner"] = "dotnettest"
    vim.g["test#fsharp#runner"] = "xunit"
    vim.g["test#strategy"] = "neovim"
    vim.g["fsharp#workspace_mode_peek_deep_level"]= 5
    vim.g["fsharp#show_signature_on_cursor_move"]= 0
    require "user.globalCommands"
    require "user.autocmds"
end
