
--[[
--showFirstScreen sets the currentScreen (will be loaded from a saved value in the future)
function showFirstScreen() 
    if currentScreen == nil then
        --currentScreen = sampleScreenA
        currentScreen = rosieStart
    end
end

--showFirstOverlay sets the currentOverlay (will be loaded from a saved value in the future)
function showFirstOverlay()
    --report("showing Overlay")
    if currentOverlay == nil then
        choicesActive = false
        --currentOverlay = introductionOverlay
        currentOverlay = function() end
    end
end

]]
--defineMainButtons sets up the main buttons for sample screens and UI.  
--this means changes made to these in editable mode will not persist between sessions
--[[function defineMainButtons()
    
    --button for introductionOverlay: activates editable mode
    uiPieceHandler.buttons['welcome'] = 
        {x = 502.5, y = 384.5, width=uiPieceHandler.defaultWidth, 
        height=uiPieceHandler.defaultHeight, 
        action = function() 
                showPlayModeOverlay()
                choicesActive = true
        end}

    --button for toggling editableMode
    uiPieceHandler.buttons['to editable mode'] = 
        {x = 928.5, y = 729.0, width=uiPieceHandler.defaultWidth, 
        height=uiPieceHandler.defaultHeight, 
        action = showEditModeOverlay}
    
    --button for toggling fixed mode
    uiPieceHandler.buttons['to fixed mode'] = 
        {x = 932.5, y = 727.5, width=uiPieceHandler.defaultWidth, 
        height=uiPieceHandler.defaultHeight, 
        action = showPlayModeOverlay}
 
    --button for resetting sample game, used by both end screens
    uiPieceHandler.buttons['reset sample game'] = 
        {x = 865.0, y = 248.5, width=uiPieceHandler.defaultWidth, 
        height=uiPieceHandler.defaultHeight, 
        action = uiPieceHandler.defaultButtonAction}
    
    --buttonTable definition for "you lose" text area
    uiPieceHandler.buttons['you lost sample game'] = 
        {x = 865.0, y = 315.5, width=uiPieceHandler.defaultWidth, 
        height=uiPieceHandler.defaultHeight, 
        action = uiPieceHandler.defaultButtonAction}
    
    --buttonTable definition for "you win" text area
    uiPieceHandler.buttons['you won sample game'] = 
        {x = 861.5, y = 319.0, width=uiPieceHandler.defaultWidth, 
        height=uiPieceHandler.defaultHeight, 
        action = uiPieceHandler.defaultButtonAction}
    
    --button for losing sample game, used on the start screen of the sample game
    uiPieceHandler.buttons['lose sample game'] = 
        {x = 860.0, y = 167.5, width=uiPieceHandler.defaultWidth, 
        height=uiPieceHandler.defaultHeight, 
        action = uiPieceHandler.defaultButtonAction}
    
    --buttonTable definition for start screen text area
    uiPieceHandler.buttons['sample game start screen'] = 
        {x = 860.5, y = 321.0, width=uiPieceHandler.defaultWidth, 
        height=uiPieceHandler.defaultHeight, 
        action = uiPieceHandler.defaultButtonAction}
    
    --button for winning sample game, used on the start screen of the sample game
    uiPieceHandler.buttons['win sample game'] = 
        {x = 860.0, y = 244.0, width=uiPieceHandler.defaultWidth, 
        height=uiPieceHandler.defaultHeight, 
        action = uiPieceHandler.defaultButtonAction}
end ]]--
