return {
  "PasiBergman/cmp-nuget",
  -- config = function()
  opts = function(_, opts)
    return vim.tbl_deep_extend("force", opts, {
      filetypes = { "fsharp_project", "csproj" }, -- on which filetypes cmp-nuget is active
      file_extensions = { "csproj", "fsproj" }, -- on which file extensions cmp-nuget is active
      nuget = {
        packages = {
          -- configuration for searching packages
          limit = 20, -- limit package serach to first 100 packages
          prerelease = true, -- include prerelase (preview, rc, etc.) packages
          sem_ver_level = "2.0.0", -- semantic version level (*
          package_type = "", -- package type to use to filter packages (*
        },
        versions = {
          prerelease = true, -- include prerelase (preview, rc, etc.) versions
          sem_ver_level = "2.0.0", -- semantic version level (*
        },
      },
    })
  end,
}
