local a = vim.api
local grp = vim.api.nvim_create_augroup
local acmd = vim.api.nvim_create_autocmd
local setlines = vim.api.nvim_buf_set_lines
local jb = vim.fn.jobstart
local uc = vim.api.nvim_create_user_command
local inp = vim.fn.input

acmd("VimLeave", {
  desc = "Stop running auto compiler",
  group = grp("autocomp", { clear = true }),
  pattern = "*",
  callback = function() vim.fn.jobstart { "autocomp", vim.fn.expand "%:p", "stop" } end,
})

local attachToBuffer = function(outputBufnr, pattern, command)
  acmd("BufWritePost", {
    desc = "AutoMagically runs a command on the file after it saves",
    group = grp("AutoMagicBufOut-->ForBufferNumber:" .. outputBufnr, { clear = true }),
    pattern = pattern,
    callback = function()
      local append_data = function(_, data)
        if data then setlines(outputBufnr, -1, -1, false, data) end
      end
      setlines(outputBufnr, 0, -1, false, { "output" })
      jb(command, {
        stdout_buffered = true,
        on_stdout = append_data,
        on_stderr = append_data,
      })
    end,
  })
end

uc("AutoRun", function()
  local bufnr = tonumber(inp "Bufnr: ")
  local pattern = inp "Pattern: "
  local command = inp "Command: "
  local csplit = vim.split(command, "")
  print "AutoRun starts now ... "
  local allcon = ("buf: " .. bufnr .. " pattern: " .. pattern .. " command: " .. command .. "")
  print(allcon)
  attachToBuffer(bufnr, pattern, csplit)
end, {})

-- attachToBuffer(1, "*.fs", { "dotnet", "test", vim.api.nvim_buf_get_name(1) })

grp("FsharpProjCommands", { clear = true })
acmd({ "BufNewFile", "BufRead" }, {
  desc = "changes comment style for fsproj",
  pattern = "*.fsproj",
  group = "FsharpProjCommands",
  callback = function() a.nvim_command "set filetype=xml" end,
})
acmd({ "FileType" }, {
  desc = "changes comment style, folding for fsproj",
  pattern = "*.fsproj",
  group = "FsharpProjCommands",
  callback = function()
    a.nvim_command "set commentstring=<!--%s-->"
    a.nvim_command "let g:xml_syntax_folding=1"
    a.nvim_command "setlocal foldmethod=syntax"
    a.nvim_command "setlocal foldlevelstart=999  foldminlines=0"
  end,
})

grp("xamlCommands", { clear = true })
acmd({ "BufNewFile", "BufRead" }, {
  desc = "changes comment style for xaml",
  pattern = "*.xaml",
  group = "xamlCommands",
  callback = function() a.nvim_command "set filetype=xml" end,
})
acmd({ "FileType" }, {
  desc = "changes comment style, folding for xaml",
  pattern = "*.xaml",
  group = "xamlCommands",
  callback = function()
    a.nvim_command "set commentstring=<!--%s-->"
    a.nvim_command "let g:xml_syntax_folding=1"
    a.nvim_command "setlocal foldmethod=syntax"
    a.nvim_command "setlocal foldlevelstart=999  foldminlines=0"
  end,
})
acmd("FileType", {
  desc = "Make q close dap floating windows",
  group = grp("dapui", { clear = true }),
  pattern = "dap-float",
  callback = function() vim.keymap.set("n", "q", "<cmd>close!<cr>") end,
})
