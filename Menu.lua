menuImages = {}
menuImages.menu = readImage(asset.doubleMenuBackground)
menuImages.charlotte = readImage(asset.doubleMenuCharlotte)
menuImages.rosie = readImage(asset.doubleMenuRosie)
menuratio = 0.0014
    parameter.number("menuratio", 0.0012, 0.002, menuratio, function()
    print(menuratio)
end)
parameter.watch("menuratio")

function startRosieIntro()
        sound(asset["Rosie_game_intro-2.wav"])
       -- uiPieceHandler.shouldUpdateScreenBlur = true 
    currentScreen = rosieIntro 
end

function mainMenu()
    drawBackground(menuImages.menu)
    button("test")
    button("menuRosie", startRosieIntro, nil, nil, nil, nil, nil, menuImages.rosie)
    button("menuCharlotte", function() 
        uiPieceHandler.shouldUpdateScreenBlur = true 
        currentScreen = charlotteStart 
    end, nil, nil, nil, nil, nil, menuImages.charlotte)
end

function rosieIntro()
    drawBackground(menuImages.menu)
pushStyle()
fill(19, 161)
 rect(WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)
    popStyle()
    pushStyle()
 fontSize(80)
    button("Hi!")
    popStyle()

simpleImage("rosieIntroFace", menuImages.rosie, 0.5)

end
