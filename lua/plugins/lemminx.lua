---@param client vim.lsp.Client
---@param bufnr integer
local customOnAttach = function(client, bufnr)
  if client.name == "lemminx" then
    local ft = vim.bo[bufnr].filetype
    local isDotnet = ft == "csx"
      or ft == "cs"
      or ft == "csproj"
      or ft == "cs_project"
      or ft == "razor"
      or ft == "cshtml"
      or ft == "vb"
      or ft == "cs"
      or ft == "fsharp"
      or ft == "fsharp_project"
    if isDotnet then
      vim.diagnostic.enable(false)
    end
    if not client.server_capabilities.hoverProvider then
      client.server_capabilities.hoverProvider = true
    end
  end
  OnAttach(client, bufnr)
end

return {
  {
    "neovim/nvim-lspconfig",

    opts = {
      servers = {
        lemminx = {

          cmd = {
            vim.fs.normalize((vim.fn.stdpath("data") or "c:/.local/share/nvim-data") .. "/mason/bin/lemminx.cmd"),
          },
          filetypes = { "xml", "fsharp_project", "cs_project" },
          on_attach = customOnAttach,
          settings = {
            xml = {
              java = {
                --.home: Specifies the folder path to the JDK (8 or more recent)
                -- used to launch the XML Language Server if the Java server is being run.
                -- If not set, falls back to either the
                -- java.home preference or the JAVA_HOME or JDK_HOME environment variables.
                home = "",
              },
              server = {
                -- server.vmargs: Specifies extra VM arguments used to launch the XML Language Server.
                -- Eg. use -Xmx1G -XX:+UseG1GC -XX:+UseStringDeduplication to bypass class verification,
                -- increase the heap size to 1GB and enable String deduplication with the G1 Garbage collector.
                vmargs = {},
                -- server.workDir: Set a custom folder path for cached XML Schemas.
                -- An absolute path is expected, although the ~ prefix (for the user home directory) is supported.
                -- Default is ~/.lemminx.
                workDir = {},
                -- server.preferBinary: If this setting is enabled,
                -- a binary version of the server will be launched even if Java is installed.
                preferBinary = false,
                binary = {
                  -- server.binary.path: Specify the path of a custom binary version of the XML server to use.
                  -- A binary will be downloaded if this is not set.
                  path = "",
                  -- server.binary.args:
                  -- Command line arguments to supply to the binary server when the binary server is being used.
                  -- Takes into effect after relaunching VSCode.
                  -- Please refer to this website for the available options.
                  -- For example, you can increase the maximum memory that the server can use to 1 GB by adding -Xmx1g
                  args = {},
                  -- server.binary.trustedHashes:
                  -- List of the SHA256 hashes of trusted copies of the lemminx (XML language server) binary.
                  trustedHashes = {},
                }, --
                -- server.silenceExtensionWarning: If this setting is enabled, do not warn about launching the binary server when there are extensions to the XML language server installed.
                silenceExtensionWarning = {},
              },

              -- trace.server: Trace the communication between VS Code and the XML language server in the Output view. Default is off.
              -- logs.client: Enable/disable logging to the Output view. Default is true.
              -- catalogs: Register XML catalog files.
              catalogs = {},
              -- downloadExternalResources.enabled: Download external resources like referenced DTD, XSD. Default is true.
              -- fileAssociations: Allows XML schemas/ DTD to be associated to file name patterns.
              fileAssociations = {},
              -- foldings.includeClosingTagInFold: Minimize the closing tag after folding. Default is false.
              -- preferences.quoteStyle: Preferred quote style to use for completion: single quotes, double quotes. Default is double.
              -- autoCloseTags.enabled : Enable/disable autoclosing of XML tags. Default is true. IMPORTANT: The following settings must be turned of for this to work: editor.autoClosingTags, editor.autoClosingBrackets.
              -- codeLens.enabled: Enable/disable XML CodeLens. Default is false.
              codeLens = { enabled = true },
              -- preferences.showSchemaDocumentationType: Specifies the source of the XML schema documentation displayed on hover and completion. Default is all.
              preferences = { showSchemaDocumentationType = "all" },
              -- validation.enabled: Enable/disable all validation. Default is true.
              -- validation.namespaces.enabled: Enable/disable namespaces validation. Default is always. Ignored if xml.validation.enabled is set to false.
              -- validation.schema.enabled: Enable/disable schema based validation. Default is always. Ignored if xml.validation.enabled is set to false.
              -- validation.disallowDocTypeDecl: Enable/disable if a fatal error is thrown if the incoming document contains a DOCTYPE declaration. Default is false.
              -- validation.resolveExternalEntities: Enable/disable resolve of external entities. Default is false. Disabled in untrusted workspace.
              -- validation.noGrammar: The message severity when a document has no associated grammar. Defaults to hint.
              -- validation.filters: Allows XML validation filter to be associated to file name patterns.
              symbols = {
                -- symbols.enabled: Enable/disable document symbols (Outline). Default is true.

                -- symbols.excluded: Disable document symbols (Outline) for the given file name patterns.
                -- Updating file name patterns does not automatically reload the Outline view for the relevant file(s).
                -- Each file must either be reopened or changed, in order to trigger an Outline view reload.
                excluded = {},

                -- symbols.maxItemsComputed: The maximum number of outline symbols and folding regions computed (limited for performance reasons). Default is 5000.
                -- symbols.showReferencedGrammars: Show referenced grammars in the Outline. Default is true.
                -- symbols.filters: Allows XML symbols filter to be associated to file name patterns.
              },
              files = {
                -- files.trimTrailingWhitespace: Now affects XML formatting. Enable/disable trailing whitespace trimming when formatting an XML document. Default is false.
                trimTrailingWhitespace = true,
              },
              -- See Formatting settings for a detailed list of the formatting settings.
              trace = {
                server = "verbose",
              },
              logs = {
                client = true,
              },
              format = {
                enabled = true,
                splitAttributes = false,
              },
              completion = {
                autoCloseTags = true,
              },

              --   semanticTokens = true,
            },
            cs_project = {
              -- codeLens = { enabled = true },
              -- preferences.showSchemaDocumentationType: Specifies the source of the XML schema documentation displayed on hover and completion. Default is all.
              preferences = { showSchemaDocumentationType = "all" },
              -- validation.enabled: Enable/disable all validation. Default is true.
              validation = {
                enabled = false,
                -- validation.schema.enabled: Enable/disable schema based validation. Default is always. Ignored if xml.validation.enabled is set to false.
                schema = {
                  enabled = false,
                },
                -- validation.noGrammar: The message severity when a document has no associated grammar. Defaults to hint.
                noGrammar = "none",
              },
              -- validation.namespaces.enabled: Enable/disable namespaces validation. Default is always. Ignored if xml.validation.enabled is set to false.
              -- validation.disallowDocTypeDecl: Enable/disable if a fatal error is thrown if the incoming document contains a DOCTYPE declaration. Default is false.
              -- validation.resolveExternalEntities: Enable/disable resolve of external entities. Default is false. Disabled in untrusted workspace.
              -- validation.filters: Allows XML validation filter to be associated to file name patterns.
              symbols = {
                -- symbols.enabled: Enable/disable document symbols (Outline). Default is true.

                -- symbols.excluded: Disable document symbols (Outline) for the given file name patterns.
                -- Updating file name patterns does not automatically reload the Outline view for the relevant file(s).
                -- Each file must either be reopened or changed, in order to trigger an Outline view reload.
                excluded = {},

                -- symbols.maxItemsComputed: The maximum number of outline symbols and folding regions computed (limited for performance reasons). Default is 5000.
                -- symbols.showReferencedGrammars: Show referenced grammars in the Outline. Default is true.
                -- symbols.filters: Allows XML symbols filter to be associated to file name patterns.
              },
              files = {
                -- files.trimTrailingWhitespace: Now affects XML formatting. Enable/disable trailing whitespace trimming when formatting an XML document. Default is false.
                trimTrailingWhitespace = true,
              },
              -- See Formatting settings for a detailed list of the formatting settings.
              trace = {
                server = "verbose",
              },
              logs = {
                client = true,
              },
              format = {
                enabled = false,
                splitAttributes = true,
              },
              completion = {
                autoCloseTags = true,
              },

              --   semanticTokens = true,
            },
          },
        },
      },
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        lemminx = function(server, opts)
          opts.single_file_support = false
          opts.autostart = true
        end,
      },
    },
  },
}
