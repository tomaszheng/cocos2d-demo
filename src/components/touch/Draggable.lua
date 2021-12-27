﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/12/15 15:40
--- 拖拽组件
---
local Touchable = require("src.components.touch.Touchable")
local Draggable = class("Draggable", Touchable)

Draggable.ANCHOR_TYPES = {
    CENTER          = "center",
    LEFT_TOP        = "left_top",
    LEFT_BOTTOM     = "left_bottom",
    LEFT_CENTER     = "left_center",
    RIGHT_TOP       = "right_top",
    RIGHT_BOTTOM    = "right_bottom",
    RIGHT_CENTER    = "right_center",
    TOP_CENTER      = "top_center",
    CENTER_BOTTOM   = "center_bottom",
    CUSTOM          = "custom",
}

local ANCHOR_POINTS = {
    [Draggable.ANCHOR_TYPES.CENTER]         = display.center,
    [Draggable.ANCHOR_TYPES.LEFT_TOP]       = display.left_top,
    [Draggable.ANCHOR_TYPES.LEFT_BOTTOM]    = display.left_bottom,
    [Draggable.ANCHOR_TYPES.LEFT_CENTER]    = display.left_center,
    [Draggable.ANCHOR_TYPES.RIGHT_TOP]      = display.right_top,
    [Draggable.ANCHOR_TYPES.RIGHT_BOTTOM]   = display.right_bottom,
    [Draggable.ANCHOR_TYPES.RIGHT_CENTER]   = display.right_center,
    [Draggable.ANCHOR_TYPES.TOP_CENTER]     = display.top_center,
    [Draggable.ANCHOR_TYPES.CENTER_BOTTOM]  = display.center_bottom,
}

function Draggable:ctor(node, data)
    Draggable.super.ctor(self, node, data)
end

function Draggable:initData(data)
    Draggable.super.initData(self, data)
    data = data or {}
    -- 拖拽时什么位置与触摸点对齐
    self.anchorType = data.anchorType or Draggable.ANCHOR_TYPES.CUSTOM
    self.draggingAnchor = data.anchor
    -- 拖拽移动时的响应函数
    self.onDragLimitFunc = data.dragLimitFunc
    -- 拖拽是否有位移限制
    self.isMoveLimit = data.isMoveLimit or false
    self.moveThreshold = data.moveThreshold or 5
    -- 是否可以回弹
    self.reboundEnabled = data.reboundEnabled or false
    self.onReboundFunc = data.reboundFunc

    self.isDragEnabled = true
    self.isRebounding = false
    self.nodeOriginalAnchor = self.node:getAnchorPoint()
    self.nodeOriginalSize = self.node:getContentSize()
    self.nodeOriginalPosition = cc.p(self.node:getPosition())
    self.currDraggingAnchor = cc.p(0, 0)
    self.action = nil
end

function Draggable:onTouchBegan(touch)
    self.nodeOriginalAnchor = self.node:getAnchorPoint()
    self.nodeOriginalSize = self.node:getContentSize()
    self.nodeOriginalPosition = cc.p(self.node:getPosition())
    self.currDraggingAnchor = self:getDraggingAnchor(touch:getLocation())

    if not self.isDragEnabled or self.isRebounding then
        return false
    end
    return Draggable.super.onTouchBegan(self, touch)
end

function Draggable:getDraggingAnchor(position)
    position = self.node:convertToNodeSpace(position)
    if self.anchorType == Draggable.ANCHOR_TYPES.CUSTOM then
        if self.draggingAnchor then
            return self.draggingAnchor
        else
            return cc.p(position.x / self.nodeOriginalSize.width, position.y / self.nodeOriginalSize.height)
        end
    else
        return ANCHOR_POINTS[self.anchorType]
    end
end

function Draggable:onTouchMoved(touch)
    if not Draggable.super.onTouchMoved(self, touch) then return false end

    if not self:isDragLimiting() then return false end

    local position = self.node:getParent():convertToNodeSpace(touch:getLocation())
    local offX = self.nodeOriginalSize.width * (self.nodeOriginalAnchor.x - self.currDraggingAnchor.x)
    local offY = self.nodeOriginalSize.height * (self.nodeOriginalAnchor.y - self.currDraggingAnchor.y)
    self.node:move(position.x + offX, position.y + offY)
    return true
end

function Draggable:onTouchEnded(touch)
    if not Draggable.super.onTouchEnded(self, touch) then return false end

    if self.reboundEnabled then
        self:rebound()
    end
    return true
end

function Draggable:onTouchCanceled()
    if not Draggable.super.onTouchCanceled(self) then return false end
    return true
end

function Draggable:isDragLimiting()
    if self.isMoveLimit then
        local distance = cc.pGetDistance(self.touchBeganPosition, self.touchCurrPosition)
        if distance > self.moveThreshold then
            return false
        end
    end
    if self.onDragLimitFunc then
        return doCallback(self.onDragLimitFunc, self.touchCurrPosition)
    end
    return true
end

function Draggable:rebound()
    if self.onReboundFunc then
        doCallback(self.onReboundFunc, self.touchCurrPosition)
    else
        self:doDefaultRebound()
    end
end

function Draggable:setDragEnabled(enabled)
    self.isDragEnabled = enabled
end

function Draggable:setRebounding(rebounding)
    self.isRebounding = rebounding
end

function Draggable:doDefaultRebound()
    self.isRebounding = true
    self.node:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.5, self.nodeOriginalPosition),
            cc.CallFunc:create(function()
                self.isRebounding = false
            end)
    ))
end

return Draggable
