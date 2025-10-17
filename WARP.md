# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a comprehensive Neovim configuration built on LazyVim, designed primarily for Windows development with extensive plugin integrations and custom tooling. The configuration includes automatic Chocolatey package management, multi-GUI support (FVim, Neovide), and optimized development workflows.

## Core Architecture

### Configuration Structure
- **init.lua**: Entry point with Windows-specific setup, Chocolatey integration, GUI configurations
- **lua/config/**: Core configuration modules
  - `lazy.lua`: Plugin manager setup with custom dev paths and icons
  - `util.lua`: Extensive utility functions for file operations, terminals, environment handling
  - `options.lua`, `keymaps.lua`, `autocmds.lua`: Standard LazyVim configuration
- **lua/plugins/**: Individual plugin configurations (50+ plugins)
- **packages.config**: Chocolatey packages required for development
- **lazyvim.json**: LazyVim extras configuration

### Key Features
- **Automatic dependency management** via Chocolatey integration
- **Multi-GUI support** with FVim and Neovide optimizations
- **Environment-aware configuration** using REPOS environment variable for local development
- **Custom terminal and float utilities** in `util.lua`
- **Windows PowerShell integration** with elevated permission detection

## Development Commands

### Plugin Management
```powershell
nvim --headless +"Lazy! sync" +qa    # Install/update all plugins
nvim +"Lazy"                         # Open plugin manager UI
```

### Code Quality
```powershell
stylua --check .                     # Check Lua formatting
stylua .                            # Format Lua files
luacheck lua/                       # Lint Lua code
```

### Testing Configuration
```powershell
nvim --clean -u init.lua            # Test configuration in clean state
nvim +checkhealth                   # Diagnose configuration issues
```

### Package Management
The configuration automatically manages Chocolatey packages defined in `packages.config`. Key executables checked:
- `7z`, `btm`, `choco`, `curl`, `docker`, `fzf`, `gdu`, `gh`, `git`, `lazygit`, `clang`, `npm`, `pwsh`, `python`, `rg`, `tree-sitter`, `wget`, `zig`

## Environment Setup

### Required Environment Variables
- `XDG_CONFIG_HOME`: `c:/.config`
- `XDG_DATA_HOME`: `c:/.local/share`
- `XDG_STATE_HOME`: `c:/.local/state`
- `NVIM_APPNAME`: `nvim`
- `REPOS`: Repository directory path (e.g., `c:/repos`)

### Prerequisites
- Neovim 0.11+
- PowerShell 7+ (pwsh) or Windows PowerShell
- C compiler 
- Chocolatey package manager (auto-installed if elevated)
- BOB for Neovim version management (recommended)

## Configuration Patterns

### Plugin Development Workflow
- Uses `dev.path` in lazy.nvim config to check local repos via REPOS environment variable
- `util.lua` provides functions for checking local plugin repositories
- Custom floating terminal utilities for testing and debugging

### Windows-Specific Adaptations
- PowerShell shell configuration with proper encoding
- Elevated permission detection for Chocolatey operations
- Path normalization for Windows/Unix compatibility
- Explorer integration for system operations

### Custom Utilities
The `util.lua` module provides extensive helper functions:
- Environment variable management
- Repository path resolution
- Floating terminal/command execution
- File system operations
- URL handling and browser integration

## Plugin Configuration

### Language Support
Configured for: Fsharp, csharp, C/C++ (clangd), TypeScript, Lua, JSON, Markdown, SQL, YAML, Docker, Git, Gleam

### Key Plugins
- **LazyVim**: Base configuration framework
- **Telescope**: Fuzzy finding
- **Neo-tree**: File explorer
- **blink.cmp**: Completion engine
- **Treesitter**: Syntax highlighting
- **LSP**: Language server integration
- **DAP**: Debug adapter protocol

### Custom Plugins
- **Choco.nvim**: Custom Chocolatey integration (embedded)
- Various development-focused plugins with Windows optimizations

## Troubleshooting

### Permission Issues
Run PowerShell as Administrator for Chocolatey operations. The configuration will prompt for elevated permissions when needed.

### Environment Path Issues
Ensure all required executables are in PATH or installed via Chocolatey. The configuration will attempt to install missing dependencies automatically.