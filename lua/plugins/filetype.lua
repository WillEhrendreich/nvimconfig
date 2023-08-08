vim.filetype.add({
  extension = {
    log = function(_, _)
      return "log",
        function(bufnr)
          -- have this buffer turn wrap on for insert mode

          vim.opt_local.wrap = true

          vim.bo[bufnr].syn = "log"
          vim.bo[bufnr].ro = false
          vim.b[bufnr].readonly = false
          -- vim.bo[bufnr].commentstring = "<!--%s-->"
          -- vim.bo[bufnr].comments = "<!--,e:-->"
          vim.opt_local.foldlevelstart = 99
          vim.w.fdm = "syntax"
        end
    end,
  },
})

-- local scrubExtraFsautocompleteStuff = function()
--   local pat = "/\\[ERROR\\].*INF\\] \\[.*] "
--   -- local buftext = vim.inspect(vim.api.nvim_buf_get_lines(0, 0, -1, false))
--   --
--   -- if string.match(buftext, pat) then
--   vim.cmd("%s" .. pat)
--
--   vim.cmd("set filetype=json")
--
--   vim.cmd([[%s/\\\\\\\\/\\\\/g]])
--   vim.cmd([[%s/\\\\/\//g]])
--   vim.cmd([[%s/\\r\\n/\n/g]])
--   -- vim.lsp.buf.format()
--
--   -- for _, line in pairs(buftext) do
--   -- if string.match(line, pat) then
--
--   -- StringReplace(line, string.match(line, pat), "")
--   -- end
--   -- end
-- end

-- vim.api.nvim_create_autocmd("BufReadPost", {
--
--   group = vim.api.nvim_create_augroup("scrubExtraFsautocompleteStuff", { clear = true }),
--   pattern = "lsp.log",
--   callback = scrubExtraFsautocompleteStuff,
-- })

return {

  "MTDL9/vim-log-highlighting",
}
