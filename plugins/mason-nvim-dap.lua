local dap = require "dap"
local util = require "neo-tree.utils"
local replaceSeps = function(p) return p:gsub("\\", "/") end

vim.g.dotnet_get_project_path = function()
  local default_path = replaceSeps(vim.lsp.buf.list_workspace_folders()[1]) .. "/"
  if vim.g["dotnet_last_proj_path"] == nil then default_path = vim.fn.getcwd() end
  local path = vim.fn.input("Path to your *proj file ", default_path, "file")
  vim.g["dotnet_last_proj_path"] = path
  return path
end

vim.g.dotnet_build_project = function(path, buildType)
  local t = buildType or "debug"
  if t == "r" or "release" or "Release" or "R" then
    print("building project: " .. path .. "with build type " .. t)
    return vim.g.dotnet_build_release_project(path)
  else
    print("building project: " .. path .. "with build type " .. t)
    return vim.g.dotnet_build_debug_project(path)
  end
end

local openFileInNewBuffer = function(f)
  if vim.fn.confirm("Do you want to open the file " .. f .. " ?\n", "&yes\n&no", 2) == 1 then vim.cmd.bufload(f) end
end

vim.g.dotnet_build_release_project = function(p)
  local logfile = "c:/temp/dotnet-release-Log.txt"
  -- local cmd = "dotnet build -c Release " .. p .. '" *> ' .. logfile
  local cmd = "dotnet build -c Release " .. p
  print ""
  print("Cmd to execute: " .. cmd)
  local f = os.execute(cmd)
  if f == 0 then
    print "\nBuild: ✔️ "
  else
    print("\nBuild: ❌ (code: " .. f .. ")")
    openFileInNewBuffer(logfile)
  end
  return f
end

vim.g.dotnet_build_debug_project = function(p)
  local logfile = "c:/temp/dap-debug-nvim-dotnet.txt"
  -- local cmd = "dotnet build -c Debug " .. p .. '" *> ' .. logfile
  local cmd = "dotnet build -c Debug " .. p
  print ""
  print("Cmd to execute: " .. cmd)
  local f = os.execute(cmd)
  if f == 0 then
    print "\nBuild: ✔️ "
  else
    print("\nBuild: ❌ (code: " .. f .. ")")
    openFileInNewBuffer(logfile)
  end
  return f
end

vim.g.dotnet_get_dll_path = function()
  local request = function()
    return vim.fn.input("Path to dll ", replaceSeps(vim.lsp.buf.list_workspace_folders()[1]) .. "/bin/Debug/", "file")
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
      if vim.fn.confirm("Should I recompile first?", "&yes\n&no", 2) == 1 then
        vim.g.dotnet_build_project(vim.g.dotnet_get_project_path())
      end
      return vim.g.dotnet_get_dll_path()
    end,
  },
}

vim.g.dotnet_run = function(proj, runtype)
  local c = ":!dotnet run " .. proj
  vim.cmd(c)
end

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
