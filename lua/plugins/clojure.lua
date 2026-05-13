return {
  -- Clojure LSP - Language Intelligence
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.clojure_lsp = {
        root_markers = { "project.clj", "deps.edn", "build.clj", ".git" },
        settings = {
          clojureLsp = {
            -- Enable additional features
            cljfmtConfigPath = ".cljfmt.edn",
            linters = {
              "clj-kondo",
            },
            -- Better completion and hover
            asyncAutocomplete = true,
          },
        },
      }
      return opts
    end,
  },

  -- Mason auto-install for clojure-lsp
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "clojure-lsp" },
    },
  },

  -- Conjure - Interactive REPL evaluation
  {
    "Olical/conjure",
    ft = { "clojure", "clojurescript", "scheme" },
    config = function()
      -- Auto-connect to Socket REPL on startup
      vim.g["conjure#filetype#clojure"] = "conjure.client.clojure.socket"

      -- Keybindings for REPL interaction
      local opts = { noremap = true, silent = true }

      -- Evaluate form (Alt+Enter - matches F# convention)
      vim.keymap.set("n", "<M-Return>", ":ConjureEvalCurrentForm<CR>", opts)
      -- Evaluate selection (Alt+Enter in visual mode)
      vim.keymap.set("x", "<M-Return>", ":ConjureEvalSelection<CR>", opts)
      -- Evaluate buffer
      vim.keymap.set("n", "<localleader>eb", ":ConjureEvalBuffer<CR>", opts)
      -- View logs
      vim.keymap.set("n", "<localleader>el", ":ConjureEvalLog<CR>", opts)
    end,
  },

  -- Parinfer-rust for structure-aware editing
  {
    "eraserhd/parinfer-rust",
    build = "cargo build --release",
    ft = { "clojure", "scheme", "lisp" },
    config = function()
      vim.g.parinfer_mode = "smart"
    end,
  },

  -- Treesitter for Clojure
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "clojure", "scheme" })
      return opts
    end,
  },

  -- Optional: vim-sexp for s-expression manipulation
  {
    "guns/vim-sexp",
    ft = { "clojure", "scheme", "lisp" },
    config = function()
      -- Keybindings for s-expression manipulation
      local opts = { noremap = true, silent = true }

      -- Wrap element
      vim.keymap.set("n", "<localleader>sw", ":SexpWrap<CR>", opts)
      -- Move forward/backward
      vim.keymap.set("n", "<M-l>", ":SexpMoveToNext<CR>", opts)
      vim.keymap.set("n", "<M-h>", ":SexpMoveToPrev<CR>", opts)
    end,
  },

  -- cmp-conjure for completions from REPL
  {
    "PaterJason/cmp-conjure",
    ft = { "clojure", "scheme" },
  },
}
