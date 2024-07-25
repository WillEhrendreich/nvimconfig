return {
  "chrisgrieser/nvim-scissors",
  dependencies = { "nvim-telescope/telescope.nvim", "L3MON4D3/LuaSnip" },
  opts = {
    snippetDir = vim.fn.stdpath("config") .. "/snippets/",
  },
}
