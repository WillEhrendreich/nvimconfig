return {
  "WillEhrendreich/NeovimUtils",
  dev = true,
  dir = vim.fn.stdpath("config") .. "/lua/dev/NeovimUtils",
  config = function()
    require("dev.NeovimUtils").setup()
  end,
  commands = { "SystemOpen" },
}
