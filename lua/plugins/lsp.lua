local fn = vim.fn
local rootSwitchSecondsInterval = 5
vim.g["LspRootSwitchLastAskedTime"] = 0
local lastAskedTime = vim.g["LspRootSwitchLastAskedTime"]
local tc = vim.tbl_contains

---returns a copy of the string where the first letter found is set to upper case
---@param str any
---@return string
local function first_to_upper(str)
  return str:gsub("^%l", string.upper)
end

---this should grab the correct lsp root of whatever buf is passed in.
---@param ignored_lsp_servers table<string>
---@param client lsp.Client
---@param bufnr number
---@return string
function FindRoot(ignored_lsp_servers, client, bufnr)
  local b = bufnr or 0
  local ignore = ignored_lsp_servers or {}
  local buf_ft = vim.api.nvim_buf_get_option(b, "filetype")
  local result
  local i = ignore or {}
  local cname = client.name
  local filetypes = client.config.filetypes
  if filetypes and vim.tbl_contains(filetypes, buf_ft) then
    if not vim.tbl_contains(i, cname) then
      local rootDirFunction = client.config.get_root_dir
      local activeConfigRootDir = client.config.root_dir
      if activeConfigRootDir then
        result = first_to_upper(vim.fs.normalize(activeConfigRootDir))
      end
    end
  end
  return result
end

vim.api.nvim_create_user_command("IonideStart", function()
  local clients = vim.lsp.get_active_clients({ name = "ionide" })
  for _, client in ipairs(clients) do
    client.stop()
  end
  vim.cmd("LspStart ionide")
end, {})
vim.api.nvim_create_user_command("LspShutdown", function()
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    client.stop()
  end
end, {})
vim.api.nvim_create_user_command("LspStatus", function()
  require("NeovimUtils").dump(vim.lsp.get_active_clients({ bufnr = 0 }))
end, {})

return {
  -- {
  --   "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  --   config = true,
  -- },
  {
    "p00f/clangd_extensions.nvim",
    config = true,
    ---@type lspconfig.options.clangd
    server = {
      -- options to pass to nvim-lspconfig
      -- i.e. the arguments to require("lspconfig").clangd.setup({})
      --

      -- clangd = {

      cmd = {
        -- "C:/ProgramData/chocolatey/bin/cpp.exe",
        "clangd",
        -- "-Wall",
        -- "-fms-compatibility-version=19.10",
        -- "-Wmicrosoft",
        -- "-Wno-invalid-token-paste",
        -- "-Wno-unknown-pragmas",
        -- "-Wno-unused-value",
        -- 'CMD.exe call "C:/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/VC/Auxiliary/Build/vcvarsall.bat" x64',
        -- "x64",
        -- "cl.exe",
        "--query-driver=C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.35.32215\\bin\\HostX64\\x64\\CL.exe",
        -- "--all-scopes-completion",
        -- "--background-index",
        "--clang-tidy",
        -- -- "--compile_args_from=filesystem", -- lsp-> does not come from compie_commands.json
        -- "--completion-parse=always",
        -- "--completion-style=bundled",
        "--cross-file-rename",
        -- "--debug-origin",
        -- "--enable-config", -- clangd 11+ supports reading from .clangd configuration file
        -- "--fallback-style=Qt",
        -- "--folding-ranges",
        "--function-arg-placeholders",
        -- "--header-insertion=iwyu",
        "--header-insertion=never",
        -- "--pch-storage=memory", -- could also be disk
        "--suggest-missing-includes",
        "-j=4", -- number of workers
        -- -- "--resource-dir="
        -- "--driver-mode=cl",
        "--log=error",
        -- --[[ "--query-driver=/usr/bin/g++", ]]
      },
      -- filetypes = { "c", "cpp", "objc", "objcpp" },
      root_dir = function(fname)
        local util = require("lspconfig.util")
        -- local util =
        -- return require("lspconfig").clangd.document_config.default_config.root_dir(fname)
        return util.root_pattern(unpack({
          -- ".clangd",
          -- ".clang-tidy",
          -- ".clang-format",
          "compile_commands.json",
          "compile_flags.txt",
          -- "build.sh", -- buildProject
          "build", -- buildProject
          "build.bat", -- buildProject
          "build.ps1", -- buildProject
          -- "configure.ac", -- AutoTools
          -- "run",
          -- "compile",
        }))(fname) or util.find_git_ancestor(fname)
      end,
      -- single_file_support = true,
      -- init_options = {
      --   compilationDatabasePath = "./build",
      -- },
      capabilities = { offsetEncoding = "utf-16" },
      -- commands = {
      --
      -- },
      settings = {
        clangd = {},
      },
    },
  },
  extensions = {
    -- defaults:
    -- Automatically set inlay hints (type hints)
    autoSetHints = true,
    -- These apply to the default ClangdSetInlayHints command
    inlay_hints = {
      -- Only show inlay hints for the current line
      only_current_line = false,
      -- Event which triggers a refersh of the inlay hints.
      -- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
      -- not that this may cause  higher CPU usage.
      -- This option is only respected when only_current_line and
      -- autoSetHints both are true.
      only_current_line_autocmd = "CursorHold",
      -- whether to show parameter hints with the inlay hints or not
      show_parameter_hints = true,
      -- prefix for parameter hints
      parameter_hints_prefix = "<- ",
      -- prefix for all the other hints (type, chaining)
      other_hints_prefix = "=> ",
      -- whether to align to the length of the longest line in the file
      max_len_align = false,
      -- padding from the left if max_len_align is true
      max_len_align_padding = 1,
      -- whether to align to the extreme right or not
      right_align = false,
      -- padding from the right if right_align is true
      right_align_padding = 7,
      -- The color of the hints
      highlight = "Comment",
      -- The highlight group priority for extmark
      priority = 100,
    },
    ast = {
      role_icons = {
        type = "",
        declaration = "",
        expression = "",
        specifier = "",
        statement = "",
        ["template argument"] = "",
      },
      kind_icons = {
        Compound = "",
        Recovery = "",
        TranslationUnit = "",
        PackExpansion = "",
        TemplateTypeParm = "",
        TemplateTemplateParm = "",
        TemplateParamObject = "",
      },
      highlights = {
        detail = "Comment",
      },
    },
    memory_usage = {
      border = "none",
    },
    symbol_info = {
      border = "none",
    },
    -- },
  },
  {

    "kkharji/sqlite.lua",
    config = function()
      -- re("sqlite")
      vim.g["sqlite_clib_path "] = "C:/ProgramData/chocolatey/lib/SQLite/tools/sqlite3.dll"
      -- vim.cmd("let g:sqlite_clib_path =" .. "C:/ProgramData/chocolatey/lib/SQLite/tools/sqlite3.dll")
    end,
  },
  -- {
  --   "glepnir/lspsaga.nvim",
  --   event = "BufRead",
  --   config = true,
  --   -- config = function()
  --   --   -- require("lspsaga").setup({})
  --   -- end,
  --   dependencies = {
  --     { "nvim-tree/nvim-web-devicons" },
  --     --Please make sure you install markdown and markdown_inline parser
  --     { "nvim-treesitter/nvim-treesitter" },
  --   },
  -- },
  { "Tetralux/odin.vim" },

  -- LSP inlay hint support
  {
    "lvimuser/lsp-inlayhints.nvim",
    config = function()
      -- local bind_all = require("conf.bindings").bind_all
      -- local key_opts = { noremap = true, silent = true }

      require("lsp-inlayhints").setup({ enabled_at_startup = true })

      vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
      vim.api.nvim_create_autocmd("LspAttach", {
        group = "LspAttach_inlayhints",
        callback = function(args)
          if not (args.data and args.data.client_id) then
            return
          end

          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          require("lsp-inlayhints").on_attach(client, bufnr)
        end,
      })

      -- bind_all("lsp.toggle_inlayhints", require("lsp-inlayhints").toggle, {}, key_opts)
    end,
  },
  {
    -- {
    --   "WillEhrendreich/ionide-vim",
    --   dir = vim.fn.getenv("repos") .. "/ionide-vim/",
    --   dev = true,
    --   -- opts = {},
    -- },
    -- {
    -- { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Goto Definition", has = "definition" },
    -- { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
    -- { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
    -- { "gI", "<cmd>Telescope lsp_implementations<cr>", desc = "Goto Implementation" },
    -- { "gt", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Goto Type Definition" },
    -- { "K", vim.lsp.buf.hover, desc = "Hover" },
    -- { "gK", vim.lsp.buf.signature_help, desc = "Signature Help", has = "signatureHelp" },
    -- { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" },
    -- { "]d", M.diagnostic_goto(true), desc = "Next Diagnostic" },
    -- { "[d", M.diagnostic_goto(false), desc = "Prev Diagnostic" },
    -- { "]e", M.diagnostic_goto(true, "ERROR"), desc = "Next Error" },
    -- { "[e", M.diagnostic_goto(false, "ERROR"), desc = "Prev Error" },
    -- { "]w", M.diagnostic_goto(true, "WARN"), desc = "Next Warning" },
    -- { "[w", M.diagnostic_goto(false, "WARN"), desc = "Prev Warning" },
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- change a keymap
      -- keys[#keys + 1] = { "K", "<cmd>echo 'hello'<cr>" }
      keys[#keys + 1] = {
        "K",
        function()
          local client = vim.lsp.get_active_clients({ buffer = 0 })[1]
          local capabilities = client.server_capabilities
          -- print("client " .. client.name .. " has capability " .. vim.inspect(capabilities))
          if capabilities.hoverProvider then
            if require("lazyvim.util").has("hover.nvim") then
              require("hover").hover()
            --     function()
            --       vim.lsp.buf.hover()
            --     end,
            --     desc = "Hover symbol details",
            --   }
            --
            else
              vim.lsp.buf.hover()
            end
          end
        end,
        "Hover",
      }
      keys[#keys + 1] =
        { "<leader>la", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" }
      keys[#keys + 1] = {
        "<leader>lcr",
        function()
          vim.lsp.codelens.clear()
          vim.lsp.codelens.refresh()
        end,
        desc = "Codelens Clear and Refresh",
        mode = "n",
        has = "codeAction",
      }
      keys[#keys + 1] = {
        "<leader>lf",
        require("lazyvim.plugins.lsp.format").format,
        desc = "Format Document",
        has = "documentFormatting",
      }
      keys[#keys + 1] = {
        "<leader>lf",
        require("lazyvim.plugins.lsp.format").format,
        desc = "Format Range",
        mode = "v",
        has = "documentRangeFormatting",
      }
      keys[#keys + 1] = { "<leader>ld", vim.diagnostic.open_float, desc = "Line Diagnostics" }
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
          has = "rename",
        }
      else
        keys[#keys + 1] = { "<leader>lr", vim.lsp.buf.rename, desc = "Rename", has = "rename" }
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
      autoformat = true,
      -- options for vim.lsp.buf.format
      -- `bufnr` and `filter` is handled by the LazyVim formatter,
      -- but can be also overridden when specified
      format = {
        -- formatting_options = nil,

        timeout_ms = 500,
      },

      -- LSP Server Settings
      ---@type lspconfig.options
      servers = {
        ---@type _.lspconfig.settings.ols
        ols = {
          cmd = { "C:/.local/share/nvim-data/mason/bin/ols.cmd" },
          -- root_dir = FindRoot({}, 0),
          root_dir = function(path)
            local util = require("lspconfig.util")
            local root
            root = util.root_pattern("ols.json", ".git")(path)
            root = root
              or (function(p)
                return (vim.fs.dirname(p or vim.fn.expand("%:p"))) .. "/"
              end)(path)
            return root
          end,
          settings = {
            odin = {
              completion_support_md = true,
              hover_support_md = true,
              signature_offset_support = true,
              collections = {},
              -- running=true,
              verbose = true,
              enable_format = true,
              enable_hover = true,
              enable_symantic_tokens = true,
              enable_document_symbols = true,
              enable_inlay_hints = true,
              enable_procedure_context = true,
              enable_snippets = true,
              enable_references = true,
              enable_rename = true,
              enable_label_details = true,
              enable_std_references = true,
              enable_import_fixer = true,
              disable_parser_errors = true,
              thread_count = 0,
              file_log = true,
              -- odin_command = "",
              checker_args = "",
            },
          },
          filetypes = { "odin" },
          single_file_support = false,
          autostart = true,
        },

        ---@type lspconfig.options.sqlls
        sqlls = {
          root_dir = function(fname)
            return vim.fs.dirname(fname)
          end,
        },

        -- (function()
        --   local c = require("lspconfig.configs")
        --   if not c["odin"] then
        --     local lspConfig = require("lspconfig")
        --     c["odin"] = lspConfig.util.defaultConfig
        --   end
        --
        --   return
        -- end)(),

        ---@type  lspconfig.options.fsautocomplete
        -- fsautocomplete = {
        --   autostart = true,
        --   filetypes = { "fsharp", "fsharp_project" },
        --   name = "fsautocomplete",
        --   -- single_file_support = false,
        --   -- cmd = { 'fsautocomplete', '--adaptive-lsp-server-enabled', '-v' },
        --   cmd = (function()
        --     return {
        --       -- "C:/Users/Will.ehrendreich/source/repos/FsAutoComplete/src/FsAutoComplete/bin/Debug/net6.0/publish/fsautocomplete.exe",
        --       "fsautocomplete",
        --       "--adaptive-lsp-server-enabled",
        --       -- "-l .fsautocomplete.log",
        --       "-v",
        --       "--wait-for-debugger",
        --       -- '--attach-debugger',
        --       -- "--project-graph-enabled",
        --     }
        --   end)(),
        -- on_attach = require("plugins.lsp").opts.on_attach,
        -- on_attach = on_attach,
        -- settings = {},
        -- },
        -- jsonls = {
        --   settings = {
        --     json = {
        --       format = {
        --         enable = true,
        --       },
        --       -- schemas = require("schemastore").json.schemas(),
        --       validate = { enable = true },
        --     },
        --   },
        --   filetypes = { "jsonc", "json" },
        -- },
        ---@type  lspconfig.options.fsautocomplete
        ionide = {
          autostart = true,

          cmd_Environment = "latestMinor",
          -- settings = {
          --   FSharp = {
          --     abstractClassStubGeneration = true,
          --     -- abstractClassStubGenerationMethodBody = "",
          --     -- abstractClassStubGenerationObjectIdentifier = "",
          --     addFsiWatcher = true,
          --     analyzersPath = {
          --       "./packages/analyzers",
          --     },
          --     autoRevealInExplorer = "enabled",
          --     -- autoRevealInExplorer= "disabled"|"enabled"|"sameAsFileExplorer",
          --     codeLenses = {
          --       ---@type _.lspconfig.settings.fsautocomplete.Signature
          --       signature = {
          --         enabled = true,
          --       },
          --       references = {
          --         enabled = true,
          --       },
          --     },
          --     disableFailedProjectNotifications = false,
          --     dotnetRoot = "",
          --     -- dotNetRoot = "",
          --     enableAnalyzers = true,
          --     enableAdaptiveLspServer = true,
          --     enableMSBuildProjectGraph = true,
          --     enableReferenceCodeLens = true,
          --     -- enableTouchBar = true,
          --     -- enableTreeView = true,
          --     excludeProjectDirectories = { ".git", "paket-files", ".fable", "packages", "node_modules" },
          --     -- externalAutocomplete = true,
          --     -- fsac = _.lspconfig.settings.fsautocomplete.Fsac,
          --     fsac = {
          --       silencedLogs = {
          --         -- "",
          --       },
          --       parallelReferenceResolution = true,
          --       -- id,
          --     },
          --     fsiExtraParameters = {},
          --     -- fsiSdkFilePath = "",
          --     -- generateBinlog = true,
          --     indentationSize = 2,
          --     infoPanelReplaceHover = true,
          --     infoPanelShowOnStartup = true,
          --     infoPanelStartLocked = true,
          --     infoPanelUpdate = "both",
          --     ---@type _.lspconfig.settings.fsautocomplete.InlayHints
          --     inlayHints = {
          --       -- enabled = false,
          --       enabled = true,
          --       parameterNames = true,
          --       typeAnnotations = true,
          --       disableLongTooltip = false,
          --     },
          --     ---@type  _.lspconfig.settings.fsautocomplete.InlineValues
          --     inlineValues = {
          --       enabled = false,
          --       -- enabled = true,
          --       prefix = "  //ilv: ",
          --     },
          --     interfaceStubGeneration = true,
          --     -- interfaceStubGenerationMethodBody = "",
          --     -- interfaceStubGenerationObjectIdentifier = "",
          --     keywordsAutocomplete = true,
          --     -- lineLens = _.lspconfig.settings.fsautocomplete.LineLens,
          --     lineLens = { enabled = "always", prefix = "  //lnlens:" },
          --     linter = true,
          --     msbuildAutoshow = true,
          --     ---@type _.lspconfig.settings.fsautocomplete.Notifications
          --     notifications = { trace = true },
          --
          --     -- openTelemetry = _.lspconfig.settings.fsautocomplete.OpenTelemetry,
          --     ---@type _.lspconfig.settings.fsautocomplete.PipelineHints
          --     pipelineHints = {
          --       enabled = true,
          --       prefix = "  // plh:",
          --     },
          --     recordStubGeneration = true,
          --     -- recordStubGenerationBody = "",
          --     resolveNamespaces = true,
          --     saveOnSendLastSelection = true,
          --     showExplorerOnStartup = true,
          --     showProjectExplorerIn = "fsharp",
          --     simplifyNameAnalyzer = true,
          --     smartIndent = true,
          --     suggestGitignore = true,
          --     suggestSdkScripts = true,
          --     -- trace = _.lspconfig.settings.fsautocomplete.Trace,
          --     trace = { server = "messages" },
          --     unionCaseStubGeneration = true,
          --     unusedOpensAnalyzer = true,
          --   },
          -- },
          filetypes = { "fsharp", "fsharp_project" },
          name = "ionide",
          -- single_file_support = false,
          -- cmd = { 'fsautocomplete', '--adaptive-lsp-server-enabled', '-v' },
          -- (function()
          -- return
          cmd = {
            -- "C:/Users/Will.ehrendreich/source/repos/FsAutoComplete/src/FsAutoComplete/bin/Debug/net6.0/publish/fsautocomplete.exe",
            -- "fsautocomplete",
            "C:/.local/share/nvim-data/mason/bin/fsautocomplete.cmd",
            "--adaptive-lsp-server-enabled",
            -- "-l",
            -- ".fsautocomplete.log",
            -- "-v",
            -- '--wait-for-debugger',
            -- '--attach-debugger',
            -- "--project-graph-enabled",
          },
          -- end)(),
          -- on_attach = on_attach,
          settings = {
            FSharp = {
              -- enableMSBuildProjectGraph = true,
              -- enableTreeView = true,
              -- fsiExtraParameters = { "--compilertool:C:/Users/Will.ehrendreich/.dotnet/tools/.store/depman-fsproj/0.2.4/depman-fsproj/0.2.4/tools/net6.0/any", },
            },
          },
        },

        -- lua_ls = {
        --   root_dir = function(path)
        --     local util = require("lspconfig.util")
        --     local root
        --     root = util.root_pattern(
        --       ".luarc.json",
        --       ".luarc.jsonc",
        --       ".luacheckrc",
        --       ".stylua.toml",
        --       "stylua.toml",
        --       "selene.toml",
        --       "selene.yml",
        --       ".git"
        --     )(path)
        --     root = root
        --       or (function(p)
        --         return (vim.fs.dirname(p or vim.fn.expand("%:p"))) .. "/"
        --       end)(path)
        --     return root
        --   end,
        --
        --   -- flags
        --   settings = {
        --     Lua = {
        --       runtime = {
        --         -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        --         version = "LuaJIT",
        --         -- path = vim.split(package.path, ";"),
        --       },
        --       diagnostics = {
        --         globals = { "vim" },
        --       },
        --       workspace = {
        --         library = {
        --           -- [vim.fn.expand("$VIMRUNTIME/lua")] = true,
        --           -- [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
        --           -- vim.api.nvim_get_runtime_file("", true),
        --           "C:/Neovim/share/nvim/runtime/lua/",
        --           -- "C:/Neovim/share/nvim/runtime/lua/vim/lsp",
        --           -- "C:/.local/share/nvim-data/",
        --         },
        --         checkThirdParty = false,
        --       },
        --       completion = {
        --         callSnippet = "Replace",
        --       },
        --     },
        --   },
        -- },
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        ionide = function(_, opts)
          -- local inp = vim.fn.input("please attach debugger")

          require("ionide").setup(opts)
          -- return true
        end,
        fsautocomplete = function(_, _)
          return true
        end,
        -- require("ionide").setup(opts)
        -- fsautocomplete = function(_, opts) -- require("ionide").setup(opts)
        -- require("lazyvim.util").on_attach(function(client, buffer) end)
        -- require("fsautocomplete").setup(opts)
        -- return false
        -- end,
        -- example to setup with typescript.nvim
        -- tsserver = function(_, opts)
        --   require("typescript").setup({ server = opts })
        --   return true
        -- end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },

      on_attach = require("lazyvim.util").on_attach(
        ---@type fun(client:any, buffer:any)
        function(client, buffer)
          local ft = vim.api.nvim_buf_get_option(0, "filetype")
          local isDotnet = ft == "cs" or ft == "fsharp" or ft == "fsharp_project"
          -- local isDotnetProj = vim.api.nvim_buf_get_option(0, "")
          local ignored = { "jsonls", "null-ls", "stylua", "lemminx", "editorconfig_checker" }
          -- local ignored = v.lsp.ignoredLspServersForFindingRoot
          -- v.Notify(client.name .. " is running on_attach")
          -- v.Notify(vim.inspect(ignored) .. " are servers being ignored")
          -- local on_attach_override = user_plugin_opts("lsp.on_attach", nil, false)
          -- conditional_func(on_attach_override, true, client, bufnr)
          -- local capabilities = client.server_capabilities
          -- vim.notify(client.name .. " is running on_attach")
          if not tc(ignored, client.name) then
            -- if client.name ~= "null-ls" and client.name ~= "stylua" and client.name ~= "lemminx" then
            -- local root = FindRoot(ignored, bufnr)
            local root = FindRoot(ignored, client, buffer)
            -- v.Notify("lsp root should have found root of : " .. root)
            local cwd = first_to_upper(vim.fs.normalize(fn.getcwd()))
            if not root then
              vim.notify(
                "lsp says it didn't find a root??? I'd go check that one out.. setting temporary root to current buffer's parent dir, but don't think that means that lsp is healthy right now.. you've been warned! "
              )
              root = first_to_upper(vim.fs.normalize(vim.fn.expand("%:p:h")))
            end
            local path = require("plenary.path")
            local rootpath = path:new(root)
            local cwdpath = path:new(cwd)
            local notEqual = rootpath.filename ~= cwdpath.filename
            -- v.Notify("i have the root and cwd now.. but ill check the number of buffers.. ")
            local recentlyAsked = lastAskedTime and os.difftime(os.time(), lastAskedTime) < rootSwitchSecondsInterval
            local shouldAsk = vim.tbl_count(fn.getbufinfo({ buflisted = true })) > 1 and recentlyAsked == false
            if notEqual then
              if shouldAsk == true then
                -- v.Notify("at this point the buffers say i should ask about setting root.. " .. vim.inspect(shouldAsk))
                if
                  fn.confirm(
                    "Do you want to change the current working directory to lsp root?  \n  ROOT: "
                      .. root
                      .. "  \n  CWD : "
                      .. cwd
                      .. "  \n",
                    "&yes\n&no",
                    2
                  ) == 1
                then
                  vim.cmd("cd " .. root)
                  vim.notify("CWD : " .. root)
                end
              else
                vim.cmd("cd " .. root)
                vim.notify("CWD : " .. root)
              end
              if isDotnet then
                vim.g["DotnetSlnRootPath"] = root
              end
            end
          end

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

          if client.name == "jsonls" then
            vim.lsp.buf.format()
          end
          if client.name == "omnisharp" then
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
      ),
    },
    -- },
  },
}
