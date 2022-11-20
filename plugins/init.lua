--local fssetup = function() require("mason-lspconfig").fsautocomplete.setup {} end

-- local ionsetup = require "ionide"
return {

  ["folke/neodev.nvim"] = {},
  ["goolord/alpha-nvim"] = { disable = true },
  ["max397574/better-escape.nvim"] = { disable = true },
  ["numToStr/Comment.nvim"] = {},
  -- ["dhruvasagar/vim-table-mode"] = require "user.plugins.vim-table-mode",
  -- ["echasnovski/mini.nvim"] = require "user.plugins.mini",
  -- ["folke/zen-mode.nvim"] = require "user.plugins.zen-mode",
  -- ["jbyuki/nabla.nvim"] = require "user.plugins.nabla",
  -- ["lukas-reineke/headlines.nvim"] = require "user.plugins.headlines",
  -- ["mickael-menu/zk-nvim"] = require "user.plugins.zk",
  -- ["phaazon/hop.nvim"] = require "user.plugins.hop",
  -- ["vitalk/vim-simple-todo"] = require "user.plugins.vim-simple-todo",
  -- ["andweeb/presence.nvim"] = require "user.plugins.presence",
  -- ["akinsho/git-conflict.nvim"] = require "user.plugins.git-conflict",
  -- ["andymass/vim-matchup"] = { after = "nvim-treesitter" },
  ["arsham/indent-tools.nvim"] = {
    requires = "arsham/arshlib.nvim",
    config = function() require "user.plugins.indent-tools" end,
  },
  ["danymat/neogen"] = {
    requires = "nvim-treesitter/nvim-treesitter",
    module = "neogen",
    cmd = "Neogen",
    config = function() require "user.plugins.neogen" end,
  },
  ["EdenEast/nightfox.nvim"] = { config = function() require "user.plugins.nightfox" end },
  ["ethanholz/nvim-lastplace"] = { config = function() require "user.plugins.nvim-lastplace" end },
  ["hrsh7th/cmp-calc"] = { after = "nvim-cmp", config = function() require "user.plugins.cmp-calc" end },
  ["hrsh7th/cmp-emoji"] = { after = "nvim-cmp", config = function() require "user.plugins.cmp-emoji" end },
  ["hrsh7th/cmp-omni"] = { after = "nvim-cmp", config = function() require "user.plugins.cmp-omni" end },
  ["jayp0521/mason-nvim-dap.nvim"] = {
    after = { "mason.nvim", "nvim-dap" },
    config = function() require "user.plugins.mason-nvim-dap" end,
  },
  ["jc-doyle/cmp-pandoc-references"] = {
    after = "nvim-cmp",
    config = function() require "user.plugins.cmp-pandoc-references" end,
  },
  ["jose-elias-alvarez/typescript.nvim"] = {
    after = "mason-lspconfig.nvim",
    config = function() require "user.plugins.typescript" end,
  },
  ["junegunn/vim-easy-align"] = {},
  ["kdheepak/cmp-latex-symbols"] = {
    after = "nvim-cmp",
    config = function() require "user.plugins.cmp-latex-symbols" end,
  },
  ["machakann/vim-sandwich"] = {},
  ["mfussenegger/nvim-dap"] = {},
  ["mtikekar/nvim-send-to-term"] = {
    cmd = "SendHere",
    config = function() require "user.plugins.nvim-send-to-term" end,
  },
  ["mxsdev/nvim-dap-vscode-js"] = {
    after = "mason-nvim-dap.nvim",
    config = function() require "user.plugins.nvim-dap-vscode-js" end,
  },
  ["nanotee/sqls.nvim"] = { module = "sqls" },
  ["nvim-telescope/telescope-bibtex.nvim"] = {
    after = "telescope.nvim",
    config = function() require "user.plugins.telescope-bibtex" end,
  },
  ["nvim-telescope/telescope-file-browser.nvim"] = {
    after = "telescope.nvim",
    config = function() require "user.plugins.telescope-file-browser" end,
  },
  ["nvim-telescope/telescope-hop.nvim"] = {
    after = "telescope.nvim",
    config = function() require "user.plugins.telescope-hop" end,
  },
  ["nvim-telescope/telescope-media-files.nvim"] = {
    after = "telescope.nvim",
    config = function() require "user.plugins.telescope-media-files" end,
  },
  ["nvim-telescope/telescope-project.nvim"] = {
    after = "telescope.nvim",
    config = function() require "user.plugins.telescope-project" end,
  },
  ["nvim-treesitter/nvim-treesitter-textobjects"] = { after = "nvim-treesitter" },
  ["p00f/clangd_extensions.nvim"] = {
    after = "mason-lspconfig.nvim",
    config = function() require "user.plugins.clangd_extensions" end,
  },
  ["rcarriga/nvim-dap-ui"] = { after = "nvim-dap", config = function() require "user.plugins.dapui" end },
  ["sindrets/diffview.nvim"] = {
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    config = function() require "user.plugins.diffview" end,
  },
  ["theHamsta/nvim-dap-virtual-text"] = {
    after = "nvim-dap",
    config = function() require "user.plugins.nvim-dap-virtual-text" end,
  },
  ["ziontee113/syntax-tree-surfer"] = {
    cmd = {
      "STSSwapUpNormal",
      "STSSwapDownNormal",
      "STSSelectCurrentNode",
      "STSSelectMasterNode",
      "STSSelectParentNode",
      "STSSelectChildNode",
      "STSSelectPrevSiblingNode",
      "STSSelectNextSiblingNode",
      "STSSwapNextVisual",
      "STSSwapPrevVisual",
    },
    config = function() require "user.plugins.syntax-tree-surfer" end,
  },
  ["ahmedkhalf/project.nvim"] = {
    event = "BufRead",
    -- config = function() require "user.plugins.project" end,
  },
  ["WillEhrendreich/ionide-vim"] = {
    after = "mason-lspconfig.nvim",
    -- config = {},
    -- config = function()
    -- require("ionide").setup { require "user.lsp.server-settings.ionide" }
    --require("ionide").setup {},
    -- cmd = { "dotnet", "fsautocomplete", "--adaptive-lsp-server-enabled" },
    -- end,
  },
  ["adelarsq/neofsharp.vim"] = {},
}
