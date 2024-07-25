return {
  {
    "tris203/rzls.nvim",
    opts = {
      ft = { "razor" },
      -- path = "C:/Code/repos/razor/artifacts/bin/rzls/x64/Debug/net8.0",
    },
    -- config = require("rzls").setup,
    -- config = true,
    -- dependencies = {
    --   "neovim/nvim-lspconfig",
    --   servers = {
    --   },
    -- },
  },
  {
    "moreiraio/razor.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",

      -- servers = {
      --   rzls = {},
      -- },
      -- setup = {
      --   rzls = function(_, opts) -- code
      --     require("rzls").setup(opts)
      --   end,
      -- },
    },
  },
}
