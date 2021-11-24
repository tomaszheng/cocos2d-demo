
local MainScene = class("MainScene", BaseScene)

function MainScene:ctor()
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)

    local rubber = RubberBand.new({
        startPos = cc.p(600, 100),
        endPos = cc.p(900, 500)
    }):addTo(self)
end

return MainScene
