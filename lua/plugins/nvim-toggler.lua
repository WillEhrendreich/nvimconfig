return {

  "nguyenvukhang/nvim-toggler",
  config = function()
    require("nvim-toggler").setup({
      inverses = {
        ["bad"] = "good",
        ["horizontal"] = "vertical",
        ["Horizontal"] = "Vertical",
        ["before"] = "after",
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
        ["IsSome"] = "IsNone",
        ["start"] = "stop",
        ["Start"] = "Stop",
        ["Ok"] = "Error",
        ["public"] = "private",
        ["/"] = "\\",
      },
      remove_default_keybinds = true,
    })
  end,
}
