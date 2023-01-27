---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--original utils.
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---@diagnostic disable-next-line: undefined-global
local vimsharp_installation = vimsharp_installation or nil
_G.vimsharp = {
  --local v = {
  lsp = {
    ignoredLspServersForFindingRoot = { "null-ls", "stylua", "lemminx", "editorconfig_checker" },
  },
  module = {},
  dotnet = {},
  debug = {},
  buf = {},
  ui = {},
  path = {},
  highlight = {},

}
-- vim.notify(vim.inspect(_G.vimsharp.lsp.ignoredLspServersForFindingRoot))
local v = _G.vimsharp
-- vim.notify(vim.inspect(v.lsp.ignoredLspServersForFindingRoot))
local stdpath = vim.fn.stdpath
local tInsert = table.insert
local tContains = vim.tbl_contains
local map = vim.keymap.set
local fn = vim.fn
local tEmpty = vim.tbl_isempty
local uc = vim.api.nvim_create_user_command
local namespace = vim.api.nvim_create_namespace
local autocmd = vim.api.nvim_create_autocmd
local grp = vim.api.nvim_create_augroup
local setlines = vim.api.nvim_buf_set_lines
local jb = fn.jobstart
local inp = fn.input

--- Call function if a condition is met
-- @param func the function to run
-- @param condition a boolean value of whether to run the function or not
function v.executeIfTrue(func, condition, ...)
  -- if the condition is true or no condition is provided, evaluate the function with the rest of the parameters and return the result
  if condition and type(func) == "function" then return func(...) end
end

local executeIfTrue = v.executeIfTrue

--#region_utils
--- installation details from external installers
v.install = vimsharp_installation or { home = stdpath "config" }
--- external vimsharp configuration folder
v.install.config = stdpath("config"):gsub("nvim$", "v")
vim.opt.rtp:append(v.install.config)
local supported_configs = { v.install.home, v.install.config }


--- Looks to see if a module path references a lua file in a configuration folder and tries to load it. If there is an error loading the file, write an error and continue
-- @param module the module path to try and load
-- @return the loaded module if successful or nil
v.module.load = function(module)
  -- placeholder for final return value
  local found_module = nil
  -- search through each of the supported configuration locations
  for _, config_path in ipairs(supported_configs) do
    -- convert the module path to a file path (example user.setup -> user/init.lua)
    local module_path = config_path .. "/lua/" .. module:gsub("%.", "/") .. ".lua"
    -- check if there is a readable file, if so, set it as found
    if fn.filereadable(module_path) == 1 then found_module = module_path end
  end
  -- if we found a readable lua file, try to load it
  if found_module then
    -- try to load the file
    local status_ok, loaded_module = pcall(require, module)
    -- if successful at loading, set the return variable
    if status_ok then
      found_module = loaded_module
      -- if unsuccessful, throw an error
    else
      vim.api.nvim_err_writeln("Error loading file: " .. found_module .. "\n\n" .. loaded_module)
    end
  end
  -- return the loaded module or nil if no file found
  return found_module
end

-- v.lsp["FindRoot"] = function(ignored_lsp_servers, bufnr)
function v.FindRoot(ignored_lsp_servers, bufnr)
  local b      = bufnr or 0
  -- Get lsp client for current buffer
  -- local bufDir = v.path.GetDirForBufnr(bufnr)
  local ignore = ignored_lsp_servers or
      v.lsp.ignoredLspServersForFindingRoot
      or {}
  -- vim.notify(vim.inspect(ignore) .. "are being ignored when finding root")
  -- vim.notify(vim.inspect(b) .. " is the bufnumber with filename " .. v.path.GetBaseFilenameForBufnr(b))

  local buf_ft  = vim.api.nvim_buf_get_option(b, "filetype")
  local result
  local clients = vim.lsp.get_active_clients({
    bufnr = b
  })
  local i       = ignore or {}
  for _, c in pairs(clients) do
    local cname = c.name
    -- v.notify("client name is " .. (cname or "not found"))
    -- local bufname = vim.api.nvim_buf_get_name(bufnr)
    -- v.notify("buf name is " .. (bufname or "not found"))
    -- local lspConfigForClient = re 'lspconfig.configs'[cname]
    -- v.notify("config for " .. (cname or "not found") .. " is " .. vim.inspect(lspConfigForClient or " not found.."))
    local filetypes = c.config.filetypes
    if filetypes and tContains(filetypes, buf_ft) then
      if not tContains(i, cname) then
        -- local rootDirFunction = lspConfigForClient.get_root_dir
        -- v.notify("lsp root dir function is " .. vim.inspect(rootDirFunction or "not found"))
        local activeConfigRootDir = c.config.root_dir
        -- local rootresult
        -- v.notify("active root dir is " .. (activeConfigRootDir or "not found"))
        -- if rootDirFunction then
        -- rootresult = rootDirFunction(bufname)
        -- if rootresult and not rootresult == nil and not rootresult == "" then v.notify("result of rootDirFunction is: "
        --     ..
        --     upperDriveLetter(vim.fs.normalize(v.path.AppendSlash(rootresult))))
        -- end
        -- end
        if activeConfigRootDir then
          result = string.gsub(v.path.AppendSlash(v.path.UpperDriveLetter(vim.fs.normalize(activeConfigRootDir .. "/")))
            , "//", "/")
          -- v.notify("active root dir is " .. (result or "not found"))
          -- else
          -- result = upperDriveLetter(vim.fs.normalize(v.path.AppendSlash(rootresult) )))
        end
      end
    end
  end
  -- return upperDriveLetter(vim.fs.normalize(v.path.AppendSlash(result or bufDir)))
  return result
end

--
-- Does package.json file contain speficied configuration or dependency?
-- (e.g. "prettier")
-- IMPORTANT! package.json file is found only if lsp root
-- where package.json is or vim-rooter (or something similar) is activated
--
v.is_in_package_json = function(field)
  local root = v.FindRoot(v.lsp.ignoredLspServersForFindingRoot)
  if fn.filereadable(root .. "/package.json") ~= 0 then
    local package_json = fn.json_decode(fn.readfile "package.json")
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

v.is_web_project = function()
  return (fn.glob "package.json" ~= "" or fn.glob "yarn.lock" ~= "" or fn.glob "node_modules" ~= "")
end

v.is_arduino_project = function()
  return (fn.glob "*.ino" ~= "")
end

v.decode_json_file = function(filename)
  if fn.filereadable(filename) == 0 then
    return nil
  end

  return fn.json_decode(fn.readfile(filename))
end

v.stringReplace = function(x, to_replace, replace_with)
  if type(x) == "string" or type(x) == "number" then
    return string.gsub(x, to_replace, replace_with)
  end

  if type(x) == "table" then
    for key, value in pairs(x) do
      x[key] = v.stringReplace(value, to_replace, replace_with)
    end
  end

  return x
end

v.dotnet.StartupProjectPath = nil
v.dotnet.GetProjectPath = function()
  if v.dotnet.StartupProjectPath == nil then
    v.dotnet.StartupProjectPath = vim.fn.getcwd()
  end
  v.debug.getConfig()
  local path = fn.input({ "Path to your startup *proj file ", v.dotnet.StartupProjectPath, "file" })
  v.dotnet.lastProjectPath = path
  v.dotnet.StartupProjectPath = path
  return path
end

local openFileInNewBuffer = function(f)
  if fn.confirm("Do you want to open the file " .. f .. " ?\n", "&yes\n&no", 2) == 1 then vim.cmd.bufload(f) end
end

v.dotnet["buildRelease"] = function(p)
  local logfile = "c:/temp/dotnet-release-Log.txt"
  -- local cmd = "dotnet build -c Release " .. p .. '" *> ' .. logfile
  local cmd = "dotnet build -c Release --project " .. p
  print ""
  print("Cmd to execute: " .. cmd)
  local f = os.execute(cmd)
  if f == 0 then
    print "\nBuild: ✔️ "
  else
    print("\nBuild: ❌ (code: " .. f .. ")")
    openFileInNewBuffer(logfile)
  end
  return f
end

v.dotnet["buildDebug"] = function(p)
  local logfile = "c:/temp/dap-debug-nvim-dotnet.txt"
  -- local cmd = "dotnet build -c Debug " .. p .. '" *> ' .. logfile
  local cmd = "dotnet build -c Debug --project " .. p
  print ""
  print("Cmd to execute: " .. cmd)
  local f = os.execute(cmd)
  if f == 0 then
    print "\nBuild: ✔️ "
  else
    print("\nBuild: ❌ (code: " .. f .. ")")
    openFileInNewBuffer(logfile)
  end
  return f
end

v.dotnet["getDllPath"] = function()
  local request = function()
    return fn.input({ "Path to dll ",
      vim.fs.normalize(vim.lsp.buf.list_workspace_folders()[1]) .. "/bin/Debug/", "file" })
  end
  if v.dotnet["dotnet_last_dll_path"] == nil then
    v.dotnet["dotnet_last_dll_path"] = request()
  else
    if fn.confirm("Do you want to change the path to dll?\n" .. v.dotnet["dotnet_last_dll_path"],
      "&yes\n&no", 2) == 1
    then
      v.dotnet["dotnet_last_dll_path"] = request()
    end
    print("path to dll is set to: " .. v.dotnet["dotnet_last_dll_path"])
  end
  return v.dotnet["dotnet_last_dll_path"]
end

v.dotnet["build"] = function(path, buildType)
  local t = buildType or "debug"
  if t == "r" or t == "release" or t == "Release" or t == "R" then
    print("building project: " .. path .. "with build type " .. t)
    return v.dotnet.buildRelease(path)
  else
    print("building project: " .. path .. "with build type " .. t)
    return v.dotnet.buildDebug(path)
  end
end


v.dotNetDapConfig = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
      if fn.confirm("Should I recompile first?", "&yes\n&no", 2) == 1 then
        v.dotnet.build(v.dotnet.getProjectPath())
      end
      return v.dotnet.getDllPath()
    end,
  },
}

v.dotnet["run"] = function(proj, runtype)
  local c = "dotnet run --project " .. proj
  os.execute(c)
end

v.debug.getConfig = function()
  local root = v.FindRoot(v.lsp.ignoredLspServersForFindingRoot)
  local dap_config = v.decode_json_file(root .. "/.dap.json")
  if dap_config ~= nil then
    return { dap_config }
  end

  local status_ok, vscode_launch_file = pcall(v.decode_json_file, root .. "/.vscode/launch.json")
  if status_ok and vscode_launch_file ~= nil then
    local configs = vscode_launch_file["configurations"]
    if configs ~= nil then
      for j = 1, #configs do
        if configs[j]["request"] == "launch" then
          local config = v.stringReplace(configs[j], "${workspaceRoot}", root)
          return { config }
        end
      end
      return v.stringReplace(configs, "${workspaceRoot}", root)
    end
  end

  return nil
end

v.get_debug_program = function()
  local root = v.FindRoot()
  local dap_config = v.decode_json_file(root .. ".dap.json")

  if dap_config ~= nil then
    local program = dap_config["program"]
    if program ~= nil then
      return program
    end
  end

  local status_ok, vscode_launch_file = pcall(v.decode_json_file, root .. ".vscode/launch.json")
  if not status_ok or vscode_launch_file == nil then
    print(root .. ".vscode/launch.json file not found or is invalid for json decoding.")
    return ""
  end

  local configs = vscode_launch_file["configurations"]
  if configs ~= nil then
    for j = 1, #configs do
      if configs[j]["request"] == "launch" then
        return v.stringReplace(configs[j]["program"], "${workspaceRoot}", root)
      end
    end
  end
  return ""
end

-- Returns the index of a item in the list
v.indexOf = function(l, value)
  for i, x in ipairs(l) do
    if x == value then
      return i
    end
  end
  return nil
end

-- Does the current project have a Prettier configuration?
-- Assumes, that LunarVim has been opened in the root of the project
v.project_has_prettier_config = function()
  local hasprettier = (
      fn.glob ".prettierrc*" ~= ""
          or fn.glob "prettier.*" ~= ""
          or v.is_in_package_json "prettier"
      )
  -- print("Project does has prettier configured? " .. tostring(hasprettier))
  return hasprettier
end



--- user settings from the base `user/init.lua` file
v.user_settings = v.module.load "user.init"
--- table of user created terminals
v.user_terminals = {}
--- table of plugins to load with git
v.git_plugins = {}
--- table of plugins to load when file opened
v.filePlugins = {}
--- regex used for matching a valid URL/URI string
v.url_matcher =
"\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

--- Main configuration engine logic for extending a default configuration table with either a function override or a table to merge into the default option
-- @function v.func_or_extend
-- @param overrides the override definition, either a table or a function that takes a single parameter of the original table
-- @param default the default configuration table
-- @param extend boolean value to either extend the default or simply overwrite it if an override is provided
-- @return the new configuration table
v.func_or_extend = function(overrides, default, extend)
  -- if we want to extend the default with the provided override
  if extend then
    -- if the override is a table, use vim.tbl_deep_extend
    if type(overrides) == "table" then
      default = v.default_tbl(overrides, default)
      -- if the override is  a function, call it with the default and overwrite default with the return value
    elseif type(overrides) == "function" then
      default = overrides(default)
    end
    -- if extend is set to false and we have a provided override, simply override the default
  elseif overrides ~= nil then
    default = overrides
  end
  -- return the modified default table
  return default
end

--- Merge extended options with a default table of options
-- @param opts the new options that should be merged with the default table
-- @param default the default table that you want to merge into
-- @return the merged table
function v.default_tbl(opts, default)
  opts = opts or {}
  return default and vim.tbl_deep_extend("force", default, opts) or opts
end

--- Get highlight properties for a given highlight name
-- @param name highlight group name
-- @return table of highlight group properties
function v.highlight.getGroup(name, fallback)
  if fn.hlexists(name) == 1 then
    local hl = vim.api.nvim_get_hl_by_name(name, vim.o.termguicolors)
    if not hl["foreground"] then hl["foreground"] = "NONE" end
    if not hl["background"] then hl["background"] = "NONE" end
    hl.fg, hl.bg, hl.sp = hl.foreground, hl.background, hl.special
    hl.ctermfg, hl.ctermbg = hl.foreground, hl.background
    return hl
  end
  return fallback
end

--- Trim a string or return nil
-- @param str the string to trim
-- @return a trimmed version of the string or nil if the parameter isn't a string
function v.trim_or_nil(str) return type(str) == "string" and vim.trim(str) or nil end

--- Add left and/or right padding to a string
-- @param str the string to add padding to
-- @param padding a table of the format `{ left = 0, right = 0}` that defines the number of spaces to include to the left and the right of the string
-- @return the padded string
function v.pad_string(str, padding)
  padding = padding or {}
  return str and str ~= "" and string.rep(" ", padding.left or 0) .. str .. string.rep(" ", padding.right or 0) or ""
end

--- Initialize icons used throughout the user interface
function v.initialize_icons()
  -- v.icons = v.user_plugin_opts("icons", re "core.icons.nerd_font")
  v.icons =
  {
    ActiveLSP = "",
    ActiveTS = "綠",
    ArrowLeft = "",
    ArrowRight = "",
    BufferClose = "",
    DapBreakpoint = "",
    DapBreakpointCondition = "",
    DapBreakpointRejected = "",
    DapLogPoint = ".>",
    DapStopped = "",
    DefaultFile = "",
    Diagnostic = "裂",
    DiagnosticError = "",
    DiagnosticHint = "",
    DiagnosticInfo = "",
    DiagnosticWarn = "",
    Ellipsis = "…",
    FileModified = "",
    FileReadOnly = "",
    FolderClosed = "",
    FolderEmpty = "",
    FolderOpen = "",
    Git = "",
    GitAdd = "",
    GitBranch = "",
    GitChange = "",
    GitConflict = "",
    GitDelete = "",
    GitIgnored = "◌",
    GitRenamed = "➜",
    GitStaged = "✓",
    GitUnstaged = "✗",
    GitUntracked = "★",
    LSPLoaded = "",
    LSPLoading1 = "",
    LSPLoading2 = "",
    LSPLoading3 = "",
    MacroRecording = "",
    Paste = "",
    Search = "",
    Selected = "❯",
    Spellcheck = "暈",
    TabClose = "",
  }

  -- v.text_icons = v.user_plugin_opts("text_icons", re "core.icons.text")
  v.text_icons = {
    ActiveLSP = "",
    ActiveTS = "綠",
    ArrowLeft = "",
    ArrowRight = "",
    BufferClose = "",
    DapBreakpoint = "",
    DapBreakpointCondition = "",
    DapBreakpointRejected = "",
    DapLogPoint = ".>",
    DapStopped = "",
    DefaultFile = "",
    Diagnostic = "裂",
    DiagnosticError = "",
    DiagnosticHint = "",
    DiagnosticInfo = "",
    DiagnosticWarn = "",
    Ellipsis = "…",
    FileModified = "",
    FileReadOnly = "",
    FolderClosed = "",
    FolderEmpty = "",
    FolderOpen = "",
    Git = "",
    GitAdd = "",
    GitBranch = "",
    GitChange = "",
    GitConflict = "",
    GitDelete = "",
    GitIgnored = "◌",
    GitRenamed = "➜",
    GitStaged = "✓",
    GitUnstaged = "✗",
    GitUntracked = "★",
    LSPLoaded = "",
    LSPLoading1 = "",
    LSPLoading2 = "",
    LSPLoading3 = "",
    MacroRecording = "",
    Paste = "",
    Search = "",
    Selected = "❯",
    Spellcheck = "暈",
    TabClose = "",
  }
end

--- Get an icon from `lspkind` if it is available and return it
-- @param kind the kind of icon in `lspkind` to retrieve
-- @return the icon
function v.get_icon(kind)
  local icon_pack = vim.g.icons_enabled and "icons" or "text_icons"
  if not v[icon_pack] then v.initialize_icons() end
  return v[icon_pack] and v[icon_pack][kind] or ""
end

--- Serve a notification with a title of v
-- @param msg the notification body
-- @param type the type of the notification (:help vim.log.levels)
-- @param opts table of nvim-notify options to use (:help notify-options)
function v.notify(msg, type, opts)
  vim.schedule(function() vim.notify(msg, type, v.default_tbl(opts, { title = "VimSharp" })) end)
end

--- Trigger an v user event
-- @param event the event name to be appended to VimSharp
function v.event(event)
  vim.schedule(function() vim.api.nvim_exec_autocmds("User", { pattern = "VimSharp" .. event }) end)
end

--- Wrapper function for neovim echo API
-- @param messages an array like table where each item is an array like table of strings to echo
function v.echo(messages)
  -- if no parameter provided, echo a new line
  messages = messages or { { "\n" } }
  if type(messages) == "table" then vim.api.nvim_echo(messages, false, {}) end
end

--- Echo a message and prompt the user for yes or no response
-- @param messages the message to echo
-- @return True if the user responded y, False for any other response
function v.confirm_prompt(messages)
  if messages then v.echo(messages) end
  local confirmed = string.lower(fn.input "(y/n) ") == "y"
  v.echo()
  return confirmed
end

--- Search the user settings (user/init.lua table) for a table with a module like path string
-- @param module the module path like string to look up in the user settings table
-- @return the value of the table entry if exists or nil
local function user_setting_table(module)
  -- get the user settings table
  local settings = v.user_settings or {}
  -- iterate over the path string split by '.' to look up the table value
  for tbl in string.gmatch(module, "([^%.]+)") do
    settings = settings[tbl]
    -- if key doesn't exist, keep the nil value and stop searching
    if settings == nil then break end
  end
  -- return the found settings
  return settings
end

--- Set vim options with a nested table like API with the format vim.<first_key>.<second_key>.<value>
-- @param options the nested table of vim options
function v.vim_opts(options)
  for scope, table in pairs(options) do
    for setting, value in pairs(table) do
      vim[scope][setting] = value
    end
  end
end

--- User configuration entry point to override the default options of a configuration table with a user configuration file or table in the user/init.lua user settings
-- @param module the module path of the override setting
-- @param default the default settings that will be overridden
-- @param extend boolean value to either extend the default settings or overwrite them with the user settings entirely (default: true)
-- @param prefix a module prefix for where to search (default: user)
-- @return the new configuration settings with the user overrides applied
function v.userConfigs(module, default, extend, prefix)
  -- default to extend = true
  if extend == nil then extend = true end
  -- if no default table is provided set it to an empty table
  if default == nil then default = {} end
  -- try to load a module file if it exists
  local user_settings = v.module.load((prefix or "user") .. "." .. module)
  -- if no user module file is found, try to load an override from the user settings table from user/init.lua
  if user_settings == nil and prefix == nil then user_settings = user_setting_table(module) end
  -- if a user override was found call the configuration engine
  if user_settings ~= nil then default = v.func_or_extend(user_settings, default, extend) end
  -- return the final configuration table with any overrides applied
  return default
end

-- --- Open a URL under the cursor with the current operating system (Supports Mac OS X and *nix)
-- -- @param path the path of the file to open with the system opener
-- function v.system_open(path)
--   path = path or fn.expand "<cfile>"
--   if fn.has "mac" == 1 then
--     -- if mac use the open command
--     fn.jobstart({ "open", path }, { detach = true })
--   elseif fn.has "unix" == 1 then
--     -- if unix then use xdg-open
--     fn.jobstart({ "xdg-open", path }, { detach = true })
--   else
--     -- if any other operating system notify the user that there is currently no support
--     v.notify("System open is not supported on this OS!", "error")
--   end
-- end
--- Open a URL under the cursor with the current operating system (Supports Mac OS X and *nix)
-- @param path the path of the file to open with the system opener
function v.system_open(path)
  path = path or fn.expand "<cfile>"
  if fn.has "mac" == 1 then
    -- if mac use the open command
    fn.jobstart({ "open", path }, { detach = true })
  elseif fn.has "unix" == 1 then
    -- if unix then use xdg-open
    fn.jobstart({ "xdg-open", path }, { detach = true })
  else
    -- if any other operating system notify the user that there is currently no support
    if v.isAvalable("OpenBrowserSmartSearch") then
      vim.cmd.OpenBrowserSmartSearch(path)
    end
    -- v.notify("System open is not supported on this OS!", "error")
  end
end

-- term_details can be either a string for just a command or
-- a complete table to provide full access to configuration when calling Terminal:new()

--- Toggle a user terminal if it exists, if not then create a new one and save it
-- @param term_details a terminal command string or a table of options for Terminal:new() (Check toggleterm.nvim documentation for table format)
function v.toggle_term_cmd(opts)
  local terms = v.user_terminals
  -- if a command string is provided, create a basic table for Terminal:new() options
  if type(opts) == "string" then opts = { cmd = opts, hidden = true } end
  local num = vim.v.count > 0 and vim.v.count or 1
  -- if terminal doesn't exist yet, create it
  if not terms[opts.cmd] then terms[opts.cmd] = {} end
  if not terms[opts.cmd][num] then
    if not opts.count then opts.count = vim.tbl_count(terms) * 100 + num end
    terms[opts.cmd][num] = require("toggleterm.terminal").Terminal:new(opts)
  end
  -- toggle the terminal
  v.user_terminals[opts.cmd][num]:toggle()
end

--- register mappings table with which-key
-- @param mappings nested table of mappings where the first key is the mode, the second key is the prefix, and the value is the mapping table for which-key
-- @param opts table of which-key options when setting the mappings (see which-key documentation for possible values)
function v.which_key_register(mappings, opts)
  local status_ok, which_key = pcall(require, "which-key")
  if not status_ok then return end
  for mode, prefixes in pairs(mappings) do
    for prefix, mapping_table in pairs(prefixes) do
      which_key.register(
        mapping_table,
        v.default_tbl(opts, {
          mode = mode,
          prefix = prefix,
          nowait = true,
        })
      )
    end
  end
end

--- Get a list of registered null-ls providers for a given filetype
-- @param filetype the filetype to search null-ls for
-- @return a list of null-ls sources
function v.null_ls_providers(filetype)
  local registered = {}
  -- try to load null-ls
  local sources_avail, sources = pcall(require, "null-ls.sources")
  if sources_avail then
    -- get the available sources of a given filetype
    for _, source in ipairs(sources.get_available(filetype)) do
      -- get each source name
      for method in pairs(source.methods) do
        registered[method] = registered[method] or {}
        tInsert(registered[method], source.name)
      end
    end
  end
  -- return the found null-ls sources
  return registered
end

--- Get the null-ls sources for a given null-ls method
-- @param filetype the filetype to search null-ls for
-- @param method the null-ls method (check null-ls documentation for available methods)
-- @return the available sources for the given filetype and method
function v.null_ls_sources(filetype, method)
  local methods_avail, methods = pcall(require, "null-ls.methods")
  return methods_avail and v.null_ls_providers(filetype)[methods.internal[method]] or {}
end

--- Create a button entity to use with the alpha dashboard
-- @param sc the keybinding string to convert to a button
-- @param txt the explanation text of what the keybinding does
-- @return a button entity table for an alpha configuration
function v.alpha_button(sc, txt)
  -- replace <leader> in shortcut text with LDR for nicer printing
  local sc_ = sc:gsub("%s", ""):gsub("LDR", "<leader>")
  -- if the leader is set, replace the text with the actual leader key for nicer printing
  if vim.g.mapleader then sc = sc:gsub("LDR", vim.g.mapleader == " " and "SPC" or vim.g.mapleader) end
  -- return the button entity to display the correct text and send the correct keybinding on press
  return {
    type = "button",
    val = txt,
    on_press = function()
      local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
      vim.api.nvim_feedkeys(key, "normal", false)
    end,
    opts = {
      position = "center",
      text = txt,
      shortcut = sc,
      cursor = 5,
      width = 36,
      align_shortcut = "right",
      hl = "DashboardCenter",
      hl_shortcut = "DashboardShortcut",
    },
  }
end

--- Check if a plugin is defined in lazy. Useful with lazy loading when a plugin is not necessarily loaded yet
-- @param plugin the plugin string to search for
-- @return boolean value if the plugin is available
function v.isAvalable(plugin)
  local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
  return lazy_config_avail and lazy_config.plugins and lazy_config.plugins[plugin]
end

--- A helper function to wrap a module function to re a plugin before running
-- @param plugin the plugin string to call `re("lazy").laod` with
-- @param module the system module where the functions live (e.g. `vim.ui`)
-- @param func_names a string or a list like table of strings for functions to wrap in the given moduel (e.g. `{ "ui", "select }`)
function v.load_plugin_with_func(plugin, module, func_names)
  if type(func_names) == "string" then func_names = { func_names } end
  for _, func in ipairs(func_names) do
    local old_func = module[func]
    module[func] = function(...)
      module[func] = old_func
      require("lazy").load { plugins = { plugin } }
      module[func](...)
    end
  end
end

--- Table based API for setting keybindings
-- @param map_table A nested table where the first key is the vim mode, the second key is the key to map, and the value is the function to set the mapping to
-- @param base A base set of options to set on every keybinding
function v.set_mappings(map_table, base)
  local wk_avail, wk = pcall(require, "which-key")
  -- iterate over the first keys for each mode
  for mode, maps in pairs(map_table) do
    -- iterate over each keybinding set in the current mode
    for keymap, options in pairs(maps) do
      -- build the options for the command accordingly
      if options then
        local cmd = options
        local keymap_opts = base or {}
        if type(options) == "table" then
          cmd = options[1]
          keymap_opts = vim.tbl_deep_extend("force", options, keymap_opts)
          keymap_opts[1] = nil
        end
        if type(options) == "table" and options.name then
          if wk_avail then
            -- if options have name, then use which-key register
            keymap_opts.mode = mode
            wk.register({ [keymap] = options }, keymap_opts)
          end
        else
          -- extend the keybinding options with the base provided and set the mapping
          map(mode, keymap, cmd, keymap_opts)
        end
      end
    end
  end
end

--- Delete the syntax matching rules for URLs/URIs if set
function v.delete_url_match()
  for _, match in ipairs(fn.getmatches()) do
    if match.group == "HighlightURL" then fn.matchdelete(match.id) end
  end
end

--- Add syntax matching rules for highlighting URLs/URIs
function v.set_url_match()
  v.delete_url_match()
  if vim.g.highlighturl_enabled then fn.matchadd("HighlightURL", v.url_matcher, 15) end
end

--- Run a shell command and capture the output and if the command succeeded or failed
-- @param cmd the terminal command to execute
-- @param show_error boolean of whether or not to show an unsuccessful command as an error to the user
-- @return the result of a successfully executed command or nil
function v.cmd(cmd, show_error)
  if fn.has "win32" == 1 then cmd = { "cmd.exe", "/C", cmd } end
  local result = fn.system(cmd)
  local success = vim.api.nvim_get_vvar "shell_error" == 0
  if not success and (show_error == nil and true or show_error) then
    vim.api.nvim_err_writeln("Error running command: " .. cmd .. "\nError message:\n" .. result)
  end
  return success and result:gsub("[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "") or nil
end

--- Check if a buffer is valid
-- @param bufnr the buffer to check
-- @return true if the buffer is valid or false
function v.is_valid_buffer(bufnr)
  if not bufnr or bufnr < 1 then return false end
  return vim.bo[bufnr].buflisted and vim.api.nvim_buf_is_valid(bufnr)
end

--- Move the current buffer tab n places in the bufferline
-- @param n numer of tabs to move the current buffer over by (positive = right, negative = left)
function v.move_buf(n)
  if n == 0 then return end -- if n = 0 then no shifts are needed
  local bufs = vim.t.bufs -- make temp variable
  for i, bufnr in ipairs(bufs) do -- loop to find current buffer
    if bufnr == vim.api.nvim_get_current_buf() then -- found index of current buffer
      for _ = 0, (n % #bufs) - 1 do -- calculate number of right shifts
        local new_i = i + 1 -- get next i
        if i == #bufs then -- if at end, cycle to beginning
          new_i = 1 -- next i is actually 1 if at the end
          local val = bufs[i] -- save value
          table.remove(bufs, i) -- remove from end
          table.insert(bufs, new_i, val) -- insert at beginning
        else -- if not at the end,then just do an in place swap
          bufs[i], bufs[new_i] = bufs[new_i], bufs[i]
        end
        i = new_i -- iterate i to next value
      end
      break
    end
  end
  vim.t.bufs = bufs -- set buffers
  vim.cmd.redrawtabline() -- redraw tabline
end

--- Navigate left and right by n places in the bufferline
-- @param n the number of tabs to navigate to (positive = right, negative = left)
function v.nav_buf(n)
  local current = vim.api.nvim_get_current_buf()
  for i, x in ipairs(vim.t.bufs) do
    if current == x then
      vim.cmd.b(vim.t.bufs[(i + n - 1) % #vim.t.bufs + 1])
      break
    end
  end
end

--- Close a given buffer
-- @param bufnr? the buffer number to close or the current buffer if not provided
function v.close_buf(bufnr, force)
  if force == nil then force = false end
  local current = vim.api.nvim_get_current_buf()
  if not bufnr or bufnr == 0 then bufnr = current end
  if bufnr == current then v.nav_buf(-1) end

  if v.isAvalable "bufdelete.nvim" then
    require("bufdelete").bufdelete(bufnr, force)
  else
    vim.cmd((force and "bd!" or "confirm bd") .. bufnr)
  end
end

--- Close the current tab
function v.close_tab()
  if #vim.api.nvim_list_tabpages() > 1 then
    vim.t.bufs = nil
    vim.cmd.tabclose()
  end
end

--#endregion_utils


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------






---UI



---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--#region_ui
-- re "core.utils.ui"



v.ui = {}

local function bool2str(bool) return bool and "on" or "off" end

local function ui_notify(str)
  if vim.g.ui_notifications_enabled then v.notify(str) end
end

--- Toggle notifications for UI toggles
function v.ui.toggle_ui_notifications()
  vim.g.ui_notifications_enabled = not vim.g.ui_notifications_enabled
  ui_notify(string.format("ui notifications %s", bool2str(vim.g.ui_notifications_enabled)))
end

--- Toggle autopairs
function v.ui.toggle_autopairs()
  local ok, autopairs = pcall(require, "nvim-autopairs")
  if ok then
    if autopairs.state.disabled then
      autopairs.enable()
    else
      autopairs.disable()
    end
    vim.g.autopairs_enabled = autopairs.state.disabled
    ui_notify(string.format("autopairs %s", bool2str(not autopairs.state.disabled)))
  else
    ui_notify "autopairs not available"
  end
end

--- Toggle diagnostics
function v.ui.toggle_diagnostics()
  local status = "on"
  if vim.g.status_diagnostics_enabled then
    if vim.g.diagnostics_enabled then
      vim.g.diagnostics_enabled = false
      status = "virtual text off"
    else
      vim.g.status_diagnostics_enabled = false
      status = "fully off"
    end
  else
    vim.g.diagnostics_enabled = true
    vim.g.status_diagnostics_enabled = true
  end

  vim.diagnostic.config(v.lsp.diagnostics[bool2str(vim.g.diagnostics_enabled)])
  ui_notify(string.format("diagnostics %s", status))
end

--- Toggle background="dark"|"light"
function v.ui.toggle_background()
  vim.go.background = vim.go.background == "light" and "dark" or "light"
  ui_notify(string.format("background=%s", vim.go.background))
end

--- Toggle cmp entrirely
function v.ui.toggle_cmp()
  vim.g.cmp_enabled = not vim.g.cmp_enabled
  local ok, _ = pcall(require, "cmp")
  ui_notify(ok and string.format("completion %s", bool2str(vim.g.cmp_enabled)) or "completion not available")
end

--- Toggle auto format
function v.ui.toggle_autoformat()
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  ui_notify(string.format("Autoformatting %s", bool2str(vim.g.autoformat_enabled)))
end

--- Toggle showtabline=2|0
function v.ui.toggle_tabline()
  vim.opt.showtabline = vim.opt.showtabline:get() == 0 and 2 or 0
  ui_notify(string.format("tabline %s", bool2str(vim.opt.showtabline:get() == 2)))
end

--- Toggle conceal=2|0
function v.ui.toggle_conceal()
  vim.opt.conceallevel = vim.opt.conceallevel:get() == 0 and 2 or 0
  ui_notify(string.format("conceal %s", bool2str(vim.opt.conceallevel:get() == 2)))
end

--- Toggle laststatus=3|2|0
function v.ui.toggle_statusline()
  local laststatus = vim.opt.laststatus:get()
  local status
  if laststatus == 0 then
    vim.opt.laststatus = 2
    status = "local"
  elseif laststatus == 2 then
    vim.opt.laststatus = 3
    status = "global"
  elseif laststatus == 3 then
    vim.opt.laststatus = 0
    status = "off"
  end
  ui_notify(string.format("statusline %s", status))
end

--- Toggle signcolumn="auto"|"no"
function v.ui.toggle_signcolumn()
  if vim.wo.signcolumn == "no" then
    vim.wo.signcolumn = "yes"
  elseif vim.wo.signcolumn == "yes" then
    vim.wo.signcolumn = "auto"
  else
    vim.wo.signcolumn = "no"
  end
  ui_notify(string.format("signcolumn=%s", vim.wo.signcolumn))
end

--- Set the indent and tab related numbers
function v.ui.set_indent()
  local input_avail, input = pcall(fn.input, "Set indent value (>0 expandtab, <=0 noexpandtab): ")
  if input_avail then
    local indent = tonumber(input)
    if not indent or indent == 0 then return end
    vim.bo.expandtab = (indent > 0) -- local to buffer
    indent = math.abs(indent)
    vim.bo.tabstop = indent -- local to buffer
    vim.bo.softtabstop = indent -- local to buffer
    vim.bo.shiftwidth = indent -- local to buffer
    ui_notify(string.format("indent=%d %s", indent, vim.bo.expandtab and "expandtab" or "noexpandtab"))
  end
end

--- Change the number display modes
function v.ui.change_number()
  local number = vim.wo.number -- local to window
  local relativenumber = vim.wo.relativenumber -- local to window
  if not number and not relativenumber then
    vim.wo.number = true
  elseif number and not relativenumber then
    vim.wo.relativenumber = true
  elseif number and relativenumber then
    vim.wo.number = false
  else -- not number and relativenumber
    vim.wo.relativenumber = false
  end
  ui_notify(string.format("number %s, relativenumber %s", bool2str(vim.wo.number), bool2str(vim.wo.relativenumber)))
end

--- Toggle spell
function v.ui.toggle_spell()
  vim.wo.spell = not vim.wo.spell -- local to window
  ui_notify(string.format("spell %s", bool2str(vim.wo.spell)))
end

--- Toggle paste
function v.ui.toggle_paste()
  vim.opt.paste = not vim.opt.paste:get() -- local to window
  ui_notify(string.format("paste %s", bool2str(vim.opt.paste:get())))
end

--- Toggle wrap
function v.ui.toggle_wrap()
  vim.wo.wrap = not vim.wo.wrap -- local to window
  ui_notify(string.format("wrap %s", bool2str(vim.wo.wrap)))
end

--- Toggle syntax highlighting and treesitter
function v.ui.toggle_syntax()
  local ts_avail, parsers = pcall(require, "nvim-treesitter.parsers")
  if vim.g.syntax_on then -- global var for on//off
    if ts_avail and parsers.has_parser() then vim.cmd.TSBufDisable "highlight" end
    vim.cmd.syntax "off" -- set vim.g.syntax_on = false
  else
    if ts_avail and parsers.has_parser() then vim.cmd.TSBufEnable "highlight" end
    vim.cmd.syntax "on" -- set vim.g.syntax_on = true
  end
  ui_notify(string.format("syntax %s", bool2str(vim.g.syntax_on)))
end

--- Toggle URL/URI syntax highlighting rules
function v.ui.toggle_url_match()
  vim.g.highlighturl_enabled = not vim.g.highlighturl_enabled
  v.set_url_match()
end

--#endregion_ui

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------



---Status




---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--#region_status


require "status"


--#endregion_status
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

---git


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--#region_git

-- local git = re "core.utils.git"


local git = { url = "https://github.com/" }

--- Run a git command from the v installation directory
-- @param args the git arguments
-- @return the result of the command or nil if unsuccessful
function git.cmd(args, ...) return v.cmd("git -C " .. v.install.home .. " " .. args, ...) end

--- Check if the v is able to reach the `git` command
-- @return the result of running `git --help`
function git.available() return fn.executable "git" == 1 end

--- Check if the v home is a git repo
-- @return the result of the command
function git.is_repo() return git.cmd("rev-parse --is-inside-work-tree", false) end

--- Fetch git remote
-- @param remote the remote to fetch
-- @return the result of the command
function git.fetch(remote, ...) return git.cmd("fetch " .. remote, ...) end

--- Pull the git repo
-- @return the result of the command
function git.pull(...) return git.cmd("pull --rebase", ...) end

--- Checkout git target
-- @param dest the target to checkout
-- @return the result of the command
function git.checkout(dest, ...) return git.cmd("checkout " .. dest, ...) end

--- Hard reset to a git target
-- @param dest the target to hard reset to
-- @return the result of the command
function git.hard_reset(dest, ...) return git.cmd("reset --hard " .. dest, ...) end

--- Check if a branch contains a commit
-- @param remote the git remote to check
-- @param branch the git branch to check
-- @param commit the git commit to check for
-- @return the result of the command
function git.branch_contains(remote, branch, commit, ...)
  return git.cmd("merge-base --is-ancestor " .. commit .. " " .. remote .. "/" .. branch, ...) ~= nil
end

--- Add a git remote
-- @param remote the remote to add
-- @param url the url of the remote
-- @return the result of the command
function git.remote_add(remote, url, ...) return git.cmd("remote add " .. remote .. " " .. url, ...) end

--- Update a git remote URL
-- @param remote the remote to update
-- @param url the new URL of the remote
-- @return the result of the command
function git.remote_update(remote, url, ...) return git.cmd("remote set-url " .. remote .. " " .. url, ...) end

--- Get the URL of a given git remote
-- @param remote the remote to get the URL of
-- @return the url of the remote
function git.remote_url(remote, ...) return v.trim_or_nil(git.cmd("remote get-url " .. remote, ...)) end

--- Get the current version with git describe including tags
-- @return the current git describe string
function git.current_version(...) return v.trim_or_nil(git.cmd("describe --tags", ...)) end

--- Get the current branch
-- @return the branch of the v installation
function git.current_branch(...) return v.trim_or_nil(git.cmd("rev-parse --abbrev-ref HEAD", ...)) end

--- Get the current head of the git repo
-- @return the head string
function git.local_head(...) return v.trim_or_nil(git.cmd("rev-parse HEAD", ...)) end

--- Get the current head of a git remote
-- @param remote the remote to check
-- @param branch the branch to check
-- @return the head string of the remote branch
function git.remote_head(remote, branch, ...)
  return v.trim_or_nil(git.cmd("rev-list -n 1 " .. remote .. "/" .. branch, ...))
end

--- Get the commit hash of a given tag
-- @param tag the tag to resolve
-- @return the commit hash of a git tag
function git.tag_commit(tag, ...) return v.trim_or_nil(git.cmd("rev-list -n 1 " .. tag, ...)) end

--- Get the commit log between two commit hashes
-- @param start_hash the start commit hash
-- @param end_hash the end commit hash
-- @return an array like table of commit messages
function git.get_commit_range(start_hash, end_hash, ...)
  local range = ""
  if start_hash and end_hash then range = start_hash .. ".." .. end_hash end
  local log = git.cmd('log --no-merges --pretty="format:[%h] %s" ' .. range, ...)
  return log and fn.split(log, "\n") or {}
end

--- Get a list of all tags with a regex filter
-- @param search a regex to search the tags with (defaults to "v*" for version tags)
-- @return an array like table of tags that match the search
function git.get_versions(search, ...)
  local tags = git.cmd('tag -l --sort=version:refname "' .. (search == "latest" and "v*" or search) .. '"', ...)
  return tags and fn.split(tags, "\n") or {}
end

--- Get the latest version of a list of versions
-- @param versions a list of versions to search (defaults to all versions available)
-- @return the latest version from the array
function git.latest_version(versions, ...)
  if not versions then versions = git.get_versions(...) end
  return versions[#versions]
end

--- Parse a remote url
-- @param str the remote to parse to a full git url
-- @return the full git url for the given remote string
function git.parse_remote_url(str)
  return fn.match(str, v.url_matcher) == -1
      and git.url .. str .. (fn.match(str, "/") == -1 and "/v.git" or ".git")
      or str
end

--- Check if a Conventional Commit commit message is breaking or not
-- @param commit a commit message
-- @return boolean true if the message is breaking, false if the commit message is not breaking
function git.is_breaking(commit) return fn.match(commit, "\\[.*\\]\\s\\+\\w\\+\\((\\w\\+)\\)\\?!:") ~= -1 end

--- Get a list of breaking commits from commit messages using Conventional Commit standard
-- @param commits an array like table of commit messages
-- @return an array like table of commits that are breaking
function git.breaking_changes(commits) return vim.tbl_filter(git.is_breaking, commits) end

--- Generate a table of commit messages for neovim's echo API with highlighting
-- @param commits an array like table of commit messages
-- @return an array like table of echo messages to provide to nvim_echo or v.echo
function git.pretty_changelog(commits)
  local changelog = {}
  for _, commit in ipairs(commits) do
    local hash, type, msg = commit:match "(%[.*%])(.*:)(.*)"
    if hash and type and msg then
      vim.list_extend(
        changelog,
        { { hash, "DiffText" }, { type, git.is_breaking(commit) and "DiffDelete" or "DiffChange" }, { msg }, { "\n" } }
      )
    end
  end
  return changelog
end

-- return git

--#endregion_git
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--mason

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--#region_mason
-- re "core.utils.mason"

v.mason = {}

--- Update a mason package
-- @param pkg_name string of the name of the package as defined in Mason (Not mason-lspconfig or mason-null-ls)
-- @param auto_install boolean of whether or not to install a package that is not currently installed (default: True)
function v.mason.update(pkg_name, auto_install)
  if auto_install == nil then auto_install = true end
  local registry_avail, registry = pcall(require, "mason-registry")
  if not registry_avail then
    vim.api.nvim_err_writeln "Unable to access mason registry"
    return
  end

  local pkg_avail, pkg = pcall(registry.get_package, pkg_name)
  if not pkg_avail then
    v.notify(("Mason: %s is not available"):format(pkg_name), "error")
  else
    if not pkg:is_installed() then
      if auto_install then
        v.notify(("Mason: Installing %s"):format(pkg.name))
        pkg:install()
      else
        v.notify(("Mason: %s not installed"):format(pkg.name), "warn")
      end
    else
      pkg:check_new_version(function(update_available, version)
        if update_available then
          v.notify(("Mason: Updating %s to %s"):format(pkg.name, version.latest_version))
          pkg:install():on("closed", function() v.notify(("Mason: Updated %s"):format(pkg.name)) end)
        else
          v.notify(("Mason: No updates available for %s"):format(pkg.name))
        end
      end)
    end
  end
end

--- Update all packages in Mason
function v.mason.update_all()
  local registry_avail, registry = pcall(require, "mason-registry")
  if not registry_avail then
    vim.api.nvim_err_writeln "Unable to access mason registry"
    return
  end

  local any_pkgs = false
  local running = 0
  local updated = false
  v.notify "Mason: Checking for package updates..."

  for _, pkg in ipairs(registry.get_installed_packages()) do
    any_pkgs = true
    running = running + 1
    pkg:check_new_version(function(update_available, version)
      if update_available then
        updated = true
        running = running - 1
        v.notify(("Mason: Updating %s to %s"):format(pkg.name, version.latest_version))
        pkg:install():on("closed", function()
          running = running - 1
          if running == 0 then
            v.notify "Mason: Update Complete"
            v.event "MasonUpdateComplete"
          end
        end)
      else
        running = running - 1
        if running == 0 then
          if updated then
            v.notify "Mason: Update Complete"
          else
            v.notify "Mason: No updates available"
          end
          v.event "MasonUpdateComplete"
        end
      end
    end)
  end
  if not any_pkgs then
    v.notify "Mason: No updates available"
    v.event "MasonUpdateComplete"
  end
end

-- return v.mason
--#endregion_mason
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------









































---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- re "core.utils.lsp"

v.lsp = {}
-- local user_plugin_opts = v.user_plugin_opts
-- local setup_handlers = nil
-- user_plugin_opts("lsp.setup_handlers", nil, false)
v.lsp.skip_setup = {
  "fsautocomplete",
  "tsserver",
  "clangd",
}

v.lsp.formatting =
-- v.user_plugin_opts("lsp.formatting", { format_on_save = { enabled = true }, disabled = {} })
{ format_on_save = {
  enabled = true,
  disabled = {
    "ionide",
    "null-ls",
    "lemminx"
  },
  ignore_filetypes = {
    "fsharp",
    "fsharp_project",
    "xml"
  },
},
}


function v.path.UpperDriveLetter(p)
  local stringArg = p or ""
  return (stringArg:gsub("^%l", string.upper))
end

v.path.GetDirForFilename = function(s)
  return vim.fs.dirname(s)
end

v.path.GetBaseFilenameForBufnr = function(bufnr)
  local fileAbs = vim.api.nvim_buf_get_name(bufnr)
  return vim.fs.basename(fileAbs)
end

v.buf.FileRowColumnToPlusRegister = function()
  local fileAbs = vim.api.nvim_buf_get_name(0)
  local fname = vim.fs.basename(fileAbs)
  local line_col_pair = vim.api.nvim_win_get_cursor(0) -- row is 1, column is 0 indexed
  local fnamecol = fname .. ':' .. tostring(line_col_pair[1]) .. ':' .. tostring(line_col_pair[2])
  fn.setreg('+', fnamecol) -- register + has filename:row:column
end


if type(v.lsp.formatting.format_on_save) == "boolean" then
  v.lsp.formatting.format_on_save = { enabled = v.lsp.formatting.format_on_save }
end
v.lsp.format_opts = vim.deepcopy(v.lsp.formatting)
v.lsp.format_opts.filter = function(client)
  local filter = v.lsp.formatting.filter
  local disabled = v.lsp.formatting.disabled or {}
  --v.lsp.format_opts.format_on_save = nil
  --v.lsp.format_opts.disabled = nil
  -- check if client is fully disabled or filtered by function
  return not (tContains(disabled, client.name) or (type(filter) == "function" and not filter(client)))
end


v.path.AppendSlash = function(str)
  if str and (not str == "") then
    if string.sub(str, -1) ~= "/" then
      return str .. "/"
    end
  end
  return str
end

---- The default v LSP capabilities
v.lsp.capabilities = vim.lsp.protocol.make_client_capabilities()
v.lsp.capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown", "plaintext" }
v.lsp.capabilities.textDocument.completion.completionItem.snippetSupport = true
v.lsp.capabilities.textDocument.completion.completionItem.preselectSupport = true
v.lsp.capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
v.lsp.capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
v.lsp.capabilities.textDocument.completion.completionItem.deprecatedSupport = true
v.lsp.capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
v.lsp.capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
v.lsp.capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}

-- lua switch fname function() to function fname()  lsp

--- The `on_attach` function used by v
-- @param client the LSP client details when attaching
-- @param bufnr the number of the buffer that the LSP client is attaching to
v.lsp.on_attach = function(client, bufnr)
  -- if not tEmpty(lsp_mappings.v) then lsp_mappings.v["<leader>l"] = { name = "LSP" } end
  -- v.set_mappings(user_plugin_opts("lsp.mappings", lsp_mappings), { buffer = bufnr })

  local ignored = { "null-ls", "stylua", "lemminx", "editorconfig_checker" }
  -- local ignored = v.lsp.ignoredLspServersForFindingRoot
  -- v.notify(client.name .. " is running on_attach")
  -- v.notify(vim.inspect(ignored) .. " are servers being ignored")
  -- local on_attach_override = user_plugin_opts("lsp.on_attach", nil, false)
  -- conditional_func(on_attach_override, true, client, bufnr)
  local capabilities = client.server_capabilities
  -- vim.notify(client.name .. " is running on_attach")
  if not tContains(ignored, client.name) then
    -- if client.name ~= "null-ls" and client.name ~= "stylua" and client.name ~= "lemminx" then
    local root = v.FindRoot(ignored, bufnr)
    -- v.notify("lsp root should have found root of : " .. root)
    local cwd = v.stringReplace(v.path.AppendSlash(v.path.UpperDriveLetter(vim.fs.normalize(fn.getcwd() .. "/"))), "//"
      , "/")
    if not root then
      v.notify("lsp says it didn't find a root??? I'd go check that one out.. setting temporary root to current buffer's parent dir, but don't think that means that lsp is healthy right now.. you've been warned! ")
      root = vim.cmd.expand("%:p:h")
    end
    -- v.notify("i have the root and cwd now.. but ill check the number of buffers.. ")
    local shouldAsk = vim.tbl_count(fn.getbufinfo { buflisted = true }) > 1
    if root and cwd ~= root then
      if shouldAsk == true then
        -- v.notify("at this point the buffers say i should ask about setting root.. " .. vim.inspect(shouldAsk))
        if fn.confirm(
          "Do you want to change the current working directory to lsp root?\nROOT: "
          .. root
          .. "\nCWD : "
          .. cwd
          .. "\n",
          "&yes\n&no",
          2
        ) == 1
        then
          vim.cmd("cd " .. root)
          v.notify("CWD : " .. root)
        end
      else

        vim.cmd("cd " .. root)
        v.notify("CWD : " .. root)
      end
      vim.g["dotnet_last_proj_path"] = root
      -- vim.g.dotnet_startup_proj_path = client.root
      vim.g["dotnet_last_dll_path"] = root .. "bin/debug/"
    end

    local lsp_mappings = {
      n = {
        ["<leader>ld"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" },
        ["gN"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" },
        ["gn"] = { function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" },
        ["gl"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" },
      },
      v = {},
    }

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


    local dotnetClients = {
      "ionide", "fsautocomplete", "fsharp-language-server", "omnisharp", "omnisharpMono", "csharpLanguageServer"
    }
    if tContains(dotnetClients, client.name) then

      -- lsp_mappings.n.l["b"] = { desc = "build dotnet..." }
      -- lsp_mappings.n["<leader>lbd"] = { function() v.notify("I haven't implemented this yet. ") end,
      --   desc = "dotnet build debug" }
      -- lsp_mappings.n["<leader>lbr"] = { function() v.notify("I haven't implemented this yet. ") end,
      --   desc = "dotnet build release" }
      -- lsp_mappings.n["<leader>lbp"] = { function() v.notify("I haven't implemented this yet. ") end,
      --   desc = "dotnet publish" }
      -- lsp_mappings.n["<leader>lbR"] = { function() v.notify("I haven't implemented this yet. ") end,
      --   desc = "dotnet run" }
    end


    lsp_mappings.n["<leader>lI"] = { function() vim.api.nvim_cmd({ cmd = "LspRestart" }, {}) end,
      desc = "LSP reInitialize" }

    if capabilities.codeActionProvider then
      lsp_mappings.n["<leader>la"] = { function() vim.lsp.buf.code_action() end, desc = "LSP code action" }
      lsp_mappings.v["<leader>la"] = lsp_mappings.n["<leader>la"]
    end

    if capabilities.declarationProvider then
      lsp_mappings.n["gD"] = { function() vim.lsp.buf.declaration() end, desc = "Declaration of current symbol" }
    end

    if capabilities.definitionProvider then
      lsp_mappings.n["gd"] = { function() vim.lsp.buf.definition() end, desc = "Show the definition of current symbol" }
    end

    if capabilities.documentFormattingProvider then
      lsp_mappings.n["<leader>lf"] = {
        function() vim.lsp.buf.format(v.lsp.format_opts) end,
        desc = "Format code",
      }
      lsp_mappings.v["<leader>lf"] = lsp_mappings.n["<leader>lf"]
      vim.api.nvim_buf_create_user_command(
        bufnr,
        "Format",
        function() vim.lsp.buf.format(v.lsp.format_opts) end,
        { desc = "Format file with LSP" }
      )

      local autoformat = v.lsp.formatting.format_on_save
      local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
      if autoformat.enabled
          and (tEmpty(autoformat.allow_filetypes or {}) or tContains(autoformat.allow_filetypes, filetype))
          and
          (tEmpty(autoformat.ignore_filetypes or {}) or not tContains(autoformat.ignore_filetypes, filetype)
          )
      then
        local autocmd_group = "auto_format_" .. bufnr
        vim.api.nvim_create_augroup(autocmd_group, { clear = true })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = autocmd_group,
          buffer = bufnr,
          desc = "Auto format buffer " .. bufnr .. " before save",
          callback = function()
            if vim.g.autoformat_enabled then
              vim.lsp.buf.format(v.default_tbl({ bufnr = bufnr }, v.lsp.format_opts))
            end
          end,
        })
        lsp_mappings.n["<leader>uf"] = {
          function() v.ui.toggle_autoformat() end,
          desc = "Toggle autoformatting",
        }
      end
    end

    if capabilities.hoverProvider then
      if v.isAvalable("hover") then
        lsp_mappings.n["K"] = { require 'hover'.hover(), desc = "Hover symbol details" }
      else
        lsp_mappings.n["K"] = { function() vim.lsp.buf.hover() end, desc = "Hover symbol details" }
      end
    end

    if capabilities.documentHighlightProvider then
      local highlight_name = fn.printf("lsp_document_highlight_%d", bufnr)
      vim.api.nvim_create_augroup(highlight_name, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = highlight_name,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.document_highlight()
        end
        ,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = highlight_name,
        buffer = bufnr,
        callback = function() vim.lsp.buf.clear_references() end,
      })
    end


    if capabilities.codeLensProvider then
      vim.defer_fn(function()
        -- v.notify("now calling first codelens refresh..")
        vim.lsp.codelens.refresh()
      end, 4000)
      local group_name = "codelens_" .. bufnr
      vim.api.nvim_create_augroup(group_name, { clear = true })
      -- default VimSharpvim version
      --vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      vim.api.nvim_create_autocmd({ "LSPAttach", "BufEnter", "BufWritePost", "InsertLeave" }, {
        --vim.api.nvim_create_autocmd({ "BufWrite" }, {
        group = group_name,
        callback = function() vim.lsp.codelens.refresh() end,
        buffer = bufnr,
      })
    end

    if capabilities.implementationProvider then
      lsp_mappings.n["gI"] = { function() vim.lsp.buf.implementation() end, desc = "Implementation of current symbol" }
    end

    if capabilities.referencesProvider then
      lsp_mappings.n["gr"] = { function() vim.lsp.buf.references() end, desc = "References of current symbol" }
      -- lsp_mappings.n["<leader>lR"] = { function() vim.lsp.buf.references() end, desc = "Search references" }
    end

    if capabilities.renameProvider then
      lsp_mappings.n["<leader>lr"] = { function() vim.lsp.buf.rename() end, desc = "Rename current symbol" }
    end

    if capabilities.signatureHelpProvider then
      lsp_mappings.n["<leader>lh"] = { function() vim.lsp.buf.signature_help() end, desc = "Signature help" }
    end

    if capabilities.typeDefinitionProvider then
      lsp_mappings.n["gT"] = { function() vim.lsp.buf.type_definition() end, desc = "Definition of current type" }
    end

    if capabilities.workspaceSymbolProvider then
      lsp_mappings.n["<leader>lG"] = { function() vim.lsp.buf.workspace_symbol() end, desc = "Search workspace symbols" }
    end

    if v.isAvalable "telescope.nvim" then -- setup telescope mappings if available

      if lsp_mappings.n.gd then lsp_mappings.n.gd[1] = function() require("telescope.builtin").lsp_definitions() end end
      if lsp_mappings.n.gI then lsp_mappings.n.gI[1] = function() require("telescope.builtin").lsp_implementations() end end
      if lsp_mappings.n.gr then lsp_mappings.n.gr[1] = function() require("telescope.builtin").lsp_references() end end
      if lsp_mappings.n["<leader>lR"] then lsp_mappings.n["<leader>lR"][1] = function() require("telescope.builtin").lsp_references() end end
      if lsp_mappings.n.gT then lsp_mappings.n.gT[1] = function() require("telescope.builtin").lsp_type_definitions() end end
      if lsp_mappings.n["<leader>lG"] then lsp_mappings.n["<leader>lG"][1] = function() require("telescope.builtin").lsp_workspace_symbols() end end

    end

    if not tEmpty(lsp_mappings.v) then lsp_mappings.v["<leader>l"] = { name = "LSP" } end
    v.set_mappings(lsp_mappings, { buffer = bufnr })

  end
end

v.lsp.configs = {
  clangd = { capabilities = { offsetEncoding = "utf-8" } },
  ionide = {

    -- cmd = { 'fsautocomplete', '--adaptive-lsp-server-enabled', '-v' },
    cmd = (function()
      -- local ok, m = pcall(require, "mason")
      -- if ok then
      -- local m =require("mason-lspconfig").get_available_servers()["fsautocomplete"]
      -- local path = stdpath("data") .. "mason/packages/fsautocomplete/fsautocomplete.exe"
      -- local path = [[C:\.local\share\nvim-data\mason\bin\fsautocomplete.CMD]]
      -- v.notify("passing through path of " .. path)
      -- v.notify("config for ionide, mason was available, passing through path of " .. path)
      -- return { path, '--adaptive-lsp-server-enabled', '-v' }
      -- else
      -- v.notify("config for ionide, mason was not available, default of fsautocomplete for first arg ")
      return { 'fsautocomplete', '--adaptive-lsp-server-enabled', '-v' }
      -- end
    end)(),
    on_attach = v.lsp.on_attach,

    -- handlers = re "ionide".handlers,
    settings = { FSharp = { UseSdkScripts = false }, },
    -- root_dir = function(fname)
    --   local util = re("lspconfig.util")
    --   local get_root_dir = function(filename, _)
    --     local root
    --     -- in order of preference:
    --     -- * git repository root
    --     -- * directory containing a solution file
    --     -- * directory containing an fsproj file
    --     -- * directory with fsx scripts
    --     root = util.find_git_ancestor(filename)
    --     root = root or util.root_pattern("*.sln")
    --     root = root or util.root_pattern("*.fsproj")
    --     root = root or util.root_pattern("*.fsx")
    --     return root
    --   end
    --   return get_root_dir(fname)
    -- end,
  },
  yamlls = {
    settings = {
      yaml = {
        schemas = {
          ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
          ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
          ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
        },
      },
    },
  }



}

-- v.lsp.capabilities = user_plugin_opts("lsp.capabilities", v.lsp.capabilities)
v.lsp.flags = {} -- Helper function to set up a given server with the Neovim LSP client
-- @param server the name of the server to be setup
v.lsp.setup = function(server)
  if not tContains(v.lsp.skip_setup, server) then
    executeIfTrue(require, server == "sumneko_lua" and v.isAvalable "neodev.nvim", "neodev") -- setup neodev for sumneko_lua
    if server == "fsautocomplete" then

      return
    end
    if server == "ionide" then
      -- vim.cmd("let g:fsharp#use_recommended_server_config =0")
      -- vim.cmd("let g:fsharp#use_sdk_scripts =0")

      local i = require "ionide".setup(v.lsp.configs.ionide)

      -- local isAttachd = fn.confirm("Do you want to attachDebuggr before ionide does setup??\n", "&yes\n&no", 2) == 1
      -- re "ionide".setup(v.lsp.configs.ionide)
    end
    -- if server doesn't exist, set it up from user server definition
    local configs = require("lspconfig.configs")
    --local server_definition = fn.default
    local ok, sv = pcall(require, "lspconfig.configs" .. server)
    if ok then
      local fallbackmessage = " one found in " .. server .. " config handlers"

      v.notify("server ok.")
      if sv.default_config then
        v.notify("server default config exists.")
      end
      if sv.default_config.handlers then
        v.notify("server default config handlers exist.")
        for n, h in pairs(sv.handlers) do
          if tContains(vim.lsp.handlers, n) then
            v.notify("overriding default vim.lsp.handlers." .. n .. " with " .. vim.pretty_print(h) or
              fallbackmessage)
            v.lsp.handlers[n] = h
          end
        end
      end

    end

    if not (configs[server]) and not require("lspconfig.server_configurations." .. server) then
      v.notify(server .. " was not found in lspconfig.configs or server_configurations.. ")
      local server_definition = v.userConfigs("lsp.server-settings." .. server)
      if server_definition.cmd then
        configs[server] = { default_config = server_definition }
      end

    end
  end
  local opts = v.lsp.server_settings(server)

  if type(setup_handlers) == "function" then
    setup_handlers(server, opts)
  elseif type(setup_handlers) == "table" and (setup_handlers[1] or setup_handlers[server]) then
    (setup_handlers[server] or setup_handlers[1])(server, opts)
  else
    local lspconfig = require("lspconfig")
    lspconfig[server].setup(opts)
  end

  if server == "ionide" then
    -- v.notify(vim.inspect(require 'lspconfig.configs'["ionide"]))
  end


end




--- Get the server settings for a given language server to be provided to the server's `setup()` call
-- @param  server_name the name of the server
-- @return the table of LSP options used when setting up the given language server
function v.lsp.server_settings(server_name)

  local server = require("lspconfig")[server_name]
  local lsp_settings
  if server_name == "jsonls" and v.isAvalable "SchemaStore.nvim" then -- by default add json schemas
    lsp_settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } }
  end

  local de = vim.tbl_deep_extend
  local upo = de("force", v.userConfigs("lsp.configs." .. server_name), server) -- get user server-settings

  local defaultServerWithvSettings = de("force",
    { settings = lsp_settings, capabilities = v.lsp.capabilities, flags = v.lsp.flags }
    ,
    { capabilities = server.capabilities, flags = server.flags }
  )
  local opts =
  de("force", defaultServerWithvSettings, upo)


  local old_on_attach = server.on_attach
  local user_on_attach = opts.on_attach
  opts.on_attach = function(client, bufnr)
    v.executeIfTrue(old_on_attach, true, client, bufnr)
    v.lsp.on_attach(client, bufnr)
    v.executeIfTrue(user_on_attach, true, client, bufnr)
  end


  return opts
end

-- return v.lsp

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--   "core.options",
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--#region_options

vim.opt.shortmess:append { s = true, I = true } -- disable startup message
-- if fn.has "nvim-0.9" == 1 then -- TODO v3 REMOVE THIS CONDITIONAL
--   vim.opt.diffopt:append "linematch:60" -- enable linematch diff algorithm
-- end
v.vim_opts({
  opt = {
    backspace = vim.opt.backspace + { "nostop" }, -- Don't stop backspace at insert
    clipboard = "unnamedplus", -- Connection to the system clipboard
    cmdheight = 0, -- hide command line unless needed
    completeopt = { "menuone", "noselect" }, -- Options for insert mode completion
    copyindent = true, -- Copy the previous indentation on autoindenting
    cursorline = true, -- Highlight the text line of the cursor
    expandtab = true, -- Enable the use of space in tab
    fileencoding = "utf-8", -- File content encoding for the buffer
    fillchars = { eob = " " }, -- Disable `~` on nonexistent lines
    history = 100, -- Number of commands to remember in a history table
    ignorecase = true, -- Case insensitive searching
    laststatus = 3, -- globalstatus
    mouse = "a", -- Enable mouse support
    number = true, -- Show numberline
    preserveindent = true, -- Preserve indent structure as much as possible
    pumheight = 10, -- Height of the pop up menu
    relativenumber = true, -- Show relative numberline
    scrolloff = 8, -- Number of lines to keep above and below the cursor
    shiftwidth = 2, -- Number of space inserted for indentation
    showmode = false, -- Disable showing modes in command line
    showtabline = 2, -- always display tabline
    sidescrolloff = 8, -- Number of columns to keep at the sides of the cursor
    signcolumn = "yes", -- Always show the sign column
    smartcase = true, -- Case sensitivie searching
    splitbelow = true, -- Splitting a new window below the current one
    -- TODO v3 REMOVE THIS CONDITIONAL
    -- splitkeep = fn.has "nvim-0.9" == 1 and "screen" or nil, -- Maintain code view when splitting
    splitright = true, -- Splitting a new window at the right of the current one
    tabstop = 2, -- Number of space in a tab
    termguicolors = true, -- Enable 24-bit RGB color in the TUI
    timeoutlen = 300, -- Length of time to wait for a mapped sequence
    undofile = true, -- Enable persistent undo
    updatetime = 50, -- Length of time to wait before triggering the plugin

    writebackup = false, -- Disable making a backup before overwriting a file
    linebreak = true, -- linebreak soft wrap at words
    list = true, -- show whitespace characters
    listchars = { tab = "│→", extends = "⟩", precedes = "⟨", trail = "·", nbsp = "␣" },
    showbreak = "↪ ",
    spellfile = fn.expand "C:/.config/nvim/lua/spell/en.utf-8.add",
    thesaurus = fn.expand "C:/.config/nvim/lua/spell/mthesaur.txt",
    wrap = true, -- soft wrap lines
    shell = "pwsh",
    shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
    shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
    shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
    shellquote = "",
    shellxquote = "",
    sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }


  },
  g = {
    keywordprg = ":help", --Windows will choke on ":Man" for whatever reason.
    highlighturl_enabled = true, -- highlight URLs by default
    mapleader = " ", -- set leader key
    autoformat_enabled = true, -- enable or disable auto formatting at start (lsp.formatting.format_on_save must be enabled)
    lsp_handlers_enabled = true, -- enable or disable default vim.lsp.handlers (hover and signatureHelp)
    cmp_enabled = true, -- enable completion at start
    autopairs_enabled = true, -- enable autopairs at start
    diagnostics_enabled = true, -- enable diagnostics at start
    status_diagnostics_enabled = true, -- enable diagnostics in statusline
    icons_enabled = true, -- disable icons in the UI (disable if no nerd font is available)
    ui_notifications_enabled = true, -- disable notifications when toggling UI elements
  },
  t = {
    bufs = vim.tbl_filter(v.is_valid_buffer, vim.api.nvim_list_bufs()), -- buffers in tab
  },
})



--#endregion_options
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--   "core.plugins",
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--#region_plugins



---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------


---Lazy stuff.

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--#region_Lazy

local lazypath = fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  fn.system { "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath }
  fn.system { "git", "-C", lazypath, "checkout", "tags/stable" }
  local oldcmdheight = vim.opt.cmdheight:get()
  vim.opt.cmdheight = 1
  vim.notify "Please wait while plugins are installed..."
  vim.api.nvim_create_autocmd("User", {
    once = true,
    pattern = "LazyInstall",
    callback = function()
      vim.cmd.bw()
      vim.opt.cmdheight = oldcmdheight
      vim.tbl_map(function(module) pcall(require, module) end, { "nvim-treesitter", "mason" })
      v.notify "Mason is installing packages if configured, check status with :Mason"
    end,
  })
end
vim.opt.rtp:prepend(lazypath)

local function parse_plugins(plugins)
  local new_plugins = {}
  local idx = 1
  for key, plugin in pairs(plugins) do
    if type(key) == "string" and not plugin[1] then plugin[1] = key end
    if plugin.dependencies then plugin.dependencies = parse_plugins(plugin.dependencies) end
    new_plugins[idx] = plugin
    idx = idx + 1
  end
  return new_plugins
end

local function pin_plugins(plugins)
  -- if not v.updater.snapshot then return plugins end
  -- for plugin, options in pairs(plugins) do
  --   local pin = v.updater.snapshot[plugin:match "/([^/]*)$"]
  --   if pin and pin.commit and not (options.version or options.commit) then
  --     options.commit = pin.commit
  --     options.branch = pin.branch
  --     if plugin.dependencies then plugin.dependencies = pin_plugins(plugin.dependencies) end
  --   end
  -- end
  return plugins
end

require("lazy").setup(
  parse_plugins(

  -- v.user_plugin_opts(
  -- "plugins.init",

  -- pin_plugins
    {
      ["MTDL9/vim-log-highlighting"] = {},
      ["leafo/moonscript-vim"] = {},
      ["eandrju/cellular-automaton.nvim"] = {},
      ["folke/lazy.nvim"] = { version = "^7" },
      ["b0o/SchemaStore.nvim"] = {},
      ["nvim-lua/plenary.nvim"] = {},
      ["folke/neodev.nvim"] = { config = function()
        require("neodev").setup({})
      end },
      -- ["goolord/alpha-nvim"] = { cmd = "Alpha",
      -- config = function()
      --   re "configs.alpha"
      -- end },

      ["mrjones2014/smart-splits.nvim"] = {
        config = function()
          -- re "configs.smart-splits"
          return {
            ignored_filetypes = {
              "nofile",
              "quickfix",
              "qf",
              "prompt",
            },
            ignored_buftypes = { "nofile" },
          }
        end
      },

      ["onsails/lspkind.nvim"] = { enabled = vim.g.icons_enabled,
        config = function()
          -- re "configs.lspkind"
          v.lspkind = {
            mode = "symbol_text",
            symbol_map = {
              NONE = "",
              Variables = "V",
              Array = "",
              Boolean = "⊨",
              Class = "",
              Constructor = "",
              Key = "",
              Namespace = "",
              Null = "NULL",
              Number = "#",
              Object = "⦿",
              Package = "",
              Property = "",
              Reference = "",
              Snippet = "",
              String = "𝓐",
              TypeParameter = "",
              Unit = "",
            },
          }
          require("lspkind").init(v.lspkind)


        end },
      ["rebelot/heirline.nvim"] = { event = "VimEnter", config = function()
        -- re "configs.heirline"
        local heirline = require "heirline"
        if not v.status then return end
        local C = require "vimsharp_theme.colors"

        local function setup_colors()
          local Normal = v.highlight.getGroup("Normal", { fg = C.fg, bg = C.bg })
          local Comment = v.highlight.getGroup("Comment", { fg = C.grey_2, bg = C.bg })
          local Error = v.highlight.getGroup("Error", { fg = C.red, bg = C.bg })
          local StatusLine = v.highlight.getGroup("StatusLine", { fg = C.fg, bg = C.grey_4 })
          local TabLine = v.highlight.getGroup("TabLine", { fg = C.grey, bg = C.none })
          local TabLineSel = v.highlight.getGroup("TabLineSel", { fg = C.fg, bg = C.none })
          local WinBar = v.highlight.getGroup("WinBar", { fg = C.grey_2, bg = C.bg })
          local WinBarNC = v.highlight.getGroup("WinBarNC", { fg = C.grey, bg = C.bg })
          local Conditional = v.highlight.getGroup("Conditional", { fg = C.purple_1, bg = C.grey_4 })
          local String = v.highlight.getGroup("String", { fg = C.green, bg = C.grey_4 })
          local TypeDef = v.highlight.getGroup("TypeDef", { fg = C.yellow, bg = C.grey_4 })
          local GitSignsAdd = v.highlight.getGroup("GitSignsAdd", { fg = C.green, bg = C.grey_4 })
          local GitSignsChange = v.highlight.getGroup("GitSignsChange", { fg = C.orange_1, bg = C.grey_4 })
          local GitSignsDelete = v.highlight.getGroup("GitSignsDelete", { fg = C.red_1, bg = C.grey_4 })
          local DiagnosticError = v.highlight.getGroup("DiagnosticError", { fg = C.red_1, bg = C.grey_4 })
          local DiagnosticWarn = v.highlight.getGroup("DiagnosticWarn", { fg = C.orange_1, bg = C.grey_4 })
          local DiagnosticInfo = v.highlight.getGroup("DiagnosticInfo", { fg = C.white_2, bg = C.grey_4 })
          local DiagnosticHint = v.highlight.getGroup("DiagnosticHint", { fg = C.yellow_1, bg = C.grey_4 })
          local HeirlineInactive = v.highlight.getGroup("HeirlineInactive", { fg = nil }).fg
              or v.status.hl.lualine_mode("inactive", C.grey_7)
          local HeirlineNormal = v.highlight.getGroup("HeirlineNormal", { fg = nil }).fg
              or v.status.hl.lualine_mode("normal", C.blue)
          local HeirlineInsert = v.highlight.getGroup("HeirlineInsert", { fg = nil }).fg
              or v.status.hl.lualine_mode("insert", C.green)
          local HeirlineVisual = v.highlight.getGroup("HeirlineVisual", { fg = nil }).fg
              or v.status.hl.lualine_mode("visual", C.purple)
          local HeirlineReplace = v.highlight.getGroup("HeirlineReplace", { fg = nil }).fg
              or v.status.hl.lualine_mode("replace", C.red_1)
          local HeirlineCommand = v.highlight.getGroup("HeirlineCommand", { fg = nil }).fg
              or v.status.hl.lualine_mode("command", C.yellow_1)
          local HeirlineTerminal = v.highlight.getGroup("HeirlineTerminal", { fg = nil }).fg
              or v.status.hl.lualine_mode("inactive", HeirlineInsert)

          local colors = {
            close_fg = Error.fg,
            fg = StatusLine.fg,
            bg = StatusLine.bg,
            section_fg = StatusLine.fg,
            section_bg = StatusLine.bg,
            git_branch_fg = Conditional.fg,
            mode_fg = StatusLine.bg,
            treesitter_fg = String.fg,
            scrollbar = TypeDef.fg,
            git_added = GitSignsAdd.fg,
            git_changed = GitSignsChange.fg,
            git_removed = GitSignsDelete.fg,
            diag_ERROR = DiagnosticError.fg,
            diag_WARN = DiagnosticWarn.fg,
            diag_INFO = DiagnosticInfo.fg,
            diag_HINT = DiagnosticHint.fg,
            winbar_fg = WinBar.fg,
            winbar_bg = WinBar.bg,
            winbarnc_fg = WinBarNC.fg,
            winbarnc_bg = WinBarNC.bg,
            tabline_bg = StatusLine.bg,
            tabline_fg = StatusLine.bg,
            buffer_fg = Comment.fg,
            buffer_path_fg = WinBarNC.fg,
            buffer_close_fg = Comment.fg,
            buffer_bg = StatusLine.bg,
            buffer_active_fg = Normal.fg,
            buffer_active_path_fg = WinBarNC.fg,
            buffer_active_close_fg = Error.fg,
            buffer_active_bg = Normal.bg,
            buffer_visible_fg = Normal.fg,
            buffer_visible_path_fg = WinBarNC.fg,
            buffer_visible_close_fg = Error.fg,
            buffer_visible_bg = Normal.bg,
            buffer_overflow_fg = Comment.fg,
            buffer_overflow_bg = StatusLine.bg,
            buffer_picker_fg = Error.fg,
            tab_close_fg = Error.fg,
            tab_close_bg = StatusLine.bg,
            tab_fg = TabLine.fg,
            tab_bg = TabLine.bg,
            tab_active_fg = TabLineSel.fg,
            tab_active_bg = TabLineSel.bg,
            inactive = HeirlineInactive,
            normal = HeirlineNormal,
            insert = HeirlineInsert,
            visual = HeirlineVisual,
            replace = HeirlineReplace,
            command = HeirlineCommand,
            terminal = HeirlineTerminal,
          }

          for _, section in ipairs {
            "git_branch",
            "file_info",
            "git_diff",
            "diagnostics",
            "lsp",
            "macro_recording",
            "mode",
            "cmd_info",
            "treesitter",
            "nav",
          } do
            if not colors[section .. "_bg"] then colors[section .. "_bg"] = colors["section_bg"] end
            if not colors[section .. "_fg"] then colors[section .. "_fg"] = colors["section_fg"] end
          end
          return colors
        end

        --- a submodule of heirline specific functions and aliases
        v.status.heirline = {}

        --- A helper function to get the type a tab or buffer is
        -- @param self the self table from a heirline component function
        -- @param prefix the prefix of the type, either "tab" or "buffer" (Default: "buffer")
        -- @return the string of prefix with the type (i.e. "_active" or "_visible")
        function v.status.heirline.tab_type(self, prefix)
          local tab_type = ""
          if self.is_active then
            tab_type = "_active"
          elseif self.is_visible then
            tab_type = "_visible"
          end
          return (prefix or "buffer") .. tab_type
        end

        --- Make a list of buffers, rendering each buffer with the provided component
        ---@param component table
        ---@return table
        v.status.heirline.make_buflist = function(component)
          local overflow_hl = v.status.hl.get_attributes("buffer_overflow", true)
          return require("heirline.utils").make_buflist(
            v.status.utils.surround(
              "tab",
              function(self)
                return {
                  main = v.status.heirline.tab_type(self) .. "_bg",
                  left = "tabline_bg",
                  right = "tabline_bg",
                }
              end,
              { -- bufferlist
                init = function(self) self.tab_type = v.status.heirline.tab_type(self) end,
                on_click = { -- add clickable component to each buffer
                  callback = function(_, minwid) vim.api.nvim_win_set_buf(0, minwid) end,
                  minwid = function(self) return self.bufnr end,
                  name = "heirline_tabline_buffer_callback",
                },
                { -- add buffer picker functionality to each buffer
                  condition = function(self) return self._show_picker end,
                  update = false,
                  init = function(self)
                    if not (self.label and self._picker_labels[self.label]) then
                      local bufname = v.status.provider.filename()(self)
                      local label = bufname:sub(1, 1)
                      local i = 2
                      while label ~= " " and self._picker_labels[label] do
                        if i > #bufname then break end
                        label = bufname:sub(i, i)
                        i = i + 1
                      end
                      self._picker_labels[label] = self.bufnr
                      self.label = label
                    end
                  end,
                  provider = function(self)
                    return v.status.provider.str { str = self.label, padding = { left = 1, right = 1 } }
                  end,
                  hl = v.status.hl.get_attributes "buffer_picker",
                },
                component, -- create buffer component
              },
              false-- disable surrounding
            ),
            { provider = v.get_icon "ArrowLeft" .. " ", hl = overflow_hl },
            { provider = v.get_icon "ArrowRight" .. " ", hl = overflow_hl },
            function() return vim.t.bufs end, -- use v bufs variable
            false-- disable internal caching
          )
        end

        --- Alias to re("heirline.utils").make_tablist
        v.status.heirline.make_tablist = require("heirline.utils").make_tablist

        --- Run the buffer picker and execute the callback function on the selected buffer
        -- @param callback function with a single parameter of the buffer number
        function v.status.heirline.buffer_picker(callback)
          local tabline = require("heirline").tabline
          local buflist = tabline and tabline._buflist[1]
          if buflist then
            local prev_showtabline = vim.opt.showtabline
            buflist._picker_labels = {}
            buflist._show_picker = true
            vim.opt.showtabline = 2
            vim.cmd.redrawtabline()
            local char = fn.getcharstr()
            local bufnr = buflist._picker_labels[char]
            if bufnr then callback(bufnr) end
            buflist._show_picker = false
            vim.opt.showtabline = prev_showtabline
            vim.cmd.redrawtabline()
          end
        end

        heirline.load_colors(setup_colors())
        local heirline_opts = {
          statusline = { -- statusline
            hl = { fg = "fg", bg = "bg" },
            v.status.component.mode(),
            v.status.component.git_branch(),
            v.status.component.file_info { filetype = {}, filename = false, file_modified = false },
            v.status.component.git_diff(),
            v.status.component.diagnostics(),
            v.status.component.fill(),
            v.status.component.cmd_info(),
            v.status.component.fill(),
            v.status.component.lsp(),
            v.status.component.treesitter(),
            v.status.component.nav(),
            v.status.component.mode { surround = { separator = "right" } },
          },
          winbar = { -- winbar
            static = {
              disabled = {
                buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
                filetype = { "NvimTree", "neo%-tree", "dashboard", "Outline", "aerial" },
              },
            },
            init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
            fallthrough = false,
            {
              condition = function(self)
                -- local  k, c  = pcall (vim.opt.diff:get()) or v.status.condition.buffer_matches(self.disabled or {}))
                -- local r = if k then c else false end,
                return false

              end,
              init = function() vim.opt_local.winbar = nil end,
            },
            v.status.component.file_info {
              condition = function() return not v.status.condition.is_active() end,
              unique_path = {},
              file_icon = { hl = v.status.hl.file_icon "winbar" },
              file_modified = false,
              file_read_only = false,
              hl = v.status.hl.get_attributes("winbarnc", true),
              surround = false,
              update = "BufEnter",
            },
            v.status.component.breadcrumbs { hl = v.status.hl.get_attributes("winbar", true) },
          },
          bufferline = { -- bufferline
            { -- file tree padding
              condition = function(self)
                self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
                return v.status.condition.buffer_matches(
                  { filetype = { "aerial", "dapui_.", "neo%-tree", "NvimTree" } },
                  vim.api.nvim_win_get_buf(self.winid)
                )
              end,
              provider = function(self) return string.rep(" ", vim.api.nvim_win_get_width(self.winid) + 1) end,
              hl = { bg = "tabline_bg" },
            },
            v.status.heirline.make_buflist(v.status.component.tabline_file_info()), -- component for each buffer tab
            v.status.component.fill { hl = { bg = "tabline_bg" } }, -- fill the rest of the tabline with background color
            { -- tab list
              condition = function() return #vim.api.nvim_list_tabpages() >= 2 end, -- only show tabs if there are more than one
              v.status.heirline.make_tablist { -- component for each tab
                provider = v.status.provider.tabnr(),
                hl = function(self)
                  return v.status.hl.get_attributes(v.status.heirline.tab_type(self, "tab"), true)
                end,
              },
              { -- close button for current tab
                provider = v.status.provider.close_button { kind = "TabClose",
                  padding = { left = 1, right = 1 } },
                hl = v.status.hl.get_attributes("tab_close", true),
                on_click = { callback = v.close_tab, name = "heirline_tabline_close_tab_callback" },
              },
            },
          },
        }
        heirline.setup(heirline_opts)

        local g = vim.api.nvim_create_augroup("Heirline", { clear = true })
        vim.api.nvim_create_autocmd("User", {
          pattern = "VimSharpColorScheme",
          group = g,
          desc = "Refresh heirline colors",
          callback = function()
            -- re("heirline.utils").on_colorscheme(setup_colors()))
          end,
        })
        vim.api.nvim_create_autocmd("User", {
          pattern = "HeirlineInitWinbar",
          group = g,
          desc = "Disable winbar for some filetypes",
          callback = function()
            if not require "heirline".winbar["disabled"] then require "heirline".winbar["disabled"] = true end
            if vim.opt.diff:get()
                -- or v.status.condition.buffer_matches(re("heirline").winbar.disabled
                or true

            then
              vim.opt_local.winbar = nil
            end
          end,
        })

      end },
      ["famiu/bufdelete.nvim"] = { cmd = { "Bdelete", "Bwipeout" } },
      ["s1n7ax/nvim-window-picker"] = { version = "^1", config = function()
        -- re "configs.window-picker"
        local colors = require "v_theme.colors"
        require("window-picker").setup(
          { use_winbar = "smart", other_win_hl_color = colors.grey_4 }
        )
      end },

      ["folke/which-key.nvim"] = { event = "VeryLazy", config = function()
        -- re "configs.which-key"
        return {
          plugins = {
            spelling = { enabled = true },
            presets = { operators = false },
          },
          window = {
            border = "rounded",
            padding = { 2, 2, 2, 2 },
          },
          disable = { filetypes = { "TelescopePrompt" } },
        }
      end },

      ["windwp/nvim-autopairs"] = {
        --Dont think i want this..
        enabled = false,
        event = "InsertEnter", config = function()
          -- re "configs.autopairs"
          local npairs = require "nvim-autopairs"
          npairs.setup(
            {
              check_ts = true,
              ts_config = { java = false },
              fast_wrap = {
                map = "<M-e>",
                chars = { "{", "[", "(", '"', "'" },
                pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
                offset = 0,
                end_key = "$",
                keys = "qwertyuiopzxcvbnmasdfghjkl",
                check_comma = true,
                highlight = "PmenuSel",
                highlight_grey = "LineNr",
              },
            })

          if not vim.g.autopairs_enabled then npairs.disable() end
          local cmp_status_ok, cmp = pcall(require, "cmp")
          if cmp_status_ok then
            cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done { tex = false })
          end
        end
      },

      ["numToStr/Comment.nvim"] = {
        --       keys = { { "<Leader>/", mode = { "n", "v" } }, { "gb", mode = { "n", "v" } } },
        config = function()
          -- re "configs.Comment"
          local utils = require "Comment.utils"
          require("Comment").setup({
            pre_hook = function(ctx)
              local location = nil
              if ctx.ctype == utils.ctype.blockwise then
                location = require("ts_context_commentstring.utils").get_cursor_location()
              elseif ctx.cmotion == utils.cmotion.v or ctx.cmotion == utils.cmotion.V then
                location = require("ts_context_commentstring.utils").get_visual_start_location()
              end

              return require("ts_context_commentstring.internal").calculate_commentstring {
                key = ctx.ctype == utils.ctype.linewise and "__default" or "__multiline",
                location = location,
              }
            end,
          })
        end,
      },
      ["akinsho/toggleterm.nvim"] = {
        cmd = { "ToggleTerm", "TermExec" },
        config = function()
          -- re "configs.toggleterm"
          require("toggleterm").setup({
            terminal_mappings = false,
            size = 10,
            open_mapping = [[<F7>]],
            shading_factor = 2,
            direction = "float",
            float_opts = {
              border = "curved",
              highlights = {
                border = "Normal",
                background = "Normal",
              },
            },
          })
        end,
      },
      ["nvim-tree/nvim-web-devicons"] = {
        enabled = vim.g.icons_enabled,
        config = function()
          --  re "configs.nvim-web-devicons"
          require("nvim-web-devicons").set_default_icon(v.get_icon "DefaultFile", "#6d8086", "66")
          require("nvim-web-devicons").set_icon({
            deb = { icon = "", name = "Deb" },
            lock = { icon = "", name = "Lock" },
            mp3 = { icon = "", name = "Mp3" },
            mp4 = { icon = "", name = "Mp4" },
            out = { icon = "", name = "Out" },
            ["robots.txt"] = { icon = "ﮧ", name = "Robots" },
            ttf = { icon = "", name = "TrueTypeFont" },
            rpm = { icon = "", name = "Rpm" },
            woff = { icon = "", name = "WebOpenFontFormat" },
            woff2 = { icon = "", name = "WebOpenFontFormat2" },
            xz = { icon = "", name = "Xz" },
            zip = { icon = "", name = "Zip" },
          })
        end,
      },
      ["Darazaki/indent-o-matic"] = {
        init = function() table.insert(v.filePlugins, "indent-o-matic") end,
        config = function()
          -- re "configs.indent-o-matic"
          local indent_o_matic = require "indent-o-matic"
          indent_o_matic.setup({})
          indent_o_matic.detect()
        end,
      },
      ["rcarriga/nvim-notify"] = {

        init = function() v.load_plugin_with_func("nvim-notify", vim, "notify") end,
        config = function()
          -- local BUILTIN_RENDERERS = {
          --   DEFAULT = "default",
          --   MINIMAL = "minimal",
          -- }
          -- local BUILTIN_STAGES = {
          --   FADE = "fade",
          --   SLIDE = "slide",
          --   FADE_IN_SLIDE_OUT = "fade_in_slide_out",
          --   STATIC = "static",
          -- }
          -- local default_config = {
          --   level = vim.log.levels.INFO,
          --   timeout = 5000,
          --   max_width = nil,
          --   max_height = nil,
          --   stages = BUILTIN_STAGES.FADE_IN_SLIDE_OUT,
          --   render = BUILTIN_RENDERERS.DEFAULT,
          --   background_colour = "Normal",
          --   on_open = nil,
          --   on_close = nil,
          --   minimum_width = 50,
          --   fps = 30,
          --   top_down = true,
          --   icons = {
          --     ERROR = "",
          --     WARN = "",
          --     INFO = "",
          --     DEBUG = "",
          --     TRACE = "✎",
          --   },
          -- }
          -- Overriding vim.notify with fancy notify if fancy notify exists


          -- re "configs.notify"
          local notify = require "notify"
          notify.setup({
            timeout = 2000,
            max_width = 500,
            top_down = false,
            fps = 60,
            background_colour = "#000000",
          })
          vim.notify = notify
        end,
      },
      ["stevearc/dressing.nvim"] = {
        init = function()
          v.load_plugin_with_func("dressing.nvim", vim.ui, { "input", "select" })
        end,
        config = function()
          -- re "configs.dressing"
          require("dressing").setup({
            input = {
              default_prompt = "➤ ",
              win_options = { winhighlight = "Normal:Normal,NormalNC:Normal" },
            },
            select = {
              backend = { "telescope", "builtin" },
              builtin = { win_options = { winhighlight = "Normal:Normal,NormalNC:Normal" } },
            },
          })

        end,
      },
      ["nvim-neo-tree/neo-tree.nvim"] = {
        version = "^2",
        dependencies = { ["MunifTanjim/nui.nvim"] = {} },
        cmd = "Neotree",
        init = function() vim.g.neo_tree_remove_legacy_commands = true end,
        config = function()
          -- re "configs.neo-tree"
          require("neo-tree").setup({
            close_if_last_window = true,
            enable_diagnostics = false,
            source_selector = {
              winbar = true,
              content_layout = "center",
              tab_labels = {
                filesystem = v.get_icon "FolderClosed" .. " File",
                buffers = v.get_icon "DefaultFile" .. " Bufs",
                git_status = v.get_icon "Git" .. " Git",
                diagnostics = v.get_icon "Diagnostic" .. " Diagnostic",
              },
            },
            default_component_configs = {
              indent = { padding = 0 },
              icon = {
                folder_closed = v.get_icon "FolderClosed",
                folder_open = v.get_icon "FolderOpen",
                folder_empty = v.get_icon "FolderEmpty",
                default = v.get_icon "DefaultFile",
              },
              git_status = {
                symbols = {
                  added = v.get_icon "GitAdd",
                  deleted = v.get_icon "GitDelete",
                  modified = v.get_icon "GitChange",
                  renamed = v.get_icon "GitRenamed",
                  untracked = v.get_icon "GitUntracked",
                  ignored = v.get_icon "GitIgnored",
                  unstaged = v.get_icon "GitUnstaged",
                  staged = v.get_icon "GitStaged",
                  conflict = v.get_icon "GitConflict",
                },
              },
            },
            -- window = {
            --   width = 30,
            --   mappings = {
            --     ["<space>"] = false, -- disable space until we figure out which-key disabling
            --     u = "navigate_up",
            --     o = "open",
            --     O = function(state) v.system_open(state.tree:get_node():get_id()) end,
            --     H = "prev_source",
            --     L = "next_source",
            --   },
            -- },
            -- filesystem = {
            --   filtered_items = {
            --     hide_hidden = false, -- only works on Windows for hidden files/directories
            --     follow_current_file = true,
            --     hijack_netrw_behavior = "open_current",
            --     use_libuv_file_watcher = true,
            --     window = { mappings = { h = "toggle_hidden" } },
            --   },
            -- },
            window = {
              width = 30,
              mappings = {
                ["<space>"] = false, -- disable space until we figure out which-key disabling
                u = "navigate_up",
                o = "open",
                O = function(state) v.system_open(state.tree:get_node():get_id()) end,
                H = "prev_source",
                L = "next_source",
              },
            },
            filesystem = {
              hide_hidden = false,
              follow_current_file = true,
              hijack_netrw_behavior = "open_current",
              use_libuv_file_watcher = true,
              window = {
                mappings = {
                  O = "system_open",
                  h = "toggle_hidden",
                },
              },
              commands = {
                system_open = function(state) v.system_open(state.tree:get_node():get_id()) end,
              },
            },
            event_handlers = {
              { event = "neo_tree_buffer_enter", handler = function(_) vim.opt_local.signcolumn = "auto" end },
            },
          })
        end,
      },

      ["nvim-treesitter/nvim-treesitter"] = {
        init = function() table.insert(v.filePlugins, "nvim-treesitter") end,
        cmd = {
          "TSBufDisable",
          "TSBufEnable",
          "TSBufToggle",
          "TSDisable",
          "TSEnable",
          "TSToggle",
          "TSInstall",
          "TSInstallInfo",
          "TSInstallSync",
          "TSModuleInfo",
          "TSUninstall",
          "TSUpdate",
          "TSUpdateSync",
        },
        dependencies = {
          ["p00f/nvim-ts-rainbow"] = {},
          ["windwp/nvim-ts-autotag"] = {},
          ["JoosepAlviste/nvim-ts-context-commentstring"] = {},
        },
        build = function() require("nvim-treesitter.install").update { with_sync = true } () end,
        config = function()
          -- re "configs.treesitter"
          require("nvim-treesitter.configs").setup({

            context_commentstring = {
              enable = true,
              enable_autocmd = false,
            },
            rainbow = {
              enable = true,
              disable = { "html" },
              extended_mode = false,
              max_file_lines = nil,
            },
            highlight = {
              enable = true,
              disable = function(lang, buf)
                local max_filesize = 100 * 1024 -- 100 KB
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if lang == "fsharp" or ok and stats and stats.size > max_filesize then return true end
              end,
              additional_vim_regex_highlighting = function(lang, _) return lang == "fsharp" end,
            },

            autoversion = { enable = true },
            incremental_selection = { enable = true },
            -- indent = { enable = false },
            indent = { enable = true, disable = { "python", "fsharp" } },

            auto_install = fn.executable "tree-sitter" == 1,
            ensure_installed = "all",
            matchup = { enable = true },
            textobjects = {
              select = {
                enable = true,
                lookahead = true,
                keymaps = {
                  aB = "@block.outer",
                  iB = "@block.inner",
                  aC = "@conditional.outer",
                  iC = "@conditional.inner",
                  aF = "@function.outer",
                  iF = "@function.inner",
                  aL = "@loop.outer",
                  iL = "@loop.inner",
                  aP = "@parameter.outer",
                  iP = "@parameter.inner",
                  aX = "@class.outer",
                  iX = "@class.inner",
                },
              },
              move = {
                enable = true,
                set_jumps = true,
                goto_next_start = {
                  ["]b"] = "@block.outer",
                  ["]f"] = "@function.outer",
                  ["]p"] = "@parameter.outer",
                  ["]x"] = "@class.outer",
                },
                goto_next_end = {
                  ["]B"] = "@block.outer",
                  ["]F"] = "@function.outer",
                  ["]P"] = "@parameter.outer",
                  ["]X"] = "@class.outer",
                },
                goto_previous_start = {
                  ["[b"] = "@block.outer",
                  ["[f"] = "@function.outer",
                  ["[p"] = "@parameter.outer",
                  ["[x"] = "@class.outer",
                },
                goto_previous_end = {
                  ["[B"] = "@block.outer",
                  ["[F"] = "@function.outer",
                  ["[P"] = "@parameter.outer",
                  ["[X"] = "@class.outer",
                },
              },
              swap = {
                enable = true,
                swap_next = {
                  [">B"] = "@block.outer",
                  [">F"] = "@function.outer",
                  [">P"] = "@parameter.inner",
                },
                swap_previous = {
                  ["<B"] = "@block.outer",
                  ["<F"] = "@function.outer",
                  ["<P"] = "@parameter.inner",
                },
              },
              lsp_interop = {
                enable = true,
                border = "single",
                peek_definition_code = {
                  ["<leader>lp"] = "@function.outer",
                  ["<leader>lP"] = "@class.outer",
                },
              },
            },



          })
        end,
      },
      ["NvChad/nvim-colorizer.lua"] = {
        init = function() table.insert(v.filePlugins, "nvim-colorizer.lua") end,
        cmd = { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerReloadAllBuffers" },
        config = function()
          -- re "configs.colorizer"
          require("colorizer").setup(
            { user_default_options = { names = false } }
          )
        end,
      },
      ["max397574/better-escape.nvim"] = {
        event = "InsertCharPre",
        config = function()
          -- re "configs.better_escape"
          require("better_escape").setup({})
        end,
      },
      ["Shatur/neovim-session-manager"] = {
        event = "BufWritePost",
        cmd = "SessionManager",
        config = function()
          -- re "configs.session_manager"
          require("session_manager").setup({})

        end,
      },
      ["lukas-reineke/indent-blankline.nvim"] = {
        init = function() table.insert(v.filePlugins, "indent-blankline.nvim") end,
        config = function()
          -- re "configs.indent-line"
          require("indent_blankline").setup({
            buftype_exclude = {
              "nofile",
              "terminal",
            },
            filetype_exclude = {
              "help",
              "startify",
              "aerial",
              "alpha",
              "dashboard",
              "lazy",
              "neogitstatus",
              "NvimTree",
              "neo-tree",
              "Trouble",
            },
            context_patterns = {
              "class",
              "return",
              "function",
              "method",
              "^if",
              "^while",
              "jsx_element",
              "^for",
              "^object",
              "^table",
              "block",
              "arguments",
              "if_statement",
              "else_clause",
              "jsx_element",
              "jsx_self_closing_element",
              "try_statement",
              "catch_clause",
              "import_statement",
              "operation_type",
            },
            show_trailing_blankline_indent = false,
            use_treesitter = true,
            char = "▏",
            context_char = "▏",
            show_current_context = true,
          })

        end,
      },
      ["lewis6991/gitsigns.nvim"] = {
        enabled = fn.executable "git" == 1,
        ft = "gitcommit",
        init = function() table.insert(v.git_plugins, "gitsigns.nvim") end,
        config = function()
          -- re "configs.gitsigns"
          require("gitsigns").setup({
            signs = {
              add = { text = "▎" },
              change = { text = "▎" },
              delete = { text = "▎" },
              topdelete = { text = "契" },
              changedelete = { text = "▎" },
              untracked = { text = "▎" },
            },
            --signs = {
            --    add = { text = '+' },
            --    change = { text = '~' },
            --    delete = { text = '_' },
            --    topdelete = { text = '‾' },
            --    changedelete = { text = '~' },
            --  },
          })

        end,
      },
      ["nvim-telescope/telescope.nvim"] = {
        cmd = "Telescope",
        config = function()
          -- re "configs.telescope"
          local telescope = require "telescope"
          local actions = require "telescope.actions"
          local hop = telescope.extensions.hop
          telescope.setup(
            {
              defaults = {
                prompt_prefix = string.format("%s ", v.get_icon "Search"),
                selection_caret = string.format("%s ", v.get_icon "Selected"),
                path_display = { "truncate" },
                sorting_strategy = "ascending",
                layout_config = {
                  horizontal = {
                    prompt_position = "top",
                    preview_width = 0.55,
                    results_width = 0.8,
                  },
                  vertical = {
                    mirror = false,
                  },
                  width = 0.87,
                  height = 0.80,
                  preview_cutoff = 120,
                },

                mappings = {
                  i = {
                    ["<C-h>"] = hop.hop,
                    ["<C-space>"] = function(prompt_bufnr)
                      hop._hop_loop(
                        prompt_bufnr,
                        { callback = actions.toggle_selection, loop_callback = actions.send_selected_to_qflist }
                      )
                    end,
                  },
                },
              },
              extensions = {
                -- bibtex = { context = true, context_fallback = false },
                --    cheat = {},
                fzf = {
                  fuzzy = true, -- false will only do exact matching
                  override_generic_sorter = true, -- override the generic sorter
                  override_file_sorter = true, -- override the file sorter
                  case_mode = "smart_case", -- or "ignore_case" or "respect_case"
                  -- the default case_mode is "smart_case"
                },
                media_files = {
                  filetypes = { "png", "jpg", "mp4", "webm", "pdf" },
                  find_cmd = "rg",
                },

                --   file_browser = {
                --      mappings = {
                --       i = {
                --        ["<C-z>"] = fb_actions.toggle_hidden,
                --     },
                --    n = {
                --          z = fb_actions.toggle_hidden,
                --        },
                --      },
                --    },


              },
              pickers = {
                find_files = {
                  hidden = true,
                },
              },
              dependencies = {
                ["nvim-telescope/telescope-fzf-native.nvim"] =
                {
                  enabled = fn.executable "make" == 1, build = "make"
                },
              },
            })

          v.executeIfTrue(telescope.load_extension, pcall(require, "notify"), "notify")
          v.executeIfTrue(telescope.load_extension, pcall(require, "aerial"), "aerial")
          v.executeIfTrue(telescope.load_extension, v.isAvalable "telescope-fzf-native.nvim",
            "fzf")
        end,

      },
      -- ["nvim-telescope/telescope-bibtex.nvim"] = {

      --   config = function()
      --     -- re "telescope-bibtex"
      --   end,
      -- },
      ["nvim-telescope/telescope-cheat.nvim"] = {

        config = function()
          require("telescope").load_extension "cheat"
        end
      },
      ["nvim-telescope/telescope-file-browser.nvim"] = {

        config = function()
          -- re "telescope-file-browser"
          require("telescope").load_extension "file_browser"
        end,
      },
      ["Verf/telescope-everything.nvim"] = {

        config = function()
          require("telescope").load_extension "everything"
        end
      },

      ["nvim-telescope/telescope-hop.nvim"] = {

        config = function()
          --  re "telescope-hop"
          require("telescope").load_extension "hop"
        end,
      },
      ["nvim-telescope/telescope-media-files.nvim"] = {

        config = function()
          -- re "telescope-media-files"
          require("telescope").load_extension "media-files"
        end,
      },
      ["nvim-telescope/telescope-project.nvim"] = {

        config = function()
          -- re "telescope-project"
          require("telescope").load_extension "project"
        end,
      },
      ["stevearc/aerial.nvim"] = {
        init = function() table.insert(v.filePlugins, "aerial.nvim") end,
        config = function()
          -- re "configs.aerial"
          require("aerial").setup({
            attach_mode = "global",
            backends = { "lsp", "treesitter", "markdown", "man" },
            layout = {
              min_width = 28,
            },
            show_guides = true,
            filter_kind = false,
            guides = {
              mid_item = "├ ",
              last_item = "└ ",
              nested_top = "│ ",
              whitespace = "  ",
            },
            keymaps = {
              ["[y"] = "actions.prev",
              ["]y"] = "actions.next",
              ["[Y"] = "actions.prev_up",
              ["]Y"] = "actions.next_up",
              ["{"] = false,
              ["}"] = false,
              ["[["] = false,
              ["]]"] = false,
            },
          })

        end,
      },


      ["L3MON4D3/LuaSnip"] = {
        config = function()
          -- re "configs.luasnip"
          local ls = require "luasnip"
          local types = require("luasnip.util.types")
          local ext_util = require("luasnip.util.ext_opts")
          local ft_functions = require("luasnip.extras.filetype_functions")
          local session = require("luasnip.session")
          local iNode = require("luasnip.nodes.insertNode")
          local cNode = require("luasnip.nodes.choiceNode")

          -- Inserts a insert(1) before all other nodes, decreases node.pos's as indexing is "wrong".
          local function modify_nodes(snip)
            for i = #snip.nodes, 1, -1 do
              snip.nodes[i + 1] = snip.nodes[i]
              local node = snip.nodes[i + 1]
              if node.pos then
                node.pos = node.pos + 1
              end
            end
            snip.nodes[1] = iNode.I(1)
          end

          ls.add_snippets("all", {
            ls.parser.parse_snippet(
              'func',
              'function ${1}(${2}) \n{\n\t${3}\n}'),
          })
          ls.config.setup({

            history = false,
            update_events = "InsertLeave",
            -- see :h User, event should never be triggered(except if it is `doautocmd`'d)
            region_check_events = "User None",
            delete_check_events = "User None",
            store_selection_keys = nil, -- Supossed to be the same as the expand shortcut
            ext_opts = {
              [types.textNode] = {
                active = { hl_group = "LuasnipTextNodeActive" },
                passive = { hl_group = "LuasnipTextNodePassive" },
                visited = { hl_group = "LuasnipTextNodeVisited" },
                unvisited = { hl_group = "LuasnipTextNodeUnvisited" },
                snippet_passive = { hl_group = "LuasnipTextNodeSnippetPassive" },
              },
              [types.insertNode] = {
                active = { hl_group = "LuasnipInsertNodeActive" },
                passive = { hl_group = "LuasnipInsertNodePassive" },
                visited = { hl_group = "LuasnipInsertNodeVisited" },
                unvisited = { hl_group = "LuasnipInsertNodeUnvisited" },
                snippet_passive = {
                  hl_group = "LuasnipInsertNodeSnippetPassive",
                },
              },
              [types.exitNode] = {
                active = { hl_group = "LuasnipExitNodeActive" },
                passive = { hl_group = "LuasnipExitNodePassive" },
                visited = { hl_group = "LuasnipExitNodeVisited" },
                unvisited = { hl_group = "LuasnipExitNodeUnvisited" },
                snippet_passive = { hl_group = "LuasnipExitNodeSnippetPassive" },
              },
              [types.functionNode] = {
                active = { hl_group = "LuasnipFunctionNodeActive" },
                passive = { hl_group = "LuasnipFunctionNodePassive" },
                visited = { hl_group = "LuasnipFunctionNodeVisited" },
                unvisited = { hl_group = "LuasnipFunctionNodeUnvisited" },
                snippet_passive = {
                  hl_group = "LuasnipFunctionNodeSnippetPassive",
                },
              },
              [types.snippetNode] = {
                active = { hl_group = "LuasnipSnippetNodeActive" },
                passive = { hl_group = "LuasnipSnippetNodePassive" },
                visited = { hl_group = "LuasnipSnippetNodeVisited" },
                unvisited = { hl_group = "LuasnipSnippetNodeUnvisited" },
                snippet_passive = {
                  hl_group = "LuasnipSnippetNodeSnippetPassive",
                },
              },
              [types.choiceNode] = {
                active = { hl_group = "LuasnipChoiceNodeActive" },
                passive = { hl_group = "LuasnipChoiceNodePassive" },
                visited = { hl_group = "LuasnipChoiceNodeVisited" },
                unvisited = { hl_group = "LuasnipChoiceNodeUnvisited" },
                snippet_passive = {
                  hl_group = "LuasnipChoiceNodeSnippetPassive",
                },
              },
              [types.dynamicNode] = {
                active = { hl_group = "LuasnipDynamicNodeActive" },
                passive = { hl_group = "LuasnipDynamicNodePassive" },
                visited = { hl_group = "LuasnipDynamicNodeVisited" },
                unvisited = { hl_group = "LuasnipDynamicNodeUnvisited" },
                snippet_passive = {
                  hl_group = "LuasnipDynamicNodeSnippetPassive",
                },
              },
              [types.snippet] = {
                active = { hl_group = "LuasnipSnippetActive" },
                passive = { hl_group = "LuasnipSnippetPassive" },
                -- not used!
                visited = { hl_group = "LuasnipSnippetVisited" },
                unvisited = { hl_group = "LuasnipSnippetUnvisited" },
                snippet_passive = { hl_group = "LuasnipSnippetSnippetPassive" },
              },
              [types.restoreNode] = {
                active = { hl_group = "LuasnipRestoreNodeActive" },
                passive = { hl_group = "LuasnipRestoreNodePassive" },
                visited = { hl_group = "LuasnipRestoreNodeVisited" },
                unvisited = { hl_group = "LuasnipRestoreNodeUnvisited" },
                snippet_passive = {
                  hl_group = "LuasnipRestoreNodeSnippetPassive",
                },
              },
            },
            ext_base_prio = 200,
            ext_prio_increase = 9,
            enable_autosnippets = false,
            -- default applied in util.parser, res iNode, cNode
            -- (Dependency cycle if here).
            parser_nested_assembler = function(pos, snip)
              modify_nodes(snip)
              snip:init_nodes()
              snip.pos = nil

              return cNode.C(pos, { snip, iNode.I(nil, { "" }) })
            end,
            -- Function expected to return a list of filetypes (or empty list)
            ft_func = ft_functions.from_filetype,
            -- fn(bufnr) -> string[] (filetypes).
            load_ft_func = ft_functions.from_filetype_load,
            -- globals injected into luasnippet-files.
            snip_env = {
              s = require("luasnip.nodes.snippet").S,
              sn = require("luasnip.nodes.snippet").SN,
              isn = require("luasnip.nodes.snippet").ISN,
              t = require("luasnip.nodes.textNode").T,
              i = require("luasnip.nodes.insertNode").I,
              f = require("luasnip.nodes.functionNode").F,
              c = require("luasnip.nodes.choiceNode").C,
              d = require("luasnip.nodes.dynamicNode").D,
              r = require("luasnip.nodes.restoreNode").R,
              events = require("luasnip.util.events"),
              ai = require("luasnip.nodes.absolute_indexer"),
              extras = require("luasnip.extras"),
              l = require("luasnip.extras").lambda,
              rep = require("luasnip.extras").rep,
              p = require("luasnip.extras").partial,
              m = require("luasnip.extras").match,
              n = require("luasnip.extras").nonempty,
              dl = require("luasnip.extras").dynamic_lambda,
              fmt = require("luasnip.extras.fmt").fmt,
              fmta = require("luasnip.extras.fmt").fmta,
              conds = require("luasnip.extras.expand_conditions"),
              postfix = require("luasnip.extras.postfix").postfix,
              types = require("luasnip.util.types"),
              parse = require("luasnip.util.parser").parse_snippet,
            },
          })

          vim.tbl_map(function(type) require("luasnip.loaders.from_" .. type).lazy_load() end,
            { "vscode", "snipmate", "lua" })

        end,
        dependencies = { ["rafamadriz/friendly-snippets"] = {} },
      },

      ["hrsh7th/nvim-cmp"] = {
        commit = "a9c701fa7e12e9257b3162000e5288a75d280c28", -- https://github.com/hrsh7th/nvim-cmp/issues/1382
        event = "InsertEnter",
        lazy = false,
        config = function()
          -- re "configs.cmp"
          local cmp = require "cmp"
          local snip_status_ok, luasnip = pcall(require, "luasnip")
          local lspkind_status_ok, lspkind = pcall(require, "lspkind")

          if not snip_status_ok then return end
          local setup = cmp.setup
          local function has_words_before()
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
          end

          local border_opts =
          { border = "single", winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None" }

          setup {
            snippet = {
              expand = function(args)
                require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
              end,
            },
            enabled = function()
              if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
              return vim.g.cmp_enabled
            end,
            preselect = cmp.PreselectMode.Item,
            -- preselect = cmp.PreselectMode.None,
            formatting = {
              fields = { "kind", "abbr", "menu" },
              format =

              -- function(entry, vim_item)
              --   local prsnt, _ = pcall(re, "lspkind")
              --   if not prsnt then
              --     -- From kind_icons array
              --     local kind_icons = v.lspkind.symbol_map
              --     vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
              --   else
              --     -- From lspkind
              --     return lspkind.cmp_format(v.lspkind) or nil
              --   end
              --   -- Source
              --   vim_item.menu = ({
              --     buffer = "[Buf]",
              --     nvim_lsp = "[LSP]",
              --     luasnip = "[Snip]",
              --     nvim_lua = "[Lua]",
              --     latex_symbols = "[LaTeX]",
              --   })[entry.source.name]
              --   return vim_item or nil
              -- end,

              lspkind_status_ok and lspkind.cmp_format(v.lspkind) or nil,
            },
            duplicates = {
              nvim_lsp = 1,
              nvim_lua = 1,
              luasnip = 1,
              cmp_tabnine = 1,
              buffer = 1,
              path = 1,
            },
            confirm_opts = {
              behavior = cmp.ConfirmBehavior.Replace,
              select = false,
            },
            window = {
              completion = cmp.config.window.bordered(border_opts),
              documentation = cmp.config.window.bordered(border_opts),
            },
            mapping = {
              ["<Up>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
              ["<Down>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
              ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
              ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
              ["<C-k>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
              ["<C-j>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
              ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
              ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
              ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
              -- ["<C-y>"] = cmp.config.disable,
              ["<C-e>"] = cmp.mapping {
                i = cmp.mapping.abort(),
                c = cmp.mapping.close(),
              },
              -- ["<CR>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
              ["<CR>"] = cmp.mapping.confirm { select = false },
              ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif luasnip.expandable() then
                  luasnip.expand()
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                elseif has_words_before() then
                  cmp.complete()
                else
                  fallback()
                end
              end, {
                "i",
                "s",
              }),
              ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
                else
                  fallback()
                end
              end, {
                "i",
                "s",
              }),
            },
            sources = cmp.config.sources {
              { name = "luasnip", priority = 1000 },
              { name = "nvim_lsp", priority = 900 },
              { name = "omni", priority = 750 },
              { name = "nuget", priority = 500 },
              { name = "path", priority = 400 },
              { name = "cmdline", priority = 350 },
              { name = "calc", priority = 300 },
              { name = "buffer", priority = 275 },
              { name = "emoji", priority = 200 },
              { name = "pandoc-references", priority = 150 },
              { name = "nvim-lua", priority = 100 },
              { name = "latex-symbols", priority = 50 },

            },
          }


        end,
        dependencies = {
          ["hrsh7th/cmp-nvim-lsp"] = {},
          ["saadparwaiz1/cmp_luasnip"] = {},
          ["hrsh7th/cmp-nvim-lsp-signature-help"] = {},
          ["hrsh7th/cmp-nvim-lua"] = {},
          ["hrsh7th/cmp-buffer"] = {},
          ["hrsh7th/cmp-path"] = {},
          ["hrsh7th/cmp-cmdline"] = {},
          ["hrsh7th/cmp-calc"] = {},
          ["hrsh7th/cmp-emoji"] = {},
          ["jc-doyle/cmp-pandoc-references"] = {},
          ["PasiBergman/cmp-nuget"] = {
            config =
            {
              filetypes = {}, -- on which filetypes cmp-nuget is active
              file_extensions = { "csproj", "fsproj" }, -- on which file extensions cmp-nuget is active
              nuget = {
                packages = { -- configuration for searching packages
                  limit = 100, -- limit package serach to first 100 packages
                  prerelease = true, -- include prerelase (preview, rc, etc.) packages
                  sem_ver_level = "2.0.0", -- semantic version level (*
                  package_type = "", -- package type to use to filter packages (*
                },
                versions = {
                  prerelease = true, -- include prerelase (preview, rc, etc.) versions
                  sem_ver_level = "2.0.0", -- semantic version level (*
                },
              },
            }

          },
          ["kdheepak/cmp-latex-symbols"] = {},
        },
      },
      ["neovim/nvim-lspconfig"] = {
        lazy = false,
        init = function() table.insert(v.filePlugins, "nvim-lspconfig") end,
        config = function()
          -- re "configs.lspconfig"
          if vim.g.lsp_handlers_enabled then
            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help,
              { border = "rounded" })
          end
          local setup_servers = function()
            vim.tbl_map(v.lsp.setup,
              {
                "sumneko_lua",
                "ionide",
                -- "fsautocomplete",
                "omnisharp",
                "clangd",
                "lemminx",
                "sqls",
                "jsonls",
                "html",
                "marksman",
                "yamlls",
                -- "tsserver",
                -- "texlab",
                -- "cssls",
                --  "cmake",
                --  "intelephense",
                --  "pyright",
              }
            )
            vim.api.nvim_exec_autocmds("FileType", {})
          end
          if v.isAvalable "mason-lspconfig.nvim" then
            vim.api.nvim_create_autocmd("User", { pattern = "VimSharpLspSetup", once = true, callback = setup_servers })
          else
            setup_servers()
          end


        end,
        dependencies = {
          ["williamboman/mason-lspconfig.nvim"] = {
            lazy = false,
            cmd = { "LspInstall", "LspUninstall" },
            config = function()

              require "mason-lspconfig".setup({
                automatic_installation = { exclude = { "fsautocomplete" } },
                ensure_installed = {
                  "fsautocomplete",
                  "omnisharp",
                  "clangd",
                  "cmake",
                  -- "cssls",
                  "html",
                  -- "intelephense",
                  "marksman",
                  "jsonls",
                  -- "pyright",
                  "sqls",
                  "sumneko_lua",
                  -- "texlab",
                  -- "tsserver",
                  "yamlls",
                },
              })
              require "mason-lspconfig".setup_handlers { function(server)
                v.lsp.setup(server)
              end }
              v.event "LspSetup"

            end,
          },
        },
      },
      ["jose-elias-alvarez/null-ls.nvim"] = {
        init = function() table.insert(v.filePlugins, "null-ls.nvim") end,
        config = function()
          -- re "configs.null-ls"

        end,
        dependencies = {
          ["jayp0521/mason-null-ls.nvim"] = {
            cmd = { "NullLsInstall", "NullLsUninstall" },
            config = function()
              -- re "configs.mason-null-ls"
              local mason_null_ls = require "mason-null-ls"
              mason_null_ls.setup({ automatic_setup = true, on_attach = v.lsp.on_attach })
              mason_null_ls.setup_handlers {}

            end,
          },
        },
      },

      ["mfussenegger/nvim-dap"] = {
        init = function() table.insert(v.filePlugins, "nvim-dap") end,

        -- config = function() re "configs.dap" end,
        config = function()

          local dap = require "dap"
          dap.adapters = dap.adapters
          dap.configurations = dap.configurations

        end,

        dependencies = {
          ["rcarriga/nvim-dap-ui"] = { config = function()

            local dap, dapui = require "dap", require "dapui"
            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
            dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
            dapui.setup({ floating = { border = "rounded" } })

          end },
          ["jayp0521/mason-nvim-dap.nvim"] = {
            cmd = { "DapInstall", "DapUninstall" },
            config = function()

              local dap = require("dap")

              v.dotnet.projectPath = function()
                if v.dotnet.lastProjectPath == nil then
                  default_path = fn.getcwd()
                end
                local path = fn.input({ "Path to your *proj file ", default_path, "file" })
                vim.g["dotnet_last_proj_path"] = path
                return path
              end

              local util = require "neo-tree.utils"

              local openFileInNewBuffer = function(f)
                if fn.confirm("Do you want to open the file " .. f .. " ?\n", "&yes\n&no", 2) == 1 then vim.cmd.bufload(f) end
              end

              vim.g["dotnet_build_release_project"] = function(p)
                local logfile = "c:/temp/dotnet-release-Log.txt"
                -- local cmd = "dotnet build -c Release " .. p .. '" *> ' .. logfile
                local cmd = "dotnet build -c Release --project " .. p
                print ""
                print("Cmd to execute: " .. cmd)
                local f = os.execute(cmd)
                if f == 0 then
                  print "\nBuild: ✔️ "
                else
                  print("\nBuild: ❌ (code: " .. f .. ")")
                  openFileInNewBuffer(logfile)
                end
                return f
              end

              vim.g["dotnet_build_debug_project"] = function(p)
                local logfile = "c:/temp/dap-debug-nvim-dotnet.txt"
                -- local cmd = "dotnet build -c Debug " .. p .. '" *> ' .. logfile
                local cmd = "dotnet build -c Debug --project " .. p
                print ""
                print("Cmd to execute: " .. cmd)
                local f = os.execute(cmd)
                if f == 0 then
                  print "\nBuild: ✔️ "
                else
                  print("\nBuild: ❌ (code: " .. f .. ")")
                  openFileInNewBuffer(logfile)
                end
                return f
              end

              vim.g["dotnet_get_dll_path"] = function()
                local request = function()
                  return fn.input({ "Path to dll ",
                    vim.fs.normalize(vim.lsp.buf.list_workspace_folders()[1]) .. "/bin/Debug/", "file" })
                end
                if vim.g["dotnet_last_dll_path"] == nil then
                  vim.g["dotnet_last_dll_path"] = request()
                else
                  if fn.confirm("Do you want to change the path to dll?\n" .. vim.g["dotnet_last_dll_path"],
                    "&yes\n&no", 2) == 1
                  then
                    vim.g["dotnet_last_dll_path"] = request()
                  end
                  print("path to dll is set to: " .. vim.g["dotnet_last_dll_path"])
                end
                return vim.g["dotnet_last_dll_path"]
              end

              vim.g["dotnet_build_project"] = function(path, buildType)
                local t = buildType or "debug"
                if t == "r" or "release" or "Release" or "R" then
                  print("building project: " .. path .. "with build type " .. t)
                  return vim.g.dotnet_build_release_project(path)
                else
                  print("building project: " .. path .. "with build type " .. t)
                  return vim.g.dotnet_build_debug_project(path)
                end
              end


              local config = {
                {
                  type = "coreclr",
                  name = "launch - netcoredbg",
                  request = "launch",
                  program = function()
                    if fn.confirm("Should I recompile first?", "&yes\n&no", 2) == 1 then
                      vim.g.dotnet_build_project(vim.g.dotnet_get_project_path())
                    end
                    return vim.g.dotnet_get_dll_path()
                  end,
                },
              }

              vim.g["dotnet_run"] = function(proj, runtype)
                local c = ":!dotnet run --project " .. proj
                vim.cmd(c)
              end

              require("mason-nvim-dap").setup {
                automatic_installation = true,
                automatic_init = true,
                ensure_installed = { "coreclr" },
              }
              require("mason-nvim-dap").setup_handlers {

                function(source_name)
                  -- all sources with no handler get passed here
                  -- Keep original functionality of `automatic_init = true`
                  require "mason-nvim-dap.automatic_setup" (source_name)
                end,

                coreclr = function(source_name)
                  dap.adapters.coreclr = {
                    type = "executable",
                    command = vim.fs.find("netcoredbg.exe", { path = stdpath "data" }),
                    -- command =  "C:/.local/share/nvim-data/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe",
                    -- command = "C:/.local/share/nvim-data/mason/bin/netcoredbg.cmd",
                    args = { "--interpreter=vscode" },
                  }
                  dap.configurations.cs = config
                  dap.configurations.fsharp = config
                end,
                python = function(source_name)
                  dap.adapters.python = {
                    type = "executable",
                    command = "C:/Python310/python.exe",
                    args = {
                      "-m",
                      "debugpy.adapter",
                    },
                  }

                  dap.configurations.python = {
                    {
                      type = "python",
                      request = "launch",
                      name = "Launch file",
                      program = "${file}", -- This configuration will launch the current file if used.
                    },
                  }
                end,
              }

              -- v.user_plugin_opts("plugins.mason-nvim-dap", { automatic_init = true }

            end,
          },
        },
      },
      ["williamboman/mason.nvim"] = {
        cmd = {
          "Mason",
          "MasonInstall",
          "MasonUninstall",
          "MasonUninstallAll",
          "MasonLog",
          "MasonUpdate", -- v command
          "MasonUpdateAll", -- v command
        },
        config = function()
          -- re "configs.mason"

          require("mason").setup {
            ui = {
              icons = {
                package_installed = "✓",
                package_uninstalled = "✗",
                package_pending = "⟳",
              },
            },
            log_level = vim.log.levels.DEBUG,
          }

          local cmd = vim.api.nvim_create_user_command
          cmd("MasonUpdateAll", function() v.mason.update_all() end, { desc = "Update Mason Packages" })
          cmd("MasonUpdate", function(opts) v.mason.update(opts.args) end,
            { nargs = 1, desc = "Update Mason Package" })
          vim.tbl_map(function(module) pcall(require, module) end, { "nvim-lspconfig", "null-ls", "dap" })
        end,
      },
      -- -- setting up this plugin in lsp/server-settings/sumneko_lua
      ["kkharji/sqlite.lua"] = {
        config = function()
          -- re("sqlite")
          vim.cmd("let g:sqlite_clib_path =" .. "C:/ProgramData/chocolatey/lib/SQLite/tools/sqlite3.dll")

        end
      },
      ["arsham/indent-tools.nvim"] = {

        init = function() table.insert(v.filePlugins, "indent-tools.nvim") end,
        dependencies = { ["arsham/arshlib.nvim"] = {} },
        config = function()
          -- re "indent-tools"
          require("indent-tools").config {}

        end,
      },
      ["danymat/neogen"] = {
        cmd = "Neogen",
        config = function()
          -- re "neogen"
          require("neogen").setup {
            snippet_engine = "luasnip",
            languages = {
              lua = { template = { annotation_convention = "ldoc" } },
              typescript = { template = { annotation_convention = "tsdoc" } },
              typescriptreact = { template = { annotation_convention = "tsdoc" } },
            },
          }

        end,
      },
      ["EdenEast/nightfox.nvim"] = {
        -- module = "nightfox",
        lazy = false,
        event = "ColorScheme",
        config = function()
          -- re "nightfox"
          require("nightfox").setup {
            options = {
              dim_inactive = true,
              styles = { comments = "italic" },
              module_default = false,
              modules = {
                aerial = true,
                cmp = true,
                ["dap-ui"] = true,
                diagnostic = true,
                gitsigns = true,
                hop = true,
                native_lsp = true,
                neotree = true,
                notify = true,
                telescope = true,
                treesitter = true,
                tsrainbow = true,
                whichkey = true,
              },
            },
            groups = { all = { NormalFloat = { link = "Normal" } } },
          }
        end,
      },
      ["ethanholz/nvim-lastplace"] = {
        lazy = true,
        init = function() table.insert(v.filePlugins, "nvim-lastplace") end,
        config = function()
          -- re "nvim-lastplace"
          require("nvim-lastplace").setup {
            lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
            lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
            lastplace_open_folds = true,
          }
        end,
      },

      ["jose-elias-alvarez/typescript.nvim"] = {
        config = function()
          --  re "typescript"

        end,
      },
      ["junegunn/vim-easy-align"] = {
        lazy = true,
        init = function() table.insert(v.filePlugins, "vim-easy-align") end,
      },

      ["machakann/vim-sandwich"] = {
        lazy = true,
        init = function() table.insert(v.filePlugins, "vim-sandwich") end,
      },

      ["nanotee/sqls.nvim"] = {},

      ["nvim-treesitter/nvim-treesitter-textobjects"] = {},

      ["p00f/clangd_extensions.nvim"] = {

        config = function()
          -- re "clangd_extensions"
          require("clangd_extensions").setup { server = v.lsp.server_settings "clangd" }
        end,
      },
      ["sindrets/diffview.nvim"] = {
        lazy = true,
        init = function() table.insert(v.git_plugins, "diffview.nvim") end,
        config = function()
          -- re "diffview"
          local actions = require "diffview.actions"

          v.which_key_register {
            n = {
              ["<leader>"] = {
                d = {
                  name = "Diff View",
                  ["<cr>"] = { "<cmd>DiffviewOpen<cr>", "Open DiffView" },
                  h = { "<cmd>DiffviewFileHistory %<cr>", "Open DiffView File History" },
                  H = { "<cmd>DiffviewFileHistory<cr>", "Open DiffView Branch History" },
                },
              },
            },
          }

          local build_keymaps = function(maps)
            local out = {}
            local i = 1
            for lhs, def in pairs(v.default_tbl({
              ["<leader>dq"] = { "<cmd>DiffviewClose<cr>", desc = "Quit Diffview" }, -- Toggle the file panel.
              ["]D"] = { actions.select_next_entry, desc = "Next Difference" }, -- Open the diff for the next file
              ["[D"] = { actions.select_prev_entry, desc = "Previous Difference" }, -- Open the diff for the previous file
              ["[C"] = { actions.prev_conflict, desc = "Next Conflict" }, -- In the merge_tool: jump to the previous conflict
              ["]C"] = { actions.next_conflict, desc = "Previous Conflict" }, -- In the merge_tool: jump to the next conflict
              ["Cl"] = { actions.cycle_layout, desc = "Cycle Diff Layout" }, -- Cycle through available layouts.
              ["Ct"] = { actions.listing_style, desc = "Cycle Tree Style" }, -- Cycle through available layouts.
              ["<leader>e"] = { actions.toggle_files, desc = "Toggle Explorer" }, -- Toggle the file panel.
              ["<leader>o"] = { actions.focus_files, desc = "Focus Explorer" }, -- Bring focus to the file panel
            }, maps)) do
              local opts
              local rhs = def
              local mode = { "n" }
              if type(def) == "table" then
                if def.mode then mode = def.mode end
                rhs = def[1]
                def[1] = nil
                def.mode = nil
                opts = def
              end
              out[i] = { mode, lhs, rhs, opts }
              i = i + 1
            end
            return out
          end

          require("diffview").setup {
            view = {
              merge_tool = { layout = "diff3_mixed" },
            },
            keymaps = {
              disable_defaults = true,
              view = build_keymaps {
                ["<leader>do"] = { actions.conflict_choose "ours", desc = "Take Ours" }, -- Choose the OURS version of a conflict
                ["<leader>dt"] = { actions.conflict_choose "theirs", desc = "Take Theirs" }, -- Choose the THEIRS version of a conflict
                ["<leader>db"] = { actions.conflict_choose "base", desc = "Take Base" }, -- Choose the BASE version of a conflict
                ["<leader>da"] = { actions.conflict_choose "all", desc = "Take All" }, -- Choose all the versions of a conflict
                ["<leader>d0"] = { actions.conflict_choose "none", desc = "Take None" }, -- Delete the conflict region
              },
              diff3 = build_keymaps {
                ["<leader>dO"] = { actions.diffget "ours", mode = { "n", "x" }, desc = "Get Our Diff" }, -- Obtain the diff hunk from the OURS version of the file
                ["<leader>dT"] = { actions.diffget "theirs", mode = { "n", "x" }, desc = "Get Their Diff" }, -- Obtain the diff hunk from the THEIRS version of the file
              },
              diff4 = build_keymaps {
                ["<leader>dB"] = { actions.diffget "base", mode = { "n", "x" }, desc = "Get Base Diff" }, -- Obtain the diff hunk from the OURS version of the file
                ["<leader>dO"] = { actions.diffget "ours", mode = { "n", "x" }, desc = "Get Our Diff" }, -- Obtain the diff hunk from the OURS version of the file
                ["<leader>dT"] = { actions.diffget "theirs", mode = { "n", "x" }, desc = "Get Their Diff" }, -- Obtain the diff hunk from the THEIRS version of the file
              },
              file_panel = build_keymaps {
                j = actions.next_entry, -- Bring the cursor to the next file entry
                k = actions.prev_entry, -- Bring the cursor to the previous file entry.
                o = actions.select_entry,
                S = actions.stage_all, -- Stage all entries.
                U = actions.unstage_all, -- Unstage all entries.
                X = actions.restore_entry, -- Restore entry to the state on the left side.
                L = actions.open_commit_log, -- Open the commit log panel.
                Cf = { actions.toggle_flatten_dirs, desc = "Flatten" }, -- Flatten empty subdirectories in tree listing style.
                R = actions.refresh_files, -- Update stats and entries in the file list.
                ["-"] = actions.toggle_stage_entry, -- Stage / unstage the selected entry.
                ["<down>"] = actions.next_entry,
                ["<up>"] = actions.prev_entry,
                ["<cr>"] = actions.select_entry, -- Open the diff for the selected entry.
                ["<2-LeftMouse>"] = actions.select_entry,
                ["<c-b>"] = actions.scroll_view(-0.25), -- Scroll the view up
                ["<c-f>"] = actions.scroll_view(0.25), -- Scroll the view down
                ["<tab>"] = actions.select_next_entry,
                ["<s-tab>"] = actions.select_prev_entry,
              },
              file_history_panel = build_keymaps {
                j = actions.next_entry,
                k = actions.prev_entry,
                o = actions.select_entry,
                y = actions.copy_hash, -- Copy the commit hash of the entry under the cursor
                L = actions.open_commit_log,
                zR = { actions.open_all_folds, desc = "Open all folds" },
                zM = { actions.close_all_folds, desc = "Close all folds" },
                ["?"] = { actions.options, desc = "Options" }, -- Open the option panel
                ["<down>"] = actions.next_entry,
                ["<up>"] = actions.prev_entry,
                ["<cr>"] = actions.select_entry,
                ["<2-LeftMouse>"] = actions.select_entry,
                ["<C-A-d>"] = actions.open_in_diffview, -- Open the entry under the cursor in a diffview
                ["<c-b>"] = actions.scroll_view(-0.25),
                ["<c-f>"] = actions.scroll_view(0.25),
                ["<tab>"] = actions.select_next_entry,
                ["<s-tab>"] = actions.select_prev_entry,
              },
              option_panel = {
                q = actions.close,
                o = actions.select_entry,
                ["<cr>"] = actions.select_entry,
                ["<2-LeftMouse"] = actions.select_entry,
              },
            },
          }

        end,
      },
      ["ziontee113/syntax-tree-surfer"] = {
        -- module = "syntax-tree-surfer",
        config = function()
          -- re "syntax-tree-surfer"
          require("syntax-tree-surfer").setup { highlight_group = "HopNextKey" }
        end,
      },
      -- ["AndrewRadev/bufferize.vim"] = {
      --   cmd = "Bufferize",
      --   config = function()
      --     --nothing here yet
      --   end
      -- },

      ["WillEhrendreich/bufferize.nvim"] = {
        cmd = "Bufferize",
        config = function()
          --nothing here yet
        end
      },
      ["Exafunction/codeium.vim"] = {
        cmd = { "Codeium" },
        config = function()
          vim.g["codeium_no_map_tab"] = true
          vim.g["codeium_disable_bindings"] = false
          vim.g["codium_map_ctrl_enter"] = true
          local cocmpt = function() fn["codeium#DebouncedComplete"]() end
          local coclr = function() fn["codeium#Clear"]() end
          local con = function() fn["codeium#CycleCompletions"](1) end
          local cop = function() fn["codeium#CycleCompletions"](-1) end
          local coac = function() fn["codeium#accept"]() end

          local grp = vim.api.nvim_create_augroup
          local ac = vim.api.nvim_create_autocmd

          local function set_style()
            if vim.g.term_color == 256 then
              vim.cmd("hi def CodeiumSuggestion guifg=#808080 ctermfg=244")
            else
              vim.cmd("hi def CodeiumSuggestion guifg=#808080 ctermfg=8")
            end
            vim.cmd("hi def link CodeiumAnnotation Normal")
          end

          local function mapAccept()
            if not vim.g.codeium_disable_bindings then
              if not vim.g.codeium_no_map_tab then
                vim.keymap.set({ "i", "n" }, "<Tab>", function() coac() end, { noremap = true, silent = true })
              end
              if vim.g.codium_map_ctrl_enter then
                vim.keymap.set({ "i", "n" }, "<C-Enter>", function() coac() end, { noremap = true, silent = true })
              end
            end
          end

          local autocmd_group = "codeium_group"
          grp(autocmd_group, { clear = true })

          ac("InsertEnter", {
            group = autocmd_group,
            desc = "Call codeium#DebouncedComplete on InsertEnter",
            callback = function() cocmpt() end,
          })

          ac("CursorMovedI", {
            group = autocmd_group,
            desc = "Call codeium#DebouncedComplete on CursorMovedI",
            callback = function() cocmpt() end,
          })

          ac("CompleteChanged", {
            group = autocmd_group,
            desc = "Call codeium#DebouncedComplete on CompleteChanged",
            callback = function() cocmpt() end,
          })

          ac("BufEnter", {
            group = autocmd_group,
            desc = "Call codeium#DebouncedComplete on BufEnter",
            callback = function()
              if fn.mode() == "i" or fn.mode() == "R" then
                cocmpt()
              end
            end,
          })
          ac("InsertLeave", {
            group = autocmd_group,
            desc = "Call codeium#Clear on InsertLeave",
            callback = function() coclr() end,
          })

          ac("BufLeave", {
            group = autocmd_group,
            desc = "Call Codium Clear on BufLeave",
            callback = function()
              if fn.mode() == "i" or fn.mode() == "R" then
                coclr()
              end
            end,
          })

          ac("ColorScheme", {
            group = autocmd_group,
            desc = "Call SetStyle on ColorScheme",
            callback = function() set_style() end,
          })

          ac("VimEnter", {
            group = autocmd_group,
            desc = "Call MapAccept on VimEnter",
            callback = function() mapAccept() end,
          })
          -- vim.g["codeium_"]
          -- vim.g["codeium_"]
          --nothing here yet
        end
      },
      -- ["jackMort/ChatGPT.nvim"] =
      -- { config = function()
      --   re("chatgpt").setup(
      --     {
      --       -- welcome_message = WELCOME_MESSAGE,
      --       loading_text = "Loading, please wait ...",
      --       question_sign = "", -- 🙂
      --       answer_sign = "ﮧ", -- 🤖
      --       max_line_length = 120,
      --       yank_register = "+",
      --       chat_layout = {
      --         relative = "editor",
      --         position = "50%",
      --         size = {
      --           height = "80%",
      --           width = "80%",
      --         },
      --       },
      --       settings_window = {
      --         border = {
      --           style = "rounded",
      --           text = {
      --             top = " Settings ",
      --           },
      --         },
      --         win_options = {
      --           winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      --         },
      --       },
      --       sessions_window = {
      --         border = {
      --           style = "rounded",
      --           text = {
      --             top = " Sessions ",
      --           },
      --         },
      --         win_options = {
      --           winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      --         },
      --       },
      --       chat_window = {
      --         filetype = "chatgpt",
      --         border = {
      --           highlight = "FloatBorder",
      --           style = "rounded",
      --           text = {
      --             top = " ChatGPT ",
      --           },
      --         },
      --         win_options = {
      --           winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      --         },
      --       },
      --       chat_input = {
      --         prompt = "  ",
      --         border = {
      --           highlight = "FloatBorder",
      --           style = "rounded",
      --           text = {
      --             top_align = "center",
      --             top = " Prompt ",
      --           },
      --         },
      --         win_options = {
      --           winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      --         },
      --       },
      --       openai_params = {
      --         model = "text-davinci-003",
      --         frequency_penalty = 0,
      --         presence_penalty = 0,
      --         max_tokens = 900,
      --         temperature = 0,
      --         top_p = 1,
      --         n = 1,
      --       },
      --       openai_edit_params = {
      --         model = "code-davinci-edit-001",
      --         temperature = 0,
      --         top_p = 1,
      --         n = 1,
      --       },
      --       keymaps = {
      --         close = { "<C-c>", "<Esc>" },
      --         yank_last = "<C-y>",
      --         scroll_up = "<C-u>",
      --         scroll_down = "<C-d>",
      --         toggle_settings = "<C-o>",
      --         new_session = "<C-n>",
      --         cycle_windows = "<Tab>",
      --       },
      --       actions_paths = {},
      --     }
      --
      --   )
      -- end,
      --   cmd = { "ChatGPT", "ChatGPTActAs", "ChatGPTEditWithInstructions" },
      --   dependencies = {
      --     "MunifTanjim/nui.nvim",
      --     "nvim-lua/plenary.nvim",
      --     "nvim-telescope/telescope.nvim"
      --   } },
      -- ["WillEhrendreich/ionide-vim"] = { config = v.lsp.configs.ionide, },
      ["WillEhrendreich/ionide-vim"] = { config = v.lsp.configs.ionide, },
      -- ["WillEhrendreich/ionide-vim"] = {},
      -- ["ionide/ionide-vim"] = { lazy = false, config = function() re("ionide").setup(v.lsp.configs.ionide) end, },

      ["hood/popui.nvim"] = {

        config = function()
          vim.ui.select = require "popui.ui-overrider"
          vim.ui.input = require "popui.input-overrider"
        end,
      },


      ["lewis6991/hover.nvim"] = {
        config = function()
          require("hover").setup {
            init = function()
              -- re providers
              require "hover.providers.lsp"
              require('hover.providers.gh')
              -- re('hover.providers.jira')
              -- re "hover.providers.man"
              require('hover.providers.dictionary')
            end,
            preview_opts = {
              border = nil,
            },
            -- Whether the contents of a currently open hover window should be moved
            -- to a :h preview-window when pressing the hover keymap.
            preview_window = false,
            title = true,
          }
          -- Setup keymaps
          vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
          vim.keymap.set("n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
        end,
      },

      ["nguyenvukhang/nvim-toggler"] = {
        config = function()
          require("nvim-toggler").setup {
            inverses = {
              ["bad"] = "good",
              ["up"] = "down",
              ["left"] = "right",
              ["1"] = "0",
            },
            remove_default_keybinds = true,
          }
        end,
      },
      ["smjonas/live-command.nvim"] = {
        -- live-command supports semantic versioning via tags
        -- version = "1.*",
        config = function()
          require("live-command").setup {
            commands = {
              Norm = { cmd = "norm" },
            },
          }

        end,
      },

      ["tyru/open-browser.vim"] = {
        commands = function()
          return {
            {
              desc = "Smart search link/word under cursor",
              cmd = "<Plug>(openbrowser-smart-search)",
              keys = {
                { "n", "gx", { noremap = true } },
                { "v", "gx", { noremap = true } },
              },
            },
          }
        end,
      },

      ["nvim-neotest/neotest"] = {

        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-treesitter/nvim-treesitter",
          "WillEhrendreich/neotest-dotnet",
          "antoinemadec/FixCursorHold.nvim",
          "nvim-neotest/neotest-plenary",
          "nvim-neotest/neotest-vim-test",
        },
        config = function()
          require("neotest").setup {
            adapters = {
              require "neotest-dotnet" {},
              -- re "neotest-python" {
              --   dap = { justMyCode = false },
              -- },
              require "neotest-plenary",
              require "neotest-vim-test" {
                ignore_file_types = { "python", "vim", "lua", "fsharp", "csharp", "cs" },
              },
            },
          }
        end,
      },

      ["tamton-aquib/duck.nvim"] = {},
      ["djoshea/vim-autoread"] = {},
      -- ["phaazon/hop.nvim"] = {},
      -- -- ["dhruvasagar/vim-table-mode"] = re "vim-table-mode",
      ["echasnovski/mini.nvim"] = {},
      -- -- ["folke/zen-mode.nvim"] = re "zen-mode",
      -- -- ["jbyuki/nabla.nvim"] = re "nabla",
      -- -- ["lukas-reineke/headlines.nvim"] = re "headlines",
      -- -- ["mickael-menu/zk-nvim"] = re "zk",
      -- -- ["vitalk/vim-simple-todo"] = re "vim-simple-todo",
      -- -- ["akinsho/git-conflict.nvim"] = re "git-conflict",

    }
  ),
  {
    defaults = { lazy = true },
    concurrency = 50,
    install = { colorscheme = { "vimsharp" } },
    performance = {
      rtp = {
        paths = { v.install.config },
        disabled_plugins = { "tohtml", "gzip", "matchit", "zipPlugin", "netrwPlugin", "tarPlugin", "matchparen" },
      },
    },
    lockfile = fn.stdpath "data" .. "/lazy-lock.json",
  }
)

--#endregion_Lazy

--#endregion_plugins
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--   "core.diagnostics",

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--#region_Diagnostics

local signs = {
  { name = "DiagnosticSignError", text = v.get_icon "DiagnosticError" },
  { name = "DiagnosticSignWarn", text = v.get_icon "DiagnosticWarn" },
  { name = "DiagnosticSignHint", text = v.get_icon "DiagnosticHint" },
  { name = "DiagnosticSignInfo", text = v.get_icon "DiagnosticInfo" },
  { name = "DapStopped", text = v.get_icon "DapStopped", texthl = "DiagnosticWarn" },
  { name = "DapBreakpoint", text = v.get_icon "DapBreakpoint", texthl = "DiagnosticInfo" },
  { name = "DapBreakpointRejected", text = v.get_icon "DapBreakpointRejected", texthl = "DiagnosticError" },
  { name = "DapBreakpointCondition", text = v.get_icon "DapBreakpointCondition", texthl = "DiagnosticInfo" },
  { name = "DapLogPoint", text = v.get_icon "DapLogPoint", texthl = "DiagnosticInfo" },
}

for _, sign in ipairs(signs) do
  if not sign.texthl then sign.texthl = sign.name end
  fn.sign_define(sign.name, sign)
end

v.lsp.diagnostics = {
  off = {
    underline = false,
    virtual_text = false,
    signs = false,
    update_in_insert = false,
  },
  on = {
    virtual_text = true,
    signs = { active = signs },
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focused = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  },
}

vim.diagnostic.config(v.lsp.diagnostics[vim.g.diagnostics_enabled and "on" or "off"])


--#endregion_Diagnostics
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--   "core.autocmds",

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--#region_autocmds

vim.on_key(function(char)
  if fn.mode() == "n" then
    local new_hlsearch = tContains({ "<CR>", "n", "N", "*", "#", "?", "/" }, fn.keytrans(char))
    if vim.opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
  end
end, namespace "auto_hlsearch")

local bufferline_group = grp("bufferline", { clear = true })
autocmd({ "BufAdd", "BufEnter" }, {
  desc = "Update buffers when adding new buffers",
  group = bufferline_group,
  callback = function(args)
    if not vim.t.bufs then vim.t.bufs = {} end
    local bufs = vim.t.bufs
    if not tContains(bufs, args.buf) then
      table.insert(bufs, args.buf)
      vim.t.bufs = bufs
    end
    vim.t.bufs = vim.tbl_filter(v.is_valid_buffer, vim.t.bufs)
  end,
})
autocmd("BufDelete", {
  desc = "Update buffers when deleting buffers",
  group = bufferline_group,
  callback = function(args)
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
      local bufs = vim.t[tab].bufs
      if bufs then
        for i, bufnr in ipairs(bufs) do
          if bufnr == args.buf then
            table.remove(bufs, i)
            vim.t[tab].bufs = bufs
            break
          end
        end
      end
    end
    vim.t.bufs = vim.tbl_filter(v.is_valid_buffer, vim.t.bufs)
    vim.cmd.redrawtabline()
  end,
})

autocmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
  desc = "URL Highlighting",
  group = grp("highlighturl", { clear = true }),
  pattern = "*",
  callback = function() v.set_url_match() end,
})

autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = grp("highlightyank", { clear = true }),
  pattern = "*",
  callback = function() vim.highlight.on_yank() end,
})

autocmd("FileType", {
  desc = "Unlist quickfix buffers",
  group = grp("unlist_quickfix", { clear = true }),
  pattern = "qf",
  callback = function() vim.bo.buflisted = false end,
})

autocmd("BufEnter", {
  desc = "Quit v if more than one window is open and only sidebar windows are list",
  group = grp("auto_quit", { clear = true }),
  callback = function()
    local wins = vim.api.nvim_tabpage_list_wins(0)
    -- Both neo-tree and aerial will auto-quit if there is only a single window left
    if #wins <= 1 then return end
    local sidebar_fts = { aerial = true, ["neo-tree"] = true }
    for _, winid in ipairs(wins) do
      if vim.api.nvim_win_is_valid(winid) then
        local bufnr = vim.api.nvim_win_get_buf(winid)
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
        -- If any visible windows are not sidebars, early return
        if not sidebar_fts[filetype] then
          return
          -- If the visible window is a sidebar
        else
          -- only count filetypes once, so remove a found sidebar from the detection
          sidebar_fts[filetype] = nil
        end
      end
    end
    if #vim.api.nvim_list_tabpages() > 1 then
      vim.cmd.tabclose()
    else
      vim.cmd.qall()
    end
  end,
})

if v.isAvalable "alpha-nvim" then
  local group_name = grp("alpha_settings", { clear = true })
  autocmd("User", {
    desc = "Disable status and tablines for alpha",
    group = group_name,
    pattern = "AlphaReady",
    callback = function()
      local prev_showtabline = vim.opt.showtabline
      local prev_status = vim.opt.laststatus
      vim.opt.laststatus = 0
      vim.opt.showtabline = 0
      vim.opt_local.winbar = nil
      autocmd("BufUnload", {
        pattern = "<buffer>",
        callback = function()
          vim.opt.laststatus = prev_status
          vim.opt.showtabline = prev_showtabline
        end,
      })
    end,
  })
  -- autocmd("VimEnter", {
  --   desc = "Start Alpha when vim is opened with no arguments",
  --   group = group_name,
  --   callback = function()
  --     local should_skip = false
  --     if fn.argc() > 0 or fn.line2byte "$" ~= -1 or not vim.o.modifiable then
  --       should_skip = true
  --     else
  --       for _, arg in pairs(vim.v.argv) do
  --         if arg == "-b" or arg == "-c" or vim.startswith(arg, "+") or arg == "-S" then
  --           should_skip = true
  --           break
  --         end
  --       end
  --     end
  --     if not should_skip then re("alpha").start(true) end
  --   end,
  -- })
end

if v.isAvalable "neo-tree.nvim" then
  autocmd("BufEnter", {
    desc = "Open Neo-Tree on startup with directory",
    group = grp("neotree_start", { clear = true }),
    callback = function()
      local stats = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
      if stats and stats.type == "directory" then require("neo-tree.setup.netrw").hijack() end
    end,
  })
end

if v.isAvalable "nvim-dap-ui" then
  autocmd("FileType", {
    desc = "Make q close dap floating windows",
    group = grp("dapui", { clear = true }),
    pattern = "dap-float",
    callback = function() vim.keymap.set("n", "q", "<cmd>close!<cr>") end,
  })
end

-- autocmd({ "VimEnter", "ColorScheme" }, {
--   desc = "Load custom highlight from user configuration",
--   group = grp("v_highlight", { clear = true }),
--   callback = function()
--     if vim.g.colors_name then
--       for _, module in ipairs { "init", vim.g.colors_name } do
--         for group, spec in pairs(v.highlight[module]) do
--           vim.api.nvim_set_hl(0, group, spec)
--         end
--       end
--     end
--     v.event "ColorScheme"
--   end,
-- })


autocmd("BufRead", {
  group = grp("git_plugin_lazy_load", { clear = true }),
  callback = function()

    fn.system("git -C " .. fn.expand "%:p:h" .. " rev-parse")
    if vim.v.shell_error == 0 then
      vim.api.nvim_del_augroup_by_name "git_plugin_lazy_load"
      if #v.git_plugins > 0 then
        vim.schedule(function() require("lazy").load { plugins = v.git_plugins } end)
      end
    end
  end,
})
autocmd({ "BufRead", "BufWinEnter", "BufNewFile" }, {
  group = grp("file_plugin_lazy_load", { clear = true }),
  callback = function(args)
    if not (fn.expand "%" == "" or vim.api.nvim_get_option_value("buftype", { buf = args.buf }) == "nofile") then
      vim.api.nvim_del_augroup_by_name "file_plugin_lazy_load"
      if #v.filePlugins > 0 then
        if tContains(v.filePlugins, "nvim-treesitter") then
          require("lazy").load { plugins = { "nvim-treesitter" } }
        end
        vim.schedule(function() require("lazy").load { plugins = v.filePlugins } end)
      end
    end
  end,
})

local cmd = vim.api.nvim_create_user_command
-- cmd("VimSharpUpdatePackages", function() v.updater.update_packages() end, { desc = "Update Plugins and Mason" })
-- cmd("VimSharpUpdate", function() v.updater.update() end, { desc = "Update v" })
-- cmd("VimSharpVersion", function() v.updater.version() end, { desc = "Check v Version" })
-- cmd("VimSharpChangelog", function() v.updater.changelog() end, { desc = "Check v Changelog" })
cmd("ToggleHighlightURL", function() v.ui.toggle_url_match() end, { desc = "Toggle URL Highlights" })

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd("FocusGained", { command = "checktime" })
-- create directories when needed, when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    local file = vim.loop.fs_realpath(event.match) or event.match

    fn.mkdir(fn.fnamemodify(file, ":p:h"), "p")
    local backup = fn.fnamemodify(file, ":p:~:h")
    backup = backup:gsub("[/\\]", "%%")
    vim.go.backupext = backup
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})



autocmd("VimLeave", {
  desc = "Stop running auto compiler",
  group = grp("autocomp", { clear = true }),
  pattern = "*",
  callback = function() fn.jobstart { "autocomp", fn.expand "%:p", "stop" } end,
})

local attachToBuffer = function(outputBufnr, pattern, command)
  autocmd("BufWritePost", {
    desc = "AutoMagically runs a command on the file after it saves",
    group = grp("AutoMagicBufOut-->ForBufferNumber:" .. outputBufnr, { clear = true }),
    pattern = pattern,
    callback = function()
      local append_data = function(_, data)
        if data then setlines(outputBufnr, -1, -1, false, data) end
      end
      setlines(outputBufnr, 0, -1, false, { "output" })
      jb(command, {
        stdout_buffered = true,
        on_stdout = append_data,
        on_stderr = append_data,
      })
    end,
  })
end
-- Fix conceallevel for json & help files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "json", "jsonc" },
  callback = function()
    vim.wo.spell = false
    vim.wo.conceallevel = 0
  end,
})
-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = "*",
  callback = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "<buffer>",
      once = true,
      callback = function()
        vim.cmd(
          [[if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif]]
        )
      end,
    })
  end,
})

uc("AutoRun", function()
  local bufnr = tonumber(inp "Bufnr: ")
  local pattern = inp "Pattern: "
  local command = inp "Command: "
  local csplit = vim.split(command, "")
  print "AutoRun starts now ... "
  local allcon = ("buf: " .. bufnr .. " pattern: " .. pattern .. " command: " .. command .. "")
  print(allcon)
  attachToBuffer(bufnr, pattern, csplit)
end, {})

-- attachToBuffer(1, "*.fs", { "dotnet", "test", vim.api.nvim_buf_get_name(1) })

-- grp("FsharpProjCommands", { clear = true })
-- autocmd({ "BufNewFile", "BufReadPre", "FileType" }, {
--   desc = "changes comment style, folding for fsproj",
--   pattern = { "*.fsproj" },
--   group = "FsharpProjCommands",
--   callback = function()
--     vim.cmd "set commentstring=<!--%s-->"
--     -- vim.cmd "let g:xml_syntax_folding=1"
--     -- vim.cmd "set foldmethod=syntax"
--     vim.cmd "set syntax=xml"
--     -- vim.cmd "set foldlevelstart=999  foldminlines=0"
--   end,
-- })

grp("xamlCommands", { clear = true })
autocmd({ "BufNewFile", "BufReadPre", "FileType" }, {
  desc = "changes comment style, folding for xaml",
  pattern = "*.xaml",
  group = "xamlCommands",
  callback = function()
    vim.cmd "set filetype=xml"
    vim.cmd "set commentstring=<!--%s-->"
    vim.cmd "let g:xml_syntax_folding=1"
    vim.cmd "set foldmethod=syntax"
    vim.cmd "set foldlevelstart=999  foldminlines=0"
  end,
})

autocmd("FileType", {
  desc = "Make q close dap floating windows",
  group = grp("dapui", { clear = true }),
  pattern = "dap-float",
  callback = function() vim.keymap.set("n", "q", "<cmd>close!<cr>") end,
})

local p = function(v)
  print(vim.inspect(v))
  return v
end

uc("P", function(v)
  return p(v)
end, {})

RELOAD = function(...)
  p("Reloading Module " .. ...)
  return require("plenary.reload").reload_module(...)
end

uc("R", function(x)
  RELOAD(x)
  return x
end, {})

R = function(name)
  RELOAD(name)
  return require(name)
end


TRY = function(module, Ok, NotOk)
  local ok, _ = pcall(require, module)
  if ok then
    Ok()
  else
    NotOk()
  end
end

uc("Try", function(x)
  TRY(x)
  return x
end, {})

-- CHEATSHEET = function()
--   E.ui_input({ width = 30 }, function(query)
--     query = table.concat(vim.split(query, " "), "+")
--     local cmd = ('curl "https://cht.sh/%s/%s"'):format(vim.bo.ft, query)
--     vim.cmd("split | term " .. cmd)
--     vim.cmd [[stopinsert!]]
--     U.set_quit_maps()
--   end)
-- end

-- uc("CheatSheet", function()
--   CHEATSHEET()
-- end, {})

SCRATCH = function(input)
  vim.cmd.Bufferize(input)
end

uc("Msgs", function()

  vim.cmd.Bufferize("messages")
end, {})

uc("Scratch", SCRATCH, {})


--#endregion_autocmds
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--   "core.mappings",

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--#region_mappings


local sections = {
  a = { name = "AI" },
  f = { name = "Find" },
  n = { name = "New" },
  p = { name = "Packages" },
  l = { name = "LSP" },
  u = { name = "UI" },
  b = { name = "Buffers" },
  d = { name = "Debugger" },
  g = { name = "Git" },
  s = { name = "SomethingNotUsedYet.. " },
  S = { name = "Session" },
  t = { name = "Terminal" },
}


-- Normal --
-- Standard Operations
local mappings =
{

  n = {

    ["<leader>l"] = sections.l,
    ["<leader>a"] = sections.a,
    ["<leader>f"] = sections.f,
    ["<leader>n"] = sections.n,
    ["<leader>p"] = sections.p,
    ["<leader>b"] = sections.b,
    ["<leader>g"] = sections.g,
    -- ["<leader>s"] = sections.s,
    ["<leader>S"] = sections.S,
    ["<leader>d"] = sections.d,
    ["<leader>u"] = sections.u,


    -- ["<leader>ac"] = { "<cmd>ChatGPT<cr>", desc = "Start ChatGPT" },
    ["<leader>ac"] = { function()
      fn["codeium#DebouncedComplete"]()
    end, desc = "Codeium Accept" },
    -- ["<leader>an"] = { "<Plug>codeium-next<cr>", desc = "Codeium Next" },
    -- ["<leader>ak"] = { "<Plug>codeium-next<cr>", desc = "Codeium Next" },

    ["<C-Space>"] = { function() local cmp = require('cmp')
      -- print 'triggered ctrl space'
      cmp.mapping.complete()
    end, desc = "trigger cmp" },

    ["<leader>V"] = { function() vim.cmd('e $myvimrc') end, desc = "edit init.lua" },

    ["<leader>."] = { function()
      local here = v.path.AppendSlash(vim.fs.normalize(fn.expand("%:p:h")))
      vim.cmd("cd " .. here)
      v.notify("CWD set to: " .. here)
    end, desc = "Set CWD to here" },

    ["<leader>w"] = { "<cmd>w<cr>", desc = "Save" },
    ["<leader>q"] = { "<cmd>q<cr>", desc = "Quit" },

    ["<leader>nf"] = { "<cmd>vnew<cr>", desc = "New File" },

    ["gx"] = { function() v.system_open() end, desc = "Open the file under cursor with system app" },
    ["Q"] = "<Nop>",
    ["K"] = { function()

      if v.isAvalable(require("hover")) then
        require("hover").hover()
      else
        vim.lsp.buf.hover()

      end
    end, desc = "Hover symbol details" },

    -- Plugin Manager
    ["<leader>pi"] = { function() require("lazy").install() end, desc = "Plugins Install" },
    ["<leader>ps"] = { function() require("lazy").home() end, desc = "Plugins Status" },
    ["<leader>pS"] = { function() require("lazy").sync() end, desc = "Plugins Sync" },
    ["<leader>pu"] = { function() require("lazy").check() end, desc = "Plugins Check Updates" },
    ["<leader>pU"] = { function() require("lazy").update() end, desc = "Plugins Update" },

    -- -- v
    -- ["<leader>pa"] = { "<cmd>VimSharpUpdatePackages<cr>", desc = "Update Plugins and Mason" },
    -- ["<leader>pA"] = { "<cmd>VimSharpUpdate<cr>", desc = "v Update" },
    -- ["<leader>pv"] = { "<cmd>VimSharpVersion<cr>", desc = "v Version" },
    -- ["<leader>pl"] = { "<cmd>VimSharpChangelog<cr>", desc = "v Changelog" },

    -- -- Alpha
    -- if v.isAvalable "alpha-nvim" then
    --   ["<leader>h"] = { function() re("alpha").start() end, desc = "Home Screen" },
    -- end

    --["<C-'>"] = ["<F7>"],
    -- Manage Buffers
    ["<leader>c"] = { function() v.close_buf(0) end, desc = "Close buffer" },
    ["<leader>C"] = { function() v.close_buf(0, true) end, desc = "Force close buffer" },
    ["<S-l>"] = { function() v.nav_buf(vim.v.count > 0 and vim.v.count or 1) end, desc = "Next buffer" },
    ["<S-h>"] =
    { function() v.nav_buf(-(vim.v.count > 0 and vim.v.count or 1)) end, desc = "Previous buffer" },
    [">b"] =
    { function() v.move_buf(vim.v.count > 0 and vim.v.count or 1) end, desc = "Move buffer tab right" },
    ["<b"] =
    { function() v.move_buf(-(vim.v.count > 0 and vim.v.count or 1)) end, desc = "Move buffer tab left" },

    ["<leader>bb"] = { function() v.status.heirline.buffer_picker(function(bufnr) vim.api.nvim_win_set_buf(0,
          bufnr)
      end)
    end, desc = "Select buffer from tabline", },
    ["<leader>bd"] = { function() v.status.heirline.buffer_picker(function(bufnr) v.close_buf(bufnr) end) end,
      desc = "Delete buffer from tabline", },
    ["<leader>b\\"] = { function() v.status.heirline.buffer_picker(function(bufnr) vim.cmd.split()
        vim.api.nvim_win_set_buf(0
          , bufnr)
      end)
    end, desc = "Horizontal split buffer from tabline", },
    ["<leader>b|"] = { function() v.status.heirline.buffer_picker(function(bufnr) vim.cmd.vsplit()
        vim.api.nvim_win_set_buf(0
          , bufnr)
      end)
    end, desc = "Vertical split buffer from tabline", },

    -- Navigate tabs
    ["]t"] = { function() vim.cmd.tabnext() end, desc = "Next tab" },
    ["[t"] = { function() vim.cmd.tabprevious() end, desc = "Previous tab" },

    -- Comment
    ["<leader>/"] = { function() require("Comment.api").toggle.linewise.current() end, desc = "Comment line" },

    -- GitSigns

    ["<leader>gj"] = { function() if v.isAvalable "gitsigns.nvim" then require("gitsigns").next_hunk() end end,
      desc = "Next git hunk" },
    ["<leader>gk"] = { function() if v.isAvalable "gitsigns.nvim" then require("gitsigns").prev_hunk() end end,
      desc = "Previous git hunk" },
    ["<leader>gl"] = { function() if v.isAvalable "gitsigns.nvim" then require("gitsigns").blame_line() end end,
      desc = "View git blame" },
    ["<leader>gp"] = { function() if v.isAvalable "gitsigns.nvim" then require("gitsigns").preview_hunk() end end,
      desc = "Preview git hunk" },
    ["<leader>gh"] = { function() if v.isAvalable "gitsigns.nvim" then require("gitsigns").reset_hunk() end end,
      desc = "Reset git hunk" },
    ["<leader>gr"] = { function() if v.isAvalable "gitsigns.nvim" then require("gitsigns").reset_buffer() end end,
      desc = "Reset git buffer" },
    ["<leader>gs"] = { function() if v.isAvalable "gitsigns.nvim" then require("gitsigns").stage_hunk() end end,
      desc = "Stage git hunk" },
    ["<leader>gu"] = { function() if v.isAvalable "gitsigns.nvim" then require("gitsigns").undo_stage_hunk() end end,
      desc = "Unstage git hunk" },
    ["<leader>gd"] = { function() if v.isAvalable "gitsigns.nvim" then require("gitsigns").diffthis() end end,
      desc = "View git diff" },

    -- NeoTree

    ["<leader>e"] = { function() if v.isAvalable "neo-tree.nvim" then vim.cmd("Neotree toggle<cr>") end end,
      desc = "Toggle Explorer" },
    ["<leader>o"] = { function() if v.isAvalable "neo-tree.nvim" then vim.cmd("Neotree focus<cr>") end end,
      desc = "Focus Explorer" },

    -- Session Manager
    ["<leader>Sl"] = { "<cmd>SessionManager! load_last_session<cr>", desc = "Load last session" },
    ["<leader>Ss"] = { "<cmd>SessionManager! save_current_session<cr>", desc = "Save this session" },
    ["<leader>Sd"] = { "<cmd>SessionManager! delete_session<cr>", desc = "Delete session" },
    ["<leader>Sf"] = { "<cmd>SessionManager! load_session<cr>", desc = "Search sessions" },
    ["<leader>S."] = { "<cmd>SessionManager! load_current_dir_session<cr>", desc = "Load current directory session" },

    -- Package Manager
    ["<leader>pm"] = { "<cmd>Mason<cr>", desc = "Mason Installer" },
    ["<leader>pM"] = { "<cmd>MasonUpdateAll<cr>", desc = "Mason Update" },

    -- Smart Splits
    ["<C-h>"] = { function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" },
    ["<C-j>"] = { function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" },
    ["<C-k>"] = { function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" },
    ["<C-l>"] = { function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" },

    -- Resize with arrows
    ["<C-Up>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" },
    ["<C-Down>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" },
    ["<C-Left>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" },
    ["<C-Right>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" },

    -- SymbolsOutline
    --

    ["<leader>lS"] = { function() if v.isAvalable "aerial.nvim" then require("aerial").toggle() end end,
      desc = "Symbols outline" },
    --end

    -- Telescope
    --if v.isAvalable "telescope.nvim" then

    ["<leader>fw"] = { function()
      require("telescope.builtin").live_grep {
        additional_args = function(args) return vim.list_extend(args, { "--hidden", "--no-ignore" }) end,
      }
    end, desc = "Search words in all files" },
    -- ["<leader>fW"] = { function() re("telescope.builtin").live_grep() end, desc = "Search words" },
    ["<leader>gt"] = { function() require("telescope.builtin").git_status() end, desc = "Git status" },
    ["<leader>gb"] = { function() require("telescope.builtin").git_branches() end, desc = "Git branches" },
    ["<leader>gc"] = { function() require("telescope.builtin").git_commits() end, desc = "Git commits" },
    ["<leader>ff"] = { function() require("telescope.builtin").find_files { hidden = true, no_ignore = true } end,
      desc = "Search all files", },
    ["<leader>fF"] = { function() require("telescope.builtin").find_files() end, desc = "Search files" },
    ["<leader>fb"] = { function() require("telescope.builtin").buffers() end, desc = "Search buffers" },
    ["<leader>fh"] = { function() require("telescope.builtin").help_tags() end, desc = "Search help" },
    ["<leader>fm"] = { function() require("telescope.builtin").marks() end, desc = "Search marks" },
    ["<leader>fo"] = { function() require("telescope.builtin").oldfiles() end, desc = "Search Old files" },
    ["<leader>fW"] = { function() require("telescope.builtin").grep_string() end, desc = "Search for word under cursor" },
    ["<leader>fr"] = { function() require("telescope.builtin").registers() end, desc = "Search registers" },
    -- ["<leader>sb"] = { function() re("telescope.builtin").git_branches() end, desc = "Git branches" },
    -- ["<leader>sh"] = { function() re("telescope.builtin").help_tags() end, desc = "Search help" },
    -- ["<leader>sm"] = { function() re("telescope.builtin").man_pages() end, desc = "Search man" },
    ["<leader>ft"] = { function() require("telescope.builtin").builtin() end, desc = "Telescope" },
    ["<leader>fe"] = { function() require("telescope").extensions.everything.everything() end, desc = "Everything" },
    ["<leader>fk"] = { function() require("telescope.builtin").keymaps() end, desc = "Search keymaps" },
    ["<leader>fc"] = { function() require("telescope.builtin").commands() end, desc = "Search commands" },
    ["<leader>fn"] = { function() if v.isAvalable "nvim-notify" then require("telescope").extensions.notify.notify() end end,
      desc = "Search notifications" },
    ["<leader>ls"] = { function() local aerial_avail, _ = pcall(require, "aerial")
      if aerial_avail then require("telescope")
            .extensions.aerial.aerial()
      else require("telescope.builtin").lsp_document_symbols() end
    end,
      desc = "Search symbols", },
    ["<leader>lD"] = { function() require("telescope.builtin").diagnostics() end, desc = "Search diagnostics" },
    --end

    -- Terminal
    --if v.isAvalable "toggleterm.nvim" then
    --if fn.executable "lazygit" == 1 then
    ["<leader>gg"] = { function() v.toggle_term_cmd "lazygit" end, desc = "ToggleTerm lazygit" },
    ["<leader>tl"] = { function() v.toggle_term_cmd "lazygit" end, desc = "ToggleTerm lazygit" },
    --end
    --if fn.executable "node" == 1 then
    ["<leader>tn"] = { function() v.toggle_term_cmd "node" end, desc = "ToggleTerm node" },
    --end
    --if fn.executable "gdu" == 1 then
    ["<leader>tu"] = { function() v.toggle_term_cmd "gdu" end, desc = "ToggleTerm gdu" },
    --end
    --if fn.executable "btm" == 1 then
    ["<leader>tb"] = { function() v.toggle_term_cmd "btm" end, desc = "ToggleTerm btm" },
    --end
    --if fn.executable "python" == 1 then
    ["<leader>tp"] = { function() v.toggle_term_cmd "python" end, desc = "ToggleTerm python" },
    --end
    ["<leader>tf"] = { "<cmd>ToggleTerm direction=float<cr>", desc = "ToggleTerm float" },
    ["<leader>th"] = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "ToggleTerm horizontal split" },
    ["<leader>tt"] = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "ToggleTerm vertical split" },
    ["<F7>"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    --end

    -- modified function keys found with `showkey -a` in the terminal to get key code
    -- run `nvim -V3log +quit` and search through the "Terminal info" in the `log` file for the correct keyname
    ["<F5>"]       = { function() if v.isAvalable "nvim-dap" then require("dap").continue() end end,
      desc = "Debugger: Start" },
    ["<F17>"]      = { function() if v.isAvalable "nvim-dap" then require("dap").terminate() end end,
      desc = "Debugger: Stop" }, -- Shift+F5,
    ["<F29>"]      = { function() if v.isAvalable "nvim-dap" then require("dap").restart_frame() end end,
      desc = "Debugger: Restart" }, -- Control+F5,
    ["<F6>"]       = { function() if v.isAvalable "nvim-dap" then require("dap").pause() end end,
      desc = "Debugger: Pause" },
    ["<F9>"]       = { function() if v.isAvalable "nvim-dap" then require("dap").toggle_breakpoint() end end,
      desc = "Debugger: Toggle Breakpoint" },
    ["<F10>"]      = { function() if v.isAvalable "nvim-dap" then require("dap").step_over() end end,
      desc = "Debugger: Step Over" },
    ["<F11>"]      = { function() if v.isAvalable "nvim-dap" then require("dap").step_into() end end,
      desc = "Debugger: Step Into" },
    ["<F23>"]      = { function() if v.isAvalable "nvim-dap" then require("dap").step_out() end end,
      desc = "Debugger: Step Out" }, -- Shift+F11,
    ["<leader>db"] = { function() if v.isAvalable "nvim-dap" then require("dap").toggle_breakpoint() end end,
      desc = "Toggle Breakpoint (F9)" },
    ["<leader>dB"] = { function() if v.isAvalable "nvim-dap" then require("dap").clear_breakpoints() end end,
      desc = "Clear Breakpoints" },
    ["<leader>dc"] = { function() if v.isAvalable "nvim-dap" then require("dap").continue() end end,
      desc = "Start/Continue (F5)" },
    ["<leader>di"] = { function() if v.isAvalable "nvim-dap" then require("dap").step_into() end end,
      desc = "Step Into (F11)" },
    ["<leader>do"] = { function() if v.isAvalable "nvim-dap" then require("dap").step_over() end end,
      desc = "Step Over (F10)" },
    ["<leader>dO"] = { function() if v.isAvalable "nvim-dap" then require("dap").step_out() end end,
      desc = "Step Out (S-F11)" },
    ["<leader>dq"] = { function() if v.isAvalable "nvim-dap" then require("dap").close() end end,
      desc = "Close Session" },
    ["<leader>dQ"] = { function() if v.isAvalable "nvim-dap" then require("dap").terminate() end end,
      desc = "Terminate Session (S-F5)" },
    ["<leader>dp"] = { function() if v.isAvalable "nvim-dap" then require("dap").pause() end end, desc = "Pause (F6)" },
    ["<leader>dr"] = { function() if v.isAvalable "nvim-dap" then require("dap").restart_frame() end end,
      desc = "Restart (C-F5)" },
    ["<leader>dR"] = { function() if v.isAvalable "nvim-dap" then require("dap").repl.toggle() end end,
      desc = "Toggle REPL" },
    ["<leader>du"] = { function() if v.isAvalable "nvim-dap-ui" then require("dapui").toggle() end end,
      desc = "Toggle Debugger UI" },
    ["<leader>dh"] = { function() if v.isAvalable "nvim-dap-ui" then require("dap.ui.widgets").hover() end end,
      desc = "Debugger Hover" },

    -- Custom menu for modification of the user experience

    ["<leader>ua"] = { function() if v.isAvalable "nvim-autopairs" then v.ui.toggle_autopairs() end end,
      desc = "Toggle autopairs" },
    ["<leader>ub"] = { function() if v.isAvalable "nvim-autopairs" then v.ui.toggle_background() end end,
      desc = "Toggle background" },

    ["<leader>uc"] = { function() if v.isAvalable "nvim-cmp" then v.ui.toggle_cmp() end end,
      desc = "Toggle autocompletion" },

    ["<leader>uC"] = { function() if v.isAvalable "nvim-colorizer.lua" then vim.cmd.ColorizerToggle() end end,
      desc = "Toggle color highlight" },

    ["<leader>uS"] = { function() v.ui.toggle_conceal() end, desc = "Toggle conceal" },
    ["<leader>ud"] = { function() v.ui.toggle_diagnostics() end, desc = "Toggle diagnostics" },
    ["<leader>ug"] = { function() v.ui.toggle_signcolumn() end, desc = "Toggle signcolumn" },
    ["<leader>ui"] = { function() v.ui.set_indent() end, desc = "Change indent setting" },
    ["<leader>ul"] = { function() v.ui.toggle_statusline() end, desc = "Toggle statusline" },
    ["<leader>un"] = { function() v.ui.change_number() end, desc = "Change line numbering" },
    ["<leader>us"] = { function() v.ui.toggle_spell() end, desc = "Toggle spellcheck" },
    ["<leader>up"] = { function() v.ui.toggle_paste() end, desc = "Toggle paste mode" },
    ["<leader>ut"] = { function() v.ui.toggle_tabline() end, desc = "Toggle tabline" },
    ["<leader>uu"] = { function() v.ui.toggle_url_match() end, desc = "Toggle URL highlight" },
    ["<leader>uw"] = { function() v.ui.toggle_wrap() end, desc = "Toggle wrap" },
    ["<leader>uy"] = { function() v.ui.toggle_syntax() end, desc = "Toggle syntax highlight" },
    ["<leader>uN"] = { function() v.ui.toggle_ui_notifications() end, desc = "Toggle UI notifications" },


    -- -- Move Lines
    ["<A-j>"] = { ":m .+1<CR>==", desc = "move line down" },
    ["<A-k>"] = { ":m .-2<CR>==", desc = "move line up" },
    -- vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
    -- vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")

    ["<C-u>"] = {
      "<C-u>zz",
      desc = "Go half a page up",
    },

    ["<C-d>"] = {
      "<C-d>zz",
      desc = "Go half a page down",
    },



    ["n"] = {
      "nzzzv",
      desc = "Next search term centered on screen",
    },

    ["N"] = {
      "Nzzzv",
      desc = "Last search term centered on screen",
    },

    -- duck. the most important of the mappings.
    ["<leader>dd"] = {
      function() require("duck").hatch("🦆", 10) end,
      desc = "hatch yoself a ducky friend",
    },
    ["<leader>df"] = {
      function() require("duck").hatch("🐈", 0.80) end,
      desc = "hatch yoself a feline.. ",
    },

    ["<leader>dk"] = {
      function() require("duck").cook() end,
      desc = "dat duk get cooked.",
    },
    --bad
    -- toggle inverses
    ["<leader><leader>i"] = {
      desc = "invert whatever's under the cursor",
      function()
        local w = fn.expand "<cword>"
        print("inverting " .. w)
        require("nvim-toggler").toggle()
      end,
    },
    -- save and source current file
    ["<leader><leader>x"] = {
      function()
        vim.cmd "write! %"
        vim.cmd "source %"
      end,
      desc = "Save And Source current File",
    },
    -- navigating wrapped lines
    j = { "gj", desc = "Navigate down" },
    k = { "gk", desc = "Navigate down" },
    -- easy splits
    ["\\"] = { "<cmd>split<cr>", desc = "Horizontal split" },
    ["|"] = { "<cmd>vsplit<cr>", desc = "Vertical split" },
    -- better increment/decrement
    ["_"] = { "<c-x>", desc = "Descrement number" },
    ["+"] = { "<c-a>", desc = "Increment number" },
    -- resize with arrows
    ["<Up>"] = { function() require("smart-splits").resize_up(2) end, desc = "Resize split up" },
    ["<Down>"] = { function() require("smart-splits").resize_down(2) end, desc = "Resize split down" },
    ["<Left>"] = { function() require("smart-splits").resize_left(2) end, desc = "Resize split left" },
    ["<Right>"] = { function() require("smart-splits").resize_right(2) end, desc = "Resize split right" },
    -- Easy-Align
    ga = { "<Plug>(EasyAlign)", desc = "Easy Align" },
    -- Treesitter Surfer
    ["<C-down>"] = {
      function() require("syntax-tree-surfer").move("n", false) end,
      desc = "Swap next tree-sitter object",
    },
    ["<C-right>"] = {
      function() require("syntax-tree-surfer").move("n", false) end,
      desc = "Swap next tree-sitter object",
    },
    ["<C-up>"] = {
      function() require("syntax-tree-surfer").move("n", true) end,
      desc = "Swap previous tree-sitter object",
    },
    ["<C-left>"] = {
      function() require("syntax-tree-surfer").move("n", true) end,
      desc = "Swap previous tree-sitter object",
    },
    ["<leader>li"] = { function() require 'lspconfig.ui.lspinfo' () end, desc = "LSP Info" },
    ["<leader>ll"] = { function() vim.cmd(string.format('tabnew %s', vim.lsp.get_log_path())) end, desc = "LSP log" },

    ["<leader>lk"] = { function()
      fn.writefile({}, vim.lsp.get_log_path())
    end,
      desc = "reset LSP log" },
  },





  i = {
    -- Move Lines
    ["<A-j>"] = { "<Esc>:m .+1<CR>==gi", desc = "move line down" },
    ["<A-k>"] = { "<Esc>:m .-2<CR>==gi", desc = "move line up" },

    -- vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
    -- vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi")
    -- type template string
    -- ["<C-CR>"] = { "<++>", desc = "Insert template string" },
    -- ["<S-Tab>"] = { "<C-V><Tab>", desc = "Tab character" },
  },
  v = {
    ["<leader>/"] = { "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
      desc = "Toggle comment line", },
    -- Move Lines
    ["<A-j>"] = { ":m '>+1<CR>gv=gv", desc = "move line down" },
    ["<A-k>"] = { ":m '<-2<CR>gv=gv", desc = "move line up" },
    -- navigating wrapped lines
    j = { "gj", desc = "Navigate down" },
    k = { "gk", desc = "Navigate down" },
    -- Stay in indent mode

    ["<"] = { "<gv", desc = "unindent line" },
    [">"] = { ">gv", desc = "indent line" },

  },








  -- terminal mappings
  t = {
    -- Improved Terminal Navigation
    ["<C-h>"] = { "<c-\\><c-n><c-w>h", desc = "Terminal left window navigation" },
    ["<C-j>"] = { "<c-\\><c-n><c-w>j", desc = "Terminal down window navigation" },
    ["<C-k>"] = { "<c-\\><c-n><c-w>k", desc = "Terminal up window navigation" },
    ["<C-l>"] = { "<c-\\><c-n><c-w>l", desc = "Terminal right window navigation" },

    ["<C-q>"] = { "<C-\\><C-n>", desc = "Terminal normal mode" },
    ["<esc><esc>"] = { "<C-\\><C-n>:q<cr>", desc = "Terminal quit" },
    --["<C-'>"] = ["<F7>"],
  },





  x = {
    -- paste without losing the paste text.
    ["p"] = { [["_dP]] },
    ["P"] = { [["_dP]] },
    -- better increment/decrement
    ["+"] = { "g<C-a>", desc = "Increment number" },
    ["_"] = { "g<C-x>", desc = "Descrement number" },
    -- line text-objects
    ["il"] = { "g_o^", desc = "Inside line text object" },
    ["al"] = { "$o^", desc = "Around line text object" },
    -- Easy-Align
    ga = { "<Plug>(EasyAlign)", desc = "Easy Align" },
    -- Tressitter Surfer
    ["J"] = {
      function() require("syntax-tree-surfer").surf("next", "visual") end,
      desc = "Surf next tree-sitter object",
    },
    ["K"] = {
      function() require("syntax-tree-surfer").surf("prev", "visual") end,
      desc = "Surf previous tree-sitter object",
    },
    ["H"] = {
      function() require("syntax-tree-surfer").surf("parent", "visual") end,
      desc = "Surf parent tree-sitter object",
    },
    ["L"] = {
      function() require("syntax-tree-surfer").surf("child", "visual") end,
      desc = "Surf child tree-sitter object",
    },
    ["<C-j>"] = {
      function() require("syntax-tree-surfer").surf("next", "visual", true) end,
      desc = "Surf next tree-sitter object",
    },
    ["<C-l>"] = {
      function() require("syntax-tree-surfer").surf("next", "visual", true) end,
      desc = "Surf next tree-sitter object",
    },
    ["<C-k>"] = {
      function() require("syntax-tree-surfer").surf("prev", "visual", true) end,
      desc = "Surf previous tree-sitter object",
    },
    ["<C-h>"] = {
      function() require("syntax-tree-surfer").surf("prev", "visual", true) end,
      desc = "Surf previous tree-sitter object",
    },
  },


  o = {
    -- line text-objects
    ["il"] = { ":normal vil<cr>", desc = "Inside line text object" },
    ["al"] = { ":normal val<cr>", desc = "Around line text object" },
  },



}

-- add more text objects for "in" and "around"
for _, char in ipairs { "_", ".", ":", ",", ";", "|", "/", "\\", "*", "+", "%", "`", "?" } do
  for _, mode in ipairs { "x", "o" } do
    mappings[mode]["i" .. char] =
    { string.format(":<C-u>silent! normal! f%sF%slvt%s<CR>", char, char, char), desc = "between " .. char }
    mappings[mode]["a" .. char] =
    { string.format(":<C-u>silent! normal! f%sF%svf%s<CR>", char, char, char), desc = "around " .. char }
  end
end

--v.set_mappings(vim.tbl_deep_extend("force", mappings, maps))
v.set_mappings(mappings)

--#endregion_mappings
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

---Final polish and color .
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--#region_polish



-- local colorscheme = "carbonfox"
local colorscheme
-- local colorscheme = "carbonfox"
if not colorscheme == nil then colorscheme = pcall(vim.cmd.colorscheme, colorscheme) end
if not colorscheme then vim.cmd.colorscheme "vimsharp" end

-- v.conditional_func(v.user_plugin_opts("polish", nil, false), true)

--#endregion_polish
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

---end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
_G.vimsharp = v
