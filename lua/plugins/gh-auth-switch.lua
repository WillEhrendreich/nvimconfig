local util = require("config.util")

local r = {
  "WillEhrendreich/gh-auth-switch",
  opts = {
    dirs = {
      -- ["C:/Code/repos/Ionide-nvim/"] = "WillEhrendreich",
      -- ["C:/Code/repos/gh-auth-switch"] = "WillEhrendreich",
    },
  },
  dependencies = {},
}

if util.hasRepoWithName("gh-auth-switch") then
  r.dev = util.hasRepoWithName("gh-auth-switch")
  r.dir = util.getRepoWithName("gh-auth-switch")
end
return r
