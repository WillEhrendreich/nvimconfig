local dotnetDapConfig = {
  type = "coreclr",
  name = "launch - netcoredbg",
  request = "launch",
  program = function()
    local dap = require("dap")
    if not dap.adapters.coreclr then
      dap.adapters["coreclr"] = {
        type = "executable",
        command = unpack(vim.inspect(vim.fs.find("netcoredbg.exe", { path = vim.fn.stdpath("data") })))[1],
        -- command =  "C:/.local/share/nvim-data/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe",
        -- command = "C:/.local/share/nvim-data/mason/bin/netcoredbg.cmd",
        args = { "--interpreter=vscode" },
      }
    end
    vim.notify("just set dap.adapters.coreclr to " .. vim.inspect(dap.adapters.coreclr or "NOTHING:?:???!+?@!?"))
    if vim.fn.confirm("Should I recompile first?", "&yes\n&no", 2) == 1 then
      DotnetBuild(GetDotnetProjectPath())
    end
    return GetDotnetDllPath()
  end,
}

local function getDapConfig()
  local root = FindRoot() or vim.fn.getcwd()
  -- local root = vimsharp.utils.lsp.FindRoot(vimsharp.utils.lsp.IgnoredLspServersForFindingRoot) or vim.fn.getcwd()

  -- vim.notify("just set dap.adapters.coreclr to " .. vim.inspect(dap.adapters.coreclr or "NOTHING:?:???!+?@!?"))
  local dap_config = DecodeJsonFile(root .. "/.dap.json") or dotnetDapConfig
  if dap_config ~= nil then
    -- vim.notify("just set dap.adapters.coreclr to " .. vim.inspect(dap.adapters.coreclr or "NOTHING:?:???!+?@!?"))
    return { dap_config }
  end

  local status_ok, vscode_launch_file = pcall(DecodeJsonFile, root .. "/.vscode/launch.json")
  if status_ok and vscode_launch_file ~= nil then
    local configs = vscode_launch_file["configurations"]
    if configs ~= nil then
      for j = 1, #configs do
        if configs[j]["request"] == "launch" then
          local config = StringReplace(configs[j], "${workspaceRoot}", root)
          return { config }
        end
      end
      return vim.json_encode(StringReplace(configs, "${workspaceRoot}", root))
    end
  end

  -- vim.notify("just set dap.adapters.coreclr to " .. vim.inspect(dap.adapters.coreclr or "NOTHING:?:???!+?@!?"))
  return nil
end

local function dapuiconfigFunc(_, opts)
  local dap, dapui = require("dap"), require("dapui")
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
  dapui.setup(opts)
end

local function dapconfig(_, opts)
  local mason_nvim_dap = require("mason-nvim-dap")
  mason_nvim_dap.setup(opts)
  mason_nvim_dap.setup_handlers({

    function(source_name)
      -- all sources with no handler get passed here
      -- Keep original functionality of `automatic_init = true`
      require("mason-nvim-dap.automatic_setup")(source_name)
    end,

    coreclr = function(source_name)
      local function get_first_string_value(t)
        for _, value in pairs(t) do
          if type(value) == "string" then
            return value
          end
        end
      end

      local dap = require("dap")
      dap.adapters.coreclr = {
        type = "executable",
        command = get_first_string_value(vim.fs.find("netcoredbg.exe", { path = vim.fn.stdpath("data") })),
        -- command =  "C:/.local/share/nvim-data/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe",
        -- command = "C:/.local/share/nvim-data/mason/bin/netcoredbg.cmd",
        args = { "--interpreter=vscode" },
      }
      dap.configurations.cs = getDapConfig()
      dap.configurations.fsharp = getDapConfig()
    end,

    python = function(source_name)
      local dap = require("dap")
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
  })
end

return {
  "mfussenegger/nvim-dap",

  dependencies = {
    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = { "nvim-dap" },
      cmd = { "DapInstall", "DapUninstall" },

      opts = {

        automatic_setup = true,
        automatic_installation = true,
        ensure_installed = { "coreclr" },
      },

      config = dapconfig,
      -- config = require "plugins.configs.mason-nvim-dap",
    },
    {
      "rcarriga/nvim-dap-ui",
      opts = { floating = { border = "rounded" } },
      config = dapuiconfigFunc,
      -- config = require "plugins.configs.nvim-dap-ui",
    },
  },
}
