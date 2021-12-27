local ShaderTest = require("src.test.ShaderTest")
local TocaTouchTest = require("src.test.TocaTouchTest")
local MainScene = class("MainScene", BaseScene)

function MainScene:ctor()
    MainScene.super.ctor(self)

    local bg = cc.Sprite:create("res/bg_default.png"):addTo(self):moveCenter()
    bg:setScale(display.height / bg:getHeight())

    ShaderTest.new():addTo(self)
    --TocaTouchTest.new():addTo(self)

    -- add HelloWorld label
    local lblHello = cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)

    --local rect = cc.rect(0, 0, 0, 0)
    --local info =  cc.AutoPolygon:generatePolygon("res/tangram/pic_2_0001.png", rect, 2, 1)
    --local spp  =  cc.Sprite:create(info):addTo(self):move(500, 500)
    --
    --local vertices = info:getVertices()
    --local indices = info:getIndices()
    --local n = #indices
    --local dn = cc.DrawNode:create():addTo(spp)
    --for i = 1, n, 3 do
    --    dn:drawSegment(vertices[indices[i] + 1], vertices[indices[i + 1] + 1], 1, cc.c4f(1, 0, 0, 1))
    --    dn:drawSegment(vertices[indices[i + 1] + 1], vertices[indices[i + 2] + 1], 1, cc.c4f(1, 0, 0, 1))
    --    dn:drawSegment(vertices[indices[i] + 1], vertices[indices[i + 2] + 1], 1, cc.c4f(1, 0, 0, 1))
    --end

    --local rubber = RubberBand.new({
    --    startPos = cc.p(600, 100),
    --    endPos = cc.p(900, 500)
    --}):addTo(self)
end

return MainScene
