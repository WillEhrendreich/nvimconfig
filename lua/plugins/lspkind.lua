return {
  {
    "onsails/lspkind.nvim",
    config = function()
      require("lspkind").init({
        mode = "symbol",
        symbol_map = {
          Text = "",
          Method = "",
          Function = "",
          Constructor = "",
          Field = "",
          Variable = "",
          Class = "ﴯ",
          Interface = "",
          Module = "",
          Property = "ﰠ",
          Value = "",
          Enum = "",
          Keyword = "",
          Color = "",
          File = "",
          Reference = "",
          Folder = "",
          EnumMember = "",
          Constant = "",
          Struct = "",
          Event = "",
          Operator = "",
          Array = "",
          Codeium = "",
          Boolean = "⊨",
          Key = "",
          Namespace = "",
          Null = "NULL",
          Number = "#",
          Object = "",
          Package = "",
          Snippet = "",
          String = "",
          TypeParameter = "",
          Unit = "",
        },
      })
    end,
    -- enabled = vim.g.icons_enabled,
    -- config = true,
    -- config = require "plugins.configs.lspkind",
  },
}
