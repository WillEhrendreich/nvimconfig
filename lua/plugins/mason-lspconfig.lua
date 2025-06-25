return {
  -- "williamboman/mason-lspconfig.nvim",

  "mason-org/mason-lspconfig.nvim",
  dependencies = {
    "mason-org/mason.nvim",
  },
  opts = {
    automatic_installation = { exclude = { "markdownlint-cli2" } },
  },
}
