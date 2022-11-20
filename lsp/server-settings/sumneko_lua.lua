-- put this file somewhere in your nvim config, like: ~/.config/nvim/lua/config/lua-lsp.lua
-- usage: require'lspconfig'.sumneko_lua.setup(require("config.lua-lsp"))

local library = {}

local path = vim.split(package.path, ";")

-- this is the ONLY correct way to setup your path
table.insert(path, "lua/?.lua")
table.insert(path, "lua/?/init.lua")

local function add(lib)
  for _, p in pairs(vim.fn.expand(lib, false, true)) do
    p = vim.loop.fs_realpath(p)
    library[p] = true
  end
end

-- add runtime
add "$VIMRUNTIME"

-- add your config
add "c:/.config/nvim"

-- add plugins
-- if you're not using packer, then you might need to change the paths below
add "c:/.local/share/nvim/site/pack/packer/opt/*"
add "c:/.local/share/nvim/site/pack/packer/start/*"
return {
  -- delete root from workspace to make sure we don't trigger duplicate warnings
  on_new_config = function(config, root)
    local libs = vim.tbl_deep_extend("force", {}, library)
    libs[root] = nil
    config.settings.Lua.workspace.library = libs
    return config
  end,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
        -- Setup your lua path
        path = path,
      },
      completion = { callSnippet = "Both" },
      diagnostics = { globals = { "vim", "astronvim", "astronvim_installation", "packer_plugins", "bit" } },
      workspace = {
        maxPreload = 2000,
        preloadFileSize = 50000,
        library = {
          vim.api.nvim_get_runtime_file("", true),
          astronvim.install.home .. "/lua",
          vim.fn.expand "$NVIMCONFIG",
          vim.fn.expand "$NVIMCONFIG/lua",
          astronvim.install.config .. "/lua",
        },
      },
    },
  },
}
