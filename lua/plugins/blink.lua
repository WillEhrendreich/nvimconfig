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
    -- config = function(opts)
    --   local cmp = require("blink.cmp")
    --
    --   cmp.setup(opts)
    --
    --   local list = require("blink.cmp.completion.list")
    --   local oldhide = require("blink.cmp.completion.list.hide")
    --   local newHide = function()
    --     list.select(nil, opts)
    --     oldhide()
    --   end
    --   list["hide"] = newHide
    -- end,
    --
    dependencies = {

      -- add source
      {
        "PasiBergman/cmp-nuget",
        ft = { "cs_project", "fsharp_project" }, -- optional but good to have
        opts = {}, -- needed
      },
      { "L3MON4D3/LuaSnip", version = "v2.*" },
    },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {

      snippets = {
        preset = "luasnip",

        -- expand = function(snippet, _)
        --   return LazyVim.cmp.expand(snippet)
        -- end,

        -- This comes from the luasnip extra, if you don't add it, won't be able to
        -- jump forward or backward in luasnip snippets
        -- https://www.lazyvim.org/extras/coding/luasnip#blinkcmp-optional
        expand = function(snippet)
          require("luasnip").lsp_expand(snippet)
        end,
        active = function(filter)
          if filter and filter.direction then
            return require("luasnip").jumpable(filter.direction)
          end
          return require("luasnip").in_snippet()
        end,
        jump = function(direction)
          require("luasnip").jump(direction)
        end,
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
        ghost_text = {
          enabled = vim.g.ai_cmp,
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
      },

      -- experimental signature help support
      signature = { enabled = true },

      cmdline = {
        sources = {},
      },

      sources = {
        -- adding any nvim-cmp sources here will enable them
        -- with blink.compat
        compat = { "nuget" },
        default = {
          "lsp",
          "path",
          "snippets",
          "lazydev",
          "buffer",
          "nuget",
          "obsidian",
          "obsidian_new",
          "obsidian_tags",
        },
        providers = {

          obsidian = {
            name = "obsidian",
            module = "blink.compat.source",
          },
          obsidian_new = {
            name = "obsidian_new",
            module = "blink.compat.source",
          },
          obsidian_tags = {
            name = "obsidian_tags",
            module = "blink.compat.source",
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100, -- show at a higher priority than lsp
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
