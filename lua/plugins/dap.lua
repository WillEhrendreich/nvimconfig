local fn = vim.fn
local dap = require("dap")
local tc = vim.tbl_contains
local has = require("lazyvim.util").has
local strs = require("plenary.strings")
if not vim.g["DotnetStartupProjectRootPath"] then
  vim.g["DotnetStartupProjectRootPath"] = ""
end
if not vim.g["DotnetExePath"] then
  vim.g["DotnetExePath"] = ""
end
if not vim.g["DotnetDllPath"] then
  vim.g["DotnetDllPath"] = ""
end
if not vim.g["DotnetStartupProjectPath"] then
  vim.g["DotnetStartupProjectPath"] = ""
end
if not vim.g["DotnetProjectFileName"] then
  vim.g["DotnetProjectFileName"] = ""
end
if not vim.g["DotnetProjectFileExtension"] then
  vim.g["DotnetProjectFileExtension"] = ""
end

local function get_extension(filepath)
  if filepath then
    return ("." .. (vim.fs.normalize(filepath or ""):match("%.([^%.]+)$") or "")) or ""
  else
    return ""
  end
end
local function get_directory(filepath)
  if filepath then
    return (vim.fs.normalize(filepath or ""):match("(.*/)")) or ""
  else
    return ""
  end
end
local function get_filename_without_extension(path)
  -- extract the filename with extension from the path
  local filename_with_extension = string.match(path or "", "[^/]+$")
  -- extract the filename without extension from the filename with extension
  local filename_without_extension = (string.match(filename_with_extension or "", "^(.+)%..+$")) or ""
  return filename_without_extension
end

-- DotnetSlnRootPath = vim.g["DotnetSlnRootPath"]
-- DotnetStartupProjectRootPath = vim.g["DotnetStartupProjectRootPath"]
-- DotnetDllPath = vim.g["DotnetDllPath"]
-- DotnetExePath = vim.g["DotnetExePath"]
-- DotnetProjectFileName = vim.g["DotnetProjectFileName"]
-- DotnetProjectFileExtension = vim.g["DotnetProjectFileExtension"]

local function pick_one_sync(items, prompt, label_fn)
  local choices = { prompt }
  for i, item in ipairs(items) do
    table.insert(choices, string.format("%d: %s", i, label_fn(item)))
  end
  local choice = vim.fn.inputlist(choices)
  if choice < 1 or choice > #items then
    return nil
  end
  return items[choice]
end

local function pick_one(items, prompt, label_fn, cb)
  local co
  if not cb then
    co = coroutine.running()
    if co then
      cb = function(item)
        coroutine.resume(co, item)
      end
    end
  end
  cb = vim.schedule_wrap(cb)
  if vim.ui then
    vim.ui.select(items, {
      prompt = prompt,
      format_item = label_fn,
    }, cb)
  else
    local result = pick_one_sync(items, prompt, label_fn)
    cb(result)
  end
  if co then
    return coroutine.yield()
  end
end

local function pick_if_many(items, prompt, label_fn, cb)
  if #items == 1 then
    if not cb then
      return items[1]
    else
      cb(items[1])
    end
  else
    return pick_one(items, prompt, label_fn, cb)
  end
end

local function pick_if_many_sync(items, prompt, label_fn)
  if #items == 1 then
    return items[1]
  else
    return pick_one_sync(items, prompt, label_fn)
  end
end

---gets nearest project file in relation to the open file.
---@param buf integer
---@return string
local function get_nearest_proj(buf)
  buf = buf or 0
  local currentFileDir = vim.fs.normalize(vim.fs.dirname(vim.api.nvim_buf_get_name(buf or 0)) or vim.fn.getcwd())
  vim.notify("currentFileDir " .. vim.inspect(currentFileDir))
  local currentWorkingDir = vim.fs.normalize(vim.fn.getcwd() or "")
  vim.notify("currentWorkingDir " .. vim.inspect(currentWorkingDir))
  -- local superlocal = "*/*.*proj"
  -- local semilocal = "**/*.*proj"
  local proj = (vim.fs.find(
    function(name, path)
      return name:match(".*%.[cfv][sb]proj$")
        and path:match(vim.fs.normalize(vim.fs.dirname(vim.api.nvim_buf_get_name(buf or 0)) or vim.fn.getcwd()))
    end,
    { type = "file", path = vim.fs.normalize(vim.fs.dirname(vim.api.nvim_buf_get_name(buf or 0)) or vim.fn.getcwd()) }
  ))[1] or ""
  -- ---@type string

  local pick = proj or ""
  if not currentWorkingDir == currentFileDir then
    -- vim.cmd.chdir(currentFileDir)
  else
  end

  vim.notify("building " .. vim.inspect(pick))
  return pick

  -- end)
end

local function get_proj(projectName)
  ---@type table<string>
  -- local items = vim.fn.globpath(vim.fs.normalize(vim.fn.getcwd()), "*/*proj", 0, 1) or {}
  --

  local projEndings = {
    ".csproj",
    ".fsproj",
    ".vbproj",
  }

  local items = vim.fs.find(function(name, path)
    local fsmatch = name:match(projectName .. ".fsproj")
    local csmatch = name:match(projectName .. ".csproj")
    local vbmatch = name:match(projectName .. ".vbproj")

    if fsmatch then
      return fsmatch
    elseif csmatch then
      return csmatch
    elseif vbmatch then
      return vbmatch
    else
      return false
    end
  end, { limit = 1, type = "file", path = FindRoot({ "" }, vim.lsp.buf_get_clients(0, { name = "ionide" })) }) or {}

  local roslynItems = vim.fs.find(function(name, path)
    local fsmatch = name:match(projectName .. ".fsproj")
    local csmatch = name:match(projectName .. ".csproj")
    local vbmatch = name:match(projectName .. ".vbproj")

    if fsmatch then
      return fsmatch
    elseif csmatch then
      return csmatch
    elseif vbmatch then
      return vbmatch
    else
      return false
    end
  end, { limit = 1, type = "file", path = FindRoot({ "" }, vim.lsp.buf_get_clients(0, { name = "roslyn" })) }) or {}
  local omnisharpItems = vim.fs.find(function(name, path)
    local fsmatch = name:match(projectName .. ".fsproj")
    local csmatch = name:match(projectName .. ".csproj")
    local vbmatch = name:match(projectName .. ".vbproj")

    if fsmatch then
      return fsmatch
    elseif csmatch then
      return csmatch
    elseif vbmatch then
      return vbmatch
    else
      return false
    end
  end, { limit = 1, type = "file", path = FindRoot({ "" }, vim.lsp.buf_get_clients(0, { name = "omnisharp" })) }) or {}
  local fsautocompleteItems = vim.fs.find(function(name, path)
    local fsmatch = name:match(projectName .. ".fsproj")
    local csmatch = name:match(projectName .. ".csproj")
    local vbmatch = name:match(projectName .. ".vbproj")

    if fsmatch then
      return fsmatch
    elseif csmatch then
      return csmatch
    elseif vbmatch then
      return vbmatch
    else
      return false
    end
  end, { limit = 1, type = "file", path = FindRoot({ "" }, vim.lsp.buf_get_clients(0, { name = "fsautcomplete" })) }) or {}
  local csharplsItems = vim.fs.find(function(name, path)
    local fsmatch = name:match(projectName .. ".fsproj")
    local csmatch = name:match(projectName .. ".csproj")
    local vbmatch = name:match(projectName .. ".vbproj")

    if fsmatch then
      return fsmatch
    elseif csmatch then
      return csmatch
    elseif vbmatch then
      return vbmatch
    else
      return false
    end
  end, { limit = 1, type = "file", path = FindRoot({ "" }, vim.lsp.buf_get_clients(0, { name = "csharp_ls" })) }) or {}
  -- local cpp_hpp = vim.fs.find()
  --  if #items < 1 then
  --    items = vim.fn.globpath(vim.fs.normalize(vim.fn.getcwd()), "**/*proj", 0, 1) or {}
  --  end

  -- vim.tbl_map(function(path) return require("plenary.path").new(vim.fn.fnamemodify(path, ":p")  ):shorten(3) end, vim.fn.globpath("c:/users/will.ehrendreich/source/repos/Fabload/", "**/bin/Debug/**/*.dll", 0, 1))
  -- for i,match in ipairs(omnisharpItems)
  --   )
  --
  -- end

  vim.tbl_extend("force", items, omnisharpItems, fsautocompleteItems, csharplsItems, roslynItems)

  -- local opts = {
  --   format_item = function(path)
  --     return vim.fn.fnamemodify(path, ":t")
  --     -- return require("plenary.path").new(vim.fn.fnamemodify(path, ":p")):shorten(3)
  --   end,
  -- }

  local pick = pick_if_many_sync(items, "Which Project is the startup project?", function(p)
    return vim.fs.normalize(p or "")
  end)
  vim.notify("picked " .. (pick or ""))
  -- vim.notify("building " .. vim.inspect(pick))
  return pick

  -- end)
end

-- local function dump(...)
--   local objects = vim.tbl_map(vim.inspect, { ... })
--   print(unpack(objects))
--   return ...
-- end
local function first_to_upper(str)
  return str:gsub("^%l", string.upper)
end

---this should grab the correct lsp root of whatever buf is passed in.
---@param ignored_lsp_servers table<string>
---@param client lsp.Client
---@param bufnr number
---@return unknown
function FindRoot(ignored_lsp_servers, client, bufnr)
  local b = bufnr or 0
  -- Get lsp client for current buffer
  -- local bufDir = Lsppath.GetDirForBufnr(bufnr)
  local ignore = ignored_lsp_servers or {}
  -- vim.notify(vim.inspect(ignore) .. "are being ignored when finding root")
  -- u
  -- vim.notify(vim.inspect(b) .. " is the bufnumber with filename " .. Lsppath.GetBaseFilenameForBufnr(b))
  local buf_ft = vim.api.nvim_buf_get_option(b, "filetype")
  local result
  -- local clients = vim.lsp.get_active_clients({
  --   bufnr = b,
  -- })
  local i = ignore or {}
  -- for _, c in pairs(clients) do
  local cname = client.name
  -- LspNotify("client name is " .. (cname or "not found"))
  -- local bufname = vim.api.nvim_buf_get_name(bufnr)
  -- LspNotify("buf name is " .. (bufname or "not found"))
  -- local lspConfigForClient = re 'lspconfig.configs'[cname]
  -- LspNotify("config for " .. (cname or "not found") .. " is " .. vim.inspect(lspConfigForClient or " not found.."))
  local filetypes = client.config.filetypes
  if filetypes and vim.tbl_contains(filetypes, buf_ft) then
    if not vim.tbl_contains(i, cname) then
      local rootDirFunction = client
      -- LspNotify("lsp root dir function is " .. vim.inspect(rootDirFunction or "not found"))
      local activeConfigRootDir = client.config.root_dir
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
  -- end
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

---replaces something in a string.
---@param x string
---@param to_replace string
---@param replace_with string
---@return string
function StringReplace(x, to_replace, replace_with)
  -- if type(x) == "string" then
  local s, _ = string.gsub(x, to_replace, replace_with)
  return s
  -- end
end

-- local function getProj()
--   ---@type table<string>
--   local items = vim.fn.globpath(vim.fn.getcwd(), "**/*proj", 0, 1)
--
--   -- vim.tbl_map(function(path) return require("plenary.path").new(vim.fn.fnamemodify(path, ":p")  ):shorten(3) end, vim.fn.globpath("c:/users/will.ehrendreich/source/repos/Fabload/", "**/bin/Debug/**/*.dll", 0, 1))
--
--   local opts = {
--     format_item = function(path)
--       return vim.fn.fnamemodify(path, ":t")
--       -- return require("plenary.path").new(vim.fn.fnamemodify(path, ":p")):shorten(3)
--     end,
--   }
--   local function cont(choice)
--     if choice == nil then
--       return ""
--     else
--       -- coroutine.resume( choice)
--       return choice
--     end
--   end
--
--   vim.ui.select(items, opts, cont)
--
--   -- vim.fn.browse(false, "Select Debug Target Dll.. ", vim.fn.getcwd(), default)
-- end

function GetCurrentBufDirname()
  local p = vim.fs.normalize(vim.fs.dirname(string.sub(vim.uri_from_bufnr(vim.api.nvim_get_current_buf()), 9)))
  return p
end

function GetDotnetProjectPath(askForChanges, buf)
  ---@type string
  local dirname = GetCurrentBufDirname()
  ---@type string
  local projectName = vim.g["DotnetProjectFileName"]
  ---@type string
  local ext = vim.g["DotnetProjectFileExtension"]
  ---@type string
  local path
  ---@type string
  local nearestProj
  -- if vim.g["DotnetStartupProjectPath"] == "" then
  nearestProj = get_nearest_proj(buf) or ""
  -- else
  -- nearestProj = vim.g["DotnetStartupProjectPath"]
  -- end

  if not nearestProj then
    nearestProj = ""
  end
  -- local files = vim.fn.readdir(dirname)
  -- for _, file in ipairs(files) do
  --   if not nearestProj then
  --     local p = Path:new(file)
  --
  --     if StringEndsWith(file, "proj") then
  --       -- local full_path = dirname .. '/' .. file
  --       nearestProj = string.sub(file, 0, string.len(file) - 7)
  --       ext = string.sub(file, string.len(file) - 6)
  --       -- nearestProj = string.sub(n, string.len(dirname), string.len(n) - 8)
  --     end
  --   end
  -- end
  -- local Path: Path {
  --     absolute: function,
  --     close: function,
  --     copy: function,
  --     exists: function,
  --     expand: function,
  --     filename: string|unknown = ".",
  --     head: function,
  --     is_absolute: function,
  --     is_dir: function,
  --     is_file: function,
  --     is_path: function,
  --     iter: function,
  --     joinpath: function,
  --     make_relative: function,
  --     mkdir: function,
  --     new: function,
  --     normalize: function,
  --     open: function,
  --     parent: function,
  --     parents: function,
  --     path: table,
  --     read: function,
  --     readbyterange: function,
  --     readlines: function,
  --     rename: function,
  --     rm: function,
  --     rmdir: function,
  --     shorten: function,
  --     tail: function,
  --     touch: function,
  --     write: function,
  --     __concat: function,
  --     __div: function,
  --     __index: function,
  --     __tostring: function,
  --     _fs_filename: function,
  --     _read: function,
  --     _read_async: function,
  --     _split: function,
  --     _st_mode: function,
  --     _stat: function,
  -- }
  -- local Path = require("plenary.path")

  -- local p = Path:new(nearestProj)
  --
  -- dump(p)
  --
  -- dump(p.path)

  local parentDir = get_directory(nearestProj)
  ext = get_extension(nearestProj)
  -- dump(ext)
  local fileShortNameAndExtension = StringReplace(nearestProj, parentDir, "")
  if not projectName or projectName == "" then
    projectName = StringReplace(fileShortNameAndExtension, ext, "")
  end
  -- if not vim.g["DotnetProjectFileName"] or vim.g["DotnetProjectFileName"] == "" then
  vim.g["DotnetProjectFileName"] = projectName
  -- end
  vim.notify("project name is " .. projectName)
  -- if not vim.g["DotnetProjectFileExtension"] or vim.g["DotnetProjectFileExtension"] == "" then
  vim.g["DotnetProjectFileExtension"] = ext
  -- end
  -- path = dirname .. "/" .. projectName .. ext
  -- if not vim.g["DotnetStartupProjectPath"] or vim.g["DotnetStartupProjectPath"] == "" then
  vim.g["DotnetStartupProjectPath"] = nearestProj
  -- end

  path = nearestProj
  if path == "" then
    -- vim.notify("StartupProjectPath was either blank or nil")
    path = GetCurrentBufDirname()
  end

  local function request(initialPath)
    vim.validate({ initialPath = { initialPath, "string" } })
    ---@type string
    -- local response = vim.fn.input({ prompt = "Path to project: ", default = initialPath, completion = "file" })
    local response = (vim.fs.normalize(get_proj()))

    vim.notify(vim.inspect(response))
    if not StringEndsWith(response, "sproj") then
      response = vim.fn.input({
        "Given path didn't end with 'sproj'.. " .. "\nPlease provide an actual path to the startup project: \n",
        initialPath,
        "file",
      })
    end
    if not StringEndsWith(response, "sproj") then
      vim.notify(
        "Fine.. BE that way.. You don't want to give an actual path? I'm setting the path to ERROR.BADproj, and you will get errors.. but it's out of my hands now. *tsk tsk.* you try to help someone.. geeez.. "
      )
      response = "ERROR.BADproj"
    end
    vim.notify(vim.inspect(response))
    return response
  end
  if
    askForChanges
    and vim.fn.confirm(
        "Do you want to change the path to project? \n" .. vim.inspect(vim.fs.normalize(path)),
        "&yes\n&no",
        2
      )
      == 1
  then
    path = (vim.fs.normalize(request(path)))
  end
  vim.notify("Path to startup project is set to: " .. vim.inspect(path))
  -- Lspdebug.GetConfig()
  -- local path =  vim.fn.input({ "Path to your startup *proj file ", LspStartupProjectPath, "file" })
  local pathParent = vim.fs.dirname(path)
  vim.fn.chdir(pathParent)
  -- vim.g["DotnetStartupProjectPath"] = path
  return path
end

function OpenFileInNewBuffer(f)
  local file_exists = vim.fn.filereadable(f) == true
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

function DotnetBuildRelease(p, launch, askForChanges)
  local cmd = "dotnet build " .. p .. " --release"
  vim.notify("Building ... command " .. cmd)
  local buildData = "Build Report: "
  -- local outputInteger = 1
  -- local jobid = -444
  local f = vim.fn.jobstart(cmd, {
    cwd = vim.fn.getcwd(),
    on_stdout = function(id, data, event)
      -- jobid = id
      vim.notify(vim.fn.inspect(StringReplace(data[1], "\\r", "\n")))
      -- vim.notify(vim.inspect(StringReplace(data[1], "\\r", "\n")))
      -- buildData = buildData .. (vim.inspect(StringReplace(data[1], "\\r", "\n")))
    end,
    on_exit = function(id, exitCode)
      -- vim.notify(vim.inspect(buildData))
      local f = exitCode
      -- local f = os.execute(cmd)
      if f == 0 then
        vim.notify("\nBuild release: ✔️ ")
        return true
      else
        vim.notify("\nBuild release failed: ❌ (exit code: " .. vim.inspect(f) .. "code: " .. vim.inspect(f) .. ")")
        --    LspOpenFileInNewBuffer(logfile)
        return false
      end
      -- outputInteger = exitCode
    end,
  })
end

function DotnetBuildDebugPopup(p, launch, launchWithDebugger, askForChanges)
  local cmd = { "dotnet", "build", p, "--debug" }
  local utils = require("config.util")

  -- vim.notify("Building command " .. cmd)
  local buildData = "Build Report: \n"
  -- local outputInteger = 1
  -- local float = utils.float_term(cmd)
  -- local float = utils.float_cmd(cmd)
  local f = utils.float_term(cmd, {
    cwd = vim.fn.getcwd(),
    on_stdout = function(id, data, event)
      -- jobid = id
      -- local k, v = unpack(data)
      buildData = buildData .. "\n" .. (StringReplace(vim.inspect(vim.fs.normalize(data[1])), "\\r", ""))
      -- vim.notify(vim.inspect(StringReplace(k, "\r", "")))
      -- buildData = buildData .. (vim.fn.inspect(StringReplace(data[1], "\\r", "\n")))
    end,
    on_exit = function(id, exitCode)
      vim.notify(
        (
          utils.markdown(
            buildData or "No Build Data populated!! did it run correctly?",
            { title = "DotnetBuildReport" }
          ) or "No Build Data populated!! did it run correctly?"
        )
      )
      local f = exitCode
      if f == 0 then
        vim.notify("\nBuild debug: ✔️ ")
        if launch then
          if launchWithDebugger then
            require("dap").continue()
          else
            local dllpath = GetDotnetDllPath(askForChanges)
            local exe = StringReplace(dllpath, "dll", "exe")
            local exists = utils.file_exists(exe)
            if exists then
              vim.g["DotnetExePath"] = exe
              utils.open(exe)
            end
          end
        end
        return true
      else
        vim.notify(
          "\nBuild debug failed: ❌ (exit code: "
            .. vim.inspect(f) -- .. "Build output :\n"
            -- .. vim.inspect(buildData)
            .. ")"
        )

        --    LspOpenFileInNewBuffer(logfile)
        return false
      end
    end,
  })

  -- vim.notify(vim.inspect(f))
  return f
end

function DotnetBuildDebug(p, launch, launchWithDebugger, askForChanges)
  local cmd = "dotnet build " .. p .. " --debug"
  vim.notify("Building command " .. cmd)
  local buildData = "Build Report: "
  local outputInteger = 1
  local f = vim.fn.jobstart(cmd, {
    cwd = vim.fn.getcwd(),
    on_stdout = function(id, data, event)
      -- jobid = id
      -- local k, v = unpack(data)
      vim.notify(StringReplace(vim.inspect(vim.fs.normalize(data[1])), "\\r", ""))
      -- vim.notify(vim.inspect(StringReplace(k, "\r", "")))
      -- buildData = buildData .. (vim.fn.inspect(StringReplace(data[1], "\\r", "\n")))
    end,
    on_exit = function(id, exitCode)
      -- vim.notify(vim.inspect(buildData))
      outputInteger = exitCode
      local f = outputInteger
      if f == 0 then
        vim.notify("\nBuild debug: ✔️ ")
        if launch then
          if launchWithDebugger then
            require("dap").continue()
          else
            local utils = require("config.util")
            local dllpath = GetDotnetDllPath(askForChanges)
            local exe = StringReplace(dllpath, "dll", "exe")
            local exists = utils.file_exists(exe)
            if exists then
              vim.g["DotnetExePath"] = exe
              utils.open(exe)
            end
          end
        end
        return true
      else
        vim.notify("\nBuild debug failed: ❌ (exit code: " .. vim.inspect(f) .. "code: " .. vim.inspect(f) .. ")")

        --    LspOpenFileInNewBuffer(logfile)
        return false
      end
    end,
  })
  return f
end

local function get_dll_Sync(startProjectPath, projectName)
  -- local proj = get_proj()
  ---@type table<string>
  -- local items = vim.fn.globpath(startProjectPath, "bin/Debug/" .. projectName .. ".dll", false, true)

  local items = vim.fs.find(projectName .. ".dll", {

    { limit = math.huge, type = "file", path = startProjectPath },
  })
  -- local items = vim.fn.globpath(vim.fn.getcwd(), "**/bin/Debug/*" .. projectName .. ".dll", false, true)

  -- vim.tbl_map(function(path) return require("plenary.path").new(vim.fn.fnamemodify(path, ":p")  ):shorten(3) end, vim.fn.globpath("c:/users/will.ehrendreich/source/repos/Fabload/", "**/bin/Debug/**/*.dll", 0, 1))
  --
  -- local opts = {
  --   format_item = function(path)
  --     return require("plenary.path").new(vim.fn.fnamemodify(path, ":p")):shorten(3)
  --   end,
  -- }

  local pick = pick_if_many_sync(items, "Which dll is the debug target?", function(p)
    return vim.fs.normalize(p)
  end)

  vim.notify("dll picked is: " .. pick)
  return pick or ""
  -- vim.ui.select(items, opts, cont)

  -- vim.fn.browse(false, "Select Debug Target Dll.. ", vim.fn.getcwd(), default)
end

function GetDotnetDllPath(askForChanges, buf)
  ---@type string
  local nearestProj
  if vim.g["DotnetStartupProjectPath"] == "" then
    nearestProj = get_nearest_proj(buf) or ""
  else
    nearestProj = vim.g["DotnetStartupProjectPath"]
  end

  if not nearestProj then
    nearestProj = ""
  end

  local parentDir = get_directory(nearestProj)
  vim.notify("parent dir is " .. parentDir)
  local projectName = get_filename_without_extension(nearestProj)
  vim.notify("project name is " .. projectName)
  local ext = get_extension(nearestProj)
  vim.notify("extension is " .. ext)
  -- dump(ext)
  if not vim.g["DotnetProjectFileName"] or vim.g["DotnetProjectFileName"] == "" then
    vim.g["DotnetProjectFileName"] = projectName
  end
  -- local path = dirname .. "/bin/debug/" .. projectName .. ".dll"
  -- local path = vim.fs.normalize(parentDir .. "bin/debug/" .. projectName .. ".dll")
  --
  local path = vim.fs.find(projectName .. ".dll", {
    { limit = 1, type = "file", path = parentDir },
  })[1] or vim.fs.normalize(parentDir .. "bin/debug/" .. projectName .. ".dll")

  -- print("path construction is " .. path)
  if not vim.g["DotnetDllPath"] or vim.g["DotnetDllPath"] == "" then
    vim.notify("DotnetDllPath was {" .. vim.inspect(vim.g["DotnetDllPath"]) .. "} Setting it to " .. path)
    vim.g["DotnetDllPath"] = path
  end
  local request = function()
    -- local p = vim.fn.input({ prompt = "Path to dll ", default = givenPath, completion = "file", cancelreturn = "" })
    local p = get_dll_Sync(parentDir, projectName)
    local pathWithExt = p .. ".dll"
    local readable = vim.fn.filereadable(pathWithExt) == 1
    if not StringEndsWith(p, ".dll") then
      if not readable then
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
  if
    askForChanges
    and vim.fn.confirm("Do you want to change the path to dll? \n" .. vim.g["DotnetDllPath"], "&yes\n&no", 2) == 1
  then
    path = request()
    vim.g["DotnetDllPath"] = path
    vim.notify("path to dll is set to: " .. path)
  end
  return path
end

function DotnetBuild(path, buildType, launch, launchWithDebugger, askForChanges)
  local t = buildType or "debug"
  if t == "r" or t == "release" or t == "Release" or t == "R" then
    vim.notify("building project: " .. path .. " with build type " .. t)
    return DotnetBuildRelease(path, launch, askForChanges)
  else
    vim.notify("building project: " .. path .. " with build type " .. t)
    return DotnetBuildDebugPopup(path, launch, launchWithDebugger, askForChanges)
  end
end

-- if vim.g.lsp_handlers_enabled then
-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
-- end
-- --- Check if a buffer is valid
-- -- @param bufnr the buffer to check
-- -- @return true if the buffer is valid or false
-- function Lspis_valid_buffer(bufnr)
--   if not bufnr or bufnr < 1 then return false end
--   return vim.bo[bufnr].buflisted and vim.api.nvim_buf_is_valid(bufnr)
-- end
--
--
local function get_dll()
  return coroutine.create(function(dap_run_co)
    local dllChoice = GetDotnetDllPath()
    if dllChoice == nil then
      return nil
    else
      coroutine.resume(dap_run_co, dllChoice)
    end
  end)
end

---tells you if you have a current buffer open that is a dotnet filetype
---@return boolean
local function BufIsDotnet()
  local ft = vim.bo.filetype
  local isDotnet = ft == "csx"
    or ft == "cs"
    or ft == "csproj"
    or ft == "cs_project"
    or ft == "razor"
    or ft == "cshtml"
    or ft == "vb"
    or ft == "cs"
    or ft == "fsharp"
    or ft == "fsharp_project"
  return isDotnet
end

local function beforeDebug(opts)
  --Check if the current filetype is one of the ones that are listed for the coreclr adapter, and if it is, then build
  --
  local bufferThatStarted = vim.api.nvim_get_current_buf()
  -- vim.notify("buffer: " .. vim.inspect(opts))
  -- vim.notify("bufferCurrent: " .. vim.inspect(bufferThatStarted))

  local askForChanges
  -- vim.notify(vim.inspect(opts))
  if opts.args and opts.args[1] and opts.args[1] == true then
    askForChanges = true
  else
    askForChanges = false
  end

  local session = require("dap").session()
  local isInDebugSession = session and session.closed == false
  local buildSuccessful
  local hasOverSeer = has("overseer.nvim")

  local path

  if BufIsDotnet() and not isInDebugSession then
    path = GetDotnetProjectPath(askForChanges, bufferThatStarted)
  end

  if hasOverSeer == true then
    vim.notify("Overseer present, handing build off to that")
    -- local path = get_proj()
    --
    -- local overseer = require("overseer")
    -- overseer

    -- local thiswin = vim.api.nvim_get_current_win()

    -- local dllpath = GetDotnetDllPath(askForChanges, bufferThatStarted)
    local oCmds = require("overseer.commands")
    oCmds._open({ bang = true })
    -- vim.api.nvim_set_option_value("wrap", true, { win = vim.api.nvim_get_current_win() })
    -- vim.api.nvim_set_current_win(thiswin)

    -- {
    --   _start_tasks = <function 1>,
    --   add_template_hook = <function 2>,
    --   clear_task_cache = <function 3>,
    --   close = <function 4>,
    --   debug_parser = <function 5>,
    --   delete_task_bundle = <function 6>,
    --   get_all_commands = <function 7>,
    --   get_all_highlights = <function 8>,
    --   list_task_bundles = <function 9>,
    --   list_tasks = <function 10>,
    --   load_task_bundle = <function 11>,
    --   load_template = <function 12>,
    --   new_task = <function 13>,
    --   on_setup = <function 14>,
    --   open = <function 15>,
    --   preload_task_cache = <function 16>,
    --   register_template = <function 17>,
    --   remove_template_hook = <function 18>,
    --   run_action = <function 19>,
    --   run_template = <function 20>,
    --   save_task_bundle = <function 21>,
    --   setup = <function 22>,
    --   toggle = <function 23>,
    --   wrap_template = <function 24>,
    --   <metatable> = {
    --     __index = <function 25>
    --   }
    -- }

    -- local bin = vim.g["DotnetStartupProjectRootPath"] .. "bin/"
    -- local obj = vim.g["DotnetStartupProjectRootPath"] .. "obj/"
    -- os.execute("rm -path " .. obj .. "-Recurse -Force -Confirm:$false")
    -- os.execute("rm -path " .. bin .. "-Recurse -Force -Confirm:$false")

    -- buildSuccessful = DotnetBuild(path, "debug", true, true)
    -- else
    require("dap").continue()
    -- GetDotnetDllPath(askForChanges)
    -- buildSuccessful = true
    -- overseer
    -- if buildSuccessful == true then
    -- oCmds._close()
    -- end
  else
    -- local bin = vim.g["DotnetStartupProjectRootPath"] .. "bin/"
    -- local obj = vim.g["DotnetStartupProjectRootPath"] .. "obj/"
    -- os.execute("rm -path " .. obj .. "-Recurse -Force -Confirm:$false")
    -- os.execute("rm -path " .. bin .. "-Recurse -Force -Confirm:$false")

    buildSuccessful = DotnetBuild(path, "debug", true, true)
    -- local dllpath = GetDotnetDllPath(askForChanges)
    require("dap").continue()
  end
  return buildSuccessful or true
end

-- Creating user commands                           *lua-guide-commands-create*
--
-- User commands can be created through with |nvim_create_user_command()|. This
-- function takes three mandatory arguments:
-- • a string that is the name of the command (which must start with an uppercase
--   letter to distinguish it from builtin commands);
-- • a string containing Vim commands or a Lua function that is executed when the
--   command is invoked;
-- • a table with |command-attributes|; in addition, it can contain the keys
--   `desc` (a string describing the command); `force` (set to `false` to avoid
--   replacing an already existing command with the same name), and `preview` (a
--   Lua function that is used for |:command-preview|).
--
-- Example:
-- >lua
--     vim.api.nvim_create_user_command('Test', 'echo "It works!"', {})
--     vim.cmd.Test()
--     --> It works!
-- <
-- (Note that the third argument is mandatory even if no attributes are given.)
--
-- Lua functions are called with a single table argument containing arguments and
-- modifiers. The most important are:
-- • `name`: a string with the command name
-- • `fargs`: a table containing the command arguments split by whitespace (see |<f-args>|)
-- • `bang`: `true` if the command was executed with a `!` modifier (see |<bang>|)
-- • `line1`: the starting line number of the command range (see |<line1>|)
-- • `line2`: the final line number of the command range (see |<line2>|)
-- • `range`: the number of items in the command range: 0, 1, or 2 (see |<range>|)
-- • `count`: any count supplied (see |<count>|)
-- • `smods`: a table containing the command modifiers (see |<mods>|)
--
-- For example:
-- >lua
--     vim.api.nvim_create_user_command('Upper',
--       function(opts)
--         print(string.upper(opts.fargs[1]))
--       end,
--       { nargs = 1 })
--
--     vim.cmd.Upper('foo')
--     --> FOO
-- <
-- The `complete` attribute can take a Lua function in addition to the
-- attributes listed in |:command-complete|. >lua
--
--     vim.api.nvim_create_user_command('Upper',
--       function(opts)
--         print(string.upper(opts.fargs[1]))
--       end,
--       { nargs = 1,
--         complete = function(ArgLead, CmdLine, CursorPos)
--           -- return completion candidates as a list-like table
--           return { "foo", "bar", "baz" }
--         end,
--     })
-- <
vim.api.nvim_create_user_command("PreDebugTask", beforeDebug, {

  nargs = "?",
  desc = "Dotnet Build Before Debug",
})

-- M.coreclr = {
-- 	{                  /
-- 		type = 'coreclr',
-- 		name = 'NetCoreDbg: Launch',
-- 		request = 'launch',
-- 		cwd = '${fileDirname}',
-- 		program = get_dll,
-- 	},
-- }

local dotnetDapConfig = {
  type = "coreclr",
  name = "NetCoreDbg",
  preLaunchTask = "build",
  request = "launch",
  console = "internalConsole",
  cwd = "${fileDirname}",
  program = get_dll,
}
-- {
--         type = "netcoredbg",
--         name = "attach - netcoredbg",
--         request = "attach",
--         processId = function()
--           local pgrep = vim.fn.system("pgrep -f 'dotnet run'")
--           vim.fn.setenv('NETCOREDBG_ATTACH_PID',"${command:pickProcess}")
--           return tonumber(pgrep)
--         end,
--       },
-- end

-- end

-- local function getDapConfig()
--   local root = FindRoot() or vim.fn.getcwd()
--   -- local root = vimsharp.utils.lsp.FindRoot(vimsharp.utils.lsp.IgnoredLspServersForFindingRoot) or vim.fn.getcwd()
--
--   -- vim.notify("just set dap.adapters.coreclr to " .. vim.inspect(dap.adapters.coreclr or "NOTHING:?:???!+?@!?"))
--   local dap_config = DecodeJsonFile(root .. "/.dap.json") or dotnetDapConfig
--   if dap_config ~= nil then
--     -- vim.notify("just set dap.adapters.coreclr to " .. vim.inspect(dap.adapters.coreclr or "NOTHING:?:???!+?@!?"))
--     return { dap_config }
--   end
--
--   local status_ok, vscode_launch_file = pcall(DecodeJsonFile, root .. "/.vscode/launch.json")
--   if status_ok and vscode_launch_file ~= nil then
--     local configs = vscode_launch_file["configurations"]
--     if configs ~= nil then
--       for j = 1, #configs do
--         if configs[j]["request"] == "launch" then
--           local config = StringReplace(configs[j], "${workspaceRoot}", root)
--           return { config }
--         end
--       end
--       return vim.json_encode(StringReplace(configs, "${workspaceRoot}", root))
--     end
--   end
--
--   -- vim.notify("just set dap.adapters.coreclr to " .. vim.inspect(dap.adapters.coreclr or "NOTHING:?:???!+?@!?"))
--   return nil
-- end

local function dapuiconfigFunc(_, opts)
  local dap, dapui = require("dap"), require("dapui")
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
  dapui.setup(opts)
end

local function get_first_string_value(t)
  for _, value in pairs(t) do
    if type(value) == "string" then
      return value
    end
  end
end

local function dapconfig(_, opts)
  local mason_nvim_dap = require("mason-nvim-dap")

  dap.set_loglevel = "TRACE"
  local o = vim.tbl_deep_extend("force", opts, {

    handlers = {
      function(config)
        -- all sources with no handler get passed here
        -- Keep original functionality of `automatic_init = true`
        require("mason-nvim-dap").default_setup(config)
      end,

      ---comment
      ---@param config
      coreclr = function(config)
        -- local dap = require("dap")
        for _, lang in ipairs({ "c", "cpp", "rust" }) do
          dap.configurations[lang] = {
            {
              type = "codelldb",
              request = "launch",
              name = "Launch file",
              program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end,
              cwd = "${workspaceFolder}",
            },
            {
              type = "codelldb",
              request = "attach",
              name = "Attach to process",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
          }
        end
        dap.configurations.cs = { dotnetDapConfig }
        dap.configurations.fsharp = { dotnetDapConfig }

        dap.adapters.codelldb = {
          name = "codelldb",
          type = "server",
          -- host = "127.0.0.1",
          host = "localhost",
          port = "${port}",
          executable = {
            command = require("mason-registry").get_package("codelldb"):get_install_path()
              .. "/extension/adapter/codelldb",
            args = { "--port", "${port}" },
          },
          detatched = false,
        }

        dap.adapters["coreclr"] = {
          type = "executable",
          -- command = (vim.fs.find("netcoredbg.exe", { path = vim.fn.stdpath("data") }))[1],
          command = vim.fs.normalize((vim.fs.find("netcoredbg.exe", { path = vim.fn.stdpath("data") }))[1]),
          -- command =  "C:/.local/share/nvim-data/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe",
          -- command = vim.fs.normalize( (vim.fs.find("netcoredbg.exe", { path = require("mason-registry").get_package("netcoredbg") }))[1]),
          --require("mason-registry").get_package("netcoredbg")
          -- options = {
          --   initialize_timeout_sec = 10,
          -- },
          -- detached = false,
          -- command = "C:/.local/share/nvim-data/mason/bin/netcoredbg.cmd",
          args = { "--interpreter=vscode" },
        }
      end,

      python = function(config)
        config.configurations = {
          {
            type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
            request = "launch",
            name = "Python: Launch file",
            program = "${file}", -- This configuration will launch the current file if used.
            -- pythonPath = "/bin/python",
          },
        }
        require("mason-nvim-dap").default_setup(config) -- don't forget this!
      end,
    },
  })
  mason_nvim_dap.setup(o)
end

---@param config {args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.input("Run with args: ", table.concat(args, " ")) --[[@as string]]
    return vim.split(vim.fn.expand(new_args) --[[@as string]], " ")
  end
  return config
end

return {
  "mfussenegger/nvim-dap",

  dependencies = {

    -- fancy UI for the debugger
    {
      "rcarriga/nvim-dap-ui",
      -- stylua: ignore
      keys = {
        { "<leader>du", function() require("dapui").toggle({}) end,  desc = "Dap UI" },
        { "<leader>de", function() require("dapui").eval() end,      desc = "Eval",  mode = { "n", "v" } },
      },
      opts = {},
      config = function(_, opts)
        -- setup dap config by VsCode launch.json file
        -- require("dap.ext.vscode").load_launchjs()
        local dap = require("dap")
        local dapui = require("dapui")
        dapui.setup(opts)
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open({})
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close({})
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close({})
        end
      end,
    },

    -- virtual text for the debugger
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {},
    },

    -- which key integration
    {
      "folke/which-key.nvim",
      optional = true,
      opts = {
        defaults = {
          ["<leader>d"] = { name = "+debug" },
          ["<leader>da"] = { name = "+adapters" },
        },
      },
    },

    -- mason.nvim integration
    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = "mason.nvim",
      cmd = { "DapInstall", "DapUninstall" },
      opts = {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please don't ask me how to install them :)

        -- automatic_setup = true,
        ensure_installed = { "coreclr", "mock", "codelldb" },
      },

      config = dapconfig,
      -- config = require "plugins.configs.mason-nvim-dap",
    },

    {
      "LiadOz/nvim-dap-repl-highlights",
      config = true,
    },

    {
      "Weissle/persistent-breakpoints.nvim",
      opts = {
        load_breakpoints_event = { "BufReadPost" },
      },
    },
  },

  config = function()
    local Config = require("lazyvim.config")
    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

    for name, sign in pairs(Config.icons.dap) do
      sign = type(sign) == "table" and sign or { sign }
      vim.fn.sign_define(
        "Dap" .. name,
        { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
      )
    end
  end,
}
