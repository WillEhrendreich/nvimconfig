local util = require("config.util")
local r = {
  {
    "MoaidHathot/dotnet.nvim",
    cmd = "DotnetUI",
    opts = {},
  },
}
if util.hasRepoWithName("dotnet.nvim") then
  r[1].dev = true
  r[1].dir = util.getRepoWithName("dotnet.nvim")
end
return r
