
local MainScene = class("MainScene", BaseScene)

function MainScene:ctor()
    local bg = cc.Sprite:create("res/bg_default.png"):addTo(self):moveCenter()
    bg:setScale(display.height / bg:getHeight())

    -- add background image
    local avatar = cc.Sprite:create("res/bg_avatar_default.png")
        :move(display.center)
        :addTo(self)

    avatar:addLuaComponent(Outline)

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
