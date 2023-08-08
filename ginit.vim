" if exists('g:fvim_loaded')
  " good old 'set guifont' compatibility with HiDPI hints...
    " if g:fvim_os == 'windows' || g:fvim_render_scale > 1.0
    "   " set guifont=Jetbrains\ Mono\ NF:h14
    "   " set guifont=+
    "   " set guifont=+
    "   " set guifont=+
    "   " set guifont=JetBrainsMono\ Nerd\ Font:h15
    "   set guifont=Caskaydia\ Cove\ Nerd\ Font\ Complete\ Mono:h14
    " else
    "   " " set guifont=Jetbrains\ Mono\ NF:h28
    "   " set guifont=+
    "   " set guifont=+
    "   " set guifont=+
    "   " " set guifont=JetBrainsMono\ Nerd\ Font:h15
    "   " set guifont=Iosevka\ NF:h14
    " endif
      
      " set guifont=CaskaydiaCove\ Nerd\ Font\ Mono\ Book:h14
    " Ctrl-ScrollWheel for zooming in/out
    " nnoremap <A-CR> :FVimToggleFullScreen<CR>    
  " FVimCursorSmoothMove v:true
  " FVimCursorSmoothBlink v:true
" Toggle between normal and fullscreen
" FVimToggleFullScreen

" Cursor tweaks
" FVimCursorSmoothMove v:true
" FVimCursorSmoothBlink v:true

" Background composition
" FVimBackgroundComposition 'none'   " 'none', 'transparent', 'blur' or 'acrylic'
" FVimBackgroundOpacity 0.15            " value between 0 and 1, default bg opacity.
" FVimBackgroundAltOpacity 0.15         " value between 0 and 1, non-default bg opacity.
" FVimBackgroundImage 'C:/foobar.png'   " background image
" FVimBackgroundImageVAlign 'center'    " vertial position, 'top', 'center' or 'bottom'
" FVimBackgroundImageHAlign 'center'    " horizontal position, 'left', 'center' or 'right'
" FVimBackgroundImageStretch 'fill'     " 'none', 'fill', 'uniform', 'uniformfill'
" FVimBackgroundImageOpacity 0.15       " value between 0 and 1, bg image opacity

" Title bar tweaks
" FVimCustomTitleBar v:true             " themed with colorscheme

" Debug UI overlay
" FVimDrawFPS v:true

" Font tweaks
" FVimFontAntialias v:true
" FVimFontAutohint v:true
" FVimFontHintLevel 'full'
" FVimFontLigature v:false
" FVimFontLineHeight '+1.0' " can be 'default', '14.0', '-1.0' etc.
" FVimFontSubpixel v:true
" FVimFontNoBuiltinSymbols v:false " Disable built-in Nerd font symbols

" Try to snap the fonts to the pixels, reduces blur
" in some situations (e.g. 100% DPI).
" FVimFontAutoSnap v:true

" Font weight tuning, possible valuaes are 100..900
" FVimFontNormalWeight 400
" FVimFontBoldWeight 700

" Font debugging -- draw bounds around each glyph
" FVimFontDrawBounds v:true

" UI options (all default to v:false)
" FVimUIPopupMenu v:true      " external popup menu
" FVimUIWildMenu v:true      " external wildmenu -- work in progress

" Keyboard mapping options
" FVimKeyDisableShiftSpace v:true " disable unsupported sequence <S-Space>
" FVimKeyAutoIme v:true           " Automatic input method engagement in Insert mode
" FVimKeyAltGr v:true             " Recognize AltGr. Side effect is that <C-A-Key> is then impossible

" Default options (workspace-agnostic)
" FVimDefaultWindowWidth 1600     " Default window size in a new workspace
" FVimDefaultWindowHeight 900

" Detach from a remote session without killing the server
" If this command is executed on a standalone instance,
" the embedded process will be terminated anyway.
" FVimDetach

" =========== BREAKING CHANGES -- the following commands are disabled ============
" FVimUIMultiGrid v:true     -- per-window grid system -- done and enabled by default
" FVimUITabLine v:false      -- external tabline -- not implemented
" FVimUICmdLine v:false      -- external cmdline -- not implemented
" FVimUIMessages v:false     -- external messages -- not implemented
" FVimUITermColors v:false   -- not implemented
" FVimUIHlState v:false      -- not implemented
  " FVimUIWildMenu 
    " FVimUIPopupMenu v:false
    " FVimUIWildMenu v:false      " external wildmenu -- work in progress
" elseif exists("g:neovide")
    " Put anything you want to happen only in Neovide here
    "
    

      " set guifont=Jetbrains\ Mono\ NF
      " set guifont=JetBrainsMono\ NF
" g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
  " let g:neovide_transparency = 0.0


  " else

    " nnoremap <A-CR> :FVimToggleFullScreen<CR>    
      " set guifont=Jetbrains\ Mono\ NF
      " set guifont=JetBrainsMono\ NF
      " set guifont=+
      " set guifont=+
" endif

    " nnoremap <silent> <C-ScrollWheelUp> :set guifont=+<CR>
    " nnoremap <silent> <C-ScrollWheelDown> :set guifont=-<CR>
