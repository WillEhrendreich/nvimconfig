return {
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if lang == "fsharp" or ok and stats and stats.size > max_filesize then return true end
    end,
    additional_vim_regex_highlighting = function(lang, _) return lang == "fsharp" end,
  },
  -- highlight = { disable = { "help" } },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  rainbow = {
    enable = true,
    disable = { "html" },
    extended_mode = false,
    max_file_lines = nil,
  },
  autotag = { enable = true },
  incremental_selection = { enable = true },
  -- indent = { enable = false },
  indent = { enable = true, disable = { "python" } },

  auto_install = vim.fn.executable "tree-sitter" == 1,
  ensure_installed = "all",
  matchup = { enable = true },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        aB = "@block.outer",
        iB = "@block.inner",
        aC = "@conditional.outer",
        iC = "@conditional.inner",
        aF = "@function.outer",
        iF = "@function.inner",
        aL = "@loop.outer",
        iL = "@loop.inner",
        aP = "@parameter.outer",
        iP = "@parameter.inner",
        aX = "@class.outer",
        iX = "@class.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]b"] = "@block.outer",
        ["]f"] = "@function.outer",
        ["]p"] = "@parameter.outer",
        ["]x"] = "@class.outer",
      },
      goto_next_end = {
        ["]B"] = "@block.outer",
        ["]F"] = "@function.outer",
        ["]P"] = "@parameter.outer",
        ["]X"] = "@class.outer",
      },
      goto_previous_start = {
        ["[b"] = "@block.outer",
        ["[f"] = "@function.outer",
        ["[p"] = "@parameter.outer",
        ["[x"] = "@class.outer",
      },
      goto_previous_end = {
        ["[B"] = "@block.outer",
        ["[F"] = "@function.outer",
        ["[P"] = "@parameter.outer",
        ["[X"] = "@class.outer",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        [">B"] = "@block.outer",
        [">F"] = "@function.outer",
        [">P"] = "@parameter.inner",
      },
      swap_previous = {
        ["<B"] = "@block.outer",
        ["<F"] = "@function.outer",
        ["<P"] = "@parameter.inner",
      },
    },
    lsp_interop = {
      enable = true,
      border = "single",
      peek_definition_code = {
        ["<leader>lp"] = "@function.outer",
        ["<leader>lP"] = "@class.outer",
      },
    },
  },
}
