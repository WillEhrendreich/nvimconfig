return {

  { "Tetralux/odin.vim" },
  {
    "neovim/nvim-lspconfig",
    ---@type lspconfig.options
    servers = {
      ---@type lspconfig.options.ols
      ols = {
        cmd = { "C:/.local/share/nvim-data/mason/bin/ols.cmd" },
        root_dir = function(path)
          local lspUtil = require("lspconfig.util")
          local root
          root = lspUtil.root_pattern("ols.json", ".git")(path)
          root = root
            or (function(p)
              return (vim.fs.dirname(p or vim.fn.expand("%:p"))) .. "/"
            end)(path)
          return root
        end,
        settings = {
          odin = {
            completion_support_md = true,
            hover_support_md = true,
            signature_offset_support = true,
            collections = {},
            -- running=true,
            verbose = true,
            enable_format = true,
            enable_hover = true,
            enable_symantic_tokens = true,
            enable_document_symbols = true,
            enable_inlay_hints = true,
            enable_procedure_context = true,
            enable_snippets = true,
            enable_references = true,
            enable_rename = true,
            enable_label_details = true,
            enable_std_references = true,
            enable_import_fixer = true,
            disable_parser_errors = true,
            thread_count = 0,
            file_log = true,
            -- odin_command = "",
            checker_args = "",
          },
        },
        filetypes = { "odin" },
        single_file_support = false,
        autostart = true,
      },
    },
  },
}
