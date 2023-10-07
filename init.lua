local function fileExists(filePath)
  local file = io.open(filePath, "r")
  if file then
    file:close()
    return true
  end
  return false
end

local function getFileLastModified(filePath)
  local fileInfo = vim.loop.fs_stat(filePath)
  if fileInfo then
    return fileInfo.mtime.sec
  end
  return nil
end

local function isFileOlderThanOneDay(filePath)
  local lastModified = getFileLastModified(filePath)
  -- vim.notify(filePath .. "LastModified: " .. vim.inspect(lastModified))
  if lastModified then
    local currentTime = os.time()
    local oneDayInSeconds = 24 * 60 * 60
    return lastModified < (currentTime - oneDayInSeconds)
  end
  return false
end

local function runCommandIfFileOlderThanOneDay(filePath, command)
  if (not fileExists(filePath)) or isFileOlderThanOneDay(filePath) then
    -- vim.notify("executing {" .. command .. "}")
    vim.fn.system(command)
  else
    -- vim.notify("file {" .. filePath .. "} was last modified in the last day, keeping it. ")
  end
end

local function extractPackageId(inputString)
  local pattern = '<package id="([^"]-)"'
  local packageName = inputString:match(pattern)
  return packageName
end

function UseChocoToInstallAllTheThings()
  -- local currentPackagesExportPath = "c:\\temp\\packages.config"
  local currentPackagesExportPath = "c:/temp/packages.config"
  local currentPackagesConfig = vim.fs.find("packages.config", { path = "c:\\temp\\" })[1] or ""
  if not currentPackagesConfig == currentPackagesExportPath then
    -- vim.notify("running choco Export to " .. currentPackagesExportPath)
    vim.fn.system("choco export " .. currentPackagesExportPath)
  else
    -- vim.notify("running choco export if the file is missing or older than a day " .. currentPackagesExportPath)
    runCommandIfFileOlderThanOneDay(currentPackagesExportPath, "choco export " .. currentPackagesExportPath)
  end

  local chocoPackagesConfig = vim.fs.find("packages.config", { path = vim.fn.stdpath("config") })[1] or ""
  -- vim.notify(
  --   "found packages.config in config dir that had these packages:\n" .. vim.inspect(installsFromPackagesConfig)
  -- )
  local linesForMissingPackagesConfig = {
    [[ <?xml version="1.0" encoding="utf-8"?>]],
    [[<packages>]],
    [[ <package id="7zip" />]],
    [[ <package id="bottom" />]],
    [[ <package id="chocolatey" />]],
    [[ <package id="curl" />]],
    [[ <package id="docker" />]],
    [[ <package id="fzf" />]],
    [[ <package id="gdu" />]],
    [[ <package id="gh" />]],
    [[ <package id="git" />]],
    [[ <package id="github-desktop" />]],
    [[ <package id="gzip" />]],
    [[ <package id="ilspy" />]],
    [[ <package id="lazygit" />]],
    [[ <package id="llvm" />]],
    [[ <package id="nerd-fonts-JetBrainsMono" />]],
    [[ <package id="nodejs" />]],
    [[ <package id="notepadplusplus" />]],
    [[ <package id="powertoys" />]],
    [[ <package id="pwsh" />]],
    [[ <package id="ripgrep" />]],
    [[ <package id="SQLite" />]],
    [[ <package id="tree-sitter" />]],
    [[ <package id="Wget" />]],
    [[ <package id="zig" />]],
    [[</packages>]],
  }
  if chocoPackagesConfig == "" then
    vim.fn.writefile(linesForMissingPackagesConfig, vim.fn.stdpath("config") .. "/packages.config")
  end
  chocoPackagesConfig = vim.fn.stdpath("config") .. "/packages.config"
  local allPackagesLinesFromDistro = {}
  for i, p in ipairs(vim.fn.readfile(chocoPackagesConfig, "")) do
    table.insert(allPackagesLinesFromDistro, extractPackageId(p))
  end

  local allPackagesLinesFromCurrent = {}
  for i, p in ipairs(vim.fn.readfile(currentPackagesExportPath, "")) do
    table.insert(allPackagesLinesFromCurrent, extractPackageId(p))
  end

  -- local installsFromPackagesConfig = {}
  local differences = {}
  for i, p in ipairs(allPackagesLinesFromDistro) do
    if not vim.tbl_contains(allPackagesLinesFromCurrent, p) then
      local chocoPackage = extractPackageId(p)
      table.insert(differences, chocoPackage)
    end
  end

  if vim.tbl_count(differences) > 0 then
    vim.notify("Not included in current choco packages :" .. vim.inspect(differences))
  end
  local packageToExecutableName = {

    ["7zip"] = "7z",
    ["autohotkey"] = "autohotkey",
    ["bottom"] = "btm",
    ["chocolatey"] = "choco",
    ["curl"] = "curl",
    ["docker"] = "docker",
    ["docker-cli"] = "docker",
    ["dotnet"] = "dotnet",

    -- ["dotnet-6.0-desktopruntime"] = "dotnet ",
    -- ["dotnet-7.0-desktopruntime"] = "dotnet-7.0-desktopruntime",
    -- ["dotnet-7.0-sdk-4xx"] = "dotnet-7.0-sdk-2xx",
    -- ["dotnet-desktopruntime"] = "dotnet-desktopruntime",
    ["drawio"] = "drawio",
    ["fzf"] = "fzf",
    ["gdu"] = "gdu",
    ["gh"] = "gh",
    ["gimp"] = "gimp",
    ["git"] = "git",
    -- ["github-desktop"] = "github-desktop",
    ["groupy"] = "groupy",
    ["gzip"] = "gzip",
    ["ilspy"] = "ilspy",
    -- ["jetbrainsmono"] = "jetbrainsmono",
    ["lazygit"] = "lazygit",
    ["llvm"] = "clang",
    ["messenger"] = "messenger",
    ["mingw"] = "gcc",
    -- ["nerd-fonts-DelugiaMono-Powerline"] = "nerd-fonts-DelugiaMono-Powerline",
    -- ["nerd-fonts-Hack"] = "nerd-fonts-Hack",
    -- ["nerd-fonts-JetBrainsMono"] = "nerd-fonts-JetBrainsMono",
    -- ["nerd-fonts-ProggyClean"] = "nerd-fonts-ProggyClean",
    -- ["nerd-fonts-SpaceMono"] = "nerd-fonts-SpaceMono",
    -- ["nerd-fonts-VictorMono"] = "nerd-fonts-VictorMono",
    ["nodejs"] = "npm",
    ["notepadplusplus"] = "notepad++",
    ["oh-my-posh"] = "oh-my-posh",
    ["opera-gx"] = "opera-gx",
    ["paint.net"] = "paint.net",
    ["powertoys"] = "powertoys",
    ["pwsh"] = "pwsh",
    ["python"] = "python",
    ["rainmeter"] = "rainmeter",
    ["ripgrep"] = "rg",
    ["SQLite"] = "SQLite3",
    ["steam"] = "steam",
    -- ["sumatrapdf"] = "sumatra",
    ["terminal-icons.powershell"] = "terminal-icons.powershell",
    ["tree-sitter"] = "tree-sitter",
    ["vcredist140"] = "vcredist140",
    ["vlc"] = "vlc",
    ["vscode"] = "code",
    ["Wget"] = "Wget",
    ["wiztree"] = "wiztree",
    ["zig"] = "zig",
  }

  local installsThatGetCalledFromNeovim = {
    "7zip",
    "bottom",
    "chocolatey",
    "curl",
    "docker",
    "fzf",
    "gdu",
    "gh",
    "git",
    "gzip",
    "lazygit",
    "llvm",
    "nodejs",
    "pwsh",
    "python",
    "ripgrep",
    "SQLite",
    "tree-sitter",
    "Wget",
    "zig",
  }
  local AllInstalled = true
  local notInstalled = {}
  for i, pack in ipairs(installsThatGetCalledFromNeovim) do
    local p = (packageToExecutableName[pack] or pack)
    -- vim.notify("checking for program: " .. p)
    local installed = vim.fn.executable(p) == 1
    -- local installed = vim.fn.system("choco " .. p) == 1

    if installed then
      -- vim.notify("program: " .. p .. " is installed and executable. ")
    else
      -- vim.notify(
      --   "program named: {"
      --     .. p
      --     .. "} is not executable. If it's intalled, then it's possible that it's parent directory is simply not included in the PATH variable. Adding it to the list of things chocolatey will try to install."
      -- )
      table.insert(notInstalled, pack)
    end
  end

  for i, pack in ipairs(differences) do
    -- local p = pack
    -- vim.notify("checking for program: " .. p)
    -- local installed = vim.fn.executable(p) == 1
    -- local installed = vim.fn.system("choco " .. p) == 1

    -- if installed then
    --   -- vim.notify("program: " .. p .. " is installed and executable. ")
    -- else
    -- vim.notify(
    --   "program named: {"
    --     .. p
    --     .. "} is not executable. If it's intalled, then it's possible that it's parent directory is simply not included in the PATH variable. Adding it to the list of things chocolatey will try to install."
    -- )
    table.insert(notInstalled, pack)
    -- end
  end
  if vim.tbl_count(notInstalled) > 0 then
    -- vim.notify(
    --   "Now going to call choco upgrade (which installs it if it's missing) on the following programs:\n"
    --     .. table.concat(notInstalled, "\n")
    -- )
    -- vim.fn.system("choco upgrade " .. table.concat(installs, " ") .. " -y --whatif" )
    -- local chocoCmd = "choco upgrade " .. table.concat(notInstalled, " ") .. " -y --whatif"
    local chocoCmd = { "choco", "upgrade" }
    vim.list_extend(chocoCmd, notInstalled)
    -- vim.notify("going to run " .. chocoCmd)
    -- vim.api.nvim
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("ChocoInstall", { clear = true }),
      -- filter = "",
      once = true,
      callback = function()
        vim.notify("going to run " .. vim.inspect(chocoCmd))
        local util = require("config.util")
        util.float_term(chocoCmd)
      end,
    })

    -- vim.fn.system(chocoCmd)
    -- vim.fn.system("refreshenv")
  else
    -- vim.notify("all listed programs are installed and executable from neovim.")
  end
end

function IsElevatedPowershell()
  local result = false
  result = string.match(
    vim.fn.system(
      "(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)"
    ),
    "True"
  ) == "True"
  -- result = vim.g["IsRunningElevatedPowershell"]
  -- vim.notify("ResultAfterCallback: " .. vim.inspect(result))

  if result == true then
    -- vim.notify("Running Powershell with elevated permissions.. ")
  else
    vim.notify("NOT Running Powershell with elevated permissions.. ")
    vim.notify("Current shell variable: " .. vim.inspect(vim.o.shell))
    -- vim.no
  end

  return result
end
-- UseChocoToInstallAllTheThings()

-- vim.notify("elevated returned: " .. vim.inspect(isElevated()))
function SetUpExternalExecutables()
  local isWindows = vim.fn.has("win32") == 1
  -- and vim.fn.executable("explorer") == 1 then
  if isWindows then
    -- vim.notify("Windows Detected")
    local shell = vim.o.shell
    local shellcmdflag = vim.o.shellcmdflag
    local shellredir = vim.o.shellredir
    local shellpipe = vim.o.shellpipe
    local shellquote = vim.o.shellquote
    local shellxquote = vim.o.shellxquote

    local pwshCoreAvailable = vim.fn.executable("pwsh")

    local isPowershell = vim.o.shell == "pwsh"
      or vim.o.shell == "pwsh.exe"
      or vim.o.shell == "powershell"
      or vim.o.shell == "powershell.exe"
    if not isPowershell then
      if pwshCoreAvailable then
        vim.o.shell = "pwsh"
      else
        vim.o.shell = "powershell"
      end
      vim.o.shellcmdflag =
        "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
      vim.o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
      vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
      vim.o.shellquote = ""
      vim.o.shellxquote = ""
    end
    isPowershell = vim.o.shell == "pwsh"
      or vim.o.shell == "pwsh.exe"
      or vim.o.shell == "powershell"
      or vim.o.shell == "powershell.exe"
    if isPowershell then
      -- vim.notify("powershell set as shell .. vim.o.shell: " .. vim.o.shell)
      local isElevated = IsElevatedPowershell()

      local hasChoco = vim.fn.executable("choco") == 1
      if hasChoco == true then
        -- vim.notify("chocolatey is installed, you rock.")
      else
        if isElevated then
          local choice = (
            vim.fn.inputlist({
              "No chocolatey package manager installed, would you like to download it? ",
              "1. Absolutely, take me there!",
              "2. No I don't like convenient things like package managers, I prefer to suffer.",
            })
          )
          vim.notify(type(choice))
          if choice == 1 then
            vim.notify(
              "You've chosen to download chocolatey, thereby winning at everything forever.. lets do that automatcally shall we? "
            )
            vim.fn.system(
              "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
            )

            local hasChoco2 = vim.fn.executable("choco") == 1
            vim.notify(
              "At this point choco should be installed! To really do this well, You're going to need to shut down the terminal, and restart this nvim distro. "
            )
            if hasChoco2 == true then
              vim.notify(
                "Nvim looked for choco as executable, and it looks great, continuing on to check all the needed installs for the system"
              )
            else
              vim.notify(
                "Nvim looked for choco as executable, couldn't find it, it looks like you really will have to restart your terminal before this continues so that environment variables can be reloaded."
              )
            end
            hasChoco = hasChoco2
          else
            vim.notify(
              "well... I guess you don't like nice things... do you perhaps put your shoes on the wrong feet for discomfort too?"
            )
          end
        end
      end
      if hasChoco == true then
        UseChocoToInstallAllTheThings()
      end
    else
      vim.notify(
        "not running powershell as main shell, currently set to: "
          .. vim.inspect(vim.o.shell)
          .. "\nfrankly I'm not able to do this choco install thing without elevated powershell.. so.. fix it."
      )
    end
    vim.o.shell = shell
    vim.o.shellcmdflag = shellcmdflag
    vim.o.shellredir = shellredir
    vim.o.shellpipe = shellpipe
    vim.o.shellquote = shellquote
    vim.o.shellxquote = shellxquote
  end
end

-- bootstrap lazy.nvim, LazyVim and your plugins
if vim.g.vscode then
else
  SetUpExternalExecutables()
  if vim.g.fvim_loaded then
    vim.o.guifont = "Iosevka NF:h17"
    -- vim.o.guifont = "JetBrainsMono NF:h14"
    vim.keymap.set(
      { "n", "x", "c", "i" },
      "<F11>",
      ":FVimToggleFullScreen <CR>",
      { desc = "toggle fullscreen", silent = true }
    )

    -- Cursor tweaks
    vim.cmd([[ FVimCursorSmoothMove v:true ]])

    --Background composition
    vim.cmd([[ FVimCursorSmoothBlink v:true ]])

    vim.cmd([[ FVimBackgroundComposition 'blur']]) -- 'none', 'transparent', 'blur' or 'acrylic'
    vim.cmd([[ FVimBackgroundOpacity 0.25 ]]) -- value between 0 and 1, default bg opacity.

    --  vim.cmd([[ FVimBackgroundAltOpacity 0.25        ]]) -- value between 0 and 1, non-default bg opacity.
    --  vim.cmd([[ FVimBackgroundImage 'C:/foobar.png'  ]]) -- background image
    --  vim.cmd([[ FVimBackgroundImageVAlign 'center'   ]]) -- vertial position, 'top', 'center' or 'bottom'
    --  vim.cmd([[ FVimBackgroundImageHAlign 'center'   ]]) -- horizontal position, 'left', 'center' or 'right'
    --  vim.cmd([[ FVimBackgroundImageStretch 'fill'    ]]) -- 'none', 'fill', 'uniform', 'uniformfill'
    --  vim.cmd([[ FVimBackgroundImageOpacity 0.01      ]]) -- value between 0 and 1, bg image opacity

    -- Title bar tweaks
    vim.cmd([[ FVimCustomTitleBar v:true ]]) -- themed with colorscheme

    -- Debug UI overlay
    -- vim.cmd([[ FVimDrawFPS v:true ]])

    -- Font tweaks
    vim.cmd([[ FVimFontAntialias v:true ]])
    vim.cmd([[ FVimFontAutohint v:true ]])
    vim.cmd([[ FVimFontHintLevel 'full' ]])
    vim.cmd([[ FVimFontLigature v:true ]])
    -- can be 'default', '14.0', '-1.0' etc.
    -- vim.cmd([[ FVimFontLineHeight '+1.0' ]])
    vim.cmd([[ FVimFontSubpixel v:true ]])
    -- Disable built-in Nerd font symbols
    vim.cmd([[ FVimFontNoBuiltinSymbols v:true ]])

    -- Try to snap the fonts to the pixels, reduces blur
    -- in some situations (e.g. 100% DPI).
    vim.cmd([[ FVimFontAutoSnap v:true ]])

    -- Font weight tuning, possible valuaes are 100..900
    vim.cmd([[ FVimFontNormalWeight 400 ]])

    vim.cmd([[ FVimFontBoldWeight 700 ]])

    -- Font debugging -- draw bounds around each glyph
    -- vim.cmd([[ FVimFontDrawBounds v:true ]])

    -- UI options (all default to v:false)
    -- external popup menu
    vim.cmd([[ FVimUIPopupMenu v:true ]])
    -- external wildmenu -- work in progress "
    vim.cmd([[ FVimUIWildMenu v:false ]])

    -- Keyboard mapping options
    -- disable unsupported sequence <S-Space>
    vim.cmd([[  FVimKeyDisableShiftSpace v:true ]])
    -- Automatic input method engagement in Insert mode
    vim.cmd([[  FVimKeyAutoIme v:true ]])
    -- Recognize AltGr. Side effect is that <C-A-Key> is then impossible
    vim.cmd([[  FVimKeyAltGr v:true ]])

    -- Default options (workspace-agnostic)
    -- Default window size in a new workspace
    -- vim.cmd([[ FVimDefaultWindowWidth 1600]])
    -- vim.cmd([[ FVimDefaultWindowHeight 900]])

    -- Detach from a remote session without killing the server
    -- If this command is executed on a standalone instance,
    -- the embedded process will be terminated anyway.
    --  vim.cmd([[ FVimDetach ]])
  end
  if vim.g.neovide then
    vim.keymap.set({ "n", "x", "c", "i" }, "<F11>", function()
      if vim.g.neovide_fullscreen == true then
        vim.g.neovide_fullscreen = false
      else
        vim.g.neovide_fullscreen = true
      end
    end)
    vim.g.transparency = 0.3

    vim.opt.guifont = { "JetBrainsMono NF", "h14" }
    vim.g.neovide_transparency = 0.5
    -- vim.g.neovide_background_color = "#0f1117" .. alpha()
    vim.g.neovide_floating_blur_amount_x = 22.0
    vim.g.neovide_floating_blur_amount_y = 20.0

    vim.g.neovide_scroll_animation_length = 0.3
    vim.g.neovide_theme = "auto"
    vim.g.neovide_refresh_rate = 75.0
    vim.g.neovide_refresh_rate_idle = 5.0
    vim.g.neovide_remember_window_size = true
    --
    vim.g.neovide_cursor_animation_length = 0.13
    --
    vim.g.neovide_cursor_antialiasing = true
    vim.g.neovide_cursor_animate_command_line = true
    --- vim redraw
    vim.cmd.redraw()
  end
end
require("config.lazy")
