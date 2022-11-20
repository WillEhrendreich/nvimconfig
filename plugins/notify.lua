-- local BUILTIN_RENDERERS = {
--   DEFAULT = "default",
--   MINIMAL = "minimal",
-- }
-- local BUILTIN_STAGES = {
--   FADE = "fade",
--   SLIDE = "slide",
--   FADE_IN_SLIDE_OUT = "fade_in_slide_out",
--   STATIC = "static",
-- }
-- local default_config = {
--   level = vim.log.levels.INFO,
--   timeout = 5000,
--   max_width = nil,
--   max_height = nil,
--   stages = BUILTIN_STAGES.FADE_IN_SLIDE_OUT,
--   render = BUILTIN_RENDERERS.DEFAULT,
--   background_colour = "Normal",
--   on_open = nil,
--   on_close = nil,
--   minimum_width = 50,
--   fps = 30,
--   top_down = true,
--   icons = {
--     ERROR = "",
--     WARN = "",
--     INFO = "",
--     DEBUG = "",
--     TRACE = "✎",
--   },
-- }
-- Overriding vim.notify with fancy notify if fancy notify exists

local notify = require "notify"
vim.notify = notify

-- print = function(...)
--   local print_safe_args = {}
--   local _ = { ... }
--   for i = 1, #_ do
--     table.insert(print_safe_args, tostring(_[i]))
--   end
--   notify(table.concat(print_safe_args, " "), "info")
-- end
--
notify.setup()

return {
  timeout = 2000,
  max_width = 500,
  top_down = false,
  fps = 60,
  background_colour = "#000000",
}
