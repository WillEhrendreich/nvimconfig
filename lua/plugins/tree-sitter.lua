local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
-- parser_config.fsharp = {
--   install_info = {
--     url = "https://github.com/Nsidorenco/tree-sitter-fsharp",
--     branch = "develop",
--     files = { "src/scanner.cc", "src/parser.c" },
--     generate_requires_npm = true,
--     requires_generate_from_grammar = true,
--   },
--   filetype = "fsharp",
-- }
local utils = require("config.util")

if utils.hasRepoWithName("tree-sitter-fsharp") then
  parser_config.fsharp = {
    install_info = {
      url = utils.getRepoWithNameOrDefault("tree-sitter-fsharp", "https://github.com/ionide/tree-sitter-fsharp"),
      files = { "src/scanner.c", "src/parser.c" },
    },
    filetype = "fsharp",
  }
else
  parser_config.fsharp = {
    install_info = {
      url = "https://github.com/ionide/tree-sitter-fsharp",
      branch = "main",
      files = { "src/scanner.c", "src/parser.c" },
      -- generate_requires_npm = true,
      -- requires_generate_from_grammar = true,
    },
    filetype = "fsharp",
  }
end

if utils.hasRepoWithName("tree-sitter-odin") then
  parser_config.odin = {
    install_info = {
      branch = "main",
      url = utils.getRepoWithNameOrDefault("tree-sitter-odin", "https://github.com/ap29600/tree-sitter-odin"),
      files = { "src/parser.c" },
    },
    filetype = "odin",
  }
else
  parser_config.odin = {
    install_info = {
      branch = "main",
      url = "https://github.com/ap29600/tree-sitter-odin",
      files = { "src/parser.c" },
    },
    filetype = "odin",
  }
end

return {

  "nvim-treesitter/nvim-treesitter",
  version = false, -- last release is way too old and doesn't work on Windows
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "LiadOz/nvim-dap-repl-highlights",

    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      -- init = function()
      --   -- PERF: no need to load the plugin, if we only need its queries for mini.ai
      --   local plugin = require("lazy.core.config").spec.plugins["nvim-treesitter"]
      --   local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      --   local enabled = false
      --   if opts.textobjects then
      --     for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
      --       if opts.textobjects[mod] and opts.textobjects[mod].enable then
      --         enabled = true
      --         break
      --       end
      --     end
      --   end
      --   if not enabled then
      --     require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
      --   end
      -- end,
    },
  },
  keys = {
    { "<space>vi", desc = "Increment selection", mode = "x" },
    { "<bs>", desc = "Decrement selection", mode = "x" },
  },
  opts = {
    auto_install = true,
    -- highlight = { enable = true, disable = { "fsharp" } },
    highlight = {
      enable = true,
      -- Disable slow treesitter highlight for large files
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
        if lang == "fsharp" then
          return true
        end
        -- if lang == "odin" then
        --   return true
        -- end
      end,

      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      -- additional_vim_regex_highlighting = { "odin" },
    },

    indent = { enable = true, disable = { "python", "odin" } },
    context_commentstring = { enable = true, disable = { "fsharp", "odin" }, enable_autocmd = true },
    -- context_commentstring = { enable = true, disable = { "odin" }, enable_autocmd = false },
    ensure_installed = {
      -- "bash",
      "c",
      "cpp",
      "fsharp",
      "c_sharp",
      "html",
      "dap_repl",
      "javascript",
      "json",
      -- "jsonc",
      "lua",
      -- "luap",
      "markdown",
      "ocaml",
      "odin",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "tsx",
      "typescript",
      "vim",
      "yaml",
    },
    -- query_linter = {
    --    enable = true,
    --    use_virtual_text = true,
    --    lint_events = { "BufWrite", "CursorHold" },
    --  },
    compilers = { "zig", "clang", "gcc", "llvm", "cc" },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<space>v",
        node_incremental = "<space>vi",
        scope_incremental = "<nop>",
        node_decremental = "<bs>",
      },
    },
  },
}
