
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = true

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 1920,
    height = 1080,
    autoScale = "FIXED_HEIGHT",
    callback = function(frameSize)
        local ratio = frameSize.width / frameSize.height
        if ratio <= 1.34 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {autoScale = "FIXED_WIDTH"}
        end
    end
}

CC_FRAME_SIZE = {
    width = 1280,
    height = 720
}
