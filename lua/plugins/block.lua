---@class blockNvimOptions
---@field percent number  -- The change in color. 0.8 would change each box to be 20% darker than the last and 1.2 would be 20% brighter.
---@field depth number -- De depths of changing colors. Defaults to 4. After this the colors reset. Note that the first color is taken from your "Normal" highlight so a 4 is 3 new colors.
---@field automatic boolean -- Automatically turns this on when treesitter finds a parser for the current file.
---@field colors string [] | nil -- A list of colors to use instead. If this is set percent and depth are not taken into account.
---@field bg string? -- If you'd prefer to use a different color other than the default "Normal" highlight.

return {
  -- {
  --   "HampusHauffman/block.nvim",
  --   config = function()
  --     require("block").setup(
  --       ---@type blockNvimOptions
  --       {
  --         percent = 0.8,
  --         depth = 4,
  --         -- colors = nil,
  --         auotmatic = true,
  --         -- bg = "",
  --       }
  --     )
  --   end,
  -- },
}
