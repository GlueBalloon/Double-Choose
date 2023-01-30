
-- simpleButtons: provides various functions for UI pieces:

--  enables pieces to be initialized with defaults

--  manages how pieces look and behave

simpleButtons = {}
simpleButtons.ui = {}
simpleButtons.standardLineHeight = function() 
    pushStyle()
    textWrapWidth(0)
    _, lineHeight = textSize("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    popStyle()
    return lineHeight
end
simpleButtons.buttonDimensionsFor = function(thisText) 
    local boundsW, boundsH = textSize(thisText)
    lineHeight = simpleButtons.standardLineHeight()
    boundsW = boundsW + (lineHeight * 1.8)
    boundsH = boundsH + lineHeight 
    return boundsW, boundsH
end

simpleButtons.baseFontSize = math.max(WIDTH, HEIGHT) * 0.027
simpleButtons.cornerRadius = simpleButtons.baseFontSize * 1.25
simpleButtons.marginPaddingH = simpleButtons.baseFontSize * 0.55
simpleButtons.marginPaddingW = simpleButtons.baseFontSize
simpleButtons.useGrid = false
simpleButtons.gridSpacing = math.min(WIDTH, HEIGHT) / 120

simpleButtons.hasCheckedForDependency = false
simpleButtons.isBeingRunAsDependency = function()
    local tabExists = false
    local localTabs = listProjectTabs()
    for _, tabName in ipairs(localTabs) do
        if tabName == "ButtonTables" then tabExists = true end
    end
    if tabExists then
        local tabData = readProjectTab("ButtonTables")
        local tabsMatch = tabData ~= readProjectTab("SimpleButtons:ButtonTables")
        return tabsMatch, tabData
    else
        return true
    end
end
simpleButtons.loadLocalTabIfDependency = function()
    local isDependency, localTabData = simpleButtons.isBeingRunAsDependency() 
    if isDependency and localTabData ~= nil then
        local dataLoader = load(localTabData)
        dataLoader()
    end
    simpleButtons.hasCheckedForDependency = true
end

simpleButtons.secondLineInfoFrom = function(traceback)
    local iterator = string.gmatch(traceback,"(%g*):(%g*): in function '(%g*)'")
    iterator() -- not interested in first line bc it'll always be from here
    local tab, lineNumber, functionName = iterator()
    return {tab = tab, functionName = functionName, lineNumber = functionName, all = tab..","..functionName..","..lineNumber}
end

simpleButtons.screenBlur = 0 --0 means "none drawn yet"; will normally be an image
simpleButtons.shouldUpdateScreenBlur = true

parameter.boolean("buttons are draggable", false)
parameter.boolean("snap_to_grid", false, function()
    simpleButtons.useGrid = snap_to_grid
end)


simpleButtons.defaultButton = function(bText, traceback)
    simpleButtons.ui[traceback] = {text=bText,
    x=0.5, y=0.5, action=simpleButtons.defaultButtonAction,
    didRenderAlready = false}
    return simpleButtons.ui[traceback]
end

simpleButtons.explicitColorFromFill = function()
    local r, g, b, a = fill()
    return color(r, g, b, a)
end


simpleButtons.defaultButtonAction = function()
    print("this is the default button action")
end


simpleButtons.doAction = function(traceback)
    if simpleButtons.ui[traceback].action == nil then
        return
    else
        simpleButtons.ui[traceback].action()
    end
end

simpleButtons.fontSizeForRect = function(textToFit, w, h)
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

simpleButtons.textFitToRect = function(textToFit, x, y, w, h) 
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

--evaluateTouchFor: called by each button inside the button() function
--precondition: to use CurrentTouch, pass nothing to the touch value
--postcondition: one of these:
--  a new activatedButton is set (if touch began on this piece)
--  activatedButton has been cleared (touch ended)
--  a button tap has occurred (for detecting button presses in editable mode)
--  a button has been moved (activatedButton was dragged in editable mode)
--  nothing (this piece did not interact with the touch)
simpleButtons.evaluateTouchFor = function(traceback, touch)
    if touch == nil then
        touch = CurrentTouch
    end
    if simpleButtons.thisButtonIsActivated(traceback, touch) then
        simpleButtons.makeActivatedButtonRespond(traceback, touch)
    end
end

--thisButtonIsActivated: called to decide if this button should respond to this touch
--precondition: name and touch cannot be nil
--postconditions:
--  activatedButton has been set or unchanged (note that it is never cleared here)
--  boolean returned true if the given button is the activatedButton, false if not
simpleButtons.thisButtonIsActivated = function(traceback, touch)
    --if there is already an activatedButton and this isn't it, return false
    if activatedButton ~= nil and activatedButton ~= traceback then
        return false
    end
    --if there is no activatedButton, see if this should become activatedButton
    if activatedButton == nil then
        --if touch state is BEGAN and touch is inside button, set it to activatedButton
        if touch.state == BEGAN and simpleButtons.touchIsInside(traceback, touch) then
            activatedButton = traceback
        else
            --otherwise return false
            return false
        end
    end
    --here only reached if this is activated button (or has become it), so return true
    return true
end

--simpleButtons.touchIsInside: calculated using touch's distance from this piece
--preconditions: name and touch cannot be nil, and touched object is basically rectangular
simpleButtons.touchIsInside = function(traceback, touch)
    local adjX, adjY = simpleButtons.ui[traceback].x*WIDTH, simpleButtons.ui[traceback].y*HEIGHT
    local xDistance = math.abs(touch.x-adjX)
    local yDistance = math.abs(touch.y-adjY)
    insideX = xDistance < simpleButtons.ui[traceback].width /2
    insideY = yDistance < simpleButtons.ui[traceback].height /2
    if insideX and insideY then
        return true
    else
        return false
    end
end

--makeActivatedButtonRespond: decide how the given button should react to given touch
--precondition: button and touch cannot be nil, button must be activatedButton
simpleButtons.makeActivatedButtonRespond = function(traceback, touch)
    --move button if it should be moved
    if buttons_are_draggable then
        simpleButtons.evaluateDrag(traceback, touch)
    end
    if touch.state == BEGAN or touch.state == MOVING then
        simpleButtons.ui[traceback].isTapped = true
    end
    --if this is an end touch, do a button action, or save new position, or do nothing
    if touch.state == ENDED or touch.state == CANCELLED or not touch then
        if buttons_are_draggable then
            if touch.tapCount == 1 then
                simpleButtons.ui[traceback].isTapped = true
                simpleButtons.doAction(traceback)
            else
                simpleButtons.savePositions()
            end
        elseif simpleButtons.touchIsInside(traceback, touch) then
            simpleButtons.ui[traceback].isTapped = true
            simpleButtons.doAction(traceback)
        end
        activatedButton = nil
    end
end

simpleButtons.evaluateDrag = function (traceback, touch)
    if touch.state == MOVING then
        local x,y = touch.x, touch.y
        --rounds x and y if using grid
        if simpleButtons.useGrid then
            local gridSpacing = simpleButtons.gridSpacing
            x = touch.x + gridSpacing - (touch.x + gridSpacing) % (gridSpacing * 2) 
            y = touch.y + gridSpacing - (touch.y + gridSpacing) % (gridSpacing * 2)
        end   
        --make x and y into percentages of width and height
        x, y = x / WIDTH, y / HEIGHT
        --store x and y on tables
        simpleButtons.ui[traceback].x = x
        simpleButtons.ui[traceback].y = y
    end
end


simpleButtons.savePositions = function ()
    local dataString = ""
    for traceback, ui in pairs(simpleButtons.ui) do
        dataString = dataString.."simpleButtons.ui[ [["..traceback.."]] ] = \n"
        dataString = dataString.."    {text = [["..ui.text.."]],\n"
        dataString = dataString.."    x = "..ui.x
        dataString = dataString..", y = "..ui.y..",\n"
        dataString = dataString.."    width = "..(ui.width or "nil")
        dataString = dataString..", height = "..(ui.height or "nil")..",\n"
        dataString = dataString.."    action = simpleButtons.defaultButtonAction\n}\n\n"
    end
    saveProjectTab("ButtonTables",dataString)
end

--button only actually needs a name to work, the rest have defaults
function button(bText, action, x, y, width, height, fontColor, imageAsset, radius)
    if simpleButtons.hasCheckedForDependency == false then
        simpleButtons.loadLocalTabIfDependency()
    end
    --get traceback info 
    --buttons have to be indexed by traceback
    --this lets different buttons have the same texts
    local trace = debug.traceback()
    --check for existing table matching key
    local tableToDraw = simpleButtons.ui[trace]
    --reject the table if the text doesn't match, though
    if tableToDraw and tableToDraw.text ~= bText then
        --store table that was found under a modified key, so table doesn't get overwritten, for inspection later
        local newKey = trace.."+"..tableToDraw.text
        simpleButtons.ui[newKey] = tableToDraw
        tableToDraw = nil
    end
    --if there's no matching table look for an identical one
    if not tableToDraw then
        --Make a function to replace any identical table found
        function setTableToDrawUsingNewId(newId, tableToUpdate, oldId)            
            --update table to use new traceback id
            simpleButtons.ui[newId] = tableToUpdate
            --clear the old traceback id
            simpleButtons.ui[oldId] = nil
            --and set this as tableToDraw
            tableToDraw = simpleButtons.ui[newId]
        end
        --find any buttons that match text
        local textMatches = {}
        for k, buttonTable in pairs(simpleButtons.ui) do
            if buttonTable.text == bText then
                if type(k) == "string" then
                    table.insert(textMatches, buttonTable)
                    --add table's key to table (won't be stored permanently, so no worries)
                    buttonTable.key = k
                end
            end
        end 
        --if only 1 button matches text, use its values but replace its key
        if #textMatches == 1 then
            setTableToDrawUsingNewId(trace, textMatches[1], textMatches[1].key)  
            --if more than one button matches text
        elseif #textMatches > 1 then 
            --find out how many match this tab and function
            local matchers = {}
            for _, buttonTable in ipairs(textMatches) do
                --extract the tab and functiom
                local tab, functionName = string.gmatch(buttonTable.key,"(%g*),(%g*),")()
                --compare to current
                if tab == trace.tab and functionName == trace.functionName then 
                    --store matches
                    table.insert(matchers, buttonTable)
                end
            end
            --if only 1 button matches tab and function and text, use it
            if #matchers == 1 then
                setTableToDrawUsingNewId(trace, matchers[1], matchers[1].key)  
                --if more than one button matches tab and function and text
            elseif #matchers > 1 then 
                --just gonna have to guess!
                --find the first one without an 'assigned' value
                for _, buttonTable in ipairs(matchers) do 
                    if not buttonTable.assigned then 
                        --update it to use *this* traceback id
                        setTableToDrawUsingNewId(trace, buttonTable, buttonTable.key)
                        
                        if buttonTable[trace] == nil or simpleButtons.ui[trace] == nil then
                        print(buttonTable[trace])
                        print(simpleButtons.ui[trace])
                            end
                        
                        --mark it 'assigned'
                        simpleButtons.ui[trace].assigned = true
                    end
                end 
            end
        end
    end
    --if there's still not a tableToDraw, make a new one
    if not tableToDraw or tableToDraw.text ~= bText then
        tableToDraw = simpleButtons.defaultButton(bText, trace)
    end
    tableToDraw.specTable = specTable
    --if x and y were explicitly stated, they should be ordinary numbers
    --so make them into percentages
    if x then x = x/WIDTH end
    if y then y = y/HEIGHT end
    --get the bounds of the button text if any dimension is undefined
    local boundsW, boundsH, lineHeight
    if width == nil or height == nil then
        boundsW, boundsH = textSize(bText)
        _, lineHeight = textSize("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    end
    width = width or boundsW + (simpleButtons.marginPaddingW * 2)
    height = height or boundsH + (simpleButtons.marginPaddingH * 2)
    --set empty specTable if none
    specTable = specTable or {}
    --set button drawing values, using saved values if none passed in
    --the saved values should already be percentages
    local x,y = x or tableToDraw.x, y or tableToDraw.y
    --update the stored values if necessary
    if x ~= tableToDraw.x or y ~= tableToDraw.y or 
    width ~= tableToDraw.width or height ~= tableToDraw.height then 
        simpleButtons.ui[trace].x = x
        simpleButtons.ui[trace].y = y
        simpleButtons.ui[trace].width = width
        simpleButtons.ui[trace].height = height
    end
    
    --can't use fill() as font color so default to white
    fontColor = fontColor or color(255)
    
    --'action' is called outside of this function
    if action then
        simpleButtons.ui[trace].action = action
    end
    
    --get the actual x and y from the percentages
    x, y = x*WIDTH, y*HEIGHT
    
    pushStyle()
    
    local startingFill = color(fill())
    if tableToDraw.isTapped == true and not specTable.isWindow then
        fill(fontColor)
        stroke(startingFill)
    end
    
    --prepare blur and/or image
    local texture, texCoordinates = nil, nil
    if simpleButtons.screenBlur ~= 0 then 
        texture = simpleButtons.screenBlur
        texCoordinates = vec4(x,y,width,height)
    end
    if imageAsset ~= nil then
        texture = nil
        texCoordinates = nil
        pushStyle()
        fill(236, 76, 67, 0)
        stroke(236, 76, 67, 0)
    end
    
    --draw button
    roundedRectangle{
        x=x,y=y,w=width,h=height,radius=radius or simpleButtons.cornerRadius,
        tex=texture,
        texCoord=texCoordinates}
    
    --draw the text
    
    if tableToDraw.isTapped == true then
        fill(startingFill)
    else
        fill(fontColor)
    end
    --if there's an image, draw only that
    if imageAsset ~= nil then
        popStyle()
        sprite(imageAsset, x, y, width, height)
    else --otherwise draw text
        fontSize(simpleButtons.baseFontSize)
        text(bText, x, y)
        popStyle()
    end
    simpleButtons.ui[trace].isTapped = false
    --handle touches (wherein action gets called or not)
    simpleButtons.evaluateTouchFor(trace)
    --set the flag that shows we rendered (used with blurring)
    simpleButtons.ui[trace].didRenderAlready = true
    return simpleButtons.ui[trace]
end

--button only actually needs a name to work, the rest have defaults
--[[function button(bText, action, width, height, fontColor, x, y, specTable, imageAsset)
    --TODO: make parameter list into varargs and detect image and color?
    local newButtonFlag = false
    --get traceback info 
    --buttons have to be indexed by traceback
    --this lets different buttons have the same texts
    local trace = simpleButtons.secondLineInfoFrom(debug.traceback())
    --check for existing table matching key
    local tableToDraw = simpleButtons.ui[trace.all]
    --reject the table if the text doesn't match, though
    if tableToDraw and tableToDraw.text ~= bText then
        --store table that was found under a modified key, so table doesn't get overwritten, for inspection later
        local newKey = trace.all.."+"..tableToDraw.text
        simpleButtons.ui[newKey] = tableToDraw
        tableToDraw = nil
    end
    --if there's no matching table look for an identical one
    if not tableToDraw then
        --Make a function to replace any identical table found
        function setTableToDrawUsingNewId(newId, tableToUpdate, oldId)            
            --update table to use new traceback id
            simpleButtons.ui[newId] = tableToUpdate
            --clear the old traceback id
            simpleButtons.ui[oldId] = nil
            --and set this as tableToDraw
            tableToDraw = simpleButtons.ui[newId]
        end
        --find any buttons that match text
        local textMatches = {}
        for k, buttonTable in pairs(simpleButtons.ui) do
            if buttonTable.text == bText then
                if type(k) == "string" then
                    table.insert(textMatches, buttonTable)
                    --add table's key to table (won't be stored permanently, so no worries)
                    buttonTable.key = k
                end
            end
        end 
        --if only 1 button matches text, use its values but replace its key
        if #textMatches == 1 then
            setTableToDrawUsingNewId(trace.all, textMatches[1], textMatches[1].key)  
            --if more than one button matches text
        elseif #textMatches > 1 then 
            --find out how many match this tab and function
            local matchers = {}
            for _, buttonTable in ipairs(textMatches) do
                --extract the tab and functiom
                local tab, functionName = string.gmatch(buttonTable.key,"(%g*),(%g*),")()
                --compare to current
                if tab == trace.tab and functionName == trace.functionName then 
                    --store matches
                    table.insert(matchers, buttonTable)
                end
            end
            --if only 1 button matches tab and function and text, use it
            if #matchers == 1 then
                setTableToDrawUsingNewId(trace.all, matchers[1], matchers[1].key)  
                --if more than one button matches tab and function and text
            elseif #matchers > 1 then 
                --just gonna have to guess!
                --find the first one without an 'assigned' value
                for _, buttonTable in ipairs(matchers) do 
                    if not buttonTable.assigned then 
                        --update it to use *this* traceback id
                        setTableToDrawUsingNewId(trace.all, buttonTable, buttonTable.key)
                        --mark it 'assigned'
                        simpleButtons[trace.all].assigned = true
                    end
                end 
            end
        end
    end
    --if there's still not a tableToDraw, make a new one
    if not tableToDraw or tableToDraw.text ~= bText then
        tableToDraw = simpleButtons.defaultButton(bText, trace.all)
    end
    tableToDraw.specTable = specTable
    --if x and y were explicitly stated, they should be ordinary numbers
    --so make them into percentages
    if x then x = x/WIDTH end
    if y then y = y/HEIGHT end
    --get the bounds of the button text if any dimension is undefined
    local boundsW, boundsH, lineHeight
    if width == nil or height == nil then
        boundsW, boundsH = textSize(bText)
        _, lineHeight = textSize("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    end
    width = width or boundsW + (simpleButtons.marginPaddingW * 2)
    height = height or boundsH + (simpleButtons.marginPaddingH * 2)
    --set empty specTable if none
    specTable = specTable or {}
    --set button drawing values, using saved values if none passed in
    --the saved values should already be percentages
    local x,y = x or tableToDraw.x, y or tableToDraw.y
    --update the stored values if necessary
    if x ~= tableToDraw.x then
        simpleButtons.ui[trace.all].x = x
    end
    if y ~= tableToDraw.y then
        simpleButtons.ui[trace.all].y = y
    end
    if width ~= tableToDraw.width then
        simpleButtons.ui[trace.all].width = width
    end
    if height ~= tableToDraw.height then
        simpleButtons.ui[trace.all].height = height
    end
    
    --can't use fill() as font color so default to white
    fontColor = fontColor or color(255)
    
    --'action' is called outside of this function
    if action then
        simpleButtons.ui[trace.all].action = action
    end
    
    --get the actual x and y from the percentages
    x, y = x*WIDTH, y*HEIGHT

    
    --draw the button
    local texture = simpleButtons.screenBlur
    
    local texCoordinates = vec4(x,y,width,height)
    if imageAsset ~= nil then
        texture = nil
        texCoordinates = nil
        pushStyle()
        fill(236, 76, 67, 0)
        stroke(236, 76, 67, 0)
    end
    roundedRectangle{
        x=x,y=y,w=width,h=height,radius=radius or 35,
        tex=texture,
        texCoord=texCoordinates}
    
    --if there's an image, draw only that
    if imageAsset ~= nil then
        popStyle()
        sprite(imageAsset, x, y, width, height)
    else --otherwise draw text
        pushStyle()
        -- textWrapWidth(width-76)
        fill(fontColor)
        text(bText, x, y)    
        popStyle()   
    end
    
    --handle touches (wherein action gets called or not)
    simpleButtons.evaluateTouchFor(trace.all)
    --set the flag that shows we rendered
    simpleButtons.ui[trace.all].didRenderAlready = true
    if newButtonFlag == true then
        print("button: should be saving positions")
        simpleButtons.savePositions() --atm saves *all* button positions, ergg
    end
end ]]

--[[
true mesh rounded rectangle. Original by @LoopSpace
with anti-aliasing, optional fill and stroke components, optional texture that preserves aspect ratio of original image, automatic mesh caching
usage: RoundedRectangle{key = arg, key2 = arg2}
required: x;y;w;h:  dimensions of the rectangle
optional: radius:   corner rounding radius, defaults to 6;
corners:  bitwise flag indicating which corners to round, defaults to 15 (all corners).
Corners are numbered 1,2,4,8 starting in lower-left corner proceeding clockwise
eg to round the two bottom corners use: 1 | 8
to round all the corners except the top-left use: ~ 2
tex:      texture image
texCoord: vec4 specifying x,y,width,and height to use as texture coordinates
scale:    size of rect (using scale)
use standard fill(), stroke(), strokeWidth() to set body fill color, outline stroke color and stroke width
]]
local __RRects = {}
function roundedRectangle(t) 
    local s = t.radius or 8
    local c = t.corners or 15
    local w = math.max(t.w+1,2*s)+1
    local h = math.max(t.h,2*s)+2
    local hasTexture = 0
    local texCoord = t.texCoord or vec4(0,0,1,1) --default to bottom-left-most corner, full with and height
    if t.tex then hasTexture = 1 end
    local label = table.concat({w,h,s,c,hasTexture,texCoord.x,texCoord.y},",")
    if not __RRects[label] then
        local rr = mesh()
        rr.shader = shader(rrectshad.vert, rrectshad.frag)

        local v = {}
        local no = {}

        local n = math.max(3, s//2)
        local o,dx,dy
        local edge, cent = vec3(0,0,1), vec3(0,0,0)
        for j = 1,4 do
            dx = 1 - 2*(((j+1)//2)%2)
            dy = -1 + 2*((j//2)%2)
            o = vec2(dx * (w * 0.5 - s), dy * (h * 0.5 - s))
            --  if math.floor(c/2^(j-1))%2 == 0 then
            local bit = 2^(j-1)
            if c & bit == bit then
                for i = 1,n do
                    
                    v[#v+1] = o
                    v[#v+1] = o + vec2(dx * s * math.cos((i-1) * math.pi/(2*n)), dy * s * math.sin((i-1) * math.pi/(2*n)))
                    v[#v+1] = o + vec2(dx * s * math.cos(i * math.pi/(2*n)), dy * s * math.sin(i * math.pi/(2*n)))
                    no[#no+1] = cent
                    no[#no+1] = edge
                    no[#no+1] = edge
                end
            else
                v[#v+1] = o
                v[#v+1] = o + vec2(dx * s,0)
                v[#v+1] = o + vec2(dx * s,dy * s)
                v[#v+1] = o
                v[#v+1] = o + vec2(0,dy * s)
                v[#v+1] = o + vec2(dx * s,dy * s)
                local new = {cent, edge, edge, cent, edge, edge}
                for i=1,#new do
                    no[#no+1] = new[i]
                end
            end
        end
        -- print("vertices", #v)
        --  r = (#v/6)+1
        rr.vertices = v
        
        rr:addRect(0,0,w-2*s,h-2*s)
        rr:addRect(0,(h-s)/2,w-2*s,s)
        rr:addRect(0,-(h-s)/2,w-2*s,s)
        rr:addRect(-(w-s)/2, 0, s, h - 2*s)
        rr:addRect((w-s)/2, 0, s, h - 2*s)
        --mark edges
        local new = {cent,cent,cent, cent,cent,cent,
        edge,cent,cent, edge,cent,edge,
        cent,edge,edge, cent,edge,cent,
        edge,edge,cent, edge,cent,cent,
        cent,cent,edge, cent,edge,edge}
        for i=1,#new do
            no[#no+1] = new[i]
        end
        rr.normals = no
        --texture
        if t.tex then
            rr.shader.fragmentProgram = rrectshad.fragTex
            rr.texture = t.tex

            local w,h = t.tex.width,t.tex.height
            local textureOffsetX,textureOffsetY = texCoord.x,texCoord.y
            
            local coordTable = {}
            for i,v in ipairs(rr.vertices) do
                coordTable[i] = vec2((v.x + textureOffsetX)/w, (v.y + textureOffsetY)/h)
            end
            rr.texCoords = coordTable
        end
        local sc = 1/math.max(2, s)
        rr.shader.scale = sc --set the scale, so that we get consistent one pixel anti-aliasing, regardless of size of corners
        __RRects[label] = rr
    end
    __RRects[label].shader.fillColor = color(fill())
    if strokeWidth() == 0 then
        __RRects[label].shader.strokeColor = color(fill())
    else
        __RRects[label].shader.strokeColor = color(stroke())
    end

    if t.resetTex then
        __RRects[label].texture = t.resetTex
        t.resetTex = nil
    end
    local sc = 0.25/math.max(2, s)
    __RRects[label].shader.strokeWidth = math.min( 1 - sc*3, strokeWidth() * sc)
    pushMatrix()
    translate(t.x,t.y)
    scale(t.scale or 1)
    __RRects[label]:draw()
    popMatrix()
end

rrectshad ={
    vert=[[
    uniform mat4 modelViewProjection;
    
    attribute vec4 position;
    
    //attribute vec4 color;
    attribute vec2 texCoord;
    attribute vec3 normal;
    
    //varying lowp vec4 vColor;
    varying highp vec2 vTexCoord;
    varying vec3 vNormal;
    
    void main()
    {
    //  vColor = color;
    vTexCoord = texCoord;
    vNormal = normal;
    gl_Position = modelViewProjection * position;
    }
    ]],
    frag=[[
    precision highp float;
    
    uniform lowp vec4 fillColor;
    uniform lowp vec4 strokeColor;
    uniform float scale;
    uniform float strokeWidth;
    
    //varying lowp vec4 vColor;
    varying highp vec2 vTexCoord;
    varying vec3 vNormal;
    
    void main()
    {
    lowp vec4 col = mix(strokeColor, fillColor, smoothstep((1. - strokeWidth) - scale * 0.5, (1. - strokeWidth) - scale * 1.5 , vNormal.z)); //0.95, 0.92,
    col = mix(vec4(col.rgb, 0.), col, smoothstep(1., 1.-scale, vNormal.z) );
    // col *= smoothstep(1., 1.-scale, vNormal.z);
    gl_FragColor = col;
    }
    ]],
    fragTex=[[
    precision highp float;
    
    uniform lowp sampler2D texture;
    uniform lowp vec4 fillColor;
    uniform lowp vec4 strokeColor;
    uniform float scale;
    uniform float strokeWidth;
    
    //varying lowp vec4 vColor;
    varying highp vec2 vTexCoord;
    varying vec3 vNormal;
    
    void main()
    {
    vec4 pixel = texture2D(texture, vTexCoord) * fillColor;
    lowp vec4 col = mix(strokeColor, pixel, smoothstep(1. - strokeWidth - scale * 0.5, 1. - strokeWidth - scale * 1.5, vNormal.z)); //0.95, 0.92,
    // col = mix(vec4(0.), col, smoothstep(1., 1.-scale, vNormal.z) );
    col *= smoothstep(1., 1.-scale, vNormal.z);
    gl_FragColor = col;
    }
    ]]
}

function screenSizedImage(imageToResize)
    local screenSizedImage = image(WIDTH,HEIGHT)
    setContext(screenSizedImage)
    sprite(imageToResize,WIDTH/2,HEIGHT/2,WIDTH,HEIGHT)
    setContext()
    return screenSizedImage
end

--draws backgroundImage and updates blur if needed
drawBackground = function(backgroundImage)
    sprite(backgroundImage, WIDTH / 2, HEIGHT/2, WIDTH,HEIGHT)
    if simpleButtons.shouldUpdateScreenBlur then
        simpleButtons.screenBlur = tintedBlurredScreenSizedImage(backgroundImage)
        simpleButtons.shouldUpdateScreenBlur = false
    end
end

--[[
function blurClipFromImage(sourceImage,x,y,width,height)
local clippedRect = image(width,height)
local clippedRectPosition = vec2(x,y)
local clippedRectHalved = vec2(width/2,height/2)
setContext(clippedRect)
pushMatrix()
translate(-clippedRectPosition.x+clippedRectHalved.x,-clippedRectPosition.y+clippedRectHalved.y)
sprite(sourceImage,sourceImage.width/2,sourceImage.height/2)
popMatrix()
setContext()
return imageWithGaussian2PassBlur(clippedRect)
end
]]

function tintedBlurredScreenSizedImage(imageToTintAndBlur)
    local resizedAndTinted = image(WIDTH,HEIGHT)
    setContext(resizedAndTinted)
    tint(194)
    sprite(imageToTintAndBlur,WIDTH/2,HEIGHT/2,WIDTH,HEIGHT)
    noTint()
    setContext()
    return imageWithGaussian2PassBlur(resizedAndTinted)
end

function imageWithGaussian2PassBlur(imageToBlur)
    --aspect ratio for blurring with:
    local largestSide = math.max(imageToBlur.width,imageToBlur.height)
    local aspect = vec2(largestSide/imageToBlur.width , largestSide/imageToBlur.height) --should be inverse ratio?
    --aspect = vec2(0.45,0.45) --********* clean up
    --dimensions for fullSized and downsampled images
    local downsampleAmount = 0.04 -- going down to 0.25 actually looks pretty good, but, weirdly, slower than 0.5
    local fullDimensions = vec2(imageToBlur.width,imageToBlur.height)
    local downsampleDimensions = vec2(imageToBlur.width*downsampleAmount,imageToBlur.height*downsampleAmount)
    --images
    local blurImages = {}
    blurImages.fullSized = imageToBlur
    blurImages.downsampled = image(downsampleDimensions.x,downsampleDimensions.y)
    setContext(blurImages.downsampled)
    sprite(imageToBlur,downsampleDimensions.x/2,downsampleDimensions.y/2,downsampleDimensions.x,downsampleDimensions.y)
    setContext()
    --meshes
    local blurMeshes = {}
    blurMeshes.horizontal = mesh()
    blurMeshes.vertical = mesh()
    --horizontal mesh settings
    blurMeshes.horizontal.texture = blurImages.fullSized
    blurMeshes.horizontal:addRect(downsampleDimensions.x/2,downsampleDimensions.y/2,
    downsampleDimensions.x,downsampleDimensions.y) --fullSized image uses downsampled rect
    blurMeshes.horizontal.shader = shader(gaussianShader.vert[1],gaussianShader.frag)
    blurMeshes.horizontal.shader.am = aspect
    --vertical mesh settings
    blurMeshes.vertical.texture = blurImages.downsampled
    blurMeshes.vertical:addRect(fullDimensions.x/2,fullDimensions.y/2,
    fullDimensions.x,fullDimensions.y) --downsampled image uses fullSized rect
    blurMeshes.vertical.shader = shader(gaussianShader.vert[2],gaussianShader.frag)
    blurMeshes.vertical.shader.am = aspect
    --draw the blurred horizontal mesh to the vertical mesh texture
    setContext(blurMeshes.vertical.texture)
    blurMeshes.horizontal:draw() --pass one
    setContext()
    --draw the double-blurred vertical mesh to a new image
    local renderTarget = image(imageToBlur.width,imageToBlur.height)
    setContext(renderTarget)
    blurMeshes.vertical:draw() --pass two
    setContext()
    --send back the blurred image
    return renderTarget
end

gaussianShader = {
vert = { -- horizontal pass vertex shader
[[
uniform mat4 modelViewProjection;
uniform vec2 am; // amount of blur, inverse aspect ratio (so that oblong shapes still produce round blur)
attribute vec4 position;
attribute vec2 texCoord;

varying vec2 vTexCoord;
varying vec2 v_blurTexCoords[14];

void main()
{
gl_Position = modelViewProjection * position;
vTexCoord = texCoord;
v_blurTexCoords[ 0] = vTexCoord + vec2(-0.028 * am.x, 0.0);
v_blurTexCoords[ 1] = vTexCoord + vec2(-0.024 * am.x, 0.0);
v_blurTexCoords[ 2] = vTexCoord + vec2(-0.020 * am.x, 0.0);
v_blurTexCoords[ 3] = vTexCoord + vec2(-0.016 * am.x, 0.0);
v_blurTexCoords[ 4] = vTexCoord + vec2(-0.012 * am.x, 0.0);
v_blurTexCoords[ 5] = vTexCoord + vec2(-0.008 * am.x, 0.0);
v_blurTexCoords[ 6] = vTexCoord + vec2(-0.004 * am.x, 0.0);
v_blurTexCoords[ 7] = vTexCoord + vec2( 0.004 * am.x, 0.0);
v_blurTexCoords[ 8] = vTexCoord + vec2( 0.008 * am.x, 0.0);
v_blurTexCoords[ 9] = vTexCoord + vec2( 0.012 * am.x, 0.0);
v_blurTexCoords[10] = vTexCoord + vec2( 0.016 * am.x, 0.0);
v_blurTexCoords[11] = vTexCoord + vec2( 0.020 * am.x, 0.0);
v_blurTexCoords[12] = vTexCoord + vec2( 0.024 * am.x, 0.0);
v_blurTexCoords[13] = vTexCoord + vec2( 0.028 * am.x, 0.0);
}]],
-- vertical pass vertex shader
[[
uniform mat4 modelViewProjection;
uniform vec2 am; // ammount of blur
attribute vec4 position;
attribute vec2 texCoord;

varying vec2 vTexCoord;
varying vec2 v_blurTexCoords[14];

void main()
{
gl_Position = modelViewProjection * position;
vTexCoord = texCoord;
v_blurTexCoords[ 0] = vTexCoord + vec2(0.0, -0.028 * am.y);
v_blurTexCoords[ 1] = vTexCoord + vec2(0.0, -0.024 * am.y);
v_blurTexCoords[ 2] = vTexCoord + vec2(0.0, -0.020 * am.y);
v_blurTexCoords[ 3] = vTexCoord + vec2(0.0, -0.016 * am.y);
v_blurTexCoords[ 4] = vTexCoord + vec2(0.0, -0.012 * am.y);
v_blurTexCoords[ 5] = vTexCoord + vec2(0.0, -0.008 * am.y);
v_blurTexCoords[ 6] = vTexCoord + vec2(0.0, -0.004 * am.y);
v_blurTexCoords[ 7] = vTexCoord + vec2(0.0,  0.004 * am.y);
v_blurTexCoords[ 8] = vTexCoord + vec2(0.0,  0.008 * am.y);
v_blurTexCoords[ 9] = vTexCoord + vec2(0.0,  0.012 * am.y);
v_blurTexCoords[10] = vTexCoord + vec2(0.0,  0.016 * am.y);
v_blurTexCoords[11] = vTexCoord + vec2(0.0,  0.020 * am.y);
v_blurTexCoords[12] = vTexCoord + vec2(0.0,  0.024 * am.y);
v_blurTexCoords[13] = vTexCoord + vec2(0.0,  0.028 * am.y);
}]]},
--fragment shader
frag = [[precision mediump float;

uniform lowp sampler2D texture;

varying vec2 vTexCoord;
varying vec2 v_blurTexCoords[14];

void main()
{
gl_FragColor = vec4(0.0);
gl_FragColor += texture2D(texture, v_blurTexCoords[ 0])*0.0044299121055113265;
gl_FragColor += texture2D(texture, v_blurTexCoords[ 1])*0.00895781211794;
gl_FragColor += texture2D(texture, v_blurTexCoords[ 2])*0.0215963866053;
gl_FragColor += texture2D(texture, v_blurTexCoords[ 3])*0.0443683338718;
gl_FragColor += texture2D(texture, v_blurTexCoords[ 4])*0.0776744219933;
gl_FragColor += texture2D(texture, v_blurTexCoords[ 5])*0.115876621105;
gl_FragColor += texture2D(texture, v_blurTexCoords[ 6])*0.147308056121;
gl_FragColor += texture2D(texture, vTexCoord         )*0.159576912161;
gl_FragColor += texture2D(texture, v_blurTexCoords[ 7])*0.147308056121;
gl_FragColor += texture2D(texture, v_blurTexCoords[ 8])*0.115876621105;
gl_FragColor += texture2D(texture, v_blurTexCoords[ 9])*0.0776744219933;
gl_FragColor += texture2D(texture, v_blurTexCoords[10])*0.0443683338718;
gl_FragColor += texture2D(texture, v_blurTexCoords[11])*0.0215963866053;
gl_FragColor += texture2D(texture, v_blurTexCoords[12])*0.00895781211794;
gl_FragColor += texture2D(texture, v_blurTexCoords[13])*0.0044299121055113265;
}]]
}

