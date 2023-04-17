-- vim.api.nvim_create_user_command("ModifyStringWithBlah", function()
--   local stringUtils = require("dev")
--   vim.notify(stringUtils.StringAppendWithBlah())
-- end, {})
return {
  {
    "folke/noice.nvim",
    enabled = function()
      local uis = vim.api.nvim_list_uis()
      for _, ui in ipairs(uis) do
        for _, ext in ipairs({ "ext_multigrid", "ext_cmdline", "ext_popupmenu", "ext_messages" }) do
          if ui[ext] then
            return false
          end
        end
      end

      return true
    end,
  },
  -- { "lukas-reineke/indent-blankline.nvim", enabled = false },
  -- scrollbar

  {
    "petertriho/nvim-scrollbar",
    event = "BufReadPost",
    config = function()
      local scrollbar = require("scrollbar")
      local colors = require("tokyonight.colors").setup()
      scrollbar.setup({
        handle = { color = colors.bg_highlight },
        excluded_filetypes = { "prompt", "TelescopePrompt", "noice", "notify" },
        marks = {
          Search = { color = colors.orange },
          Error = { color = colors.error },
          Warn = { color = colors.warning },
          Info = { color = colors.info },
          Hint = { color = colors.hint },
          Misc = { color = colors.purple },
        },
      })
    end,
  },

  {
    "tyru/open-browser.vim",

    commands = function()
      return {
        {
          desc = "Smart search link/word under cursor",
          cmd = "<Plug>(openbrowser-smart-search)",
          keys = {
            { "n", "gx", { noremap = true } },
            { "v", "gx", { noremap = true } },
          },
        },
      }
    end,
  },
  -- style windows with different colorschemes
  {
    "folke/styler.nvim",
    event = "VeryLazy",
    opts = {
      themes = {
        markdown = { colorscheme = "tokyonight-storm" },
        help = { colorscheme = "tokyonight", background = "dark" },
      },
    },
  },

  -- -- silly drops
  -- {
  --   "folke/drop.nvim",
  --   event = "VeryLazy",
  --   enabled = function()
  --     local uis = vim.api.nvim_list_uis()
  --     for _, ui in ipairs(uis) do
  --       for _, ext in ipairs({ "ext_multigrid", "ext_cmdline", "ext_popupmenu", "ext_messages" }) do
  --         if ui[ext] then
  --           return false
  --         end
  --       end
  --     end
  --
  --     return true
  --   end,
  --   config = function()
  --     math.randomseed(os.time())
  --     local theme = ({ "stars", "snow" })[math.random(1, 3)]
  --     require("drop").setup({ theme = theme })
  --   end,
  -- },
  {
    "kevinhwang91/nvim-ufo",
    init = function()
      -- ### vimsharp C Extensions
      --
      -- local ffi = require("ffi")
      --
      -- -- Custom C extension to get direct fold information from Neovim
      -- ffi.cdef([[
      --   typedef struct {} Error;
      --   typedef struct {} win_T;
      --   typedef struct {
      --     int start;  // line number where deepest fold starts
      --     int level;  // fold level, when zero other fields are N/A
      --     int llevel; // lowest level that starts in v:lnum
      --     int lines;  // number of lines from v:lnum to end of closed fold
      --   } foldinfo_T;
      --   foldinfo_T fold_info(win_T* wp, int lnum);
      --   win_T *find_window_by_handle(int Window, Error *err);
      --   int compute_foldcolumn(win_T *wp, int col);
      -- ]])
      -- vim.keymap.set("n", "zR", function()
      --   require("ufo").openAllFolds()
      -- end, { desc = "Open All Folds" })
      -- vim.keymap.set("n", "zM", function()
      --   require("ufo").closeAllFolds()
      -- end, { desc = "Close All Folds" })
      -- return ffi
      -- table.insert(vimsharp.file_plugins, "nvim-ufo")
    end,
    event = "BufReadPost",
    -- event = "InsertEnter",
    dependencies = {
      "kevinhwang91/promise-async",
      {
        "luukvbaal/statuscol.nvim",
        config = function()
          local builtin = require("statuscol.builtin")
          require("statuscol").setup({
            relculright = true,
            segments = {
              { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
              { text = { "%s" }, click = "v:lua.ScSa" },
              { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
            },
          })
        end,
      },
    },
    opts = {
      preview = {
        mappings = {
          scrollB = "<C-b>",
          scrollF = "<C-f>",
          scrollU = "<C-u>",
          scrollD = "<C-d>",
        },
      },
      -- provider_selector = function(_, filetype, buftype)
      --   local function handleFallbackException(bufnr, err, providerName)
      --     if type(err) == "string" and err:match("UfoFallbackException") then
      --       return require("ufo").getFolds(bufnr, providerName)
      --     else
      --       return require("promise").reject(err)
      --     end
      --   end
      --
      --   return (filetype == "" or buftype == "nofile") and "indent" -- only use indent until a file is opened
      --     or function(bufnr)
      --       return require("ufo")
      --         .getFolds(bufnr, "lsp")
      --         :catch(function(err)
      --           return handleFallbackException(bufnr, err, "treesitter")
      --         end)
      --         :catch(function(err)
      --           return handleFallbackException(bufnr, err, "indent")
      --         end)
      --     end
      -- end,
    },
  },
}
