function love.conf(t)
    t.title = "Simple LOVE.physics testbed"
    t.author = "Gulyás Imre Miklós"         
    t.url = nil                 
    t.identity = nil            
    t.version = "0.8.0"         
    t.console = false            
    t.release = false           
    t.screen.width = 800     
    t.screen.height = 600       
    t.screen.fullscreen = false 
    t.screen.vsync = true       
    t.screen.fsaa = 2           
    t.modules.joystick = false   
    t.modules.audio = false     
    t.modules.keyboard = true   
    t.modules.event = true      
    t.modules.image = true      
    t.modules.graphics = true   
    t.modules.timer = true      
    t.modules.mouse = true     
    t.modules.sound = false     
    t.modules.physics = true    
end