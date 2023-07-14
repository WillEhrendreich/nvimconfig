return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  opts = function(_,opts)
    local dashboard = require("alpha.themes.dashboard")
    local logo = [[
     ...     ..      ..                           ...                                                 .                
  x*8888x.:*8888: -"888:     ..               xH88"`~ .x8X                                 oec :    @88>              
 X   48888X `8888H  8888    @L              :8888   .f"8888Hf        u.      u.    u.     @88888    %8P               
X8x.  8888X  8888X  !888>  9888i   .dL     :8888>  X8L  ^""`   ...ue888b   x@88k u@88c.   8"*88%     .         uL     
X8888 X8888  88888   "*8%- `Y888k:*888.    X8888  X888h        888R Y888r ^"8888""8888"   8b.      .@88u   .ue888Nc.. 
'*888!X8888> X8888  xH8>     888E  888I    88888  !88888.      888R I888>   8888  888R   u888888> ''888E` d88E`"888E` 
  `?8 `8888  X888X X888>     888E  888I    88888   %88888      888R I888>   8888  888R    8888R     888E  888E  888E  
  -^  '888"  X888  8888>     888E  888I    88888 '> `8888>     888R I888>   8888  888R    8888P     888E  888E  888E  
   dx '88~x. !88~  8888>     888E  888I    `8888L %  ?888   ! u8888cJ888    8888  888R    *888>     888E  888E  888E  
 .8888Xf.888x:!    X888X.:  x888N><888'     `8888  `-*""   /   "*888*P"    "*88*" 8888"   4888      888&  888& .888E  
:""888":~"888"     `888*"    "88"  888        "888.      :"      'Y"         ""   'Y"     '888      R888" *888" 888&  
    "~'    "~        ""            88F          `""***~"`                                  88R       ""    `"   "888E 
                                  98"                                                      88>            .dWi   `88E 
                                ./"                                                        48             4888~  J8%  
                               ~`                                                          '8              ^"===*"`     


                               ]]

    opts.section.header.val = vim.split(logo, "\n")

    -- dashboard.section.buttons.val = {
    --   dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
    --   dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
    --   dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
    --   dashboard.button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
    --   dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
    --   dashboard.button("s", " " .. " Restore Session", [[:lua require("persistence").load() <cr>]]),
    --   dashboard.button("l", "󰒲 " .. " Lazy", ":Lazy<CR>"),
    --   dashboard.button("q", " " .. " Quit", ":qa<CR>"),
    -- }
    -- for _, button in ipairs(dashboard.section.buttons.val) do
    --   button.opts.hl = "AlphaButtons"
    --   button.opts.hl_shortcut = "AlphaShortcut"
    -- end
    -- dashboard.section.header.opts.hl = "AlphaHeader"
    -- dashboard.section.buttons.opts.hl = "AlphaButtons"
    -- dashboard.section.footer.opts.hl = "AlphaFooter"
    -- dashboard.opts.layout[1].val = 8
    -- return dashboard
    return opts
  end,
  config = function(_, dashboard)
    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == "lazy" then
      vim.cmd.close()
      vim.api.nvim_create_autocmd("User", {
        pattern = "AlphaReady",
        callback = function()
          require("lazy").show()
        end,
      })
    end

    require("alpha").setup(dashboard.opts)

    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
