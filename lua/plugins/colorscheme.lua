return {
  -- "AlessandroYorba/Alduin",
  -- "whatyouhide/vim-gotham",
  -- "morhetz/gruvbox",
  "ellisonleao/gruvbox.nvim",
  -- "AstroNvim/astrotheme",
  -- "sainnhe/everforest",
  {
    "rebelot/kanagawa.nvim",
    opts = {
      compile = false, -- enable compiling the colorscheme
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = true, -- do not set background color
      dimInactive = false, -- dim inactive window `:h hl-NormalNC`
      terminalColors = true, -- define vim.g.terminal_color_{0,17}
      colors = { -- add/modify theme and palette colors
        palette = {},
        theme = {
          wave = {},
          lotus = {},
          dragon = {},
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
      -- overrides = function(colors) -- add/modify highlights
      --   return {}
      -- end,
      overrides = function(colors)
        local theme = colors.theme
        return {
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          FloatTitle = { bg = "none" },

          -- Save an hlgroup with dark background and dimmed foreground
          -- so that you can use it where your still want darker windows.
          -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
          NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

          -- Popular plugins that open floats will link to NormalFloat by default;
          -- set their background accordingly if you wish to keep them dark and borderless
          LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
        }
      end,
      theme = "wave", -- Load "wave" theme when 'background' option is not set
      background = { -- map the value of 'background' option to a theme
        dark = "wave", -- try "dragon" !
        -- dark = "dragon", -- try "dragon" !
        light = "lotus",
      },
    },
  },
  -- "echasnovski/mini.base16",
  -- {
  --   "EdenEast/nightfox.nvim",
  --
  --   opts = {
  --     dim_inactive = true,
  --     styles = { comments = "italic" },
  --     module_default = false,
  --     modules = {
  --       aerial = true,
  --       cmp = true,
  --       ["dap-ui"] = true,
  --       diagnostic = true,
  --       gitsigns = true,
  --       hop = true,
  --       native_lsp = true,
  --       neotree = true,
  --       notify = true,
  --       telescope = true,
  --       treesitter = true,
  --       tsrainbow = true,
  --       whichkey = true,
  --     },
  --     groups = { all = { NormalFloat = { link = "Normal" } } },
  --   },
  -- },
  -- "nyoom-engineering/oxocarbon.nvim",
  -- "rose-pine/neovim",
  {
    "folke/tokyonight.nvim",
    -- enabled = false,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa",
    },
  },
}
