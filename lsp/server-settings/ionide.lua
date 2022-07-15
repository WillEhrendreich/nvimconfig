local getGitRoot = function(filepath)
  local lsp = require 'lspconfig'
  local root = lsp.util.find_git_ancestor(filepath)
  return root
end

vim.cmd [[
  " Required: to be used with nvim-cmp.
  let g:fsharp#lsp_auto_setup = 0
  let g:fsharp#workspace_mode_peek_deep_level = 5 

  " Recommended: show tooptip when you hold cursor over something for 1s.
  if has('nvim') && exists('*nvim_open_win')
    set updatetime=1000
    augroup FSharpShowTooltip
      autocmd!
      autocmd CursorHold *.fs,*.fsi,*.fsx call fsharp#showTooltip()
    augroup END
  endif
]]


return {
 -- capabilities = function()
 --  -- local finalCap 
 --  local lsp = vim.lsp
 --  local caps =  lsp.protocol.make_client_capabilities()
 --
 --    local combined = vim.tbl_deep_extend(  )
 --  return combined
 --  end,
  root_dir = getGitRoot,

}
