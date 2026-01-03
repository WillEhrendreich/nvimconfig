-- FSI MCP Client - Connect to existing fsi-mcp-server via MCP
-- This allows true session sharing between Neovim and other MCP clients

local M = {}

M.server_url = "http://localhost:5020"
M.agent_name = "neovim"

-- Check if fsi-mcp-server is running
---@return boolean
function M.is_server_running()
  local handle = io.popen('powershell -Command "Get-NetTCPConnection -LocalPort 5020 -ErrorAction SilentlyContinue | Select-Object -First 1"')
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result:find("5020") ~= nil
  end
  return false
end

-- Start fsi-mcp-server as a background service if not running
function M.ensure_server_running()
  if M.is_server_running() then
    vim.notify("✅ fsi-mcp-server already running on :5020", vim.log.levels.INFO)
    return true
  end
  
  vim.notify("🚀 Starting shared fsi-mcp-server...", vim.log.levels.INFO)
  
  -- Start fsi-mcp-server in background (detached)
  vim.fn.jobstart({"fsi-mcp-server"}, {
    detach = true,
    cwd = "C:\\fsi-mcp",
  })
  
  -- Wait for server to start
  vim.wait(3000, function() return M.is_server_running() end, 100)
  
  if M.is_server_running() then
    vim.notify("✅ Shared fsi-mcp-server started on :5020", vim.log.levels.INFO)
    return true
  else
    vim.notify("❌ Failed to start fsi-mcp-server", vim.log.levels.ERROR)
    return false
  end
end

-- Send F# code to the shared FSI session via direct stdin write
---@param code string
function M.send_code(code)
  if not M.is_server_running() then
    vim.notify("❌ fsi-mcp-server not running. Use :FsiMcpStart", vim.log.levels.ERROR)
    return
  end
  
  -- Ensure code ends with ;;
  if not code:match(";;%s*$") then
    code = code .. ";;"
  end
  
  -- Use the fsi-mcp-stdin tool that sends directly to FSI's stdin
  -- This is simpler than using MCP JSON-RPC
  
  -- Create a temp file with the code
  local temp_file = vim.fn.tempname() .. ".fsx"
  local f = io.open(temp_file, "w")
  if f then
    f:write(code)
    f:close()
    
    -- Use PowerShell to send via named pipe or HTTP
    -- For now, we'll write to FSI's stdin via echo piping
    -- This is a workaround - ideally use proper MCP client
    
    local cmd = string.format(
      'powershell -Command "Get-Content \'%s\' | Out-File -Encoding ASCII -FilePath \\\\.\\pipe\\fsi-input"',
      temp_file
    )
    
    -- Alternative: Just notify user to manually copy-paste for now
    vim.notify("📤 Code prepared. FSI MCP doesn't expose simple HTTP endpoint.", vim.log.levels.WARN)
    vim.notify("Code:\n" .. code, vim.log.levels.INFO)
    
    -- Clean up
    os.remove(temp_file)
  end
end

-- Create user commands
vim.api.nvim_create_user_command("FsiMcpStart", function()
  M.ensure_server_running()
end, { desc = "Start shared fsi-mcp-server" })

vim.api.nvim_create_user_command("FsiMcpStatus", function()
  if M.is_server_running() then
    vim.notify("✅ Shared fsi-mcp-server running on :5020", vim.log.levels.INFO)
  else
    vim.notify("❌ fsi-mcp-server not running. Use :FsiMcpStart", vim.log.levels.WARN)
  end
end, { desc = "Check fsi-mcp-server status" })

_G.FsiMcpClient = M

return {
  "nvim-lua/plenary.nvim", -- Required
}
