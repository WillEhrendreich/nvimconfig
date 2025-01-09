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

      -- add source
      {
        "PasiBergman/cmp-nuget",
        ft = { "cs_project", "fsharp_project" }, -- optional but good to have
        opts = {}, -- needed
      },
    },
    opts = {

      snippets = {
        expand = function(snippet, _)
          return LazyVim.cmp.expand(snippet)
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
      },

      -- experimental signature help support
      signature = { enabled = true },

      sources = {
        -- adding any nvim-cmp sources here will enable them
        -- with blink.compat
        compat = { "nuget" },
        default = { "lsp", "path", "snippets", "buffer", "nuget" },
        cmdline = {},
        providers = {
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
        ["<C-y>"] = { "select_and_accept" },
        ["<Down>"] = {
          "select_next",
        },
        ["<C-n>"] = {
          function(cmp)
            if not cmp.is_visible() then
              cmp.show()
              return true
            end -- runs the next command
          end,
          "select_next",
        },
        ["<Up>"] = {
          "select_prev",
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
