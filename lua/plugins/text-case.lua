return {
  "johmsalas/text-case.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("textcase").setup({})
    require("telescope").load_extension("textcase")
  end,
  -- keys = {
  --   "<leader>", -- Default invocation prefix
  --   { "ga.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "x" }, desc = "Telescope" },
  -- },
  opts = {
    -- Set `default_keymappings_enabled` to false if you don't want automatic keymappings to be registered.
    default_keymappings_enabled = false,
    -- `prefix` is only considered if `default_keymappings_enabled` is true. It configures the prefix
    -- of the keymappings, e.g. `gau ` executes the `current_word` method with `to_upper_case`
    -- and `gaou` executes the `operator` method with `to_upper_case`.
    -- prefix = "ga",
    -- If `substitude_command_name` is not nil, an additional command with the passed in name
    -- will be created that does the same thing as "Subs" does.
    substitude_command_name = nil,
    -- By default, all methods are enabled. If you set this option with some methods omitted,
    -- these methods will not be registered in the default keymappings. The methods will still
    -- be accessible when calling the exact lua function e.g.:
    -- "<CMD>lua require('textcase').current_word('to_snake_case')<CR>"
    enabled_methods = {
      "to_upper_case",
      "to_lower_case",
      "to_snake_case",
      "to_dash_case",
      "to_title_dash_case",
      "to_constant_case",
      "to_dot_case",
      "to_phrase_case",
      "to_camel_case",
      "to_pascal_case",
      "to_title_case",
      "to_path_case",
      "to_upper_phrase_case",
      "to_lower_phrase_case",
    },
  },
  cmd = {
    -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
    "Subs",
    "TextCaseOpenTelescope",
    "TextCaseOpenTelescopeQuickChange",
    "TextCaseOpenTelescopeLSPChange",
    "TextCaseStartReplacingCommand",
  },
  -- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
  -- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
  -- available after the first executing of it or after a keymap of text-case.nvim has been used.
  lazy = false,
}
