return {
  "hrsh7th/nvim-cmp",

  dependencies = {

    {
      "PasiBergman/cmp-nuget",
      ft = { "cs_project", "fsharp_project" }, -- optional but good to have
      opts = {}, -- needed
    },
  },

  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    local nuget = require("cmp-nuget")
    nuget.setup({})

    table.insert(opts.sources, 1, {
      name = "nuget",
    })

    opts.formatting.format = function(entry, vim_item)
      if entry.source.name == "nuget" then
        vim_item.kind = "NuGet"
      end
      return vim_item
    end
  end,
}
