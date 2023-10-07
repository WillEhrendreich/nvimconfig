local uc = vim.api.nvim_create_user_command
-- local lazyvim = require("lazyvim")
local M = {}

function M.stringContains(str, searchedForString)
  return string.match(str, searchedForString)
end

---tries to get an environment variable's value, and if it's not found or empty returns an empty string
---@param name string
---@return string
function M.getEnvVariableOrEmptyString(name)
  local var = os.getenv(name)
  if var then
    if var == "" then
      return ""
    end
    return var
  end
  return ""
end

function M.hasEnvironmentVariableSet(name)
  local EnvVar = M.getEnvVariableOrEmptyString(name)
  if EnvVar then
    if EnvVar == "" then
      return false
    end
    return true
  end
  return false
end

---tries to get an environment variable's value, and if it's not found or empty returns the default value, or an empty string
---@param name string
---@param defaultValueIfEmpty string
---@return string
function M.getEnvVariableOrDefault(name, defaultValueIfEmpty)
  defaultValueIfEmpty = defaultValueIfEmpty or ""
  local var = M.getEnvVariableOrEmptyString(name)
  if var == "" then
    return defaultValueIfEmpty
  end
  return var
end

function M.hasReposEnvironmentVarSet()
  return M.hasEnvironmentVariableSet("repos")
end

function M.getReposVariableIfSet()
  return M.getEnvVariableOrEmptyString("repos")
end

-- Finds any files or directories given in {names} starting from {path}. If
-- {upward} is "true" then the search traverses upward through parent
-- directories; otherwise, the search traverses downward. Note that downward
-- searches are recursive and may search through many directories! If {stop}
-- is non-nil, then the search stops when the directory given in {stop} is
-- reached. The search terminates when {limit} (default 1) matches are found.
-- The search can be narrowed to find only files or only directories by
-- specifying {type} to be "file" or "directory", respectively.
--
-- Examples:
--
-- -- location of Cargo.toml from the current buffer's path
-- local cargo = vim.fs.find('Cargo.toml', {
--   upward = true,
--   stop = vim.loop.os_homedir(),
--   path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
-- })
--
-- -- list all test directories under the runtime directory
-- local test_dirs = vim.fs.find(
--   {'test', 'tst', 'testdir'},
--   {limit = math.huge, type = 'directory', path = './runtime/'}
-- )
--
-- -- get all files ending with .cpp or .hpp inside lib/
-- local cpp_hpp = vim.fs.find(function(name, path)
--   return name:match('.*%.[ch]pp$') and path:match('[/\\\\]lib$')
-- end, {limit = math.huge, type = 'file'})

function M.getRepoWithName(name)
  if M.hasReposEnvironmentVarSet() then
    return (
      vim.fs.find(name, { upward = false, limit = 1, path = M.getReposVariableIfSet(), type = "directory" })[1] or ""
    )
  else
    return ""
  end
end

function M.hasRepoWithName(name)
  if M.hasReposEnvironmentVarSet() then
    local repoWithName = M.getRepoWithName(name)
    if repoWithName == "" then
      return false
    else
      return true
    end
  else
    return false
  end
end

---tries to get an environment variable's value, and if it's not found or empty returns the default value, or an empty string
---@param name string
---@param defaultValueIfEmpty string
---@return string
function M.getRepoWithNameOrDefault(name, defaultValueIfEmpty)
  defaultValueIfEmpty = defaultValueIfEmpty or ""
  local var = M.getRepoWithName(name)
  if var == "" then
    return defaultValueIfEmpty
  end
  return var
end

-- M.WatchEvent = vim.uv.new_fs_event()
local function on_change(err, fname, status)
  -- Do work...
  vim.api.nvim_command("checktime")
  -- Debounce: stop/start.
  M.WatchEvent:stop()
  Watch_file(fname)
end

function Watch_file(fname)
  local fullpath = vim.api.nvim_call_function("fnamemodify", { fname, ":p" })
  M.WatchEvent:start(
    fullpath,
    {},
    vim.schedule_wrap(function(...)
      on_change(...)
    end)
  )
end
vim.api.nvim_command("command! -nargs=1 Watch call luaeval('Watch_file(_A)', expand('<args>'))")

vim.api.nvim_create_user_command("WatchCurrentFile", function()
  -- local success, fwatch = pcall(require, "fwatch")
  -- if success then
  local path = vim.fn.fnamemodify("%", ":p")
  Watch_file(path)
  --   fwatch.watch(path, {
  --     on_event = function()
  --       -- reload colorscheme whenever path changes
  --       vim.
  --     end,
  --   })
  -- end
end, { desc = "watches current file " })

---@return string
function M.norm(path)
  if path:sub(1, 1) == "~" then
    local home = vim.loop.os_homedir()
    if home then
      if home:sub(-1) == "\\" or home:sub(-1) == "/" then
        home = home:sub(1, -2)
      end
      path = home .. path:sub(2)
    end
  end
  path = path:gsub("\\", "/"):gsub("/+", "/")
  return path:sub(-1) == "/" and path:sub(1, -2) or path
end

function M.file_exists(file)
  return vim.loop.fs_stat(file) ~= nil
end

---@param opts? LazyFloatOptions
function M.float(opts)
  return require("lazy.view.float")(opts)
end

function M.setup(opts)
  -- print("now Setup for NeovimUtils called with opts : \n" .. vim.inspect(opts))
end

---@param msg string|string[]
---@param opts? table
function M.markdown(msg, opts)
  if type(msg) == "table" then
    msg = table.concat(msg, "\n") or msg
  end

  vim.notify(
    msg,
    vim.log.levels.INFO,
    vim.tbl_deep_extend("force", {
      title = "lazy.nvim",
      on_open = function(win)
        vim.wo[win].conceallevel = 3
        vim.wo[win].concealcursor = "n"
        vim.wo[win].spell = false

        vim.treesitter.start(vim.api.nvim_win_get_buf(win), "markdown")
      end,
    }, opts or {})
  )
end

function M.GetVisualSelection(keepSelectionIfNotInBlockMode, advanceCursorOneLine, debugNotify)
  local line_start, column_start
  local line_end, column_end
  -- if debugNotify is true, use vim.notify to show debug info.
  debugNotify = debugNotify or false
  -- keep selection defaults to false, but if true the selection will
  -- be reinstated after it's cleared to set '> and '<
  -- only relevant in visual or visual line mode, block always keeps selection.
  keepSelectionIfNotInBlockMode = keepSelectionIfNotInBlockMode or false
  -- advance cursor one line defaults to true, but is turned off for
  -- visual block mode regardless.
  advanceCursorOneLine = (function()
    if keepSelectionIfNotInBlockMode == true then
      return false
    else
      return advanceCursorOneLine or true
    end
  end)()

  if vim.fn.visualmode() == "\22" then
    line_start, column_start = unpack(vim.fn.getpos("v"), 2)
    line_end, column_end = unpack(vim.fn.getpos("."), 2)
  else
    -- if not in visual block mode then i want to escape to normal mode.
    -- if this isn't done here, then the '< and '> do not get set,
    -- and the selection will only be whatever was LAST selected.
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "x", true)
    line_start, column_start = unpack(vim.fn.getpos("'<"), 2)
    line_end, column_end = unpack(vim.fn.getpos("'>"), 2)
  end
  if column_start > column_end then
    column_start, column_end = column_end, column_start
    if debugNotify == true then
      vim.notify(
        "switching column start and end, \nWas "
          .. column_end
          .. ","
          .. column_start
          .. "\nNow "
          .. column_start
          .. ","
          .. column_end
      )
    end
  end
  if line_start > line_end then
    line_start, line_end = line_end, line_start
    if debugNotify == true then
      vim.notify(
        "switching line start and end, \nWas "
          .. line_end
          .. ","
          .. line_start
          .. "\nNow "
          .. line_start
          .. ","
          .. line_end
      )
    end
  end
  if vim.g.selection == "exclusive" then
    column_end = column_end - 1 -- Needed to remove the last character to make it match the visual selection
  end
  if debugNotify == true then
    vim.notify(
      "vim.fn.visualmode(): "
        .. vim.fn.visualmode()
        .. "\nsel start "
        .. vim.inspect(line_start)
        .. " "
        .. vim.inspect(column_start)
        .. "\nSel end "
        .. vim.inspect(line_end)
        .. " "
        .. vim.inspect(column_end)
    )
  end
  local n_lines = math.abs(line_end - line_start) + 1
  local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
  if #lines == 0 then
    return { "" }
  end
  if vim.fn.visualmode() == "\22" then
    -- this is what actually sets the lines to only what is found between start and end columns
    for i = 1, #lines do
      lines[i] = string.sub(lines[i], column_start, column_end)
    end
  else
    lines[1] = string.sub(lines[1], column_start, -1)
    if n_lines == 1 then
      lines[n_lines] = string.sub(lines[n_lines], 1, column_end - column_start + 1)
    else
      lines[n_lines] = string.sub(lines[n_lines], 1, column_end)
    end
    -- if advanceCursorOneLine == true, then i do want the cursor to advance once.
    if advanceCursorOneLine == true then
      if debugNotify == true then
        vim.notify("advancing cursor one line past the end of the selection to line " .. vim.inspect(line_end + 1))
      end
      vim.api.nvim_win_set_cursor(0, { line_end + 1, 0 })
    end

    if keepSelectionIfNotInBlockMode then
      vim.api.nvim_feedkeys("gv", "n", true)
    end
  end
  if debugNotify == true then
    vim.notify(table.concat(lines, "\n"))
  end
  return lines -- use this return if you want an array of text lines
  -- return table.concat(lines, "\n") -- use this return instead if you need a text block
end
uc("Scratch", function(arg)
  M.scratch(arg)
  --local M = {}
end, {})

---this is a test to see about structure and calling things
---@param s string
---@return string
function M.StringAppendWithBLAH(s)
  local result = s .. "BLAH"
  return result
end

--- Merge extended options with a default table of options
-- @param default the default table that you want to merge into
-- @param opts the new options that should be merged with the default table
-- @return the merged table
function M.extend_tbl(default, opts)
  opts = opts or {}
  return default and vim.tbl_deep_extend("force", default, opts) or opts
end

--- Call function if a condition is met
-- @param func the function to run
-- @param condition a boolean value of whether to run the function or not
function M.conditional_func(func, condition, ...)
  -- if the condition is true or no condition is provided, evaluate the function with the rest of the parameters and return the result
  if condition and type(func) == "function" then
    return func(...)
  end
end

--- Open a URL under the cursor with the current operating system
-- @param path the path of the file to open with the system opener
function M.system_open(path)
  local cmd
  if vim.fn.has("win32") == 1 and vim.fn.executable("explorer") == 1 then
    cmd = "explorer"
  elseif vim.fn.has("unix") == 1 and vim.fn.executable("xdg-open") == 1 then
    cmd = "xdg-open"
  elseif (vim.fn.has("mac") == 1 or vim.fn.has("unix") == 1) and vim.fn.executable("open") == 1 then
    cmd = "open"
  end
  if not cmd then
    M.notify("Available system opening tool not found!", "error")
  end
  if require("lazy.util").has("open-browser.vim") then
    -- require("openbrowser-smart-search")
    vim.cmd.OpenBrowserSmartSearch(path)
  else
    vim.fn.jobstart({ cmd, path or vim.fn.expand("<cfile>") }, { detach = true })
  end
end

function M.open(uri)
  if M.file_exists(uri) then
    return M.float({ style = "", file = uri })
  end
  local Config = require("lazy.core.config")
  local cmd
  if Config.options.ui.browser then
    cmd = { Config.options.ui.browser, uri }
  elseif vim.fn.has("win32") == 1 then
    cmd = { "explorer", uri }
  elseif vim.fn.has("macunix") == 1 then
    cmd = { "open", uri }
  else
    if vim.fn.executable("xdg-open") == 1 then
      cmd = { "xdg-open", uri }
    elseif vim.fn.executable("wslview") == 1 then
      cmd = { "wslview", uri }
    else
      cmd = { "open", uri }
    end
  end

  local ret = vim.fn.jobstart(cmd, { detach = true })
  if ret <= 0 then
    local msg = {
      "Failed to open uri",
      ret,
      vim.inspect(cmd),
    }
    vim.notify(table.concat(msg, "\n"), vim.log.levels.ERROR)
  end
end

uc("SystemOpen", function()
  M.open(vim.fn.expand("<cfile>"))
  -- M.system_open(vim.fn.expand("<cfile>"))
end, {})

-- term_details can be either a string for just a command or
-- a complete table to provide full access to configuration when calling Terminal:new()

--- Toggle a user terminal if it exists, if not then create a new one and save it
-- @param term_details a terminal command string or a table of options for Terminal:new() (Check toggleterm.nvim documentation for table format)
function M.toggle_term_cmd(opts)
  local terms = {}
  -- if a command string is provided, create a basic table for Terminal:new() options
  if type(opts) == "string" then
    opts = { cmd = opts, hidden = true }
  end
  local num = vim.v.count > 0 and vim.v.count or 1
  -- if terminal doesn't exist yet, create it
  if not terms[opts.cmd] then
    terms[opts.cmd] = {}
  end
  if not terms[opts.cmd][num] then
    if not opts.count then
      opts.count = vim.tbl_count(terms) * 100 + num
    end
    if not opts.on_exit then
      opts.on_exit = function()
        terms[opts.cmd][num] = nil
      end
    end
    terms[opts.cmd][num] = require("toggleterm.terminal").Terminal:new(opts)
  end
  -- toggle the terminal
  terms[opts.cmd][num]:toggle()
end

--- regex used for matching a valid URL/URI string
local url_matcher =
  "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

--- Delete the syntax matching rules for URLs/URIs if set
function M.delete_url_match()
  for _, match in ipairs(vim.fn.getmatches()) do
    if match.group == "HighlightURL" then
      vim.fn.matchdelete(match.id)
    end
  end
end

function M.read_file(file)
  local fd = assert(io.open(file, "r"))
  ---@type string
  local data = fd:read("*a")
  fd:close()
  return data
end

function M.write_file(file, contents)
  local fd = assert(io.open(file, "w+"))
  fd:write(contents)
  fd:close()
end

---@generic F: fun()
---@param ms number
---@param fn F
---@return F
function M.throttle(ms, fn)
  local timer = vim.loop.new_timer()
  local running = false
  local first = true

  return function(...)
    local args = { ... }
    local wrapped = function()
      fn(unpack(args))
    end
    if not running then
      if first then
        wrapped()
        first = false
      end

      timer:start(ms, 0, function()
        running = false
        vim.schedule(wrapped)
      end)

      running = true
    end
  end
end

---@class LazyCmdOptions: LazyFloatOptions
---@field cwd? string
---@field env? table<string,string>
---@field float? LazyFloatOptions

-- Opens a floating terminal (interactive by default)
---@param cmd? string[]|string
---@param opts? LazyCmdOptions|{interactive?:boolean}
function M.float_term(cmd, opts)
  cmd = cmd or {}
  if type(cmd) == "string" then
    cmd = { cmd }
  end
  if #cmd == 0 then
    cmd = { vim.env.SHELL or vim.o.shell }
  end
  opts = opts or {}
  local float = M.float(opts)
  vim.fn.termopen(cmd, vim.tbl_isempty(opts) and vim.empty_dict() or opts)
  if opts.interactive ~= false then
    vim.cmd.startinsert()
    vim.api.nvim_create_autocmd("TermClose", {
      once = true,
      buffer = float.buf,
      callback = function()
        float:close()
        vim.cmd.checktime()
      end,
    })
  end
  return float
end

--- Runs the command and shows it in a floating window
---@param cmd string[]
---@param opts? LazyCmdOptions|{filetype?:string}
function M.float_cmd(cmd, opts)
  opts = opts or {}
  local float = M.float(opts)
  if opts.filetype then
    vim.bo[float.buf].filetype = opts.filetype
  end
  local Process = require("lazy.manage.process")
  local lines = Process.exec(cmd, { cwd = opts.cwd })
  vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, lines)
  vim.bo[float.buf].modifiable = false
  return float
end

---@alias FileType "file"|"directory"|"link"
---@param path string
---@param fn fun(path: string, name:string, type:FileType):boolean?
function M.ls(path, fn)
  local handle = vim.loop.fs_scandir(path)
  while handle do
    local name, t = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end

    local fname = path .. "/" .. name

    -- HACK: type is not always returned due to a bug in luv,
    -- so fecth it with fs_stat instead when needed.
    -- see https://github.com/folke/lazy.nvim/issues/306
    if fn(fname, name, t or vim.loop.fs_stat(fname).type) == false then
      break
    end
  end
end

---@param path string
---@param fn fun(path: string, name:string, type:FileType)
function M.walk(path, fn)
  M.ls(path, function(child, name, type)
    if type == "directory" then
      M.walk(child, fn)
    end
    fn(child, name, type)
  end)
end

---@param root string
---@param fn fun(modname:string, modpath:string)
---@param modname? string
function M.walkmods(root, fn, modname)
  modname = modname and (modname:gsub("%.$", "") .. ".") or ""
  M.ls(root, function(path, name, type)
    if name == "init.lua" then
      fn(modname:gsub("%.$", ""), path)
    elseif (type == "file" or type == "link") and name:sub(-4) == ".lua" then
      fn(modname .. name:sub(1, -5), path)
    elseif type == "directory" then
      M.walkmods(path, fn, modname .. name .. ".")
    end
  end)
end

---@generic V
---@param t table<string, V>
---@param fn fun(key:string, value:V)
function M.foreach(t, fn)
  ---@type string[]
  local keys = vim.tbl_keys(t)
  pcall(table.sort, keys, function(a, b)
    return a:lower() < b:lower()
  end)
  for _, key in ipairs(keys) do
    fn(key, t[key])
  end
end

--- Add syntax matching rules for highlighting URLs/URIs
function M.set_url_match()
  M.delete_url_match()
  if vim.g.highlighturl_enabled then
    vim.fn.matchadd("HighlightURL", url_matcher, 15)
  end
end

--- Run a shell command and capture the output and if the command succeeded or failed
-- @param cmd the terminal command to execute
-- @param show_error boolean of whether or not to show an unsuccessful command as an error to the user
-- @return the result of a successfully executed command or nil
function M.cmd(cmd, show_error)
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

---@generic F: fun()
---@param ms number
---@param fn F
---@return F
function M.throttle(ms, fn)
  local timer = vim.loop.new_timer()
  local running = false
  local first = true

  return function(...)
    local args = { ... }
    local wrapped = function()
      fn(unpack(args))
    end
    if not running then
      if first then
        wrapped()
        first = false
      end

      timer:start(ms, 0, function()
        running = false
        vim.schedule(wrapped)
      end)

      running = true
    end
  end
end

function M._dump(value, result)
  local t = type(value)
  if t == "number" or t == "boolean" then
    table.insert(result, tostring(value))
  elseif t == "string" then
    table.insert(result, ("%q"):format(value))
  elseif t == "table" then
    table.insert(result, "{")
    local i = 1
    ---@diagnostic disable-next-line: no-unknown
    for k, v in pairs(value) do
      if k == i then
      elseif type(k) == "string" then
        table.insert(result, ("[%q]="):format(k))
      else
        table.insert(result, k .. "=")
      end
      M._dump(v, result)
      table.insert(result, ",")
      i = i + 1
    end
    table.insert(result, "}")
  else
    error("Unsupported type " .. t)
  end
end
-- For pretty printing lua objects (`:lua dump(vim.fn)`)
M.dump = function(...)
  -- local objects = vim.tbl_map(vim.inspect, { ... })
  local result = {}
  M.foreach(..., function(val)
    M._dump(val, result)
    -- table.concat(result, "")
    -- print(unpack(objects))
  end)
  print(unpack(result))
  return ...
end

---@param opts? {finally:fun()}
function M.try(fn, opts)
  opts = opts or {}
  local ok, err = pcall(fn)

  if opts.finally then
    pcall(opts.finally)
  end

  if not ok then
    M.error(err)
  end
end

function M.notify(msg, level)
  vim.notify(msg, level, { title = "edgy.nvim" })
end

function M.error(msg)
  M.notify(msg, vim.log.levels.ERROR)
end

function M.warn(msg)
  M.notify(msg, vim.log.levels.WARN)
end

function M.info(msg)
  M.notify(msg, vim.log.levels.INFO)
end

function M.debug(msg)
  if require("edgy.config").debug then
    M.info(msg)
  end
end

---@generic F: fun()
---@param fn F
---@param max_retries? number
---@return F
function M.with_retry(fn, max_retries)
  max_retries = max_retries or 3
  local retries = 0
  local function try()
    local ok, ret = pcall(fn)
    if ok then
      retries = 0
    else
      if retries >= max_retries or require("edgy.config").debug then
        M.error(ret)
      end
      if retries < max_retries then
        return vim.schedule(try)
      end
    end
  end
  return try
end

---@generic F: fun()
---@param fn F
---@return F
function M.noautocmd(fn)
  return function(...)
    vim.o.eventignore = "all"
    local ok, ret = pcall(fn, ...)
    vim.o.eventignore = ""
    if not ok then
      error(ret)
    end
    return ret
  end
end

--- @generic F: function
--- @param fn F
--- @param ms? number
--- @return F
function M.throttle(fn, ms)
  ms = ms or 200
  local timer = assert(vim.loop.new_timer())
  local waiting = 0
  return function()
    if timer:is_active() then
      waiting = waiting + 1
      return
    end
    waiting = 0
    fn() -- first call, execute immediately
    timer:start(ms, 0, function()
      if waiting > 1 then
        vim.schedule(fn) -- only execute if there are calls waiting
      end
    end)
  end
end

--- @generic F: function
--- @param fn F
--- @param ms? number
--- @return F
function M.debounce(fn, ms)
  ms = ms or 50
  local timer = assert(vim.loop.new_timer())
  local waiting = 0
  return function()
    if timer:is_active() then
      waiting = waiting + 1
    else
      waiting = 0
      fn()
    end
    timer:start(ms, 0, function()
      if waiting then
        vim.schedule(fn) -- only execute if there are calls waiting
      end
    end)
  end
end

return M
