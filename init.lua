-- bootstrap lazy.nvim, LazyVim and your plugins
if vim.g.vscode then
else
end

if vim.g.neovide then
  vim.keymap.set({ "n", "x", "c", "i" }, "<F11>", function()
    if vim.g.neovide_fullscreen == true then
      vim.g.neovide_fullscreen = false
    else
      vim.g.neovide_fullscreen = true
    end
  end, { desc = "toggle fullscreen" })

  vim.g.transparency = 0.3
  vim.o.guifont = "JetBrains Mono NF:h17"

  vim.g.neovide_transparency = 0.5
  -- vim.g.neovide_background_color = "#0f1117" .. alpha()
  vim.g.neovide_floating_blur_amount_x = 22.0
  vim.g.neovide_floating_blur_amount_y = 20.0

  vim.g.neovide_scroll_animation_length = 0.3
  vim.g.neovide_theme = "auto"
  vim.g.neovide_refresh_rate = 60.0
  vim.g.neovide_refresh_rate_idle = 5.0
  vim.g.neovide_remember_window_size = true
  --
  vim.g.neovide_cursor_animation_length = 0.13
  --
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_cursor_animate_command_line = true
  --- vim redraw
  vim.cmd.redraw()
end
local debugCodeium = os.getenv("DEBUG_CODEIUM")
if debugCodeium and debugCodeium ~= "warn" and debugCodeium ~= "info" then
  vim.opt.cmdheight = 0
else
  vim.opt.cmdheight = 1
end
require("config.lazy")
