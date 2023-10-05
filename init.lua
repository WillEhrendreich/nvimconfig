-- bootstrap lazy.nvim, LazyVim and your plugins
if vim.g.vscode then
else
  if vim.g.fvim_loaded then
    vim.o.guifont = "Iosevka NF:h17"
    -- vim.o.guifont = "JetBrainsMono NF:h14"
    vim.keymap.set(
      { "n", "x", "c", "i" },
      "<F11>",
      ":FVimToggleFullScreen <CR>",
      { desc = "toggle fullscreen", silent = true }
    )

    -- Cursor tweaks
    vim.cmd([[ FVimCursorSmoothMove v:true ]])

    --Background composition
    vim.cmd([[ FVimCursorSmoothBlink v:true ]])

    vim.cmd([[ FVimBackgroundComposition 'blur']]) -- 'none', 'transparent', 'blur' or 'acrylic'
    vim.cmd([[ FVimBackgroundOpacity 0.25 ]]) -- value between 0 and 1, default bg opacity.

    --  vim.cmd([[ FVimBackgroundAltOpacity 0.25        ]]) -- value between 0 and 1, non-default bg opacity.
    --  vim.cmd([[ FVimBackgroundImage 'C:/foobar.png'  ]]) -- background image
    --  vim.cmd([[ FVimBackgroundImageVAlign 'center'   ]]) -- vertial position, 'top', 'center' or 'bottom'
    --  vim.cmd([[ FVimBackgroundImageHAlign 'center'   ]]) -- horizontal position, 'left', 'center' or 'right'
    --  vim.cmd([[ FVimBackgroundImageStretch 'fill'    ]]) -- 'none', 'fill', 'uniform', 'uniformfill'
    --  vim.cmd([[ FVimBackgroundImageOpacity 0.01      ]]) -- value between 0 and 1, bg image opacity

    -- Title bar tweaks
    vim.cmd([[ FVimCustomTitleBar v:true ]]) -- themed with colorscheme

    -- Debug UI overlay
    -- vim.cmd([[ FVimDrawFPS v:true ]])

    -- Font tweaks
    vim.cmd([[ FVimFontAntialias v:true ]])
    vim.cmd([[ FVimFontAutohint v:true ]])
    vim.cmd([[ FVimFontHintLevel 'full' ]])
    vim.cmd([[ FVimFontLigature v:true ]])
    -- can be 'default', '14.0', '-1.0' etc.
    -- vim.cmd([[ FVimFontLineHeight '+1.0' ]])
    vim.cmd([[ FVimFontSubpixel v:true ]])
    -- Disable built-in Nerd font symbols
    vim.cmd([[ FVimFontNoBuiltinSymbols v:true ]])

    -- Try to snap the fonts to the pixels, reduces blur
    -- in some situations (e.g. 100% DPI).
    vim.cmd([[ FVimFontAutoSnap v:true ]])

    -- Font weight tuning, possible valuaes are 100..900
    vim.cmd([[ FVimFontNormalWeight 400 ]])

    vim.cmd([[ FVimFontBoldWeight 700 ]])

    -- Font debugging -- draw bounds around each glyph
    -- vim.cmd([[ FVimFontDrawBounds v:true ]])

    -- UI options (all default to v:false)
    -- external popup menu
    vim.cmd([[ FVimUIPopupMenu v:true ]])
    -- external wildmenu -- work in progress "
    vim.cmd([[ FVimUIWildMenu v:false ]])

    -- Keyboard mapping options
    -- disable unsupported sequence <S-Space>
    vim.cmd([[  FVimKeyDisableShiftSpace v:true ]])
    -- Automatic input method engagement in Insert mode
    vim.cmd([[  FVimKeyAutoIme v:true ]])
    -- Recognize AltGr. Side effect is that <C-A-Key> is then impossible
    vim.cmd([[  FVimKeyAltGr v:true ]])

    -- Default options (workspace-agnostic)
    -- Default window size in a new workspace
    -- vim.cmd([[ FVimDefaultWindowWidth 1600]])
    -- vim.cmd([[ FVimDefaultWindowHeight 900]])

    -- Detach from a remote session without killing the server
    -- If this command is executed on a standalone instance,
    -- the embedded process will be terminated anyway.
    --  vim.cmd([[ FVimDetach ]])
  end
  if vim.g.neovide then
    vim.keymap.set({ "n", "x", "c", "i" }, "<F11>", function()
      if vim.g.neovide_fullscreen == true then
        vim.g.neovide_fullscreen = false
      else
        vim.g.neovide_fullscreen = true
      end
    end)
    vim.g.transparency = 0.3

    vim.opt.guifont = { "JetBrainsMono NF", "h14" }
    vim.g.neovide_transparency = 0.5
    -- vim.g.neovide_background_color = "#0f1117" .. alpha()
    vim.g.neovide_floating_blur_amount_x = 22.0
    vim.g.neovide_floating_blur_amount_y = 20.0

    vim.g.neovide_scroll_animation_length = 0.3
    vim.g.neovide_theme = "auto"
    vim.g.neovide_refresh_rate = 75.0
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
  local utils = require("config.util")
  local debugCodeium = utils.getEnvVariableOrDefault("DEBUG_CODEIUM", "info")
  if debugCodeium and debugCodeium ~= "warn" and debugCodeium ~= "info" then
    vim.opt.cmdheight = 1
  else
    vim.opt.cmdheight = 0
  end
end
require("config.lazy")
