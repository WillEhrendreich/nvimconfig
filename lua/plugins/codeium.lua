-- local fn = vim.fn
vim.api.nvim_create_user_command("CodeiumLog", function()
  local logpath = vim.fn.stdpath("cache") .. "/codeium/codeium.log"
  vim.cmd.e(logpath)
end, { desc = "View CodeiumLog" })
-- vim.fn.getenv("DEBUG_CODEIUM")
--

return {
  -- {
  --   "jcdickinson/http.nvim",
  --   build = "cargo build --workspace --release",
  -- },
  {
    "jcdickinson/codeium.nvim",
    dependencies = {
      -- "jcdickinson/http.nvim",
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({})
    end,
  },
  -- {
  --   -- "jcdickinson/codeium.nvim",
  --   "Willehrendreich/codeium.nvim",
  --   dev = true,
  --   dir = os.getenv("repos") .. "/codeium.nvim/",
  --   opts = {
  --     manager_path = nil,
  --     bin_path = vim.fn.stdpath("cache") .. "/codeium/bin",
  --     config_path = vim.fn.stdpath("cache") .. "/codeium/config.json",
  --     api = {
  --       host = "server.codeium.com",
  --       port = "443",
  --     },
  --     tools = {
  --       -- uname = "uname",
  --       -- genuuid = "genuuid",
  --     },
  --     wrapper = nil,
  --   },
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "hrsh7th/nvim-cmp",
  --   },
  --   -- config = true,
  --   config = true,
  -- },
}
