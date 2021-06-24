menuImages = {}
menuImages.menu = readImage(asset.doubleMenuBackground)
menuImages.charlotte = readImage(asset.doubleMenuCharlotte)
menuImages.rosie = readImage(asset.doubleMenuRosie)
menuratio = 0.0014
--[[
    parameter.number("menuratio", 0.0012, 0.002, menuratio, function()
    print(menuratio)
end)
parameter.watch("menuratio")

]]

function startRosieIntroSound()
    sound(asset["Rosie_game_intro-2.wav"])
    currentScreen = rosieGreetingText 
end

function mainMenu()
    drawBackground(menuImages.menu)
    button("menuRosie", startRosieIntroSound, nil, nil, nil, nil, nil, menuImages.rosie)
    button("menuCharlotte", function() 
        uiPieceHandler.shouldUpdateScreenBlur = true 
        currentScreen = charlotteStart 
    end, nil, nil, nil, nil, nil, menuImages.charlotte)
end

function rosieGreetingText()
    --menu background
    drawBackground(menuImages.menu)
    --tint and dark rounded rect
    pushStyle()
    fill(19, 161)
    strokeWidth(0)
    rect(WIDTH/2, HEIGHT/2, WIDTH + 4, HEIGHT + 4)
    strokeWidth(3)
    button("not visible text", rosieStartGameForReal, WIDTH/2, HEIGHT/2, WIDTH*5/6, HEIGHT - (WIDTH*1/6), color(255, 0))
    popStyle()
    
    pushStyle()
    --text balloons
    fill(26, 161)
    textWrapWidth(WIDTH/3)
    fontSize(70)
    strokeWidth(4)
    button("I'm Rosie and this is my game!", rosieStartGameForReal)
    fontSize(80)
    strokeWidth(4)
    button("Hi!", rosieStartGameForReal)
    --image
    simpleImage("rosieIntroFace", menuImages.rosie, 0.95)
    popStyle()

end

function rosieStartGameForReal()
    uiPieceHandler.shouldUpdateScreenBlur = true 
    currentScreen = rosieStart
end
