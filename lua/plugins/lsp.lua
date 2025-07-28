local vim = vim
local util = require("config.util")

---@return ConnectionParams[]
local function LoadSqlPersistenceJsonFile(path)
  ---@type ConnectionParams[]
  local conns = {}

  if not vim.uv.fs_stat(path) then
    return {}
  end
  local lines = {}
  for line in io.lines(path) do
    if not vim.startswith(vim.trim(line), "//") then
      table.insert(lines, line)
    end
  end

  local contents = table.concat(lines, "\n")
  local ok, data = pcall(vim.fn.json_decode, contents)
  if not ok then
    error('Could not parse json file: "' .. path .. '".')
    return {}
  end

  for _, conn in pairs(data) do
    if type(conn) == "table" then
      table.insert(conns, conn)
    end
  end

  return conns
end

local function LoadSqlPersistenceAndSetSqlLanguageServerConnectionSettings()
  local conns = LoadSqlPersistenceJsonFile(vim.fn.stdpath("state") .. "/dbee/persistence.json")
  if #conns == 0 then
    return
  end
  local mapFromDbeeTypeToDriverNameForSqlLanguageServer = {
    sqlserver = "mssql",
    mysql = "mysql",
    pgsql = "postgressql",
    sqlite = "sqlite3",
  }
  local function lookupDriverName(dbeeType)
    return mapFromDbeeTypeToDriverNameForSqlLanguageServer[dbeeType] or dbeeType
  end
  local connections = {}
  for _, conn in pairs(conns) do
    table.insert(connections, { alias = conn.name, driver = lookupDriverName(conn.type), dataSourceName = conn.url })
  end

  return connections
end

vim.api.nvim_create_user_command("LspShutdownAll", function()
  if vim.lsp.get_clients then
    vim.lsp.stop_client(vim.lsp.get_clients(), true)
  else
    vim.lsp.stop_client(vim.lsp.get_active_clients(), true)
  end
end, {})

vim.api.nvim_create_user_command("LspShutdownAllOnCurrentBuffer", function()
  if vim.lsp.get_clients then
    vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = 0 }), true)
  else
    vim.lsp.stop_client(vim.lsp.get_active_clients({ buffer = 0 }), true)
  end
end, {})

OnAttach =
  ---@param client vim.lsp.Client
  ---@param buffer integer
  function(client, buffer)
    if client.name == "msbuild_project_tools_server" then
      client.server_capabilities.completionProvider = {
        triggerCharacters = { "<", '"' },
      }
    end

    if client.name == "rzls" then
      client.server_capabilities.foldingRangeProvider = false
    end
    if client.name == "ionide" then
      client.server_capabilities.documentFormattingProvider = false
    end
    if client.name == "sqls" then
      client.server_capabilities.documentFormattingProvider = false
      require("sqls").on_attach(client, buffer)
    end
    if client.name == "csharp_ls" or client.name == "roslyn" then
      if client.supports_method(require("vim.lsp.protocol").Methods.textDocument_diagnostic) then
        vim.api.nvim_create_autocmd("BufEnter", {
          buffer = buffer,
          callback = function()
            require("vim.lsp.util")._refresh(
              require("vim.lsp.protocol").Methods.textDocument_diagnostic,
              { only_visible = true, client_id = client.id }
            )
          end,
        })
      end
    end
  end

return {
  "neovim/nvim-lspconfig",

  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
  },
  init = function()
    vim.treesitter.language.register("xml", { "fsharp_project" })

    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    keys[#keys + 1] = {
      "K",
      function()
        if require("lazyvim.util").has("hover.nvim") then
          require("hover").hover()
        else
          vim.lsp.buf.hover()
        end
      end,
      "Hover",
    }
    keys[#keys + 1] = {
      "<leader>laa",
      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").code_action()
        else
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Code Action",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>laf",

      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").apply_first()
        else
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Apply first Code Action",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>larr",

      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").refactor()
        else
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Refactor",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>lari",
      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").refactor_inline()
        else
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Refactor Inline",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>lare",
      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").refactor_extract()
        else
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Refactor extract",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>larw",

      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").refactor_rewrite()
        else
          -- vim.lsp.buf.hover()
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Refactor rewrite",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>lcr",
      function()
        vim.lsp.codelens.clear()
        vim.lsp.codelens.refresh()
      end,
      desc = "Codelens Clear and Refresh",
      mode = "n",
    }
    keys[#keys + 1] = {
      "<leader>lf",
      function()
        require("lazyvim.util").format.format({ force = true })
      end,
      desc = "Format Document",
    }
    keys[#keys + 1] = {
      "<leader>lF",
      function()
        require("lazyvim.util").format.info()
      end,
      desc = "Get LazyVim formatter info about the current buffer",
    }
    keys[#keys + 1] = {
      "<leader>lf",
      function()
        require("lazyvim.util").format.format({ force = true })
      end,
      desc = "Format Range",

      mode = "v",
    }
    keys[#keys + 1] = {
      "<leader>ld",
      function()
        vim.diagnostic.open_float()
      end,
      desc = "Line Diagnostics",
    }
    if require("lazyvim.util").has("inc-rename.nvim") then
      keys[#keys + 1] = {
        "<leader>lr",
        function()
          require("inc_rename")
          return ":IncRename " .. vim.fn.expand("<cword>")
        end,
        expr = true,
        desc = "Rename",
      }
    else
      keys[#keys + 1] = { "<leader>lr", vim.lsp.buf.rename, desc = "Rename" }
    end
    -- disable a keymap
    -- keys[#keys + 1] = { "K", false }
    -- add a keymap
    -- keys[#keys + 1] = { "H", "<cmd>echo 'hello'<cr>" }
  end,
  ---@type PluginLspOpts
  opts = {
    inlay_hints = { enabled = true },
    codelens = {
      enabled = true,
    },
    capabilities = {
      workspace = {
        fileOperations = {
          didRename = true,
          willRename = true,
        },
      },
      textDocument = {
        foldingRange = {
          -- dynamicRegistration = false,
          lineFoldingOnly = true,
        },
      },
    },
    -- options for vim.diagnostic.config()
    ---@type vim.diagnostic.Opts
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = { spacing = 4, prefix = "●" },
      severity_sort = true,
    },
    format = {
      timeout_ms = 1000,
    },

    config = function(_, opts)
      local lspconfig = require("lspconfig")
      for server, config in pairs(opts.servers) do
        -- passing config.capabilities to blink.cmp merges with the capabilities in your
        -- `opts[server].capabilities, if you've defined it
        config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end
    end,

    ---@type lspconfig.options
    servers = {
      msbuild_project_tools_server = {
        ft = { "csproj", "fsharp_project" },
        cmd = { "dotnet", "c:/.local/share/language-servers/msbuild/MSBuildProjectTools.LanguageServer.Host.dll" },
        on_attach = function(client, bufnr)
          vim.notify("msbuild_project_tools_server attached")
          vim.notify(vim.inspect(client.server_capabilities))
          OnAttach(client, bufnr)
        end,
      },
      bashls = {
        mason = false,
      },
      sqls = {
        cmd = { "sqls" },

        on_attach = function(client, bufnr)
          OnAttach(client, bufnr)
        end,
        settings = {
          sqls = {
            connections = LoadSqlPersistenceAndSetSqlLanguageServerConnectionSettings(),
          },
        },
      },
    },
    -- you can do any additional lsp server setup here
    -- return true if you don't want this server to be setup with lspconfig
    ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
    setup = {
      fsautocomplete = function(_, opts)
        return true
      end,
      -- example to setup with typescript.nvim
      -- tsserver = function(_, opts)
      --   require("typescript").setup({ server = opts })
      --   return true
      -- end,
      -- Specify * to use this function as a fallback for any server
      -- ["*"] = function(server, opts) end,
    },
  },
}
