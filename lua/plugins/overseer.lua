return {
  "stevearc/overseer.nvim",
  dependencies = {
    "nvim-neotest/neotest",
  },
  opts = {
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
    -- consumers = {
    --   overseer = require("neotest.consumers.overseer"),
    -- },
  },
}
