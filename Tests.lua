
    --[[
function t  e  s  t  s ()
    
    --testTouch and a function to reset it
    local testTouch = {}
    local resetTestTouch = function()
        testTouch = {}
    end
    
    --when in playModeOverlay, and a touch on the editable mode button is of state BEGIN
    showPlayModeOverlay()
    local detectedTestTouch, correctButtonActivated = false, false
    local editModeButtonName = "to editable mode"
    local buttonTable = uiPieceHandler.buttons["to editable mode"]
    local testTouch = {x=buttonTable.x, y=buttonTable.y}
    testTouch.state = BEGAN
    --then if it is passed to touchIsInside
    detectedTestTouch = uiPieceHandler.touchIsInside(editModeButtonName, testTouch)
    --result is a true value for detectedTestTouch
    print("detectedTestTouch: "..boolToString(detectedTestTouch))
    
    --and then if it is passed to evaluateTouchFor
    uiPieceHandler.evaluateTouchFor(editModeButtonName, testTouch)
    --result is the correct activatedButton
    correctButtonActivated = activatedButton == editModeButtonName
    print("correctButtonActivated: "..boolToString(correctButtonActivated))
    
    --and when the touch moves over a different object
    local playModeButtonName = "to fixed mode"
    local playModeButton = uiPieceHandler.buttons[playModeButtonName]
    testTouch.x, testTouch.y = playModeButton.x, playModeButton.y
    testTouch.state = MOVING
    --then if it is passed to evaluateTouchFor
    uiPieceHandler.evaluateTouchFor(playModeButtonName, testTouch)
    --result is the first object remaining the activatedButton
    correctButtonActivated = activatedButton == editModeButtonName
    print("touching second object preserves activatedButton: "..
        boolToString(correctButtonActivated))
    
    --and when the touch ends outside the button
    local outsideOffsetX, outsideOffsetY = buttonTable.width, buttonTable.height
    local startingX, startingY = buttonTable.x, buttonTable.y
    testTouch.x = buttonTable.x+outsideOffsetX
    testTouch.y = playModeButton.y+outsideOffsetY
    testTouch.state = ENDED
    --then if it is passed to evaluateTouchFor
    uiPieceHandler.evaluateTouchFor(editModeButtonName, testTouch)
    --result is that activatedButton is now nil
    local activatedButtonIsNil = activatedButton == nil
    print("touch ending outside button erases activatedButton: "..
        boolToString(activatedButtonIsNil))
    --and result is that the button has NOT moved
    local buttonInRightPlace = buttonTable.x == startingX and buttonTable.y == startingY
    print("button did not move when it shouldn't: "..boolToString(buttonInRightPlace))
    --and result is button action NOT performed (action = setting editable mode)
    local actionPerformed = currentOverlay == editModeOverlay
    print("action not performed when it shouldn't: "..
        boolToString(actionPerformed == false))
    
    --when playModeOverlay & NOT ui_pieces_are_draggable & touch starts on editable mode button
    showPlayModeOverlay()
    resetTestTouch()
    ui_pieces_are_draggable = false
    testTouch.state = BEGAN
    testTouch.x, testTouch.y = buttonTable.x, buttonTable.y
    uiPieceHandler.evaluateTouchFor(editModeButtonName, testTouch)
    --then if it also ends on that button
    testTouch.state = ENDED
    uiPieceHandler.evaluateTouchFor(editModeButtonName, testTouch)
    --result is that activatedButton is now nil
    activatedButtonIsNil = activatedButton == nil
    print("touch ending inside button erases activatedButton: "..
        boolToString(activatedButtonIsNil))
    --and result is Overlay is in editable mode 
    actionPerformed = currentOverlay == editModeOverlay
    print("action performed when it should in fixed mode: "..
        boolToString(actionPerformed))
    
    --and when buttons are draggable and a touch starts on the fixed mode button
    resetTestTouch()
    showEditModeOverlay()
    testTouch = {x=buttonTable.x, y=buttonTable.y}
    testTouch.state = BEGAN
    uiPieceHandler.evaluateTouchFor(playModeButtonName, testTouch)
    --then if the touch moves
    testTouch.x = playModeButton.x-outsideOffsetX
    testTouch.y = playModeButton.y-outsideOffsetY
    testTouch.state = MOVING
    uiPieceHandler.evaluateTouchFor(playModeButtonName, testTouch)
    --result is that button has moved along with it
    local rightX = playModeButton.x == testTouch.x
    local rightY = playModeButton.y == testTouch.y
    buttonInRightPlace = rightX and rightY
    print("button moved when it should for MOVING state: "..
        boolToString(buttonInRightPlace))
    --then if the touch moves more and ends
    startingX, startingY = playModeButton.x, playModeButton.y
    testTouch.x, testTouch.y = testTouch.x+outsideOffsetX, testTouch.y+outsideOffsetY
    testTouch.state = ENDED
    uiPieceHandler.evaluateTouchFor(playModeButtonName, testTouch)
    --result is that button has moved along with it
    buttonInRightPlace = playModeButton.x == startingX and playModeButton.y == startingY
    print("button didn't move for ENDED state: "..boolToString(buttonInRightPlace))
    
    --at the end of te____=sts, reset all the default button values
    defineMainButtons()
end

]]
