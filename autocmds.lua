vim.api.nvim_create_augroup("autocomp", { clear = true })
vim.api.nvim_create_autocmd("VimLeave", {
  desc = "Stop running auto compiler",
  group = "autocomp",
  pattern = "*",
  callback = function()
    vim.fn.jobstart { "autocomp", vim.fn.expand "%:p", "stop" }
  end,
})

vim.api.nvim_create_augroup("dapui", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  desc = "Make q close dap floating windows",
  group = "dapui",
  pattern = "dap-float",
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close!<cr>")
  end,
})

vim.api.nvim_create_augroup("mini", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "TermOpen" }, {
  desc = "Disable indent scope for conent types",
  group = "mini",
  callback = function()
    vim.b.miniindentscope_disable = vim.tbl_contains({ "help", "terminal", "nofile", "prompt" }, vim.bo.buftype)
  end,
})

vim.api.nvim_create_augroup("fsharpComments", { clear = true })
vim.api.nvim_create_autocmd({ "FileType"  }, {
  desc = "changes comment style for fsharp",
  pattern = "*.fs,*.fsx,*.fsi",
  group = "fsharpComments",
  callback = function()
      vim.api.nvim_command("set commentstring=//%s")
  end,
})
