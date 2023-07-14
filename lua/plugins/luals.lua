return {

  "neovim/nvim-lspconfig",

  ---@type lspconfig.options
  servers = {
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = {
            workspaceEvent = "OnSave",
          },
          codeLens = { enable = true },
        },
      },
    },
  },
}
