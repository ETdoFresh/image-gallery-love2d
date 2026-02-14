-- Image Gallery for LOVE2D
-- Navigate with keyboard, gamepad, or mouse

local images = {}
local thumbnails = {}
local selectedIndex = 0  -- Start at 0, will be set to 1 if images loaded
local viewMode = "grid" -- "grid" or "fullscreen"
local gridCols = 4
local gridRows = 2
local scrollOffset = 0
local showInfo = false -- toggle info overlay in fullscreen

-- Input dedup (prevents double-press from D-pad firing both keyboard + gamepad events)
local lastPressTime = {}
local DEDUP_WINDOW = 0.08 -- 80ms

function love.load()
    love.window.setTitle("Image Gallery - Grid View")
    loadImages()
    
    -- Set selectedIndex to 1 if we have images, keep at 0 if not
    if #images > 0 then
        selectedIndex = 1
        createThumbnails()
    else
        print("WARNING: No images loaded. Gallery will be empty.")
    end
end

function loadImages()
    -- Try multiple paths to find the images folder
    -- This handles both standalone mode and running inside app launchers
    local candidates = {
        "images",                                              -- standalone: love .
        "apps/ETdoFresh/image-gallery-love2d/main/images",    -- ets-apps-love2d launcher
    }
    
    -- Also try to detect via debug.getinfo
    local info = debug.getinfo(1, "S")
    if info and info.source then
        local src = info.source:gsub("^@", "")
        local dir = src:match("(.+/)main%.lua$")
        if dir then
            table.insert(candidates, 2, dir .. "images")
        end
    end
    
    local imageFolder = nil
    for _, candidate in ipairs(candidates) do
        local cInfo = love.filesystem.getInfo(candidate)
        if cInfo and cInfo.type == "directory" then
            imageFolder = candidate
            break
        end
    end
    
    if not imageFolder then
        print("ERROR: Could not find images/ folder in any known location:")
        for _, c in ipairs(candidates) do print("  tried: " .. c) end
        return
    end
    
    print("=== Image Loading Debug ===")
    print("Image folder found at: " .. imageFolder)
    print("Source directory: " .. love.filesystem.getSource())
    print("Save directory: " .. love.filesystem.getSaveDirectory())
    
    -- Check if images directory exists
    local info = love.filesystem.getInfo(imageFolder)
    if info then
        print("images/ folder found, type: " .. info.type)
    else
        print("ERROR: images/ folder not found!")
        print("Trying to get directory items anyway...")
    end
    
    local success, files = pcall(love.filesystem.getDirectoryItems, imageFolder)
    if not success then
        print("ERROR calling getDirectoryItems: " .. tostring(files))
        return
    end
    
    print("Files found in images/: " .. #files)
    for i, file in ipairs(files) do
        print("  " .. i .. ": " .. file)
    end
    
    for _, file in ipairs(files) do
        local extension = file:match("^.+%.(.+)$")
        print("Checking file: " .. file .. ", extension: " .. tostring(extension))
        
        if extension and (extension:lower() == "jpg" or extension:lower() == "jpeg" or extension:lower() == "png") then
            local imagePath = imageFolder .. "/" .. file
            print("  Attempting to load: " .. imagePath)
            local success, imageData = pcall(love.graphics.newImage, imagePath)
            if success then
                print("  ✓ Successfully loaded!")
                table.insert(images, {
                    path = imagePath,
                    image = imageData,
                    name = file
                })
            else
                print("  ✗ Failed to load: " .. tostring(imageData))
            end
        end
    end
    
    print("Total images loaded: " .. #images)
    print("======================")
    
    if #images == 0 then
        print("No images found in images/ folder!")
    end
end

function createThumbnails()
    for i, imgData in ipairs(images) do
        local canvas = love.graphics.newCanvas(256, 144)
        love.graphics.setCanvas(canvas)
        love.graphics.clear()
        
        local img = imgData.image
        local scaleX = 256 / img:getWidth()
        local scaleY = 144 / img:getHeight()
        local scale = math.min(scaleX, scaleY)
        
        local x = (256 - img:getWidth() * scale) / 2
        local y = (144 - img:getHeight() * scale) / 2
        
        love.graphics.draw(img, x, y, 0, scale, scale)
        love.graphics.setCanvas()
        
        thumbnails[i] = canvas
    end
end

function love.update(dt)
end

function love.draw()
    if viewMode == "grid" then
        drawGrid()
    elseif viewMode == "fullscreen" then
        drawFullscreen()
    end
end

function drawGrid()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    
    local w, h = love.graphics.getDimensions()
    local padding = 20
    local thumbWidth = 256
    local thumbHeight = 144
    local spacing = 15
    
    -- Auto-calculate grid layout
    gridCols = math.floor((w - padding * 2 + spacing) / (thumbWidth + spacing))
    gridCols = math.max(3, gridCols)
    
    love.graphics.printf("Image Gallery - Use Arrow Keys, Mouse, or Gamepad to Navigate", 
        0, 10, w, "center")
    love.graphics.printf("Press Enter/A/Click to view fullscreen", 
        0, 30, w, "center")
    
    local startY = 60
    
    for i, thumb in ipairs(thumbnails) do
        local col = (i - 1) % gridCols
        local row = math.floor((i - 1) / gridCols) - scrollOffset
        
        if row >= 0 and row < 10 then -- Only draw visible rows
            local x = padding + col * (thumbWidth + spacing)
            local y = startY + row * (thumbHeight + spacing)
            
            -- Draw selection highlight
            if i == selectedIndex then
                love.graphics.setColor(0.3, 0.6, 1)
                love.graphics.rectangle("fill", x - 5, y - 5, thumbWidth + 10, thumbHeight + 10, 5)
            end
            
            -- Draw thumbnail
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(thumb, x, y)
            
            -- Draw border
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("line", x, y, thumbWidth, thumbHeight)
            
            -- Draw filename
            love.graphics.setColor(0.9, 0.9, 0.9)
            love.graphics.printf(images[i].name, x, y + thumbHeight + 5, thumbWidth, "center")
        end
    end
    
    love.graphics.setColor(1, 1, 1)
    if #images > 0 then
        love.graphics.printf(string.format("Image %d / %d", selectedIndex, #images),
            0, h - 30, w, "center")
    else
        love.graphics.printf("No images found in images/ folder. Add .jpg, .jpeg, or .png files.",
            0, h - 30, w, "center")
    end
end

function drawFullscreen()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setColor(1, 1, 1)
    
    local currentImage = images[selectedIndex]
    if currentImage and currentImage.image then
        local img = currentImage.image
        local w, h = love.graphics.getDimensions()
        
        -- Fit image to window
        local scaleX = w / img:getWidth()
        local scaleY = h / img:getHeight()
        local scale = math.min(scaleX, scaleY)
        
        local x = (w - img:getWidth() * scale) / 2
        local y = (h - img:getHeight() * scale) / 2
        
        love.graphics.draw(img, x, y, 0, scale, scale)
        
        -- Only show info bar when toggled on
        if showInfo then
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.rectangle("fill", 0, h - 70, w, 70)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(currentImage.name, 0, h - 65, w, "center")
            love.graphics.printf(string.format("%dx%d  |  Image %d / %d", img:getWidth(), img:getHeight(), selectedIndex, #images), 0, h - 45, w, "center")
            love.graphics.printf("Escape/B = back  |  Select/Start = toggle info", 0, h - 25, w, "center")
        end
    else
        -- No image to display
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("No image available", 0, h/2, w, "center")
        love.graphics.printf("Press Escape to return to grid", 0, h/2 + 30, w, "center")
    end
end

function love.keypressed(key, scancode, isrepeat)
    if isrepeat then return end
    
    local now = love.timer.getTime()
    if lastPressTime[key] and (now - lastPressTime[key]) < DEDUP_WINDOW then return end
    lastPressTime[key] = now
    
    if viewMode == "grid" then
        if key == "escape" then
            love.event.quit()
            return
        end
        -- Don't process nav keys if no images loaded
        if #images == 0 then return end
        if key == "return" or key == "space" then
            if images[selectedIndex] then
                viewMode = "fullscreen"
                love.window.setTitle("Image Gallery - " .. images[selectedIndex].name)
            end
        elseif key == "right" then
            selectedIndex = math.min(selectedIndex + 1, #images)
            ensureVisible()
        elseif key == "left" then
            selectedIndex = math.max(selectedIndex - 1, 1)
            ensureVisible()
        elseif key == "down" then
            selectedIndex = math.min(selectedIndex + gridCols, #images)
            ensureVisible()
        elseif key == "up" then
            selectedIndex = math.max(selectedIndex - gridCols, 1)
            ensureVisible()
        end
    elseif viewMode == "fullscreen" then
        if key == "escape" then
            viewMode = "grid"
            showInfo = false
            love.window.setTitle("Image Gallery - Grid View")
        elseif key == "tab" or key == "i" then
            showInfo = not showInfo
        elseif key == "right" then
            selectedIndex = math.min(selectedIndex + 1, #images)
            if images[selectedIndex] then
                love.window.setTitle("Image Gallery - " .. images[selectedIndex].name)
            end
        elseif key == "left" then
            selectedIndex = math.max(selectedIndex - 1, 1)
            if images[selectedIndex] then
                love.window.setTitle("Image Gallery - " .. images[selectedIndex].name)
            end
        end
    end
end

function love.mousepressed(x, y, button)
    -- Don't process mouse if no images loaded
    if #images == 0 then return end
    
    if viewMode == "grid" and button == 1 then
        -- Check if clicked on a thumbnail
        local w, h = love.graphics.getDimensions()
        local padding = 20
        local thumbWidth = 256
        local thumbHeight = 144
        local spacing = 15
        local startY = 60
        
        for i = 1, #thumbnails do
            local col = (i - 1) % gridCols
            local row = math.floor((i - 1) / gridCols) - scrollOffset
            local thumbX = padding + col * (thumbWidth + spacing)
            local thumbY = startY + row * (thumbHeight + spacing)
            
            if x >= thumbX and x <= thumbX + thumbWidth and
               y >= thumbY and y <= thumbY + thumbHeight and
               row >= 0 and images[i] then
                selectedIndex = i
                viewMode = "fullscreen"
                love.window.setTitle("Image Gallery - " .. images[i].name)
                break
            end
        end
    elseif viewMode == "fullscreen" then
        if button == 2 then
            -- Right click to go back
            viewMode = "grid"
            showInfo = false
            love.window.setTitle("Image Gallery - Grid View")
        elseif button == 1 then
            -- Left click to toggle info
            showInfo = not showInfo
        end
    end
end

function love.gamepadpressed(joystick, button)
    -- Map gamepad to key names for dedup
    local map = {
        dpup = "up", dpdown = "down", dpleft = "left", dpright = "right",
        a = "return", b = "b_button",
    }
    local mapped = map[button] or button
    local now = love.timer.getTime()
    if lastPressTime[mapped] and (now - lastPressTime[mapped]) < DEDUP_WINDOW then return end
    lastPressTime[mapped] = now
    
    if viewMode == "grid" then
        if button == "b" then
            love.event.quit()
            return
        end
        -- Don't process nav if no images loaded
        if #images == 0 then return end
        if button == "a" then
            if images[selectedIndex] then
                viewMode = "fullscreen"
                love.window.setTitle("Image Gallery - " .. images[selectedIndex].name)
            end
        elseif button == "dpright" then
            selectedIndex = math.min(selectedIndex + 1, #images)
            ensureVisible()
        elseif button == "dpleft" then
            selectedIndex = math.max(selectedIndex - 1, 1)
            ensureVisible()
        elseif button == "dpdown" then
            selectedIndex = math.min(selectedIndex + gridCols, #images)
            ensureVisible()
        elseif button == "dpup" then
            selectedIndex = math.max(selectedIndex - gridCols, 1)
            ensureVisible()
        end
    elseif viewMode == "fullscreen" then
        if button == "b" then
            viewMode = "grid"
            showInfo = false
            love.window.setTitle("Image Gallery - Grid View")
        elseif button == "start" or button == "x" then
            showInfo = not showInfo
        elseif button == "dpright" then
            selectedIndex = math.min(selectedIndex + 1, #images)
            if images[selectedIndex] then
                love.window.setTitle("Image Gallery - " .. images[selectedIndex].name)
            end
        elseif button == "dpleft" then
            selectedIndex = math.max(selectedIndex - 1, 1)
            if images[selectedIndex] then
                love.window.setTitle("Image Gallery - " .. images[selectedIndex].name)
            end
        end
    end
end

function ensureVisible()
    local currentRow = math.floor((selectedIndex - 1) / gridCols)
    local h = love.graphics.getHeight()
    local visibleRows = math.floor((h - 100) / 159) -- thumb height + spacing
    
    if currentRow < scrollOffset then
        scrollOffset = currentRow
    elseif currentRow >= scrollOffset + visibleRows then
        scrollOffset = currentRow - visibleRows + 1
    end
end

function love.wheelmoved(x, y)
    if viewMode == "grid" then
        scrollOffset = math.max(0, scrollOffset - y)
    end
end
