Utilities = {}

function Utilities.playSoundAndWaitUntilFinished(soundName)
    --start the sound playing and assign it to a variable
    local soundMonitor = sound(soundName)
    --run an empty loop until the sound is over
    while soundMonitor.playing == true do
        --nothing
    end
end
