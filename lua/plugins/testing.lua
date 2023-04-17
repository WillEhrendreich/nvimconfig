-- local path = require("plenary.path")
return {
  -- {
  --   "echasnovski/mini.test",
  --   config = function()
  --     require("mini.test").setup({})
  --   end,
  --   version = false,
  -- },
  {

    "nvim-neotest/neotest",

    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "WillEhrendreich/neotest-dotnet",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-plenary",
      -- "nvim-neotest/neotest-vim-test",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-dotnet")({}),
          -- re "neotest-python" {
          --   dap = { justMyCode = false },
          -- },
          require("neotest-plenary"),
          -- require("neotest-vim-test")({
          --   ignore_file_types = { "python", "vim", "lua", "fsharp", "csharp", "cs" },
          -- }),
        },
      })
    end,
  },
}
