local cmp = require("cmp")
local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

return {

  -- Use <tab> for completion and snippets (supertab)
  -- first: disable default <tab> and <s-tab> behavior in LuaSnip
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    config = function()
      -- re "configs.luasnip"
      local ls = require("luasnip")
      local types = require("luasnip.util.types")
      local ext_util = require("luasnip.util.ext_opts")
      local ft_functions = require("luasnip.extras.filetype_functions")
      local session = require("luasnip.session")
      local iNode = require("luasnip.nodes.insertNode")
      local cNode = require("luasnip.nodes.choiceNode")

      -- Inserts a insert(1) before all other nodes, decreases node.pos's as indexing is "wrong".
      local function modify_nodes(snip)
        for i = #snip.nodes, 1, -1 do
          snip.nodes[i + 1] = snip.nodes[i]
          local node = snip.nodes[i + 1]
          if node.pos then
            node.pos = node.pos + 1
          end
        end
        snip.nodes[1] = iNode.I(1)
      end

      ls.add_snippets("lua", {
        ls.parser.parse_snippet("func", "function ${1}(${2}) \n\n\t${3}\nend"),
      })

      ls.add_snippets("cs", {
        ls.parser.parse_snippet("func", "public  ${1} ${2} (${3})\n{\n\t${4}\n}"),
      })

      ls.add_snippets("razor", {
        ls.parser.parse_snippet("tag", "<${1}>\n\t${2}\n</${1}>"),
      })

      ls.config.setup({
        history = false,
        update_events = "InsertLeave",
        -- see :h User, event should never be triggered(except if it is `doautocmd`'d)
        -- region_check_events = "User None",
        -- delete_check_events = "User None",
        store_selection_keys = nil, -- Supossed to be the same as the expand shortcut
        ext_opts = {
          [types.textNode] = {
            active = { hl_group = "LuasnipTextNodeActive" },
            passive = { hl_group = "LuasnipTextNodePassive" },
            visited = { hl_group = "LuasnipTextNodeVisited" },
            unvisited = { hl_group = "LuasnipTextNodeUnvisited" },
            snippet_passive = { hl_group = "LuasnipTextNodeSnippetPassive" },
          },
          [types.insertNode] = {
            active = { hl_group = "LuasnipInsertNodeActive" },
            passive = { hl_group = "LuasnipInsertNodePassive" },
            visited = { hl_group = "LuasnipInsertNodeVisited" },
            unvisited = { hl_group = "LuasnipInsertNodeUnvisited" },
            snippet_passive = {
              hl_group = "LuasnipInsertNodeSnippetPassive",
            },
          },
          [types.exitNode] = {
            active = { hl_group = "LuasnipExitNodeActive" },
            passive = { hl_group = "LuasnipExitNodePassive" },
            visited = { hl_group = "LuasnipExitNodeVisited" },
            unvisited = { hl_group = "LuasnipExitNodeUnvisited" },
            snippet_passive = { hl_group = "LuasnipExitNodeSnippetPassive" },
          },
          [types.functionNode] = {
            active = { hl_group = "LuasnipFunctionNodeActive" },
            passive = { hl_group = "LuasnipFunctionNodePassive" },
            visited = { hl_group = "LuasnipFunctionNodeVisited" },
            unvisited = { hl_group = "LuasnipFunctionNodeUnvisited" },
            snippet_passive = {
              hl_group = "LuasnipFunctionNodeSnippetPassive",
            },
          },
          [types.snippetNode] = {
            active = { hl_group = "LuasnipSnippetNodeActive" },
            passive = { hl_group = "LuasnipSnippetNodePassive" },
            visited = { hl_group = "LuasnipSnippetNodeVisited" },
            unvisited = { hl_group = "LuasnipSnippetNodeUnvisited" },
            snippet_passive = {
              hl_group = "LuasnipSnippetNodeSnippetPassive",
            },
          },
          [types.choiceNode] = {
            active = { hl_group = "LuasnipChoiceNodeActive" },
            passive = { hl_group = "LuasnipChoiceNodePassive" },
            visited = { hl_group = "LuasnipChoiceNodeVisited" },
            unvisited = { hl_group = "LuasnipChoiceNodeUnvisited" },
            snippet_passive = {
              hl_group = "LuasnipChoiceNodeSnippetPassive",
            },
          },
          [types.dynamicNode] = {
            active = { hl_group = "LuasnipDynamicNodeActive" },
            passive = { hl_group = "LuasnipDynamicNodePassive" },
            visited = { hl_group = "LuasnipDynamicNodeVisited" },
            unvisited = { hl_group = "LuasnipDynamicNodeUnvisited" },
            snippet_passive = {
              hl_group = "LuasnipDynamicNodeSnippetPassive",
            },
          },
          [types.snippet] = {
            active = { hl_group = "LuasnipSnippetActive" },
            passive = { hl_group = "LuasnipSnippetPassive" },
            -- not used!
            visited = { hl_group = "LuasnipSnippetVisited" },
            unvisited = { hl_group = "LuasnipSnippetUnvisited" },
            snippet_passive = { hl_group = "LuasnipSnippetSnippetPassive" },
          },
          [types.restoreNode] = {
            active = { hl_group = "LuasnipRestoreNodeActive" },
            passive = { hl_group = "LuasnipRestoreNodePassive" },
            visited = { hl_group = "LuasnipRestoreNodeVisited" },
            unvisited = { hl_group = "LuasnipRestoreNodeUnvisited" },
            snippet_passive = {
              hl_group = "LuasnipRestoreNodeSnippetPassive",
            },
          },
        },
        ext_base_prio = 200,
        ext_prio_increase = 9,
        enable_autosnippets = false,
        -- default applied in util.parser, res iNode, cNode
        -- (Dependency cycle if here).
        parser_nested_assembler = function(pos, snip)
          modify_nodes(snip)
          snip:init_nodes()
          snip.pos = nil

          return cNode.C(pos, { snip, iNode.I(nil, { "" }) })
        end,
        -- Function expected to return a list of filetypes (or empty list)
        ft_func = ft_functions.from_filetype,
        -- fn(bufnr) -> string[] (filetypes).
        load_ft_func = ft_functions.from_filetype_load,
        -- globals injected into luasnippet-files.
        snip_env = {
          s = require("luasnip.nodes.snippet").S,
          sn = require("luasnip.nodes.snippet").SN,
          isn = require("luasnip.nodes.snippet").ISN,
          t = require("luasnip.nodes.textNode").T,
          i = require("luasnip.nodes.insertNode").I,
          f = require("luasnip.nodes.functionNode").F,
          c = require("luasnip.nodes.choiceNode").C,
          d = require("luasnip.nodes.dynamicNode").D,
          r = require("luasnip.nodes.restoreNode"),
          events = require("luasnip.util.events"),
          ai = require("luasnip.nodes.absolute_indexer"),
          extras = require("luasnip.extras"),
          l = require("luasnip.extras").lambda,
          rep = require("luasnip.extras").rep,
          p = require("luasnip.extras").partial,
          m = require("luasnip.extras").match,
          n = require("luasnip.extras").nonempty,
          dl = require("luasnip.extras").dynamic_lambda,
          fmt = require("luasnip.extras.fmt").fmt,
          fmta = require("luasnip.extras.fmt").fmta,
          conds = require("luasnip.extras.expand_conditions"),
          postfix = require("luasnip.extras.postfix").postfix,
          types = require("luasnip.util.types"),
          parse = require("luasnip.util.parser").parse_snippet,
        },
      })

      vim.tbl_map(function(type)
        require("luasnip.loaders.from_" .. type).lazy_load()
      end, { "vscode", "snipmate", "lua" })
    end,
    dependencies = { "rafamadriz/friendly-snippets" },
    keys = function()
      return {}
    end,
  },
  -- then: setup supertab in cmp
  {
    -- "yioneko/nvim-cmp",
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",

      -- {
      --   "kola-web/cmp-path",
      -- },

      -- "jcdickinson/codeium.nvim",
      -- "willehrendreich/codeium.nvim",

      {

        "hrsh7th/cmp-cmdline",
        dependencies = {
          "hrsh7th/cmp-nvim-lsp-document-symbol",
        },
        config = function()
          cmp.setup.cmdline("/", {
            -- mapping = cmp.mapping.preset.cmdline(),
            sources = {
              { name = "nvim_lsp_document_symbol" },
            },
            {
              { name = "buffer" },
            },
          })

          cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline({
              ["<Tab>"] = function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                else
                  cmp.complete()
                  fallback()
                  -- completeAndInsertFirstMatch()
                end
              end,
              ["<S-Tab>"] = function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                else
                  fallback()
                end
              end,
            }),
            sources = cmp.config.sources({
              {
                name = "cmdline",
                option = {
                  ignore_cmds = { "Man", "!" },
                },
              },
            }, {
              --   {
              --     name = "path",
              --     option = {
              --       trailing_slash = true,
              --       label_trailing_slash = true,
              --     },
              --   },
            }),
          })
        end,
      },

      -- "hrsh7th/cmp-calc",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      -- "hrsh7th/cmp-emoji",
      {
        -- show completion in dap
        "rcarriga/cmp-dap",

        require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
          sources = {
            { name = "dap" },
          },
        }),
      },
      "L3MON4D3/LuaSnip",
      {
        "PasiBergman/cmp-nuget",
        -- config = function()
        opts = {
          filetypes = { "fsharp_project", "csproj" }, -- on which filetypes cmp-nuget is active
          file_extensions = { "csproj", "fsproj" }, -- on which file extensions cmp-nuget is active
          nuget = {
            packages = {
              -- configuration for searching packages
              limit = 100, -- limit package serach to first 100 packages
              prerelease = true, -- include prerelase (preview, rc, etc.) packages
              sem_ver_level = "2.0.0", -- semantic version level (*
              package_type = "", -- package type to use to filter packages (*
            },
            versions = {
              prerelease = true, -- include prerelase (preview, rc, etc.) versions
              sem_ver_level = "2.0.0", -- semantic version level (*
            },
          },
        },
        -- end,
      },
      "onsails/lspkind.nvim",
      -- {
      -- "rafamadriz/friendly-snippets",
      -- config = function()
      --   require("luasnip.loaders.from_vscode").lazy_load()
      -- end,
      -- },
    },
    opts = function(_, opts)
      -- local cmp = require("cmp")
      -- local luasnip = require("luasnip")
      return vim.tbl_deep_extend("force", opts, {
        performance = {
          trigger_debounce_time = 500,
          throttle = 550,
          fetching_timeout = 80,
        },
        completion = {
          completeopt = "menu,menuone,noinsert,noselect",
          -- completeopt = "menu,menuone,noinsert",
        },
        sources = {
          { name = "luasnip", max_item_count = 4 },
          { name = "nvim_lsp_signature_help" },
          { name = "nvim_lsp" },
          { name = "copilot" },
          { name = "path" },
          { name = "buffer" },
          { name = "nvim_lua" },
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        preselect = cmp.PreselectMode.Item,
        mapping = cmp.mapping({
          -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
          -- they way you will only jump inside the snippet region
          ["<C-j>"] = cmp.mapping({
            i = function()
              if require("luasnip").expand_or_jumpable() then
                require("luasnip").expand_or_jump()
              end
            end,
          }),
          ["<C-k>"] = cmp.mapping({
            i = function()
              if require("luasnip").expand_or_jumpable(-1) then
                require("luasnip").expand_or_jump(-1)
              end
            end,
          }),
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Tab>"] = cmp.mapping.complete({
            config = {
              view = {
                entries = { name = "custom" },
              },
            },
          }),
          ["<C-e>"] = cmp.mapping.abort(),
          -- ["<Esc>"] = function()
          --   if cmp.visible() then
          --     cmp.close()
          --   end
          -- end,
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = false,
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<Tab>"] = cmp.mapping({
            c = function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
                -- completeAndInsertFirstMatch()
              end
            end,
            i = function(fallback)
              -- if cmp.visible() and #cmp.get_entries() > 0 then
              -- cmp.select_next_item()
              -- cmp.select_prev_item()
              -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
              -- they way you will only jump inside the snippet region
              -- elseif require('luasnip').expand_or_jumpable() then
              --   require('luasnip').expand_or_jump()
              -- elseif cmp.visible() then
              if cmp.visible() then
                cmp.select_next_item()
                -- elseif has_words_before() then
                --   completeAndInsertFirstMatch()
              elseif has_words_before() then
                cmp.complete()
                cmp.select_next_item()
              else
                fallback()
              end
            end,
            -- s = function(fallback)
            --   if cmp.visible() then
            --     cmp.select_next_item()
            --     -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            --     -- they way you will only jump inside the snippet region
            --   elseif require("luasnip").expand_or_jumpable() then
            --     require("luasnip").expand_or_jump()
            --   elseif has_words_before() then
            --     cmp.complete()
            --     cmp.select_next_item()
            --     --     cmp.select_prev_item()
            --     -- completeAndInsertFirstMatch()
            --   else
            --     fallback()
            --   end
            -- end,
          }),

          -- ["<Tab>"] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.select_next_item()
          --   -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
          --   -- they way you will only jump inside the snippet region
          --   elseif luasnip.expand_or_jumpable() then
          --     luasnip.expand_or_jump()
          --   elseif has_words_before() then
          --     cmp.complete()
          --     cmp.select_next_item()
          --     cmp.select_prev_item()
          --   else
          --     fallback()
          --   end
          -- end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping({
            c = function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end,
            i = function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
                -- elseif require('luasnip').jumpable( -1) then
                --   require('luasnip').jump( -1)
              else
                fallback()
              end
            end,
            s = function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
                -- elseif require('luasnip').jumpable( -1) then
                --   require('luasnip').jump( -1)
              else
                fallback()
              end
            end,
          }),
          -- ["<S-Tab>"] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.select_prev_item()
          --   elseif luasnip.jumpable(-1) then
          --     luasnip.jump(-1)
          --   else
          --     fallback()
          --   end
          -- end, { "i", "s" }),
        }),

        -- sources = cmp.config.sources({
        --   -- { name = "codeium", keyword_length = 0 },
        --   -- { name = "jupyter"},
        --   -- { name = "jupynium"},
        --   { name = "luasnip", keyword_length = 0 },
        --   { name = "nvim_lsp", keyword_length = 0 },
        --   { name = "buffer", keyword_length = 5, max_item_count = 10 },
        --   -- { name = "emoji" },
        -- }),
        -- sorting = {
        --   comparators = {
        --     cmp.config.compare.exact,
        --     cmp.config.compare.recently_used,
        --     cmp.config.compare.sort_text,
        --     cmp.config.compare.score,
        --     cmp.config.compare.order,
        --     cmp.config.compare.kind,
        --     cmp.config.compare.offset,
        --     -- require("clangd_extensions.cmp_scores"),
        --     cmp.config.compare.length,
        --   },
        -- },
        formatting = {
          -- format = function(_, item)
          --   local icons = require("lazyvim.config").icons.kinds
          --   if icons[item.kind] then
          --     item.kind = icons[item.kind] .. item.kind
          --   end
          --   return item
          -- end,

          format = require("lspkind").cmp_format({
            mode = "symbol",
            with_text = true,
            maxwidth = 80,
            ellipsis_char = "",
            menu = {
              codeium = "[Cdim]",
              jupyter = "[Jup]",
              buffer = "[Buf]",
              nuget = "[Ngt]",
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              nvim_lua = "[Lua]",
              latex_symbols = "[Ltx]",
            },
          }),
        },
        experimental = {
          native_menu = false,
          ghost_text = {
            enabled = true,
            hl_group = "LspCodeLens",
          },
        },
      })
    end,
  },
  --     -- (
  --     opts = function(_, opts)
  --       -- local has_words_before = function()
  --       --   unpack = unpack or table.unpack
  --       --   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  --       --   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  --       -- end
  --
  --       local border_opts = {
  --         border = "single",
  --         winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
  --       }
  --       local luasnip = require("luasnip")
  --       local lspkind_status_ok, lspkind = pcall(require, "lspkind")
  --       local cmp = require("cmp")
  --
  --       return vim.tbl_extend("force", opts, {
  --
  --         formatting = {
  --           fields = { "kind", "abbr", "menu" },
  --           -- format = lspkind_status_ok and lspkind.cmp_format(lspkind) or nil,
  --           format = function(entry, vim_item)
  --             local kind_icons = {
  --               mode = "symbol",
  --               symbol_map = {
  --                 Array = "",
  --                 Boolean = "⊨",
  --                 Class = "",
  --                 Constructor = "",
  --                 Key = "",
  --                 Namespace = "",
  --                 Null = "NULL",
  --                 Number = "#",
  --                 Object = "",
  --                 Package = "",
  --                 Property = "",
  --                 Reference = "",
  --                 Snippet = "",
  --                 String = "",
  --                 TypeParameter = "",
  --                 Unit = "",
  --               },
  --             }
  --             local prsnt, _ = pcall(require, "lspkind")
  --
  --             if not prsnt then
  --               -- From kind_icons array
  --               vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
  --             else
  --               -- From lspkind
  --               vim_item.menu = ({
  --                 buffer = "[Buf]",
  --                 nvim_lsp = "[LSP]",
  --                 luasnip = "[Snip]",
  --                 nvim_lua = "[Lua]",
  --                 latex_symbols = "[LaTeX]",
  --               })[entry.source.name]
  --               -- return vim_item or nil
  --               return (lspkind.cmp_format(kind_icons))(entry, vim_item) or nil
  --             end
  --             -- Source
  --             vim_item.menu = ({
  --               buffer = "[Buf]",
  --               nvim_lsp = "[LSP]",
  --               luasnip = "[Snip]",
  --               nvim_lua = "[Lua]",
  --               latex_symbols = "[LaTeX]",
  --             })[entry.source.name]
  --             -- return vim_item or nil
  --           end,
  --         },
  --         snippet = {
  --           expand = function(args)
  --             luasnip.lsp_expand(args.body)
  --           end,
  --         },
  --         duplicates = {
  --           nvim_lsp = 1,
  --           luasnip = 1,
  --           cmp_tabnine = 1,
  --           buffer = 1,
  --           path = 1,
  --         },
  --
  --         confirm_opts = { behavior = cmp.ConfirmBehavior.Replace, select = true },
  --         window = {
  --           completion = cmp.config.window.bordered(border_opts),
  --           documentation = cmp.config.window.bordered(border_opts),
  --         },
  --         -- preselect = cmp.PreselectMode.None,
  --
  --         mapping = {
  --
  --
  --           -- ["<Cr>"] = cmp.mapping(function(fallback)
  --
  --           --   if cmp.visible() then
  --           --     cmp.complete()
  --           --     fallback()
  --           --   end
  --           -- end, { "i", "s" }),
  --           ["<Tab>"] = cmp.mapping(function(fallback)
  --             if cmp.visible() then
  --               cmp.select_next_item()
  --             -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
  --             -- they way you will only jump inside the snippet region
  --             elseif luasnip.expand_or_jumpable() then
  --               luasnip.expand_or_jump()
  --             -- elseif has_words_before() then
  --             --   cmp.complete()
  --             else
  --               fallback()
  --             end
  --           end, { "i", "s" }),
  --           ["<S-Tab>"] = cmp.mapping(function(fallback)
  --             if cmp.visible() then
  --               cmp.select_prev_item()
  --             elseif luasnip.jumpable(-1) then
  --               luasnip.jump(-1)
  --             else
  --               fallback()
  --             end
  --           end, { "i", "s" }),
  --         },
  --       })
  --     end, -- )()
  --   },
}

-- {
--   "onsails/lspkind.nvim",
--   config = function()
--     require("lspkind").init({
--       mode = "symbol",
--       symbol_map = {
--         Text = "",
--         Method = "",
--         Function = "",
--         Constructor = "",
--         Field = "",
--         Variable = "",
--         Class = "ﴯ",
--         Interface = "",
--         Module = "",
--         Property = "ﰠ",
--         Value = "",
--         Enum = "",
--         Keyword = "",
--         Color = "",
--         File = "",
--         Reference = "",
--         Folder = "",
--         EnumMember = "",
--         Constant = "",
--         Struct = "",
--         Event = "",
--         Operator = "",
--         Array = "",
--         Codeium = "",
--         Boolean = "⊨",
--         Key = "",
--         Namespace = "",
--         Null = "NULL",
--         Number = "#",
--         Object = "",
--         Package = "",
--         Snippet = "",
--         String = "",
--         TypeParameter = "",
--         Unit = "",
--       },
--     })
--   end,
--   -- enabled = vim.g.icons_enabled,
--   -- config = true,
--   -- config = require "plugins.configs.lspkind",
-- },
