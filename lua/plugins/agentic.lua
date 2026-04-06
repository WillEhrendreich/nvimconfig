-- GitHub Copilot CLI as ACP provider via agentic.nvim
-- Copilot CLI speaks standard ACP protocol over stdio via copilot.exe --acp --stdio
-- Since agentic.nvim doesn't have a built-in Copilot adapter, we patch
-- agent_instance to fall back to the base ACPClient for unknown providers.

local copilot_exe = vim.fn.expand(
  "~/AppData/Roaming/npm/node_modules/@github/copilot/node_modules/@github/copilot-win32-x64/copilot.exe"
)

return {
  "carlos-algms/agentic.nvim",
  event = "VeryLazy",
  opts = {
    provider = "copilot-acp",
    acp_providers = {
      ["copilot-acp"] = {
        name = "GitHub Copilot",
        command = copilot_exe,
        args = { "--acp", "--stdio" },
        env = {},
      },
    },
  },
  config = function(_, opts)
    require("agentic").setup(opts)

    -- Patch agent_instance to support Copilot (unknown provider) using base ACPClient
    local AgentInstance = require("agentic.acp.agent_instance")
    local original_get_instance = AgentInstance.get_instance

    AgentInstance.get_instance = function(provider_name, on_ready)
      local ok, result = pcall(original_get_instance, provider_name, on_ready)
      if ok then
        return result
      end

      -- If the original errored (unsupported provider), use base ACPClient
      local Config = require("agentic.config")
      local config = Config.acp_providers[provider_name]
      if not config then
        error("No ACP provider configuration found for: " .. provider_name)
      end

      local ACPClient = require("agentic.acp.acp_client")
      local client = ACPClient:new(config, on_ready)
      AgentInstance._instances[provider_name] = client
      return client
    end
  end,
  keys = {
    { "<leader>aa", "<cmd>AgenticToggle<cr>", desc = "Toggle Agentic (Copilot)" },
    { "<leader>as", "<cmd>AgenticSwitchProvider<cr>", desc = "Switch ACP Provider" },
  },
}
