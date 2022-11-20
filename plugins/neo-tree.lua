return {

  window = {
    mappings = {
      ["<space>"] = false, -- disable space until we figure out which-key disabling
      u = "navigate_up",
      o = "open",
      O = function(state) astronvim.system_open(state.tree:get_node():get_id()) end,
      H = "prev_source",
      L = "next_source",
    },
  },
  filesystem = {
    filtered_items = {
      hide_hidden = false, -- only works on Windows for hidden files/directories
      follow_current_file = true,
      hijack_netrw_behavior = "open_current",
      use_libuv_file_watcher = true,
      window = { mappings = { h = "toggle_hidden" } },
    },
  },
}
