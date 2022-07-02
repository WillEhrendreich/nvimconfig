local getDotNetRoot = function(filepath)
  local lsp = require 'lspconfig'
  local root = lsp.util.find_git_ancestor(filepath)
  return root
end

return {
  servers = {
    "clangd",
    "cmake",
    -- "cssls",
    "html",
    -- "intelephense",
    "jsonls",
    "pyright",
    -- "sqls",
    "ionide",
    "omnisharp",
    "sumneko_lua",
    -- "texlab",
    "tsserver",
    "yamlls",
  },
  plugins = {
    ["nvim-lsp-installer"] = {
      ensure_installed = {
        "omnisharp",
        "fsautocomplete",
      },
    },
  },

  skip_setup = { "tsserver", "clangd", "fsautocomplete" },
  ["server-settings"] = {
    clangd = { capabilities = { offsetencoding = "utf-8" } },
    pyright = {
      settings = {
        python = {
          analysis = {
            typecheckingmode = "on",
          },
        },
      },
    },

    omnisharp = {
      root_dir = getDotNetRoot,
      log_level = 2,
      settings =
      {
        FileOptions =
        {
          ExcludeSearchPatterns = {
            '**/node_modules/**/*',
            '**/bin/**/*',
            '**/obj/**/*',
            '/tmp/**/*'
          }
          ,
          SystemExcludeSearchPatterns = {
            '**/node_modules/**/*',
            '**/bin/**/*',
            '**/obj/**/*',
            '/tmp/**/*'
          }
          ,
        },
        FormattingOptions = { EnableEditorConfigSupport = true },
        ImplementTypeOptions =
        {
          InsertionBehavior = 'WithOtherMembersOfTheSameKind',
          PropertyGenerationBehavior = 'PreferAutoProperties',
        },
        RenameOptions =
        {
          RenameInComments = true,
          RenameInStrings  = true,
          RenameOverloads  = true,
        },
        RoslynExtensionsOptions =
        {
          EnableAnalyzersSupport = true,
          EnableDecompilationSupport = true,
          LocationPaths =
          {
            -- 		"~/.omnisharp/Roslynator/src/Analyzers.CodeFixes/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/Analyzers/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/CodeAnalysis.Analyzers.CodeFixes/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/CodeAnalysis.Analyzers/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/CodeFixes/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/CommandLine/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/Common/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/Core/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/CSharp.Workspaces/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/CSharp/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/Documentation/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/Formatting.Analyzers.CodeFixes/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/Formatting.Analyzers/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/Refactorings/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/Workspaces.Common/bin/Debug/netstandard2.0",
            -- 		"~/.omnisharp/Roslynator/src/Workspaces.Core/bin/Debug/netstandard2.0",
          },
        },
      },
    },
    ionide = {
      root_dir = getDotNetRoot,
    },
    sumneko_lua = {
      on_attach = function(client)
        client.server_capabilities.document_formatting = false
        print("sumneko lua attaching to " ..
          vim.fn.expand("%") ..
          " and document formatting is set to " .. vim.inspect(client.server_capabilities.document_formatting))
      end,
    },
    yamlls = {


      settings = {
        yaml = {
          schemas = {
            ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
            ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
            ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
          },
        },
      },
    },
    -- sqls = {
    --   on_attach = function(client, bufnr)
    --     if client.name == "sqls" then
    --       require("sqls").on_attach(client, bufnr)
    --     end
    --   end,
    -- },

    -- texlab = {
    --   settings = {
    --     texlab = {
    --       build = { onsave = true },
    --       forwardsearch = {
    --         executable = "zathura",
    --         args = { "--synctex-forward", "%l:1:%f", "%p" },
    --       },
    --     },
    --   },
    -- },
    --
  },
}
