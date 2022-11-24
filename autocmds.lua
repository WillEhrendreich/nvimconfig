vim.api.nvim_create_autocmd("VimLeave", {
  desc = "Stop running auto compiler",
  group = vim.api.nvim_create_augroup("autocomp", { clear = true }),
  pattern = "*",
  callback = function() vim.fn.jobstart { "autocomp", vim.fn.expand "%:p", "stop" } end,
})

vim.api.nvim_create_augroup("FsharpProjCommands", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  desc = "changes comment style for fsproj",
  pattern = "*.fsproj",
  group = "FsharpProjCommands",
  callback = function() vim.api.nvim_command "set filetype=xml" end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  desc = "changes comment style, folding for fsproj",
  pattern = "*.fsproj",
  group = "FsharpProjCommands",
  callback = function()
    vim.api.nvim_command "set commentstring=<!--%s-->"
    vim.api.nvim_command "let g:xml_syntax_folding=1"
    vim.api.nvim_command "setlocal foldmethod=syntax"
    vim.api.nvim_command "setlocal foldlevelstart=999  foldminlines=0"
  end,
})
vim.api.nvim_create_augroup("xamlCommands", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  desc = "changes comment style for xaml",
  pattern = "*.xaml",
  group = "xamlCommands",
  callback = function() vim.api.nvim_command "set filetype=xml" end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  desc = "changes comment style, folding for xaml",
  pattern = "*.xaml",
  group = "xamlCommands",
  callback = function()
    vim.api.nvim_command "set commentstring=<!--%s-->"
    vim.api.nvim_command "let g:xml_syntax_folding=1"
    vim.api.nvim_command "setlocal foldmethod=syntax"
    vim.api.nvim_command "setlocal foldlevelstart=999  foldminlines=0"
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  desc = "Make q close dap floating windows",
  group = vim.api.nvim_create_augroup("dapui", { clear = true }),
  pattern = "dap-float",
  callback = function() vim.keymap.set("n", "q", "<cmd>close!<cr>") end,
})
