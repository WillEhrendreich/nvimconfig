return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
      },
      linters = {
        --   ["markdownlint-cli2"] = {
        --     -- args = { "--config", "~/.markdownlint.jsonc", "--" },
        --     args = {},
        -- },
      },
    },
    config = function()
      local markdownlint = require("lint").linters.markdownlint
      markdownlint.args = {
        "--disable",
        "MD013",
        "MD007",
        "--", -- Required
      }
    end,
  },
}
