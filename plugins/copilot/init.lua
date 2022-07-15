-- local status_ok, copilot = pcall(require, "copilot")
-- if not status_ok then
--   return {}
-- end
return  {
config = function () require("user.plugins.copilot.config")end,
}

