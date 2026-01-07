-- Configuration for FsiX MCP server integration (Integrated Architecture)
-- FsiX v0.2.0+ runs with MCP server ENABLED BY DEFAULT on port 37749
-- Single binary (fsix) with integrated MCP server
-- Use --no-mcp flag to disable MCP if you don't want it
-- When fsix is running, Neovim shares the same F# session with Copilot

local M = {}

-- MCP server configuration
M.MCP_PORT = 37749
M.MCP_URL = "http://localhost:" .. M.MCP_PORT
M.MCP_SESSION_ID = "default" -- Use "default" session to share with Copilot and interactive terminal
M.discovered_session = nil

-- Discover active fsix session by querying the MCP server
function M.discover_session()
  if M.discovered_session then
    return M.discovered_session
  end

  -- Try to discover session by attempting to connect
  local handle = io.popen(
    'pwsh -NoProfile -Command "try { $response = Invoke-WebRequest -Uri \\"http://localhost:37749/\\" -Method POST -Body \'{\\"jsonrpc\\":\\"2.0\\",\\"id\\":1,\\"method\\":\\"ping\\"}\' -ContentType \\"application/json\\" -Headers @{\\"Accept\\"=\\"application/json, text/event-stream\\"; \\"Mcp-Session-Id\\"=\\"discover\\"} -UseBasicParsing 2>&1; $response.Content } catch { $_.ErrorDetails.Message }" 2>nul'
  )

  if handle then
    local result = handle:read("*a")
    handle:close()

    -- Parse any error message that might contain session info
    -- For now, we'll use "cli-integrated" as discovered from fsix-get_fsi_status
    M.discovered_session = "cli-integrated"
    return M.discovered_session
  end

  return "cli-integrated" -- fallback
end

-- Get or create MCP session ID
function M.get_session_id()
  -- Try to discover active session first
  return M.discover_session()
end

-- Store FSI terminal info
M.fsi_buf = nil
M.fsi_win = nil
M.fsi_job = nil

-- Check if FsiX MCP server is available (running on localhost:37749)
---@return boolean
function M.is_fsi_mcp_available()
  -- Check if root endpoint responds
  local handle = io.popen(string.format("curl -s --max-time 1 %s/ 2>nul", M.MCP_URL))
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result:match("FsiX MCP Server") ~= nil
  end
  return false
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
    return { "fsix" } -- MCP enabled by default
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

-- Check if fsix-mcp is already running on port 37749
---@return boolean, number|nil
function M.is_fsi_mcp_server_running()
  -- Get the PID of the process listening on 37749
  local handle = io.popen(
    string.format(
      'pwsh -Command "Get-NetTCPConnection -LocalPort %d -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess"',
      M.MCP_PORT
    )
  )
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

-- Connect to existing fsix --mcp server (just verify it's running)
function M.connect_to_existing_fsi_server()
  local running, pid = M.is_fsi_mcp_server_running()
  if running then
    vim.notify(
      string.format("✅ Connected to existing FsiX MCP (PID: %d, port: %d)", pid, M.MCP_PORT),
      vim.log.levels.INFO
    )
    vim.notify("📤 Send code with Alt-Enter or <leader>ss", vim.log.levels.INFO)
    vim.notify("💡 Interactive REPL already available in fsix window", vim.log.levels.INFO)
    return true
  else
    vim.notify(string.format("❌ No FsiX MCP server found on port %d", M.MCP_PORT), vim.log.levels.ERROR)
    return false
  end
end

-- Note: With integrated fsix --mcp, the interactive REPL is already available
-- in the same window where you started fsix --mcp
-- This function is kept for compatibility but just shows a message
function M.attach_interactive_repl()
  local running, pid = M.is_fsi_mcp_server_running()
  if not running then
    vim.notify(
      string.format("❌ No FsiX MCP server running on port %d. Start with :FsixStartVisible first.", M.MCP_PORT),
      vim.log.levels.ERROR
    )
    return
  end

  vim.notify("💡 The fsix --mcp window already has an interactive REPL!", vim.log.levels.INFO)
  vim.notify("📝 Type directly in that window, or use Alt-Enter from any buffer", vim.log.levels.INFO)
  vim.notify("🔄 Both terminal input and Alt-Enter share the same session", vim.log.levels.INFO)
end

-- Open FSI terminal in a bottom split
---@param use_mcp? boolean Force use of FsiX.Mcp if true, force regular fsi if false, auto-detect if nil
function M.open_fsi(use_mcp)
  if M.is_fsi_open() then
    return
  end

  local cmd
  if use_mcp == true then
    if not M.is_fsi_mcp_available() then
      vim.notify(
        string.format("FsiX.Mcp not running on localhost:%d. Start with :FsixStart first.", M.MCP_PORT),
        vim.log.levels.ERROR
      )
      return
    end

    -- When using FsiX.Mcp, we don't need a local terminal - everything goes through HTTP
    vim.notify("✅ FsiX.Mcp available - use <space>ss to send code to shared session", vim.log.levels.INFO)
    return
  elseif use_mcp == false then
    if not M.is_dotnet_fsi_available() then
      vim.notify("dotnet fsi not found. Install dotnet SDK first.", vim.log.levels.ERROR)
      return
    end
    cmd = { "dotnet", "fsi" }
  else
    cmd = M.get_fsi_command()
    if not cmd then
      vim.notify("Neither fsix-mcp nor dotnet fsi found.", vim.log.levels.ERROR)
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
  vim.api.nvim_buf_set_name(
    M.fsi_buf,
    "FSI: " .. (use_mcp == true and "fsi-mcp-server" or use_mcp == false and "dotnet fsi" or "auto")
  )

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

-- Send text to FSI via the simple /exec endpoint (no session ID required)
---@param text string
function M.send_to_fsi(text)
  local start_time = vim.loop.hrtime()
  local timestamp = os.date("%H:%M:%S")
  vim.notify(string.format("📤 [%s] Sending to FsiX...", timestamp), vim.log.levels.INFO)

  -- Ensure code ends with ;;
  if not text:match(";;%s*$") then
    text = text .. ";;"
  end

  -- Use simple /exec endpoint that auto-routes to cli-integrated session
  local json_body = vim.fn.json_encode({ code = text })

  -- Use curl for simple HTTP POST
  local curl_cmd = {
    "curl",
    "-X", "POST",
    M.MCP_URL .. "/exec",
    "-H", "Content-Type: application/json",
    "-d", json_body,
    "--max-time", "10",
    "--silent", "--show-error"
  }

  local stdout_data = {}
  local stderr_data = {}

  vim.fn.jobstart(curl_cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        stdout_data = data
      end
    end,
    on_stderr = function(_, data)
      if data then
        stderr_data = data
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        local end_time = vim.loop.hrtime()
        local elapsed_ms = (end_time - start_time) / 1000000

        if exit_code == 0 then
          local stdout_str = table.concat(stdout_data, "\n")
          local ok, response = pcall(vim.fn.json_decode, stdout_str)
          if ok and response.success then
            vim.notify(string.format("✅ Sent to FsiX (%.0fms)", elapsed_ms), vim.log.levels.INFO)
          elseif ok then
            vim.notify(string.format("❌ FsiX error: %s", response.error or "unknown"), vim.log.levels.ERROR)
          else
            vim.notify(string.format("❌ Failed to parse response: %s", stdout_str), vim.log.levels.ERROR)
          end
        else
          local stderr_str = table.concat(stderr_data, "\n")
          vim.notify(string.format("❌ HTTP error (exit %d): %s", exit_code, stderr_str), vim.log.levels.ERROR)
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

-- Store terminal buffer numbers
M.daemon_buf = nil
M.mcp_buf = nil
M.fsi_interactive_buf = nil
M.daemon_win = nil
M.mcp_win = nil
M.fsi_interactive_win = nil

-- Check FsiX status (integrated MCP server)
function M.check_fsix_status()
  -- Check MCP server
  local mcp_running = M.is_fsi_mcp_available()

  if mcp_running then
    vim.notify(string.format("✅ FsiX MCP running on port %d", M.MCP_PORT), vim.log.levels.INFO)
    return true
  else
    vim.notify(
      string.format("❌ FsiX MCP not running on port %d. Use :FsixStart or :FsixStartVisible to start", M.MCP_PORT),
      vim.log.levels.ERROR
    )
    return false
  end
end

-- Start FsiX with MCP server (hidden window)
function M.start_fsix()
  -- Check if already running - if so, just connect
  local running, pid = M.is_fsi_mcp_server_running()
  if running then
    vim.notify(string.format("⚠️  FsiX MCP already running (PID: %d). Connected!", pid), vim.log.levels.WARN)
    M.connect_to_existing_fsi_server()
    return
  end

  vim.notify("🚀 Starting FsiX with MCP server...", vim.log.levels.INFO)

  -- Start fsix (MCP enabled by default) in detached mode
  local mcp_cmd = {
    "pwsh",
    "-NoProfile",
    "-Command",
    "Start-Process -FilePath 'pwsh' -ArgumentList '-NoExit', '-Command', 'fsix' -WindowStyle Hidden",
  }

  vim.fn.jobstart(mcp_cmd, { detach = true })

  -- Check status after startup
  vim.defer_fn(function()
    if M.check_fsix_status() then
      M.connect_to_existing_fsi_server()
    end
  end, 2000)
end

-- Start FsiX with MCP server in visible terminal in Neovim
function M.start_fsix_visible()
  -- Check if already running - if so, just connect
  local running, pid = M.is_fsi_mcp_server_running()
  if running then
    vim.notify(string.format("⚠️  FsiX MCP already running (PID: %d). Connected!", pid), vim.log.levels.WARN)
    M.connect_to_existing_fsi_server()
    return
  end

  vim.notify("🚀 Starting FsiX with visible terminal...", vim.log.levels.INFO)

  -- Create terminal for MCP server (full bottom split)
  vim.cmd("botright split")
  vim.cmd("resize 15")
  local mcp_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, mcp_buf)

  -- Start fsix (MCP enabled by default) in terminal
  vim.fn.termopen("fsix", {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.notify("❌ FsiX MCP exited with code " .. exit_code, vim.log.levels.ERROR)
      end
      M.mcp_buf = nil
      M.mcp_win = nil
    end,
  })

  vim.api.nvim_buf_set_name(mcp_buf, "FsiX MCP (Interactive + HTTP)")
  M.mcp_buf = mcp_buf
  M.mcp_win = vim.api.nvim_get_current_win()

  -- Go back to previous window
  vim.cmd("wincmd p")

  -- Check status after startup
  vim.defer_fn(function()
    M.check_fsix_status()
    vim.notify(
      string.format("✨ FsiX MCP ready on port %d! Send code with Alt-Enter or type directly", M.MCP_PORT),
      vim.log.levels.INFO
    )
  end, 2000)
end

-- Toggle FsiX terminal window
function M.toggle_fsix_windows()
  local mcp_visible = M.mcp_win and vim.api.nvim_win_is_valid(M.mcp_win)

  if mcp_visible then
    -- Hide window
    vim.api.nvim_win_close(M.mcp_win, false)
    M.mcp_win = nil
    vim.notify("👁️  FsiX MCP terminal hidden", vim.log.levels.INFO)
  else
    -- Show window if buffer exists
    if M.mcp_buf and vim.api.nvim_buf_is_valid(M.mcp_buf) then
      vim.cmd("botright split")
      vim.cmd("resize 15")
      M.mcp_win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(M.mcp_win, M.mcp_buf)
      vim.cmd("wincmd p")
      vim.notify("👁️  FsiX MCP terminal visible", vim.log.levels.INFO)
    else
      vim.notify("⚠️  No FsiX MCP terminal found. Use :FsixStartVisible first.", vim.log.levels.WARN)
    end
  end
end

-- Stop FsiX MCP (kill process on port 37749)
function M.stop_fsix()
  vim.notify("🛑 Stopping FsiX MCP...", vim.log.levels.INFO)

  -- Kill processes on port 37749
  vim.fn.system(
    string.format(
      'pwsh -Command "Get-NetTCPConnection -LocalPort %d -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }"',
      M.MCP_PORT
    )
  )

  vim.defer_fn(function()
    vim.notify("✅ FsiX MCP stopped", vim.log.levels.INFO)
  end, 500)
end

-- Send visual selection to FSI
function M.send_selection_to_fsi()
  -- Exit visual mode to set marks
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)

  -- Get visual selection marks
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  -- Get lines from buffer
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)

  -- If single line, handle column selection
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
  else
    -- Trim first and last line based on column positions
    if start_pos[3] > 1 then
      lines[1] = string.sub(lines[1], start_pos[3])
    end
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  end

  local text = table.concat(lines, "\n")

  -- DEBUG: Show exactly what we're sending
  vim.notify(
    "📤 NEOVIM SENDING:\n─────────────────────────────────\n"
      .. text
      .. "\n─────────────────────────────────",
    vim.log.levels.INFO
  )

  M.send_to_fsi(text)
end

-- Export module functions
_G.FsiMcp = M

-- Create user commands
vim.api.nvim_create_user_command("FsixConnect", function()
  M.connect_to_existing_fsi_server()
end, { desc = "Connect to existing FsiX MCP server" })

vim.api.nvim_create_user_command("FsixAttachInteractive", function()
  M.attach_interactive_repl()
end, { desc = "Show info about interactive REPL (it's already in the fsix window)" })

vim.api.nvim_create_user_command("FsixStatus", function()
  M.check_fsix_status()
end, { desc = "Check FsiX MCP status" })

vim.api.nvim_create_user_command("FsixStart", function()
  M.start_fsix()
end, { desc = "Start FsiX with MCP server (hidden)" })

vim.api.nvim_create_user_command("FsixStartVisible", function()
  M.start_fsix_visible()
end, { desc = "Start FsiX with MCP server (visible terminal)" })

vim.api.nvim_create_user_command("FsixToggle", function()
  M.toggle_fsix_windows()
end, { desc = "Toggle FsiX MCP terminal visibility" })

vim.api.nvim_create_user_command("FsixStop", function()
  M.stop_fsix()
end, { desc = "Stop FsiX MCP" })

vim.api.nvim_create_user_command("FsixRestart", function()
  M.stop_fsix()
  vim.defer_fn(function()
    M.start_fsix()
  end, 1000)
end, { desc = "Restart FsiX MCP" })

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
        "<leader>xc",
        function()
          _G.FsiMcp.connect_to_existing_fsi_server()
        end,
        desc = "FsiX: Connect to Existing Server",
      },
      {
        "<leader>xi",
        function()
          _G.FsiMcp.attach_interactive_repl()
        end,
        desc = "FsiX: Attach Interactive REPL",
      },
      {
        "<leader>xs",
        function()
          _G.FsiMcp.check_fsix_status()
        end,
        desc = "FsiX: Check Status",
      },
      {
        "<leader>xS",
        function()
          _G.FsiMcp.start_fsix()
        end,
        desc = "FsiX: Start (Hidden)",
      },
      {
        "<leader>xV",
        function()
          _G.FsiMcp.start_fsix_visible()
        end,
        desc = "FsiX: Start (Visible)",
      },
      {
        "<leader>xt",
        function()
          _G.FsiMcp.toggle_fsix_windows()
        end,
        desc = "FsiX: Toggle Terminal Windows",
      },
      {
        "<leader>xk",
        function()
          _G.FsiMcp.stop_fsix()
        end,
        desc = "FsiX: Stop MCP Server",
      },
      {
        "<leader>xr",
        function()
          _G.FsiMcp.stop_fsix()
          vim.defer_fn(function()
            _G.FsiMcp.start_fsix()
          end, 1000)
        end,
        desc = "FsiX: Restart",
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
