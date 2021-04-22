
function homeAndSleep()
    drawBackground(charlotteImages.homeAndSleep)
    textArea("You go back home and go to sleep.")
    choice("start over", charlotteStart)
end
    
    
    --[[
    {name = "homeAndSleep",
        background = "ccHomeAndSleep",
        narration = "You go back home and go to sleep.",
        choices = {
            {choiceText = "start over", resultScreen ="firstScreen",
                inventoryRemove = "allItems" } }
                },
                ]]


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
--backgrounds
charlotteImages.sizeGuide = readImage(asset.ccSizeGuide)
charlotteImages.charlotteStart = readImage(asset.ccFirst)
charlotteImages.boyfriendTells = readImage(asset.ccGenericOutside)
charlotteImages.knightScreen = readImage(asset.ccKnightScreen)
charlotteImages.boredQueen = readImage(asset.ccQueenBored)
charlotteImages.genericOutside = readImage(asset.ccGenericOutside)
charlotteImages.queenNotLike = readImage(asset.ccQueenNotLike)
charlotteImages.homeAndSleep = readImage(asset.ccHomeAndSleep)
--images drawn over background
charlotteImages.placementGuide = readImage(asset.choices_cup_big)
charlotteImages.heroineStart = readImage(asset.ccHeroine)
charlotteImages.heroineDrank = readImage(asset.ccHeroineFlipped)
charlotteImages.heroineSavedCoffee = readImage(asset.ccHeroine)
charlotteImages.heroineWithBoyfriend = readImage(asset.ccHeroineFlipped)
charlotteImages.heroineWithQueen = readImage(asset.ccHeroine)
charlotteImages.heroineLeavingQueen = readImage(asset.ccHeroineFlipped)
charlotteImages.boyfriend = readImage(asset.ccBoyfriend)
charlotteImages.heroineWithKnight = readImage(asset.ccHeroine)
charlotteImages.heroineWithKnight2 = readImage(asset.ccHeroine)
charlotteImages.heroineMeetsGrouchy = readImage(asset.ccHeroineFlipped)
charlotteImages.heroineWithSockPuppets = readImage(asset.ccHeroineWithSockPuppets)
charlotteImages.grouchyPuppeteer = readImage(asset.ccPuppeteerGrumpy)
charlotteImages.puppeteerTeaching = readImage(asset.ccPuppeteerHappy)
charlotteImages.coffee = readImage(asset.ccCoffeeSmall)
charlotteImages.inventoryCoffee = readImage(asset.ccCoffeeBig)
charlotteImages.inventoryChocolate = readImage(asset.ccHeartBox)

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
    local scaleFactor = HEIGHT * 0.00155
    for i, name in ipairs(inventory) do
        simpleImage(name, charlotteImages[name], scaleFactor, inventoryX, 140)
        inventoryX = inventoryX + (charlotteImages[name].width * scaleFactor)
    end
end

function charlotteStart()
    inventory = {}
    drawBackground(charlotteImages.charlotteStart)
    simpleImage("heroineStart", charlotteImages.heroineStart, HEIGHT * 0.00155)
    simpleImage("coffee", charlotteImages.coffee, 1.6)
    textArea("You woke up.\n\nWhat do you want to do with your coffee?")
    choice("drink it", drankCoffee)
    choice("save it for later", savedCoffee)
end

function drankCoffee()
    drawBackground(charlotteImages.charlotteStart)
    simpleImage("heroineDrank", charlotteImages.heroineDrank, HEIGHT * 0.00155)
    textArea("It tastes good.")
    choice("go outside", boyfriendTells)
end

function savedCoffee()
    drawBackground(charlotteImages.charlotteStart)
    simpleImage("heroineSaved", charlotteImages.heroineSavedCoffee, HEIGHT * 0.00155)
    inventory = {"inventoryCoffee"}
    drawInventory()
    textArea("You keep it with you for later.")
    choice("go out", boyfriendTells)
end

function boyfriendTells()
    drawBackground(charlotteImages.boyfriendTells)
    simpleImage("boyfriend", charlotteImages.boyfriend, HEIGHT * 0.0014)
    simpleImage("heroineWithBoyfriend", charlotteImages.heroineWithBoyfriend, HEIGHT * 0.0014)
    drawInventory()
    textArea("Your boyfriend tells you the queen is bored.")
    choice("go see the queen", knightScreen)
end

function knightScreen ()
    drawBackground(charlotteImages.knightScreen)
    simpleImage("heroineWithKnight", charlotteImages.heroineWithKnight, HEIGHT * 0.00076)
    drawInventory()
    textArea("You see a knight at the gate.\n\nWhat do you say to him?")
    choice("Just let me in to the castle.", knightScolds)
    choice("Hi, having a nice day?", knightGivesHeart)
end

function knightGivesHeart ()
    drawBackground(charlotteImages.knightScreen)
    simpleImage("heroineScolded", charlotteImages.heroineWithKnight2, HEIGHT * 0.00076)
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
    simpleImage("heroineScolded", charlotteImages.heroineWithKnight2, HEIGHT * 0.00076)
    drawInventory()
    textArea("The knight tells you that you have a bad attitude.")
    choice("go home", homeAfterKnight)
end


function homeAfterKnight ()
    drawBackground(charlotteImages.charlotteStart)
    simpleImage("heroineScolded", charlotteImages.heroineDrank, HEIGHT * 0.00155)
    drawInventory()
    textArea([[You say to yourself, "He doesn't like me anyway."]])
    choice("begin again", charlotteStart)
end

function boredQueen()
    drawBackground(charlotteImages.boredQueen)
    simpleImage("heroineWithQueen", charlotteImages.heroineWithQueen, HEIGHT * 0.0013)
    drawInventory()
    textArea("The queen tells you she's really bored.")
    choice("tell her you know a puppet show", queenSaysShowMe)
end

function queenSaysShowMe()
    drawBackground(charlotteImages.boredQueen)
    simpleImage("heroineWithQueen", charlotteImages.heroineLeavingQueen, HEIGHT * 0.0013)
    drawInventory()
    textArea([[You tell the queen you know how to put on a puppet show.
    
    She says, "Show me as soon as you can!"]])
    choice("leave", branchForPuppeteer)
end

function branchForPuppeteer()
    if inventory[1] == "inventoryCoffee" then
        makeScreenChangingAction(puppeteerWithCoffee)()
    else
        makeScreenChangingAction(charlotteStart)()
    end
end

function puppeteerWithCoffee()
    drawBackground(charlotteImages.genericOutside)
    simpleImage("heroineMeetsGrouchy", charlotteImages.heroineMeetsGrouchy, HEIGHT * 0.001)
    simpleImage("grouchyPuppeteer", charlotteImages.grouchyPuppeteer, HEIGHT * 0.001)
    drawInventory()
    textArea("On your way home you see a grouchy puppeteer.")
    choice("give him your coffee", happyPuppeteer)
    choice("go home and practice", queenNotLike)
end

function happyPuppeteer()
    drawBackground(charlotteImages.genericOutside)
    simpleImage("heroineMeetsGrouchy", charlotteImages.heroineMeetsGrouchy, HEIGHT * 0.001)
    simpleImage("puppeteerTeaching", charlotteImages.puppeteerTeaching, HEIGHT * 0.001)
    drawInventory()
    textArea("He teaches you a new puppet show.")
    choice("go home and give up", homeAndSleep)
    choice("go show the queen", charlotteStart)
end

function queenNotLike()
    drawBackground(charlotteImages.queenNotLike)
    simpleImage("heroineWithSockPuppets", charlotteImages.heroineWithSockPuppets, HEIGHT * 0.0013)
    drawInventory()
    textArea("You practice, but the queen doesn't like your show, and you're embarrassed.")
    choice("back to start", homeAndSleep)
end

                                                                                                                                
--[[
                                                                                                                                {name = "homeAndSleep",
                                                                                                                                background = "ccHomeAndSleep",
                                                                                                                                narration = "You go back home and go to sleep.",
                                                                                                                                choices = {
                                                                                                                                {choiceText = "start over", resultScreen ="firstScreen",
                                                                                                                                inventoryRemove = "allItems" } }
                                                                                                                                },
]]


--[[

{name = "firstScreen",
background = "ccFirst",
images = {
{"heroine", "ccHeroine", WIDTH * 0.23, HEIGHT * 0.576, heightRatio = 0.61197917},
{"coffeeSmall", "ccCoffeeSmall", WIDTH * 0.457, HEIGHT * 0.57161, heightRatio = 0.0625} },
narration = "You woke up.\n\rWhat do you want to do with your coffee?",
choices = {
{choiceText = "drink it", resultScreen = "drankCoffee"},
{choiceText = "save it for later", resultScreen ="savedCoffee",
inventoryAdd = {name = "coffee", icon = "ccCoffeeBig", heightRatio = 0.21875} } }
},

{name = "drankCoffee",
background = "ccFirst",
images = {
{"heroine", "ccHeroine", WIDTH * 0.23, HEIGHT * 0.576, heightRatio = 0.61197917} },
narration = "It tastes good.",
choices = {
{choiceText = "go outside", resultScreen = "boyfriendTellsAboutQueen"} },
},

{name = "savedCoffee",
background = "ccFirst",
images = {
{"heroine", "ccHeroine", WIDTH * 0.23, HEIGHT * 0.576, heightRatio = 0.61197917} },
narration = "You keep it with you for later.",
choices = {
{choiceText = "go outside", resultScreen = "boyfriendTellsAboutQueen"} },
},

{name = "boyfriendTellsAboutQueen",
background = "ccGenericOutside",
images = {
{"heroine", "ccHeroine", WIDTH * 0.3115, HEIGHT * 0.576, heightRatio = 0.61197917},
{"boyfriend", "ccBoyfriend", WIDTH * 0.54003906, HEIGHT * 0.5859375, heightRatio = 0.65885417} },
narration = "Your boyfriend tells you the queen is bored.",
choices = {
{choiceText = "go to see the queen", resultScreen = "knightScreen"} }
},

{name = "knightScreen",
background = "ccKnightScreen",
images = {
{"heroine", "ccHeroine", WIDTH * 0.2675, HEIGHT * 0.576, heightRatio = 0.61197917} },
narration = "You see a knight at the gate.\n\rWhat do you say to him?",
choices = {
{choiceText = "Just let me in to the castle.", resultScreen ="knightScolds" },
{choiceText = "Hi, having a nice day?", resultScreen = "knightGivesHeart",
inventoryAdd = {name = "heartBox", icon = "ccHeartBox", heightRatio = 0.22135417} } }
},

{name = "knightGivesHeart",
background = "ccKnightScreen",
images = {
{"heroine", "ccHeroine", WIDTH * 0.2675, HEIGHT * 0.576, heightRatio = 0.61197917} },
narration = "The knight likes you and gives you a heart box with chocolates in it.",
choices = {
{choiceText = "go in to castle", resultScreen ="boredQueen" } }
},

{name = "knightScolds",
background = "ccKnightScreen",
images = {
{"heroine", "ccHeroine", WIDTH * 0.23, HEIGHT * 0.576, heightRatio = 0.61197917} },
narration = "The knight tells you that you have a bad attitude.",
choices = {
{choiceText = "go home", resultScreen ="homeAfterKnight" } }
},

{name = "homeAfterKnight",
background = "ccFirst",
images = {
{"heroineFlipped", "ccHeroineFlipped", WIDTH * 0.390625, HEIGHT * 0.56380208, heightRatio = 0.61197917} },
narration = "You say to yourself, \"He doesn't like me anyway.\"",
choices = {
{choiceText = "start over", resultScreen ="firstScreen",
inventoryRemove = "allItems" } }
},

{name = "boredQueen",
background = "ccQueenBored",
images = {
{"heroine", "ccHeroine", WIDTH * 0.2197, HEIGHT * 0.576, heightRatio = 0.61197917} },
narration = "The queen tells you she's really bored.",
choices = {
{choiceText = "tell her you know a puppet show", resultScreen = "queenSaysShowMe" } }
},

{name = "queenSaysShowMe",
background = "ccQueenBored",
images = {
{"heroine", "ccHeroine", WIDTH * 0.2246, HEIGHT * 0.576, heightRatio = 0.61197917} },
narration = "You tell the queen you know how to put on a puppet show.\n\rShe says, \"Show me as soon as you can!\"",
choices = {
{choiceText = "leave", resultScreen = "grouchyPuppeteer" } }
},

{name = "grouchyPuppeteer",
background = "ccGenericOutside",
images = {
{"heroineFlipped", "ccHeroineFlipped", WIDTH * 0.68359375, HEIGHT * 0.59635417, heightRatio = 0.61197917},
{"puppeteerGrouchy", "ccPuppeteerGrumpy", WIDTH * 0.31738281, HEIGHT * 0.59635417, heightRatio = 0.67317708} },
narration = "On your way home you see a grouchy puppeteer.",
choices = {
{onlyIfInInventory = "coffee", choiceText = "give him your coffee",
resultScreen = "happyPuppeteer", inventoryRemove = "coffee" },
{choiceText = "go home and practice", resultScreen ="queenNotLike" } }
},

{name = "happyPuppeteer",
background = "ccGenericOutside",
images = {
{"heroineFlipped", "ccHeroineFlipped", WIDTH * 0.67675781, HEIGHT * 0.59635417, heightRatio = 0.61197917},
{"puppeteerHappy", "ccPuppeteerHappy", WIDTH * 0.31738281, HEIGHT * 0.59635417, heightRatio = 0.66145833} },
narration = "He teaches you a new puppet show.",
choices = {
{choiceText = "go home and give up", resultScreen ="homeAndSleep" },
{choiceText = "go show the queen", resultScreen = "queenLovesShow"} }
},

{name = "queenNotLike",
background = "ccQueenNotLike",
images = {
{"heroineWithSockPuppets", "ccHeroineWithSockPuppets", WIDTH * 0.26464844, HEIGHT * 0.55989583, heightRatio = 0.63932292} },
narration = "You practice, but the queen doesn't like your show, and you're embarrassed.",
choices = {
{choiceText = "start over", resultScreen ="firstScreen",
inventoryRemove = "allItems" } }
},

{name = "homeAndSleep",
background = "ccHomeAndSleep",
narration = "You go back home and go to sleep.",
choices = {
{choiceText = "start over", resultScreen ="firstScreen",
inventoryRemove = "allItems" } }
},

{name = "queenLovesShow",
background = "ccQueenLoves",
images = {
{"heroineWithMarionettes", "ccHeroineWithMarionettes", WIDTH * 0.26464844, HEIGHT * 0.57291667, heightRatio = 0.63932292} },
narration = "The queen loves the show!\n\rShe tells you a secret. If you give the princess a heart box with chocolates in it, you will become the new queen.",
choices = {
{choiceText = "choose who to give the heart to", resultScreen ="chooseHeart" } }
},

{name = "chooseHeart",
background = "ccGenericCastleInterior",
images = {
{"princess", "ccPrincess", WIDTH * 0.5, HEIGHT * 0.64453125, heightRatio = 0.72916667},
{"boyfriend", "ccBoyfriend", WIDTH * 0.23730469, HEIGHT * 0.58854167, heightRatio = 0.65885417} },
narration = "Do you give the heart to the princess or your boyfriend?",
choices = {
{choiceText = "princess", resultScreen = "youBecomeQueen",
inventoryRemove = "heartBox"},
{choiceText = "boyfriend", resultScreen ="happyInForest",
inventoryRemove = "heartBox" } }
},

{name = "youBecomeQueen",
background = "ccGenericCastleInterior",
images = {
{"heroineQueened", "ccHeroineQueened", WIDTH * 0.31152344, HEIGHT * 0.58854167, heightRatio = 0.64973958} },
narration = "You become the queen!",
choices = {
{choiceText = "The End", resultScreen ="firstScreen",
inventoryRemove = "allItems" } }
},

{name = "happyInForest",
background = "ccHappyInForest",
images = {
{"happyFamily", "ccHappyFamily", WIDTH * 0.31835938, HEIGHT * 0.42057292, heightRatio = 0.286} },
narration = "You and your boyfriend end up living in a shack in the forest with your kids.\n\rAnd you are happy.",
choices = {
{choiceText = "The End", resultScreen ="firstScreen",
inventoryRemove = "allItems" } }
}
)


]]