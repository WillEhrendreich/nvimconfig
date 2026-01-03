-- Configuration for fsi-mcp-server integration
-- This allows you to use fsi-mcp-server instead of regular dotnet fsi
-- when available, providing enhanced F# REPL capabilities
-- FSI terminal is created as a split at the bottom, separate from ToggleTerm

local M = {}

-- Store FSI terminal info
M.fsi_buf = nil
M.fsi_win = nil
M.fsi_job = nil

-- Check if fsi-mcp-server is available
---@return boolean
function M.is_fsi_mcp_available()
  return vim.fn.executable("fsi-mcp-server") == 1
end

-- Check if regular dotnet fsi is available
---@return boolean
function M.is_dotnet_fsi_available()
  return vim.fn.executable("dotnet") == 1
end

-- Get the appropriate FSI command
---@return string[]|nil
function M.get_fsi_command()
  if M.is_fsi_mcp_available() then
    return { "fsi-mcp-server" }
  elseif M.is_dotnet_fsi_available() then
    return { "dotnet", "fsi" }
  end
  return nil
end

-- Check if FSI terminal is open
---@return boolean
function M.is_fsi_open()
  return M.fsi_buf ~= nil 
    and vim.api.nvim_buf_is_valid(M.fsi_buf) 
    and M.fsi_win ~= nil 
    and vim.api.nvim_win_is_valid(M.fsi_win)
end

-- Close FSI terminal
function M.close_fsi()
  if M.fsi_win and vim.api.nvim_win_is_valid(M.fsi_win) then
    vim.api.nvim_win_close(M.fsi_win, true)
  end
  M.fsi_win = nil
  if M.fsi_buf and vim.api.nvim_buf_is_valid(M.fsi_buf) then
    vim.api.nvim_buf_delete(M.fsi_buf, { force = true })
  end
  M.fsi_buf = nil
  M.fsi_job = nil
end

-- Check if fsi-mcp-server is already running on port 5020
---@return boolean, number|nil
function M.is_fsi_mcp_server_running()
  -- Get the PID of the process listening on 5020
  local handle = io.popen('powershell -Command "Get-NetTCPConnection -LocalPort 5020 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess"')
  if handle then
    local result = handle:read("*a")
    handle:close()
    local pid = tonumber(result:match("%d+"))
    if pid then
      return true, pid
    end
  end
  return false, nil
end

-- Connect to existing fsi-mcp-server by piping to its console input
function M.connect_to_existing_fsi_server(pid)
  if not M.is_fsi_open() then
    -- Create a buffer for the terminal
    M.fsi_buf = vim.api.nvim_create_buf(false, true)
    
    -- Set buffer options
    vim.api.nvim_buf_set_option(M.fsi_buf, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(M.fsi_buf, "buflisted", false)
    vim.api.nvim_buf_set_option(M.fsi_buf, "swapfile", false)
    
    -- Create a split at the bottom
    vim.cmd("botright split")
    M.fsi_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_height(M.fsi_win, 15)
    vim.api.nvim_win_set_buf(M.fsi_win, M.fsi_buf)
    
    -- Use PowerShell to read from fsi-mcp's log file in real-time and send input via named pipe or similar
    -- This is a workaround - we'll tail the debug log and send via stdin simulation
    local tempPath = vim.fn.expand("$TEMP")
    local sessionId = string.format("%08x", math.random(0, 0xFFFFFFFF)) -- guess session ID from logs
    
    -- Find the actual session ID from logs
    local logPattern = tempPath .. "\\fsi-mcp-debugging-*.log"
    local findSessionCmd = string.format(
      'powershell -Command "Get-ChildItem -Path \'%s\' | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Select-Object -ExpandProperty Name"',
      tempPath
    )
    
    local logHandle = io.popen(findSessionCmd)
    if logHandle then
      local logFile = logHandle:read("*a"):gsub("%s+", "")
      logHandle:close()
      sessionId = logFile:match("fsi%-mcp%-debugging%-(%w+)%.log") or sessionId
    end
    
    -- Connect by tailing the log file for output and using a wrapper script for input
    M.fsi_job = vim.fn.termopen(
      string.format('powershell -Command "Get-Content -Path \'%s\\fsi-mcp-debugging-%s.log\' -Wait -Tail 50"', tempPath, sessionId),
      {
        on_exit = function()
          M.close_fsi()
        end,
      }
    )
    
    vim.api.nvim_buf_set_name(M.fsi_buf, "FSI-MCP: Connected to session " .. sessionId)
    vim.notify("📺 Connected to existing FSI session: " .. sessionId, vim.log.levels.INFO)
    vim.notify("⚠️  Output only - for input, use the fsi-mcp console window", vim.log.levels.WARN)
    
    -- Go back to previous window
    vim.cmd("wincmd p")
  end
end

-- Open FSI terminal in a bottom split
---@param use_mcp? boolean Force use of mcp server if true, force regular fsi if false, auto-detect if nil
function M.open_fsi(use_mcp)
  if M.is_fsi_open() then
    return
  end

  local cmd
  if use_mcp == true then
    if not M.is_fsi_mcp_available() then
      vim.notify("fsi-mcp-server not found. Install it first.", vim.log.levels.ERROR)
      return
    end
    
    -- Check if fsi-mcp-server is already running
    local is_running, pid = M.is_fsi_mcp_server_running()
    if is_running then
      vim.notify(string.format("✅ fsi-mcp-server already running (PID: %d)", pid), vim.log.levels.INFO)
      vim.notify("Connecting to existing session...", vim.log.levels.INFO)
      M.connect_to_existing_fsi_server(pid)
      return
    end
    
    cmd = { "fsi-mcp-server" }
  elseif use_mcp == false then
    if not M.is_dotnet_fsi_available() then
      vim.notify("dotnet fsi not found. Install dotnet SDK first.", vim.log.levels.ERROR)
      return
    end
    cmd = { "dotnet", "fsi" }
  else
    cmd = M.get_fsi_command()
    if not cmd then
      vim.notify("Neither fsi-mcp-server nor dotnet fsi found.", vim.log.levels.ERROR)
      return
    end
  end

  -- Create a buffer for the terminal
  M.fsi_buf = vim.api.nvim_create_buf(false, true)
  
  -- Set buffer options to make it hidden from buffer list
  vim.api.nvim_buf_set_option(M.fsi_buf, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(M.fsi_buf, "buflisted", false)
  vim.api.nvim_buf_set_option(M.fsi_buf, "swapfile", false)
  
  -- Create a split at the bottom
  vim.cmd("botright split")
  M.fsi_win = vim.api.nvim_get_current_win()
  
  -- Set window height
  vim.api.nvim_win_set_height(M.fsi_win, 15)
  
  -- Set the buffer in the window
  vim.api.nvim_win_set_buf(M.fsi_win, M.fsi_buf)
  
  -- Start the terminal
  M.fsi_job = vim.fn.termopen(cmd, {
    on_exit = function()
      M.close_fsi()
    end,
  })
  
  -- Set buffer name
  vim.api.nvim_buf_set_name(M.fsi_buf, "FSI: " .. (use_mcp == true and "fsi-mcp-server" or use_mcp == false and "dotnet fsi" or "auto"))
  
  -- Set up keymaps for the FSI buffer
  vim.api.nvim_buf_set_keymap(M.fsi_buf, "n", "q", "", {
    noremap = true,
    silent = true,
    callback = function()
      M.close_fsi()
    end,
  })
  
  vim.api.nvim_buf_set_keymap(M.fsi_buf, "t", "<C-q>", "", {
    noremap = true,
    silent = true,
    callback = function()
      M.close_fsi()
    end,
  })
  
  -- Go back to previous window
  vim.cmd("wincmd p")
end

-- Toggle FSI terminal
---@param use_mcp? boolean
function M.toggle_fsi(use_mcp)
  if M.is_fsi_open() then
    M.close_fsi()
  else
    M.open_fsi(use_mcp)
  end
end

-- Send text to FSI terminal OR to fsix daemon via PowerShell bridge
---@param text string
function M.send_to_fsi(text)
  -- Send to fsi-mcp-server for FULL collaboration (neovim + Copilot share events)
  local start_time = vim.loop.hrtime()
  local timestamp = os.date("%H:%M:%S")
  vim.notify(string.format("📤 [%s] Sending...", timestamp), vim.log.levels.INFO)
  
  -- Ensure code ends with ;;
  if not text:match(";;%s*$") then
    text = text .. ";;"
  end
  
  -- Send to MCP server via HTTP POST to /api/send
  local api_request = vim.json.encode({
    code = text,
    agentName = "neovim",
    useFsix = true
  })
  
  -- Use curl with stdin (no temp file needed)
  local cmd = {
    "curl",
    "-s",
    "-X", "POST",
    "-H", "Content-Type: application/json",
    "-d", api_request,
    "--max-time", "2",
    "http://localhost:5020/api/send"
  }
  
  -- Run asynchronously
  local stdout_data = {}
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stdout_data, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        local end_time = vim.loop.hrtime()
        local elapsed_ms = (end_time - start_time) / 1000000
        
        local output = table.concat(stdout_data, " ")
        if exit_code == 0 then
          vim.notify(string.format("✅ Sent (%.0fms)", elapsed_ms), vim.log.levels.INFO)
        else
          vim.notify("❌ " .. (output ~= "" and output or "Failed"), vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

-- Internal function to send text
---@param text string
function M._send_text(text)
  if not M.fsi_job then
    return
  end
  
  -- Send the text followed by ;; and newline to execute
  vim.fn.chansend(M.fsi_job, text .. ";;\n")
end

-- Send current line to FSI
function M.send_line_to_fsi()
  local line = vim.api.nvim_get_current_line()
  M.send_to_fsi(line)
end

-- Send visual selection to FSI
function M.send_selection_to_fsi()
  local util = require("config.util")
  local lines = util.GetVisualSelection()
  local text = table.concat(lines, "\n")
  M.send_to_fsi(text)
end

-- Export module functions
_G.FsiMcp = M

return {
  {
    "akinsho/toggleterm.nvim",
    optional = true,
    keys = {
      {
        "<leader>tf",
        function()
          _G.FsiMcp.toggle_fsi()
        end,
        desc = "Toggle FSI REPL (auto-detect)",
      },
      {
        "<leader>tm",
        function()
          _G.FsiMcp.toggle_fsi(true)
        end,
        desc = "Toggle FSI-MCP REPL",
      },
      {
        "<leader>td",
        function()
          _G.FsiMcp.toggle_fsi(false)
        end,
        desc = "Toggle Dotnet FSI REPL",
      },
    },
  },
}
