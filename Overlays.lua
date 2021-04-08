
function orientationOverlay()
    pushStyle()
    fontSize(HEIGHT * 0.05)
    font("Futura-CondensedExtraBold")
    fill(187, 45, 37, 159)
    textMode(CENTER)
    textAlign(CENTER)
    local banner = "INTENDED FOR LANDSCAPE MODE ONLY"
    local w, h = textSize(banner)
fill(54, 31, 57, 83)
text(banner, WIDTH * 0.5, HEIGHT - (h * 0.6))
fill(255, 86, 0, 78)
    text(banner, (WIDTH * 0.5) - 2, HEIGHT - (h * 0.6) + 2)

    popStyle()
end
