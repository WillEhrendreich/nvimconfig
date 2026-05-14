-- vbnet-lsp.lua
-- Thin wrapper around DNAKode/vbnet-lsp — a purpose-built VB.NET LSP server.
-- Repo:    https://github.com/DNAKode/vbnet-lsp
-- Install: dotnet tool install --global DNAKode.VbNet.Lsp  (command: vbnet-ls)
--
-- This plugin runs PARALLEL to roslyn.nvim for VB files.  Roslyn continues to
-- serve C# / Razor; vbnet-ls serves VB exclusively and avoids the
-- MiscellaneousFiles workspace problem that plagues Roslyn for VB-only projects.
--
-- The adapter logic below is adapted from:
--   adapters/nvim/vbnet-lsp.nvim/lua/vbnet_lsp/init.lua  (MIT, DNAKode)
-- Inlined here so no plugin-manager dependency on the upstream adapter repo
-- is needed.  The vbnet-ls binary is installed as a global .NET tool.

-- Guard: only activate when vbnet-ls is on PATH.
if vim.fn.executable("vbnet-ls") == 0 then
  return {}
end

return {
  {
    -- "virtual" = true tells lazy.nvim this spec has no plugin directory to
    -- manage.  lazy = false ensures config() runs at startup so the augroup
    -- is registered before any VB FileType events fire.
    "vbnet-lsp",
    virtual  = true,
    name     = "vbnet-lsp",
    lazy     = false,
    priority = 100,
    config   = function()
      -- Resolve root dir upward from a buffer's file path.
      -- Prefers the closest .sln / .slnx, then .vbproj, then cwd.
      local function resolve_root(buf_path)
        local marker = vim.fs.find(function(name)
          return name:match("%.sln$")  ~= nil
              or name:match("%.slnx$") ~= nil
              or name:match("%.vbproj$") ~= nil
        end, { upward = true, path = buf_path })[1]
        return marker and vim.fs.dirname(marker) or vim.fn.getcwd()
      end

      local diagnostic_group = vim.api.nvim_create_augroup("vbnet_lsp_diagnostics", { clear = true })

      local function disable_duplicate_vbnet_namespace(client, bufnr)
        local function disable_now()
          local duplicate_name = string.format("nvim.lsp.%s.%d.vbnet", client.name, client.id)
          for ns_id, meta in pairs(vim.diagnostic.get_namespaces()) do
            if meta.name == duplicate_name then
              vim.diagnostic.enable(false, { bufnr = bufnr, ns_id = ns_id })
            end
          end
        end

        disable_now()
        vim.api.nvim_create_autocmd("DiagnosticChanged", {
          group = diagnostic_group,
          buffer = bufnr,
          callback = disable_now,
          desc = "Disable duplicate vbnet-lsp diagnostic namespace for this buffer",
        })
      end

      -- Start (or reuse) a vbnet-ls client for the given buffer.
      -- Each unique root_dir gets its own client instance; buffers sharing
      -- the same root reuse the existing client (upstream reuse_client logic).
      local function start_vbnet(bufnr)
        -- Enable autoread so that when vbnet-ls writes a formatted version of
        -- the file to disk (as a side effect of its analysis), Neovim silently
        -- reloads the buffer instead of prompting "file changed since reading
        -- it".  LazyVim's default checktime autocmd (on FocusGained /
        -- TermClose / TermLeave) triggers the reload automatically.
        vim.bo[bufnr].autoread = true

        local buf_path = vim.api.nvim_buf_get_name(bufnr)
        local root     = resolve_root(buf_path)

        vim.lsp.start({
          name     = "vbnet_lsp",
          cmd      = { "vbnet-ls", "--stdio" },
          root_dir = root,
          filetypes = { "vb" },
          on_attach = function(client, attached_bufnr)
            disable_duplicate_vbnet_namespace(client, attached_bufnr)
          end,
          -- Reuse an existing vbnet-ls client for the same root_dir.
          reuse_client = function(client, cfg)
            return client.name == cfg.name
               and client.config.root_dir == cfg.root_dir
          end,
        }, { bufnr = bufnr })
      end

      -- Wire the FileType autocmd.  Using a dedicated augroup so `:Lazy reload`
      -- can cleanly re-register without duplicating the autocmd.
      local group = vim.api.nvim_create_augroup("vbnet_lsp", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group    = group,
        pattern  = "vb",
        callback = function(args)
          start_vbnet(args.buf)
        end,
      })

      -- Handle the currently open VB buffer (the one that triggered lazy to
      -- load this plugin).  The FileType event has already fired for it, so
      -- we need to kick start_vbnet manually.
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf)
          and vim.bo[buf].filetype == "vb"
        then
          start_vbnet(buf)
        end
      end

      -- Convenience command: pick a solution file and notify the running server.
      vim.api.nvim_create_user_command("VbNetPickSolution", function()
        local client = vim.lsp.get_clients({ name = "vbnet_lsp" })[1]
        if not client then
          vim.notify("[vbnet-lsp] server not running", vim.log.levels.ERROR)
          return
        end
        local root       = client.config.root_dir
        local candidates = {}
        for _, f in ipairs(vim.fn.globpath(root, "**/*.sln",  true, true)) do table.insert(candidates, f) end
        for _, f in ipairs(vim.fn.globpath(root, "**/*.slnx", true, true)) do table.insert(candidates, f) end
        table.sort(candidates, function(a, b) return #a < #b end)
        if #candidates == 0 then
          vim.notify("[vbnet-lsp] No .sln files found under " .. root, vim.log.levels.WARN)
          return
        end
        vim.ui.select(candidates, { prompt = "vbnet-lsp: Select solution" }, function(choice)
          if choice and choice ~= "" then
            client.notify("solution/open", { solution = vim.fn.fnamemodify(choice, ":p") })
          end
        end)
      end, {})
    end,
  },
}
