-- sagefs.nvim — Jupyter-notebook-like F# development
-- Uses the same dev-plugin pattern as Ionide-nvim
local util = require("config/util")

local spec = {
  "WillEhrendreich/sagefs.nvim",
  ft = { "fsharp" },
  opts = {
    port = tonumber(vim.env.SAGEFS_MCP_PORT) or 37749,
    auto_connect = true,
  },
}

if util.hasRepoWithName("sagefs.nvim") then
  spec.dev = true
  spec.dir = util.getRepoWithNameOrDefault("sagefs.nvim", "")
end

return { spec }
