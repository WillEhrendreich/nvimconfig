return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  opts = {
    textobjects = {
      swap = {
        enable = true,
        swap_next = {
          ["<leader><leader>l"] = { "@parameter.inner", "@parameter.fsharp" },
        },
        swap_previous = {
          ["<leader><leader>h"] = "@parameter.inner",
        },
      },
    },
  },
}
