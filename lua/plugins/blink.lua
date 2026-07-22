local function clamp_vbnet_lsp_completion_ranges(ctx, items)
  if vim.bo.filetype ~= "vb" then
    return items
  end

  local cursor_line = ctx.cursor[1] - 1
  local cursor_col = ctx.cursor[2]

  for _, item in ipairs(items) do
    if item.client_name == "vbnet_lsp" and item.textEdit ~= nil then
      local edit = item.textEdit

      -- vbnet-ls can return replace ranges that extend into the next word.
      -- Treat VB completions as insert-only so accepting an item cannot eat
      -- text to the right of the cursor.
      if edit.insert ~= nil then
        edit.range = vim.deepcopy(edit.insert)
        edit.insert = nil
        edit.replace = nil
      elseif edit.range ~= nil then
        if edit.range["end"].line > cursor_line then
          edit.range["end"].line = cursor_line
          edit.range["end"].character = cursor_col
        elseif edit.range["end"].line == cursor_line and edit.range["end"].character > cursor_col then
          edit.range["end"].character = cursor_col
        end
      end
    end
  end

  return items
end

return {
  -- add blink.compat
  {
    "saghen/blink.compat",
    -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
    version = "*",
    -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
    lazy = true,
    -- make sure to set opts so that lazy.nvim calls blink.compat's setup
    opts = {},
  },
  {
    "saghen/blink.cmp",
    dependencies = {
      "Kaiser-Yang/blink-cmp-avante",
      -- add source
      {
        "PasiBergman/cmp-nuget",
        ft = { "cs_project", "fsharp_project" }, -- optional but good to have
        opts = {}, -- needed
      },
      { "L3MON4D3/LuaSnip", version = "v2.*" },
    },
    --
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- fuzzy = { implementation = "prefer_rust" },
      snippets = {
        preset = "default",
      },
      appearance = {
        -- sets the fallback highlight groups to nvim-cmp's highlight groups
        -- useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release, assuming themes add support
        use_nvim_cmp_as_default = false,
        -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",
        kind_icons = vim.tbl_extend("keep", {
          Color = "██", -- Use block instead of icon for color items to make swatches more usable
        }, LazyVim.config.icons.kinds),
      },
      completion = {
        accept = {
          -- experimental auto-brackets support
          auto_brackets = {
            enabled = false,
          },
        },
        menu = {
          draw = {
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        -- ghost_text = {
        --   enabled = vim.g.ai_cmp,
        -- },
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
      },

      -- experimental signature help support
      signature = { enabled = true },

      -- cmdline = {
      --   sources = {},
      -- },
      --
      sources = {
        -- adding any nvim-cmp sources here will enable them
        -- with blink.compat
        compat = { "nuget" },
        default = {
          "avante",
          "lsp",
          "path",
          "snippets",
          "lazydev",
          "buffer",
          "nuget",
          -- "obsidian",
          "easy-dotnet",
          -- "obsidian_new",
          -- "obsidian_tags",
        },
        providers = {

          -- obsidian = {
          --   name = "obsidian",
          --   module = "blink.compat.source",
          -- },
          -- obsidian_new = {
          --   name = "obsidian_new",
          --   module = "blink.compat.source",
          -- },
          -- obsidian_tags = {
          --   name = "obsidian_tags",
          --   module = "blink.compat.source",
          -- },
          lsp = {
            transform_items = clamp_vbnet_lsp_completion_ranges,
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100, -- show at a higher priority than lsp
          },
          ["easy-dotnet"] = {
            name = "easy-dotnet",
            enabled = true,
            module = "easy-dotnet.completion.blink",
            score_offset = 10000,
            async = true,
          },
          avante = {
            module = "blink-cmp-avante",
            name = "Avante",
            opts = {
              -- options for blink-cmp-avante
            },
          },
          -- create provider
          nuget = {
            name = "nuget", -- IMPORTANT: use the same name as you would for nvim-cmp
            module = "cmp-nuget.nuget",

            -- all blink.cmp source config options work as normal:
            score_offset = -3,

            -- this table is passed directly to the proxied completion source
            -- as the `option` field in nvim-cmp's source config
            --
            -- this is NOT the same as the opts in a plugin's lazy.nvim spec
            opts = {},
          },
        },
      },

      keymap = {
        preset = "default",

        ["<esc>"] = {
          function(cmp)
            if cmp.is_visible() then
              cmp.cancel()
              return false
            end -- runs the next command
          end,
          "fallback",
        },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },

        ["<S-n>"] = { "scroll_documentation_up", "fallback" },
        ["<S-p>"] = { "scroll_documentation_down", "fallback" },

        ["<C-y>"] = { "select_and_accept" },
        ["<Down>"] = {
          function(cmp)
            if cmp.is_visible() then
              cmp.select_next()
              return true
            else
              return false
            end
          end,
          "fallback",
        },
        ["<C-n>"] = {
          function(cmp)
            if not cmp.is_visible() then
              cmp.show()
              return true -- doesn't run the next command
            end -- runs the next command
          end,
          "select_next",
        },
        ["<Up>"] = {
          function(cmp)
            if cmp.is_visible() then
              cmp.select_prev()
              return true -- doesn't run the next command
            else
              return false
            end
          end,
          "fallback",
        },
        ["<C-p>"] = {
          function(cmp)
            if not cmp.is_visible() then
              cmp.show()
              return true -- doesn't run the next command
            end -- runs the next command
          end,
          "select_prev",
        },
      },
    },
  },
}
