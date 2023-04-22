local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.fsharp = {
  install_info = {
    url = "https://github.com/Nsidorenco/tree-sitter-fsharp",
    branch = "develop",
    files = { "src/scanner.cc", "src/parser.c" },
  },
  filetype = "fsharp",
}
parser_config.odin = {
  install_info = {
    branch = "main",
    url = os.getenv("repos") .. "/tree-sitter-odin",
    files = { "src/parser.c" },
  },
  filetype = "odin",
}
return {

  "nvim-treesitter/nvim-treesitter",
  version = false, -- last release is way too old and doesn't work on Windows
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      init = function()
        -- PERF: no need to load the plugin, if we only need its queries for mini.ai
        local plugin = require("lazy.core.config").spec.plugins["nvim-treesitter"]
        local opts = require("lazy.core.plugin").values(plugin, "opts", false)
        local enabled = false
        if opts.textobjects then
          for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
            if opts.textobjects[mod] and opts.textobjects[mod].enable then
              enabled = true
              break
            end
          end
        end
        if not enabled then
          require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
        end
      end,
    },
  },
  -- { "nvim-treesitter/playground" },
  keys = {
    { "<space>vi", desc = "Increment selection", mode = "x" },
    { "<bs>", desc = "Decrement selection", mode = "x" },
  },
  opts = {
    -- highlight = { enable = true, disable = { "fsharp" } },
    highlight = { enable = true },
    indent = { enable = true, disable = { "python", "odin" } },
    -- indent = { enable = true, disable = { "fsharp", "python", "odin" } },
    -- context_commentstring = { enable = true, enable_autocmd = true },
    context_commentstring = { enable = true, disable = { "fsharp", "odin" }, enable_autocmd = true },
    -- context_commentstring = { enable = true, disable = { "odin" }, enable_autocmd = false },
    ensure_installed = {
      "bash",
      "c",
      "fsharp",
      "help",
      "html",
      "javascript",
      "json",
      "jsonc",
      "lua",
      "luap",
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
    -- playground = {
    --   enable = true,
    --   disable = {},
    --   updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    --   persist_queries = false, -- Whether the query persists across vim sessions
    --   keybindings = {
    --     toggle_query_editor = "o",
    --     toggle_hl_groups = "i",
    --     toggle_injected_languages = "t",
    --     toggle_anonymous_nodes = "a",
    --     toggle_language_display = "I",
    --     focus_language = "f",
    --     unfocus_language = "F",
    --     update = "R",
    --     goto_node = "<cr>",
    --     show_help = "?",
    --   },
    -- },
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = { "BufWrite", "CursorHold" },
    },
    compilers = { "gcc", "llvm", "clang", "cc" },
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
