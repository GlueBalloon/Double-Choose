menuImages = {}
menuImages.menu = readImage(asset.doubleMenuBackground)
menuImages.charlotte = readImage(asset.doubleMenuCharlotte)
menuImages.rosie = readImage(asset.doubleMenuRosie)
menuratio = 0.0014
    parameter.number("menuratio", 0.0012, 0.002, menuratio, function()
    print(menuratio)
end)
parameter.watch("menuratio")
function mainMenu()
    drawBackground(menuImages.menu)
    button("menuRosie", nil, nil, nil, nil, nil, nil, menuImages.rosie)
    button("menuCharlotte", nil, nil, nil, nil, nil, nil, menuImages.charlotte)
end