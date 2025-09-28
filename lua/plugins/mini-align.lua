return {
  "nvim-mini/mini.align",

  event = "VeryLazy",

  config = function()
    require("mini.align").setup()
  end,
}
