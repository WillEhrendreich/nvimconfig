local util = require("lspconfig.util")
return {
  { "Hoffs/omnisharp-extended-lsp.nvim", lazy = true },
  {
    "jmederosalvarado/roslyn.nvim",
    lazy = false,
    config = function(_, opts)
      local configs = require("lspconfig.configs")
      require("roslyn").setup(opts)
      -- vim.notify("creating entry in lspconfig configs for roslyn ")
      configs["roslyn"] = {
        default_config = opts,
      }

      --- ftplugin section ---
      vim.filetype.add({
        extension = {
          csproj = function(_, _)
            return "cs_project",
              function(bufnr)
                vim.bo[bufnr].syn = "xml"
                vim.bo[bufnr].ro = false
                vim.b[bufnr].readonly = false
                vim.bo[bufnr].commentstring = "<!--%s-->"
                -- vim.bo[bufnr].comments = "<!--,e:-->"
                vim.opt_local.foldlevelstart = 99
                vim.w.fdm = "syntax"
              end
          end,
        },
      })

      vim.filetype.add({
        extension = {
          razor = function(path, bufnr)
            return "razor",
              function(bufnr)
                -- comment settings
                vim.bo[bufnr].formatoptions = "croql"
                -- vim.bo[bufnr].commentstring = "(*%s*)"
                vim.bo[bufnr].commentstring = "<!--%s-->"
                vim.bo[bufnr].syntax = "xml"
                -- vim.bo[bufnr].commentstring = "//%s"
                -- vim.bo[bufnr].comments = [[s0:*\ -,m0:*\ \ ,ex0:*),s1:(*,mb:*,ex:*),:\/\/\/,:\/\/]]
              end
          end,
          cshtml = function(path, bufnr)
            return "cshtml",
              function(bufnr)
                vim.w.fdm = "syntax"
                -- comment settings
                vim.bo[bufnr].formatoptions = "croql"
                -- vim.bo[bufnr].commentstring = "(*%s*)"
                vim.bo[bufnr].commentstring = "<!--%s-->"
                -- vim.bo[bufnr].comments = [[s0:*\ -,m0:*\ \ ,ex0:*),s1:(*,mb:*,ex:*),:\/\/\/,:\/\/]]
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
                -- vim.bo[bufnr].commentstring = "(*%s*)"
                vim.bo[bufnr].commentstring = "//%s"
                -- vim.bo[bufnr].comments = [[s0:*\ -,m0:*\ \ ,ex0:*),s1:(*,mb:*,ex:*),:\/\/\/,:\/\/]]
              end
          end,
          csx = function(path, bufnr)
            return "cs",
              function(bufnr)
                vim.w.fdm = "syntax"
                -- comment settings
                vim.bo[bufnr].formatoptions = "croql"
                vim.bo[bufnr].commentstring = "//%s"
                -- vim.bo[bufnr].commentstring = "(*%s*)"
                -- vim.bo[bufnr].comments = [[s0:*\ -,m0:*\ \ ,ex0:*),s1:(*,mb:*,ex:*),:\/\/\/,:\/\/]]
              end
          end,
        },
      })
    end,
    dependencies = {
      "neovim/nvim-lspconfig",
    },
  },
  { "adamclerk/vim-razor" },
  -- require("roslyn").setup({
  --   on_attach = require("lazyvim.util.lsp").on_attach,
  -- }),

  --
  -- opts = {
  --   dotnet_cmd = "dotnet",
  -- },
  -- config= function (opts)
  --   dotnet_cmd ="dotnet",
  --
  --
  -- end
}
