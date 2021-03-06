-- GlobalOverrides
--by Steppers

-- Provides a simple interface for intercepting global
-- variable and function usage.

-- WebRepo provides this already so don't add it here.
--[[
if _WEB_REPO_LAUNCH_ then
return
end
]]

function initSupportedOrientations()
    
    -- Global shadow table & remappings
    local shadow = nil
    local func_remap = nil
    local value_remap = nil
    
    -- Initialises the global environment's metatable
    -- and sets up the shadow & remap tables
    local function initGlobalMetatable()
        shadow = {}
        func_remap = {}
        value_remap = {}
        
        if getmetatable(_G) ~= nil then
            error("Unable to init global metatable as the global environment already has a metatable!")
        end
        
        -- Set the metatable of the global table
        -- We can then apply any remappings
        setmetatable(_G, {
            __index = function(t, k)
                -- Only remap values when read
                k = value_remap[k] or k
                return shadow[k]
            end,
            __newindex = function(t, k, v)
                -- Only remap functions when writing
                k = func_remap[k] or k
                shadow[k] = v
            end
        })
    end
    
    -- Wraps a global function with the provided function
    --
    -- The wrapper function should call _wrap_<global_name>
    -- to call the wrapped function.
    --
    -- Reads of the wrapped global will always return the
    -- wrapper itself rather than the currently wrapped
    -- function. This means you cannot read the wrapped value
    -- directly. Use getWrappedGlobalFunc() instead.
    function wrapGlobalFunc(global_name, wrapper)
        
        if shadow == nil then
            initGlobalMetatable()
        end
        
        if func_remap[global_name] ~= nil then
            error("Wrapping already wrapped global function! (" .. global_name .. ")")
        end
        
        -- Setup mapping and wrapper
        func_remap[global_name] = "_wrap_" .. global_name
        shadow[global_name] = wrapper
        shadow["_wrap_" .. global_name] = rawget(_G, global_name)
        
        -- Make sure the raw global is not set
        rawset(_G, global_name, nil)
    end
    
    -- Returns the function currently wrapped for the specified global
    function getWrappedGlobalFunc(global_name)
        return shadow["_wrap_" .. global_name]
    end
    
    -- Overrides the value of a Global variable
    -- The value can then only be set using this function
    -- Any write to the global outside of this function
    -- will not be visible to the rest of the project.
    function overrideGlobal(global_name, value)
        if shadow == nil then
            initGlobalMetatable()
        end
        
        -- Setup mapping and override
        value_remap[global_name] = "_ovrd_" .. global_name
        shadow["_ovrd_" .. global_name] = value
        shadow[global_name] = rawget(_G, global_name)
        
        -- Make sure the raw global is not set
        -- so we force access via the shadow
        rawset(_G, global_name, nil)
    end
    
    -- Returns the value of the provided global
    -- ignoring any override.
    function getOverriddenGlobal(global_name)
        if shadow == nil then return nil end
        return shadow[global_name]
    end
    
    -- supportedOrientations
    --
    -- Implementation of the old supportedImplementations function
    --
    -- Usage:
    --      Call supportedOrientations(lock) with the desired orientation
    --      lock. Choose from the following:
    --          PORTRAIT_ANY
    --          LANDSCAPE_ANY
    --          PORTRAIT
    --          PORTRAIT_UPSIDE_DOWN
    --          LANDSCAPE_LEFT
    --          LANDSCAPE_RIGHT
    
    -- If run as part of a project launched through WebRepo
    -- don't continue. WebRepo provides this already
    if _WEB_REPO_LAUNCH_ then
        return
    end
    
    -- Save original Codea values
    local setContext_codea = setContext
    local perspective_codea = perspective
    local ortho_codea = ortho
    local layout_codea = layout
    local sprite_codea = sprite
    
    local WIDTH_codea = WIDTH
    local HEIGHT_codea = HEIGHT
    
    local CurrentTouch_codea = CurrentTouch
    
    -- Maps supported orientations and current orientation to the
    -- rotation to apply
    local orientation_rot_map = {
        [PORTRAIT_ANY] = {
            [LANDSCAPE_LEFT] = 90,
            [LANDSCAPE_RIGHT] = 90,
            [PORTRAIT] = 0,
            [PORTRAIT_UPSIDE_DOWN] = 0
        },
        [PORTRAIT] = {
            [LANDSCAPE_LEFT] = -90,
            [LANDSCAPE_RIGHT] = 90,
            [PORTRAIT] = 0,
            [PORTRAIT_UPSIDE_DOWN] = 180
        },
        [PORTRAIT_UPSIDE_DOWN] = {
            [LANDSCAPE_LEFT] = 90,
            [LANDSCAPE_RIGHT] = -90,
            [PORTRAIT] = 180,
            [PORTRAIT_UPSIDE_DOWN] = 0
        },
        [LANDSCAPE_ANY] = {
            [LANDSCAPE_LEFT] = 0,
            [LANDSCAPE_RIGHT] = 0,
            [PORTRAIT] = 90,
            [PORTRAIT_UPSIDE_DOWN] = 90
        },
        [LANDSCAPE_RIGHT] = {
            [LANDSCAPE_LEFT] = 180,
            [LANDSCAPE_RIGHT] = 0,
            [PORTRAIT] = -90,
            [PORTRAIT_UPSIDE_DOWN] = 90
        },
        [LANDSCAPE_LEFT] = {
            [LANDSCAPE_LEFT] = 0,
            [LANDSCAPE_RIGHT] = 180,
            [PORTRAIT] = 90,
            [PORTRAIT_UPSIDE_DOWN] = -90
        },
    }
    
    -- Internal state
    local orientation = nil
    local orientation_rot = 0
    local orientation_width = 0
    local orientation_height = 0
    local orientation_fb = nil
    
    -- Translate a position into framebuffer space
    local function toFB(pos)
        pos = pos - vec2(getOverriddenGlobal("WIDTH")/2, getOverriddenGlobal("HEIGHT")/2)
        pos = pos:rotate(math.rad(-orientation_rot))
        pos = pos + vec2(orientation_width/2, orientation_height/2)
        return pos
    end
    
    -- Initialise orientation lock variables
    local function initOrientationLock()
        
        -- If no lock is set, ignore it
        if orientation == nil then
            orientation_fb = nil
            return
        end
        
        local is_portrait = (CurrentOrientation == PORTRAIT) or (CurrentOrientation == PORTRAIT_UPSIDE_DOWN)
        
        -- Determine the target orientation's resolution
        if orientation == PORTRAIT_ANY or orientation == PORTRAIT or orientation == PORTRAIT_UPSIDE_DOWN then
            if is_portrait then
                orientation_height = HEIGHT_codea
                orientation_width = WIDTH_codea
            else
                orientation_height = WIDTH_codea
                orientation_width = HEIGHT_codea
            end
        elseif orientation == LANDSCAPE_ANY or orientation == LANDSCAPE_LEFT or orientation == LANDSCAPE_RIGHT then
            if is_portrait then
                orientation_height = WIDTH_codea
                orientation_width = HEIGHT_codea
            else
                orientation_height = HEIGHT_codea
                orientation_width = WIDTH_codea
            end
        end
        
        -- Get the intended rotation
        orientation_rot = orientation_rot_map[orientation][CurrentOrientation]
        
        -- Create a new orientation framebuffer
        orientation_fb = image(orientation_width, orientation_height)
    end
    
    -- Update orientation lock variables
    local function updateOrientationLock()
        
        -- If no lock is set return immediately
        if orientation == nil then
            return
        end
        
        -- Get the intended rotation
        orientation_rot = orientation_rot_map[orientation][CurrentOrientation]
    end
    
    local function drawWrapper()
        
        -- No user implementation
        if _wrap_draw == nil then
            return
        end
        
        -- Just call the project provided impl.
        -- if we have no lock
        if orientation == nil then
            _wrap_draw()
            return
        end
        
        -- Set framebuffer
        setContext_codea(orientation_fb, true)
        
        -- Draw into framebuffer
        _wrap_draw()
        
        -- Draw to display buffer
        setContext_codea()
        
        -- Blit the backbuffer with the locked rotation
        -- Push style & matrix
        pushMatrix()
        pushStyle()
        
        -- Reset matrices
        resetMatrix()
        ortho_codea()
        viewMatrix(matrix())
        
        -- Transform
        translate(getOverriddenGlobal("WIDTH")/2, getOverriddenGlobal("HEIGHT")/2)
        rotate(orientation_rot)
        
        -- Draw framebuffer
        spriteMode(CENTER)
        sprite_codea(orientation_fb, 0, 0)
        
        popStyle()
        popMatrix()
    end
    
    local function touchedWrapper(touch)
        -- No user implementation
        if _wrap_touched == nil then
            return
        end
        
        -- No transformation needed
        if orientation == nil or orientation == CurrentOrientation then
            _wrap_touched(touch)
            return
        end
        
        -- Transform touch values
        local pos = toFB(touch.pos)
        local prevPos = toFB(touch.prevPos)
        local precisePos = toFB(touch.precisePos)        
        local precisePrevPos = toFB(touch.precisePos)
        local delta = touch.delta:rotate(math.rad(-orientation_rot))
        
        local t = {
            x = pos.x,
            y = pos.y,
            pos = pos,
            prevPos = prevPos,
            precisePos = precisePos,
            precisePrevPos = precisePrevPos,
            delta = delta,
        }
        
        -- Fallback to the original touch object
        t = setmetatable(t, {
            __index = function(t, k)
                return touch[k]
            end,
            __newindex = function(t, k, v)
                touch[k] = v
            end
        })
        
        _wrap_touched(t)
    end
    
    local function sizeChangedWrapper(newWidth, newHeight)
        -- adjust the orientation rotation if set
        updateOrientationLock()
        
        -- Call wrapped function
        if _wrap_sizeChanged then _wrap_sizeChanged(orientation_width, orientation_height) end
    end
    
    -- Our implementation
    function supportedOrientations(orientations)
        
        -- Initialise the orientation lock
        orientation = orientations
        initOrientationLock()
        
        wrapGlobalFunc("draw", drawWrapper)
        wrapGlobalFunc("touched", touchedWrapper)
        wrapGlobalFunc("sizeChanged", sizeChangedWrapper)
        
        -- Override the WIDTH & HEIGHT values
        overrideGlobal("WIDTH", orientation_width)
        overrideGlobal("HEIGHT", orientation_height)
        
        -- Overridden CurrentTouch object to apply orientation
        -- transforms
        CurrentTouch = setmetatable({}, {
            __index = function(t, k)
                local v = CurrentTouch_codea[k]
                
                -- No transformation needed
                if orientation == nil or orientation == CurrentOrientation then
                    return v
                end
                
                if k == "x" then
                    return toFB(CurrentTouch_codea.pos).x
                    
                elseif k == "y" then
                    return toFB(CurrentTouch_codea.pos).y
                    
                elseif k == "pos" or k == "prevPos" or k == "precisePos" or k == "precisePrevPos" then
                    return toFB(v)
                    
                    -- I don't have a stylus to check this behaviour
                    -- elseif k == "azimuthVec" then
                    --    return v:rotate(math.rad(-orientation_rot))
                    
                elseif k == "delta" then
                    return v:rotate(math.rad(-orientation_rot))
                end
                
                return v
            end,
            __newindex = function(t, k, v)
                CurrentTouch_codea[k] = v
            end
        })
        
        -- Override the Codea perspective() function to account for
        -- a locked orientation resolution
        perspective = function(fov, aspect, near, far)
            if fov == nil then
                perspective_codea(45, WIDTH/HEIGHT)
            elseif aspect == nil then
                perspective_codea(fov, WIDTH/HEIGHT)
            else
                perspective_codea(fov, aspect, near, far)
            end
        end
        
        -- Override the Codea ortho() function to account for
        -- a locked orientation resolution
        ortho = function(left, right, bottom, top, near, far)
            if left == nil then
                ortho_codea(0, WIDTH, 0, HEIGHT, -10, 10)
            else
                ortho_codea(left, right, bottom, top, near, far)
            end
        end
        
        -- Override the Codea setContext() function to reinstate
        -- the orientation framebuffer when the project tries
        -- to apply nil
        setContext = function(img, useDepth)
            if img == nil then
                if orientation_fb ~= nil then
                    setContext_codea(orientation_fb, true)
                else
                    setContext_codea()
                end
            else
                setContext_codea(img, useDepth)
            end
        end
    end  
end