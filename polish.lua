--- Open a URL under the cursor with the current operating system (Supports Mac OS X and *nix)
-- @param path the path of the file to open with the system opener
function astronvim.system_open(path)
  path = path or vim.fn.expand "<cfile>"
  if vim.fn.has "mac" == 1 then
    -- if mac use the open command
    vim.fn.jobstart({ "open", path }, { detach = true })
  elseif vim.fn.has "unix" == 1 then
    -- if unix then use xdg-open
    vim.fn.jobstart({ "xdg-open", path }, { detach = true })
  else
    -- if any other operating system notify the user that there is currently no support
    vim.fn.jobstart({ "openbrowser-smart-search", path }, { detach = true })
    -- astronvim.notify("System open is not supported on this OS!", "error")
  end
end

return function()
  vim.filetype.add {
    extension = {
      qmd = "markdown",
    },
    pattern = {
      ["/tmp/neomutt.*"] = "markdown",
    },
  }
  require "user.autocmds"
  require "user.globalCommands"
end
