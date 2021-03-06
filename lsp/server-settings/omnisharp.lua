local getGitRoot = function(filepath)
  local lsp = require 'lspconfig'
  local root = lsp.util.find_git_ancestor(filepath)
  return root
end
return {
      root_dir = getGitRoot,
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
    }

