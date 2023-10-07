-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local LazyVimUtil = require("lazyvim.util")
local lazyutil = require("lazy.util")

local function map(mode, lhs, rhs, opts)
  if type(opts) == "string" then
    opts = { desc = opts }
  end
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end
-- within config/keymaps.lua
vim.api.nvim_del_keymap("n", "<leader>ww")
vim.api.nvim_del_keymap("n", "<leader>wd")
vim.api.nvim_del_keymap("n", "<leader>w-")
vim.api.nvim_del_keymap("n", "<leader>w|")

map("n", "<C-ScrollWheelUp>", ":set guifont=+<CR>", "Font Size +")
map("n", "<C-ScrollWheelDown>", ":set guifont=-<CR>", "Font Size -")
map("n", "<leader>o", "<cmd>Neotree toggle<cr>", "Neotree Toggle")

if LazyVimUtil.has("NeoComposer.nvim") then
  map("n", "<leader>me", function()
    require("NeoComposer.ui").edit_macros()
  end, "Edit Macros")
  map("n", "<leader>md", function()
    require("NeoComposer.store").clear_macros()
  end, "Clear Macros from NeoComposer")

  -- play_macro = "Q",
  map({ "n", "x" }, "<leader>Q", function()
    require("NeoComposer.macro").toggle_play_macro()
  end, "Toggle Play Macro")
  -- yank_macro = "yq",
  map("n", "yq", function()
    require("NeoComposer.macro").yank_macro()
  end, "Yank Macro")
  -- toggle_record = "q",
  map("n", "q", function()
    require("NeoComposer.macro").toggle_record()
  end, "Toggle record Macro")
  map("n", "<leader>md", function()
    require("NeoComposer.macro").toggle_delay()
  end, "Toggle delay of macro execution")
  map("n", "<leader>mm", function()
    require("NeoComposer.ui").toggle_macro_menu()
  end, "Toggle Macro Menu")
  map("n", "<leader>mn", function()
    require("NeoComposer.ui").cycle_next()
  end, "Cycle next Macro")
  map("n", "<leader>mp", function()
    require("NeoComposer.ui").cycle_prev()
  end, "Cycle previous Macro")
  map("n", "<leader>mh", function()
    require("NeoComposer.macro").halt_macro()
  end, "Halt Macro")
end

map({ "n" }, "gx", function()
  local currentWord = vim.fn.expand("<cWORD>")
  if currentWord then
    -- if not string.match(currentWord, "") then
    vim.notify("trying to open " .. currentWord)
    lazyutil.open(currentWord)
    -- end
  end
end, "open WORD under cursor")

map({ "v" }, "gx", function()
  local currentWord = require("config.util").GetVisualSelection(true, false, false)[1]
  if currentWord then
    -- if not string.match(currentWord, "") then
    vim.notify("trying to open " .. currentWord)
    lazyutil.open(currentWord)
    -- end
  end
end, "open selection if possible")

map("n", "<leader>/", 'v:lua.MiniComment.operator() . "_"', { expr = true, desc = "Comment line" })
map(
  "x",
  "<leader>/",
  -- Using `:<c-u>` instead of `<cmd>` as latter results into executing before
  -- proper update of `'<` and `'>` marks which is needed to work correctly.
  [[:<c-u>lua MiniComment.operator('visual')<cr>]],
  { desc = "Comment selection" }
)
map("o", "<leader>/", "<cmd>lua MiniComment.textobject()<cr>", { desc = "Comment textobject" })

map({ "v", "x" }, "<M-CR>", function()
  local lua_ls = vim.lsp.get_active_clients({ name = "lua_ls" })[1]
  if lua_ls then
    local text = vim.fn.join(require("config.util").GetVisualSelection(), "\n")
    require("luadev").exec(text)
  end
end, "Send Lines to Repl")

map("n", "<M-CR>", function()
  local lua_ls = vim.lsp.get_active_clients({ name = "lua_ls" })[1]
  if lua_ls then
    -- vim.notify("ive got lua ls as a client ")
    -- local b = vim.api.nvim_buf_get_name(0)
    -- if not root_dir then
    -- 	root_dir = util.path.dirname(api.nvim_buf_get_name(0)) or ""
    -- end
    -- if not root_dir or root_dir == "" then
    -- 	root_dir = vim.fn.getcwd()
    -- end
    -- root_dir = string.gsub(root_dir, "\\", "
    -- vim.notify(b)
    -- local luaDev = (function()
    --   if string.find(b, "[" .. "nvim" .. "-" .. "lua" .. "]", 0, true) then
    --     return true
    --   else
    --     return false
    --   end
    -- end)()
    -- vim.notify(vim.inspect(luaDev))

    -- if luaDev then
    require("luadev").exec(vim.api.nvim_get_current_line())
    -- require("luadev").exec()
    -- vim.notify("luadev here too ")
    -- end
  end
  local ionide = vim.lsp.get_active_clients({ name = "ionide" })[1]
  if ionide then
    vim.notify("ive got ionide  as a client ")
  end
end, "Send to Repl")

local function GetVisualStartAndEndLineNumbers(keepSelectionIfNotInBlockMode, advanceCursorOneLine, debugNotify)
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
  -- local n_lines = math.abs(line_end - line_start) + 1
  -- local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
  -- if #lines == 0 then
  --   return { "" }
  -- end
  if vim.fn.visualmode() == "\22" then
    --   -- this is what actually sets the lines to only what is found between start and end columns
    --   for i = 1, #lines do
    --     lines[i] = string.sub(lines[i], column_start, column_end)
    --   end
    -- else
    --   lines[1] = string.sub(lines[1], column_start, -1)
    --   if n_lines == 1 then
    --     lines[n_lines] = string.sub(lines[n_lines], 1, column_end - column_start + 1)
    --   else
    --     lines[n_lines] = string.sub(lines[n_lines], 1, column_end)
    --   end
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

  -- if debugNotify == true then
  --   vim.notify(table.concat(lines, "\n"))
  -- end

  return line_start, line_end -- use this return if you want an array of text lines
  -- return table.concat(lines, "\n") -- use this return instead if you need a text block
end

map("x", "<leader>/", function()
  -- local pos = unpack(vim.fn.getpos(">"), 2)
  -- local mc = require("mini.comment").MiniComment
  local s, e = GetVisualStartAndEndLineNumbers(false, true, false)
  if LazyVimUtil.has("mini.comment") then
    -- local mc = require("mini.comment")
    MiniComment.toggle_lines(s, e)
  else
    vim.notify("no mini.comment found, please install it or change this mapping to point to something else")
  end
end)

-- fold
map("n", "zz", "za", { desc = "Toggle Fold Under Cursor" })

map("n", "<K>", function()
  if vim.bo.filetype == "help" then
    vim.api.nvim_feedkeys("K", "ni", true)
    return
  else
    if require("lazyvim.util").has("hover.nvim") then
      require("hover").hover()
    else
      vim.lsp.buf.hover()
    end
  end
end, "Hover")

-- map("n", "<leader>c", "", { desc = "Code" })
-- map("n", "<leader>cm", , { desc = "Code" })
map("n", "<leader>l", "", { desc = "LSP" })
-- save file
map({ "i" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map({ "n", "v", "s" }, "<leader>w", "<cmd>w<cr><esc>", { desc = "Save file" })

map("n", "<leader>pi", function()
  require("lazy").install()
end, "Plugins Install")

map("n", "<leader>pcua", function()
  local chocoCmd = { "choco", "upgrade", "all" }
  require("config.util").float_term(chocoCmd, {
    style = "",
    title = "Choco Packages upgrade all",
  })
end, "Choco Packages upgrade all")

---@class LazyFloatOptions
---@field buf? number
---@field file? string
---@field margin? {top?:number, right?:number, bottom?:number, left?:number}
---@field size? {width:number, height:number}
---@field zindex? number
---@field style? "" | "minimal"
---@field border? "none" | "single" | "double" | "rounded" | "solid" | "shadow"
---@field title? string
---@field title_pos? "center" | "left" | "right"
---@field persistent? boolean
---@field ft? string
---@field noautocmd? boolean

---@class LazyFloat
---@field buf number
---@field win number
---@field opts LazyFloatOptions
---@field win_opts LazyWinOpts
---@overload fun(opts?:LazyFloatOptions):LazyFloat
--
map("n", "<leader>pcuw", function()
  local chocoCmd = { "choco", "upgrade", "all", "--noop" }
  require("config.util").float_term(chocoCmd, {
    style = "",
    title = "Choco Packages upgrade all whatif",
  })
end, "Choco Packages upgrade all whatif")

map("n", "<leader>ps", function()
  require("lazy").home()
end, "Plugins Status")

map("n", "<leader>pS", function()
  require("lazy").sync()
end, "Plugins Sync")

map("n", "<leader>pu", function()
  require("lazy").check()
end, "Plugins Check Updates")

map("n", "<leader>pU", function()
  require("lazy").update()
end, "Plugins Update")

-- windows
map("n", "<leader>gwo", "<C-W>p", "Other window")
map("n", "<leader>gwd", "<C-W>c", "Delete window")
map("n", "<leader>-", "<C-W>s", "Split window below")
map("n", "<leader>|", "<C-W>v", "Split window right")

map("n", "<leader>.", function()
  local here = vim.fn.expand("%:p:h")
  vim.cmd("cd " .. here)
  vim.notify("CWD set to: " .. here)
end, "Set CWD to here")
map("n", "<leader><leader>x", function()
  vim.cmd("w")
  vim.cmd("source %")
end, "save and source current file")
map("n", "<leader><leader>i", function()
  if LazyVimUtil.has("nvim-toggler") then
    require("nvim-toggler").toggle()
  else
    print("not implemented yet")
  end
end, "invert under cursor")

map("n", "<leader>llog", "<cmd>LspLog<cr>", "LspLog")
-- map("n", "<leader>lI", "<cmd>LspRestart<cr>", "Lsp Reinit")
map("n", "<leader>lI", "<cmd>LspRestart<cr>", "Lsp Reinit")
map("n", "<leader>li", function()
  require("lspconfig.ui.lspinfo")()
end, "LSP Info")
map("n", "<leader>lk", function()
  vim.fn.writefile({}, vim.lsp.get_log_path())
end, "reset LSP log")

if LazyVimUtil.has("telescope.nvim") then -- setup telescope mappings if available
  map("n", "<leader>ft", function()
    require("telescope.builtin").builtin()
  end, "Telescope") -- map("n","<leader>gd", function()
  map("n", "gT", function()
    require("telescope.builtin").lsp_type_definitions()
  end, "Telescope Type Definitions") -- map("n","<leader>gd", function()
  map("n", "gI", function()
    require("telescope.builtin").lsp_implementations()
  end, "Telescope lsp implementations")
  map("n", "<leader>lG", function()
    require("telescope.builtin").lsp_workspace_symbols()
  end, "Telescope lsp workspace symbols")
end
if LazyVimUtil.has("definition-or-references.nvim") then
  map("n", "gd", function()
    require("definition-or-references").definition_or_references()
  end, "Go to definition or references")
end
if LazyVimUtil.has("toggleterm.nvim") then
  --if fn.executable "lazygit" == 1 then

  -- term_details can be either a string for just a command or
  -- a complete table to provide full access to configuration when calling Terminal:new()
  --- Toggle a user terminal if it exists, if not then create a new one and save it
  -- @param term_details a terminal command string or a table of options for Terminal:new() (Check toggleterm.nvim documentation for table format)
  local function toggle_term_cmd(stringOrTableOpts)
    local terms = UserTerms
    local opts
    -- if a command string is provided, create a basic table for Terminal:new() options
    if type(stringOrTableOpts) == "string" then
      opts = { cmd = stringOrTableOpts, hidden = true }
    else
      opts = stringOrTableOpts
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

  map("n", "<leader>tr", function()
    require("neotest").run.run()
  end, "Run the nearest test")

  map("n", "<leader>tR", function()
    local path = require("plenary.path")
    local thisFile = StringReplace(vim.fn.expand("%:p"), "\\", "/")
    vim.notify("running tests in file: " .. thisFile)
    require("neotest").run.run(thisFile)
  end, "Run the current file")

  map("n", "<leader>ts", function()
    require("neotest").run.stop()
  end, "stop the nearest test")

  map("n", "<leader>ta", function()
    require("neotest").run.attach()
  end, "attach to the nearest test")

  map("n", "<leader>th", function()
    require("neotest").output.open({ enter = true })
  end, "open output window")

  map("n", "<leader>td", function()
    require("neotest").run.run({ strategy = "dap" })
  end, "run the test in debug mode.")

  -- Improved Terminal Navigation
  map("t", "<C-h>", "<c-\\><c-n><c-w>h", "Terminal left window navigation")
  map("t", "<C-j>", "<c-\\><c-n><c-w>j", "Terminal down window navigation")
  map("t", "<C-k>", "<c-\\><c-n><c-w>k", "Terminal up window navigation")
  map("t", "<C-l>", "<c-\\><c-n><c-w>l", "Terminal right window navigation")
  map("t", "<C-q>", "<C-\\><C-n>", "Terminal normal mode")
  map("t", "<esc><esc>", "<C-\\><C-n>:q<cr>", "Terminal quit")
  --["<C-'>","<F7>"],
  map("n", "<leader>gg", function()
    toggle_term_cmd("lazygit")
  end, "ToggleTerm lazygit")
  -- map("n", "<leader>tl", function()
  --   toggle_term_cmd("lazygit")
  -- end, "ToggleTerm lazygit")
  --end
  --if fn.executable "node" == 1 then
  -- map("n", "<leader>tn", function()
  --   toggle_term_cmd("node")
  -- end, "ToggleTerm node")
  --end
  --if fn.executable "gdu" == 1 then
  map("n", "<leader>tu", function()
    toggle_term_cmd("gdu")
  end, "ToggleTerm gdu")
  --end
  --if fn.executable "btm" == 1 then
  map("n", "<leader>tb", function()
    toggle_term_cmd("btm")
  end, "ToggleTerm btm")
  --end
  --if fn.executable "python" == 1 then
  -- map("n", "<leader>tp", function()
  --   toggle_term_cmd("python")
  -- end, "ToggleTerm python")
  --end
  map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", "ToggleTerm float")
  -- map("n", "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", "ToggleTerm horizontal split")
  map("n", "<leader>tt", "<cmd>ToggleTerm size=80 direction=vertical<cr>", "ToggleTerm vertical split")
  map("n", "<F7>", "<cmd>ToggleTerm<cr>", "Toggle terminal")
  --end
end

-- if Util.has("mini.align") then
--   map({ "v" }, "ga", function()
--     require("mini.align").align()
--   end, "Mini Align")
-- end

-- map({ "i", "s" }, "<cr>", function()
--   -- require("cmp").complete({ select = true })
-- end, "Cmp Complete")

if LazyVimUtil.has("nvim-dap") then
  if LazyVimUtil.has("hydra.nvim") then
    map("n", "<leader>dh", function()
      -- if vim.cmd.PreDebugTask() then
      local hydra = require("hydra")
      hydra.spawn("dap-hydra")
      -- if vim.cmd.PreDebugTask() then
      --   -- require("dap").continue()
      -- else
      --   print("predebug task was false, so assuming there was a problem and not debugging")
      -- end
      -- require("dap").continue()
      -- else
      -- print("predebug task was false, so assuming there was a problem and not debugging")
      -- end
    end, "Debugger: DapHydra")
  end
  -- ['<leader>da']  = {
  -- function()
else
  -- 	-- require'dap'.set_breakpoint()
  -- 	-- require'dap'.run({type='python', request='attach', host='127.0.0.1', port=5678})
  -- end,    'Attach (localhost, 5678)'} ,
  map("n", "<F5>", function()
    if vim.cmd.PreDebugTask() then
      -- require("dap").continue()
    else
      print("predebug task was false, so assuming there was a problem and not debugging")
    end
  end, "Debugger: Start")
  map("n", "<F17>", function()
    require("dap").terminate()
  end, "Debugger: Stop") -- Shift+F5,
  map("n", "<F29>", function()
    require("dap").restart_frame()
  end, "Debugger: Restart") -- Control+F5,
  map("n", "<F6>", function()
    require("dap").pause()
  end, "Debugger: Pause")
  map("n", "<F9>", function()
    require("dap").toggle_breakpoint()
  end, "Debugger: Toggle Breakpoint")
  map("n", "<F10>", function()
    require("dap").step_over()
  end, "Debugger: Step Over")
  map("n", "<F11>", function()
    require("dap").step_into()
  end, "Debugger: Step Into")
  map("n", "<F23>", function()
    require("dap").step_out()
  end, "Debugger: Step Out") -- Shift+F11,
  map("n", "<leader>db", function()
    require("dap").toggle_breakpoint()
  end, "Toggle Breakpoint (F9)")
  map("n", "<leader>dB", function()
    require("dap").clear_breakpoints()
  end, "Clear Breakpoints")
  map("n", "<leader>dc", function()
    if vim.cmd.PreDebugTask() then
      -- require("dap").continue()
    else
      print("predebug task was false, so assuming there was a problem and not debugging")
    end
  end, "Start/Continue (F5)")
  map("n", "<leader>di", function()
    require("dap").step_into()
  end, "Step Into (F11)")
  map("n", "<leader>do", function()
    require("dap").step_over()
  end, "Step Over (F10)")
  map("n", "<leader>dO", function()
    require("dap").step_out()
  end, "Step Out (S-F11)")
  map("n", "<leader>dq", function()
    require("dap").close()
  end, "Close Session")
  map("n", "<leader>dQ", function()
    require("dap").terminate()
  end, "Terminate Session (S-F5)")
  map("n", "<leader>dp", function()
    require("dap").pause()
  end, "Pause (F6)")
  map("n", "<leader>dr", function()
    require("dap").restart_frame()
  end, "Restart (C-F5)")
  map("n", "<leader>dR", function()
    require("dap").repl.toggle()
  end, "Toggle REPL")

  -- end
  if "nvim-dap-ui" then
    map("n", "<leader>du", function()
      require("dapui").toggle()
    end, "Toggle Debugger UI")
    map("n", "<leader>dh", function()
      require("dap.ui.widgets").hover()
    end, "Debugger Hover")
  end
end

--   n = {
--     ["<leader>"] = {
--       -- b = { "<cmd>read !getbib -c<cr>", "Get Bib" },
--       d = {
--         name = "Duck...",
--         -- popular candidates: 🦆 ඞ 🦀 🐈 🐎 🦖 🐤
--         -- d = { function() require("duck").hatch("🦆", 10) end },
--         -- c = { function() require("duck").hatch("🐈", 0.80) end },
--         -- k = { function() require("duck").cook() end },
--       },
--
--       I = {
--         name = "Invert Word under Cursor",
--       },
--       -- r = { "<cmd>SendHere<cr>", "Set REPL" },
--       N = { "<cmd>tabnew<cr>", "New Buffer" },
--       -- ["<cr>"] = { '<esc>/<++><cr>"_c4l', "Next Template" },
--       ["."] = { "<cmd>cd %:p:h<cr>", "Set CWD" },
--
--       -- a = {
--       --   name = "Annotate",
--       --   ["<cr>"] = { function() require("neogen").generate() end, "Current" },
--       --   c = { function() require("neogen").generate { type = "class" } end, "Class" },
--       --   f = { function() require("neogen").generate { type = "func" } end, "Function" },
--       --   t = { function() require("neogen").generate { type = "type" } end, "Type" },
--       --   F = { function() require("neogen").generate { type = "file" } end, "File" },
--       -- },
--       --
--       f = {
--         name = "Telescope",
--         ["?"] = { "<cmd>Telescope help_tags<cr>", "Find Help" },
--         ["'"] = { "<cmd>Telescope marks<cr>", "Marks" },
--         -- B = { "<cmd>Telescope bibtex<cr>", "BibTeX" },
--         e = { "<cmd>Telescope file_browser<cr>", "Explorer" },
--         h = { "<cmd>Telescope oldfiles<cr>", "History" },
--         --a        h = { function() require("telescope").load_extension "file_browser" end, "History" },
--         k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
--         m = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
--         M = { "<cmd>Telescope media_files<cr>", "Media" },
--         n = { "<cmd>Telescope notify<cr>", "Notifications" },
--         p = { "<cmd>Telescope project<cr>", "Projects" },
--         r = { "<cmd>Telescope registers<cr>", "Registers" },
--         t = { "<cmd>Telescope colorscheme<cr>", "Themes" },
--       },
--
--       m = {
--         name = "Compiler",
--         -- k = {
--         --   function()
--         --     vim.cmd "silent! write"
--         --     local filename = vim.fn.expand "%:t"
--         --     utils.async_run(
--         --       { "compiler", vim.fn.expand "%:p" },
--         --       function() utils.quick_notification("Compiled " .. filename) end
--         --     )
--         --   end,
--         --   "Compile",
--         -- },
--         -- a = {
--         --   function()
--         --     vim.notify "Autocompile Started"
--         --     utils.async_run(
--         --       { "autocomp", vim.fn.expand "%:p" },
--         --       function() utils.quick_notification "Autocompile stopped" end
--         --     )
--         --   end,
--         --   "Auto Compile",
--         -- },
--         v = { function() vim.fn.jobstart { "opout", vim.fn.expand "%:p" } end, "View Output" },
--         -- b = {
--         --   function()
--         --     local filename = vim.fn.expand "%:t"
--         --     utils.async_run({
--         --       "pandoc",
--         --       vim.fn.expand "%",
--         --       "--pdf-engine=xelatex",
--         --       "--variable",
--         --       "urlcolor=blue",
--         --       "-t",
--         --       "beamer",
--         --       "-o",
--         --       vim.fn.expand "%:r" .. ".pdf",
--         --     }, function() utils.quick_notification("Compiled " .. filename) end)
--         --   end,
--         --   "Compile Beamer",
--         -- },
--         b = {
--           function()
--             local isDotnet = function()
--               for k, v in pairs(vim.lsp.get_active_clients()) do
--                 if v.name == "omnisharp" or v.name == "ionide" or v.name == "fsautocomlete" then return true end
--                 return false
--               end
--             end
--             if isDotnet() then
--               local proj = vim.g.dotnet_get_project_path()
--               local build = function()
--                 vim.cmd("w " .. vim.fn.expand "%")
--                 print("attempting to build " .. proj)
--                 -- utils.async_run {
--                 return vim.g.dotnet_build_project(proj)
--                 -- }
--               end
--               local bok, b = pcall(build)
--
--               if bok then
--                 if b == 0 then
--                   if vim.fn.confirm("Build Successful, run now?", "&yes\n&no", 2) == 1 then
--                     vim.g.dotnet_run(proj, "release")
--                   end
--                 else
--                   print "Build Not Successful.. check log."
--                 end
--               end
--             end
--           end,
--           "Build Dotnet project",
--         },
--         -- p = {
--         --   function()
--         --     local pdf_path = vim.fn.expand "%:r" .. ".pdf"
--         --     if vim.fn.filereadable(pdf_path) == 1 then vim.fn.jobstart { "pdfpc", pdf_path } end
--         --   end,
--         --   "Present Output",
--         -- },
--         l = { function() utils.toggle_qf() end, "Logs" },
--         -- t = { "<cmd>TexlabBuild<cr>", "LaTeX" },
--         -- f = { "<cmd>TexlabForward<cr>", "Forward Search" },
--       },
--
--       s = {
--         name = "Surf",
--         s = { function() require("syntax-tree-surfer").select() end, "Surf" },
--         S = { function() require("syntax-tree-surfer").select_current_node() end, "Surf Node" },
--       },
--
--       x = {
--         name = "Debugger",
--         b = { function() require("dap").toggle_breakpoint() end, "Toggle Breakpoint" },
--         B = { function() require("dap").clear_breakpoints() end, "Clear Breakpoints" },
--         c = { function() require("dap").continue() end, "Continue" },
--         i = { function() require("dap").step_into() end, "Step Into" },
--         l = { function() require("dapui").float_element "breakpoints" end, "List Breakpoints" },
--         o = { function() require("dap").step_over() end, "Step Over" },
--         q = { function() require("dap").close() end, "Close Session" },
--         Q = { function() require("dap").terminate() end, "Terminate" },
--         r = { function() require("dap").repl.toggle() end, "REPL" },
--         s = { function() require("dapui").float_element "scopes" end, "Scopes" },
--         t = { function() require("dapui").float_element "stacks" end, "Threads" },
--         u = { function() require("dapui").toggle() end, "Toggle Debugger UI" },
--         w = { function() require("dapui").float_element "watches" end, "Watches" },
--         x = { function() require("dap.ui.widgets").hover() end, "Inspect" },
--       },
--       t = {
--         name = "Tests",
--         s = { function() require("neotest").summary.toggle() end, "Neotest: Open test summary window" },
--         f = { function() require("neotest").run.run(vim.fn.expand "%") end, "Neotest: Run tests in file" },
--         n = { function() require("neotest").run.run() end, "Neotest: Run nearest test" },
--         d = { function() require("neotest").run.run { strategy = "dap" } end, "Neotest: Debug nearest test" },
--       },
--     },
--     ["]"] = {
--       f = "Next function start",
--       x = "Next class start",
--       F = "Next function end",
--       X = "Next class end",
--     },
--     ["["] = {
--       f = "Previous function start",
--       x = "Previous class start",
--       F = "Previous function end",
--       X = "Previous class end",
--     },
--     g = {
--       t = {
--         name = "Treesitter",
--         v = {
--           function() require("syntax-tree-surfer").targeted_jump { "variable_declaration" } end,
--           "Go to Variables",
--         },
--         f = {
--           function() require("syntax-tree-surfer").targeted_jump { "function" } end,
--           "Go to Functions",
--         },
--         i = {
--           function()
--             require("syntax-tree-surfer").targeted_jump {
--               "if_statement",
--               "else_clause",
--               "else_statement",
--               "elseif_statement",
--             }
--           end,
--           "Go to If Statements",
--         },
--         r = {
--           function() require("syntax-tree-surfer").targeted_jump { "for_statement" } end,
--           "Go to If Statements",
--         },
--         w = {
--           function() require("syntax-tree-surfer").targeted_jump { "white_statement" } end,
--           "Go to While Statements",
--         },
--         s = {
--           function() require("syntax-tree-surfer").targeted_jump { "switch_statement" } end,
--           "Go to Switch Statements",
--         },
--         t = {
--           function()
--             require("syntax-tree-surfer").targeted_jump {
--               "function",
--               "if_statement",
--               "else_clause",
--               "else_statement",
--               "elseif_statement",
--               "for_statement",
--               "while_statement",
--               "switch_statement",
--             }
--           end,
--           "Go to Statement",
--         },
--       },
--       n = {},
--     },
--   },
--   i = {
--     ["<c-d>"] = {
--       n = { "<c-r>=strftime('%Y-%m-%d')<cr>", "Y-m-d" },
--       x = { "<c-r>=strftime('%m/%d/%y')<cr>", "m/d/y" },
--       f = { "<c-r>=strftime('%B %d, %Y')<cr>", "B d, Y" },
--       X = { "<c-r>=strftime('%H:%M')<cr>", "H:M" },
--       F = { "<c-r>=strftime('%H:%M:%S')<cr>", "H:M:S" },
--       d = { "<c-r>=strftime('%Y/%m/%d %H:%M:%S -')<cr>", "Y/m/d H:M:S -" },
--     },
--   },
--   v = {
--     ["<leader>"] = {
--       x = {
--         name = "Debugger",
--         e = { function() require("dapui").eval() end, "Evaluate Line" },
--       },
--     },
--   },
-- }
