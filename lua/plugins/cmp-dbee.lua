return {

  "hrsh7th/nvim-cmp",
  dependencies = {
    {
      "MattiasMTS/cmp-dbee",
      dependencies = {
        { "kndndrj/nvim-dbee" },
      },
      ft = "sql", -- optional but good to have
      opts = {}, -- needed
    },
  },
  opts = function(_, opts)
    table.insert(opts.sources, 1, { name = "dbee" })
    opts.formatting.format = function(entry, vim_item)
      if entry.source.name == "dbee" then
        vim_item.kind = "Dbee"
      end
      return vim_item
    end
  end,
}
