if exists('g:fvim_loaded')
  " good old 'set guifont' compatibility with HiDPI hints...
    if g:fvim_os == 'windows' || g:fvim_render_scale > 1.0
      " set guifont=Jetbrains\ Mono\ NF:h14
      set guifont=Jetbrains\ Mono\ NF
      set guifont=+
      set guifont=+
      set guifont=+
    else
      " set guifont=Jetbrains\ Mono\ NF:h28
      set guifont=+
      set guifont=+
      set guifont=+
      set guifont=Jetbrains\ Mono\ NF
      set guifont=+
      set guifont=+
      set guifont=+
    endif
      
    " Ctrl-ScrollWheel for zooming in/out
    nnoremap <A-CR> :FVimToggleFullScreen<CR>    
  FVimCursorSmoothMove v:true
  FVimCursorSmoothBlink v:true
  " FVimUIWildMenu 
    " FVimUIPopupMenu v:false
    " FVimUIWildMenu v:false      " external wildmenu -- work in progress
elseif exists("g:neovide")
    " Put anything you want to happen only in Neovide here
    "
    

      set guifont=Jetbrains\ Mono\ NF
" g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
  " let g:neovide_transparency = 0.0


  else

    " nnoremap <A-CR> :FVimToggleFullScreen<CR>    
      set guifont=Jetbrains\ Mono\ NF
      " set guifont=+
      " set guifont=+
endif

    " nnoremap <silent> <C-ScrollWheelUp> :set guifont=+<CR>
    " nnoremap <silent> <C-ScrollWheelDown> :set guifont=-<CR>
