-- Double Choose, but redone with better UI and cleaner code
-- The great code for rounded rectangles with transparent-blur backgrounds is pulled from yojimbo2000's amazing SODA project
 
viewer.mode = FULLSCREEN_NO_BUTTONS
--654.7518075904	 	547.1759527936
-- originally coded on 1366 x 1024


function setup()
    initSupportedOrientations()
    supportedOrientations(LANDSCAPE_ANY)

    --code recovered from a commit where the menu button sizes worked on ipad:
    --[[
    deviceWnH = vec2(WIDTH, HEIGHT)
    adjstmt = coordinateMultipliers(1366, 1024)
    ]]
    --end recovered code
    
    --when need to reset as if first time opened
    parameter.action("Clear local data", function()
        clearLocalData()
        local dataList = listLocalData()
        print("local data keys: ", #dataList)
    end)
    
    print(258.69 / math.max(WIDTH, HEIGHT)) --0.3878
    print(144 / math.max(WIDTH, HEIGHT)) --0.2159
    
    parameter.number("vFontSize", 1, 30, math.max(WIDTH, HEIGHT) * 0.0245)
    parameter.number("vTextWidth", 1, 800, math.max(WIDTH, HEIGHT) * 0.3878)
    parameter.number("vTextHeight", 1, 800, math.max(WIDTH, HEIGHT) * 0.21)

    --set global styles
    rectMode(CENTER)
    font("HelveticaNeue")
    stroke(255, 255, 255, 255)
    strokeWidth(1)
    fill(255, 255, 255, 255)
    mainMenuStarter()
    
    print("menuCharlotte height: ", readImage(asset.doubleMenuCharlotte).height) -- 400
    print("device: ", WIDTH, " ", HEIGHT)--	1366, 	1024
    
    print("adjstmt: ", adjstmt.x, adjstmt.y)
    print("height multiplier: ", HEIGHT * 0.0012969697)
    print("target height: ", readImage(asset.doubleMenuCharlotte).height * HEIGHT * 0.0012969697)
    -- 400 * x = 531.23878912
    print(531.23878912 / 400)
    print("image times multiplier: ", 400 * 1.3280969728)
    print("multiplier / height = adjuster ", 1.3280969728 / HEIGHT) -- 	0.0012969697
    print("height * adjuster: ", HEIGHT * 0.0012969697) -- 	1.3280969728
    
    print("WIDTH", WIDTH) --1366
    
    print("readImage(asset.doubleMenuCharlotte).width", readImage(asset.doubleMenuCharlotte).width) --377
    print("width times multiplier: ", 377 * 1.3280969728) -- 	500.6925587456
    print("multiplier / width = adjuster ", 1.3280969728 / WIDTH) -- 	0.00097225254231332
    
    print(377/1366) --0.27598828696925
    print("target width: " , readImage(asset.doubleMenuCharlotte).width * WIDTH * 0.00097225254231332)
    
    
    
    --height * x = 1.3280969728
end

--[[
function coordinateMultipliers(originalW, originalH)
    local multX, multY = deviceWnH.x / originalW, deviceWnH.y / originalH
    return vec2(multX, multY)
end
]]

function draw()
    currentScreen()
    if currentOverlay then
        currentOverlay()
    end
    --[[
    simpleButtons.baseFontSize = vFontSize
    uiPieceHandler.narrationW = vTextWidth
    uiPieceHandler.narrationH = vTextHeight
    uiPieceHandler.choiceW = vTextWidth
    ]]
end
