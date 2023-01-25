vim.g.mapleader = " "

local sections = {
  f = { name = "File" },
  p = { name = "Packages" },
  l = { name = "LSP" },
  u = { name = "UI" },
  b = { name = "Buffers" },
  d = { name = "Debugger" },
  g = { name = "Git" },
  s = { name = "Search" },
  S = { name = "Session" },
  t = { name = "Terminal" },
}

local mappings =
{
  n = {

    ["<leader>b"] = sections.b,
    ["<leader>w"] = { "<cmd>VSCodeCall('workbench.action.files.save')<cr>", desc = "Save" },
    ["<leader>q"] = { "<cmd>VSCodeCall('workbench.action.files.quit')<cr>", desc = "Quit" },
    ["<leader>f"] = sections.f,
    ["<leader>fn"] = { "<cmd>enew<cr>", desc = "New File" },
    -- ["gx"] = { function() vimsharp.system_open() end, desc = "Open the file under cursor with system app" },
    ["<C-s>"] = { "<cmd>w!<cr>", desc = "Force write" },
    ["<C-q>"] = { "<cmd>q!<cr>", desc = "Force quit" },
    ["Q"] = "<Nop>",
    ["<C-h>"] = { "<C-w>h", desc = "Move to left split" },
    ["<C-j>"] = { "<C-w>j", desc = "Move to below split" },
    ["<C-k>"] = { "<C-w>k", desc = "Move to above split" },
    ["<C-l>"] = { "<C-w>l", desc = "Move to right split" },
    ["<leader>/"] = { "<cmd>VSCodeCommentary()<cr>", desc = "Comment line" },
    -- Move Lines
    ["<A-j>"] = { ":m .+1<CR>==", desc = "move line down" },
    ["<A-k>"] = { ":m .-2<CR>==", desc = "move line up" },

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
    -- Move Lines
    ["<A-j>"] = { ":m '>+1<CR>gv=gv", desc = "move line down" },
    ["<A-k>"] = { ":m '<-2<CR>gv=gv", desc = "move line up" },
    ["<leader>/"] = { "<cmd>VSCodeCommentary()<cr>", desc = "Comment line" },
    -- navigating wrapped lines
    j = { "gj", desc = "Navigate down" },
    k = { "gk", desc = "Navigate down" },
  },
  -- terminal mappings
  t = {
    ["<C-q>"] = { "<C-\\><C-n>", desc = "Terminal normal mode" },
    ["<esc><esc>"] = { "<C-\\><C-n>:q<cr>", desc = "Terminal quit" },
  },
  x = {
    -- better increment/decrement
    ["+"] = { "g<C-a>", desc = "Increment number" },
    ["_"] = { "g<C-x>", desc = "Descrement number" },
    -- line text-objects
    ["il"] = { "g_o^", desc = "Inside line text object" },
    ["al"] = { "$o^", desc = "Around line text object" },

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


return mappings

