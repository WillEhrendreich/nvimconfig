local util = require("config.util")
return {
  {
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
          version = false, -- last release is way too old
          opts = {
            servers = {

              ---@type IonideOptions
              ionide = {

                IonideNvimSettings = {
                  LspRecommendedColorScheme = true,
                  EnableFsiStdOutTeeToFile = true,
                  FsiStdOutFileName = "./FsiOutput.txt",
                },
                cmd = {
                  -- vim.fs.normalize(vim.fn.stdpath("data") .. "/mason/bin/fsautocomplete.cmd"),
                  util.getMasonBinCommandIfExists("fsautocomplete"),
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
                      "--compilertool:C:/Users/Will.ehrendreich/.dotnet/tools/.store/depman-fsproj/0.2.6/depman-fsproj/0.2.6/tools/net7.0/any",
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
  },
}
