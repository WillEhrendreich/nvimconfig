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
    version = "0.*",
    dependencies = {
      -- add source
      {
        "PasiBergman/cmp-nuget",
        ft = { "cs_project", "fsharp_project" }, -- optional but good to have
        opts = {}, -- needed
      },
    },
    sources = {
      completion = {
        -- remember to enable your providers here
        enabled_providers = { "lsp", "path", "snippets", "buffer", "nuget" },
      },

      providers = {
        -- create provider
        digraphs = {
          name = "nuget", -- IMPORTANT: use the same name as you would for nvim-cmp
          module = "blink.compat.source",

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
  },
}
