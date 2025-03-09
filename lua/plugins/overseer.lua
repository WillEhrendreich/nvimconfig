return {
  "stevearc/overseer.nvim",
  dependencies = {
    "nvim-neotest/neotest",
  },
  ---@type overseer.Config
  opts = {
    dap = true,
    -- dap = false,
    sections = {
      lualine_x = {
        {
          "overseer",
          label = "", -- Prefix for task counts
          colored = true, -- Color the task icons and counts
          -- symbols = {
          --   [overseer.STATUS.FAILURE] = "F:",
          --   [overseer.STATUS.CANCELED] = "C:",
          --   [overseer.STATUS.SUCCESS] = "S:",
          --   [overseer.STATUS.RUNNING] = "R:",
          -- },
          unique = false, -- Unique-ify non-running task count by name
          name = nil, -- List of task names to search for
          name_not = false, -- When true, invert the name search
          status = nil, -- List of task statuses to display
          status_not = false, -- When true, invert the status search
        },
      },
    },
    component_aliases = {
      -- Most tasks are initialized with the default components
      default = {
        { "display_duration", detail_level = 2 },
        "on_output_summarize",
        "on_exit_set_status",
        "on_complete_notify",
        "on_complete_dispose",
      },
      -- Tasks from tasks.json use these components
      default_vscode = {
        "default",
        "on_complete_notify",
        "on_result_diagnostics",
        "on_exit_set_status",
        "on_result_diagnostics_quickfix",
      },
    },
    strategy = { "toggleterm", open_on_start = false },
    task_launcher = {
      -- Set keymap to false to remove default behavior
      -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
      bindings = {
        i = {
          ["<CR>"] = "Submit",
          ["<Esc>"] = "Cancel",
        },
        n = {
          ["<CR>"] = "Submit",
          -- ["<C-s>"] = "Submit",
          ["q"] = "Cancel",
          ["?"] = "ShowHelp",
        },
      },
    },

    task_editor = {

      win_opts = {
        title = "Task Editor",
        title_position = "center",
      },
      -- Set keymap to false to remove default behavior
      -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
      bindings = {
        i = {
          -- ["<CR>"] = "NextOrSubmit",
          ["<CR>"] = "Submit",
          ["<Tab>"] = "Next",
          ["<S-Tab>"] = "Prev",
          ["<esc>"] = "Cancel",
        },
        n = {
          -- ["<CR>"] = "NextOrSubmit",
          ["<CR>"] = "Submit",
          ["n"] = "Next",
          ["k"] = "Prev",
          -- ["<esc>"] = "Cancel",
          ["q"] = "Cancel",
          ["?"] = "ShowHelp",
        },
      },
    },
    task_list = {
      bindings = {
        ["?"] = "ShowHelp",
        ["g?"] = "ShowHelp",
        ["<CR>"] = "RunAction",
        ["l"] = "Edit",
        ["o"] = "Open",
        ["v"] = "OpenVsplit",
        ["s"] = "OpenSplit",
        ["f"] = "OpenFloat",
        ["<C-q>"] = "OpenQuickFix",
        ["p"] = "TogglePreview",
        ["<S-l>"] = "IncreaseDetail",
        ["<S-h>"] = "DecreaseDetail",
        -- ["L"] = "IncreaseAllDetail",
        -- ["H"] = "DecreaseAllDetail",
        ["["] = "DecreaseWidth",
        ["]"] = "IncreaseWidth",
        ["k"] = "PrevTask",
        ["j"] = "NextTask",
        ["<C-u>"] = "ScrollOutputUp",
        ["<C-d>"] = "ScrollOutputDown",
      },
      -- Default detail level for tasks. Can be 1-3.
      default_detail = 1,
      -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      -- min_width and max_width can be a single value or a list of mixed integer/float types.
      -- max_width = {100, 0.2} means "the lesser of 100 columns or 20% of total"
      max_width = { 100, 0.4 },
      -- min_width = {40, 0.1} means "the greater of 40 columns or 10% of total"
      min_width = { 20, 0.1 },
      -- optionally define an integer/float for the exact width of the task list
      width = nil,
      max_height = { 20, 0.1 },
      min_height = 8,
      height = nil,
      -- String that separates tasks
      separator = "────────────────────────────────────────",
      -- Default direction. Can be "left", "right", or "bottom"
      title = "Task List",
      title_position = "center",

      direction = "bottom",
      win_opts = {
        wrap = true,
        winblend = 0,
      },
    },
    -- Configure the floating window used for confirmation prompts
    confirm = {
      title = "Confirm Dialog",
      title_pos = "center",
      border = "rounded",
      zindex = 40,
      -- Dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      -- min_X and max_X can be a single value or a list of mixed integer/float types.
      min_width = 20,
      max_width = 0.9,
      width = nil,
      min_height = 6,
      max_height = 0.9,
      height = nil,
      -- Set any window options here (e.g. winhighlight)
      win_opts = {

        wrap = true,
        winblend = 0,
      },
    },
    -- consumers = {
    --   overseer = require("neotest.consumers.overseer"),
    -- },
  },
}
