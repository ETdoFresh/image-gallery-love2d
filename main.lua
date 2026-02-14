-- Image Gallery for LOVE2D
-- Navigate with keyboard, gamepad, or mouse

local images = {}
local thumbnails = {}
local selectedIndex = 0  -- Start at 0, will be set to 1 if images loaded
local viewMode = "grid" -- "grid" or "fullscreen"
local gridCols = 4
local gridRows = 2
local scrollOffset = 0

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
    -- Detect base path (works both standalone and inside app launcher)
    local baseDir = ""
    local info = debug.getinfo(1, "S")
    if info and info.source then
        local src = info.source:gsub("^@", "")
        baseDir = src:match("(.+/)main%.lua$") or ""
    end
    
    local imageFolder = baseDir .. "images"
    
    -- Debug: Check if directory exists and what Love2D sees
    print("=== Image Loading Debug ===")
    print("Detected base directory: " .. (baseDir ~= "" and baseDir or "(none - running standalone)"))
    print("Image folder path: " .. imageFolder)
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
    gridCols = math.max(1, gridCols)
    
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
        
        -- Draw filename and instructions
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.rectangle("fill", 0, h - 50, w, 50)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(currentImage.name, 0, h - 45, w, "center")
        love.graphics.printf("Press Escape/B/Right-Click to return to grid", 0, h - 25, w, "center")
    else
        -- No image to display
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("No image available", 0, h/2, w, "center")
        love.graphics.printf("Press Escape to return to grid", 0, h/2 + 30, w, "center")
    end
end

function love.keypressed(key)
    -- Don't process keys if no images loaded
    if #images == 0 then return end
    
    if viewMode == "grid" then
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
            love.window.setTitle("Image Gallery - Grid View")
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
    elseif viewMode == "fullscreen" and button == 2 then
        -- Right click to go back
        viewMode = "grid"
        love.window.setTitle("Image Gallery - Grid View")
    end
end

function love.gamepadpressed(joystick, button)
    -- Don't process gamepad if no images loaded
    if #images == 0 then return end
    
    if viewMode == "grid" then
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
            love.window.setTitle("Image Gallery - Grid View")
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
