local util = require("lspconfig.util")
return {
  { "Hoffs/omnisharp-extended-lsp.nvim", lazy = true },
  {
    "seblj/roslyn.nvim",
    opts = {
      on_attach = function(client, bufnr)
        OnAttach(client, bufnr)
      end,
      handlers = {
        ["textDocument/definition"] = function(...)
          return require("omnisharp_extended").handler(...)
        end,
      },
      keys = {
        {
          "gd",
          function()
            require("omnisharp_extended").telescope_lsp_definitions()
          end,
          desc = "Goto Definition",
        },
      },
    },

    config = function(_, opts)
      local configs = require("lspconfig.configs")
      require("roslyn").setup(opts)
      configs["roslyn"] = {
        default_config = opts,
      }

      --- ftplugin section ---
      -- vim.filetype.add({
      --   extension = {
      --     csproj = function(path, bufnr)
      --       return "cs_project",
      --         function(buf)
      --           -- vim.bo[buf].syn = "xml"
      --           -- vim.cmd("set syntax= xml")
      --           vim.bo[buf].syntax = "xml"
      --           vim.bo[buf].ro = false
      --           vim.b[buf].readonly = false
      --           vim.opt_local.foldlevelstart = 99
      --           vim.w.fdm = "syntax"
      --         end
      --     end,
      --   },
      -- })

      vim.filetype.add({
        extension = {
          razor = function(path, bufnr)
            return "razor",
              function(bufnr)
                -- comment settings
                vim.bo[bufnr].formatoptions = "croql"
                vim.bo[bufnr].syntax = "xml"
              end
          end,
          cshtml = function(path, bufnr)
            return "cshtml",
              function(bufnr)
                vim.w.fdm = "syntax"
                -- comment settings
                vim.bo[bufnr].formatoptions = "croql"
                vim.bo[bufnr].commentstring = "<!--%s-->"
              end
          end,
          cs = function(path, bufnr)
            return "cs",
              function(bufnr)
                if not vim.g.filetype_cs then
                  vim.g["filetype_cs"] = "cs"
                end
                if not vim.g.filetype_cs == "cs" then
                  vim.g["filetype_cs"] = "cs"
                end
                vim.w.fdm = "syntax"
                -- comment settings
                vim.bo[bufnr].formatoptions = "croql"
                vim.bo[bufnr].commentstring = "// %s"
              end
          end,
          csx = function(path, bufnr)
            return "cs",
              function(bufnr)
                vim.w.fdm = "syntax"
                vim.bo[bufnr].formatoptions = "croql"
              end
          end,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    servers = {
      roslyn = {
        ft = "cs",
      },
    },
    setup = {
      roslyn = function(_, opts) -- code
        require("roslyn").setup(opts)
      end,
    },
  },
  { "adamclerk/vim-razor" },
}
