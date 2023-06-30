return {
  "williamboman/mason.nvim",
  cmd = "Mason",
  keys = { { "<leader>pm", "<cmd>Mason<cr>", desc = "Mason" } },
  opts = {

    ui = {
      icons = {
        package_installed = "✓",
        package_uninstalled = "✗",
        package_pending = "⟳",
      },
    },
    ensure_installed = {
      "fsautocomplete",
      "lemminx",
      "sqlls",
      "stylua",
      "shfmt",
      "flake8",
      "ols",
    },
  },
}
