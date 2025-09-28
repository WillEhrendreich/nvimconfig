return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = {
    "mason-org/mason.nvim",
  },
  opts = {
    automatic_installation = { exclude = { "markdownlint-cli2" } },
    -- automatic_enable = false,

    -- automatic_enable = {
    --   "ionide",
    -- },
    -- ensure_installed = {
    --   "fsautocomplete",
    -- },
  },
}
