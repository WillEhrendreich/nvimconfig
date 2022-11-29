require("mason").setup {
  ui = {
    icons = {
      package_installed = "✓",
      package_uninstalled = "✗",
      package_pending = "⟳",
    },
  },
  log_level = vim.log.levels.DEBUG,
}
