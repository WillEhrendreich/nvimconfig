local util = require("lspconfig.util")
return {
  { "Hoffs/omnisharp-extended-lsp.nvim", lazy = true },
  {
    "seblj/roslyn.nvim",
    args = {
      "--logLevel=Information",
      "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
      "--razorSourceGenerator=" .. vim.fs.joinpath(
        vim.fn.stdpath("data") --[[@as string]],
        "mason",
        "packages",
        "roslyn",
        "libexec",
        "Microsoft.CodeAnalysis.Razor.Compiler.dll"
      ),
      "--razorDesignTimePath=" .. vim.fs.joinpath(
        vim.fn.stdpath("data") --[[@as string]],
        "mason",
        "packages",
        "rzls",
        "libexec",
        "Targets",
        "Microsoft.NET.Sdk.Razor.DesignTime.targets"
      ),
    },
    dependancies = {
      "tris203/rzls.nvim",
    },
    opts = {
      on_attach = function(client, bufnr)
        OnAttach(client, bufnr)
      end,
      handlers = vim.tbl_deep_extend("force", {}, require("rzls.roslyn_handlers"), {
        ["textDocument/definition"] = function(...)
          return require("omnisharp_extended").handler(...)
        end,
      }),
      keys = {
        {
          "gd",
          function()
            require("omnisharp_extended").telescope_lsp_definitions()
          end,
          desc = "Goto Definition",
        },
      },
      settings = {
        ["csharp|background_analysis"] = {
          dotnet_compiler_diagnostics_scope = "fullSolution",
        },
        ["csharp|inlay_hints"] = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
          csharp_enable_inlay_hints_for_lambda_parameter_types = true,
          csharp_enable_inlay_hints_for_types = true,
          dotnet_enable_inlay_hints_for_indexer_parameters = true,
          dotnet_enable_inlay_hints_for_literal_parameters = true,
          dotnet_enable_inlay_hints_for_object_creation_parameters = true,
          dotnet_enable_inlay_hints_for_other_parameters = true,
          dotnet_enable_inlay_hints_for_parameters = true,
          dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = false,
          dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
          dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = false,
        },
        ["csharp|code_lens"] = {
          dotnet_enable_references_code_lens = true,
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
          -- razor = function(path, bufnr)
          --   return "razor",
          --     function(bufnr)
          --       -- comment settings
          --       vim.bo[bufnr].formatoptions = "croql"
          --       vim.bo[bufnr].syntax = "xml"
          --     end
          -- end,
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
  -- { "adamclerk/vim-razor" },
}
