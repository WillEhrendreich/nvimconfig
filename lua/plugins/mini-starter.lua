return {
  "echasnovski/mini.starter",

  -- opts = function(_, o)
  opts = function()
    local logo = table.concat({
      "            ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z",
      "            ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    ",
      "            ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       ",
      "            ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         ",
      "            ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║           ",
      "            ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝           ",
    }, "\n")
    local nvimlogo = [[
      █████ █     ██                                                         
   ██████  ██    ████ █                                 █                    
  ██   █  █ ██    ████                    ██           ███                   
 █    █  █  ██    █ █                     ██            █                    
     █  █    ██   █                ████    ██    ███                         
    ██ ██    ██   █       ███     █ ███  █  ██    ███ ███    ███ ████ ████   
    ██ ██     ██  █      █ ███   █   ████   ██     ███ ███    ███ ████ ███  █
    ██ ██     ██  █     █   ███ ██    ██    ██      ██  ██     ██  ████ ████ 
    ██ ██      ██ █    ██    █████    ██    ██      ██  ██     ██   ██   ██  
    ██ ██      ██ █    ████████ ██    ██    ██      ██  ██     ██   ██   ██  
    █  ██       ███    ███████  ██    ██    ██      ██  ██     ██   ██   ██  
       █        ███    ██       ██    ██    ██      █   ██     ██   ██   ██  
   ████          ██    ████    █ ██████      ███████    ██     ██   ██   ██  
  █  █████              ███████   ████        █████     ███ █  ███  ███  ███ 
 █     ██                █████                           ███    ███  ███  ███
 █                                                                           
  █                                                                          
   ██                                                                        
                                                                             
]]
    local pad = string.rep(" ", 22)
    local new_section = function(name, action, section)
      return { name = name, action = action, section = pad .. section }
    end

    local starter = require("mini.starter")
  --stylua: ignore
  local config = {
    evaluate_single = true,
    header = nvimlogo,
    items = {
      new_section("Find file",       LazyVim.pick(),                        "Telescope"),
      new_section("New file",        "ene | startinsert",                   "Built-in"),
      new_section("Recent files",    LazyVim.pick("oldfiles"),              "Telescope"),
      new_section("Text search",     LazyVim.pick("live_grep"),             "Telescope"),
      new_section("Config",          LazyVim.pick.config_files(),           "Config"),
      new_section("Session",         [[lua require("persistence").load()]], "Session"),
      new_section("Extras For Lazy", "LazyExtras",                          "Config"),
      new_section("Lazy",            "Lazy",                                "Config"),
      new_section("Quit",            "qa",                                  "Built-in"),
    },
    content_hooks = {
      starter.gen_hook.adding_bullet(pad .. "💠 ", false),
      starter.gen_hook.aligning("center", "center"),
    },
  }
    return config
  end,
  config = true,
}
