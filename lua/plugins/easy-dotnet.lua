return {
  opts = {
    --Optional function to return the path for the dotnet sdk (e.g C:/ProgramFiles/dotnet/sdk/8.0.0)
    get_sdk_path = function()
      local sdk_version = vim.trim(vim.system({ "dotnet", "--version" }):wait().stdout)
      local sdk_list = vim.trim(vim.system({ "dotnet", "--list-sdks" }):wait().stdout)
      local base = nil
      for line in sdk_list:gmatch("[^\n]+") do
        if line:find(sdk_version, 1, true) then
          base = vim.fs.normalize(line:match("%[(.-)%]"))
          break
        end
      end
      local sdk_path = vim.fs.joinpath(base, sdk_version):gsub("Program Files", '"Program Files"')
      return sdk_path
    end,
    ---@type TestRunnerOptions
    test_runner = {
      ---@type "split" | "float" | "buf"
      viewmode = "float",
      enable_buffer_test_execution = true, --Experimental, run tests directly from buffer
      noBuild = true,
      noRestore = true,
      icons = {
        passed = "",
        skipped = "",
        failed = "",
        success = "",
        reload = "",
        test = "",
        sln = "󰘐",
        project = "󰘐",
        dir = "",
        package = "",
      },
      mappings = {
        run_test_from_buffer = { lhs = "<leader>rt", desc = "run test from buffer" },
        debug_test_from_buffer = { lhs = "<leader>rd", desc = "run test from buffer" },
        filter_failed_tests = { lhs = "<leader>dff", desc = "filter failed tests" },
        debug_test = { lhs = "<leader>dt", desc = "debug test" },
        go_to_file = { lhs = "g", desc = "got to file" },
        run_all = { lhs = "<leader>R", desc = "run all tests" },
        run = { lhs = "<leader>r", desc = "run test" },
        peek_stacktrace = { lhs = "<leader>p", desc = "peek stacktrace of failed test" },
        peek_stack_trace_from_buffer = { lhs = "<leader>stb", desc = "peek stacktrace of failed test from buffer" },
        expand = { lhs = "l", desc = "expand" },
        expand_node = { lhs = "E", desc = "expand node" },
        expand_all = { lhs = "-", desc = "expand all" },
        collapse_all = { lhs = "h", desc = "collapse all" },
        close = { lhs = "q", desc = "close testrunner" },
        refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" },
      },
      --- Optional table of extra args e.g "--blame crash"
      additional_args = {},
    },
    ---@param action "test" | "restore" | "build" | "run"
    terminal = function(path, action)
      local commands = {
        run = function()
          return "dotnet run --project " .. path
        end,
        test = function()
          return "dotnet test " .. path
        end,
        restore = function()
          return "dotnet restore " .. path
        end,
        build = function()
          return "dotnet build " .. path
        end,
      }
      local command = commands[action]() .. "\r"
      vim.cmd("vsplit")
      vim.cmd("term " .. command)
    end,
    secrets = {
      path = function() end, --filling this in at runtime.
    },
    csproj_mappings = true,
    fsproj_mappings = true,
    auto_bootstrap_namespace = true,
  },
  "GustavEikaas/easy-dotnet.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function(_, opts)
    local easy = require("easy-dotnet")
    local function get_secret_path(secret_guid)
      local path = ""
      local home_dir = vim.fn.expand("~")
      if require("easy-dotnet.extensions").isWindows() then
        local secret_path = home_dir
          .. "\\AppData\\Roaming\\Microsoft\\UserSecrets\\"
          .. secret_guid
          .. "\\secrets.json"
        path = secret_path
      else
        local secret_path = home_dir .. "/.microsoft/usersecrets/" .. secret_guid .. "/secrets.json"
        path = secret_path
      end
      return path
    end

    opts["get_secret_path"] = get_secret_path

    easy.setup(opts)
    -- local dotnet = require("easy-dotnet")
    -- -- Options are not required
    -- dotnet.setup()

    -- Example command
    -- vim.api.nvim_create_user_command("Secrets", function()
    --   dotnet.secrets()
    -- end, {})

    -- Example keybinding
    -- vim.keymap.set("n", "<C-p>", function()
    --   dotnet.run_project()
    -- end)
  end,
}
