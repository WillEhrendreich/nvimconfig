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
    nnoremap <silent> <C-ScrollWheelUp> :set guifont=+<CR>
    nnoremap <silent> <C-ScrollWheelDown> :set guifont=-<CR>
    nnoremap <A-CR> :FVimToggleFullScreen<CR>    
  FVimCursorSmoothMove v:true
  FVimCursorSmoothBlink v:true
  " FVimUIWildMenu 
    " FVimUIPopupMenu v:false
    " FVimUIWildMenu v:false      " external wildmenu -- work in progress
else

      set guifont=Jetbrains\ Mono\ NF
      set guifont=+
      set guifont=+
endif
