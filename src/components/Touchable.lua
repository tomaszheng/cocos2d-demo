﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/12/13 18:20
--- Content: 触摸组件
---
local Touchable = class("Touchable", BaseComponent)

Touchable.CLICK_STYLES = {
    NONE    = 'none',
    COLOR   = 'color',
    SCALE   = 'scale',
    IMAGE   = 'image'
}

Touchable.ON_BEGAN = "on-began"
Touchable.ON_MOVED = "on-moved"
Touchable.ON_ENDED = "on-ended"
Touchable.ON_CANCELED = "on-canceled"
Touchable.ON_DESTROY = "on-destroy"

function Touchable:ctor(node, data)
    cc.load("event").new():bind(self)
    Touchable.super.ctor(self, node, data)
    self:initData(data)
    self:initListener()
end

function Touchable:initData(data)
    data = data or {}
    self.shape = data.shape or {}
end

function Touchable:initListener()
    self.node:addTouchEvent({
        onBegan = handler(self, self.onTouchBegan),
        onMoved = handler(self, self.onTouchMoved),
        onEnded = handler(self, self.onTouchEnded),
        onCanceled = handler(self, self.onTouchCanceled),
    })
end

function Touchable:onTouchBegan(touch)
    if self:isHit(touch) then
        self:dispatchEvent({name = Touchable.ON_BEGAN, sender = self, touch = touch})
        return true
    end
    return false
end

function Touchable:onTouchMoved(touch)
    self:dispatchEvent({name = Touchable.ON_MOVED, sender = self, touch = touch})
end

function Touchable:onTouchEnded(touch)
    local isHit = self:isHit(touch)
    self:dispatchEvent({name = Touchable.ON_ENDED, sender = self, touch = touch, isHit = isHit})
end

function Touchable:onTouchCanceled()
    self:dispatchEvent({name = Touchable.ON_CANCELED, sender = self})
end

function Touchable:isHit(touch)
    if not self.node:isAncestorsVisible() then return false end

    local location = touch:getLocation()
    local position = self.node:convertToNodeSpace(location)
    if next(self.shape) then
        return IntersectionUtils.pInPolygon(position, self.shape)
    elseif type(self.node.isHit) == "function" then
        return self.node:isHit(position)
    else
        position = self.node:getParent():convertToNodeSpace(location)
        return cc.rectContainsPoint(self.node:getBoundingBox(), position)
    end
end

function Touchable:onDestroy()
    self:dispatchEvent({name = Touchable.ON_DESTROY})
end

return Touchable