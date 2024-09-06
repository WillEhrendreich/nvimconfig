return {

  "nanotee/sqls.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  config = function(_, opts)
    vim.api.nvim_create_autocmd("User", {
      pattern = "SqlsConnectionChoice",
      callback = function(event)
        vim.notify(event.data.choice)
      end,
    })
  end,
  opts = {},
}
