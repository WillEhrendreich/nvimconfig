-- term_details can be either a string for just a command or
-- a complete table to provide full access to configuration when calling Terminal:new()

UserTerms = {}
return {
  {

    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    opts = {

      size = 12,
      open_mapping = [[<F7>]],
      shading_factor = 2,
      direction = "float",
      float_opts = {
        border = "curved",
        highlights = { border = "Normal", background = "Normal" },
      },
    },
  },
}
