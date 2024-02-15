return {

  "nguyenvukhang/nvim-toggler",
  config = function()
    require("nvim-toggler").setup({
      inverses = {
        ["bad"] = "good",
        ["up"] = "down",
        ["left"] = "right",
        ["1"] = "0",
        [">"] = "<",
        [">="] = "<=",
        ["=="] = "!=",
        ["++"] = "--",
        ["+"] = "-",
        ["yes"] = "no",
        ["Some"] = "None",
        ["Ok"] = "Error",
      },
      remove_default_keybinds = true,
    })
  end,
}
