-- uiPieceHandler: provides various functions for UI pieces:
--  enables pieces to be initialized with defaults
--  manages how pieces look and behave

deviceWnH = vec2(math.max(WIDTH, HEIGHT), math.min(WIDTH, HEIGHT))
adjstmt = vec2(deviceWnH.x / 1366, deviceWnH.y / 1024)

uiPieceHandler = {}
uiPieceHandler.fontSizeDefault = deviceWnH.x * 0.028
uiPieceHandler.defaultWidth = 160
uiPieceHandler.defaultHeight = 80
uiPieceHandler.defaultFontColor = color(255)
uiPieceHandler.buttons = {}
uiPieceHandler.shouldUpdateScreenBlur = true
uiPieceHandler.backgroundImage = 0 --not sure how this will be set irl
uiPieceHandler.screenBlur = 0 --0 means "none drawn yet"; will normally be an image
uiPieceHandler.narrationW = deviceWnH.x / 2.45
uiPieceHandler.narrationH = deviceWnH.y / 2.17
uiPieceHandler.narrationX = deviceWnH.x - (uiPieceHandler.narrationW / 2) - 66
uiPieceHandler.narrationY = deviceWnH.y / 2.1
uiPieceHandler.narrationWrap = uiPieceHandler.narrationW * 0.84
--specify the size of the choice buttons
uiPieceHandler.choiceW = uiPieceHandler.narrationW
uiPieceHandler.choiceH = deviceWnH.y / 8.5
--align the horizontal position of the buttons with the narration box
uiPieceHandler.choice1X = uiPieceHandler.narrationX
uiPieceHandler.choice2X = uiPieceHandler.choice1X
uiPieceHandler.choice1Y = uiPieceHandler.narrationY - (uiPieceHandler.narrationH / 2) - 95
uiPieceHandler.choice2Y = uiPieceHandler.choice1Y - uiPieceHandler.choiceH - 21

parameter.boolean("ui pieces are draggable", false)

--[[
from OG Double Choose:
self.narrationW = WIDTH / 2.15
self.narrationH = HEIGHT / 3.4
self.narrationX = WIDTH - (self.narrationW / 2) - 35
self.narrationY = HEIGHT / 2.9
--specify the size of the choice buttons
self.choiceW = self.narrationW
self.choiceH = HEIGHT / 13.9
--align the horizontal position of the buttons with the narration box
self.choice1X = self.narrationX
self.choice2X = self.choice1X
]]--

uiPieceHandler.defaultButton = function(name)
    uiPieceHandler.buttons[name] = {x=math.random(WIDTH),y=math.random(HEIGHT), 
    width = uiPieceHandler.defaultWidth, height = uiPieceHandler.defaultHeight,
    fontColor = uiPieceHandler.defaultFontColor,
    didRenderAlready = false}
    return uiPieceHandler.buttons[name]
end

uiPieceHandler.defaultButtonAction = function()
    print("use 'buttonAction(name, action)' to define an action for this button")
end

uiPieceHandler.doAction = function(name)
    if uiPieceHandler.buttons[name].action == nil then
        return
    else
        uiPieceHandler.buttons[name].action()
    end
end

uiPieceHandler.explicitColorFromFill = function()
    local r, g, b, a = fill()
    return color(r, g, b, a)
end

--evaluateTouchFor: called by each button inside the button() function
--precondition: to use CurrentTouch, pass nothing to the touch value
--postcondition: one of these:
--  a new activatedButton is set (if touch began on this piece)
--  activatedButton has been cleared (touch ended)
--  a button tap has occurred (for detecting button presses in editable mode)
--  a button has been moved (activatedButton was dragged in editable mode)
--  nothing (this piece did not interact with the touch)
uiPieceHandler.evaluateTouchFor = function(name, touch)
    if touch == nil then
        touch = CurrentTouch
    end
    if uiPieceHandler.thisButtonIsActivated(name, touch) then
        uiPieceHandler.makeActivatedButtonRespond(name, touch)
    end
end

--thisButtonIsActivated: called to decide if this button should respond to this touch
--precondition: name and touch cannot be nil
--postconditions: 
--  activatedButton has been set or unchanged (note that it is never cleared here)
--  boolean returned true if the given button is the activatedButton, false if not
uiPieceHandler.thisButtonIsActivated = function(name, touch)
    --if there is already an activatedButton and this isn't it, return false
    if activatedButton ~= nil and activatedButton ~= name then
        return false
    end
    --if there is no activatedButton, see if this should become activatedButton
    if activatedButton == nil then
        --if touch state is BEGAN and touch is inside button, set it to activatedButton
        if touch.state == BEGAN and uiPieceHandler.touchIsInside(name, touch) then
            activatedButton = name
        else
            --otherwise return false
            return false
        end
    end
    --here only reached if this is activated button (or has become it), so return true
    return true
end

--uiPieceHandler.touchIsInside: calculated using touch's distance from this piece
--preconditions: name and touch cannot be nil, and touched object is basically rectangular
uiPieceHandler.touchIsInside = function(name, touch) 
    local xDistance = math.abs(touch.x-uiPieceHandler.buttons[name].x * adjstmt.x)
    local yDistance = math.abs(touch.y-uiPieceHandler.buttons[name].y * adjstmt.y)
    insideX = xDistance < uiPieceHandler.buttons[name].width / 2 * adjstmt.x
    insideY = yDistance < uiPieceHandler.buttons[name].height / 2 * adjstmt.y
    if insideX and insideY then
        return true
    else
        return false
    end
end

--makeActivatedButtonRespond: decide how the given button should react to given touch
--precondition: button and touch cannot be nil, button must be activatedButton
uiPieceHandler.makeActivatedButtonRespond = function(name, touch)
    --move button if it should be moved
    if ui_pieces_are_draggable then
        uiPieceHandler.evaluateDrag(name, touch)
    end
    --if this is an end touch, do a button action, or save new position, or do nothing
    if touch.state == ENDED then
        if ui_pieces_are_draggable then
            if touch.tapCount == 1 then
                uiPieceHandler.doAction(name)
            else
                --report("saving buttons positions")
                uiPieceHandler.savePositions()
            end
        elseif uiPieceHandler.touchIsInside(name, touch) then
            uiPieceHandler.doAction(name)
            --report(name, uiPieceHandler.buttons[name].action)
        end
        activatedButton = nil
    end    
end

uiPieceHandler.evaluateDrag = function (name, touch)
    if touch.state == MOVING then
        uiPieceHandler.buttons[name].x = touch.x / adjstmt.x
        uiPieceHandler.buttons[name].y = touch.y / adjstmt.y
    end
end

uiPieceHandler.savePositions = function (name, position)
    dataString = ""
    for name, buttonValues in pairs(uiPieceHandler.buttons) do
        dataString = dataString.."uiPieceHandler.buttons[ [["..name.."]] ] = \n"
        dataString = dataString.."    {x = "..buttonValues.x
        dataString = dataString..", y = "..buttonValues.y..",\n"
        dataString = dataString.."    width="..buttonValues.width..", "
        dataString = dataString.."height="..buttonValues.height..",\n"
        dataString = dataString.."    fontColor=color("..buttonValues.fontColor.r..","
        dataString = dataString..buttonValues.fontColor.g..","
        dataString = dataString..buttonValues.fontColor.b..","
        dataString = dataString..buttonValues.fontColor.a.."),\n"
        dataString = dataString.."    action = uiPieceHandler.defaultButtonAction}\n\n"
    end
    saveProjectTab("uiPieceTables",dataString)
    print("uiPieceHandler.savePositions: saved")
end

uiPieceHandler.fontSizeForRect = function(textToFit, w, h)
    local fSize, fontSizeNotSet = 0, true
    pushStyle()
    textWrapWidth(w)
    while fontSizeNotSet do
        fontSize(fSize)
        local _, boundsY = textSize(textToFit)
        if boundsY < h then
            fSize = fSize + 0.01
        elseif boundsY > h then
            fSize = fSize - 0.01
            fontSizeNotSet = false
        else                
            fontSizeNotSet = false
        end
    end    
    popStyle()
    return fSize 
end

uiPieceHandler.textFitToRect = function(textToFit, x, y, w, h) 
    bounds = bounds
    local fSize, fontSizeNotSet, testString, acceptableInset
    fSize = fontSize()
    fontSizeNotSet = true
    testString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-/:;()$&@.,?!'[]{}#%^*+=_\\|~<>€£¥•\""
    
    pushStyle()
    rectMode(CENTER)
    textWrapWidth(w)
    while fontSizeNotSet do
        bounds = vec2(textSize(textToFit))
        pushStyle()
        textWrapWidth(500000000)
        _, acceptableInset = textSize(testString)
        popStyle()
        if math.floor(bounds.y) < math.floor(h - acceptableInset) then
            fSize = fSize + 0.1
        elseif math.floor(bounds.y) > math.floor(h) then
            fSize = fSize - 0.1
        else                
            fontSizeNotSet = false
        end
        fontSize(fSize)
    end    
    text(textToFit, x, y)
    popStyle()
end