local utils = require("config.util")
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
-- vim.notify("tree-sitter-fsharp Non Repo")
parser_config.fsharp = {
  install_info = {
    url = "https://github.com/ionide/tree-sitter-fsharp",
    branch = "main",
    files = { "src/scanner.c", "src/parser.c" },
    location = "fsharp",
  },
  requires_generate_from_grammar = false,
  filetype = "fsharp",
}

if utils.hasRepoWithName("tree-sitter-odin") then
  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
  parser_config.odin = {
    install_info = {
      branch = "main",
      url = utils.getRepoWithNameOrDefault("tree-sitter-odin", "https://github.com/ap29600/tree-sitter-odin"),
      files = { "src/parser.c" },
    },
    filetype = "odin",
  }
else
  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
  parser_config.odin = {
    install_info = {
      branch = "main",
      url = "https://github.com/ap29600/tree-sitter-odin",
      files = { "src/parser.c" },
    },
    filetype = "odin",
  }
end

if utils.hasRepoWithName("tree-sitter-jsonc") then
  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
  parser_config.jsonc = {
    install_info = {
      branch = "main",
      url = utils.getRepoWithNameOrDefault("tree-sitter-jsonc", "https://gitlab.com/WhyNotHugo/tree-sitter-jsonc.git"),
      files = { "src/parser.c" },
    },
    filetype = "json",
  }
else
  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
  parser_config.jsonc = {
    install_info = {
      branch = "main",
      url = "https://gitlab.com/WhyNotHugo/tree-sitter-jsonc.git",
      files = { "src/parser.c" },
    },
    filetype = "json",
  }
end

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.razor = {
  install_info = {
    -- url = '~/code/tree-sitter-razor', -- local path or git repo
    url = "https://github.com/tris203/tree-sitter-razor",
    files = { "src/parser.c", "src/scanner.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
    -- optional entries:
    branch = "main", -- default branch in case of git repo if different from master
    generate_requires_npm = false, -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
  },
  filetype = "razor", -- if filetype does not match the parser name
}

-- if utils.hasRepoWithName("tree-sitter-razor") then
--   local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
--   parser_config.razor = {
--     install_info = {
--       url = utils.getRepoWithNameOrDefault("tree-sitter-razor", "https://github.com/moreiraio/tree-sitter-razor"),
--       -- files = { "src/scanner.c", "src/parser.c" },
--       files = { "src/parser.c" },
--     },
--     filetype = "razor",
--   }
-- else
--   local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
--   parser_config.razor = {
--     install_info = {
--       url = "https://github.com/moreiraio/tree-sitter-razor",
--       branch = "main",
--       files = { "src/parser.c" },
--       -- generate_requires_npm = true,
--       -- requires_generate_from_grammar = true,
--     },
--     filetype = "razor",
--   }
-- end
require("nvim-treesitter.install").prefer_git = true
return {

  "nvim-treesitter/nvim-treesitter",
  version = false, -- last release is way too old and doesn't work on Windows
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  keys = {
    { "<space>vi", desc = "Increment selection", mode = "x" },
    { "<bs>", desc = "Decrement selection", mode = "x" },
  },
  opts = {
    auto_install = true,
    highlight = {
      enable = true,
      -- Disable slow treesitter highlight for large files
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
        -- if lang == "fsharp" then
        --   return true
        -- end
        -- if lang == "odin" then
        --   return true
        -- end
      end,

      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      -- additional_vim_regex_highlighting = { "odin" },
      additional_vim_regex_highlighting = { "fsharp" },
    },

    indent = { enable = true, disable = { "python", "odin" } },
    context_commentstring = { enable = true, disable = { "fsharp", "odin" }, enable_autocmd = true },
    ensure_installed = {
      "c",
      "fsharp",
      "c_sharp",
      "html",
      "javascript",
      "json",
      "jsonc",
      "lua",
      "luap",
      "markdown",
      "odin",
      "markdown_inline",
      "query",
      "regex",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    },
    -- query_linter = {
    --    enable = true,
    --    use_virtual_text = true,
    --    lint_events = { "BufWrite", "CursorHold" },
    --  },
    compilers = { "clang", "zig", "gcc", "llvm", "cc" },
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
