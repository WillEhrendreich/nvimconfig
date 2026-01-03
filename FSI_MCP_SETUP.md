# FSI-MCP-Server Setup for Neovim

This guide explains how to use `fsi-mcp-server` in your Neovim setup for F# development.

## What is fsi-mcp-server?

`fsi-mcp-server` is an enhanced F# Interactive (FSI) server that provides Model Context Protocol (MCP) capabilities, offering better integration and features compared to the standard `dotnet fsi`.

## Installation

### Install fsi-mcp-server

First, you need to install fsi-mcp-server. You can typically install it via:

```powershell
# Using dotnet tool (if available)
dotnet tool install -g fsi-mcp-server

# Or via npm (if it's packaged that way)
npm install -g fsi-mcp-server
```

Check if it's installed correctly:

```powershell
fsi-mcp-server --version
```

## How It Works

Your Neovim configuration now automatically detects and prefers `fsi-mcp-server` when available:

1. **Automatic Detection**: When you send F# code to the REPL (using `<M-CR>`), Neovim checks:
   - Is `fsi-mcp-server` available? → Use it
   - Otherwise → Fall back to standard `dotnet fsi` via Ionide

2. **Manual Terminal Control**: You can explicitly open FSI terminals:
   - `<leader>tf` - Auto-detect and use best available FSI
   - `<leader>tm` - Force use of fsi-mcp-server
   - `<leader>td` - Force use of standard dotnet fsi

## Key Mappings

### Existing (now enhanced)

- **`<M-CR>`** (Alt+Enter) in normal mode: Send current line to FSI REPL
- **`<M-CR>`** (Alt+Enter) in visual mode: Send selected lines to FSI REPL

These now prefer `fsi-mcp-server` when available!

### New Terminal Toggles

- **`<leader>tf`**: Toggle FSI REPL (auto-detects best option)
- **`<leader>tm`**: Toggle FSI-MCP REPL (forces fsi-mcp-server)
- **`<leader>td`**: Toggle Dotnet FSI REPL (forces standard fsi)

## Usage Example

### Basic Workflow

1. Open an F# file (`.fs` or `.fsx`)
2. Press `<leader>tf` to open the FSI REPL (will use fsi-mcp-server if installed)
3. Write some F# code:
   ```fsharp
   let add x y = x + y
   let result = add 5 3
   ```
4. In normal mode, put cursor on a line and press `<Alt-Enter>` to send it to REPL
5. Or select multiple lines in visual mode and press `<Alt-Enter>` to evaluate them

### Forcing Specific FSI Version

If you want to test with standard FSI even when fsi-mcp-server is installed:

1. Press `<leader>td` to open standard dotnet fsi
2. Then use `<Alt-Enter>` as usual (will use the open terminal)

## Configuration Files Modified

The following files were created/modified:

1. **`lua/plugins/fsi-mcp.lua`** (NEW)
   - Core functionality for fsi-mcp-server integration
   - Auto-detection logic
   - Terminal management
   - Send-to-REPL functions

2. **`lua/config/keymaps.lua`** (MODIFIED)
   - Updated `<M-CR>` mappings to prefer fsi-mcp-server
   - Falls back gracefully to Ionide's FSI if fsi-mcp-server isn't available

## Troubleshooting

### "fsi-mcp-server not found"

This means the executable isn't in your PATH. To fix:

1. Install fsi-mcp-server (see Installation section)
2. Ensure it's in your PATH:
   ```powershell
   $env:PATH
   ```
3. Restart Neovim

### Falls back to dotnet fsi

This is expected if fsi-mcp-server isn't installed. The setup gracefully falls back to standard FSI.

### Neither FSI works

Ensure you have .NET SDK installed:
```powershell
dotnet --version
```

## Advantages of fsi-mcp-server

When using fsi-mcp-server over standard FSI, you get:

- Better integration with MCP-compatible tools
- Enhanced REPL capabilities
- Improved code completion context
- Better error reporting

## Reverting to Standard FSI

If you want to completely disable fsi-mcp-server preference:

1. Edit `lua/config/keymaps.lua`
2. Find the lines checking `vim.fn.executable("fsi-mcp-server")`
3. Comment them out to always use Ionide's standard FSI

Or simply don't install fsi-mcp-server - the configuration will automatically use standard FSI.

## Additional Resources

- [Ionide Documentation](https://ionide.io/)
- F# Interactive: `dotnet fsi --help`
- Your Ionide config: `lua/plugins/ionide.lua`
