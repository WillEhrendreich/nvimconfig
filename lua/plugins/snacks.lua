---@class snacks.animate.Config
---@field easing? snacks.animate.easing|snacks.animate.easing.Fn
---
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    -- your animate configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    animate = {
      ---@type snacks.animate.Duration|number
      duration = { total = 50 }, -- ms per step
      easing = "linear",
      -- easing = "inCirc",
      -- fps = 144, -- frames per second. Global setting for all animations
      fps = 30, -- frames per second. Global setting for all animations
    },
    image = {},
  },
}
