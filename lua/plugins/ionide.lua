return {

  -- add json to treesitter
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = function(_, opts)
  --     if type(opts.ensure_installed) == "table" then
  --       vim.list_extend(opts.ensure_installed, { "json", "json5", "jsonc" })
  --     end
  --   end,
  -- },

  -- correctly setup lspconfig
  {
    -- "ionide/ionide-vim",
    -- dependencies = {
    --   "neovim/nvim-lspconfig",
    -- },
    -- config = true,
    "WillEhrendreich/ionide-vim",
    dir = vim.fn.getenv("repos") .. "/ionide-vim/",
    dev = true,

    dependencies = {
      "neovim/nvim-lspconfig",
      version = false, -- last release is way too old
    },
    -- config=    local inp = vim.fn.input("please attach debugger")
    -- opts = {
    --   -- make sure mason installs the server
    --   servers = {
    --     -- ---@type  lspconfig.options.fsautocomplete
    --     ionide = {
    --       -- on_new_config = function(new_config)
    --       -- new_config.settings.json.schemas = new_config.settings.json.schemas or {}
    --       -- vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
    --       -- end,
    --       mason = false, -- set to false if you don't want this server to be installed with mason
    --       autostart = true,
    --       filetypes = { "fsharp", "fsharp_project" },
    --       name = "ionide",
    --       -- single_file_support = false,
    --       settings = {
    --         FSharp = {},
    --       },
    --       -- cmd = { 'fsautocomplete', '--adaptive-lsp-server-enabled', '-v' },
    --       cmd = (function()
    --         return {
    --           -- "C:/Users/Will.ehrendreich/source/repos/FsAutoComplete/src/FsAutoComplete/bin/Debug/net6.0/publish/fsautocomplete.exe",
    --           "fsautocomplete",
    --           "--adaptive-lsp-server-enabled",
    --           -- "-l .fsautocomplete.log",
    --           "-v",
    --           "--wait-for-debugger",
    --           -- '--attach-debugger',
    --           -- "--project-graph-enabled",
    --         }
    --       end)(),
    --       on_attach = require("plugins.lsp").opts.on_attach,
    --
    --       -- settings = {},
    --     },
    --   },
    -- },
  },
}
