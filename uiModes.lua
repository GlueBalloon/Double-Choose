--Overlay defaults
--[[
overlayModeButtonWidth = 300
overlayModeButtonFontColor = color(229, 223, 94, 255)

--all the Overlays that can be used as currentOverlay


function introductionOverlay()
    tintScreen(color(255,128,128))
    button("welcome", function() 
                showPlayModeOverlay()
                choicesActive = true
        end)
end

function editModeOverlay()
    tintScreen(color(0,128,128,95))
    button("to fixed mode", showPlayModeOverlay,overlayModeButtonWidth,nil,overlayModeButtonFontColor)
end

function playModeOverlay()
    button("to editable mode", showEditModeOverlay,overlayModeButtonWidth,nil,overlayModeButtonFontColor)
end
  ]]
--[[
--these are the routines that manage Overlay displays
function showOverlay()
    if currentOverlay == nil then
        currentOverlay = introductionOverlay
    end
end
function showEditModeOverlay()
    currentOverlay = editModeOverlay
    ui_pieces_are_draggable = true
end
function showPlayModeOverlay()
    currentOverlay = playModeOverlay
    ui_pieces_are_draggable = false
end
]]
