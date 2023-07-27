return {
  -- generate doc comment
  "haringsrob/nvim_context_vt",
  config = function()
    require("nvim_context_vt").setup({
      -- disable_ft = {"rust", "rs"},
      disable_virtual_lines = true,
      min_rows = 8,
    })
  end,
}
