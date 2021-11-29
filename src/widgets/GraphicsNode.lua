﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/6/2 9:33
---
local GraphicsNode = class('GraphicsNode', cc.DrawNode)

function GraphicsNode:ctor(data)
    self:initData(data)
end

function GraphicsNode:initData(data)
    data = data or {}
    self.lineWidth = data.lineWidth or 2
    self.lineColor = data.lineColor or cc.convertColor(display.COLOR_WHITE, '4f')
    self.solidColor = data.solidColor
end

function GraphicsNode:drawEllipse(centerP, rx, ry, startRad, endRad)
    local points = {}
    local n = 50
    local rad = (endRad - startRad) / n
    for i = 1, n + 1 do
        local t = startRad + rad * (i - 1)
        table.insert(points, cc.p(
                math.sin(t) * rx + centerP.x,
                math.cos(t) * ry + centerP.y
        ))
    end
    self:drawSegments(points)
end

function GraphicsNode:drawSegment(startP, endP, lineWidth, lineColor)
    lineWidth = lineWidth or self.lineWidth
    lineColor = lineColor or self.lineColor
    cc.DrawNode.drawSegment(self, startP, endP, lineWidth, lineColor)
end

function GraphicsNode:drawArc(centerP, radius, startRad, totalRad)
    local points = {}
    local n = math.max(math.ceil(math.abs(totalRad) * 50 / (2 * GeometryConstants.PI)), 1)
    local rad = totalRad / n
    for i = 1, n + 1 do
        local t = startRad + rad * (i - 1)
        local p = cc.p(
                math.cos(t) * radius + centerP.x,
                math.sin(t) * radius + centerP.y
        )
        table.insert(points, p)
    end
    self:drawSegments(points)
end

function GraphicsNode:drawSegments(points, lineWidth, lineColor)
    local n = #points
    for i = 1, n - 1 do
        self:drawSegment(points[i], points[i + 1], lineWidth, lineColor)
    end
end

return GraphicsNode