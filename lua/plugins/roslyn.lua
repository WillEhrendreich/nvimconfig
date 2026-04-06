-- local mson_packages = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages")
-- local mason_registry = require("mason-registry")
--
-- --NOTE: should check the dir exists
-- local roslyn_base_path = vim.fs.joinpath(mson_packages, "roslyn", "libexec")
-- local rzls_base_path = vim.fs.joinpath(mson_packages, "rzls", "libexec")
--
-- ---@type string[]
-- local cmd = {
--   "dotnet",
--   vim.fs.joinpath(roslyn_base_path, "Microsoft.CodeAnalysis.LanguageServer.dll"),
--   "--stdio",
--   "--logLevel=Information",
--   "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
--   "--razorSourceGenerator=" .. vim.fs.joinpath(rzls_base_path, "Microsoft.CodeAnalysis.Razor.Compiler.dll"),
--   "--razorDesignTimePath=" .. vim.fs.joinpath(rzls_base_path, "Targets", "Microsoft.NET.Sdk.Razor.DesignTime.targets"),
-- }
--
-- --- @type RoslynNvimConfig
-- local config = {
--   ---@diagnostic disable-next-line: missing-fields
--   config = {
--     cmd = cmd,
--     capabilities = require("lsp.common").capabilities,
--     filetypes = { "cs" },
--     handlers = require("rzls.roslyn_handlers"),
--     settings = {
--       ["csharp|background_analysis"] = {
--         dotnet_analyzer_diagnostics_scope = "fullSolution",
--         dotnet_compiler_diagnostics_scope = "fullSolution",
--       },
--       ["csharp|inlay_hints"] = {
--         csharp_enable_inlay_hints_for_implicit_object_creation = true,
--         csharp_enable_inlay_hints_for_implicit_variable_types = true,
--
--         csharp_enable_inlay_hints_for_lambda_parameter_types = true,
--         csharp_enable_inlay_hints_for_types = true,
--         dotnet_enable_inlay_hints_for_indexer_parameters = true,
--         dotnet_enable_inlay_hints_for_literal_parameters = true,
--         dotnet_enable_inlay_hints_for_object_creation_parameters = true,
--         dotnet_enable_inlay_hints_for_other_parameters = true,
--         dotnet_enable_inlay_hints_for_parameters = true,
--         dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = false,
--         dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
--         dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = false,
--       },
--       ["csharp|code_lens"] = {
--         dotnet_enable_references_code_lens = true,
--         dotnet_enable_tests_code_lens = true,
--       },
--     },
--   },
--   filewatching = "auto",
-- }

return {
  -- { "Hoffs/omnisharp-extended-lsp.nvim", lazy = true },
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor", "vb" },
    dependencies = {},
    init = function()
      -- Extend roslyn LSP to also handle VB.NET files.
      -- The upstream lsp/roslyn.lua only declares { "cs", "razor" }, so we
      -- merge "vb" in here before the server starts.
      vim.lsp.config("roslyn", {
        filetypes = { "cs", "razor", "vb" },
      })

      -- Override root_dir so Roslyn can find a workspace root for VB.NET files.
      --
      -- The upstream sln/utils.lua only searches for .sln / .slnx / .slnf and
      -- .csproj. For VB-only projects there is no .csproj, so root_dir returns
      -- nil and Roslyn starts with no workspace (every file lands in
      -- MiscellaneousFiles, breaking InlineHints and other services).
      --
      -- This wrapper calls the upstream logic first (preserving all its special
      -- cases), then falls back to searching upward for a .vbproj.
      --
      -- NOTE: We register root_dir and all VB autocmds here in `init` (which runs
      -- at startup, before any FileType events) rather than in `config` (which runs
      -- after the plugin loads on first FileType match). By the time `config` would
      -- run, Roslyn has already attached to the buffer and the LspAttach event has
      -- already fired — making the autocmd registration too late.
      vim.lsp.config("roslyn", {
        root_dir = function(bufnr, on_dir)
          -- Special case 1: target is locked — use the stored solution directory.
          if vim.g.roslyn_nvim_selected_solution then
            local cfg_ok, cfg = pcall(require, "roslyn.config")
            if cfg_ok and cfg.get().lock_target then
              on_dir(vim.fs.dirname(vim.g.roslyn_nvim_selected_solution))
              return
            end
          end

          -- Special case 2: source-generated files share the root of the existing client.
          local buf_name = vim.api.nvim_buf_get_name(bufnr)
          if buf_name:match("^roslyn%-source%-generated://") then
            local existing = vim.lsp.get_clients({ name = "roslyn" })[1]
            if existing and existing.config.root_dir then
              on_dir(existing.config.root_dir)
              return
            end
          end

          -- Normal path: .sln / .csproj search (upstream logic).
          -- Guard with pcall because roslyn.nvim may not be loaded yet at this point;
          -- Neovim resolves root_dir lazily when Roslyn first starts, by which time
          -- the plugin will be loaded.
          local utils_ok, sln_utils = pcall(require, "roslyn.sln.utils")
          if utils_ok then
            local root = sln_utils.root_dir(bufnr)
            if root then
              on_dir(root)
              return
            end
          end

          -- VB fallback: search upward for a .vbproj.
          local vbproj = vim.fs.find(function(name)
            return name:match("%.vbproj$") ~= nil
          end, { upward = true, path = buf_name })[1]

          on_dir(vbproj and vim.fs.dirname(vbproj) or nil)
        end,
      })

      -- Register VB-specific autocmds to mirror what plugin/roslyn.lua does for
      -- C# and Razor. The upstream plugin/roslyn.lua only matches *.cs / *.razor /
      -- *.cshtml patterns; VB files are silently excluded from those autocmds.
      local group = vim.api.nvim_create_augroup("roslyn.nvim.vb", { clear = true })

      -- When on_init.sln() fires for our TubeEdit.sln, cycle all open .vb
      -- buffers through didClose/didOpen so Roslyn re-registers them under
      -- the project context instead of MiscellaneousFiles.
      --
      -- PRIMARY PATH: combined_on_init installs a one-shot
      -- workspace/projectInitializationComplete handler that does the
      -- didClose/didOpen cycle at exactly the right moment (when Roslyn
      -- finishes MSBuild evaluation). That handler fires first.
      --
      -- THIS AUTOCMD IS A FALLBACK for `:Roslyn restart` or any scenario
      -- where combined_on_init's handler was already consumed. The 500ms
      -- defer is intentionally short — workspace/projectInitializationComplete
      -- normally fires within 2s, so by the time this fires it is usually
      -- redundant (cycling already-migrated files is harmless).
      --
      -- WHY solution/open AND NOT project/open:
      --   Roslyn's VB.NET language service only responds to solution/open.
      --   project/open is handled by the C# service only — VB files sent via
      --   project/open stay in MiscellaneousFiles.  We confirmed this live:
      --   project/open + didClose/didOpen still returned -32000.
      --   solution/open with a real .sln (TubeEdit.sln → TubeEdit.vbproj)
      --   is the correct path.
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "RoslynOnInit",
        callback = function(args)
          -- Fire for both solution and project inits so we cover any future
          -- upstream change, but in practice this will be "solution" for VB.
          if not args.data then
            return
          end

          local client_id = args.data.client_id
          local client = vim.lsp.get_client_by_id(client_id)
          if not client then
            return
          end

          -- Defer briefly to let Roslyn settle after the project/solution
          -- notification. The primary migration path is the one-shot
          -- workspace/projectInitializationComplete handler in combined_on_init;
          -- this fallback fires after 500 ms and is harmless if migration already
          -- happened (cycling an already-registered document is a no-op).
          vim.defer_fn(function()
            local count = 0
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf) then
                local bname = vim.api.nvim_buf_get_name(buf)
                if bname:match("%.vb$") then
                  -- Only cycle buffers that are attached to this specific client.
                  local attached = false
                  for _, c in ipairs(vim.lsp.get_clients({ name = "roslyn", bufnr = buf })) do
                    if c.id == client_id then
                      attached = true
                      break
                    end
                  end
                  if attached then
                    client:notify("textDocument/didClose", {
                      textDocument = { uri = vim.uri_from_fname(bname) },
                    })
                    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                    client:notify("textDocument/didOpen", {
                      textDocument = {
                        uri        = vim.uri_from_fname(bname),
                        languageId = "vb",
                        version    = 0,
                        text       = table.concat(lines, "\n"),
                      },
                    })
                    count = count + 1
                  end
                end
              end
            end
            if count > 0 then
              vim.notify(
                string.format("Roslyn VB: re-registered %d buffer(s) under project context", count),
                vim.log.levels.INFO,
                { title = "roslyn.nvim" }
              )
            end
          end, 500)
        end,
      })

      -- Keep vim.g.roslyn_nvim_selected_solution current when switching VB buffers.
      vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        pattern = "*.vb",
        callback = function(args)
          local cfg_ok, cfg = pcall(require, "roslyn.config")
          if not cfg_ok then
            return
          end
          local client = vim.lsp.get_clients({ name = "roslyn", bufnr = args.buf })[1]
          if client and not cfg.get().lock_target then
            local store_ok, store = pcall(require, "roslyn.store")
            if store_ok then
              vim.g.roslyn_nvim_selected_solution = store.get(client.id)
            end
          end
        end,
      })

      -- Register RoslynCommands (target picker, restart, etc.) for VB file types.
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "vb",
        callback = function()
          local ok, cmds = pcall(require, "roslyn.commands")
          if ok then
            cmds.create_roslyn_commands()
          end

          -- :RoslynReloadVB — manually force didClose/didOpen for all open .vb
          -- buffers. Use this when Roslyn reports MiscellaneousFiles errors after
          -- a fresh Neovim start (project/open races with the initial attach).
          vim.api.nvim_create_user_command("RoslynReloadVB", function()
            local clients = vim.lsp.get_clients({ name = "roslyn" })
            if #clients == 0 then
              vim.notify("No roslyn client attached", vim.log.levels.WARN)
              return
            end
            local c = clients[1]
            local count = 0
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf) then
                local bname = vim.api.nvim_buf_get_name(buf)
                if bname:match("%.vb$") then
                  c:notify("textDocument/didClose", {
                    textDocument = { uri = vim.uri_from_fname(bname) },
                  })
                  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                  c:notify("textDocument/didOpen", {
                    textDocument = {
                      uri        = vim.uri_from_fname(bname),
                      languageId = "vb",
                      version    = 0,
                      text       = table.concat(lines, "\n"),
                    },
                  })
                  count = count + 1
                end
              end
            end
            vim.notify(
              string.format("RoslynReloadVB: cycled %d .vb buffer(s)", count),
              vim.log.levels.INFO
            )
          end, { desc = "Force Roslyn to reload all open .vb buffers" })
        end,
      })

      -- Refresh diagnostics after saving or leaving insert mode in VB files.
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        group = group,
        pattern = "*.vb",
        callback = function()
          for _, client in ipairs(vim.lsp.get_clients({ name = "roslyn" })) do
            local ok, diag = pcall(require, "roslyn.lsp.diagnostics")
            if ok then
              diag.refresh(client)
            end
          end
        end,
      })

      -- Disable LSP capabilities that are fundamentally broken for VB.NET in
      -- Roslyn's LSP implementation.  Roslyn's VB support does not expose the
      -- syntax tree model required by these three handlers, so every request
      -- results in a "-32000 Syntax tree" error.  Nulling the capability entries
      -- tells Neovim not to send the requests in the first place.
      --
      -- This fires on every LspAttach for a VB buffer, which is safe: capability
      -- tables are per-client, so modifying them here only affects VB contexts
      -- (Roslyn will still serve documentSymbol etc. for C# files in other clients).
      vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        pattern = "*.vb",
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "roslyn" then
            return
          end
          -- documentSymbol: outline / symbol list (broken for VB)
          client.server_capabilities.documentSymbolProvider = nil
          -- documentHighlight: highlight other occurrences of word under cursor (broken for VB)
          client.server_capabilities.documentHighlightProvider = nil
          -- semanticTokens: token-based syntax highlighting (broken for VB)
          client.server_capabilities.semanticTokensProvider = nil
        end,
      })

      -- Inject a combined on_init handler that replicates the upstream logic AND
      -- adds a VB.NET fallback.
      --
      -- WHY HERE AND NOT IN `config`:
      --   lazy.nvim calls `init` before any FileType event; `config` runs only
      --   after the plugin is loaded (which happens on the FIRST FileType match).
      --   By that time Neovim's lsp_enable_callback has already fired, deep-copied
      --   the resolved config (with only the upstream on_init), and started the
      --   Roslyn client.  Any table.insert done in `config` is too late — the
      --   running client's _on_init_cbs list was already finalised.
      --
      -- WHY NOT table.insert ON vim.lsp.config["roslyn"].on_init:
      --   vim.lsp.config["roslyn"] triggers __index → tbl_deep_extend → a NEW
      --   resolved_config table is returned and cached in _enabled_configs.
      --   table.insert mutates that cached table, but the client was already
      --   started with a deepcopy made at FileType time.  The mutation is too late.
      --
      -- WHY THIS APPROACH WORKS:
      --   vim.lsp.config._configs["roslyn"] is the user-level layer.  During
      --   resolution it wins over the rtp layer (lsp/roslyn.lua) via
      --   tbl_deep_extend('force', rtp_config, _configs[name]).  By writing
      --   our combined function here we replace the rtp on_init array entirely,
      --   but our function contains all of the upstream logic verbatim so no
      --   C# / Razor behaviour is lost.
      --
      -- WHAT THE COMBINED FUNCTION DOES (mirrors upstream lsp/roslyn.lua exactly):
      --   1. Fix renameProvider (upstream line 105).
      --   2. Disable semanticTokens.full for Razor on nvim < 0.12 (upstream 107-119).
      --   3. Guard on root_dir (upstream 121-123).
      --   4. lock_target + selected_solution → on_init.sln (upstream 131-133).
      --   5. .sln / .slnx / .slnf search → on_init.sln (upstream 135-141).
      --        NOTE: TubeEdit.sln is found here for VB workspaces — no VB-specific
      --        step needed.  on_init.sln() calls store.set() + solution/open, which
      --        is the ONLY path that works for Roslyn's VB.NET language service.
      --   6. .csproj search → on_init.project (upstream 143-146).
      --   7. selected_solution fallback → on_init.sln (upstream 148-150).
      --        Terminal step; if none of 4-7 matched, Roslyn has no workspace.
      local combined_on_init = function(client)
        -- 1. Roslyn advertises prepareRename but cohosted Razor doesn't support it.
        client.server_capabilities.renameProvider = true

        -- 2. Semantic tokens /full is unsupported for Razor files on nvim < 0.12.
        if vim.fn.has("nvim-0.12") == 0 then
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              if vim.api.nvim_get_option_value("filetype", { buf = args.buf }) == "razor" then
                if args.data.client_id == client.id then
                  if client.server_capabilities.semanticTokensProvider then
                    client.server_capabilities.semanticTokensProvider.full = nil
                  end
                end
              end
            end,
          })
        end

        -- 3. Nothing to open if Roslyn has no workspace root.
        if not client.config.root_dir then
          return
        end

        -- Mirror the upstream debug log line (lsp/roslyn.lua line 124).
        local log_ok, rlog = pcall(require, "roslyn.log")
        if log_ok then
          rlog.log(string.format("lsp on_init root_dir: %s", client.config.root_dir))
        end

        -- All further logic depends on these modules being available.
        -- They are guaranteed to be loaded by the time on_init fires because
        -- the FileType event that starts Roslyn also loads the plugin.
        local utils    = require("roslyn.sln.utils")
        local on_init  = require("roslyn.lsp.on_init")
        local config   = require("roslyn.config").get()
        local selected = vim.g.roslyn_nvim_selected_solution

        -- 4. Locked target: always re-open the same solution.
        if config.lock_target and selected then
          return on_init.sln(client, selected)
        end

        -- 5. Search for a solution file first.
        local files = utils.find_files_with_extensions(
          client.config.root_dir, { ".sln", ".slnx", ".slnf" }
        )
        local solution = utils.predict_target(vim.api.nvim_get_current_buf(), files)
        if solution then
          -- Register a one-shot handler for workspace/projectInitializationComplete.
          --
          -- WHY: solution/open is a fire-and-forget notification. Roslyn begins loading
          -- the solution asynchronously. workspace/projectInitializationComplete is the
          -- signal that MSBuild evaluation is done and all projects are registered.
          --
          -- The original RoslynOnInit autocmd used a blind 3s defer to cycle
          -- didClose/didOpen. The log showed workspace/inlayHint/refresh arriving at
          -- T+2s — before the 3s defer fired — causing MiscellaneousFiles errors.
          --
          -- This handler fires exactly when Roslyn is ready, with no race. It is
          -- cleared after first use so it doesn't re-run on subsequent project reloads.
          --
          -- NOTE: we only install this for VB workspaces (where solution contains a
          -- .vbproj). For C# solutions Roslyn handles document migration automatically.
          if solution:match("%.sln$") or solution:match("%.slnx$") or solution:match("%.slnf$") then
            local vb_files_present = vim.iter(vim.api.nvim_list_bufs()):any(function(b)
              return vim.api.nvim_buf_get_name(b):match("%.vb$") ~= nil
            end)
            if vb_files_present then
              -- CRITICAL: must write to client.config.handlers, NOT client.handlers.
              -- Neovim's _resolve_handler() checks client.config.handlers first (set at startup
              -- from the lsp config); client.handlers is a secondary per-client override table
              -- that is only consulted when client.config.handlers has no entry.  The upstream
              -- roslyn.nvim plugin already registers its own handler for this notification in
              -- client.config.handlers at startup, so writing to client.handlers would be
              -- silently shadowed.  We wrap the upstream handler so it still runs after us.
              local orig_handler = client.config.handlers and client.config.handlers["workspace/projectInitializationComplete"]
              client.config.handlers = client.config.handlers or {}
              client.config.handlers["workspace/projectInitializationComplete"] = function(err, result, ctx, config)
                -- Restore original handler (or remove) immediately to make this one-shot.
                client.config.handlers["workspace/projectInitializationComplete"] = orig_handler

                -- Cycle all open .vb buffers attached to this client through
                -- didClose/didOpen so Roslyn re-registers them under the project
                -- context instead of MiscellaneousFiles.
                local count = 0
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                  if vim.api.nvim_buf_is_loaded(buf) then
                    local bname = vim.api.nvim_buf_get_name(buf)
                    if bname:match("%.vb$") then
                      local attached = vim.iter(vim.lsp.get_clients({ name = "roslyn", bufnr = buf })):any(
                        function(c) return c.id == client.id end
                      )
                      if attached then
                        client:notify("textDocument/didClose", {
                          textDocument = { uri = vim.uri_from_fname(bname) },
                        })
                        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                        client:notify("textDocument/didOpen", {
                          textDocument = {
                            uri        = vim.uri_from_fname(bname),
                            languageId = "vb",
                            version    = 0,
                            text       = table.concat(lines, "\n"),
                          },
                        })
                        count = count + 1
                      end
                    end
                  end
                end
                if count > 0 then
                  vim.schedule(function()
                    vim.notify(
                      string.format("Roslyn VB: migrated %d buffer(s) from MiscellaneousFiles on projectInitializationComplete", count),
                      vim.log.levels.INFO,
                      { title = "roslyn.nvim" }
                    )
                  end)
                end

                -- Call original handler if one existed.
                if orig_handler then
                  orig_handler(err, result, ctx, config)
                end
              end
            end
          end

          return on_init.sln(client, solution)
        end

        -- 6. C# project file search.
        local csproj = utils.find_files_with_extensions(client.config.root_dir, { ".csproj" })
        if #csproj > 0 then
          return on_init.project(client, csproj)
        end

        -- 7. Previously-selected solution fallback (e.g. after :Roslyn target pick).
        if selected then
          return on_init.sln(client, selected)
        end

        -- No workspace target found.  Roslyn will start with no solution loaded;
        -- files will land in MiscellaneousFiles until a target is supplied manually
        -- via :Roslyn target.
      end

      -- Write the combined handler into the user-level config layer.
      -- tbl_deep_extend('force', rtp_config, _configs[name]) means _configs wins,
      -- so this replaces the rtp on_init array for the resolved config.
      local existing = vim.lsp.config._configs["roslyn"] or {}
      existing.on_init = { combined_on_init }
      vim.lsp.config._configs["roslyn"] = existing
    end,
    opts = {
      -- "auto" | "roslyn" | "off"
      --
      -- - "auto": Does nothing for filewatching, leaving everything as default
      -- - "roslyn": Turns off neovim filewatching which will make roslyn do the filewatching
      -- - "off": Hack to turn off all filewatching. (Can be used if you notice performance issues)
      filewatching = "auto",

      -- Optional function that takes an array of targets as the only argument. Return the target you
      -- want to use. If it returns `nil`, then it falls back to guessing the target like normal
      -- Example:
      --
      -- choose_target = function(target)
      --     return vim.iter(target):find(function(item)
      --         if string.match(item, "Foo.sln") then
      --             return item
      --         end
      --     end)
      -- end
      choose_target = nil,

      -- Optional function that takes the selected target as the only argument.
      -- Returns a boolean of whether it should be ignored to attach to or not
      --
      -- I am for example using this to disable a solution with a lot of .NET Framework code on mac
      -- Example:
      --
      -- ignore_target = function(target)
      --     return string.match(target, "Foo.sln") ~= nil
      -- end
      ignore_target = nil,

      -- Whether or not to look for solution files in the child of the (root).
      -- Set this to true if you have some projects that are not a child of the
      -- directory with the solution file
      broad_search = false,

      -- Whether or not to lock the solution target after the first attach.
      -- This will always attach to the target in `vim.g.roslyn_nvim_selected_solution`.
      -- NOTE: You can use `:Roslyn target` to change the target
      lock_target = false,
    },
    config = function(_, opts)
      -- roslyn.nvim's setup() registers the plugin config and finalises LSP
      -- settings (filewatching capabilities etc.). All VB-specific overrides
      -- (root_dir, combined on_init, RoslynOnInit autocmd, mirror autocmds)
      -- are registered in `init` above so they are in place before Roslyn can
      -- attach on the very first FileType event.
      require("roslyn").setup(opts)
    end,
  },
  -- {
  --   "seblj/roslyn.nvim",
  --   args = {
  --     "--logLevel=Information",
  --     "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
  --     "--stdio",
  --     "--razorSourceGenerator=" .. vim.fs.joinpath(
  --       vim.fn.stdpath("data") --[[@as string]],
  --       "mason",
  --       "packages",
  --       "roslyn",
  --       "libexec",
  --       "Microsoft.CodeAnalysis.Razor.Compiler.dll"
  --     ),
  --     "--razorDesignTimePath=" .. vim.fs.joinpath(
  --       vim.fn.stdpath("data") --[[@as string]],
  --       "mason",
  --       "packages",
  --       "rzls",
  --       "libexec",
  --       "Targets",
  --       "Microsoft.NET.Sdk.Razor.DesignTime.targets"
  --     ),
  --   },
  --   dependancies = {
  --     "tris203/rzls.nvim",
  --   },
  --   opts = {
  --     on_attach = function(client, bufnr)
  --       OnAttach(client, bufnr)
  --     end,
  --
  --     capabilities = vim.lsp.protocol.make_client_capabilities(),
  --     handlers = vim.tbl_deep_extend("force", {}, require("rzls.roslyn_handlers"), {
  --       ["textDocument/definition"] = function(...)
  --         return require("omnisharp_extended").handler(...)
  --       end,
  --     }),
  --     keys = {
  --       {
  --         "gd",
  --         function()
  --           require("omnisharp_extended").telescope_lsp_definitions()
  --         end,
  --         desc = "Goto Definition",
  --       },
  --     },
  --     settings = {
  --       ["csharp|background_analysis"] = {
  --         dotnet_compiler_diagnostics_scope = "fullSolution",
  --       },
  --       ["csharp|inlay_hints"] = {
  --         csharp_enable_inlay_hints_for_implicit_object_creation = true,
  --         csharp_enable_inlay_hints_for_implicit_variable_types = true,
  --         csharp_enable_inlay_hints_for_lambda_parameter_types = true,
  --         csharp_enable_inlay_hints_for_types = true,
  --         dotnet_enable_inlay_hints_for_indexer_parameters = true,
  --         dotnet_enable_inlay_hints_for_literal_parameters = true,
  --         dotnet_enable_inlay_hints_for_object_creation_parameters = true,
  --         dotnet_enable_inlay_hints_for_other_parameters = true,
  --         dotnet_enable_inlay_hints_for_parameters = true,
  --         dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = false,
  --         dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
  --         dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = false,
  --       },
  --       ["csharp|code_lens"] = {
  --         dotnet_enable_references_code_lens = true,
  --       },
  --     },
  --   },
  --
  --   init = function()
  --     -- we add the razor filetypes before the plugin loads
  --     vim.filetype.add({
  --       extension = {
  --         razor = "razor",
  --         cshtml = function(path, bufnr)
  --           return "razor",
  --             function(bufnr)
  --               vim.w.fdm = "syntax"
  --               -- comment settings
  --               vim.bo[bufnr].formatoptions = "croql"
  --               vim.bo[bufnr].commentstring = "<!--%s-->"
  --             end
  --         end,
  --         cs = function(path, bufnr)
  --           return "cs",
  --             function(bufnr)
  --               if not vim.g.filetype_cs then
  --                 vim.g["filetype_cs"] = "cs"
  --               end
  --               if not vim.g.filetype_cs == "cs" then
  --                 vim.g["filetype_cs"] = "cs"
  --               end
  --               vim.w.fdm = "syntax"
  --               -- comment settings
  --               vim.bo[bufnr].formatoptions = "croql"
  --               vim.bo[bufnr].commentstring = "// %s"
  --             end
  --         end,
  --         csx = function(path, bufnr)
  --           return "cs",
  --             function(bufnr)
  --               vim.w.fdm = "syntax"
  --               vim.bo[bufnr].formatoptions = "croql"
  --             end
  --         end,
  --         --     csproj = function(path, bufnr)
  --         --       return "cs_project",
  --         --         function(buf)
  --         --           -- vim.bo[buf].syn = "xml"
  --         --           -- vim.cmd("set syntax= xml")
  --         --           vim.bo[buf].syntax = "xml"
  --         --           vim.bo[buf].ro = false
  --         --           vim.b[buf].readonly = false
  --         --           vim.opt_local.foldlevelstart = 99
  --         --           vim.w.fdm = "syntax"
  --         --         end
  --         --     end,
  --       },
  --     })
  --   end,
  --   config = true,
  -- },
  -- {
  --   "neovim/nvim-lspconfig",
  --   servers = {
  --     roslyn = {
  --       ft = { "cs", "razor" },
  --     },
  --   },
  --   setup = {
  --     roslyn = function(_, opts) -- code
  --       require("roslyn").setup(opts)
  --     end,
  --   },
  -- },
  -- { "adamclerk/vim-razor" },
}
