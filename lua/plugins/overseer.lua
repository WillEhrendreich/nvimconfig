return {
  "stevearc/overseer.nvim",
  dependencies = {
    "nvim-neotest/neotest",
  },
  opts = {
    dap = true,
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
    strategy = { "toggleterm", open_on_start = false },
    task_list = {
      bindings = {
        ["?"] = "ShowHelp",
        ["g?"] = "ShowHelp",
        ["<CR>"] = "RunAction",
        ["<C-e>"] = "Edit",
        ["o"] = "Open",
        ["<C-v>"] = "OpenVsplit",
        ["<C-s>"] = "OpenSplit",
        ["<C-f>"] = "OpenFloat",
        ["<C-q>"] = "OpenQuickFix",
        ["p"] = "TogglePreview",
        ["<S-l>"] = "IncreaseDetail",
        ["<S-h>"] = "DecreaseDetail",
        -- ["L"] = "IncreaseAllDetail",
        -- ["H"] = "DecreaseAllDetail",
        ["["] = "DecreaseWidth",
        ["]"] = "IncreaseWidth",
        ["{"] = "PrevTask",
        ["}"] = "NextTask",
        ["<C-u>"] = "ScrollOutputUp",
        ["<C-d>"] = "ScrollOutputDown",
      },
    },
    -- consumers = {
    --   overseer = require("neotest.consumers.overseer"),
    -- },
  },
}
