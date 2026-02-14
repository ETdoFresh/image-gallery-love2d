function love.conf(t)
    -- t.identity = "image-gallery-love2d" -- Disabled: prevents filesystem from seeing local images/ folder
    t.version = "11.4"
    t.console = true
    
    t.window.title = "Image Gallery"
    t.window.icon = nil
    t.window.width = 1280
    t.window.height = 720
    t.window.borderless = false
    t.window.resizable = true
    t.window.minwidth = 800
    t.window.minheight = 600
    t.window.fullscreen = false
    t.window.vsync = 1
    
    t.modules.joystick = true
    t.modules.touch = false
end
