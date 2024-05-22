local util = require("config.util")

return {
  "WillEhrendreich/gh-auth-switch.nvim",
  dev = util.hasRepoWithName("gh-auth-switch"),
  dir = util.getRepoWithName("gh-auth-switch"),
  opts = {
    dirs = {
      ["C:/Code/repos/gh-auth-switch"] = "WillEhrendreich",
      ["C:/Code/repos/source"] = "EHRWI_RTI",
    },
  },
  dependencies = {},
}
