local util = require("config.util")
return {
  {
    "MoaidHathot/dotnet.nvim",
    dev = util.hasRepoWithName("dotnet.nvim"),
    dir = util.getRepoWithName("dotnet.nvim"),
    cmd = "DotnetUI",
    opts = {},
  },
}
