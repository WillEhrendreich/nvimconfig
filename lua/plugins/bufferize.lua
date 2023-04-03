SCRATCH = function(input)
  vim.cmd.Bufferize(input)
end
return {
  "WillEhrendreich/bufferize.nvim",
  cmd = "Bufferize",
  -- dir = vim.fn.getenv("repos") .. "/bufferize/",
  -- dev = true,

  config = function()
    --nothing here yet
  end,
}
