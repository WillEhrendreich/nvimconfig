# FSI Session Sharing - The Real Solution

## The Problem

When Neovim runs `fsi-mcp-server` via `termopen()`, it creates a **new FSI session** every time. This means:
- Neovim's FSI session: `9f292bd8`
- Copilot's FSI session: `92958d60`
- **They're NOT sharing the same REPL!**

## Why This Happens

`termopen()` **spawns a new process** - it can't "connect" to an existing one. Each client that runs `fsi-mcp-server` gets its own isolated FSI session.

## The Solution

**Run ONE fsi-mcp-server as a background service**, then have all clients connect to it via MCP (HTTP/SSE).

### Architecture

```
┌─────────────────────────────────────┐
│   Single fsi-mcp-server Process    │
│   (Background service on :5020)     │
│                                     │
│   One shared FSI session: abc123    │
└──────────┬─────────────┬────────────┘
           │             │
           │             │
    ┌──────▼─────┐  ┌───▼────────┐
    │  Neovim    │  │  Copilot   │
    │  (MCP      │  │  (MCP      │
    │   client)  │  │   client)  │
    └────────────┘  └────────────┘
```

### Implementation Steps

#### 1. Start fsi-mcp-server Once (Background)

```powershell
# PowerShell - start as background service
Start-Process -FilePath "fsi-mcp-server.exe" -WindowStyle Hidden
```

Or in Neovim:
```vim
:FsiMcpStart
```

#### 2. Neovim Connects via MCP Client

Instead of `termopen("fsi-mcp-server")`, Neovim should:
- Check if server is running (port 5020)
- If not, start it once as detached process
- Send code via HTTP POST to `http://localhost:5020/mcp`

#### 3. Copilot Connects via MCP (Already Done!)

Copilot CLI already connects properly via:
```json
{
  "fsi-mcp": {
    "url": "http://localhost:5020/sse",
    "type": "http"
  }
}
```

## Current Neovim Limitation

The current `fsi-mcp.lua` uses `termopen()` which:
- ✅ Gives you an interactive terminal
- ❌ Creates a NEW session each time
- ❌ Can't share with other clients

**Trade-off**: 
- **Option A**: Keep terminal experience, lose session sharing
- **Option B**: Use MCP client, gain session sharing, lose terminal interactivity

## Recommended Hybrid Approach

1. **Start fsi-mcp-server once** as a background service (manually or via `:FsiMcpStart`)
2. **In Neovim**: Use terminal view for DISPLAY only (readonly)
3. **Send code**: Use MCP client to send to shared session
4. **Everyone sees**: All clients (Neovim + Copilot) work in same FSI session

## Files Created

- `fsi-mcp-client.lua`: New MCP client that connects to existing server
- Modified `fsi-mcp.lua`: Warns when server already running

## Next Steps

To enable true sharing, you need to:
1. Start fsi-mcp-server once: `:FsiMcpStart`
2. Check status: `:FsiMcpStatus`  
3. Both Neovim and Copilot connect to same session
4. Code sent by either appears in both!

## Alternative: Accept Separate Sessions

If you prefer the terminal experience over sharing:
- Keep current setup
- Neovim has its own FSI
- Copilot has its own FSI
- Use them independently for different purposes
