local util = require("lspconfig.util")
return {
  -- "neovim/nvim-lspconfig",
  -- opts = {
  --
  --   ---@type lspconfig.options
  --   servers = {
  --
  --     csharp_ls = {
  --       handlers = {
  --         ["textDocument/definition"] = require("csharpls_extended").handler,
  --         ["textDocument/typeDefinition"] = require("csharpls_extended").handler,
  --       },
  --     },
  --     -- you can do any additional lsp server setup here
  --     -- return true if you don't want this server to be setup with lspconfig
  --     ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
  --   },
  --   setup = {
  --     ---@type  fun(server:string, opts:_.lspconfig.options)
  --     csharp_ls = function(server, opts) end,
  --     -- all seperate lsp servers have thier own setup files, for clarity
  --   },
  -- },
}
