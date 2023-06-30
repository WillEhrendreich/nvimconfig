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
local fsharpFileSystemSource = {
  window = {
    mappings = {
      ["H"] = "toggle_hidden",
      ["/"] = "fuzzy_finder",
      ["D"] = "fuzzy_finder_directory",
      --["/"] = "filter_as_you_type", -- this was the default until v1.28
      ["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
      -- ["D"] = "fuzzy_sorter_directory",
      ["f"] = "filter_on_submit",
      ["<C-x>"] = "clear_filter",
      ["<bs>"] = "navigate_up",
      ["."] = "set_root",
      ["[g"] = "prev_git_modified",
      ["]g"] = "next_git_modified",
    },
    fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
      ["<down>"] = "move_cursor_down",
      ["<C-n>"] = "move_cursor_down",
      ["<up>"] = "move_cursor_up",
      ["<C-p>"] = "move_cursor_up",
    },
  },
  -- async_directory_scan = "auto", -- "auto"   means refreshes are async, but it's synchronous when called from the Neotree commands.
  async_directory_scan = "always", -- "auto"   means refreshes are async, but it's synchronous when called from the Neotree commands.
  -- "always" means directory scans are always async.
  -- "never"  means directory scans are never async.
  scan_mode = "shallow", -- "shallow": Don't scan into directories to detect possible empty directory a priori
  -- "deep": Scan into directories to detect empty or grouped empty directories a priori.
  bind_to_cwd = true, -- true creates a 2-way binding between vim's cwd and neo-tree's root
  cwd_target = {
    sidebar = "tab", -- sidebar is when position = left or right
    current = "window", -- current is when position = current
  },
  -- The renderer section provides the renderers that will be used to render the tree.
  --   The first level is the node type.
  --   For each node type, you can specify a list of components to render.
  --       Components are rendered in the order they are specified.
  --         The first field in each component is the name of the function to call.
  --         The rest of the fields are passed to the function as the "config" argument.
  filtered_items = {
    visible = false, -- when true, they will just be displayed differently than normal items
    force_visible_in_empty_folder = false, -- when true, hidden files will be shown if the root folder is otherwise empty
    show_hidden_count = true, -- when true, the number of hidden items in each folder will be shown as the last entry
    hide_dotfiles = true,
    hide_gitignored = true,
    hide_hidden = true, -- only works on Windows for hidden files/directories
    hide_by_name = {
      ".DS_Store",
      "thumbs.db",
      --"node_modules",
    },
    hide_by_pattern = { -- uses glob style patterns
      --"*.meta",
      --"*/src/*/tsconfig.json"
    },
    always_show = { -- remains visible even if other settings would normally hide it
      --".gitignored",
    },
    never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
      --".DS_Store",
      --"thumbs.db"
    },
    never_show_by_pattern = { -- uses glob style patterns
      --".null-ls_*",
    },
  },
  find_by_full_path_words = false, -- `false` means it only searches the tail of a path.
  -- `true` will change the filter into a full path
  -- search with space as an implicit ".*", so
  -- `fi init`
  -- will match: `./sources/filesystem/init.lua
  --find_command = "fd", -- this is determined automatically, you probably don't need to set it
  --find_args = {  -- you can specify extra args to pass to the find command.
  --  fd = {
  --  "--exclude", ".git",
  --  "--exclude",  "node_modules"
  --  }
  --},
  ---- or use a function instead of list of strings
  --find_args = function(cmd, path, search_term, args)
  --  if cmd ~= "fd" then
  --    return args
  --  end
  --  --maybe you want to force the filter to always include hidden files:
  --  table.insert(args, "--hidden")
  --  -- but no one ever wants to see .git files
  --  table.insert(args, "--exclude")
  --  table.insert(args, ".git")
  --  -- or node_modules
  --  table.insert(args, "--exclude")
  --  table.insert(args, "node_modules")
  --  --here is where it pays to use the function, you can exclude more for
  --  --short search terms, or vary based on the directory
  --  if string.len(search_term) < 4 and path == "/home/cseickel" then
  --    table.insert(args, "--exclude")
  --    table.insert(args, "Library")
  --  end
  --  return args
  --end,
  group_empty_dirs = false, -- when true, empty folders will be grouped together
  search_limit = 50, -- max number of search results when using filters
  follow_current_file = false, -- This will find and focus the file in the active buffer every time
  -- the current file is changed while the tree is open.
  hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
  -- in whatever position is specified in window.position
  -- "open_current",-- netrw disabled, opening a directory opens within the
  -- window like netrw would, regardless of window.position
  -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
  use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
  -- instead of relying on nvim autocmd events.
}

return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "WillEhrendreich/neo-tree-fsharp",
      dev = true,
      dir = os.getenv("repos") .. "/neo-tree-fsharp/",
    },
  },
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
      addFileAbove = function (state)
        local hasIonide, ionide = pcall(require,"ionide")
        local hasWillEhrendreichIonide = false
        if ionide.Projects then
          hasWillEhrendreichIonide = true
        end 
        if hasWillEhrendreichIonide == true  then


          ---@type NeoTreeItem
          local currentNode = state.tree:get_node()
          ---@type ProjectInfo|nil
          local currentNodeProjectFile = vim.tbl_filter (function (x)

            local projItems = vim.tbl_map(function(p) return p.path end , x.items )
            return vim.tbl_contains(projItems, currentNode.path) end,
            ionide.Projects)[1] or nil
          if not currentNodeProjectFile then
            vim.notify("Could not get a project file for curent selected neo-tree node, cannot add file above it")
            return
          else
            local newFileName = vim.fn.input("add new file above current file " .. vim.fs.normalize(vim.fn.fnnamemodify(currentNode.path,":p:.")))
            vim.notify("wants to add a new file called " .. (newFileName or "None") )
            if newFileName then

              ionide.CallFSharpAddFileAbove(currentNodeProjectFile.Project, currentNode.path, newFileName)

                    end
            end
        end
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
      sources = {
        "filesystem",
        "neo-tree-fsharp",
        -- "buffers",
        -- "git_status",
        -- "document_symbols",
      },
      -- sort_function = function(f)
      --   local nt = require("neo-tree")
      --   -- nt.config.commands
      --   -- nt.
      -- end, -- uses a custom function for sorting files and directories in the tree
      source_selector = {
        winbar = true,
        content_layout = "center",
        sources = {
          { source = "filesystem" },
          { source = "neo-tree-fsharp" },
        },
        -- tab_labels = {
        -- filesystem = v.get_icon("FolderClosed") .. " File",
        -- fsharp = v.get_icon("FSharp") .. " FSharp",
        --   buffers = v.get_icon("DefaultFile") .. " Bufs",
        --   git_status = v.get_icon("Git") .. " Git",
        --   diagnostics = v.get_icon("Diagnostic") .. " Diagnostic",
        -- },
      },
      default_component_configs = {
        indent = { padding = 0 },
      },
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
      ["neo-tree-fsharp"] = {
        follow_current_file = true,
        group_empty_dirs = true, -- when true, empty folders will be grouped together
        hijack_netrw_behavior = "open_current",
        use_libuv_file_watcher = true,
        async_directory_scan = "auto", -- "auto"   means refreshes are async, but it's synchronous when called from the Neotree commands.
        -- "always" means directory scans are always async.
        -- "never"  means directory scans are never async.
        scan_mode = "shallow", -- "shallow": Don't scan into directories to detect possible empty directory a priori
        -- "deep": Scan into directories to detect empty or grouped empty directories a priori.
        bind_to_cwd = true, -- true creates a 2-way binding between vim's cwd and neo-tree's root
        cwd_target = {
          sidebar = "tab", -- sidebar is when position = left or right
          current = "window", -- current is when position = current
        },
        filtered_items = {
          visible = true, -- when true, they will just be displayed differently than normal items
          force_visible_in_empty_folder = true, -- when true, hidden files will be shown if the root folder is otherwise empty
          show_hidden_count = true, -- when true, the number of hidden items in each folder will be shown as the last entry
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false, -- only works on Windows for hidden files/directories
          hide_by_name = {
            ".DS_Store",
            "thumbs.db",
            --"node_modules",
          },
          hide_by_pattern = { -- uses glob style patterns
            --"*.meta",
            --"*/src/*/tsconfig.json"
          },
          always_show = { -- remains visible even if other settings would normally hide it
            --".gitignored",
          },
          never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
            --".DS_Store",
            --"thumbs.db"
          },
          never_show_by_pattern = { -- uses glob style patterns
            --".null-ls_*",
          },
        },
        window = {
          mappings = {
            O = "system_open",
            i = "toggle_hidden",
            h = "parent_or_close",
            l = "child_or_open",
            u = "navigate_up",
          },
        },
        commands = global_commands,
      },
      filesystem = {
        follow_current_file = true,
        group_empty_dirs = true, -- when true, empty folders will be grouped together
        hijack_netrw_behavior = "open_current",
        use_libuv_file_watcher = true,
        async_directory_scan = "auto", -- "auto"   means refreshes are async, but it's synchronous when called from the Neotree commands.
        -- "always" means directory scans are always async.
        -- "never"  means directory scans are never async.
        scan_mode = "shallow", -- "shallow": Don't scan into directories to detect possible empty directory a priori
        -- "deep": Scan into directories to detect empty or grouped empty directories a priori.
        bind_to_cwd = true, -- true creates a 2-way binding between vim's cwd and neo-tree's root
        cwd_target = {
          sidebar = "tab", -- sidebar is when position = left or right
          current = "window", -- current is when position = current
        },
        filtered_items = {
          visible = true, -- when true, they will just be displayed differently than normal items
          force_visible_in_empty_folder = true, -- when true, hidden files will be shown if the root folder is otherwise empty
          show_hidden_count = true, -- when true, the number of hidden items in each folder will be shown as the last entry
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false, -- only works on Windows for hidden files/directories
          hide_by_name = {
            ".DS_Store",
            "thumbs.db",
            --"node_modules",
          },
          hide_by_pattern = { -- uses glob style patterns
            --"*.meta",
            --"*/src/*/tsconfig.json"
          },
          always_show = { -- remains visible even if other settings would normally hide it
            --".gitignored",
          },
          never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
            --".DS_Store",
            --"thumbs.db"
          },
          never_show_by_pattern = { -- uses glob style patterns
            --".null-ls_*",
          },
        },
        window = {
          mappings = {
            O = "system_open",
            i = "toggle_hidden",
            h = "parent_or_close",
            l = "child_or_open",
            u = "navigate_up",
          },
        },
        commands = global_commands,
      },
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function(_)
            vim.opt_local.signcolumn = "auto"
          end,
        },
      },
      -- buffers = { commands = global_commands },
      -- git_status = { commands = global_commands },
    })
  end,
}
