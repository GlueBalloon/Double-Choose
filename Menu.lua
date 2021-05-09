menuImages = {}
menuImages.menu = readImage(asset.doubleMenuBackground)
menuImages.charlotte = readImage(asset.doubleMenuCharlotte)
menuImages.rosie = readImage(asset.doubleMenuRosie)
    
function mainMenu()
    drawBackground(menuImages.menu)
    simpleImage("menuRosie", menuImages.rosie, HEIGHT * 0.0014)
    simpleImage("menuCharlotte", menuImages.charlotte)
end
