return {
  -- "williamboman/mason.nvim",
  -- Mason is pinned to version 1 for now: https://github.com/LazyVim/LazyVim/issues/6039
  "mason-org/mason.nvim",
  version = "^1.0.0",
  cmd = "Mason",
  build = ":MasonUpdate",
  keys = { { "<leader>pm", "<cmd>Mason<cr>", desc = "Mason" } },
  opts_extend = { "ensure_installed" },
  opts = {
    registries = {
      "github:mason-org/mason-registry",
      "github:crashdummyy/mason-registry",
    },

    ui = {
      icons = {
        package_installed = "✓",
        package_uninstalled = "✗",
        package_pending = "⟳",
      },
    },
    ensure_installed = {
      "lemminx",
      "texlab",
      "roslyn",
      "rzls",
      -- "html-lsp",
      -- "csharp-language-server",
      -- "sqlls",
      "stylua",
      "fantomas",
      -- "shfmt",
      -- "flake8",
      "ols",
    },
  },
}
