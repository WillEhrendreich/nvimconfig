local tbl_contains = vim.tbl_contains
local tbl_isempty = vim.tbl_isempty
local user_plugin_opts = astronvim.user_plugin_opts
local conditional_func = astronvim.conditional_func

local replaceSeps = function(p)
  local stringArg = p or ""
  return stringArg:gsub("\\", "/")
end
return function(client, bufnr)
  local capabilities = client.server_capabilities
  -- vim.notify(client.name .. " is running on_attach")
  if client.name ~= "null-ls" or client.name ~= "stylua" or client.name ~= "" then
    local root = replaceSeps(vim.lsp.buf.list_workspace_folders()[1]) .. "/"
    local cwd = replaceSeps(vim.fn.getcwd()) .. "/"
    -- if client.name == "ionide" or client.name == "omnisharp" or client.name == "fsautocomplete" then
    if root and cwd ~= root then
      if vim.fn.confirm(
        "Do you want to change the current working directory to lsp root?\nROOT: "
        .. root
        .. "\nCWD : "
        .. cwd
        .. "\n",
        "&yes\n&no",
        2
      ) == 1
      then
        vim.cmd("cd " .. root)
        vim.notify("CWD : " .. root)
      end
      vim.g["dotnet_last_proj_path"] = root
      -- vim.g.dotnet_startup_proj_path = client.root
      vim.g["dotnet_last_dll_path"] = root .. "bin/debug/"
    end
  end
  local lsp_mappings = {
    n = {
      ["<leader>ld"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" },
      ["gN"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" },
      ["gn"] = { function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" },
      ["gl"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" },
    },
    v = {},
  }

  if capabilities.codeActionProvider then
    lsp_mappings.n["<leader>ca"] = { function() vim.lsp.buf.code_action() end, desc = "LSP code action" }
    lsp_mappings.v["<leader>ca"] = lsp_mappings.n["<leader>ca"]
  end

  if capabilities.declarationProvider then
    lsp_mappings.n["gD"] = { function() vim.lsp.buf.declaration() end, desc = "Declaration of current symbol" }
  end

  if capabilities.definitionProvider then
    lsp_mappings.n["gd"] = { function() vim.lsp.buf.definition() end, desc = "Show the definition of current symbol" }
  end

  if capabilities.documentFormattingProvider then
    lsp_mappings.n["<leader>lf"] = {
      function() vim.lsp.buf.format(astronvim.lsp.format_opts) end,
      desc = "Format code",
    }
    lsp_mappings.v["<leader>lf"] = lsp_mappings.n["<leader>lf"]

    vim.api.nvim_buf_create_user_command(
      bufnr,
      "Format",
      function() vim.lsp.buf.format(astronvim.lsp.format_opts) end,
      { desc = "Format file with LSP" }
    )
    local autoformat = astronvim.lsp.formatting.format_on_save
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
    if autoformat.enabled
        and (tbl_isempty(autoformat.allow_filetypes or {}) or tbl_contains(autoformat.allow_filetypes, filetype))
        and (tbl_isempty(autoformat.ignore_filetypes or {}) or not tbl_contains(autoformat.ignore_filetypes, filetype))
    then
      local autocmd_group = "auto_format_" .. bufnr
      vim.api.nvim_create_augroup(autocmd_group, { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = autocmd_group,
        buffer = bufnr,
        desc = "Auto format buffer " .. bufnr .. " before save",
        callback = function()
          if vim.g.autoformat_enabled then
            vim.lsp.buf.format(astronvim.default_tbl({ bufnr = bufnr }, astronvim.lsp.format_opts))
          end
        end,
      })
      lsp_mappings.n["<leader>uf"] = {
        function() astronvim.ui.toggle_autoformat() end,
        desc = "Toggle autoformatting",
      }
    end
  end

  if capabilities.hoverProvider then
    lsp_mappings.n["K"] = { function() vim.lsp.buf.hover() end, desc = "Hover symbol details" }
  end

  if capabilities.implementationProvider then
    lsp_mappings.n["gI"] = { function() vim.lsp.buf.implementation() end, desc = "Implementation of current symbol" }
  end

  if capabilities.referencesProvider then
    lsp_mappings.n["gr"] = { function() vim.lsp.buf.references() end, desc = "References of current symbol" }
  end

  if capabilities.renameProvider then
    lsp_mappings.n["<leader>lr"] = { function() vim.lsp.buf.rename() end, desc = "Rename current symbol" }
  end

  if capabilities.signatureHelpProvider then
    lsp_mappings.n["<leader>lh"] = { function() vim.lsp.buf.signature_help() end, desc = "Signature help" }
  end

  if capabilities.typeDefinitionProvider then
    lsp_mappings.n["gT"] = { function() vim.lsp.buf.type_definition() end, desc = "Definition of current type" }
  end

  -- original version from Astrovim --
  --
  -- if capabilities.documentHighlightProvider then
  --   local highlight_name = vim.fn.printf("lsp_document_highlight_%d", bufnr)
  --   vim.api.nvim_create_augroup(highlight_name, {})
  --   vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  --     group = highlight_name,
  --     buffer = bufnr,
  --     callback = function() vim.lsp.buf.document_highlight() end,
  --   })
  --   vim.api.nvim_create_autocmd("CursorMoved", {
  --     group = highlight_name,
  --     buffer = bufnr,
  --     callback = function() vim.lsp.buf.clear_references() end,
  --   })
  -- end
  --

  if capabilities.documentHighlightProvider then
    local highlight_name = vim.fn.printf("lsp_document_highlight_%d", bufnr)
    vim.api.nvim_create_augroup(highlight_name, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = highlight_name,
      buffer = bufnr,
      callback = function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        -- check if cursor is on an empty column
        local row, col = cursor[1] - 1, cursor[2]
        local line = vim.api.nvim_buf_get_lines(0, row, row + 1, true)[1]
        if line
            and (
            #line == 0
                or line:sub(col + 1, col + 1):match "^%s+$"
                or line:sub(col + 1, col + 1):match "let"
                or line:sub(col + 1, col + 1):match "="
                or line:sub(col + 1, col + 1):match "/\\W"

            )
        then
          return
        end

        vim.lsp.buf.document_highlight()
      end,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = highlight_name,
      buffer = bufnr,
      callback = function() vim.lsp.buf.clear_references() end,
    })
  end

  if capabilities.codeLensProvider then
    local group_name = "codelens_" .. bufnr
    vim.api.nvim_create_augroup(group_name, { clear = true })
    -- default Astrovim version
    --vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      --vim.api.nvim_create_autocmd({ "BufWrite" }, {
      group = group_name,
      callback = function() vim.lsp.codelens.refresh() end,
      buffer = bufnr,
    })
  end
end
