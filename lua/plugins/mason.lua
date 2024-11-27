return {
  "williamboman/mason.nvim",
  cmd = "Mason",
  keys = { { "<leader>pm", "<cmd>Mason<cr>", desc = "Mason" } },
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
