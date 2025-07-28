local util = require("config.util")
local repo = { "WillEhrendreich/CsvToMdTable", name = "csvToMdTable" }
if util.hasRepoWithName("CsvToMdTable") then
  repo = {
    "WillEhrendreich/CsvToMdTable",
    dir = util.getRepoWithName("CsvToMdTable"),
    name = "csvToMdTable",
  }
end
return repo
