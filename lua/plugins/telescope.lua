-- require("telescope").load_extension("macros")

vim.g["sqlite_clib_path"] = "C:/ProgramData/chocolatey/lib/SQLite/tools/sqlite3.dll"
return {
  "nvim-telescope/telescope.nvim",

  keys = {

    -- disable the keymap to grep files

    { "<leader>/", false },

    { "<leader><leader>", false },

    -- change a keymap

    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },

    {
      "<leader>fq",
      "<cmd>Telescope macros<cr>",
      desc = "Find macros",
    },
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
  --   macros = {},
  -- },
  dependencies = {
    -- {
    -- "nvim-telescope/telescope-fzf-native.nvim",
    -- build = "make",
    -- config = function()
    --   if vim.fn.executable("fzf") then
    --
    --   require("telescope").load_extension("fzf")
    --   end
    -- end,
    -- },
    -- "ecthelionvi/NeoComposer.nvim",
  },

  config = function(opts)
    -- require("telescope").load_extension("macros")
    require("telescope").setup(opts)

    -- local store = require("NeoComposer.store")
    --
    -- vim.notify(vim.inspect(store))
  end,
}
