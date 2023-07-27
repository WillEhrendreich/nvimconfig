-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
local grp = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
grp("xamlCommands", { clear = true })
autocmd({ "BufNewFile", "BufReadPre", "FileType" }, {
  desc = "changes comment style, folding for xaml",
  pattern = "*.xaml",
  group = "xamlCommands",
  callback = function()
    vim.cmd("set filetype=xml")
    vim.cmd("set commentstring=<!--%s-->")
    vim.cmd("let g:xml_syntax_folding=1")
    vim.cmd("set foldmethod=syntax")
    vim.cmd("set foldlevelstart=999  foldminlines=0")
  end,
})

autocmd("BufReadPost", {
  desc = "Make sure the filetype automatically is set to include comments.",
  group = grp("MakeJsonFTJsonC", { clear = true }),
  pattern = { "json", "*.json" },
  callback = function(_)
    vim.notify("im totally going to set this filetype to jsonc. dawg")

    vim.schedule_wrap(function()
      vim.notify("im totally going to set this filetype to jsonc. dawg")
      vim.cmd("set filetype=jsonc")
      vim.cmd("set syntax=jsonc")
      vim.bo.filetype("jsonc")
      vim.notify(
        "im totally going to set this filetype to " .. vim.opt.filetype .. " which by this point i hope is jsonc. dawg"
      )
    end)
  end,
})

autocmd("FileType", {
  desc = "Make sure the moon type automatically compiles on save ",
  group = grp("MoonAutoCompile", { clear = true }),
  pattern = "*.moon",
  callback = function(ev)
    vim.cmd("set syntax=moon")

    print(string.format("event fired: %s", vim.inspect(ev)))
  end,
})

autocmd({ "BufReadPost", "FileType" }, {
  desc = "Make sure the lua transpiled from moon type automatically re-reads on moon change",
  pattern = "*.moon",
  group = grp("MoonDerivedAutoRead", { clear = true }),
  callback = function(ev)
    vim.schedule(function()
      local thisActualBufnum = vim.api.nvim_get_current_buf()
      local luaBuffer = (vim.fn.filter(vim.api.nvim_list_bufs(), function(x)
        local basename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(thisActualBufnum), ":p:r")
        local moonfileName = basename .. ".moon"
        local otherName = basename .. ".lua"
        return otherName == vim.fn.fnamemodify(vim.api.nvim_buf_get_name(x), ":p")
      end))[1]
      if luaBuffer and vim.api.nvim_buf_is_loaded(luaBuffer) then
        vim.cmd.buffer(luaBuffer)
        vim.cmd("e!")
        vim.cmd.buffer(thisActualBufnum)
      end
    end)
  end,
})

grp("CppCommands", { clear = true })
autocmd({ "BufNewFile", "BufReadPre", "FileType" }, {
  desc = "changes comment string for cpp and similar files ",
  pattern = { "c", "cpp", "proto", "h", "objc", "cuda" },
  group = "CppCommands",
  callback = function()
    -- vim.cmd("set filetype=xml")
    vim.cmd("set commentstring=" .. "//" .. "%s")
    -- vim.cmd("let g:xml_syntax_folding=1")
    -- vim.cmd("set foldmethod=syntax")
    -- vim.cmd("set foldlevelstart=999  foldminlines=0")
  end,
})
-- vim.bo[bufnr].commentstring = "<!--%s-->"
autocmd("FileType", {
  desc = "Make q close help, man, quickfix, dap floats",
  group = grp("q_close_windows", { clear = true }),
  pattern = { "qf", "help", "man", "dap-float" },
  callback = function(event)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, nowait = true })
  end,
})
