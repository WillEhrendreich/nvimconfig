-- local fn = vim.fn
local vim = vim
vim.api.nvim_create_user_command("CodeiumLogClear", function()
  vim.fn.writefile({}, vim.fn.stdpath("cache") .. "/codeium.log")
end, { desc = "View CodeiumLog" })

vim.api.nvim_create_user_command("CodeiumLog", function()
  local logpath = vim.fn.stdpath("cache") .. "/codeium.log"
  vim.cmd.e(logpath)
end, { desc = "View CodeiumLog" })
local utils = require("config.util")
vim.api.nvim_create_user_command("CodeiumCmpSourceHealthy", function()
  local sources = require("cmp").core.sources
  local cdm = vim.tbl_filter(function(t)
    return t.name == "codeium"
  end, require("cmp").core.sources)[1]
  if cdm then
    if cdm.source.server.is_healthy() then
      vim.notify("Codeium cmp source server is healthy")
    else
      vim.notify("Codeium cmp source server is not healthy")
    end
  else
    vim.notify("Codeium cmp source server is not healthy")
  end
  -- vim.cmd.e(logpath)
end, { desc = "check for current Codeium cmp source server health" })

return {
  -- {
  --   "jcdickinson/http.nvim",  --   build = "cargo build --workspace --release",
  -- },
  {
    -- "jcdickinson/codeium.nvim",
    "willehrendreich/codeium.nvim",
    dev = utils.hasReposEnvironmentVarSet(),
    dir = utils.getRepoWithName("codeium.nvim"),
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = true,
    -- function()

    -- require("codeium").setup({})
    -- end,
  },
  -- Install-Module -Name Get-GzipContent
  -- {
  --   -- "jcdickinson/codeium.nvim",
  --   dev = true,
  --   dir = os.getenv("repos") .. "/codeium.nvim/",
  --   opts = {
  --     manager_path = nil,
  --     bin_path = vim.fn.stdpath("cache") .. "/codeium/bin",
  --     config_path = uim.fn.stdpath("cache") .. "/codeium/config.json",
  --     api = {
  --       host = "server.codeium.com",
  --       port = "443",
  --     },
  --     tools = {
  --       -- uname = "uname",
  --       -- genuuid = "genuuid",
  --     },
  --     wrapper = nil,
  --   },
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "hrsh7th/nvim-cmp",
  --   },
  --   -- config = true,
  --   config = true,
  -- },
}
