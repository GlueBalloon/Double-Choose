rosieImages = {}
rosieImages.first = readImage(asset.documents.rcFirst)
rosieImages.theAdventureis = readImage(asset.documents.theAdventureIs)
rosieImages.sleepForDays = readImage(asset.documents.rcSleepForDays)
rosieImages.boyfriendAsks = readImage(asset.documents.rcBoyfriendAsks)
rosieImages.boyfriendWithNote = readImage(asset.documents.rcBoyfriendWithNote)
rosieImages.breakup = readImage(asset.documents.rcBreakup)
rosieImages.helpEverybody = readImage(asset.documents.rcHelpEverybody)
rosieImages.queenAsksYouToDeliver = readImage(asset.documents.rcQueenAsksYouToDeliver)
rosieImages.deliverAllInvitations = readImage(asset.documents.rcDeliverAllInvitations)
rosieImages.everybodysDisappointed = readImage(asset.documents.rcEverybodysDisappointed)
rosieImages.secretOrQueen = readImage(asset.documents.rcSecretOrQueen)
rosieImages.tellYourSecret = readImage(asset.documents.rcTellYourSecret)
rosieImages.youreQueen = readImage(asset.documents.rcYoureQueen)
    
function rosieGameInfo()
    drawBackground(rosieImages.first)
    --tinted overlay
    pushStyle()
    fill(19, 161)
    strokeWidth(0)
    rect(WIDTH/2, HEIGHT/2, WIDTH + 4, HEIGHT + 4)
    popStyle()
    --info
    pushStyle()
    fontSize(WIDTH * 0.025)
    textWrapWidth(WIDTH * 0.73)
    fill(55, 161)
    button([[Rosie designed, wrote, and drew this little story game when she was 9. 
    
It's a game where the real fun is losing!
    
To get the most out of it, try to find all of the excellent emotional torments Rosie makes the heroine endure.
    
Both girls roughly copied the plot of the game that inspired this, 'The Story of Choices' by Behold Studios. But they each put their own spin on it, giving us a unique glimpse of the kinds of things that were rolling around in their young minds at the time.]], rosieStart, WIDTH/2, HEIGHT/2)
    popStyle()
end
    
function rosieFirstScreenDecider()
    if not readLocalData("infoShown") then
        currentScreen = rosieGameInfo
        saveLocalData("infoShown", "true")
    else
        currentScreen = rosieStart
    end
end

function rosieStart()
    drawBackground(rosieImages.first)
    textArea("Do you want to have an adventure?")
    choice("adventure", theAdventureIs)
    choice("stay in bed", sleepForDays)
    pushStyle()
    stroke(0, 0)
    font("Inconsolata")
    fontSize(fontSize() * 1.015)
  --  fill(236, 228, 228, 201)
    local textColor = color(0, 177)
    button("x", nil, nil, nil, nil, nil, nil, nil, 15)
    button("i",nil, nil, nil, nil, nil, nil, nil, 15)
    popStyle()
end

function theAdventureIs()
    drawBackground(rosieImages.theAdventureis)
    textArea("The adventure is: help everybody!")
    choice("first go see your boyfriend", boyfriendAsks)
end

function sleepForDays()
    drawBackground(rosieImages.sleepForDays)
    textArea("You sleep for days and days and end up hated by everybody.",narrationWidth,narrationHeight)
    choice("The End", rosieStart)
end

function boyfriendAsks()
    drawBackground(rosieImages.boyfriendAsks)
    textArea("Your boyfriend says, "..'"'.."Do you want to know my secret, or do you want to break up?"..'"',narrationWidth,narrationHeight)
    choice("break up", breakup)
    choice("secret", boyfriendWithNote)
end

function boyfriendWithNote()
    drawBackground(rosieImages.boyfriendWithNote)
    textArea('He says "My secret is this note I need to get to my sister somehow."',narrationWidth,narrationHeight)
    choice("send note for him", helpEverybody)
end

function breakup()
    drawBackground(rosieImages.breakup)
    textArea('You break up and he gets a girlfriend prettier than you and you cry.',narrationWidth,narrationHeight)
    choice("The End!", rosieStart)
end

function helpEverybody()
    drawBackground(rosieImages.helpEverybody)
    textArea("First, you send your boyfriend's note. Then you help everybody!",narrationWidth,narrationHeight)
    choice("good job", queenAsksYouToDeliver)
end

function queenAsksYouToDeliver()
    drawBackground(rosieImages.queenAsksYouToDeliver)
    textArea('For doing such a good job, the Queen says you should be Queen, but only if you deliver some birthday invitations for her.',narrationWidth,narrationHeight)
    choice("deliver", deliverAllInvitations)
    choice("don't deliver", everybodysDisappointed)
end

function deliverAllInvitations()
    drawBackground(rosieImages.deliverAllInvitations)
    textArea('You deliver all the invitations!',narrationWidth,narrationHeight)
    choice("go back to Queen", secretOrQueen)
end

function everybodysDisappointed()
    drawBackground(rosieImages.everybodysDisappointed)
    textArea("You never get famous and everybody's disappointed because they wanted you to be Queen.",narrationWidth,narrationHeight)
    choice("The End :(", rosieStart)
end

function secretOrQueen()
    drawBackground(rosieImages.secretOrQueen)
    textArea('The Queen asks: "Do you have a secret or do you want to be Queen?"',narrationWidth,narrationHeight)
    choice("reveal your secret", tellYourSecret)
    choice("become Queen", youreQueen)
end

function tellYourSecret()
    drawBackground(rosieImages.tellYourSecret)
    textArea('You tell your secret: "I didn'.."'"..'t really want to help anybody." The people kick you out and you lose.',narrationWidth,narrationHeight)
    choice("...the end...", rosieStart)
end

function youreQueen()
drawBackground(rosieImages.youreQueen)
    textArea("You're Queen!",narrationWidth,narrationHeight)
    choice("Start over", rosieStart)
end


