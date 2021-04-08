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
    
function rosieStart()
    drawBackground(rosieImages.first)
    textArea("Do you want to have an adventure?")
    choice("adventure", theAdventureIs)
    choice("stay in bed", sleepForDays)
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


