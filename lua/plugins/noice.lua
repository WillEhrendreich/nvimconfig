return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    -- add any options here
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("noice").setup({
      routes = {

        {
          filter = {
            event = "notify",
            find = "Checking",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "notify",
            find = "checking",
          },
          opts = { skip = true },
        },
      },
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    })
  end,
}
