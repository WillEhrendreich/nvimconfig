local fn = vim.fn
local tc = vim.tbl_contains
if not vim.g["LastDotnetProjectRootPath"] then
  vim.g["LastDotnetProjectRootPath"] = ""
end
if not vim.g["LastDotnetDllPath"] then
  vim.g["LastDotnetDllPath"] = ""
end
if not vim.g["DotnetStartupProjectPath"] then
  vim.g["DotnetStartupProjectPath"] = ""
end
if not vim.g["LastDotnetProjectFileName"] then
  vim.g["LastDotnetProjectFileName"] = ""
end
if not vim.g["LastDotnetProjectFileExtension"] then
  vim.g["LastDotnetProjectFileExtension"] = ""
end

LastDotnetProjectRootPath = vim.g["LastDotnetProjectRootPath"]
LastDotnetDllPath = vim.g["LastDotnetDllPath"]
DotnetStartupProjectPath = vim.g["DotnetStartupProjectPath"]
LastDotnetProjectFileName = vim.g["LastDotnetProjectFileName"]
LastDotnetProjectFileExtension = vim.g["LastDotnetProjectFileExtension"]

local function first_to_upper(str)
  return str:gsub("^%l", string.upper)
end
function FindRoot(ignored_lsp_servers, bufnr)
  local b = bufnr or 0
  -- Get lsp client for current buffer
  -- local bufDir = Lsppath.GetDirForBufnr(bufnr)
  local ignore = ignored_lsp_servers or {}
  -- vim.notify(vim.inspect(ignore) .. "are being ignored when finding root")
  -- u
  -- vim.notify(vim.inspect(b) .. " is the bufnumber with filename " .. Lsppath.GetBaseFilenameForBufnr(b))
  local buf_ft = vim.api.nvim_buf_get_option(b, "filetype")
  local result
  local clients = vim.lsp.get_active_clients({
    bufnr = b,
  })
  local i = ignore or {}
  for _, c in pairs(clients) do
    local cname = c.name
    -- LspNotify("client name is " .. (cname or "not found"))
    -- local bufname = vim.api.nvim_buf_get_name(bufnr)
    -- LspNotify("buf name is " .. (bufname or "not found"))
    -- local lspConfigForClient = re 'lspconfig.configs'[cname]
    -- LspNotify("config for " .. (cname or "not found") .. " is " .. vim.inspect(lspConfigForClient or " not found.."))
    local filetypes = c.config.filetypes
    if filetypes and vim.tbl_contains(filetypes, buf_ft) then
      if not vim.tbl_contains(i, cname) then
        -- local rootDirFunction = lspConfigForClient.get_root_dir
        -- LspNotify("lsp root dir function is " .. vim.inspect(rootDirFunction or "not found"))
        local activeConfigRootDir = c.config.root_dir
        -- local rootresult
        -- LspNotify("active root dir is " .. (activeConfigRootDir or "not found"))
        -- if rootDirFunction then
        -- rootresult = rootDirFunction(bufname)
        -- if rootresult and not rootresult == nil and not rootresult == "" then LspNotify("result of rootDirFunction is: "
        --     ..
        --     upperDriveLetter((v.path.AppendSlash(rootresult))))
        -- end
        -- end
        if activeConfigRootDir then
          result = first_to_upper(StringReplace(activeConfigRootDir, "\\", "/"))
          -- LspNotify("active root dir is " .. (result or "not found"))
          -- else
          -- result = upperDriveLetter((v.path.AppendSlash(rootresult) )))
        end
      end
    end
  end
  -- return upperDriveLetter((v.path.AppendSlash(result or bufDir)))
  return result
end

--- Run a shell command and capture the output and if the command succeeded or failed
-- @param cmd the terminal command to execute
-- @param show_error boolean of whether or not to show an unsuccessful command as an error to the user
-- @return the result of a successfully executed command or nil
function RunShellCmd(cmd, show_error)
  if vim.fn.has("win32") == 1 then
    cmd = { "cmd.exe", "/C", cmd }
  end
  local result = vim.fn.system(cmd)
  local success = vim.api.nvim_get_vvar("shell_error") == 0
  if not success and (show_error == nil or show_error) then
    vim.api.nvim_err_writeln("Error running command: " .. cmd .. "\nError message:\n" .. result)
  end
  return success and result:gsub("[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "") or nil
end

--
-- Does package.json file contain speficied configuration or dependency?
-- (e.g. "prettier")
-- ILspORTANT! package.json file is found only if lsp root
-- where package.json is or vim-rooter (or something similar) is activated
--
function IsInPackageJson(field)
  local root = FindRoot()
  if vim.fn.filereadable(root .. "/package.json") ~= 0 then
    local package_json = vim.fn.json_decode(vim.fn.readfile("package.json"))
    if package_json == nil then
      return false
    end
    if package_json[field] ~= nil then
      return true
    end
    local dev_dependencies = package_json["devDependencies"]
    if dev_dependencies ~= nil and dev_dependencies[field] ~= nil then
      return true
    end
    local dependencies = package_json["dependencies"]
    if dependencies ~= nil and dependencies[field] ~= nil then
      return true
    end
  end
  return false
end

function IsWebProject()
  return (vim.fn.glob("package.json") ~= "" or vim.fn.glob("yarn.lock") ~= "" or vim.fn.glob("node_modules") ~= "")
end

function IsArduinoProject()
  return (vim.fn.glob("*.ino") ~= "")
end

function DecodeJsonFile(filename)
  if vim.fn.filereadable(filename) == 0 then
    return nil
  end
  return vim.fn.json_decode(vim.fn.readfile(filename))
end

function StringEndsWith(str, ending)
  return ending == "" or string.sub(str, -string.len(ending)) == ending
end

function StringReplace(x, to_replace, replace_with)
  if type(x) == "string" or type(x) == "number" then
    return string.gsub(x, to_replace, replace_with)
  end
  if type(x) == "table" then
    for key, value in pairs(x) do
      x[key] = StringReplace(value, to_replace, replace_with)
    end
  end
  return x
end

function GetCurrentBufDirname()
  local p = vim.fs.dirname(string.sub(vim.uri_from_bufnr(vim.api.nvim_get_current_buf()), 9))
  return p
end

function GetDotnetProjectPath()
  local dirname = GetCurrentBufDirname()
  local projectName = LastDotnetProjectFileName
  local ext = LastDotnetProjectFileExtension
  local path
  local nearestProj
  local files = vim.fn.readdir(dirname)
  for _, file in ipairs(files) do
    if not nearestProj then
      if StringEndsWith(file, "proj") then
        -- local full_path = dirname .. '/' .. file
        nearestProj = string.sub(file, 0, string.len(file) - 7)
        ext = string.sub(file, string.len(file) - 6)
        -- nearestProj = string.sub(n, string.len(dirname), string.len(n) - 8)
      end
    end
  end
  if not nearestProj then
    nearestProj = ""
  end
  if not projectName or projectName == "" then
    projectName = nearestProj
  end
  if not LastDotnetProjectFileName or LastDotnetProjectFileName == "" then
    vim.g["LastDotnetProjectFileName"] = projectName
  end
  if not LastDotnetProjectFileExtension or LastDotnetProjectFileExtension == "" then
    vim.g["LastDotnetProjectFileExtension"] = ext
  end
  path = dirname .. "/" .. projectName .. ext
  if not DotnetStartupProjectPath or DotnetStartupProjectPath == "" then
    vim.g["DotnetStartupProjectPath"] = path
  end

  path = DotnetStartupProjectPath or ""
  if path == "" then
    -- vim.notify("StartupProjectPath was either blank or nil")
    path = GetCurrentBufDirname()
  end

  local function request(initialPath)
    local response = vim.fn.input({ prompt = "Path to project: ", default = initialPath, completion = "file" })
    if not StringEndsWith(response, "proj") then
      response = vim.fn.input({
        "Given path didn't end with 'proj'.. " .. "\nPlease provide an actual path to the startup project: \n",
        initialPath,
        "file",
      })
    end
    if not StringEndsWith(response, "proj") then
      vim.notify(
        "Fine.. BE that way.. You don't want to give an actual path? I'm setting the path to ERROR.BADproj, and you will get errors.. but it's out of my hands now. *tsk tsk.* you try to help someone.. geeez.. "
      )
      response = "ERROR.BADproj"
    end
    return response
  end
  if vim.fn.confirm("Do you want to change the path to project?\n" .. vim.inspect(path), "&yes\n&no", 2) == 1 then
    path = request(GetCurrentBufDirname())
  end
  print("Path to startup project is set to: " .. path)
  -- Lspdebug.GetConfig()
  -- local path =  vim.fn.input({ "Path to your startup *proj file ", LspStartupProjectPath, "file" })
  vim.g["DotnetStartupProjectPath"] = path
  return path
end

function OpenFileInNewBuffer(f)
  local file_exists = os.rename(f, f)
  if not file_exists then
    local file = io.open(f, "w")
    if file then
      file:close()
    end
  end
  local choice = vim.fn.confirm("Do you want to open the file\n" .. f .. "\nin a new buffer? \n", "&yes\n&no", "y")
  if choice == "y" then
    local cmd = "vnew " .. f
    vim.cmd.vnew(cmd)
  end
  -- if  vim.fn.confirm("Do you want to open the file " .. f .. " ?\n", "&yes\n&no", 2) == 1 then vim. vim.fn.bufload(f) end
end

function DotnetBuildRelease(p)
  -- local logfile = "c:/temp/dotnet-release-Log.log"
  --   local cmd = "dotnet build " .. p .. " -c release *> " .. logfile
  local cmd = "dotnet build " .. p .. " -c Release"
  print("Building ... ")
  -- print("Cmd to execute: " .. cmd)
  local f = os.execute(cmd)
  if f == 0 then
    print("\nBuild Release: ✔️ ")
  else
    print("\nBuild Release failed: ❌ (code: " .. f .. ")")
    --    LspOpenFileInNewBuffer(logfile)
  end
  return f
end

function DotnetBuildDebug(p)
  -- local logfile = "c:/temp/dap-debug-nvim-log"
  --   local cmd = "dotnet build " .. p .. " -c Debug *> " .. logfile
  local cmd = "dotnet build " .. p .. " -c Debug"
  print("Building ... ")
  -- print("Cmd to execute: " .. cmd)
  local f = os.execute(cmd)
  if f == 0 then
    print("\nBuild debug: ✔️ ")
  else
    print("\nBuild debug failed: ❌ (code: " .. f .. ")")
    --    LspOpenFileInNewBuffer(logfile)
  end
  return f
end

function GetDotnetDllPath()
  local dirname = vim.fs.dirname(DotnetStartupProjectPath)
  local projectName = LastDotnetProjectFileName
    or string.sub(DotnetStartupProjectPath, string.len(dirname), string.len(DotnetStartupProjectPath or "") - 8)
    or ""
  local path = dirname .. "/bin/debug/" .. projectName .. ".dll"
  if not LastDotnetDllPath or LastDotnetDllPath == "" then
    vim.g["LastDotnetDllPath"] = path
  end
  local request = function(givenPath)
    local p = vim.fn.input({ prompt = "Path to dll ", default = givenPath, completion = "file", cancelreturn = "" })
    if not StringEndsWith(p, ".dll") then
      local pathWithExt = p .. ".dll"
      if not os.rename(pathWithExt, pathWithExt) then
        p = vim.fn.input({
          prompt = "Could not find " .. p .. ".dll, please try entering another path? ",
          default = p,
          completion = "file",
        })
      end
    end
    if not os.rename(p, p) then
      p = vim.fn.input({
        prompt = "Could not find " .. p .. ", please try entering another path? ",
        default = p,
        completion = "file",
      })
    end
    return p
  end
  if vim.fn.confirm("Do you want to change the path to dll?\n" .. LastDotnetDllPath, "&yes\n&no", 2) == 1 then
    path = request(vim.fs.dirname(DotnetStartupProjectPath) .. "/bin/debug/")
  end
  vim.g["LastDotnetDllPath"] = path
  --  print("path to dll is set to: " .. Dotnetdotnet["LastDllPath"])
  return path
end

function DotnetBuild(path, buildType)
  local t = buildType or "debug"
  if t == "r" or t == "release" or t == "Release" or t == "R" then
    print("building project: " .. path .. "with build type " .. t)
    return DotnetBuildRelease(path)
  else
    print("building project: " .. path .. "with build type " .. t)
    return DotnetBuildDebug(path)
  end
end

if vim.g.lsp_handlers_enabled then
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
end
-- --- Check if a buffer is valid
-- -- @param bufnr the buffer to check
-- -- @return true if the buffer is valid or false
-- function Lspis_valid_buffer(bufnr)
--   if not bufnr or bufnr < 1 then return false end
--   return vim.bo[bufnr].buflisted and vim.api.nvim_buf_is_valid(bufnr)
-- end
--
--

return {
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = true,
  },
  {

    "p00f/clangd_extensions.nvim",
    config = true,
    ---@type lspconfig.options.clangd
    server = {
      -- options to pass to nvim-lspconfig
      -- i.e. the arguments to require("lspconfig").clangd.setup({})
      --

      -- clangd = {

      cmd = {
        -- "C:/ProgramData/chocolatey/bin/cpp.exe",
        "clangd",
        -- "-Wall",
        -- "-fms-compatibility-version=19.10",
        -- "-Wmicrosoft",
        -- "-Wno-invalid-token-paste",
        -- "-Wno-unknown-pragmas",
        -- "-Wno-unused-value",
        -- 'CMD.exe call "C:/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/VC/Auxiliary/Build/vcvarsall.bat" x64',
        -- "x64",
        -- "cl.exe",
        "--query-driver=C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.35.32215\\bin\\HostX64\\x64\\CL.exe",
        -- "--all-scopes-completion",
        -- "--background-index",
        "--clang-tidy",
        -- -- "--compile_args_from=filesystem", -- lsp-> does not come from compie_commands.json
        -- "--completion-parse=always",
        -- "--completion-style=bundled",
        "--cross-file-rename",
        -- "--debug-origin",
        -- "--enable-config", -- clangd 11+ supports reading from .clangd configuration file
        -- "--fallback-style=Qt",
        -- "--folding-ranges",
        "--function-arg-placeholders",
        -- "--header-insertion=iwyu",
        "--header-insertion=never",
        -- "--pch-storage=memory", -- could also be disk
        "--suggest-missing-includes",
        "-j=4", -- number of workers
        -- -- "--resource-dir="
        -- "--driver-mode=cl",
        "--log=error",
        -- --[[ "--query-driver=/usr/bin/g++", ]]
      },
      -- filetypes = { "c", "cpp", "objc", "objcpp" },
      root_dir = function(fname)
        local util = require("lspconfig.util")
        -- local util =
        -- return require("lspconfig").clangd.document_config.default_config.root_dir(fname)
        return util.root_pattern(unpack({
          -- ".clangd",
          -- ".clang-tidy",
          -- ".clang-format",
          "compile_commands.json",
          "compile_flags.txt",
          -- "build.sh", -- buildProject
          "build", -- buildProject
          "build.bat", -- buildProject
          "build.ps1", -- buildProject
          -- "configure.ac", -- AutoTools
          -- "run",
          -- "compile",
        }))(fname) or util.find_git_ancestor(fname)
      end,
      -- single_file_support = true,
      -- init_options = {
      --   compilationDatabasePath = "./build",
      -- },
      capabilities = { offsetEncoding = "utf-16" },
      -- commands = {
      --
      -- },
      settings = {
        clangd = {},
      },
    },
  },
  extensions = {
    -- defaults:
    -- Automatically set inlay hints (type hints)
    autoSetHints = true,
    -- These apply to the default ClangdSetInlayHints command
    inlay_hints = {
      -- Only show inlay hints for the current line
      only_current_line = false,
      -- Event which triggers a refersh of the inlay hints.
      -- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
      -- not that this may cause  higher CPU usage.
      -- This option is only respected when only_current_line and
      -- autoSetHints both are true.
      only_current_line_autocmd = "CursorHold",
      -- whether to show parameter hints with the inlay hints or not
      show_parameter_hints = true,
      -- prefix for parameter hints
      parameter_hints_prefix = "<- ",
      -- prefix for all the other hints (type, chaining)
      other_hints_prefix = "=> ",
      -- whether to align to the length of the longest line in the file
      max_len_align = false,
      -- padding from the left if max_len_align is true
      max_len_align_padding = 1,
      -- whether to align to the extreme right or not
      right_align = false,
      -- padding from the right if right_align is true
      right_align_padding = 7,
      -- The color of the hints
      highlight = "Comment",
      -- The highlight group priority for extmark
      priority = 100,
    },
    ast = {
      role_icons = {
        type = "",
        declaration = "",
        expression = "",
        specifier = "",
        statement = "",
        ["template argument"] = "",
      },
      kind_icons = {
        Compound = "",
        Recovery = "",
        TranslationUnit = "",
        PackExpansion = "",
        TemplateTypeParm = "",
        TemplateTemplateParm = "",
        TemplateParamObject = "",
      },
      highlights = {
        detail = "Comment",
      },
    },
    memory_usage = {
      border = "none",
    },
    symbol_info = {
      border = "none",
    },
    -- },
  },
  "b0o/SchemaStore.nvim",
  {

    "kkharji/sqlite.lua",
    config = function()
      -- re("sqlite")
      vim.g["sqlite_clib_path "] = "C:/ProgramData/chocolatey/lib/SQLite/tools/sqlite3.dll"
      -- vim.cmd("let g:sqlite_clib_path =" .. "C:/ProgramData/chocolatey/lib/SQLite/tools/sqlite3.dll")
    end,
  },
  -- {
  --   "glepnir/lspsaga.nvim",
  --   event = "BufRead",
  --   config = true,
  --   -- config = function()
  --   --   -- require("lspsaga").setup({})
  --   -- end,
  --   dependencies = {
  --     { "nvim-tree/nvim-web-devicons" },
  --     --Please make sure you install markdown and markdown_inline parser
  --     { "nvim-treesitter/nvim-treesitter" },
  --   },
  -- },
  {
    -- {
    --   "WillEhrendreich/ionide-vim",
    --   dir = vim.fn.getenv("repos") .. "/ionide-vim/",
    --   dev = true,
    --   -- opts = {},
    -- },
    -- {
    -- { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Goto Definition", has = "definition" },
    -- { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
    -- { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
    -- { "gI", "<cmd>Telescope lsp_implementations<cr>", desc = "Goto Implementation" },
    -- { "gt", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Goto Type Definition" },
    -- { "K", vim.lsp.buf.hover, desc = "Hover" },
    -- { "gK", vim.lsp.buf.signature_help, desc = "Signature Help", has = "signatureHelp" },
    -- { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" },
    -- { "]d", M.diagnostic_goto(true), desc = "Next Diagnostic" },
    -- { "[d", M.diagnostic_goto(false), desc = "Prev Diagnostic" },
    -- { "]e", M.diagnostic_goto(true, "ERROR"), desc = "Next Error" },
    -- { "[e", M.diagnostic_goto(false, "ERROR"), desc = "Prev Error" },
    -- { "]w", M.diagnostic_goto(true, "WARN"), desc = "Next Warning" },
    -- { "[w", M.diagnostic_goto(false, "WARN"), desc = "Prev Warning" },
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- change a keymap
      -- keys[#keys + 1] = { "K", "<cmd>echo 'hello'<cr>" }
      keys[#keys + 1] = {
        "K",
        function()
          local client = vim.lsp.get_active_clients({ buffer = 0 })[1]
          local capabilities = client.server_capabilities
          -- print("client " .. client.name .. " has capability " .. vim.inspect(capabilities))
          if capabilities.hoverProvider then
            if require("lazyvim.util").has("hover.nvim") then
              require("hover").hover()
            --     function()
            --       vim.lsp.buf.hover()
            --     end,
            --     desc = "Hover symbol details",
            --   }
            --
            else
              vim.lsp.buf.hover()
            end
          end
        end,
        "Hover",
      }
      keys[#keys + 1] =
        { "<leader>la", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" }
      keys[#keys + 1] = {
        "<leader>lcr",
        function()
          vim.lsp.codelens.clear()
          vim.lsp.codelens.refresh()
        end,
        desc = "Codelens Clear and Refresh",
        mode = "n",
        has = "codeAction",
      }
      keys[#keys + 1] = {
        "<leader>lf",
        require("lazyvim.plugins.lsp.format").format,
        desc = "Format Document",
        has = "documentFormatting",
      }
      keys[#keys + 1] = {
        "<leader>lf",
        require("lazyvim.plugins.lsp.format").format,
        desc = "Format Range",
        mode = "v",
        has = "documentRangeFormatting",
      }
      keys[#keys + 1] = { "<leader>ld", vim.diagnostic.open_float, desc = "Line Diagnostics" }
      -- keys[#keys + 1] = { "<leader>lI", "<cmd>LspRestart<cr>", desc = "Lsp Reinit" }

      if require("lazyvim.util").has("inc-rename.nvim") then
        keys[#keys + 1] = {
          "<leader>lr",
          function()
            require("inc_rename")
            return ":IncRename " .. vim.fn.expand("<cword>")
          end,
          expr = true,
          desc = "Rename",
          has = "rename",
        }
      else
        keys[#keys + 1] = { "<leader>lr", vim.lsp.buf.rename, desc = "Rename", has = "rename" }
      end
      -- keys[#keys + 1] = { "<leader>ll", "<cmd>LspLog<cr>" }
      -- keys[#keys + 1] = { "<leader>ll", "<cmd>LspLog<cr>" }
      -- keys[#keys + 1] = { "<leader>ll", "<cmd>LspLog<cr>" }
      -- keys[#keys + 1] = { "<leader>ll", "<cmd>LspLog<cr>" }
      -- keys[#keys + 1] = {
      --   "<leader>li",
      --   function()
      --     require("lspconfig.ui.lspinfo")()
      --   end,
      --   "LSP Info",
      -- }
      -- keys[#keys + 1] = {
      --   "<leader>lk",
      --   function()
      --     vim.fn.writefile({}, vim.lsp.get_log_path())
      --   end,
      --   "reset LSP log",
      -- }
      -- disable a keymap
      -- keys[#keys + 1] = { "K", false }
      -- add a keymap
      -- keys[#keys + 1] = { "H", "<cmd>echo 'hello'<cr>" }
    end,
    opts = {
      capabilities = {
        textDocument = {
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
        },
      },
      -- options for vim.diagnostic.config()
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, prefix = "●" },
        -- virtual_text = { spacing = 4, prefix = "●" },
        severity_sort = true,
      },
      -- Automatically format on save
      autoformat = true,
      -- options for vim.lsp.buf.format
      -- `bufnr` and `filter` is handled by the LazyVim formatter,
      -- but can be also overridden when specified
      format = {
        -- formatting_options = nil,
        -- timeout_ms = nil,
      },
      -- LSP Server Settings
      ---@type lspconfig.options
      servers = {
        jsonls = {},

        ---@type  lspconfig.options.fsautocomplete
        -- fsautocomplete = {
        --   autostart = true,
        --   filetypes = { "fsharp", "fsharp_project" },
        --   name = "fsautocomplete",
        --   -- single_file_support = false,
        --   -- cmd = { 'fsautocomplete', '--adaptive-lsp-server-enabled', '-v' },
        --   cmd = (function()
        --     return {
        --       -- "C:/Users/Will.ehrendreich/source/repos/FsAutoComplete/src/FsAutoComplete/bin/Debug/net6.0/publish/fsautocomplete.exe",
        --       "fsautocomplete",
        --       "--adaptive-lsp-server-enabled",
        --       -- "-l .fsautocomplete.log",
        --       "-v",
        --       "--wait-for-debugger",
        --       -- '--attach-debugger',
        --       -- "--project-graph-enabled",
        --     }
        --   end)(),
        -- on_attach = require("plugins.lsp").opts.on_attach,
        -- on_attach = on_attach,
        -- settings = {},
        -- },

        ---@type  lspconfig.options.fsautocomplete
        ionide = {
          autostart = true,

          -- cmd_Environment = "latestMinor",
          settings = {
            FSharp = {
              abstractClassStubGeneration = true,
              -- abstractClassStubGenerationMethodBody = "",
              -- abstractClassStubGenerationObjectIdentifier = "",
              addFsiWatcher = true,
              analyzersPath = {
                "./packages/analyzers",
              },
              autoRevealInExplorer = "enabled",
              -- autoRevealInExplorer= "disabled"|"enabled"|"sameAsFileExplorer",
              codeLenses = {
                ---@type _.lspconfig.settings.fsautocomplete.Signature
                signature = {
                  enabled = true,
                },
                references = {
                  enabled = true,
                },
              },
              disableFailedProjectNotifications = false,
              dotnetRoot = "",
              -- dotNetRoot = "",
              enableAnalyzers = true,
              enableAdaptiveLspServer = true,
              enableMSBuildProjectGraph = true,
              enableReferenceCodeLens = true,
              -- enableTouchBar = true,
              -- enableTreeView = true,
              excludeProjectDirectories = { ".git", "paket-files", ".fable", "packages", "node_modules" },
              -- externalAutocomplete = true,
              -- fsac = _.lspconfig.settings.fsautocomplete.Fsac,
              fsac = {
                silencedLogs = {
                  -- "",
                },
                parallelReferenceResolution = true,
              },
              fsiExtraParameters = {},
              -- fsiSdkFilePath = "",
              -- generateBinlog = true,
              indentationSize = 2,
              infoPanelReplaceHover = true,
              infoPanelShowOnStartup = true,
              infoPanelStartLocked = true,
              infoPanelUpdate = "both",
              ---@type _.lspconfig.settings.fsautocomplete.InlayHints
              inlayHints = {
                -- enabled = false,
                enabled = true,
                parameterNames = true,
                typeAnnotations = true,
                disableLongTooltip = false,
              },
              ---@type  _.lspconfig.settings.fsautocomplete.InlineValues
              inlineValues = {
                enabled = false,
                -- enabled = true,
                prefix = "  //ilv: ",
              },
              interfaceStubGeneration = true,
              -- interfaceStubGenerationMethodBody = "",
              -- interfaceStubGenerationObjectIdentifier = "",
              keywordsAutocomplete = true,
              -- lineLens = _.lspconfig.settings.fsautocomplete.LineLens,
              lineLens = { enabled = "always", prefix = "  //lnlens:" },
              linter = true,
              msbuildAutoshow = true,
              ---@type _.lspconfig.settings.fsautocomplete.Notifications
              notifications = { trace = true },

              -- openTelemetry = _.lspconfig.settings.fsautocomplete.OpenTelemetry,
              ---@type _.lspconfig.settings.fsautocomplete.PipelineHints
              pipelineHints = {
                enabled = true,
                prefix = "  // plh:",
              },
              recordStubGeneration = true,
              -- recordStubGenerationBody = "",
              resolveNamespaces = true,
              saveOnSendLastSelection = true,
              showExplorerOnStartup = true,
              showProjectExplorerIn = "fsharp",
              simplifyNameAnalyzer = true,
              smartIndent = true,
              suggestGitignore = true,
              suggestSdkScripts = true,
              -- trace = _.lspconfig.settings.fsautocomplete.Trace,
              trace = { server = "messages" },
              unionCaseStubGeneration = true,
              unusedOpensAnalyzer = true,
            },
          },
          filetypes = { "fsharp", "fsharp_project" },
          name = "ionide",
          -- single_file_support = false,
          -- cmd = { 'fsautocomplete', '--adaptive-lsp-server-enabled', '-v' },
          cmd = (function()
            return {
              -- "C:/Users/Will.ehrendreich/source/repos/FsAutoComplete/src/FsAutoComplete/bin/Debug/net6.0/publish/fsautocomplete.exe",
              "fsautocomplete",
              "--adaptive-lsp-server-enabled",
              -- "-l",
              -- ".fsautocomplete.log",
              "-v",
              -- '--wait-for-debugger',
              -- '--attach-debugger',
              "--project-graph-enabled",
            }
          end)(),
          -- on_attach = on_attach,
          -- settings = {},
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
              },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = {
                  -- vim.api.nvim_get_runtime_file("", true),
                  "C:\\Neovim\\share\\nvim\\runtime\\lua\\",
                },
                checkThirdParty = false,
              },

              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        ionide = function(_, opts)
          --   -- local inp = vim.fn.input("please attach debugger")

          require("ionide").setup(opts)
          -- return true
        end,
        fsautocomplete = function(_, _)
          return true
        end,
        -- require("ionide").setup(opts)
        -- fsautocomplete = function(_, opts) -- require("ionide").setup(opts)
        -- require("lazyvim.util").on_attach(function(client, buffer) end)
        -- require("fsautocomplete").setup(opts)
        -- return false
        -- end,
        -- example to setup with typescript.nvim
        -- tsserver = function(_, opts)
        --   require("typescript").setup({ server = opts })
        --   return true
        -- end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },

      on_attach = require("lazyvim.util").on_attach(
        ---@type fun(client:any, buffer:any)
        function(client, buffer)
          local ignored = { "jsonls", "null-ls", "stylua", "lemminx", "editorconfig_checker" }
          -- local ignored = v.lsp.ignoredLspServersForFindingRoot
          -- v.Notify(client.name .. " is running on_attach")
          -- v.Notify(vim.inspect(ignored) .. " are servers being ignored")
          -- local on_attach_override = user_plugin_opts("lsp.on_attach", nil, false)
          -- conditional_func(on_attach_override, true, client, bufnr)
          -- local capabilities = client.server_capabilities
          -- vim.notify(client.name .. " is running on_attach")
          if not tc(ignored, client.name) then
            -- if client.name ~= "null-ls" and client.name ~= "stylua" and client.name ~= "lemminx" then
            -- local root = FindRoot(ignored, bufnr)
            local root = FindRoot(ignored, buffer)
            -- v.Notify("lsp root should have found root of : " .. root)
            local cwd = first_to_upper(StringReplace(fn.getcwd(), "\\", "/"))
            if not root then
              vim.notify(
                "lsp says it didn't find a root??? I'd go check that one out.. setting temporary root to current buffer's parent dir, but don't think that means that lsp is healthy right now.. you've been warned! "
              )
              root = vim.fn.expand("%:h")
            end
            -- v.Notify("i have the root and cwd now.. but ill check the number of buffers.. ")
            local shouldAsk = vim.tbl_count(fn.getbufinfo({ buflisted = true })) > 1
            if root and cwd ~= root then
              if shouldAsk == true then
                -- v.Notify("at this point the buffers say i should ask about setting root.. " .. vim.inspect(shouldAsk))
                if
                  fn.confirm(
                    "Do you want to change the current working directory to lsp root?  \n  ROOT: "
                      .. root
                      .. "  \n  CWD : "
                      .. cwd
                      .. "  \n",
                    "&yes\n&no",
                    2
                  ) == 1
                then
                  vim.cmd("cd " .. root)
                  vim.notify("CWD : " .. root)
                end
              else
                vim.cmd("cd " .. root)
                vim.notify("CWD : " .. root)
              end
              LastDotnetProjectRootPath = root
              -- vim.g.dotnet_startup_proj_path = client.root
              LastDotnetDllPath = root .. "bin/debug/"
            end
          end
          --     vim.notify(" on attach for " .. client.name .. " just got called")
          --     if client.name == "ionide" then
          --       local inp = vim.fn.input("please attach debugger")
          --     end
          --     -- local normalCaps = vim.lsp.protocol.make_client_capabilities()
          --     -- print("client " .. client.name .. " has capability " .. vim.inspect(normalCaps))
          --     local capabilities = client.server_capabilities
          --     -- print("client " .. client.name .. " has capability " .. vim.inspect(capabilities))
          --     -- if capabilities.hoverProvider then
          --     --   if require("lazyvim.util").has("hover.nvim") then
          --     --     vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
          --     --     -- vim.keymap.set ("n", "K", require("hover").hover, {desc = "hover.nvim" })
          --     --     -- lsp_mappings.n["gK"] = { require("hover").hover_select, desc = "Hover symbol details (select)" }
          --     --     -- else
          --     --     --   lsp_mappings.n["K"] = {
          --     --     --     function()
          --     --     --       vim.lsp.buf.hover()
          --     --     --     end,
          --     --     --     desc = "Hover symbol details",
          --     --     --   }
          --     --   end
          --     -- end

          if client.name == "jsonls" then
            vim.lsp.buf.format()
          end
          if client.name == "omnisharp" then
            client.server_capabilities.semanticTokensProvider = {
              full = vim.empty_dict(),
              legend = {
                tokenModifiers = { "static_symbol" },
                tokenTypes = {
                  "comment",
                  "excluded_code",
                  "identifier",
                  "keyword",
                  "keyword_control",
                  "number",
                  "operator",
                  "operator_overloaded",
                  "preprocessor_keyword",
                  "string",
                  "whitespace",
                  "text",
                  "static_symbol",
                  "preprocessor_text",
                  "punctuation",
                  "string_verbatim",
                  "string_escape_character",
                  "class_name",
                  "delegate_name",
                  "enum_name",
                  "interface_name",
                  "module_name",
                  "struct_name",
                  "type_parameter_name",
                  "field_name",
                  "enum_member_name",
                  "constant_name",
                  "local_name",
                  "parameter_name",
                  "method_name",
                  "extension_method_name",
                  "property_name",
                  "event_name",
                  "namespace_name",
                  "label_name",
                  "xml_doc_comment_attribute_name",
                  "xml_doc_comment_attribute_quotes",
                  "xml_doc_comment_attribute_value",
                  "xml_doc_comment_cdata_section",
                  "xml_doc_comment_comment",
                  "xml_doc_comment_delimiter",
                  "xml_doc_comment_entity_reference",
                  "xml_doc_comment_name",
                  "xml_doc_comment_processing_instruction",
                  "xml_doc_comment_text",
                  "xml_literal_attribute_name",
                  "xml_literal_attribute_quotes",
                  "xml_literal_attribute_value",
                  "xml_literal_cdata_section",
                  "xml_literal_comment",
                  "xml_literal_delimiter",
                  "xml_literal_embedded_expression",
                  "xml_literal_entity_reference",
                  "xml_literal_name",
                  "xml_literal_processing_instruction",
                  "xml_literal_text",
                  "regex_comment",
                  "regex_character_class",
                  "regex_anchor",
                  "regex_quantifier",
                  "regex_grouping",
                  "regex_alternation",
                  "regex_text",
                  "regex_self_escaped_character",
                  "regex_other_escape",
                },
              },
              range = true,
            }
          end
        end
      ),
    },
    -- },
  },
}
