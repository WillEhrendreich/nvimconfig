return {
  "AlessandroYorba/Alduin",
  "whatyouhide/vim-gotham",
  "morhetz/gruvbox",
  "AstroNvim/astrotheme",
  "sainnhe/everforest",
  "rebelot/kanagawa.nvim",
  "echasnovski/mini.base16",
  {
    "EdenEast/nightfox.nvim",

    opts = {
      dim_inactive = true,
      styles = { comments = "italic" },
      module_default = false,
      modules = {
        aerial = true,
        cmp = true,
        ["dap-ui"] = true,
        diagnostic = true,
        gitsigns = true,
        hop = true,
        native_lsp = true,
        neotree = true,
        notify = true,
        telescope = true,
        treesitter = true,
        tsrainbow = true,
        whichkey = true,
      },
      groups = { all = { NormalFloat = { link = "Normal" } } },
    },
  },
  "nyoom-engineering/oxocarbon.nvim",
  "rose-pine/neovim",
  {
    "folke/tokyonight.nvim",
    opts = {
      -- transparent = true,
      -- styles = {
      --   sidebars = "transparent",
      --   floats = "transparent",
      -- },
    },
  },
}
