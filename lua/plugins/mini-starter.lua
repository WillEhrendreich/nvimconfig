return {
  "echasnovski/mini.starter",

  opts = function(_, o)
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
    o.header = nvimlogo
    return o
  end,
  config = true,
}
