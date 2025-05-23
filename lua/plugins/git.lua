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

  {
    "ldelossa/gh.nvim",
    dependencies = {
      {
        "ldelossa/litee.nvim",
        event = "VeryLazy",
        opts = {
          -- icons={}
          -- notify = { enabled = false },
          notify = { enabled = true },
          panel = {
            orientation = "left",
            panel_size = 30,
          },
        },
        config = function(_, opts)
          require("litee.lib").setup(opts)
        end,
      },

      {
        "ldelossa/litee-calltree.nvim",
        dependencies = "ldelossa/litee.nvim",
        event = "VeryLazy",
        opts = {
          on_open = "panel",
          map_resize_keys = false,
        },
        config = function(_, opts)
          require("litee.calltree").setup(opts)
        end,
      },
    },
    config = function()
      require("litee.gh").setup()
    end,
  },
}
