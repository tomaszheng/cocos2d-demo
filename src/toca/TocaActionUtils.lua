﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/12/15 17:04
---
local TocaConstants = require("src.toca.TocaConstants")
local TocaActionUtils = {}

function TocaActionUtils.press(node, dstPos, options)
    options = options or {}
    local srcAnchor = node:getAnchorPoint()
    local scale = options.scale or node:getScale()
    local angle = options.angle or node:getRotation()
    local anchor = options.anchor or srcAnchor
    dstPos.x = dstPos.x - (anchor.x - srcAnchor.x) * node:getWidth()
    dstPos.y = dstPos.y - (anchor.y - srcAnchor.y) * node:getHeight()
    local duration = TocaConstants.PRESS_DURATION
    local moveAction = cc.EaseSineInOut:create(cc.MoveTo:create(duration, dstPos))
    local scaleAction = cc.ScaleTo:create(duration, scale)
    local rotationAction = cc.RotateTo:create(duration, angle)
    return node:runAction(cc.Spawn:create(moveAction, scaleAction, rotationAction))
end

function TocaActionUtils.loosen(node, dstPos, options)
    options = options or {}
    local srcAnchor = node:getAnchorPoint()
    local scale = options.scale or 1
    local angle = options.angle or 0
    local duration = TocaConstants.PRESS_DURATION
    local srcPos = cc.p(node:getPosition())
    local anchor = options.anchor or srcAnchor
    dstPos.x = dstPos.x - (anchor.x - srcAnchor.x) * node:getWidth()
    dstPos.y = dstPos.y - (anchor.y - srcAnchor.y) * node:getHeight()
    local bezier = {
        srcPos,
        cc.p(srcPos.x, math.max(dstPos.y, srcPos.y)),
        dstPos,
    }
    local moveAction = cc.EaseSineInOut:create(cc.BezierTo:create(duration, bezier))
    local scaleAction = cc.ScaleTo:create(duration, scale)
    local rotationAction = cc.RotateTo:create(duration, angle)
    return node:runAction(cc.Sequence:create(
            cc.Spawn:create(moveAction, scaleAction, rotationAction),
            cc.JumpTo:create(TocaConstants.BOUNCE_DURATION, dstPos, TocaConstants.BOUNCE_HEIGHT, TocaConstants.BOUNCE_NUM)
    ))
end

return TocaActionUtils