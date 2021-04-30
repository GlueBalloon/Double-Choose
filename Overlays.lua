
function orientationOverlay()
    pushStyle()
    fontSize(HEIGHT * 0.05)
    font("Futura-CondensedExtraBold")
    fill(187, 45, 37, 159)
    textMode(CENTER)
    textAlign(CENTER)
    local banner = "INTENDED FOR LANDSCAPE MODE ONLY"
    local w, h = textSize(banner)
    local horizontalPlace, verticalPlace = WIDTH * 0.5, HEIGHT - (h * 0.6)
    if CurrentOrientation == PORTRAIT or CurrentOrientation == PORTRAIT_UPSIDE_DOWN then
        banner = "GET OUT OF PORTRAIT MODE SONNY"
        verticalPlace = HEIGHT / 2
    end
fill(54, 31, 57, 83)
text(banner, horizontalPlace, verticalPlace)
fill(255, 86, 0, 78)
    text(banner, (horizontalPlace) - 2, verticalPlace + 2)

    popStyle()
end
