local util = require("config.util")
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
  },
  ui = {
    icons = {
      Text = "",
      Method = "⛏",
      Function = "🦾",
      Constructor = "👷",
      Field = "🏕️",
      Variable = "🛡️",
      Class = "🧩",
      Interface = "",
      Module = "",
      Property = "🥠",
      Unit = "",
      Value = "🗿",
      Enum = "",
      Keyword = "🗝️",
      Snippet = "",
      Color = "🎨",
      File = "📄",
      Reference = "",
      Folder = "📂",
      EnumMember = "",
      Constant = "🪨",
      Struct = "",
      Event = "",
      Operator = "🎬",
      TypeParameter = "🌀",
      cmd = "⌘",
      config = "🛠",
      event = "",
      ft = "📂",
      init = "⚙",
      keys = "🎹",
      plugin = "🔌",
      runtime = "💻",
      source = "📄",
      start = "🚀",
      task = "📌",
    },
    -- leave nil, to automatically select a browser depending on your OS.
    -- If you want to use a specific browser, you can define it here
    -- browser = "firefox", ---@type string?
    browser = nil, ---@type string?
  },
  dev = {
    -- directory where you store your local plugin projects
    path = (function()
      if util.hasReposEnvironmentVarSet() then
        return util.getReposVariableIfSet()
      else
        if vim.fn.has("win32") == 1 then
          return "c:/code/repos"
        else
          return "~/code/repos"
        end
      end
    end)(),
    ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
    patterns = {}, -- For example {"folke"}
    fallback = true, -- Fallback to git when local plugin doesn't exist
  },
  install = { colorscheme = { "kanagawa" } },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        -- "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
