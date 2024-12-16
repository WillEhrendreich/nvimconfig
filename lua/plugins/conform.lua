return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      -- cs = { "csharpier" },
      ["markdown"] = { "prettier", "markdown-toc" },
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
      -- csharpier = {
      --   command = "dotnet-csharpier",
      --   args = { "--write-stdout" },
      -- },
    },
  },
}
