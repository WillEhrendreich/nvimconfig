local dap = require "dap"
local util = require "neo-tree.utils"

vim.g.dotnet_build_project = function()
  local default_path = vim.lsp.buf.list_workspace_folders()[1] .. "/"
  if vim.g["dotnet_last_proj_path"] ~= nil then default_path = vim.g["dotnet_last_proj_path"] end
  local path = vim.fn.input("Path to your *proj file ", default_path, "file")
  vim.g["dotnet_last_proj_path"] = path
  local cmd = "dotnet build -c Debug " .. path
  -- local cmd = "dotnet build -c Debug " .. path .. " > /dev/null"
  print ""
  print("Cmd to execute: " .. cmd)
  local f = os.execute(cmd)
  if f == 0 then
    print "\nBuild: ✔️ "
  else
    print("\nBuild: ❌ (code: " .. f .. ")")
  end
end
local replaceSeps = function(p) return p:gsub("\\", "/") end
vim.g.dotnet_get_dll_path = function()
  local request = function()
    return replaceSeps(vim.fn.input("Path to dll ", vim.lsp.buf.list_workspace_folders()[1] .. "/bin/Debug/", "file"))
  end
  if vim.g["dotnet_last_dll_path"] == nil then
    vim.g["dotnet_last_dll_path"] = request()
  else
    if
      vim.fn.confirm("Do you want to change the path to dll?\n" .. vim.g["dotnet_last_dll_path"], "&yes\n&no", 2) == 1
    then
      vim.g["dotnet_last_dll_path"] = request()
    end
    print("path to dll is set to: " .. vim.g["dotnet_last_dll_path"])
  end
  return vim.g["dotnet_last_dll_path"]
end

local config = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
      if vim.fn.confirm("Should I recompile first?", "&yes\n&no", 2) == 1 then vim.g.dotnet_build_project() end
      return vim.g.dotnet_get_dll_path()
    end,
  },
}

require("mason-nvim-dap").setup {
  automatic_installation = true,
  automatic_setup = true,
  ensure_installed = { "coreclr", "bash", "js", "python" },
}
require("mason-nvim-dap").setup_handlers {

  function(source_name)
    -- all sources with no handler get passed here
    -- Keep original functionality of `automatic_setup = true`
    require "mason-nvim-dap.automatic_setup"(source_name)
  end,

  coreclr = function(source_name)
    dap.adapters.coreclr = {
      type = "executable",
      command = "C:/.local/share/nvim-data/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe",
      -- command = "C:/.local/share/nvim-data/mason/bin/netcoredbg.cmd",
      args = { "--interpreter=vscode" },
    }
    dap.configurations.cs = config
    dap.configurations.fsharp = config
  end,
  python = function(source_name)
    dap.adapters.python = {
      type = "executable",
      command = "C:/Python310/python.exe",
      args = {
        "-m",
        "debugpy.adapter",
      },
    }

    dap.configurations.python = {
      {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}", -- This configuration will launch the current file if used.
      },
    }
  end,
}
