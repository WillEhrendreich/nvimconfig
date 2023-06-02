-- require("telescope").load_extension("macros")
return {
  "nvim-telescope/telescope.nvim",

  keys = {

    -- disable the keymap to grep files

    { "<leader>/", false },

    { "<leader><leader>", false },

    -- change a keymap

    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },

    {
      "<leader>fo",
      function()
        require("telescope.builtin").oldfiles()
      end,
      desc = "Find Recent Files",
    },
    -- add a keymap to browse plugin files
    {
      "<leader>fp",
      function()
        require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
      end,
      desc = "Find Plugin File",
    },
    { "<leader>?", "<cmd>Telescope help_tags<cr>", "Find Help" },
  },

  opts = {
    defaults = {
      layout_strategy = "horizontal",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      winblend = 0,
    },
  },

  -- extensions = {
  --   macros,
  -- },
  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
    -- {
    --   "ecthelionvi/NeoComposer.nvim",
    --   dependencies = {
    --     "kkharji/sqlite.lua",
    --   },
    --   opts = {
    --     notify = true,
    --     delay_timer = "150",
    --     status_bg = "#16161e",
    --     preview_fg = "#ff9e64",
    --     keymaps = {
    --       play_macro = "Q",
    --       yank_macro = "yq",
    --       stop_macro = "cq",
    --       toggle_record = "q",
    --       cycle_next = "<c-n>",
    --       cycle_prev = "<c-p>",
    --       toggle_macro_menu = "<m-q>",
    --     },
    --   },
    -- },
    -- "ecthelionvi/NeoComposer.nvim",
  },

  -- config = function(opts)
  --   require("telescope").setup(opts)
  -- end,
}
