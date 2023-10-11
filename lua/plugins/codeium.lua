-- local fn = vim.fn
local logpath = vim.fs.normalize(vim.fn.stdpath("cache")) .. "/codeium/codeium.log"
local vim = vim
vim.api.nvim_create_user_command("CodeiumLogClear", function()
  vim.fn.writefile({}, logpath)
end, { desc = "View CodeiumLog" })

vim.api.nvim_create_user_command("CodeiumLog", function()
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
end, { desc = "check for current Codeium cmp source server health" })

-- return {
--   -- {
--   --   "jcdickinson/http.nvim",  --   build = "cargo build --workspace --release",
--   -- },
--   -- {
--   --   -- "jcdickinson/codeium.nvim",
--   --   -- "willehrendreich/codeium.nvim",
--   "Exafunction/codeium.nvim",
--   --   dev = utils.hasReposEnvironmentVarSet(),
--   --   dir = utils.getRepoWithName("codeium.nvim"),
--   --   dependencies = {
--   --     "nvim-lua/plenary.nvim",
--   --     "hrsh7th/nvim-cmp",
--   --   },
--
--   build = "",
--   opts = {
--
--     tools = {
--       -- uname = "uname",
--       genuuid = "guidgen",
--       uuidgen = "guidgen",
--     },
--   },
--   -- config = true,
--   --
--   -- function()
--
--   -- require("codeium").setup({})
--   -- end,
--   -- },
--   -- Install-Module -Name Get-GzipContent
--   -- {
--   --   -- "jcdickinson/codeium.nvim",
--   --   dev = true,
--   --   dir = os.getenv("repos") .. "/codeium.nvim/",
--   --   opts = {
--   --     manager_path = nil,
--   --     bin_path = vim.fn.stdpath("cache") .. "/codeium/bin",
--   --     config_path = uim.fn.stdpath("cache") .. "/codeium/config.json",
--   --     api = {
--   --       host = "server.codeium.com",
--   --       port = "443",
--   --     },
--   --     tools = {
--   --       -- uname = "uname",
--   --       -- genuuid = "genuuid",
--   --     },
--   --     wrapper = nil,
--   --   },
--   --   dependencies = {
--   --     "nvim-lua/plenary.nvim",
--   --     "hrsh7th/nvim-cmp",
--   --   },
--   --   -- config = true,
--   --   config = true,
--   -- },
return {

  -- codeium cmp source
  {
    "nvim-cmp",
    dependencies = {
      -- codeium
      {
        -- "Exafunction/codeium.nvim",
        "willehrendreich/codeium.nvim",
        cmd = "Codeium",
        dev = utils.hasReposEnvironmentVarSet(),
        dir = utils.getRepoWithName("codeium.nvim"),
        dependencies = {
          "nvim-lua/plenary.nvim",
          "hrsh7th/nvim-cmp",
        },

        build = ":Codeium Auth",
        opts = {},
      },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "codeium",
        group_index = 1,
        priority = 100,
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      local started = false
      local function status()
        if not package.loaded["cmp"] then
          return
        end
        for _, s in ipairs(require("cmp").core.sources) do
          if s.name == "codeium" then
            if s.source:is_available() then
              started = true
            else
              return started and "error" or nil
            end
            if s.status == s.SourceStatus.FETCHING then
              return "pending"
            end
            return "ok"
          end
        end
      end

      local Util = require("lazyvim.util")
      local colors = {
        ok = Util.fg("Special"),
        error = Util.fg("DiagnosticError"),
        pending = Util.fg("DiagnosticWarn"),
      }
      table.insert(opts.sections.lualine_x, 2, {
        function()
          local stat = status()
          -- for _, s in ipairs(require("cmp").core.sources) do
          --   if s.name == "codeium" then
          --     stat = s.SourceStatus.
          --   end
          -- end
          return require("lazyvim.config").icons.kinds.Codeium .. vim.inspect(stat)
        end,
        cond = function()
          return status() ~= nil
        end,
        color = function()
          return colors[status()] or colors.ok
        end,
      })
    end,
  },
}

-- }
