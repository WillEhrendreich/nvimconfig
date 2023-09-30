local result = {
  {
    "ecthelionvi/NeoComposer.nvim",
    lazy = false,
    -- config = function(opts)
    --   -- local store = require("NeoComposer.store")
    --
    --   -- vim.notify(vim.inspect(store))
    --   require("NeoComposer").setup(opts)
    -- end,
    dependencies = {
      "kkharji/sqlite.lua",
    },
    opts = {
      keymaps = {
        -- play_macro = "Q",
        -- yank_macro = "yq",
        -- stop_macro = "cq",
        -- toggle_record = "q",
        -- cycle_next = "<leader>mn",
        -- cycle_prev = "<leader>mp",
        -- toggle_macro_menu = "<leader>mm",
      },
    },
    -- opts = {
    --   notify = true,
    --   delay_timer = "150",
    --   status_bg = "#16161e",
    --   preview_fg = "#ff9e64",
    --   keymaps = {
    --     play_macro = "Q",
    --     yank_macro = "yq",
    --     stop_macro = "cq",
    --     toggle_record = "q",
    --     cycle_next = "<c-n>",
    --     cycle_prev = "<c-p>",
    --     toggle_macro_menu = "<m-q>",
    --   },
    -- },
  },
  --
  -- vim.g["sqlite_clib_path"] = "C:/ProgramData/chocolatey/lib/SQLite/tools/sqlite3.dll"
  -- return {
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
}

-- require("telescope").load_extension("macros")
return result
