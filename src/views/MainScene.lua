local ShaderTest = require("src.test.ShaderTest")
local MainScene = class("MainScene", BaseScene)

function MainScene:ctor()
    MainScene.super.ctor(self)

    local bg = cc.Sprite:create("res/bg_default.png"):addTo(self):moveCenter()
    bg:setScale(display.height / bg:getHeight())

    ShaderTest.new():addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)

    local rubber = RubberBand.new({
        startPos = cc.p(600, 100),
        endPos = cc.p(900, 500)
    }):addTo(self)

    local avatar = cc.Sprite:create("res/bg_avatar_default.png")
                     :move(200, 500)
                     :addTo(self)

    self:delayAction(function()
        --local size = avatar:getSize()
        --local target = avatar
        local box = avatar:getBoundingBox()
        --local size = avatar:getContentSize()
        local size = avatar:getRealSize()
        local target = display.getRunningScene()
        --local size = display.size
        --local screenTex = UIUtils.screenshot(display.getRunningScene(), size.width, size.height)
        local rt = UIUtils.screenshot(target, {
            area = cc.rect(box.x, box.y, size.width, size.height),
            filename = "w3.png",
            onComplete = function(filepath)
                cc.Sprite:create(filepath):addTo(self):moveCenter()
            end
        })
    end, 0)
end

return MainScene
