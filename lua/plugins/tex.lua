-- Live compilation
vim.g.vimtex_compiler_latexmk = {
  build_dir = ".out",
  options = {
    "-shell-escape",
    "-verbose",
    "-file-line-error",
    "-interaction=nonstopmode",
    "-synctex=1",
  },
}
vim.g.vimtex_view_method = "sumatrapdf"
vim.g.vimtex_fold_enabled = true
local gknapsettings = {
  delay = 250,
  htmloutputext = "html",
  htmltohtml = "none",
  htmltohtmlviewerlaunch = "falkon %outputfile%",
  htmltohtmlviewerrefresh = "none",
  markdownoutputext = "html",
  markdowntohtml = "pandoc --standalone %docroot% -o %outputfile%",
  markdowntohtmlviewerlaunch = "falkon %outputfile%",
  markdowntohtmlviewerrefresh = "none",
  markdowntopdf = "pandoc %docroot% -o %outputfile%",
  markdowntopdfviewerlaunch = "sioyek %outputfile%",
  markdowntopdfviewerrefresh = "none",
  mdoutputext = "html",
  mdtohtml = "pandoc --standalone %docroot% -o %outputfile%",
  mdtohtmlviewerlaunch = "falkon %outputfile%",
  mdtohtmlviewerrefresh = "none",
  mdtopdf = "pandoc %docroot% -o %outputfile%",
  mdtopdfviewerlaunch = "sioyek %outputfile%",
  mdtopdfviewerrefresh = "none",
  texoutputext = "pdf",
  textopdf = "pdflatex -synctex=1 -halt-on-error -interaction=batchmode %docroot%",
  textopdfforwardjump = "sioyek --inverse-search 'nvim --headless -es --cmd \"lua require('\"'\"'knaphelper'\"'\"').relayjump('\"'\"'%servername%'\"'\"','\"'\"'%1'\"'\"',%2,%3)\"' --reuse-window --forward-search-file %srcfile% --forward-search-line %line% %outputfile%",
  textopdfshorterror = 'A=%outputfile% ; LOGFILE="${A%.pdf}.log" ; rubber-info "$LOGFILE" 2>&1 | head -n 1',
  -- textopdfviewerlaunch = "mupdf %outputfile%",
  textopdfviewerlaunch = "sioyek --inverse-search 'nvim --headless -es --cmd \"lua require('\"'\"'knaphelper'\"'\"').relayjump('\"'\"'%servername%'\"'\"','\"'\"'%1'\"'\"',%2,%3)\"' --new-window %outputfile%",
  textopdfviewerrefresh = "kill -HUP %pid%",
  -- textopdfviewerrefresh = "none",
}
vim.g.knap_settings = gknapsettings
return {
  {
    "frabjous/knap",
    -- Live recompilation
    "lervag/vimtex",
  },
  {
    -- "nvim-treesitter/nvim-treesitter",
    -- opts = function(_, opts)
    --   -- vim.list_extend(opts.ensure_installed, {
    --   --   "xml",
    --   -- })
    -- end,
  },
  {
    "neovim/nvim-lspconfig",

    opts = {
      servers = {

        texlab = {},
      },
      --      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      -- setup = {
      -- },
    },
  },
}
