return {

  {
    "lewis6991/gitsigns.nvim",
    enabled = vim.fn.executable("git") == 1,
    ft = "gitcommit",
    opts = {
      signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
    },
  },
}
