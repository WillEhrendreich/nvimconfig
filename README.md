<a href="https://dotfyle.com/WillEhrendreich/nvimconfig"><img src="https://dotfyle.com/WillEhrendreich/nvimconfig/badges/plugins?style=flat" /></a>
<a href="https://dotfyle.com/WillEhrendreich/nvimconfig"><img src="https://dotfyle.com/WillEhrendreich/nvimconfig/badges/leaderkey?style=flat" />(space)</a>
<a href="https://dotfyle.com/WillEhrendreich/nvimconfig"><img src="https://dotfyle.com/WillEhrendreich/nvimconfig/badges/plugin-manager?style=flat" /></a>

## Install Instructions

Install requires Neovim 0.10+. Always review the code before installing a configuration.
It is required to have a C compiler for treesitter to work properly.
I recommend the Zig one, it's fantastic.
If you don't have it in your path, and don't have it as the CC environment variable, it will not work to install treesitter grammars at all.
clang also works, but it's not as good.

It's recommend heavily to not install nvim itself with anything but [BOB](https://github.com/MordechaiHadad/bob).
This is a fantastic tool that makes it very easy to install and update Neovim, and it's what I use.

Incredibly important is this: this configuration is heavily reliant on having Chocolatey installed.
In fact, I have a super secret plugin of my own invention that handles chocolatey installations, but you have to have it installed first.
Choco.nvim is the name of the plugin, and it's not available aside from in this configuration.
It uses the packages.config file in the root of the repository to install packages.

If you're using powershell, you can install chocolatey with the initChocoScript.ps1 script, if I've done it right,
but if that doesn't work for you go to the [chocolatey website](https://docs.chocolatey.org/en-us/choco/setup) and follow the instructions there.

You can set environment variables on windows by opening the start menu and searching for edit environment variables.![editEnvironmentVariables](https://github.com/WillEhrendreich/nvimconfig/assets/55286472/bb26e542-79a1-4d70-8e5e-83f4b5e7d921)


I recommend setting the following user environment variables:

XDG_CONFIG_HOME to c:/.config
XDG_DATA_HOME to c:/.local/share
XDG_STATE_HOME to c:/.local/state
NVIM_APPNAME to nvim

REPOS to c:/repos or whatever you want to use as your repository directory.
(this is because of checks that are occurring in the configuration for if there are local repos of specific plugins: see [./lua/config/util.lua](https://github.com/WillEhrendreich/nvimconfig/blob/master/lua/config/util.lua) )

Clone the repository and install the plugins:

```pwsh
git clone git@github.com:WillEhrendreich/nvimconfig c:/.config/nvim
nvim --headless +"Lazy! sync" +qa
```

Also, take a look at this great video guide to having multiple nvim configurations: [Elijah Manor - Neovim Config Switcher](https://www.youtube.com/watch?v=LkHjJlSgKZY)
I've implemented a similar system in this my [pwsh profile](https://github.com/WillEhrendreich/pwshProfile), and it's fantastic.

## Plugins

### bars-and-lines

- [luukvbaal/statuscol.nvim](https://dotfyle.com/plugins/luukvbaal/statuscol.nvim)

### code-runner

- [stevearc/overseer.nvim](https://dotfyle.com/plugins/stevearc/overseer.nvim)
- [Civitasv/cmake-tools.nvim](https://dotfyle.com/plugins/Civitasv/cmake-tools.nvim)

### colorscheme

- [sainnhe/everforest](https://dotfyle.com/plugins/sainnhe/everforest)
- [folke/tokyonight.nvim](https://dotfyle.com/plugins/folke/tokyonight.nvim)
- [nyoom-engineering/oxocarbon.nvim](https://dotfyle.com/plugins/nyoom-engineering/oxocarbon.nvim)
- [rebelot/kanagawa.nvim](https://dotfyle.com/plugins/rebelot/kanagawa.nvim)
- [rose-pine/neovim](https://dotfyle.com/plugins/rose-pine/neovim)
- [EdenEast/nightfox.nvim](https://dotfyle.com/plugins/EdenEast/nightfox.nvim)

### colorscheme-creation

- [echasnovski/mini.base16](https://dotfyle.com/plugins/echasnovski/mini.base16)

### completion

- [hrsh7th/nvim-cmp](https://dotfyle.com/plugins/hrsh7th/nvim-cmp)

### debugging

- [Weissle/persistent-breakpoints.nvim](https://dotfyle.com/plugins/Weissle/persistent-breakpoints.nvim)
- [rcarriga/nvim-dap-ui](https://dotfyle.com/plugins/rcarriga/nvim-dap-ui)
- [mfussenegger/nvim-dap](https://dotfyle.com/plugins/mfussenegger/nvim-dap)

### diagnostics

- [folke/trouble.nvim](https://dotfyle.com/plugins/folke/trouble.nvim)

### editing-support

- [tomiis4/hypersonic.nvim](https://dotfyle.com/plugins/tomiis4/hypersonic.nvim)
- [bennypowers/splitjoin.nvim](https://dotfyle.com/plugins/bennypowers/splitjoin.nvim)
- [echasnovski/mini.pairs](https://dotfyle.com/plugins/echasnovski/mini.pairs)
- [haringsrob/nvim_context_vt](https://dotfyle.com/plugins/haringsrob/nvim_context_vt)

### file-explorer

- [nvim-neo-tree/neo-tree.nvim](https://dotfyle.com/plugins/nvim-neo-tree/neo-tree.nvim)
- [echasnovski/mini.files](https://dotfyle.com/plugins/echasnovski/mini.files)

### formatting

- [echasnovski/mini.align](https://dotfyle.com/plugins/echasnovski/mini.align)

### fuzzy-finder

- [nvim-telescope/telescope.nvim](https://dotfyle.com/plugins/nvim-telescope/telescope.nvim)

### git

- [lewis6991/gitsigns.nvim](https://dotfyle.com/plugins/lewis6991/gitsigns.nvim)

### keybinding

- [anuvyklack/hydra.nvim](https://dotfyle.com/plugins/anuvyklack/hydra.nvim)
- [folke/which-key.nvim](https://dotfyle.com/plugins/folke/which-key.nvim)

### lsp

- [simrat39/symbols-outline.nvim](https://dotfyle.com/plugins/simrat39/symbols-outline.nvim)
- [onsails/lspkind.nvim](https://dotfyle.com/plugins/onsails/lspkind.nvim)
- [nvimtools/none-ls.nvim](https://dotfyle.com/plugins/jose-elias-alvarez/null-ls.nvim)
- [neovim/nvim-lspconfig](https://dotfyle.com/plugins/neovim/nvim-lspconfig)
- [jose-elias-alvarez/typescript.nvim](https://dotfyle.com/plugins/jose-elias-alvarez/typescript.nvim)

### lsp-installer

- [williamboman/mason.nvim](https://dotfyle.com/plugins/williamboman/mason.nvim)

### lua-colorscheme

- [ellisonleao/gruvbox.nvim](https://dotfyle.com/plugins/ellisonleao/gruvbox.nvim)

### nvim-dev

- [kkharji/sqlite.lua](https://dotfyle.com/plugins/kkharji/sqlite.lua)
- [MunifTanjim/nui.nvim](https://dotfyle.com/plugins/MunifTanjim/nui.nvim)
- [nvim-lua/plenary.nvim](https://dotfyle.com/plugins/nvim-lua/plenary.nvim)
- [echasnovski/mini.test](https://dotfyle.com/plugins/echasnovski/mini.test)
- [bfredl/nvim-luadev](https://dotfyle.com/plugins/bfredl/nvim-luadev)

### plugin-manager

- [folke/lazy.nvim](https://dotfyle.com/plugins/folke/lazy.nvim)

### preconfigured

- [LazyVim/LazyVim](https://dotfyle.com/plugins/LazyVim/LazyVim)

### snippet

- [L3MON4D3/LuaSnip](https://dotfyle.com/plugins/L3MON4D3/LuaSnip)

### startup

- [goolord/alpha-nvim](https://dotfyle.com/plugins/goolord/alpha-nvim)
- [echasnovski/mini.starter](https://dotfyle.com/plugins/echasnovski/mini.starter)

### statusline

- [nvim-lualine/lualine.nvim](https://dotfyle.com/plugins/nvim-lualine/lualine.nvim)

### syntax

- [nvim-treesitter/nvim-treesitter-textobjects](https://dotfyle.com/plugins/nvim-treesitter/nvim-treesitter-textobjects)
- [nvim-treesitter/nvim-treesitter](https://dotfyle.com/plugins/nvim-treesitter/nvim-treesitter)

### tabline

- [akinsho/bufferline.nvim](https://dotfyle.com/plugins/akinsho/bufferline.nvim)

### terminal-integration

- [m00qek/baleia.nvim](https://dotfyle.com/plugins/m00qek/baleia.nvim)
- [willothy/flatten.nvim](https://dotfyle.com/plugins/willothy/flatten.nvim)

### test

- [nvim-neotest/neotest](https://dotfyle.com/plugins/nvim-neotest/neotest)

### utility

- [ecthelionvi/NeoComposer.nvim](https://dotfyle.com/plugins/ecthelionvi/NeoComposer.nvim)
- [folke/noice.nvim](https://dotfyle.com/plugins/folke/noice.nvim)
- [rcarriga/nvim-notify](https://dotfyle.com/plugins/rcarriga/nvim-notify)
- [nguyenvukhang/nvim-toggler](https://dotfyle.com/plugins/nguyenvukhang/nvim-toggler)
- [stevearc/dressing.nvim](https://dotfyle.com/plugins/stevearc/dressing.nvim)
- [kevinhwang91/nvim-ufo](https://dotfyle.com/plugins/kevinhwang91/nvim-ufo)

## Language Servers

- clangd
- [Ionide-Nvim](https://github.com/WillEhrendreich/Ionide-nvim)
- html
- jsonls
- lemminx
- lua_ls
- ols
- omnisharp
- sqlls

This readme was generated by [Dotfyle](https://dotfyle.com)
