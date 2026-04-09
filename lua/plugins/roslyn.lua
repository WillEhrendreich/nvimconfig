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
    ft = { "cs", "razor" },
    dependencies = {},
    build = function()
      -- Re-apply the fsproj/vbproj patch after upstream updates.
      -- The patch widens all hardcoded "%.csproj$" guards to "%.%a+proj$"
      -- so that .fsproj and .vbproj files are discovered correctly.
      local patch = vim.fn.stdpath("config") .. "/patches/roslyn-fsproj-support.patch"
      local plugin_dir = vim.fn.stdpath("data") .. "/lazy/roslyn.nvim"
      if vim.fn.filereadable(patch) == 1 then
        local result = vim.fn.system({
          "git", "-C", plugin_dir, "apply", "--ignore-whitespace", patch
        })
        if vim.v.shell_error ~= 0 then
          -- Already applied or conflict — check clean state before worrying.
          vim.notify("roslyn.nvim patch: " .. result, vim.log.levels.WARN)
        end
      end
    end,
    init = function()
      -- VB.NET is now handled exclusively by vbnet-lsp (lua/plugins/vbnet-lsp.lua).
      -- Roslyn only handles C# and Razor.

      -- Override root_dir to preserve upstream special-case handling (locked targets,
      -- source-generated files) while delegating the normal search to roslyn.sln.utils.
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

          -- Normal path: delegate to upstream .sln / .csproj search.
          local utils_ok, sln_utils = pcall(require, "roslyn.sln.utils")
          if utils_ok then
            local root = sln_utils.root_dir(bufnr)
            if root then
              on_dir(root)
              return
            end
          end

          on_dir(nil)
        end,
      })

      -- Inject a combined on_init handler that replicates the upstream logic.
      --
      -- WHY HERE AND NOT IN `config`:
      --   lazy.nvim calls `init` before any FileType event; `config` runs only
      --   after the plugin is loaded (which happens on the FIRST FileType match).
      --   By that time Neovim's lsp_enable_callback has already fired, deep-copied
      --   the resolved config (with only the upstream on_init), and started the
      --   Roslyn client.  Any table.insert done in `config` is too late — the
      --   running client's _on_init_cbs list was already finalised.
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
      --   6. .csproj search → on_init.project (upstream 143-146).
      --   7. selected_solution fallback → on_init.sln (upstream 148-150).
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
          return on_init.sln(client, solution)
        end

        -- 6. Project file search (.csproj, .fsproj, .vbproj, etc.)
        local csproj = utils.find_files_with_extensions(client.config.root_dir, { ".csproj", ".fsproj", ".vbproj" })
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
