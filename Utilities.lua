Utilities = {}

function Utilities.playSoundAndWaitUntilFinished(soundName)
    --start the sound playing and assign it to a variable
    local soundMonitor = sound(soundName)
    --run an empty loop until the sound is over
    while soundMonitor.playing == true do
        --nothing
    end
end

function Utilities.imageSizeForDevice(imageSizeOnOriginalPad, currentDeviceSize)
    local iPadAspectRatio = vec2(1366, 1024)
    local widthScalingFactor = currentDeviceSize.x / iPadAspectRatio.x
    local heightScalingFactor = currentDeviceSize.y / iPadAspectRatio.y
    local scaledWidth = imageSizeOnOriginalPad.x * widthScalingFactor
    local scaledHeight = imageSizeOnOriginalPad.y * heightScalingFactor
    return vec2(scaledWidth, scaledHeight)
end

