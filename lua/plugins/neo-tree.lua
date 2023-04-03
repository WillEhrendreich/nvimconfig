--- Open a URL under the cursor with the current operating system
-- @param path the path of the file to open with the system opener
local function system_open(path)
  local cmd
  if vim.fn.has("win32") == 1 and vim.fn.executable("explorer") == 1 then
    cmd = "explorer"
  elseif vim.fn.has("unix") == 1 and vim.fn.executable("xdg-open") == 1 then
    cmd = "xdg-open"
  elseif (vim.fn.has("mac") == 1 or vim.fn.has("unix") == 1) and vim.fn.executable("open") == 1 then
    cmd = "open"
  end
  if not cmd then
    vim.notify("Available system opening tool not found!", "error")
  end
  vim.fn.jobstart({ cmd, path or vim.fn.expand("<cfile>") }, { detach = true })
end
return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = "Neotree",
  init = function()
    vim.g.neo_tree_remove_legacy_commands = true
  end,
  config = function()
    -- re "configs.neo-tree"
    -- TODO move after neo-tree improves (https://github.com/nvim-neo-tree/neo-tree.nvim/issues/707)
    local global_commands = {
      parent_or_close = function(state)
        local node = state.tree:get_node()
        if (node.type == "directory" or node:has_children()) and node:is_expanded() then
          state.commands.toggle_node(state)
        else
          require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
        end
      end,
      child_or_open = function(state)
        local node = state.tree:get_node()
        if node.type == "directory" or node:has_children() then
          if not node:is_expanded() then -- if unexpanded, expand
            state.commands.toggle_node(state)
          else -- if expanded and has children, seleect the next child
            require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
          end
        else -- if not a directory just open it
          state.commands.open(state)
        end
      end,
      system_open = function(state)
        system_open(state.tree:get_node():get_id())
      end,
      -- delete = function(state)
      --   local path = state.tree:get_node().path
      --   local b = "C:\\$Recycle.Bin"
      --   local uid = (function()
      --     if os.getenv("LocalUserId") then
      --       return os.getenv("LocalUserId")
      --     else
      --       local function getUid()
      --         local function runWhoAmI()
      --           return vim.fn.system("whoami /user /NH")
      --         end
      --
      --         local _, id = unpack(vim.split(string.gsub(runWhoAmI(), "\n", ""), " "))
      --         if id then
      --           return id
      --         else
      --           return ""
      --         end
      --       end
      --
      --       vim.env["LocalUserId"] = getUid()
      --     end
      --   end)()
      --   local command = "Add-Type -AssemblyName Microsoft.VisualBasic\n"
      --     .. '[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile("'
      --     .. vim.fn.fnameescape(path)
      --     .. "\",'OnlyErrorDialogs','SendToRecycleBin')"
      --   vim.fn.system(command)
      --   -- vim.fn.system({ "Recycle", vim.fn.fnameescape(path) })
      --   require("neo-tree.sources.manager").refresh(state.name)
      -- end,
    }
    require("neo-tree").setup({
      close_if_last_window = true,
      enable_diagnostics = true,
      source_selector = {
        winbar = true,
        content_layout = "center",
        -- tab_labels = {
        --   filesystem = v.get_icon("FolderClosed") .. " File",
        --   buffers = v.get_icon("DefaultFile") .. " Bufs",
        --   git_status = v.get_icon("Git") .. " Git",
        --   diagnostics = v.get_icon("Diagnostic") .. " Diagnostic",
        -- },
      },
      default_component_configs = {
        indent = { padding = 0 },

        -- icon = {
        --   folder_closed = v.get_icon("FolderClosed"),
        --   folder_open = v.get_icon("FolderOpen"),
        --   folder_empty = v.get_icon("FolderEmpty"),
        --   default = v.get_icon("DefaultFile"),
        -- },

        -- git_status = {
        --   symbols = {
        --     added = v.get_icon("GitAdd"),
        --     deleted = v.get_icon("GitDelete"),
        --     modified = v.get_icon("GitChange"),
        --     renamed = v.get_icon("GitRenamed"),
        --     untracked = v.get_icon("GitUntracked"),
        --     ignored = v.get_icon("GitIgnored"),
        --     unstaged = v.get_icon("GitUnstaged"),
        --     staged = v.get_icon("GitStaged"),
        --     conflict = v.get_icon("GitConflict"),
        --   },
        -- },
      },
      -- window = {
      --   width = 30,
      --   mappings = {
      --     ["<space>"] = false, -- disable space until we figure out which-key disabling
      --     u = "navigate_up",
      --     o = "open",
      --     O = function(state) v.SystemOpen(state.tree:get_node():get_id()) end,
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
          -- ["<space>"] = false, -- disable space until we figure out which-key disabling
          o = "open",
          O = "system_open",
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
            i = "toggle_hidden",
            h = "parent_or_close",
            l = "child_or_open",
            u = "navigate_up",
            -- h = "toggle_hidden",
            -- h = "toggle_hidden",
            -- h = "toggle_hidden",
            -- h = "toggle_hidden",
          },
        },
        commands = global_commands,
      },
      buffers = { commands = global_commands },
      git_status = { commands = global_commands },
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function(_)
            vim.opt_local.signcolumn = "auto"
          end,
        },
      },
    })
  end,
}
