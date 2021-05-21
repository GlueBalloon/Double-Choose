Utilities = {}

function Utilities.playSoundAndWaitUntilFinished(soundName)
    --start the sound playing and assign it to a variable
    local soundMonitor = sound(soundName)
    --run an empty loop until the sound is over
    while soundMonitor.playing == true do
        --nothing
    end
end

-- setReporting &c handles control whether or not report(string) commands get printed
--[[
function setReporting(shouldReport)
    if shouldReport then
        reporting = true
    else
        reporting = false
    end        
end
function report(x)
    if reporting == nil then
        print("reporting not set")
    elseif reporting == false then
        return
    else
        print(x)
    end
end

--lets just consolidate pushStyle() and popStyle() here
function styleSafe(functionToCall)
    pushStyle()
    functionToCall()
    popStyle()
end

--need an easy boolean-to-string thingy
function boolToString(boolean) 
    if boolean == true then
        return "TRUE"
    elseif boolean == false then
        return "FALSE"
    else
        return "NOT A BOOLEAN"
    end
end


--tintScreen applies given color as semitransparent tint to a CargoBot full-screen sprite
function tintScreen(tintColor)
    --enforce a minimum opacity of 191
    if tintColor.a > 191 then
        tintColor.a = 191
    end
    tint(tintColor)
    sprite("Cargo Bot:Game Lower BG", WIDTH/2,HEIGHT/2,WIDTH,HEIGHT)
    noTint()
end
]]

