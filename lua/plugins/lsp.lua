local vim = vim
-- local fn = vim.fn
-- local rootSwitchSecondsInterval = 5
-- vim.g["LspRootSwitchLastAskedTime"] = 0
-- local lastAskedTime = vim.g["LspRootSwitchLastAskedTime"]
-- local tc = vim.tbl_contains
-- local util = require("config.util")

---returns a copy of the string where the first letter found is set to upper case
-- ---@param str any
-- ---@return string
-- local function first_to_upper(str)
--   return str:gsub("^%l", string.upper)
-- end

---this should grab the correct lsp root of whatever buf is passed in.
-- -@param ignored_lsp_servers table<string>
-- -@param client lsp.Client
-- -@param bufnr number
-- -@return string
-- function FindRoot(ignored_lsp_servers, client, bufnr)
--   local b = bufnr or 0
--   local ignore = ignored_lsp_servers or {}
--   local buf_ft = vim.api.nvim_buf_get_option(b, "filetype")
--   local result
--   local i = ignore or {}
--   local cname = client.name
--   local filetypes = (function()
--     if client.config.filetypes then
--       return client.config.filetypes
--     else
--       return {}
--     end
--   end)()
--   if filetypes and vim.tbl_contains(filetypes, buf_ft) then
--     if not vim.tbl_contains(i, cname) then
--       local rootDirFunction = client.config.get_root_dir
--       local activeConfigRootDir = client.config.root_dir
--       if activeConfigRootDir then
--         result = first_to_upper(vim.fs.normalize(activeConfigRootDir))
--       end
--     end
--   end
--   return result
-- end

vim.api.nvim_create_user_command("LspShutdownAll", function()
  vim.lsp.stop_client(vim.lsp.get_active_clients(), true)
end, {})

vim.api.nvim_create_user_command("LspShutdownAllOnCurrentBuffer", function()
  vim.lsp.stop_client(vim.lsp.get_active_clients({ buffer = 0 }), true)
end, {})

OnAttach =
  ---@param client lsp.Client
  ---@param buffer integer
  function(client, buffer)
    -- vim.notify(client.name .. " is running OnAttach")
    -- local ft = vim.api.nvim_buf_get_option(0, "filetype")
    -- local Util = require("lazyvim.util")
    -- local isDotnet = ft == "cs" or ft == "fsharp" or ft == "fsharp_project"
    -- -- local isDotnetProj = vim.api.nvim_buf_get_option(0, "")
    -- local ignored = { "jsonls", "null-ls", "stylua", "editorconfig_checker" }
    -- -- local ignored = v.lsp.ignoredLspServersForFindingRoot
    -- -- v.notify(client.name .. " is running on_attach")
    -- -- v.notify(vim.inspect(ignored) .. " are servers being ignored")
    -- -- local on_attach_override = user_plugin_opts("lsp.on_attach", nil, false)
    -- -- conditional_func(on_attach_override, true, client, bufnr)
    -- -- local capabilities = client.server_capabilities
    -- -- vim.notify(client.name .. " is running on_attach")
    -- if not tc(ignored, client.name) then
    --   -- if client.name ~= "null-ls" and client.name ~= "stylua" and client.name ~= "lemminx" then
    --   -- local root = FindRoot(ignored, bufnr)
    --   local root = FindRoot(ignored, client, buffer)
    --   -- v.notify("lsp root should have found root of : " .. root)
    --   local cwd = first_to_upper(vim.fs.normalize(fn.getcwd()))
    --   if not root then
    --     vim.notify(
    --       "lsp says it didn't find a root??? I'd go check that one out.. setting temporary root to current buffer's parent dir, but don't think that means that lsp is healthy right now.. you've been warned! "
    --     )
    --     root = first_to_upper(vim.fs.normalize(vim.fn.expand("%:p:h")))
    --   end
    --   local path = require("plenary.path")
    --   local rootpath = path:new(root)
    --   local cwdpath = path:new(cwd)
    --   local notEqual = rootpath.filename ~= cwdpath.filename
    --   -- v.notify("i have the root and cwd now.. but ill check the number of buffers.. ")
    --   local recentlyAsked = lastAskedTime and os.difftime(os.time(), lastAskedTime) < rootSwitchSecondsInterval
    --   local shouldAsk = vim.tbl_count(fn.getbufinfo({ buflisted = true })) > 1 and recentlyAsked == false
    --   if notEqual then
    --     if shouldAsk == true then
    --       -- v.notify("at this point the buffers say i should ask about setting root.. " .. vim.inspect(shouldAsk))
    --       if
    --         fn.confirm(
    --           "Do you want to change the current working directory to lsp root?  \n  ROOT: "
    --             .. root
    --             .. "  \n  CWD : "
    --             .. cwd
    --             .. "  \n",
    --           "&yes\n&no",
    --           2
    --         ) == 1
    --       then
    --         vim.cmd("cd " .. root)
    --         vim.notify("CWD : " .. root)
    --       end
    --     else
    --       vim.cmd("cd " .. root)
    --       vim.notify("CWD : " .. root)
    --     end
    --     if isDotnet then
    --       vim.g["DotnetSlnRootPath"] = root
    --     end
    --   end
    -- end

    -- if client.name == "lemminx" then
    --   -- vim.notify(" on attach for " .. client.name .. " just got called")
    --
    --   -- local capabilities = client.server_capabilities
    -- end
    --     vim.notify(" on attach for " .. client.name .. " just got called")
    --     if client.name == "ionide" then
    --       local inp = vim.fn.input("please attach debugger")
    --     end
    --     -- local normalCaps = vim.lsp.protocol.make_client_capabilities()
    --     -- print("client " .. client.name .. " has capability " .. vim.inspect(normalCaps))
    --     local capabilities = client.server_capabilities
    --     -- print("client " .. client.name .. " has capability " .. vim.inspect(capabilities))
    --     -- if capabilities.hoverProvider then
    --     --   if require("lazyvim.util").has("hover.nvim") then
    --     --     vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
    --     --     -- vim.keymap.set ("n", "K", require("hover").hover, {desc = "hover.nvim" })
    --     --     -- lsp_mappings.n["gK"] = { require("hover").hover_select, desc = "Hover symbol details (select)" }
    --     --     -- else
    --     --     --   lsp_mappings.n["K"] = {
    --     --     --     function()
    --     --     --       vim.lsp.buf.hover()
    --     --     --     end,
    --     --     --     desc = "Hover symbol details",
    --     --     --   }
    --     --   end
    --     -- end

    if client.name == "jsonls" then
      if vim.bo.filetype == "json" then
        vim.bo.syntax = "jsonc"
        vim.bo.filetype = "jsonc"
      end
      -- vim.lsp.buf.format()
    end
    if client.name == "omnisharp" then
      client.server_capabilities.semanticTokensProvider = {
        full = vim.empty_dict(),
        legend = {
          tokenModifiers = { "static_symbol" },
          tokenTypes = {
            "comment",
            "excluded_code",
            "identifier",
            "keyword",
            "keyword_control",
            "number",
            "operator",
            "operator_overloaded",
            "preprocessor_keyword",
            "string",
            "whitespace",
            "text",
            "static_symbol",
            "preprocessor_text",
            "punctuation",
            "string_verbatim",
            "string_escape_character",
            "class_name",
            "delegate_name",
            "enum_name",
            "interface_name",
            "module_name",
            "struct_name",
            "type_parameter_name",
            "field_name",
            "enum_member_name",
            "constant_name",
            "local_name",
            "parameter_name",
            "method_name",
            "extension_method_name",
            "property_name",
            "event_name",
            "namespace_name",
            "label_name",
            "xml_doc_comment_attribute_name",
            "xml_doc_comment_attribute_quotes",
            "xml_doc_comment_attribute_value",
            "xml_doc_comment_cdata_section",
            "xml_doc_comment_comment",
            "xml_doc_comment_delimiter",
            "xml_doc_comment_entity_reference",
            "xml_doc_comment_name",
            "xml_doc_comment_processing_instruction",
            "xml_doc_comment_text",
            "xml_literal_attribute_name",
            "xml_literal_attribute_quotes",
            "xml_literal_attribute_value",
            "xml_literal_cdata_section",
            "xml_literal_comment",
            "xml_literal_delimiter",
            "xml_literal_embedded_expression",
            "xml_literal_entity_reference",
            "xml_literal_name",
            "xml_literal_processing_instruction",
            "xml_literal_text",
            "regex_comment",
            "regex_character_class",
            "regex_anchor",
            "regex_quantifier",
            "regex_grouping",
            "regex_alternation",
            "regex_text",
            "regex_self_escaped_character",
            "regex_other_escape",
          },
        },
        range = true,
      }
    end
  end

return {
  "neovim/nvim-lspconfig",
  init = function()
    -- vim.notify("entered lspconfig init func, doing keymaps now. ")
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    -- change a keymap
    -- keys[#keys + 1] = { "K", "<cmd>echo 'hello'<cr>" }
    keys[#keys + 1] = {
      "K",
      function()
        -- vim.notify("I'm printing for hover")
        if require("lazyvim.util").has("hover.nvim") then
          -- vim.notify("I have hover.nvim")
          require("hover").hover()
        else
          -- vim.notify("I do not have hover.nvim, defaulting to vim.lsp.buf.hover()")
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
          -- vim.lsp.buf.hover()
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
          -- vim.lsp.buf.hover()
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
          -- vim.lsp.buf.hover()
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
          -- vim.lsp.buf.hover()
          vim.lsp.buf.code_action()
        end
      end,
      desc = "Refactor Inline",
      mode = { "n", "v" },
    }
    keys[#keys + 1] = {
      "<leader>lari",

      function()
        if require("lazyvim.util").has("clear-action.nvim") then
          require("clear-action.actions").refactor_inline()
        else
          -- vim.lsp.buf.hover()
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
          -- vim.lsp.buf.hover()
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
      -- has = "codeAction",
      -- has = "codeAction",
    }
    keys[#keys + 1] = {
      "<leader>lf",
      function()
        require("lazyvim.util").format.format({ force = true })
      end,
      desc = "Format Document",
      -- has = "documentFormatting",
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
    -- keys[#keys + 1] = { "<leader>lI", "<cmd>LspRestart<cr>", desc = "Lsp Reinit" }

    if require("lazyvim.util").has("inc-rename.nvim") then
      keys[#keys + 1] = {
        "<leader>lr",
        function()
          require("inc_rename")
          return ":IncRename " .. vim.fn.expand("<cword>")
        end,
        expr = true,
        desc = "Rename",
        -- has = "rename",
      }
    else
      -- keys[#keys + 1] = { "<leader>lr", vim.lsp.buf.rename, desc = "Rename", has = "rename" }
      keys[#keys + 1] = { "<leader>lr", vim.lsp.buf.rename, desc = "Rename" }
    end
    -- keys[#keys + 1] = { "<leader>ll", "<cmd>LspLog<cr>" }
    -- keys[#keys + 1] = { "<leader>ll", "<cmd>LspLog<cr>" }
    -- keys[#keys + 1] = { "<leader>ll", "<cmd>LspLog<cr>" }
    -- keys[#keys + 1] = { "<leader>ll", "<cmd>LspLog<cr>" }
    -- keys[#keys + 1] = {
    --   "<leader>li",
    --   function()
    --     require("lspconfig.ui.lspinfo")()
    --   end,
    --   "LSP Info",
    -- }
    -- keys[#keys + 1] = {
    --   "<leader>lk",
    --   function()
    --     vim.fn.writefile({}, vim.lsp.get_log_path())
    --   end,
    --   "reset LSP log",
    -- }
    -- disable a keymap
    -- keys[#keys + 1] = { "K", false }
    -- add a keymap
    -- keys[#keys + 1] = { "H", "<cmd>echo 'hello'<cr>" }
  end,
  opts = {
    capabilities = {
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true,
        },
      },
    },
    -- options for vim.diagnostic.config()
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = { spacing = 4, prefix = "●" },
      -- virtual_text = { spacing = 4, prefix = "●" },
      severity_sort = true,
    },
    -- Automatically format on save
    -- autoformat = true,
    -- options for vim.lsp.buf.format
    -- `bufnr` and `filter` is handled by the LazyVim formatter,
    -- but can be also overridden when specified
    format = {
      -- formatting_options = nil,

      -- timeout_ms = 10000,
      timeout_ms = 1000,
    },

    -- LSP Server Settings
    --      ---@type lspconfig.options
    servers = {

      -- vimls = {},
      -- ---@type lspconfig.options.jsonls
      -- jsonls = {
      --   settings = {
      --     json = {
      --       -- format ={
      --       -- enable},
      --       validate = {
      --         enable = true,
      --       },
      --     },
      --   },
      -- },

      -- all seperate lsp servers have thier own setup files, for clarity
    },
    -- you can do any additional lsp server setup here
    -- return true if you don't want this server to be setup with lspconfig
    ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
    -- setup = {

    -- all seperate lsp servers have thier own setup files, for clarity
    -- },

    on_attach = require("lazyvim.util").lsp.on_attach(OnAttach),
  },
  -- },
}
