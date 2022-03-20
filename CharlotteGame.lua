function testCharlottesGame()
    CodeaUnit.detailed = true
    
    _:describe("Charlotte's game tests", function()
        
        _:before(function()
            backupInventory = inventory
            inventory = {}
        end)
        
        _:after(function()
            inventory = backupInventory
        end)
        
        _:test("SavedCoffeeCount", function()
            inventory = {}
            savedCoffee()
            _:expect(#inventory).is(1)
        end)
        
        _:test("SavedCoffeeInventoryContents", function()
            savedCoffee()
            _:expect(inventory).has("inventoryCoffee")
        end)
        
        _:test("BoyfriendWithCoffee", function()
            savedCoffee()
            boyfriendTells()
            _:expect(inventory).has("inventoryCoffee")
        end)
        
        _:test("BoyfriendWithoutCoffee", function()
            drankCoffee()
            boyfriendTells()
            _:expect(inventory).hasnt("inventoryCoffee")
        end)
        
        _:test("Knight screen with coffee", function()
            savedCoffee()
            boyfriendTells()
            knightScreen()
            _:expect(inventory).has("inventoryCoffee")
        end)
        
        _:test("Knight screen without coffee", function()
            drankCoffee()
            boyfriendTells()
            knightScreen()
            _:expect(inventory).hasnt("inventoryCoffee")
        end)
        
    end)
end


charlotteImages = {}

--images for the very first screen
charlotteImages.charlotteStart = readImage(asset.ccFirst)
charlotteImages.heroineStart = readImage(asset.ccHeroine)
charlotteImages.coffee = readImage(asset.ccCoffeeSmall)
charlotteImages.inventoryCoffee = readImage(asset.ccCoffeeBig)

charlotteImages.charlotteImageLoader = coroutine.create(function()
    --backgrounds
    charlotteImages.sizeGuide = readImage(asset.ccSizeGuide)
    coroutine.yield()
    charlotteImages.boyfriendTells = readImage(asset.ccGenericOutside)
    coroutine.yield()
    charlotteImages.knightScreen = readImage(asset.ccKnightScreen)
    coroutine.yield()
    charlotteImages.boredQueen = readImage(asset.ccQueenBored)
    coroutine.yield()
    charlotteImages.genericOutside = readImage(asset.ccGenericOutside)
    coroutine.yield()
    charlotteImages.queenNotLike = readImage(asset.ccQueenNotLike)
    coroutine.yield()
    charlotteImages.homeAndSleep = readImage(asset.ccHomeAndSleep)
    coroutine.yield()
    charlotteImages.queenLovesShow = readImage(asset.ccQueenLoves)
    coroutine.yield()
    charlotteImages.genericCastleInterior = readImage(asset.choices_boyfriend_or_princess_light)
    coroutine.yield()
    charlotteImages.happyInForest = readImage(asset.ccHappyInForest)
    coroutine.yield()
    --images drawn over background
    charlotteImages.placementGuide = readImage(asset.choices_cup_big)
    coroutine.yield()
    charlotteImages.heroineDrank = readImage(asset.ccHeroineFlipped)
    coroutine.yield()
    charlotteImages.heroineSavedCoffee = readImage(asset.ccHeroine)
    coroutine.yield()
    charlotteImages.heroineWithBoyfriend = readImage(asset.ccHeroineFlipped)
    coroutine.yield()
    charlotteImages.heroineWithQueen = readImage(asset.ccHeroine)
    coroutine.yield()
    charlotteImages.heroineLeavingQueen = readImage(asset.ccHeroineFlipped)
    coroutine.yield()
    charlotteImages.heroineQueened = readImage(asset.ccHeroineQueened)
    coroutine.yield()
    charlotteImages.boyfriend = readImage(asset.ccBoyfriend)
    coroutine.yield()
    charlotteImages.heroineWithKnight = readImage(asset.ccHeroine)
    coroutine.yield()
    charlotteImages.heroineWithKnight2 = readImage(asset.ccHeroine)
    coroutine.yield()
    charlotteImages.heroineMeetsGrouchy = readImage(asset.ccHeroineFlipped)
    coroutine.yield()
    charlotteImages.heroineWithSockPuppets = readImage(asset.ccHeroineWithSockPuppets)
    coroutine.yield()
    charlotteImages.heroineWithMarionettes = readImage(asset.ccHeroineWithMarionettes)
    coroutine.yield()
    charlotteImages.grouchyPuppeteer = readImage(asset.ccPuppeteerGrumpy)
    coroutine.yield()
    charlotteImages.puppeteerTeaching = readImage(asset.ccPuppeteerHappy)
    coroutine.yield()
    charlotteImages.heartChoiceBoyfriend = readImage(asset.ccBoyfriend)
    coroutine.yield()
    charlotteImages.heartChoicePrincess = readImage(asset.ccPrincess)
    coroutine.yield()
    charlotteImages.happyFamily = readImage(asset.ccHappyFamily)
    coroutine.yield()
    charlotteImages.inventoryChocolate = readImage(asset.ccHeartBox)
    print("charlotte images loaded")
end)
charlotteInfoText = 
[[Charlotte made this game at 8, and she designed, wrote, art directed, and drew one of the ending screens for it. Later (at 13) she made its backround music.

I was and am impressed that Charlotte made a genuine branching-choice inventory-based story puzzle, precocious for an 8-year-old. Plus it's a sweet bit of grace that she gave her heroine two possible happy endings.

Both girls roughly copied the plot of the game that inspired this, 'The Story of Choices' by Behold Studios. 

But in their different spins on it we get a great glimpse of how their young brains were busy forming themselves.]]
charlotteImageScale = 0.0045 * adjstmt.x * deviceWnH.x
charKnightScale = charlotteImageScale * 0.55
charQueenScale = charlotteImageScale * 0.825
charPuppeteerScale = charlotteImageScale * 0.785


function charlotteFirstScreenDecider()
    if not readLocalData("charlotteInfoShown") then
        currentScreen = charlotteGameInfo
        saveLocalData("charlotteInfoShown", "true")
    else
        currentScreen = charlotteStart
    end
    charlotteInfoFontSize = uiPieceHandler.fontSizeForRect(charlotteInfoText, WIDTH * 0.85, HEIGHT * 0.8)
end

function charlotteMusicStarter()
    music(asset.CharlottesGameBGMusicMP3,true, 0.2)
end

function charlotteGameInfo()
    drawBackground(charlotteImages.charlotteStart)
    --tinted overlay
    pushStyle()
    fill(19, 161)
    strokeWidth(0)
    rect(WIDTH/2, HEIGHT/2, WIDTH + 4, HEIGHT + 4)
    popStyle()
    --info
    pushStyle()
    fontSize(charlotteInfoFontSize)
    textWrapWidth(WIDTH * 0.85)
    fill(55, 161)
button(
charlotteInfoText, 
    function() currentScreen = charlotteStart end, nil, nil, WIDTH * 0.92, HEIGHT * 0.9, color(255))
popStyle()
end

inventory = {}

function inventoryList()
    local summary = "inventory contents: "
    for i, v in pairs(inventory) do
        summary = summary.."  "..v.name
    end
    return summary
end

function drawInventory()
    local inventoryX = 167--309.5
    for i, name in ipairs(inventory) do
        simpleImage(name, charlotteImages[name], charlotteImageScale, inventoryX, 140)
        inventoryX = inventoryX + (charlotteImages[name].width * charlotteImageScale)
    end
end

function charlotteStart()
    inventory = {}
    drawBackground(charlotteImages.charlotteStart)
    simpleImage("heroineStart", charlotteImages.heroineStart, HEIGHT * 0.00155)
    simpleImage("coffee", charlotteImages.coffee, 1.6)
    textArea("You woke up.\n\nWhat do you want to do with your coffee?")
    if coroutine.status(charlotteImages.charlotteImageLoader) ~= "dead" then
        print("still loading")
        coroutine.resume(charlotteImages.charlotteImageLoader)
    else
        choice("drink it", drankCoffee)
        choice("save it for later", savedCoffee)
    end
    pushStyle()
    stroke(0, 0)
    fontSize(charlotteInfoFontSize * 0.75)
    --function button(bText, action, x, y, width, height, fontColor, imageAsset, radius)
    button("i", function() currentScreen = charlotteGameInfo end, nil, nil)
    button("x", function() currentScreen = mainMenuStarter end, nil, nil)
    popStyle()
end

function drankCoffee()
    drawBackground(charlotteImages.charlotteStart)
    simpleImage("heroineDrank", charlotteImages.heroineDrank, charlotteImageScale)
    textArea("It tastes good.")
    choice("go outside", boyfriendTells)
end

function savedCoffee()
    drawBackground(charlotteImages.charlotteStart)
    simpleImage("heroineSaved", charlotteImages.heroineSavedCoffee, charlotteImageScale)
    inventory = {"inventoryCoffee"}
    drawInventory()
    textArea("You keep it with you for later.")
    choice("go out", boyfriendTells)
end

function boyfriendTells()
    drawBackground(charlotteImages.boyfriendTells)
simpleImage("boyfriend", charlotteImages.boyfriend, charlotteImageScale * 0.8)
    simpleImage("heroineWithBoyfriend", charlotteImages.heroineWithBoyfriend, charlotteImageScale * 0.8)
    drawInventory()
    textArea("Your boyfriend tells you the queen is bored.")
    choice("go see the queen", knightScreen)
end

function knightScreen ()
    drawBackground(charlotteImages.knightScreen)
simpleImage("heroineWithKnight", charlotteImages.heroineWithKnight, charKnightScale)
    drawInventory()
    textArea("You see a knight at the gate.\n\nWhat do you say to him?")
    choice("Just let me in to the castle.", knightScolds)
    choice("Hi, having a nice day?", knightGivesHeart)
end

function knightGivesHeart ()
    drawBackground(charlotteImages.knightScreen)
    simpleImage("heroineScolded", charlotteImages.heroineWithKnight2, charKnightScale)
    if inventory[1] == "inventoryCoffee" then
        inventory = {"inventoryCoffee", "inventoryChocolate"}
        else
        inventory = {"inventoryChocolate"}
    end
    drawInventory()
    textArea("The knight likes you and gives you a heart box with chocolates in it.")
    choice("go in to castle", boredQueen)
end

function knightScolds ()
    drawBackground(charlotteImages.knightScreen)
    simpleImage("heroineScolded", charlotteImages.heroineWithKnight2, charKnightScale)
    drawInventory()
    textArea("The knight tells you that you have a bad attitude.")
    choice("go home", homeAfterKnight)
end


function homeAfterKnight ()
    drawBackground(charlotteImages.charlotteStart)
    simpleImage("heroineScolded", charlotteImages.heroineDrank, charlotteImageScale)
    drawInventory()
    textArea([[You say to yourself, "He doesn't like me anyway."]])
    choice("begin again", charlotteStart)
end

function boredQueen()
    drawBackground(charlotteImages.boredQueen)
    simpleImage("heroineWithQueen", charlotteImages.heroineWithQueen, charQueenScale)
    drawInventory()
    textArea("The queen tells you she's really bored.")
    choice("suggest a puppet show", queenSaysShowMe)
end

function queenSaysShowMe()
    drawBackground(charlotteImages.boredQueen)
    simpleImage("heroineWithQueen", charlotteImages.heroineLeavingQueen, charQueenScale)
    drawInventory()
    textArea([[You tell the queen you know how to put on a puppet show.
    
    She says, "Show me as soon as you can!"]])
    choice("leave", puppeteer)
end

function puppeteer()
    drawBackground(charlotteImages.genericOutside)
    simpleImage("heroineMeetsGrouchy", charlotteImages.heroineMeetsGrouchy, charPuppeteerScale)
    simpleImage("grouchyPuppeteer", charlotteImages.grouchyPuppeteer, charPuppeteerScale)
    drawInventory()
    textArea("On your way home you see a grouchy puppeteer.")
    if inventory[1] == "inventoryCoffee" then
        choice("give him your coffee", happyPuppeteer)
    end
    choice("go home and practice", queenNotLike)
end

function happyPuppeteer()
    if inventory[1] == "inventoryCoffee" then
        table.remove(inventory, 1)
    end
    drawBackground(charlotteImages.genericOutside)
    simpleImage("heroineMeetsGrouchy", charlotteImages.heroineMeetsGrouchy, charPuppeteerScale)
simpleImage("puppeteerTeaching", charlotteImages.puppeteerTeaching, charPuppeteerScale)
    drawInventory()
    textArea("He teaches you a new puppet show.")
    choice("go home and give up", homeAndSleep)
    choice("go show the queen", queenLovesShow)
end

function queenNotLike()
    drawBackground(charlotteImages.queenNotLike)
    simpleImage("heroineWithSockPuppets", charlotteImages.heroineWithSockPuppets, charQueenScale)
    drawInventory()
    textArea("You practice, but the queen doesn't like your show, and you're embarrassed.")
    choice("back to start", homeAndSleep)
end

function homeAndSleep()
    drawBackground(charlotteImages.homeAndSleep)
    textArea("You go back home and go to sleep.")
    choice("start over", charlotteStart)
end

function queenLovesShow()
    drawBackground(charlotteImages.queenLovesShow)
    textArea([[The queen loves the show!
    
She tells you a secret. If you give the princess a heart box with chocolates in it, you will become the new queen.]])
    simpleImage("heroineWithMarionettes", charlotteImages.heroineWithMarionettes, charQueenScale)
    choice("choose who to give the heart to", heartChoice)
    drawInventory()
end

function heartChoice()
    drawBackground(charlotteImages.genericCastleInterior)
    textArea("Do you give the heart to the princess or your boyfriend?")
    choice("give to princess", youBecomeQueen)
    choice("give to boyfriend", happyInForest)
    simpleImage("heartChoiceBoyfriend", charlotteImages.heartChoiceBoyfriend, charlotteImageScale)
    simpleImage("heartChoicePrincess", charlotteImages.heartChoicePrincess, charlotteImageScale * 0.9)
    drawInventory()
end

function youBecomeQueen()
    drawBackground(charlotteImages.genericCastleInterior)
    textArea("You become the queen!")
    choice("The End", charlotteStart)
    simpleImage("heroineQueened", charlotteImages.heroineQueened, charlotteImageScale * 1.2)
end

function happyInForest()
    drawBackground(charlotteImages.happyInForest)
    textArea([[You and your boyfriend end up living in a shack in the forest with your kids.
    
    And you are happy.]])
    choice(" The End ", charlotteStart)
    simpleImage("happyFamily", charlotteImages.happyFamily, charlotteImageScale * 1.65)
end