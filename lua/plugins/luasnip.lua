local util = require("config.util")
return {
  "L3MON4D3/LuaSnip",
  dependencies = {
    "rafamadriz/friendly-snippets",
    dev = util.hasRepoWithName("friendly-snippets"),
    dir = util.getRepoWithName("friendly-snippets"),
  },
}
