return {
  opt = {
    runtimepath = vim.opt.runtimepath + "c:/neovim/*",
    updatetime = 4000,
    expandtab = true,
    autoindent = true,
    softtabstop = 2,
    relativenumber = true,
    autoread = true,
    tabstop = 2,
    shiftwidth = 2,
    conceallevel = 2, -- enable conceal
    foldenable = false,
    foldexpr = "nvim_treesitter#foldexpr()", -- set Treesitter based folding
    foldmethod = "expr",
    linebreak = true, -- linebreak soft wrap at words
    list = true, -- show whitespace characters
    listchars = { tab = "│→", extends = "⟩", precedes = "⟨", trail = "·", nbsp = "␣" },
    showbreak = "↪ ",
    spellfile = vim.fn.expand "~/.config/nvim/lua/user/spell/en.utf-8.add",
    thesaurus = vim.fn.expand "~/.config/nvim/lua/user/spell/mthesaur.txt",
    wrap = true, -- soft wrap lines
    shell = "pwsh",
    shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
    shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
    shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
    shellquote = "",
    shellxquote = "",
  },
  g = {
    matchup_matchparen_deferred = 1,
  },
}
