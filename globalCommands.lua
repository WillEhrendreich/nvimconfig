P = function(v)
  print(vim.inspect(v))
  return v
end
RELOAD = function(...)
  P("Reloading Module " .. ...)

  return require("plenary.reload").reload_module(...)
end
R = function(name)
  RELOAD(name)
  return require(name)
end

TRY = function(module, Ok, NotOk)
  local ok, _ = pcall(require, module)
  if ok then
    Ok()
  else
    NotOk()
  end
end



SCRATCH = function(input)
  -- vim.ui.input({ prompt = "enter command", completion = "command" }, function(input)
  --
  if input == nil then
    return
  elseif input == "scratch" then
    input = "echo('')"
  end
  local cmd = vim.api.nvim_exec(input, { output = true })
  local output = {}
  for line in cmd:gmatch "[^\n]+" do
    table.insert(output, line)
  end
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
  vim.api.nvim_win_set_buf(0, buf)
  -- end)
end
