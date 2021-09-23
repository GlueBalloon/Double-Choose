menuImages = {}
menuImages.menu = readImage(asset.doubleMenuBackground)
menuImages.charlotte = readImage(asset.doubleMenuCharlotte)
menuImages.rosie = readImage(asset.doubleMenuRosie)
menuratio = 0.0014

function mainMenu()
    drawBackground(menuImages.menu)
    button("menuRosie", function()
            sound(asset["Rosie_game_intro-2.wav"])
            currentScreen = rosieGreetingText 
        end, nil, nil, nil, nil, nil, menuImages.rosie)
    button("menuCharlotte", function() 
        sound(asset["Charlotte_Game_intro-3.wav"])
        currentScreen = charlotteGreetingText 
    end, nil, nil, nil, nil, nil, menuImages.charlotte)
end

function rosieGreetingText()
    --menu background
    drawBackground(menuImages.menu)
    --'tint'
    pushStyle()
    fill(19, 161)
    strokeWidth(3)
    button("not visible text", prepRosiesGame, WIDTH/2, HEIGHT/2, WIDTH * 1.1, HEIGHT * 1.1, color(255, 0))
    popStyle()
    
    pushStyle()
    --text balloons
    fill(26, 161)
    textWrapWidth(WIDTH/3)
    fontSize(70)
    strokeWidth(4)
    button("I'm Rosie and this is my game!", prepRosiesGame, nil, nil, nil, nil, color(255) )
    fontSize(100)
    strokeWidth(4)
    button("Hi!", prepRosiesGame, nil, nil, nil, nil, color(255))
    simpleImage("rosieIntroFace", menuImages.rosie, 0.95)
    popStyle()
end

function prepRosiesGame()
    uiPieceHandler.shouldUpdateScreenBlur = true 
    currentScreen = rosieFirstScreenDecider
end

function charlotteGreetingText()
    --menu background
    drawBackground(menuImages.menu)
    --'tint'
    pushStyle()
    fill(19, 161)
    strokeWidth(3)
    button("not visible text", prepCharlottesGame, WIDTH/2, HEIGHT/2, WIDTH * 1.1, HEIGHT * 1.1, color(255, 0))
    popStyle()
    
    pushStyle()
    --text balloons
    fill(26, 161)
    textWrapWidth(WIDTH/3)
    fontSize(70)
    strokeWidth(4)
    button("I'm Charlotte and this is my game!", prepCharlottesGame, nil, nil, nil, nil, color(255) )
    fontSize(100)
    strokeWidth(4)
    button("Hi!", prepCharlottesGame, nil, nil, nil, nil, color(255))
    simpleImage("charlotteIntroFace", menuImages.charlotte, 0.95)
    popStyle()
end

function prepCharlottesGame()
    uiPieceHandler.shouldUpdateScreenBlur = true 
    currentScreen = charlotteFirstScreenDecider
    charlotteMusicStarter()
end