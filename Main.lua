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
    
    --set global styles
    fontSize(uiPieceHandler.fontSizeDefault)
    rectMode(CENTER)
    font("HelveticaNeue-Light")
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
end
