local util = require("config/util")

local spec = {
  "WillEhrendreich/datastar.nvim",
  ft = "html",
  opts = {},
}

if util.hasRepoWithName("datastar.nvim") then
  spec.dev = true
  spec.dir = util.getRepoWithNameOrDefault("datastar.nvim", "")
end

return { spec }
