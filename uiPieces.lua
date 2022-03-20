--pieces are interface elements like buttons, text areas, etc
--because I began with the button class, all pieces are called 'buttons' in many places
--these should all be refactored so that there's a generic 'piece' function

--sends an image to the button(...) function but has parameters ordered by how often they're used: only the first two are actually necessary to draw an image
--if scaleFactor is given as well as width and/or height, the direct values will be used instead of applying the scaleFactor
function simpleImage(name, imageAsset, scaleFactor, x, y, action, width, height)
    scaleFactor = scaleFactor or 1
    width = width or imageAsset.width * scaleFactor
    height = height or imageAsset.height * scaleFactor
    button(name, action, x, y, width, height, nil, imageAsset)
end


--button only actually needs a name to work, the rest have defaults
function button(name, action, x, y, width, height, fontColor, imageAsset, radius)
    --TODO: make parameter list into varargs and detect image and color?
    local newButtonFlag = false
    --create a default button if none exists under this name
    if uiPieceHandler.buttons[name] == nil then
        uiPieceHandler.defaultButton(name)
        newButtonFlag = true
    end
    --set button drawing values, using saved values if none passed in
    local buttonTable = uiPieceHandler.buttons[name]
    local x,y = x or buttonTable.x, y or buttonTable.y
    fontColor = fontColor or uiPieceHandler.explicitColorFromFill()
    --get the bounds of the button text if any dimension is undefined *and* there is no image asset
    local boundsW, boundsH
    if (width == nil or height == nil) and imageAsset == nil then
        boundsW, boundsH = textSize(name)
        width = boundsW + (74 * adjstmt.x) 
        height = boundsH + (64 * adjstmt.y) 
    else
        width = width or buttonTable.width
        height = height or buttonTable.height
    end
    --  update the stored values if necessary
    if x ~= buttonTable.x then
        uiPieceHandler.buttons[name].x = x
    end
    if y ~= buttonTable.y then
        uiPieceHandler.buttons[name].y = y
    end
    if width ~= buttonTable.width then
        uiPieceHandler.buttons[name].width = width
    end
    if height ~= buttonTable.height and height ~= nil then
        uiPieceHandler.buttons[name].height = height
    end
    if fontColor ~= buttonTable.fontColor and fontColor ~= nil then
        uiPieceHandler.buttons[name].fontColor = fontColor
    end
    
    --'action' must be stored, not retrieved; it's called outside of this function
    if action ~= nil or buttonTable.action == nil then
        buttonTable.action = action
        uiPieceHandler.buttons[name].action = action
    end
    
    --adjust stored values for screen size
    x = x * adjstmt.x
    y = y * adjstmt.y
    if imageAsset then
        width = width * adjstmt.x
        height = height * adjstmt.y
    end
    radius = radius or 35
    radius = radius * adjstmt.x
    
    --draw the button
    local texture = uiPieceHandler.screenBlur
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
        text(name, x, y)    
        popStyle()   
    end
    
    --handle touches (wherein action gets called or not)
    uiPieceHandler.evaluateTouchFor(name)
    --set the flag that shows we rendered
    uiPieceHandler.buttons[name].didRenderAlready = true
    if newButtonFlag == true then
        print("button: should be saving positions")
        --uiPieceHandler.savePositions() --atm saves *all* button positions, ergg
    end
end

--textArea is a button that has no action and defaults to black text
function textArea(textToShow, x, y)
    --a placeholder action value
    local action
    --if first draw, set temporary empty action (in case tapped in first draw)
    if uiPieceHandler.buttons[textToShow] == nil then
        action = function() end
    end
    pushStyle()
    textWrapWidth(uiPieceHandler.narrationWrap)
    --pass all the values to button()--by default setting border transparent (as above)
    button(textToShow, action, x, y, uiPieceHandler.narrationW, uiPieceHandler.narrationH, color(255))
    popStyle()
    --if button action isn't nil yet, nil it--this will only be needed first time drawn
    if uiPieceHandler.buttons[textToShow].action ~= nil then
        uiPieceHandler.buttons[textToShow].action = nil
    end
end

--choice creates a button whose action changes currentScreen to the specified screen
function choice(choiceText, resultScreenAsFunction, x, y)
    local choiceAction = makeScreenChangingAction(resultScreenAsFunction)
    button(choiceText, choiceAction, x, y, uiPieceHandler.choiceW, uiPieceHandler.choiceH, color(255))
end

function makeScreenChangingAction(newScreenAsFunction)
    return function ()
        currentScreen = newScreenAsFunction
        uiPieceHandler.shouldUpdateScreenBlur = true
    end
end

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







