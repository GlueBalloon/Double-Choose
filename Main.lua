-- Double Choose, but redone with better UI and cleaner code
-- The great code for rounded rectangles with transparent-blur backgrounds is pulled from yojimbo2000's amazing SODA project

viewer.mode = OVERLAY
supportedOrientations(LANDSCAPE_ANY)
 
function setup()
    --monitor performance
    profiler.init()
    --toggle for reporting debug messages
    --setReporting(true)
    --set global styles
    rectMode(CENTER)
    font("HelveticaNeue-Light")
    fontSize(35)
    stroke(255, 255, 255, 255)
    strokeWidth(1)
    fill(255, 255, 255, 255)
    --[[
    --set starting state
    showFirstScreen()
    showFirstOverlay()
    
    --create win and lose screens
    winScreen = image(WIDTH,HEIGHT)
    setContext(winScreen)
    background(255, 231, 0, 255)
    sprite("SpaceCute:Star", WIDTH / 2, HEIGHT/2,WIDTH,HEIGHT)
    setContext()
    loseScreen = image(WIDTH,HEIGHT)
    setContext(loseScreen)
    background(73, 30, 33, 255)
    sprite("Tyrian Remastered:Flame Wave", WIDTH / 2, HEIGHT/2,WIDTH,HEIGHT)
    setContext()
    ]]
    
    --setRosiesImages()
    --[[
    startScreen = screenSizedImage(readImage(asset.documents.rcFirst))
    uiPieceHandler.backgroundImage = startScreen
    ]]
    currentOverlay = orientationOverlay
    currentScreen = rosieStart
    screenChangeTime = os.time()
    uiPieceHandler.shouldUpdateScreenBlur = true --needs to be called before the new background is first drawn I think
    currentScreen = mainMenu
    --currentOverlay = function() end
    music(asset.documents["Choices_rumble-2.mp3"],true)    
end


function draw()
    profiler.draw()
    currentScreen()
    if currentOverlay then
        currentOverlay()
    end
end

--measure performance:

profiler={}

function profiler.init(quiet)
    profiler.del=0
    profiler.c=0
    profiler.fps=0
    profiler.mem=0
    if not quiet then
        parameter.watch("profiler.fps")
        parameter.watch("profiler.mem")
    end
end

function profiler.draw()
    profiler.del = profiler.del +  DeltaTime
    profiler.c = profiler.c + 1
    if profiler.c==10 then
        profiler.fps=profiler.c/profiler.del
        profiler.del=0
        profiler.c=0
        profiler.mem=collectgarbage("count", 2)
    end
end
