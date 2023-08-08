local Util = require("lazyvim.util")
return {
  "anuvyklack/hydra.nvim",
  opts = {},
  config = function()
    -- if Util.has("hydra") then

    local Hydra = require("hydra")
    local dap = require("dap")

    local hint = [[
      _o_: step over   _c_: Continue/Start   _b_: Breakpoint     _K_: Hover
      _i_: step into   _x_: Quit             _d_: Toggle DapUi   ^ ^
      _u_: step up/out _X_: Stop             ^ ^
      _t_: to cursor   _C_: Close UI
      ^
      ^ ^              _q_: exit
      ]]

    local dap_hydra = Hydra({
      -- hint = hint,
      config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
          type = "statusline",
          position = "bottom",
          border = "rounded",
        },
      },
      name = "dap",
      mode = { "n", "x" },
      body = "<leader>dh",
      heads = {
        { "o", dap.step_over, { silent = true } },
        { "i", dap.step_into, { silent = true } },
        { "u", dap.step_out, { silent = true } },
        { "t", dap.run_to_cursor, { silent = true } },
        {
          "d",
          function()
            if Util.has("nvim-dap-ui") then
              require("dapui").toggle()
            end
          end,
          { silent = true },
        },

        { "c", dap.continue, { silent = true } },
        {
          "p",

          function()
            vim.notify("trying to execute PreDebugTask user command ")
            local hasPreDebugTaskUserCommand = vim.api.nvim_get_commands({})["PreDebugTask"] or false
            if hasPreDebugTaskUserCommand then
              vim.cmd("PreDebugTask")
            else
              -- require("dap").continue()
              -- print("predebug task was false, so assuming there was a problem and not debugging")
            end
            -- vim.cmd.predebugtask()
            -- dap.continue
          end,
          { silent = true },
        },
        { "x", ":lua require'dap'.disconnect({ terminateDebuggee = false })<CR>", { exit = true, silent = true } },
        { "X", dap.close, { silent = true } },
        { "C", ":lua require('dapui').close()<cr>:DapVirtualTextForceRefresh<CR>", { silent = true } },
        { "b", dap.toggle_breakpoint, { silent = true } },
        {
          "K",
          function()
            -- if "nvim-dap-ui" then
            -- require("dap.ui.widgets").hover()
            -- else
            require("dap.ui.widgets").hover()
            -- end
          end,
          { silent = true },
        },
        { "q", nil, { exit = true, nowait = true } },
      },
    })
    Hydra.spawn = function(head)
      if head == "dap-hydra" then
        dap_hydra:activate()
      end
    end
    -- end
  end,

  dependancies = {
    "mfussenegger/nvim-dap",
  },
}
