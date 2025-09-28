-- local path = require("plenary.path")
return {
  -- {
  --   "nvim-mini/mini.test",
  --   config = function()
  --     require("mini.test").setup({})
  --   end,
  --   version = false,
  -- },
  {

    "nvim-neotest/neotest",

    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "WillEhrendreich/neotest-dotnet",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-plenary",
      "nvim-neotest/neotest-vim-test",
    },
    config = function(_, opts)
      -- get neotest namespace (api call creates or returns namespace)
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)
      local group = vim.api.nvim_create_augroup("lazyvim_neotest_close_with_q", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = {
          "neotest-output",
        },
        callback = function(event)
          vim.bo[event.buf].buflisted = false
          vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
        end,
      })
      -- overseer.nvim
      opts.consumers = {
        overseer = require("neotest.consumers.overseer"),
      }
      opts.overseer = {
        enabled = true,
        force_default = true,
      }
      require("neotest").setup(opts)
    end,
  },
}
