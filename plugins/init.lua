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
        opt = true,
        setup = function() table.insert(astronvim.file_plugins, "indent-tools.nvim") end,
        requires = { "arsham/arshlib.nvim", module = "arshlib" },
        config = function() require "user.plugins.indent-tools" end,
    },
    ["danymat/neogen"] = {
        requires = "nvim-treesitter/nvim-treesitter",
        module = "neogen",
        cmd = "Neogen",
        config = function() require "user.plugins.neogen" end,
    },
    ["EdenEast/nightfox.nvim"] = {
        module = "nightfox",
        event = "ColorScheme",
        config = function() require "user.plugins.nightfox" end,
    },
    ["ethanholz/nvim-lastplace"] = {
        opt = true,
        setup = function() table.insert(astronvim.file_plugins, "nvim-lastplace") end,
        config = function() require "user.plugins.nvim-lastplace" end,
    },
    ["hrsh7th/cmp-calc"] = { after = "nvim-cmp", config = function() require "user.plugins.cmp-calc" end },
    ["hrsh7th/cmp-emoji"] = { after = "nvim-cmp", config = function() require "user.plugins.cmp-emoji" end },
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
    ["junegunn/vim-easy-align"] = {
        opt = true,
        setup = function() table.insert(astronvim.file_plugins, "vim-easy-align") end,
    },
    ["kdheepak/cmp-latex-symbols"] = {
        after = "nvim-cmp",
        config = function() require "user.plugins.cmp-latex-symbols" end,
    },
    ["machakann/vim-sandwich"] = {
        opt = true,
        setup = function() table.insert(astronvim.file_plugins, "vim-sandwich") end,
    },
    ["mfussenegger/nvim-dap"] = { opt = true, setup = function() table.insert(astronvim.file_plugins, "nvim-dap") end },
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
        opt = false,
        module = "telescope-file-browser",
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
        opt = true,
        setup = function() table.insert(astronvim.git_plugins, "diffview.nvim") end,
        config = function() require "user.plugins.diffview" end,
    },
    ["theHamsta/nvim-dap-virtual-text"] = {
        after = "nvim-dap",
        config = function() require "user.plugins.nvim-dap-virtual-text" end,
    },
    ["ziontee113/syntax-tree-surfer"] = {
        module = "syntax-tree-surfer",
        config = function() require "user.plugins.syntax-tree-surfer" end,
    },
    ["ahmedkhalf/project.nvim"] = {
        event = "BufRead",
        -- config = function() require "user.plugins.project" end,
    },
    ["WillEhrendreich/ionide-vim"] = {
        after = "mason-lspconfig.nvim",
        commit = "25144fb",

        -- config = {},
        -- config = function()
        -- require("ionide").setup { require "user.lsp.server-settings.ionide" }
        --require("ionide").setup {},
        -- cmd = { "dotnet", "fsautocomplete", "--adaptive-lsp-server-enabled" },
        -- end,
    },
    ["hood/popui.nvim"] = {

        config = function()
            vim.ui.select = require "popui.ui-overrider"
            vim.ui.input = require "popui.input-overrider"
        end,
    },
    ["adelarsq/neofsharp.vim"] = {},
    ["lewis6991/hover.nvim"] = {
        config = function()
            require("hover").setup {
                init = function()
                    -- Require providers
                    require "hover.providers.lsp"
                    -- require('hover.providers.gh')
                    -- require('hover.providers.jira')
                    require "hover.providers.man"
                    -- require('hover.providers.dictionary')
                end,
                preview_opts = {
                    border = nil,
                },
                -- Whether the contents of a currently open hover window should be moved
                -- to a :h preview-window when pressing the hover keymap.
                preview_window = false,
                title = true,
            }

            -- Setup keymaps
            vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
            vim.keymap.set("n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
        end,
    },
    ["nguyenvukhang/nvim-toggler"] = {
        config = function()
            require("nvim-toggler").setup {
                inverses = {
                    ["bad"] = "good",
                },
                remove_default_keybinds = true,
            }
        end,
    },
    ["hrsh7th/cmp-nvim-lua"] = {
        after = "nvim-cmp",
    },
    ["tyru/open-browser.vim"] = {
        commands = function()
            return {
                {
                    desc = "Smart search link/word under cursor",
                    cmd = "<Plug>(openbrowser-smart-search)",
                    keys = {
                        { "n", "gx", { noremap = true } },
                        { "v", "gx", { noremap = true } },
                    },
                },
            }
        end,
    },
    ["AndrewRadev/bufferize.vim"] = {},
    ["kosayoda/nvim-lightbulb"] = {
        requires = "antoinemadec/FixCursorHold.nvim",
        config = function() require("nvim-lightbulb").setup(require "user.plugins.nvim-lightbulb") end,
    },
    ["nvim-neotest/neotest"] = {

        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "WillEhrendreich/neotest-dotnet",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-neotest/neotest-plenary",
            "nvim-neotest/neotest-vim-test",
        },
        config = function()
            require("neotest").setup {
                adapters = {
                    require "neotest-dotnet" {},
                    -- require "neotest-python" {
                    --   dap = { justMyCode = false },
                    -- },
                    require "neotest-plenary",
                    require "neotest-vim-test" {
                        ignore_file_types = { "python", "vim", "lua", "fsharp", "csharp", "cs" },
                    },
                },
            }
        end,
    },
}
