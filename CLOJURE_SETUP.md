# Clojure Development in Neovim - Setup Guide

## Installation Instructions

### 1. Choose Your Build Tool

#### Option A: Clojure CLI (Recommended for Learning)
Install via Scoop:
```powershell
scoop install clojure
```

Or use Windows Installer: https://clojure.org/guides/install_clojure

Verify:
```powershell
clj --version
```

#### Option B: Leiningen (Traditional)
Install via Scoop:
```powershell
scoop install leiningen
```

Or download from: https://leiningen.org/

Verify:
```powershell
lein --version
```

### 2. Install Clojure LSP

Via Scoop (recommended):
```powershell
scoop install clojure-lsp
```

Or manually download from: https://github.com/clojure-lsp/clojure-lsp/releases

Verify:
```powershell
clojure-lsp --version
```

### 3. Build Parinfer Rust (Already configured in Neovim)

The plugin will automatically build on first load if Rust/Cargo is available (which you have).

### 4. Build Clojure-LSP Formatter (Optional but recommended)

For better formatting support:
```powershell
# With Clojure CLI
clj -M:format

# With Leiningen
lein format
```

## Creating a Project

### With Clojure CLI
```powershell
clj -M:new app my.learning
cd my.learning
```

### With Leiningen
```powershell
lein new app my-learning
cd my-learning
```

## Starting a REPL

### With Clojure CLI (Socket REPL)
```powershell
clj -r
```
Connects to localhost:50505

### With Leiningen
```powershell
lein repl
```
Connects to localhost:nREPL (auto-detected by Conjure)

## Neovim Configuration Files Added

Created `lua/plugins/clojure.lua` with:
- **Clojure LSP** - IntelliSense, refactoring, diagnostics
- **Conjure** - Interactive REPL evaluation (`:ConjureEvalCurrentForm`)
- **Parinfer** - Automatic structural editing
- **Vim-sexp** - S-expression manipulation
- **Treesitter** - Syntax highlighting

## Quick Start Workflow

### 1. Create a Clojure Project

**With Clojure CLI:**
```powershell
clj -M:new app my.learning
cd my.learning
```

**With Leiningen:**
```powershell
lein new app my-learning
cd my-learning
```

### 2. Start a REPL

**With Clojure CLI (Socket REPL on :50505):**
```powershell
clj -r
```

**With Leiningen (nREPL on dynamic port):**
```powershell
lein repl
```

Conjure auto-detects both Socket REPL and nREPL!

### 3. In Neovim

Open a Clojure file:
```bash
nvim src/my/learning.clj
```

Your LSP will auto-start. Conjure will auto-connect to the Socket REPL.

### Keyboard Shortcuts (Local Leader is Space + Space by default)

| Key | Action |
|-----|--------|
| `<space><space>ee` | Evaluate current form |
| `<space><space>eb` | Evaluate entire buffer |
| `<space><space>el` | View REPL log |
| `<space><space>sw` | Wrap in parentheses (sexp) |
| `<M-l>` / `<M-h>` | Move s-expression forward/backward |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |

## Testing the Setup

Create a test file `hello.clj`:

```clojure
(ns hello)

(defn greet [name]
  (str "Hello, " name "!"))

(greet "Clojure")
```

1. Start REPL: `clj -r` or `lein repl` in project directory
2. Open file in Neovim
3. Press `<space><space>ee` on the `(greet "Clojure")` line
4. Result should appear in Conjure log (`:ConjureEvalLog`)

## Recommended Learning Resources

- https://clojure.org/guides/learn/syntax - Official syntax guide
- https://4clojure.com/ - Interactive Clojure exercises
- https://exercism.org/tracks/clojure - Guided exercises

## Troubleshooting

### Conjure not connecting to REPL
- **With Clojure CLI**: Ensure REPL running with `clj -r` (port 50505)
- **With Leiningen**: Ensure REPL running with `lein repl` (nREPL auto-detected)
- Check logs: `:ConjureEvalLog`
- Verify Conjure found the REPL: `:ConjureClientState`

### Parinfer not working
- May need to rebuild: `:call v:lua.parinfer_rust.ensure_installed()`
- Or manually: `cargo build --release` in plugin directory

### LSP not starting
- Install clojure-lsp: `scoop install clojure-lsp`
- Check `:LspInfo` in Neovim
- Verify `clojure-lsp` is in PATH
- Works with both `project.clj` (Leiningen) and `deps.edn` (Clojure CLI)

## Project Setup

### With Leiningen (project.clj)
```clojure
(defproject my-learning "0.1.0-SNAPSHOT"
  :description "Learning Clojure in Neovim"
  :url "http://example.com"
  :license {:name "EPL-2.0"}
  :dependencies [[org.clojure/clojure "1.11.1"]]
  :repl-options {:port 50505}
  :main my-learning.core)
```

Then start REPL with: `lein repl`

### With Clojure CLI (deps.edn)

```edn
{:paths ["src"]
 :deps {org.clojure/clojure {:mvn/version "1.11.1"}}
 :aliases
 {:repl/socket {:extra-paths ["dev"]
                :jvm-opts ["-Dclojure.server.repl={:port,50505,:accept,clojure.core.server/repl}"]}}
```

Then start REPL with:
```powershell
clj -M:repl/socket
```

## Next Steps

1. Install either **Clojure CLI** or **Leiningen** (see steps above)
   - `scoop install clojure` — or —
   - `scoop install leiningen`
2. Install clojure-lsp: `scoop install clojure-lsp`
3. Restart Neovim to load the Clojure plugin
4. Create a test Clojure project
5. Start evaluating code interactively!

Enjoy learning Clojure! 🍀
