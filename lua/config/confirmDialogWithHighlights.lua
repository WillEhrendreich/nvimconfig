-- local config = require("overseer.config")
-- local M = {} like a

local uc = vim.api.nvim_create_user_command

local default_config = {
  -- Default task strategy
  strategy = "terminal",
  -- Template modules to load
  templates = { "builtin" },
  -- When true, tries to detect a green color from your colorscheme to use for success highlight
  auto_detect_success_color = true,
  -- Patch nvim-dap to support preLaunchTask and postDebugTask
  dap = true,
  -- Configure the task list
  task_list = {
    -- Default detail level for tasks. Can be 1-3.
    default_detail = 1,
    -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_width and max_width can be a single value or a list of mixed integer/float types.
    -- max_width = {100, 0.2} means "the lesser of 100 columns or 20% of total"
    max_width = { 100, 0.2 },
    -- min_width = {40, 0.1} means "the greater of 40 columns or 10% of total"
    min_width = { 40, 0.1 },
    -- optionally define an integer/float for the exact width of the task list
    width = nil,
    max_height = { 20, 0.1 },
    min_height = 8,
    height = nil,
    -- String that separates tasks
    separator = "────────────────────────────────────────",
    -- Default direction. Can be "left", "right", or "bottom"
    direction = "left",
    -- Set keymap to false to remove default behavior
    -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
    bindings = {
      ["?"] = "ShowHelp",
      ["g?"] = "ShowHelp",
      ["<CR>"] = "RunAction",
      ["<C-e>"] = "Edit",
      ["o"] = "Open",
      ["<C-v>"] = "OpenVsplit",
      ["<C-s>"] = "OpenSplit",
      ["<C-f>"] = "OpenFloat",
      ["<C-q>"] = "OpenQuickFix",
      ["p"] = "TogglePreview",
      ["<C-l>"] = "IncreaseDetail",
      ["<C-h>"] = "DecreaseDetail",
      ["L"] = "IncreaseAllDetail",
      ["H"] = "DecreaseAllDetail",
      ["["] = "DecreaseWidth",
      ["]"] = "IncreaseWidth",
      ["{"] = "PrevTask",
      ["}"] = "NextTask",
      ["<C-k>"] = "ScrollOutputUp",
      ["<C-j>"] = "ScrollOutputDown",
      ["q"] = "Close",
    },
  },
  -- See :help overseer-actions
  actions = {},
  -- Configure the floating window used for task templates that require input
  -- and the floating window used for editing tasks
  form = {
    border = "rounded",
    zindex = 40,
    -- Dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_X and max_X can be a single value or a list of mixed integer/float types.
    min_width = 80,
    max_width = 0.9,
    width = nil,
    min_height = 10,
    max_height = 0.9,
    height = nil,
    -- Set any window options here (e.g. winhighlight)
    win_opts = {
      winblend = 10,
    },
  },
  task_launcher = {
    -- Set keymap to false to remove default behavior
    -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
    bindings = {
      i = {
        ["<C-s>"] = "Submit",
        ["<C-c>"] = "Cancel",
      },
      n = {
        ["<CR>"] = "Submit",
        ["<C-s>"] = "Submit",
        ["q"] = "Cancel",
        ["?"] = "ShowHelp",
      },
    },
  },
  task_editor = {
    -- Set keymap to false to remove default behavior
    -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
    bindings = {
      i = {
        ["<CR>"] = "NextOrSubmit",
        ["<C-s>"] = "Submit",
        ["<Tab>"] = "Next",
        ["<S-Tab>"] = "Prev",
        ["<C-c>"] = "Cancel",
      },
      n = {
        ["<CR>"] = "NextOrSubmit",
        ["<C-s>"] = "Submit",
        ["<Tab>"] = "Next",
        ["<S-Tab>"] = "Prev",
        ["q"] = "Cancel",
        ["?"] = "ShowHelp",
      },
    },
  },
  -- Configure the floating window used for confirmation prompts
  confirm = {
    border = "rounded",
    zindex = 40,
    -- Dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_X and max_X can be a single value or a list of mixed integer/float types.
    min_width = 20,
    max_width = 0.9,
    width = nil,
    min_height = 6,
    max_height = 0.9,
    height = nil,
    -- Set any window options here (e.g. winhighlight)
    win_opts = {

      wrap = true,
      winblend = 0,
    },
  },
  -- Configuration for task floating windows
  task_win = {
    -- How much space to leave around the floating window
    padding = 2,
    border = "rounded",
    -- Set any window options here (e.g. winhighlight)
    win_opts = {
      winblend = 10,
    },
  },
  -- Configuration for mapping help floating windows
  help_win = {
    border = "rounded",
    win_opts = {},
  },
  -- Aliases for bundles of components. Redefine the builtins, or create your own.
  component_aliases = {
    -- Most tasks are initialized with the default components
    default = {
      { "display_duration", detail_level = 2 },
      "on_output_summarize",
      "on_exit_set_status",
      "on_complete_notify",
      "on_complete_dispose",
    },
    -- Tasks from tasks.json use these components
    default_vscode = {
      "default",
      "on_result_diagnostics",
      "on_result_diagnostics_quickfix",
    },
  },
  bundles = {
    -- When saving a bundle with OverseerSaveBundle or save_task_bundle(), filter the tasks with
    -- these options (passed to list_tasks())
    save_task_opts = {
      bundleable = true,
    },
  },
  -- A list of components to preload on setup.
  -- Only matters if you want them to show up in the task editor.
  preload_components = {},
  -- Controls when the parameter prompt is shown when running a template
  --   always    Show when template has any params
  --   missing   Show when template has any params not explicitly passed in
  --   allow     Only show when a required param is missing
  --   avoid     Only show when a required param with no default value is missing
  --   never     Never show prompt (error if required param missing)
  default_template_prompt = "allow",
  -- For template providers, how long to wait (in ms) before timing out.
  -- Set to 0 to disable timeouts.
  template_timeout = 3000,
  -- Cache template provider results if the provider takes longer than this to run.
  -- Time is in ms. Set to 0 to disable caching.
  template_cache_threshold = 100,
  -- Configure where the logs go and what level to use
  -- Types are "echo", "notify", and "file"
  log = {
    {
      type = "echo",
      level = vim.log.levels.WARN,
    },
    {
      type = "file",
      filename = "overseer.log",
      level = vim.log.levels.WARN,
    },
  },
}

local M = vim.deepcopy(default_config)

local function merge_actions(default_actions, user_actions)
  local actions = {}
  for k, v in pairs(default_actions) do
    actions[k] = v
  end
  for k, v in pairs(user_actions or {}) do
    if not v then
      actions[k] = nil
    else
      actions[k] = v
    end
  end
  return actions
end

---If user creates a mapping for an action, remove the default mapping to that action
---(unless they explicitly specify that key as well)
---@param user_conf overseer.Config
local function remove_binding_conflicts(user_conf)
  for key, configval in pairs(user_conf) do
    if type(configval) == "table" and configval.bindings then
      local orig_bindings = default_config[key].bindings
      local rev = {}
      -- Make a reverse lookup of shortcut-to-key
      -- e.g. ["Open"] = "o"
      for k, v in pairs(orig_bindings) do
        rev[v] = k
      end
      for k, v in pairs(configval.bindings) do
        -- If the user is choosing to map a command to a different key, remove the original default
        -- map (e.g. if {"u" = "Open"}, then set {"o" = false})
        if rev[v] and rev[v] ~= k and not configval.bindings[rev[v]] then
          configval.bindings[rev[v]] = false
        end
      end
    end
  end
end

---@param opts? overseer.Config
M.setup = function(opts)
  local component = require("overseer.component")
  local log = require("overseer.log")
  opts = opts or {}
  remove_binding_conflicts(opts)
  local newconf = vim.tbl_deep_extend("force", default_config, opts)
  for k, v in pairs(newconf) do
    M[k] = v
  end

  log.set_root(log.new({ handlers = M.log }))

  M.actions = merge_actions(require("overseer.task_list.actions"), newconf.actions)

  for k, v in pairs(M.component_aliases) do
    component.alias(k, v)
  end
end

-- return M
local function is_float(value)
  local _, p = math.modf(value)
  return p ~= 0
end

local function calc_float(value, max_value)
  if value and is_float(value) then
    return math.min(max_value, value * max_value)
  else
    return value
  end
end

M.get_editor_width = function()
  return vim.o.columns
end

M.get_editor_height = function()
  local editor_height = vim.o.lines - vim.o.cmdheight
  -- Subtract 1 if tabline is visible
  if vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1) then
    editor_height = editor_height - 1
  end
  -- Subtract 1 if statusline is visible
  if vim.o.laststatus >= 2 or (vim.o.laststatus == 1 and #vim.api.nvim_tabpage_list_wins(0) > 1) then
    editor_height = editor_height - 1
  end
  return editor_height
end

local function calc_list(values, max_value, aggregator, limit)
  local ret = limit
  if not max_value or not values then
    return nil
  elseif type(values) == "table" then
    for _, v in ipairs(values) do
      ret = aggregator(ret, calc_float(v, max_value))
    end
    return ret
  else
    ret = aggregator(ret, calc_float(values, max_value))
  end
  return ret
end

local function calculate_dim(desired_size, exact_size, min_size, max_size, total_size)
  local ret = calc_float(exact_size, total_size)
  local min_val = calc_list(min_size, total_size, math.max, 1)
  local max_val = calc_list(max_size, total_size, math.min, total_size)
  if not ret then
    if not desired_size then
      if min_val and max_val then
        ret = (min_val + max_val) / 2
      else
        ret = 80
      end
    else
      ret = calc_float(desired_size, total_size)
    end
  end
  if max_val then
    ret = math.min(ret, max_val)
  end
  if min_val then
    ret = math.max(ret, min_val)
  end
  return math.floor(ret)
end

M.calculate_width = function(desired_width, opts)
  return calculate_dim(desired_width, opts.width, opts.min_width, opts.max_width, M.get_editor_width())
end

M.calculate_height = function(desired_height, opts)
  return calculate_dim(desired_height, opts.height, opts.min_height, opts.max_height, M.get_editor_height())
end

---@param bufnr integer
---@return integer
M.open_fullscreen_float = function(bufnr)
  local conf = M.task_win
  local width = M.get_editor_width() - 2 - 2 * conf.padding
  local height = M.get_editor_height() - 2 * conf.padding
  local row = conf.padding
  local col = conf.padding
  local winid = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    border = conf.border,
    zindex = conf.zindex,
    style = "minimal",
  })
  for k, v in pairs(conf.win_opts) do
    vim.api.nvim_set_option_value(k, v, { scope = "local", win = winid })
  end
  vim.api.nvim_create_autocmd("WinLeave", {
    desc = "Close float on WinLeave",
    once = true,
    nested = true,
    callback = function()
      pcall(vim.api.nvim_win_close, winid, true)
    end,
  })
  return winid
end

-- local config = require("overseer.config")
-- local layout = require("overseer.layout")

function M.DisplayConfirmDialog(opts, callback)
  vim.validate({
    message = { opts.message, "s" },
    choices = { opts.choices, "t", true },
    default = { opts.default, "n", true },
    type = { opts.type, "s", true },
    callback = { callback, "f" },
  })
  if not opts.choices then
    opts.choices = { "&OK" }
  end
  if not opts.default then
    opts.default = 1
  end
  -- TODO this doesn't do anything yet
  if not opts.type then
    opts.type = "G"
  else
    opts.type = string.sub(opts.type, 1, 1)
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "buflisted", false)
  vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
  local winid

  local function choose(idx)
    local cb = callback
    callback = function(_) end
    if winid then
      vim.api.nvim_win_close(winid, true)
    end
    cb(idx)
  end
  local function cancel()
    choose(0)
  end

  local clean_choices = {}
  local choice_shortcut_idx = {}
  for i, choice in ipairs(opts.choices) do
    local idx = choice:find("&")
    local key
    if idx and idx < string.len(choice) then
      table.insert(clean_choices, choice:sub(1, idx - 1) .. choice:sub(idx + 1))
      key = choice:sub(idx + 1, idx + 1)
      table.insert(choice_shortcut_idx, idx)
    else
      key = choice:sub(1, 1)
      table.insert(clean_choices, choice)
      table.insert(choice_shortcut_idx, 1)
    end
    vim.keymap.set("n", key:lower(), function()
      choose(i)
    end, { buffer = bufnr })
    vim.keymap.set("n", key:upper(), function()
      choose(i)
    end, { buffer = bufnr })
  end
  vim.keymap.set("n", "<C-c>", cancel, { buffer = bufnr })
  vim.keymap.set("n", "<Esc>", cancel, { buffer = bufnr })

  local lines = vim.split(opts.message, "\n")
  local highlights = {}
  table.insert(lines, "")

  -- Calculate the width of the choices if they are on a single line
  local choices_width = 0
  for _, choice in ipairs(clean_choices) do
    choices_width = choices_width + vim.api.nvim_strwidth(choice)
  end
  -- Make sure to account for spacing
  choices_width = choices_width + #clean_choices - 1

  local desired_width = choices_width
  for _, line in ipairs(lines) do
    local len = string.len(line)
    if len > desired_width then
      desired_width = len
    end
  end

  local width = M.calculate_width(desired_width, M.confirm)

  if width < choices_width then
    -- Render one choice per line
    for i, choice in ipairs(clean_choices) do
      table.insert(lines, choice)
      table.insert(highlights, { "Keyword", #lines, choice_shortcut_idx[i] - 1 })
    end
  else
    -- Render all choices on a single line
    local extra_spacing = width - choices_width
    local line = ""
    local num_dividers = #clean_choices - 1
    for i, choice in ipairs(clean_choices) do
      if i > 1 then
        line = line .. " " .. string.rep(" ", math.floor(extra_spacing / num_dividers))
        if extra_spacing % num_dividers >= i then
          line = line .. " "
        end
      end
      local col_start = line:len() - 1
      line = line .. choice
      table.insert(highlights, { "Keyword", #lines + 1, col_start + choice_shortcut_idx[i] })
    end
    table.insert(lines, line)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
  local ns = vim.api.nvim_create_namespace("confirm")
  for _, hl in ipairs(highlights) do
    local group, lnum, col_start, col_end = unpack(hl)
    if not col_end then
      col_end = col_start + 1
    end
    vim.hl.range(bufnr, ns, group, lnum - 1, col_start, col_end)
  end

  local height = M.calculate_height(#lines, M.confirm)
  winid = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    border = M.confirm.border,
    zindex = M.confirm.zindex,
    style = "minimal",
    title = "Confirm Dialog",
    title_pos = "center",
    -- style = "rounded",
    width = width,
    height = height,
    col = math.floor((M.get_editor_width() - width) / 2),
    row = math.floor((M.get_editor_height() - height) / 2),
  })
  for k, v in pairs(M.confirm.win_opts) do
    vim.api.nvim_set_option_value(k, v, { scope = "local", win = winid })
  end

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = bufnr,
    callback = cancel,
    once = true,
    nested = true,
  })
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

function M.CreateSampleConfirm()
  local opts = {
    choices = {
      "Choice 1, which is of course the bestest choice",
      "&Second Choice, not as good, but most certainly not the worst.",
      "Fascinating &Third Choice. as in.. I'm fascinated by how bad you are at choosing. for SHAME.",
    },
    default = 1,
    message = "this is a sample to see how this Works. ",
    type = "G",
  }
  M.DisplayConfirmDialog(opts, function(choice)
    vim.notify(vim.inspect(choice or "No Choice given, something went wrong"))
  end)
end

uc("SampleConfirm", M.CreateSampleConfirm, { desc = "Create a sample confirm dialog" })

return M
