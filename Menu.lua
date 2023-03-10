menuImages = {}
menuImages.menu = readImage(asset.doubleMenuBackground)
menuImages.charlotte = readImage(asset.doubleMenuCharlotte)
menuImages.rosie = readImage(asset.doubleMenuRosie)
menuratio = 0.0014
parameter.number("menuratio", 0.0012, 0.002, menuratio, function()
    print(menuratio)
end)
parameter.watch("menuratio")


function mainMenuStarter()
    drawBackground(menuImages.menu)
    uiPieceHandler.shouldUpdateScreenBlur = true --needs to be called before the new background is first drawn I think
    currentScreen = mainMenu
    music(asset["Choices_rumble-2.mp3"],true)   
end

function mainMenu()
    parameter.number("number", 0, 100, 50)
    drawBackground(menuImages.menu)
    
    --simpleImage("menuRosie", menuImages.rosie, HEIGHT * 0.0012969697)
   -- simpleImage("menuCharlotte", menuImages.charlotte, HEIGHT * 0.0012969697)
    
    --bText, action, x, y, width, height, fontColor, imageAsset, radius
    --print("menuImages.rosie.height ", menuImages.rosie.height)
    --print("ratio: ", menuImages.rosie.height / HEIGHT)
    OGroVec = vec2(menuImages.rosie.width * 1.3280969728, menuImages.rosie.height * 1.3280969728)
    newRoVec = Utilities.imageSizeForDevice(OGroVec, vec2(WIDTH, HEIGHT))
    
    button("menuRosie", function()
        sound(asset["Rosie_game_intro-2.wav"])
        currentScreen = rosieGreetingText 
    end, nil, nil, newRoVec.x, newRoVec.y, nil, menuImages.rosie)
    
    adj = HEIGHT * 0.0012969697
    charHeight = menuImages.charlotte.height * adj * simpleButtons.screenRatios.y
    --charWidth = menuImages.charlotte.height * WIDTH * 0.00097225254231332
    charWidth = menuImages.charlotte.height * adj * simpleButtons.screenRatios.x
    
    OGcharVec = vec2(menuImages.charlotte.width * 1.3280969728, menuImages.charlotte.height * 1.3280969728)
    newVec = Utilities.imageSizeForDevice(OGcharVec, vec2(WIDTH, HEIGHT))
    
    button("menuCharlotte", function() 
        sound(asset["Charlotte_Game_intro-3.wav"])
        currentScreen = charlotteGreetingText 
        print(hhh)
    end, nil, nil, newVec.x, newVec.y, nil, menuImages.charlotte)
    
end

function rosieGreetingText()
    --menu background
    drawBackground(menuImages.menu)
    --'tint'
    pushStyle()
    fill(19, 161)
    noStroke()
    button("not visible text", prepRosiesGame, nil, nil, WIDTH * 1.1, HEIGHT * 1.1, color(255, 0))
    popStyle()
    --text balloons
    pushStyle()
    fill(26, 161)
    textWrapWidth(WIDTH/3)
    fontSize(70 * adjstmt.x)
    strokeWidth(9 * adjstmt.x)
    button("I'm Rosie and this is my game!", prepRosiesGame, nil, nil, nil, nil, color(255) )
    fontSize(100 * adjstmt.x)
    button("Hi!", prepRosiesGame, nil, nil, nil, nil, color(255))
    simpleImage("rosieIntroFace", menuImages.rosie, 0.95)
    popStyle()
end

function charlotteGreetingText()
    --menu background
    drawBackground(menuImages.menu)
    --'tint'
    pushStyle()
    fill(19, 161)
    noStroke()
    button("not visible text", prepCharlottesGame, nil, nil, WIDTH * 1.1, HEIGHT * 1.1, color(255, 0))
    popStyle()
    --text balloons
    pushStyle()
    fill(26, 161)
    textWrapWidth(WIDTH/3)
    fontSize(70 * adjstmt.x)
    strokeWidth(9 * adjstmt.x)
    button("I'm Charlotte and this is my game!", prepCharlottesGame, nil, nil, nil, nil, color(255) )
    fontSize(100 * adjstmt.x)
    button("Hi!", prepCharlottesGame, nil, nil, nil, nil, color(255))
    simpleImage("charlotteIntroFace", menuImages.charlotte, 0.95)
    popStyle()
end

function prepCharlottesGame()
    uiPieceHandler.shouldUpdateScreenBlur = true 
    simpleButtons.shouldUpdateScreenBlur = true
    currentScreen = charlotteFirstScreenDecider
    charlotteMusicStarter()
end

function prepRosiesGame()
    uiPieceHandler.shouldUpdateScreenBlur = true 
    simpleButtons.shouldUpdateScreenBlur = true
    currentScreen = rosieFirstScreenDecider
end