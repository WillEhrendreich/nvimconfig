local util = require("config.util")
---@class _.lspconfig.options
---@field root_dir fun(filename, bufnr): string|nil
---@field name string
---@field filetypes string[] | nil
---@field autostart boolean
---@field single_file_support boolean
---@field on_new_config fun(new_config, new_root_dir)
---@field capabilities table
---@field cmd string[]
---@field handlers table<string, fun()>
---@field init_options table
---@field on_attach fun(client, bufnr)
---

---@class lspconfig.options.fsautocomplete: _.lspconfig.options
---@field settings lspconfig.settings.fsautocomplete
---

return {
  "WillEhrendreich/Ionide-nvim",
  dev = util.hasRepoWithName("Ionide-nvim"),
  dir = util.getRepoWithName("Ionide-nvim"),
  dependencies = {
    {
      "williamboman/mason.nvim",
      opts = {
        ensure_installed = {
          "fsautocomplete",
        },
      },
      {
        "neovim/nvim-lspconfig",
        opts = {
          servers = {

            ---@type IonideOptions
            ionide = {

              IonideNvimSettings = {
                -- LspRecommendedColorScheme = true,
                EnableFsiStdOutTeeToFile = true,
                ShowSignatureOnCursorMove = false,
                FsiStdOutFileName = "./FsiOutput.txt",
              },
              cmd = {
                util.getMasonBinCommandIfExists("fsautocomplete"),
              },
              settings = {
                FSharp = {
                  enableMSBuildProjectGraph = true,
                  -- enableTreeView = true,
                  -- fsiExtraParameters = {
                  --   "--compilertool:C:/Users/Will.ehrendreich/.dotnet/tools/.store/depman-fsproj/0.2.6/depman-fsproj/0.2.6/tools/net7.0/any",
                  -- },
                },
              },
            },
          },
          -- you can do any additional lsp server setup here
          -- return true if you don't want this server to be setup with lspconfig
          ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
          setup = {
            ionide = function(_, opts)
              -- print("setup ionide")
              require("ionide").setup(opts)
            end,
            -- NOTE: returning true will make sure fsautocomplete is not setup with neovim, which is what we want if we're using Ionide-nvim
            fsautocomplete = function(_, _)
              return true
            end,
          },
        },
      },
    },
  },
}
