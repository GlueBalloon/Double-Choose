-- Double Choose, but redone with better UI and cleaner code
-- The great code for rounded rectangles with transparent-blur backgrounds is pulled from yojimbo2000's amazing SODA project

viewer.mode = FULLSCREEN_NO_BUTTONS
--654.7518075904	 	547.1759527936

function setup()
    
    initSupportedOrientations()
    supportedOrientations(LANDSCAPE_ANY)
    
    deviceWnH = vec2(WIDTH, HEIGHT)
    percentagesFromAbsoluteCoordinates(399.5, 409.0)
    --when need to reset as if first time opened
    parameter.action("Clear local data", function()
        clearLocalData()
        local dataList = listLocalData()
        print("local data keys: ", #dataList)
    end)
    
    --set global styles
    rectMode(CENTER)
    font("HelveticaNeue-Light")
    fontSize(35)
    stroke(255, 255, 255, 255)
    strokeWidth(1)
    fill(255, 255, 255, 255)

    mainMenuStarter()
    
end

function percentagesFromAbsoluteCoordinates(x, y)
    print(WIDTH, " ", HEIGHT)
    local percX, percY = x / WIDTH, y / HEIGHT
    print(x, " ", y)
    print(percX * WIDTH, " ", percY * HEIGHT)
    print(percX, " ", percY)
    return percX, percY
end

function draw()
    currentScreen()
    if currentOverlay then
        currentOverlay()
    end
end
