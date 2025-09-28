local util = require("config.util")
---@class _.lspconfig.options
---@field root_dir fun(filename, bufnr): string|nil
---@field name string
---@field filetypes string[] | nil
---@field autostart boolean
---@field single_file_support boolean
---@field on_new_config fun(new_config, new_root_dir)
---@field capabilities table
---@field cmd string[]
---@field handlers table<string, fun()>
---@field init_options table
---@field on_attach fun(client, bufnr)

-- if require("lazyvim.util").has("ionide") then
print("Ionide is installed, proceeding with setup ")

local ionide = require("ionide")
local r = {
  IonideNvimSettings = {
    -- LspRecommendedColorScheme = true,
    EnableFsiStdOutTeeToFile = true,
    ShowSignatureOnCursorMove = false,
    FsiStdOutFileName = "./FsiOutput.txt",
  },
  root_markers = { "*.slnx", "*.sln", "*.fsproj", ".git" },
  filetypes = { "fsharp", "fsharp_project" },
  cmd = { "fsautocomplete" },
  --   util.getMasonBinCommandIfExists("fsautocomplete"),
  settings = {
    FSharp = {
      enableMSBuildProjectGraph = true,
      -- enableTreeView = true,
      -- fsiExtraParameters = {
      --   "--compilertool:C:/Users/Will.ehrendreich/.dotnet/tools/.store/depman-fsproj/0.2.6/depman-fsproj/0.2.6/tools/net7.0/any",
      -- },
    },
  },
}

--
return ionide.setup(r)
-- else
--   print("Ionide not installed")
-- end
