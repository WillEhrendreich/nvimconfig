# Clojure Development in Neovim - Setup Guide

## ✅ Current Installation Status

You now have:
- ✅ **Java 25 (OpenJDK)** — `C:\Program Files\OpenJDK\jdk-25`
- ✅ **Leiningen 2.12.0** — `C:\ProgramData\chocolatey\bin\lein.bat`
- ✅ **clojure-lsp** (standalone jar) — `C:\ProgramData\chocolatey\bin\clojure-lsp.bat`

## 🔧 Setup PATH (Required Before First Use)

### Option 1: Auto-Setup Script (Recommended)
```powershell
# Run this script to add Java and Clojure tools to PATH permanently
C:\.config\nvim\INSTALL_CLOJURE.ps1

# Then restart PowerShell/terminal
```

### Option 2: Manual PATH Setup
```powershell
# Run in PowerShell (Administrator)
[Environment]::SetEnvironmentVariable("Path", "C:\Program Files\OpenJDK\jdk-25\bin;C:\ProgramData\chocolatey\bin;" + [Environment]::GetEnvironmentVariable("Path", "User"), "User")

# Restart PowerShell/terminal for changes to take effect
```

### Verify Installation
```powershell
java -version
lein --version
clojure-lsp --version
```

All three should print version info without errors.

## Neovim Configuration Files Added

Created `lua/plugins/clojure.lua` with:
- **Clojure LSP** - IntelliSense, refactoring, diagnostics
- **Conjure** - Interactive REPL evaluation (`:ConjureEvalCurrentForm`)
- **Parinfer** - Automatic structural editing (builds on first load with Cargo)
- **Vim-sexp** - S-expression manipulation
- **Treesitter** - Syntax highlighting

## Quick Start Workflow

### 1. Create a Clojure Project

```powershell
lein new app my-learning
cd my-learning
```

### 2. Start a REPL

Inside your project directory:
```powershell
lein repl
```

This starts an nREPL (Conjure will auto-connect)

### 3. In Neovim

Open a Clojure file:
```bash
nvim src/my_learning/core.clj
```

Your LSP and REPL will auto-connect!

### Keyboard Shortcuts (Local Leader is Space + Space by default)

| Key | Action |
|-----|--------|
| `<Alt+Enter>` | Evaluate current form (matches F# convention) |
| `<Alt+Enter>` (visual) | Evaluate selection |
| `<space><space>eb` | Evaluate entire buffer |
| `<space><space>el` | View REPL log |
| `<space><space>sw` | Wrap in parentheses (sexp) |
| `<M-l>` / `<M-h>` | Move s-expression forward/backward |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |

## Testing the Setup

### 1. Setup PATH first (see above)

### 2. Create a test project:
```powershell
lein new app clojure-test
cd clojure-test
```

### 3. Edit `src/clojure_test/core.clj`:
```clojure
(ns clojure-test.core)

(defn greet [name]
  (str "Hello, " name "!"))

; Test in REPL with <space><space>ee
(greet "Clojure")
```

### 4. Start REPL:
```powershell
lein repl
```

### 5. In Neovim:
```bash
nvim src/clojure_test/core.clj
```

### 6. Evaluate:
- Position cursor on `(greet "Clojure")`
- Press `<Alt+Enter>` (same as F#)
- Result appears in Conjure log: `:ConjureEvalLog`

## Project Structure with Leiningen

```
my-learning/
├── project.clj          # Project configuration
├── src/
│   └── my_learning/
│       └── core.clj     # Main code
├── test/
│   └── my_learning/
│       └── core_test.clj
└── resources/
```

### project.clj Example
```clojure
(defproject my-learning "0.1.0-SNAPSHOT"
  :description "Learning Clojure in Neovim"
  :url "http://example.com"
  :license {:name "EPL-2.0"}
  :dependencies [[org.clojure/clojure "1.11.1"]]
  :main my-learning.core)
```

## Troubleshooting

### "java not found"
- Run the PATH setup script: `C:\.config\nvim\INSTALL_CLOJURE.ps1`
- Or manually add: `C:\Program Files\OpenJDK\jdk-25\bin` to your PATH
- Restart terminal after PATH changes

### "lein not found"
- Add `C:\ProgramData\chocolatey\bin` to PATH
- Verify: `cmd /c lein.bat --version`

### Conjure not connecting to REPL
- Ensure REPL running with `lein repl` inside project
- Check logs: `:ConjureEvalLog`
- Verify Conjure found REPL: `:ConjureClientState`
- Try refreshing: `:ConjureEval` from within a Clojure buffer

### Parinfer not working
- On first use, it needs to build: wait 30-60 seconds
- If build fails, check Cargo is installed: `cargo --version`
- Manual rebuild: `:call v:lua.parinfer_rust.ensure_installed()`

### LSP not starting
- Check clojure-lsp: `cmd /c clojure-lsp.bat --version`
- Check `:LspInfo` in Neovim to see server status
- Works with both `project.clj` (Leiningen) and `deps.edn` (Clojure CLI)

## Recommended Learning Resources

- https://clojure.org/guides/learn/syntax — Official syntax guide
- https://4clojure.com/ — Interactive Clojure exercises (great for learning!)
- https://exercism.org/tracks/clojure — Guided Clojure exercises
- https://www.braveclojure.com/ — Clojure from the Ground Up (free book)
- https://clojuredocs.org/ — API documentation with examples

## Next Steps

1. ✅ **Tools installed** (Java, Leiningen, clojure-lsp)
2. **Setup PATH** using the script or manual method above
3. **Restart Neovim** to load the Clojure plugin
4. **Create a test project** with `lein new app my-learning`
5. **Start learning!** Open a `.clj` file and start evaluating code with `<space><space>ee`

Enjoy learning Clojure! 🍀
