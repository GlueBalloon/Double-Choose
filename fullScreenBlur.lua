function screenSizedImage(imageToResize)
    local screenSizedImage = image(WIDTH,HEIGHT)
    setContext(screenSizedImage)
    sprite(imageToResize,WIDTH/2,HEIGHT/2,WIDTH,HEIGHT)
    setContext()
    return screenSizedImage
end

--draws backgroundImage and updates blur if needed
drawBackground = function(backgroundImage)
    sprite(backgroundImage, WIDTH / 2, HEIGHT/2,WIDTH,HEIGHT)
    if uiPieceHandler.shouldUpdateScreenBlur then
        uiPieceHandler.screenBlur = tintedBlurredScreenSizedImage(backgroundImage)
        uiPieceHandler.shouldUpdateScreenBlur = false
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

