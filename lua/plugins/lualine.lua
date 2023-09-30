return {

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local Util = require("lazyvim.util")
      -- local colors = {
      --   [""] = Util.fg("Special"),
      --   ["Normal"] = Util.fg("Special"),
      --   ["Warning"] = Util.fg("DiagnosticError"),
      --   ["InProgress"] = Util.fg("DiagnosticWarn"),
      -- }

      if require("lazyvim.util").has("NeoComposer.nvim") then
        table.insert(opts.sections.lualine_c, 2, {
          require("NeoComposer.ui").status_recording,
        })
      end
      if require("lazyvim.util").has("overseer.nvim") then
        table.insert(opts.sections.lualine_x, 2, { "overseer" })
      end
    end,
  },
}
-- table.insert(opts.sections.lualine_x, 2, {
--   function()
--     local icon = require("lazyvim.config").icons.kinds.Copilot
--     local status = require("copilot.api").status.data
--     return icon .. (status.message or "")
--   end,
--   cond = function()
--     local clients = vim.lsp.get_active_clients({ name = "copilot", bufnr = 0 })
--     return #clients > 0
--   end,
--   color = function()
--     local status = require("copilot.api").status.data
--     return colors[status.status] or colors[""]
--   end,
-- })
