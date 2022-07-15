local status_ok, x = pcall(require, "nvim-luapad")
if not status_ok then
  return
end
x.setup()
