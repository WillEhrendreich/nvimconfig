local util = require("config.util")

local r = {
  "WillEhrendreich/gh-auth-switch.nvim",
  opts = {
    dirs = {
      ["C:/Code/repos/Ionide-nvim/"] = "WillEhrendreich",
      ["C:/Code/repos/gh-auth-switch"] = "WillEhrendreich",
      ["C:/Code/repos/source"] = "EHRWI_RTI",
      ["C:/Code/repos/edi-api/"] = "EHRWI_RTI",
      ["C:/Code/repos/edi-web-tools/"] = "EHRWI_RTI",
      ["C:/Code/repos/customer/"] = "EHRWI_RTI",
    },
  },
  dependencies = {},
}

if util.hasRepoWithName("gh-auth-switch") then
  r.dev = util.hasRepoWithName("gh-auth-switch")
  r.dir = util.getRepoWithName("gh-auth-switch")
end
return r
