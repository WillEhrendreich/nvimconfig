return {

  "neovim/nvim-lspconfig",

  ---@type lspconfig.options
  servers = {
    -- Ensure mason installs the server
    clangd = {
      cmd = {
        -- "C:/ProgramData/chocolatey/bin/cpp.exe",
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--query-driver=" .. os.getenv("CC"),
        "--cross-file-rename",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
        -- "--header-insertion=never",
        "--suggest-missing-includes",
        "-j=4", -- number of workers
        -- -- "--resource-dir="
        -- "--driver-mode=cl",
        "--log=error",
        -- --[[ "--query-driver=/usr/bin/g++", ]]
      },
      keys = {
        { "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
      },
      root_dir = function(...)
        -- using a root .clang-format or .clang-tidy file messes up projects, so remove them
        return require("lspconfig.util").root_pattern(
          "compile_commands.json",
          "compile_flags.txt",
          "configure.ac",
          ".git"
        )(...)
      end,
      capabilities = {
        offsetEncoding = { "utf-16" },
      },
      init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
      },
    }, -- you can do any additional lsp server setup here
    -- return true if you don't want this server to be setup with lspconfig
    ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
    setup = {
      clangd = function(_, opts)
        local clangd_ext_opts = require("lazyvim.util").opts("clangd_extensions.nvim")
        require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts }))
        return true
      end,
      -- ionide and fsautocomplete settings are in ionide.lua now
    },
  },
  -- },
}
