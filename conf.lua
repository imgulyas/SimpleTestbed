function love.conf(t)
    t.title = "Sandbox testbed"
    t.author = "Gulyás Imre Miklós"
    t.url = "https://github.com/imgulyas/SimpleTestbed"
    t.identity = nil
    t.version = "0.10.2"
    t.console = false
    t.release = false
    t.window.width = 1024
    t.window.height = 768
    t.window.fullscreen = false
    t.window.vsync = true
    t.window.fsaa = 2
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
