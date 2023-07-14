local null_ls = require("null-ls")
return {
  {
    "WillEhrendreich/ionide-vim",
    dir = vim.fn.getenv("repos") .. "/ionide-vim/",
    dev = true,
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
          version = false, -- last release is way too old
          opts = {
            servers = {

              ---@type IonideOptions
              ionide = {

                IonideNvimSettings = {
                  LspRecommendedColorScheme = true,
                },
                cmd = {
                  -- "C:/.local/share/nvim-data/mason/bin/fsautocomplete.cmd",

                  vim.fs.normalize(vim.fn.stdpath("data") .. "/mason/bin/fsautocomplete.cmd"),
                  -- "-l",
                  -- ".fsautocomplete.log",
                  -- "-v",
                  -- '--wait-for-debugger',
                  -- "--project-graph-enabled",
                },
                settings = {
                  FSharp = {
                    enableMSBuildProjectGraph = true,
                    -- enableTreeView = true,
                    fsiExtraParameters = {
                      "--compilertool:C:/Users/Will.ehrendreich/.dotnet/tools/.store/depman-fsproj/0.2.4/depman-fsproj/0.2.4/tools/net6.0/any",
                    },
                  },
                },
              },
            },
            -- you can do any additional lsp server setup here
            -- return true if you don't want this server to be setup with lspconfig
            ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
            setup = {
              ionide = function(_, opts)
                -- local inp = vim.fn.input("please attach debugger")
                require("ionide").setup(opts)
              end,
              fsautocomplete = function(_, _)
                return true
              end,
            },
          },
        },
      },
    },
  },
}
