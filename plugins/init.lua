return {
  ["declancm/cinnamon.nvim"] = { disable = true },
  ["famiu/bufdelete.nvim"] = { disable = true },
  ["goolord/alpha-nvim"] = { disable = true },
  ["lukas-reineke/indent-blankline.nvim"] = { disable = true },
  ["max397574/better-escape.nvim"] = { disable = true },
  ["numToStr/Comment.nvim"] = { disable = true },
  ["EdenEast/nightfox.nvim"] = {
    config = function()
      require("nightfox").setup(require "user.plugins.nightfox")
    end,
  },
  ["noralambda/fsproj-edit.nvim"] =
    { 
      -- config =function() require("fsproj-edit").setup({}) end,
    },
  ["bfredl/nvim-luadev"]= {},
  ["rafcamlet/nvim-luapad"]= {
    after = "antoinemadec/FixCursorHold",
    -- config = function() require("nvim-luapad").setup({}) end,
  },
  ["nvim-telescope/telescope-dap.nvim"] = {

    after = "telescope.nvim",
    -- config = function()
      -- require("telescope").load_extension "dap"
    -- end,
  },
  ["adelarsq/neofsharp.vim"] = {
    -- config = require "neofsharp.vim".setup() end,
  },
  ["danymat/neogen"] = {
    module = "neogen",
    cmd = "Neogen",
    config = function()
      require("neogen").setup(require "user.plugins.neogen")
    end,
    requires = "nvim-treesitter/nvim-treesitter",
  },
  ["dhruvasagar/vim-table-mode"] = {
    cmd = "TableModeToggle",
    config = function()
      vim.g.table_mode_corner = "|"
    end,
  },
  ["echasnovski/mini.nvim"] = {
    event = "VimEnter",
    config = function()
      require "user.plugins.mini" ()
    end,
  },
  ["ethanholz/nvim-lastplace"] = {
    event = "BufRead",
    config = function()
      require("nvim-lastplace").setup(require "user.plugins.nvim-lastplace")
    end,
  },
  ["folke/zen-mode.nvim"] = {
    cmd = "ZenMode",
    module = "zen-mode",
    config = function()
      require("zen-mode").setup(require "user.plugins.zen-mode")
    end,
  },
  ["hrsh7th/cmp-calc"] = {
    after = "nvim-cmp",
    config = function()
      astronvim.add_user_cmp_source "calc"
    end,
  },
  ["hrsh7th/cmp-emoji"] = {
    after = "nvim-cmp",
    config = function()
      astronvim.add_user_cmp_source "emoji"
    end,
  },
  ["jbyuki/nabla.nvim"] = { module = "nabla" },
  ["jc-doyle/cmp-pandoc-references"] = {
    after = "nvim-cmp",
    config = function()
      astronvim.add_user_cmp_source "pandoc_references"
    end,
  },
  ["jose-elias-alvarez/typescript.nvim"] = {
    after = "nvim-lsp-installer",
    config = function()
      require("typescript").setup(require "user.plugins.typescript")
    end,
  },
  ["luisiacc/gruvbox-baby"] = {},
  ["ionide/ionide-vim"] = {
  },
  ["omnisharp/omnisharp-roslyn"] = {
    after = "nvim-lsp-installer",
  },
  ["samsung/netcoredbg"] = {
    --after ="mfussenegger/nvim-dap",
  },
  ["github/copilot.vim"] = {

    event = "InsertEnter"
  },
  ["kdheepak/cmp-latex-symbols"] = {
    after = "nvim-cmp",
    config = function()
      astronvim.add_user_cmp_source "latex_symbols"
    end,
  },
  ["lukas-reineke/headlines.nvim"] = {
    ft = { "markdown", "rmd" },
    config = function()
      require("headlines").setup(require "user.plugins.headlines")
    end,
  },
  ["mfussenegger/nvim-dap"] = {
    module = "dap",
    config = require "user.plugins.dap",
  },
  ["mickael-menu/zk-nvim"] = {
    module = { "zk", "zk.commands" },
    config = function()
      require("zk").setup(require "user.plugins.zk")
    end,
  },
  ["mtikekar/nvim-send-to-term"] = {
    cmd = "SendHere",
    config = function()
      vim.g.send_disable_mapping = true
    end,
  },
  -- ["nanotee/sqls.nvim"] = { module = "sqls" },
  ["phaazon/hop.nvim"] = {
    cmd = { "HopChar1", "HopChar2", "HopLine", "HopPattern", "HopWord" },
    branch = "v1",
    config = function()
      require("hop").setup()
    end,
  },
  ["rcarriga/nvim-dap-ui"] = {
    after = "nvim-dap",
    config = function()
      local dap, dapui = require "dap", require "dapui"
      dapui.setup(require "user.plugins.dapui")
      -- add listeners to auto open DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  ["nvim-treesitter/nvim-treesitter-textobjects"] = { after = "nvim-treesitter" },
  ["nvim-telescope/telescope-bibtex.nvim"] = {
    after = "telescope.nvim",
    config = function()
      require("telescope").load_extension "bibtex"
    end,
  },
  ["nvim-telescope/telescope-file-browser.nvim"] = {
    after = "telescope.nvim",
    config = function()
      require("telescope").load_extension "file_browser"
    end,
  },
  ["nvim-telescope/telescope-hop.nvim"] = {
    after = "telescope.nvim",
    config = function()
      require("telescope").load_extension "hop"
    end,
  },
  ["nvim-telescope/telescope-media-files.nvim"] = {
    after = "telescope.nvim",
    config = function()
      require("telescope").load_extension "media_files"
    end,
  },
  ["nvim-telescope/telescope-project.nvim"] = {
    after = "telescope.nvim",
    config = function()
      require("telescope").load_extension "project"
    end,
  },
  ["p00f/clangd_extensions.nvim"] = {
    after = "nvim-lsp-installer",
    config = function()
      require("clangd_extensions").setup(require "user.plugins.clangd_extensions")
    end,
  },

  ["christianchiarulli/nvim-gps"]={
    branch = "text_hl"
  },
  ["nvim-neotest/neotest"] =
    {
      requires = { 
      "nvim-lua/plenary.nvim",
      "nvim-neotest/neotest-plenary",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim"},
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
    config = function()
      require("syntax-tree-surfer").setup(require "user.plugins.syntax-tree-surfer")
    end,
  },
   ["EdenEast/nightfox.nvim"] = require "user.plugins.nightfox",
  ["danymat/neogen"] = require "user.plugins.neogen",
  ["dhruvasagar/vim-table-mode"] = require "user.plugins.vim-table-mode",
  ["echasnovski/mini.nvim"] = require "user.plugins.mini",
  ["ethanholz/nvim-lastplace"] = require "user.plugins.nvim-lastplace",
  ["folke/zen-mode.nvim"] = require "user.plugins.zen-mode",
  ["hrsh7th/cmp-calc"] = require "user.plugins.cmp-calc",
  ["hrsh7th/cmp-emoji"] = require "user.plugins.cmp-emoji",
  ["jbyuki/nabla.nvim"] = require "user.plugins.nabla",
  ["jc-doyle/cmp-pandoc-references"] = require "user.plugins.cmp-pandoc-references",
  ["jose-elias-alvarez/typescript.nvim"] = require "user.plugins.typescript",
  ["kdheepak/cmp-latex-symbols"] = require "user.plugins.cmp-latex-symbols",
  ["lukas-reineke/headlines.nvim"] = require "user.plugins.headlines",
  ["mfussenegger/nvim-dap"] = require "user.plugins.dap",
  ["mickael-menu/zk-nvim"] = require "user.plugins.zk",
  ["mtikekar/nvim-send-to-term"] = require "user.plugins.nvim-send-to-term",
  ["nanotee/sqls.nvim"] = require "user.plugins.sqls",
  ["nvim-telescope/telescope-bibtex.nvim"] = require "user.plugins.telescope-bibtex",
  ["nvim-telescope/telescope-file-browser.nvim"] = require "user.plugins.telescope-file-browser",
  ["nvim-telescope/telescope-hop.nvim"] = require "user.plugins.telescope-hop",
  ["nvim-telescope/telescope-media-files.nvim"] = require "user.plugins.telescope-media-files",
  ["nvim-telescope/telescope-project.nvim"] = require "user.plugins.telescope-project",
  ["nvim-treesitter/nvim-treesitter-textobjects"] = require "user.plugins.nvim-treesitter-textobjects",
  ["p00f/clangd_extensions.nvim"] = require "user.plugins.clangd_extensions",
  ["phaazon/hop.nvim"] = require "user.plugins.hop",
  ["rcarriga/nvim-dap-ui"] = require "user.plugins.dapui",
  ["vitalk/vim-simple-todo"] = require "user.plugins.vim-simple-todo",
  ["wakatime/vim-wakatime"] = require "user.plugins.vim-wakatime",
  ["ziontee113/syntax-tree-surfer"] = require "user.plugins.syntax-tree-surfer", 
}
