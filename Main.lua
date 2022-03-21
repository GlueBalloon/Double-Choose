-- Double Choose, but redone with better UI and cleaner code
-- The great code for rounded rectangles with transparent-blur backgrounds is pulled from yojimbo2000's amazing SODA project
 
viewer.mode = FULLSCREEN_NO_BUTTONS
--654.7518075904	 	547.1759527936
-- originally coded on 1366 x 1024


function setup()
    
    initSupportedOrientations()
    supportedOrientations(LANDSCAPE_ANY)

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
end

function coordinateMultipliers(originalW, originalH)
    local multX, multY = deviceWnH.x / originalW, deviceWnH.y / originalH
    return vec2(multX, multY)
end

function draw()
    currentScreen()
    if currentOverlay then
        currentOverlay()
    end
    simpleButtons.baseFontSize = vFontSize
    uiPieceHandler.narrationW = vTextWidth
    uiPieceHandler.narrationH = vTextHeight
    uiPieceHandler.choiceW = vTextWidth
end
