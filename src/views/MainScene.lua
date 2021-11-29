
local MainScene = class("MainScene", BaseScene)

function MainScene:ctor()
    local bg = cc.Sprite:create("res/bg_default.png"):addTo(self):moveCenter()
    bg:setScale(display.height / bg:getHeight())

    -- add background image
    local avatar = cc.Sprite:create("res/bg_avatar_default.png")
        :move(100, display.height - 150)
        :addTo(self)

    avatar:addLuaComponent(Outline)

    local avatar2 = cc.Sprite:create("res/bg_avatar_default.png")
                     :move(300, display.height - 150)
                     :addTo(self)

    avatar2:addLuaComponent(Blur, {defines = {blurType = Blur.BLUR_TYPE.FUZZY}})

    local avatar3 = cc.Sprite:create("res/bg_avatar_default.png")
                      :move(500, display.height - 150)
                      :addTo(self)

    avatar3:addLuaComponent(Blur, {defines = {sampleNum = 5}})

    local avatar4 = cc.Sprite:create("res/bg_avatar_default.png")
                      :move(700, display.height - 150)
                      :addTo(self)

    avatar4:addLuaComponent(Blur, {
        defines = {sampleNum = 5, blurType = Blur.BLUR_TYPE.RADIAL},
        blur = 0.03, center = cc.p(0.5, 0.8)
    })

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
