﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/6/2 15:19
---
local IntersectionUtils = {}

function IntersectionUtils.isCollinear(p, c, n)
    return math.abs(cc.pCross(cc.pSub(p, c), cc.pSub(n, c))) < GeometryConstants.EPS_S
end

function IntersectionUtils.pInLine(p, began, ended)
    if IntersectionUtils.isCollinear(p, began, ended) then
        return cc.pDot(cc.pSub(p, began), cc.pSub(ended, began)) * cc.pDot(cc.pSub(p, ended), cc.pSub(began, ended)) >= 0
    end
    return false
end

--- 判断点是否在多边形内
--- @param polygon array 描述一个多边形，逆时针序
function IntersectionUtils.pInPolygon(p, polygon)
    local len, lastDirection = #polygon, 1
    for i = 1, len do
        local c = polygon[i]
        local n = polygon[i % len + 1]
        local direction = cc.pCross(cc.pSub(c, p), cc.pSub(n, p))
        if math.abs(direction) < GeometryConstants.EPS_S then
            return IntersectionUtils.pInLine(p, c, n)
        end
        if lastDirection * direction < 0 then
            return false
        end
        lastDirection = direction
    end
    return true
end

return IntersectionUtils