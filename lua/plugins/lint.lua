-- markdownlint-cli2 only discovers config files from the linted file's directory
-- upward to the working directory, so a global one never applies and every
-- markdown buffer arrives with the full default ruleset. Point it at the repo's
-- own config when there is one, and at the one shipped beside this config otherwise.
local project_config_names = {
  ".markdownlint-cli2.jsonc",
  ".markdownlint-cli2.yaml",
  ".markdownlint-cli2.cjs",
  ".markdownlint.jsonc",
  ".markdownlint.json",
  ".markdownlint.yaml",
  ".markdownlint.yml",
}

local function markdownlint_config()
  local buffer_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  if buffer_dir ~= "" then
    local found = vim.fs.find(project_config_names, { upward = true, path = buffer_dir, type = "file" })[1]
    if found then
      return found
    end
  end
  return vim.fs.joinpath(vim.fn.stdpath("config"), "markdownlint-cli2.jsonc")
end

return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = function()
    require("lint").linters["markdownlint-cli2"].args = { "--config", markdownlint_config, "-" }
  end,
}
