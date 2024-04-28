local vim = vim
local util = require("config.util")
local function get_rid()
  local system_info = vim.uv.os_uname()
  local platform = system_info.sysname:lower()
  local arch = system_info.machine:lower()

  if platform == "darwin" then
    if arch == "x86_64" then
      return "osx-x64"
    elseif arch == "arm64" then
      return "osx-arm64"
    end
  end

  -- probably missing linux-musl/alpine
  if platform == "linux" then
    if arch == "x86_64" then
      return "linux-x64"
    elseif arch == "arm64" then
      return "linux-arm64"
    end
  end

  -- not sure about this one
  if platform == "windows_nt" then
    if arch == "x86_64" then
      return "win-x64"
    elseif arch == "x86" then
      return "win-x86"
    end
  end

  vim.notify("Unsupported platform: " .. vim.inspect(system_info), vim.log.levels.ERROR, { title = "Roslyn" })
end
-- local function getRoslynCommand()
--   local dotnet_cmd = "dotnet"
--   local server_path = vim.fs.joinpath(vim.fn.stdpath("data"), "roslyn", "Microsoft.CodeAnalysis.LanguageServer.dll")
--
-- 	local server_args = {
-- 		server_path,
-- 		"--logLevel=Information",
-- 		"--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
-- 	}
--
--
-- 	-- capabilities = vim.tbl_deep_extend("force", capabilities, {
-- 	-- 	workspace = {
-- 	-- 		didChangeWatchedFiles = {
-- 	-- 			dynamicRegistration = false,
-- 	-- 		},
-- 	-- 	},
-- 	-- })
--
-- 	local spawned = RoslynClient.new(target)
--
---@diagnostic disable-next-line: missing-fields
-- spawned.id = vim.lsp.start_client({
-- name = "roslyn",
-- capabilities = capabilities,
-- settings = settings,
-- -- cmd = hacks.wrap_server_cmd(vim.lsp.rpc.connect("127.0.0.1", 8080)),
-- cmd = hacks.wrap_server_cmd(roslyn_lsp_rpc.start_uds(cmd, server_args)),

-- vim.fn.rename(
--   vim.fs.joinpath(download_path, "out", roslyn_pkg_name, roslyn_pkg_version, "content", "LanguageServer", rid),
--   server_path
-- )
--
-- end

-- local fn = vim.fn
-- local rootSwitchSecondsInterval = 5
-- vim.g["LspRootSwitchLastAskedTime"] = 0
-- local lastAskedTime = vim.g["LspRootSwitchLastAskedTime"]
-- local tc = vim.tbl_contains
-- local util = require("config.util")

---returns a copy of the string where the first letter found is set to upper case
-- ---@param str any
-- ---@return string
-- local function first_to_upper(str)
--   return str:gsub("^%l", string.upper)
-- end

---this should grab the correct lsp root of whatever buf is passed in.
-- -@param ignored_lsp_servers table<string>
-- -@param client lsp.Client
-- -@param bufnr number
-- -@return string
-- function FindRoot(ignored_lsp_servers, client, bufnr)
--   local b = bufnr or 0
--   local ignore = ignored_lsp_servers or {}
--   local buf_ft = vim.api.nvim_buf_get_option(b, "filetype")
--   local result
--   local i = ignore or {}
--   local cname = client.name
--   local filetypes = (function()
--     if client.config.filetypes then
--       return client.config.filetypes
--     else
--       return {}
--     end
--   end)()
--   if filetypes and vim.tbl_contains(filetypes, buf_ft) then
--     if not vim.tbl_contains(i, cname) then
--       local rootDirFunction = client.config.get_root_dir
--       local activeConfigRootDir = client.config.root_dir
--       if activeConfigRootDir then
--         result = first_to_upper(vim.fs.normalize(activeConfigRootDir))
--       end
--     end
--   end
--   return result
-- end

vim.api.nvim_create_user_command("LspShutdownAll", function()
  vim.lsp.stop_client(vim.lsp.get_active_clients(), true)
end, {})

vim.api.nvim_create_user_command("LspShutdownAllOnCurrentBuffer", function()
  vim.lsp.stop_client(vim.lsp.get_active_clients({ buffer = 0 }), true)
end, {})

OnAttach =
  ---@param client lsp.Client
  ---@param buffer integer
  function(client, buffer)
    -- vim.notify(client.name .. " is running OnAttach")
    -- local ft = vim.api.nvim_buf_get_option(0, "filetype")
    -- local Util = require("lazyvim.util")
    -- local isDotnet = ft == "cs" or ft == "fsharp" or ft == "fsharp_project"
    -- -- local isDotnetProj = vim.api.nvim_buf_get_option(0, "")
    -- local ignored = { "jsonls", "null-ls", "stylua", "editorconfig_checker" }
    -- -- local ignored = v.lsp.ignoredLspServersForFindingRoot
    -- -- v.notify(client.name .. " is running on_attach")
    -- -- v.notify(vim.inspect(ignored) .. " are servers being ignored")
    -- -- local on_attach_override = user_plugin_opts("lsp.on_attach", nil, false)
    -- -- conditional_func(on_attach_override, true, client, bufnr)
    -- -- local capabilities = client.server_capabilities
    -- -- vim.notify(client.name .. " is running on_attach")
    -- if not tc(ignored, client.name) then
    --   -- if client.name ~= "null-ls" and client.name ~= "stylua" and client.name ~= "lemminx" then
    --   -- local root = FindRoot(ignored, bufnr)
    --   local root = FindRoot(ignored, client, buffer)
    --   -- v.notify("lsp root should have found root of : " .. root)
    --   local cwd = first_to_upper(vim.fs.normalize(fn.getcwd()))
    --   if not root then
    --     vim.notify(
    --       "lsp says it didn't find a root??? I'd go check that one out.. setting temporary root to current buffer's parent dir, but don't think that means that lsp is healthy right now.. you've been warned! "
    --     )
    --     root = first_to_upper(vim.fs.normalize(vim.fn.expand("%:p:h")))
    --   end
    --   local path = require("plenary.path")
    --   local rootpath = path:new(root)
    --   local cwdpath = path:new(cwd)
    --   local notEqual = rootpath.filename ~= cwdpath.filename
    --   -- v.notify("i have the root and cwd now.. but ill check the number of buffers.. ")
    --   local recentlyAsked = lastAskedTime and os.difftime(os.time(), lastAskedTime) < rootSwitchSecondsInterval
    --   local shouldAsk = vim.tbl_count(fn.getbufinfo({ buflisted = true })) > 1 and recentlyAsked == false
    --   if notEqual then
    --     if shouldAsk == true then
    --       -- v.notify("at this point the buffers say i should ask about setting root.. " .. vim.inspect(shouldAsk))
    --       if
    --         fn.confirm(
    --           "Do you want to change the current working directory to lsp root?  \n  ROOT: "
    --             .. root
    --             .. "  \n  CWD : "
    --             .. cwd
    --             .. "  \n",
    --           "&yes\n&no",
    --           2
    --         ) == 1
    --       then
    --         vim.cmd("cd " .. root)
    --         vim.notify("CWD : " .. root)
    --       end
    --     else
    --       vim.cmd("cd " .. root)
    --       vim.notify("CWD : " .. root)
    --     end
    --     if isDotnet then
    --       vim.g["DotnetSlnRootPath"] = root
    --     end
    --   end
    -- end

    -- if client.name == "lemminx" then
    --   -- vim.notify(" on attach for " .. client.name .. " just got called")
    --
    --   -- local capabilities = client.server_capabilities
    -- end
    --     vim.notify(" on attach for " .. client.name .. " just got called")
    --     if client.name == "ionide" then
    --       local inp = vim.fn.input("please attach debugger")
    --     end
    --     -- local normalCaps = vim.lsp.protocol.make_client_capabilities()
    --     -- print("client " .. client.name .. " has capability " .. vim.inspect(normalCaps))
    --     local capabilities = client.server_capabilities
    --     -- print("client " .. client.name .. " has capability " .. vim.inspect(capabilities))
    --     -- if capabilities.hoverProvider then
    --     --   if require("lazyvim.util").has("hover.nvim") then
    --     --     vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
    --     --     -- vim.keymap.set ("n", "K", require("hover").hover, {desc = "hover.nvim" })
    --     --     -- lsp_mappings.n["gK"] = { require("hover").hover_select, desc = "Hover symbol details (select)" }
    --     --     -- else
    --     --     --   lsp_mappings.n["K"] = {
    --     --     --     function()
    --     --     --       vim.lsp.buf.hover()
    --     --     --     end,
    --     --     --     desc = "Hover symbol details",
    --     --     --   }
    --     --   end
    --     -- end

    if client.name == "ionide" then
      client.server_capabilities.documentFormattingProvider = false

      vim.bo[buffer].commentstring = "// %s"
    end
    if client.name == "csharp_ls" then
      -- client.server_capabilities.documentFormattingProvider = false

      vim.bo[buffer].commentstring = "// %s"
    end
    if client.name == "jsonls" then
      if vim.bo[buffer].filetype == "json" then
        vim.bo[buffer].syntax = "jsonc"
        vim.bo[buffer].filetype = "jsonc"
      end
      -- vim.lsp.buf.format()
    end
    if client.name == "omnisharp" then
      vim.bo[buffer].commentstring = "// %s"
      client.server_capabilities.semanticTokensProvider = {
        full = vim.empty_dict(),
        legend = {
          tokenModifiers = { "static_symbol" },
          tokenTypes = {
            "comment",
            "excluded_code",
            "identifier",
            "keyword",
            "keyword_control",
            "number",
            "operator",
            "operator_overloaded",
            "preprocessor_keyword",
            "string",
            "whitespace",
            "text",
            "static_symbol",
            "preprocessor_text",
            "punctuation",
            "string_verbatim",
            "string_escape_character",
            "class_name",
            "delegate_name",
            "enum_name",
            "interface_name",
            "module_name",
            "struct_name",
            "type_parameter_name",
            "field_name",
            "enum_member_name",
            "constant_name",
            "local_name",
            "parameter_name",
            "method_name",
            "extension_method_name",
            "property_name",
            "event_name",
            "namespace_name",
            "label_name",
            "xml_doc_comment_attribute_name",
            "xml_doc_comment_attribute_quotes",
            "xml_doc_comment_attribute_value",
            "xml_doc_comment_cdata_section",
            "xml_doc_comment_comment",
            "xml_doc_comment_delimiter",
            "xml_doc_comment_entity_reference",
            "xml_doc_comment_name",
            "xml_doc_comment_processing_instruction",
            "xml_doc_comment_text",
            "xml_literal_attribute_name",
            "xml_literal_attribute_quotes",
            "xml_literal_attribute_value",
            "xml_literal_cdata_section",
            "xml_literal_comment",
            "xml_literal_delimiter",
            "xml_literal_embedded_expression",
            "xml_literal_entity_reference",
            "xml_literal_name",
            "xml_literal_processing_instruction",
            "xml_literal_text",
            "regex_comment",
            "regex_character_class",
            "regex_anchor",
            "regex_quantifier",
            "regex_grouping",
            "regex_alternation",
            "regex_text",
            "regex_self_escaped_character",
            "regex_other_escape",
          },
        },
        range = true,
      }
    end
  end

return {
  "neovim/nvim-lspconfig",
  init = function()
    local configs = require("lspconfig.configs")

    if not configs["razorLsp"] then
      vim.notify("creating entry in lspconfig configs for razorLsp ")
      configs["razorLsp"] = {
        default_config = {

          settings = vim.empty_dict(),
          init_options = vim.empty_dict(),
          handlers = {},
          autostart = true,
        },
      }
    end
    -- opts.on_attach = OnAttach(, buffer)
    -- vim.notify("entered lspconfig init func, doing keymaps now. ")
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    -- change a keymap
    -- keys[#keys + 1] = { "K", "<cmd>echo 'hello'<cr>" }
    keys[#keys + 1] = {
      "K",
      function()
        -- vim.notify("I'm printing for hover")
        if require("lazyvim.util").has("hover.nvim") then
          -- vim.notify("I have hover.nvim")
          require("hover").hover()
        else
          -- vim.notify("I do not have hover.nvim, defaulting to vim.lsp.buf.hover()")
          vim.lsp.buf.hover()
        end
      end,
      "Hover",
    }
    keys[#keys + 1] = {
      "<leader>laa",
      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").code_action()
        else
          -- vim.lsp.buf.hover()
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Code Action",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>laf",

      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").apply_first()
        else
          -- vim.lsp.buf.hover()
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Apply first Code Action",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>larr",

      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").refactor()
        else
          -- vim.lsp.buf.hover()
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Refactor",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>lari",

      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").refactor_inline()
        else
          -- vim.lsp.buf.hover()
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Refactor Inline",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>lari",

      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").refactor_inline()
        else
          -- vim.lsp.buf.hover()
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Refactor Inline",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>lare",

      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").refactor_extract()
        else
          -- vim.lsp.buf.hover()
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Refactor extract",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>larw",

      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").refactor_rewrite()
        else
          -- vim.lsp.buf.hover()
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Refactor rewrite",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>lcr",
      function()
        vim.lsp.codelens.clear()
        vim.lsp.codelens.refresh()
      end,
      desc = "Codelens Clear and Refresh",
      mode = "n",
      -- has = "codeAction",
      -- has = "codeAction",
    }
    keys[#keys + 1] = {
      "<leader>lf",
      function()
        require("lazyvim.util").format.format({ force = true })
      end,
      desc = "Format Document",
      -- has = "documentFormatting",
    }
    keys[#keys + 1] = {
      "<leader>lF",
      function()
        require("lazyvim.util").format.info()
      end,
      desc = "Get LazyVim formatter info about the current buffer",
    }
    keys[#keys + 1] = {
      "<leader>lf",
      function()
        require("lazyvim.util").format.format({ force = true })
      end,
      desc = "Format Range",

      mode = "v",
    }
    keys[#keys + 1] = {
      "<leader>ld",
      function()
        vim.diagnostic.open_float()
      end,
      desc = "Line Diagnostics",
    }
    -- keys[#keys + 1] = { "<leader>lI", "<cmd>LspRestart<cr>", desc = "Lsp Reinit" }

    if require("lazyvim.util").has("inc-rename.nvim") then
      keys[#keys + 1] = {
        "<leader>lr",
        function()
          require("inc_rename")
          return ":IncRename " .. vim.fn.expand("<cword>")
        end,
        expr = true,
        desc = "Rename",
        -- has = "rename",
      }
    else
      -- keys[#keys + 1] = { "<leader>lr", vim.lsp.buf.rename, desc = "Rename", has = "rename" }
      keys[#keys + 1] = { "<leader>lr", vim.lsp.buf.rename, desc = "Rename" }
    end
    -- keys[#keys + 1] = { "<leader>ll", "<cmd>LspLog<cr>" }
    -- keys[#keys + 1] = { "<leader>ll", "<cmd>LspLog<cr>" }
    -- keys[#keys + 1] = { "<leader>ll", "<cmd>LspLog<cr>" }
    -- keys[#keys + 1] = { "<leader>ll", "<cmd>LspLog<cr>" }
    -- keys[#keys + 1] = {
    --   "<leader>li",
    --   function()
    --     require("lspconfig.ui.lspinfo")()
    --   end,
    --   "LSP Info",
    -- }
    -- keys[#keys + 1] = {
    --   "<leader>lk",
    --   function()
    --     vim.fn.writefile({}, vim.lsp.get_log_path())
    --   end,
    --   "reset LSP log",
    -- }
    -- disable a keymap
    -- keys[#keys + 1] = { "K", false }
    -- add a keymap
    -- keys[#keys + 1] = { "H", "<cmd>echo 'hello'<cr>" }
  end,
  opts = {
    inlay_hints = { enabled = true },
    capabilities = {
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true,
        },
      },
    },
    -- options for vim.diagnostic.config()
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = { spacing = 4, prefix = "●" },
      -- virtual_text = { spacing = 4, prefix = "●" },
      severity_sort = true,
    },
    -- Automatically format on save
    -- autoformat = true,
    -- options for vim.lsp.buf.format
    -- `bufnr` and `filter` is handled by the LazyVim formatter,
    -- but can be also overridden when specified
    format = {
      -- formatting_options = nil,

      -- timeout_ms = 10000,
      timeout_ms = 1000,
    },
    dependencies = {
      {

        "Decodetalkers/csharpls-extended-lsp.nvim",
      },
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
          },
        },
      },
    },
  },
  -- },

  -- LSP Server Settings
  --      ---@type lspconfig.options
  -- servers = {
  -- {
  --         ---@type IonideOptions
  --           ionide = {
  --
  --             IonideNvimSettings = {
  --               LspRecommendedColorScheme = true,
  --               EnableFsiStdOutTeeToFile = true,
  --               FsiStdOutFileName = "./FsiOutput.txt",
  --             },
  --             cmd = {
  --               util.getMasonBinCommandIfExists("fsautocomplete"),
  --               -- "-l",
  --               -- ".fsautocomplete.log",
  --               -- "-v",
  --               -- '--wait-for-debugger',
  --               -- "--project-graph-enabled",
  --             },
  --             settings = {
  --               FSharp = {
  --                 enableMSBuildProjectGraph = true,
  --                 -- enableTreeView = true,
  --                 fsiExtraParameters = {
  --                   "--compilertool:C:/Users/Will.ehrendreich/.dotnet/tools/.store/depman-fsproj/0.2.6/depman-fsproj/0.2.6/tools/net7.0/any",
  --                 },
  --               },
  --             },
  --           },
  --         },
  --         -- you can do any additional lsp server setup here
  --         -- return true if you don't want this server to be setup with lspconfig
  --         ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
  --         setup = {
  --           ionide = function(_, opts)
  --             print("setup ionide")
  --             require("ionide").setup(opts)
  --           end,
  --           -- NOTE: returning true will make sure fsautocomplete is not setup with neovim, which is what we want if we're using Ionide-nvim
  --           fsautocomplete = function(_, _)
  --             return true
  --           end,
  --         },
  --       },
  -- {
  -- Syntax highlighting
  --

  -- LspConfig

  -- purescriptls will be automatically installed with mason and loaded with lspconfig
  servers = {

    -- ---@type IonideOptions
    -- ionide = {
    --
    --   IonideNvimSettings = {
    --     LspRecommendedColorScheme = true,
    --     EnableFsiStdOutTeeToFile = true,
    --     FsiStdOutFileName = "./FsiOutput.txt",
    --   },
    --   cmd = {
    --     util.getMasonBinCommandIfExists("fsautocomplete"),
    --     -- "-l",
    --     -- ".fsautocomplete.log",
    --     -- "-v",
    --     -- '--wait-for-debugger',
    --     -- "--project-graph-enabled",
    --   },
    --   settings = {
    --     FSharp = {
    --       enableMSBuildProjectGraph = true,
    --       -- enableTreeView = true,
    --       fsiExtraParameters = {
    --         "--compilertool:C:/Users/Will.ehrendreich/.dotnet/tools/.store/depman-fsproj/0.2.6/depman-fsproj/0.2.6/tools/net7.0/any",
    --       },
    --     },
    --   },
    -- },

    -- razorLsp = {
    --   cmd = {
    --     "c:/Users/ehrwi/.vscode/extensions/ms-dotnettools.csharp-2.18.16-win32-x64/.razor/rzls.exe",
    --     "--logLevel",
    --     "2",
    --     "--projectConfigurationFileName",
    --     "project.razor.vscode.bin",
    --     "--DelegateToCSharpOnDiagnosticPublish",
    --     "true",
    --     "--UpdateBuffersForClosedDocuments",
    --     "true",
    --     "--telemetryLevel",
    --     "none",
    --   },
    --   filetypes = { "razor", "cshtml" },
    --   on_attach = require("lazyvim.util").lsp.on_attach(OnAttach),
    --   -- cmd = "",
    --   capabilities = require("lazyvim.util").lsp.capabilities,
    --   settings = {
    --     DefaultCSharpVirtualDocumentSuffix = ".ide.g.cs",
    --     DefaultHtmlVirtualDocumentSuffix = "__virtual.html",
    --
    --     SupportsFileManipulation = true,
    --
    --     ProjectConfigurationFileName = "project.razor.bin",
    --
    --     CSharpVirtualDocumentSuffix = ".ide.g.cs",
    --
    --     HtmlVirtualDocumentSuffix = "__virtual.html",
    --
    --     SingleServerCompletionSupport = false,
    --
    --     SingleServerSupport = false,
    --
    --     DelegateToCSharpOnDiagnosticPublish = false,
    --
    --     UpdateBuffersForClosedDocuments = false,
    --
    --     --// Code action and rename paths in Windows VS Code need to be prefixed with '/':
    --     -- // https://github.com/dotnet/razor/issues/8131
    --     ReturnCodeActionAndRenamePathsWithPrefixedSlash = true,
    --
    --     ShowAllCSharpCodeActions = false,
    --
    --     IncludeProjectKeyInGeneratedFilePath = false,
    --
    --     UsePreciseSemanticTokenRanges = false,
    --
    --     MonitorWorkspaceFolderForConfigurationFiles = true,
    --
    --     UseRazorCohostServer = false,
    --
    --     DisableRazorLanguageServer = false,
    --   },
    -- },

    roslyn = {
      on_attach = require("lazyvim.util").lsp.on_attach(OnAttach),
    },

    purescriptls = {
      settings = {
        purescript = {
          formatter = "purs-tidy",
        },
      },
    },
  },
  setup = {
    -- ionide = function(_, opts)
    --   -- print("setup ionide")
    --   require("ionide").setup(opts)
    -- end,
    -- -- NOTE: returning true will make sure fsautocomplete is not setup with neovim, which is what we want if we're using Ionide-nvim
    -- fsautocomplete = function(_, _)
    --   return true
    -- end,

    -- razorLsp = function(_, opts) -- code
    --   require("razorLsp").setup(opts)
    -- end,

    purescriptls = function(_, opts)
      opts.root_dir = function(path)
        local lspConfigUtil = require("lspconfig.util")
        -- if path:match("/.spago/") then
        --   return nil
        -- end
        return lspConfigUtil.root_pattern("bower.json", "psc-package.json", "spago.dhall", "flake.nix", "shell.nix")(
          path
        )
      end
    end,
  },
  on_attach = require("lazyvim.util").lsp.on_attach(OnAttach),
}

-- vimls = {},
-- ---@type lspconfig.options.jsonls
-- jsonls = {
--   settings = {
--     json = {
--       -- format ={
--       -- enable},
--       validate = {
--         enable = true,
--       },
--     },
--   },
-- },

-- all seperate lsp servers have thier own setup files, for clarity
-- },
-- you can do any additional lsp server setup here
-- return true if you don't want this server to be setup with lspconfig
---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
-- setup = {

-- all seperate lsp servers have thier own setup files, for clarity
-- },

-- },
-- },
-- }
