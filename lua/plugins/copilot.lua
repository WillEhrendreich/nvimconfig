local LazyVimUtil = require("lazyvim.util")
return {
  "zbirenbaum/copilot.lua",
  opts = function(_, opts)
    if LazyVimUtil.has("copilot.lua") then
      local api = require("copilot.api")
      -- vim.notify(vim.inspect(require("copilot.api")))
      api.handlers["copilot/openURL"] = function(_, result)
        vim.notify("Custom copilot handler called: \n" .. vim.inspect({ _, result }))
      end
    end
    return opts
  end,
}
