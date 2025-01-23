return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      -- cs = { "csharpier" },
      sql = { "sql_formatter" },
      ["*"] = { "injected" }, -- enables injected-lang formatting for all filetypes
      ["markdown"] = { "prettier", "markdown-toc" },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
    formatters = {
      ["markdownlint-cli2"] = {
        -- condition = function(_, ctx)
        --   local diag = vim.tbl_filter(function(d)
        --     return d.source == "markdownlint"
        --   end, vim.diagnostic.get(ctx.buf))
        --   return #diag > 0
        -- end,
        condition = false,
      },
      sql_formatter = {
        command = "sql-formatter",
        args = { "-l", "transactsql" },
      },

      -- sqlfluff = {
      --   args = { "format", "--dialect=tsql", "-" },
      -- },
      -- csharpier = {
      --   command = "dotnet-csharpier",
      --   args = { "--write-stdout" },
      -- },
    },
  },
}
