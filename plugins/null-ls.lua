local null_ls = require "null-ls"
return {
  sources = {
    null_ls.builtins.code_actions.gitsigns,
    null_ls.builtins.code_actions.shellcheck,
    -- null_ls.builtins.formatting.stylua,
    -- null_ls.builtins.formatting.black,
    -- null_ls.builtins.formatting.isort,
    null_ls.builtins.formatting.prettier.with { extra_filetypes = { "rmd" } },
    -- null_ls.builtins.formatting.shfmt,
    null_ls.builtins.diagnostics.cue_fmt,
    null_ls.builtins.diagnostics.shellcheck,
  },
  on_attach = function(client)
    if vim.api.nvim_call_function('has', { 'nvim-0.8' }) == 1 then
      if client.server_capabilities.document_formatting then
        vim.api.nvim_create_autocmd("BufWritePre", {
          desc = "Auto format before save",
          pattern = "<buffer>",
          callback = function()
            vim.lsp.buf.format()
          end,
        })
      end
    else
      -- if client.resolved_capabilities.document_formatting then
      --   vim.api.nvim_create_autocmd("BufWritePre", {
      --     desc = "Auto format before save",
      --     pattern = "<buffer>",
      --     callback = function()
      --       vim.lsp.buf.formatting_sync()
      --     end,
      --   })
      -- end
    end
  end,
}
