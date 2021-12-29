﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/12/29 17:02
---
local TouchConstants = require("src.components.touch.TouchConstants")
local Dragging = class("Dragging", BaseComponent)

local DEFAULT_FOLLOW_FRAME = 10

function Dragging:ctor(node, data)
    Dragging.super.ctor(self, node, data)
    self:initData(data)
end

function Dragging:initData(data)
    data = data or {}
    -- 拖拽时什么位置与触摸点对齐
    self._alignType = data.alignType or TouchConstants.DRAG_ALIGN_TYPES.CUSTOM
    self._alignAnchor = data.alignAnchor
    -- 是否可以回弹
    self._reboundEnabled = data.reboundEnabled or false
    -- 回弹响应方法
    self._onReboundFunc = data.onRebound
    -- 是否可以跟随
    self._isStartFollowEnabled = data.startFollowEnabled or false
    self._isMoveFollowEnabled = data.moveFollowEnabled or false
    -- 拖拽响应函数
    self._onMoveFunc = data.onMove
    self._onFollowFunc = data.onStartFollow

    -- node数据
    self._nodeOriginalAnchor = cc.p(0, 0)
    self._nodeOriginalSize = cc.size(0, 0)
    self._nodeOriginalPosition = cc.p(0, 0)
    self._isNodeOriginalSaved = false

    self._nodeCurrPosition = cc.p(0, 0)

    self._isDragging = false
    self._isStartFollowed = false
    self._followSpeed = cc.p(0, 0)
    self._isFollowing = false
    self._isRebounding = false
    self._currAlignAnchor = cc.p(0, 0)
    self._reboundAction = nil
    self._dstPosition = cc.p(0, 0)
end

function Dragging:begin(position)
    if not self._isNodeOriginalSaved then
        self:updateOriginalData()
    end
    self._nodeCurrPosition = cc.p(self._nodeOriginalPosition.x, self._nodeOriginalPosition.y)
    self._currAlignAnchor = self:getCurrAlignAnchor(position)
    self._isStartFollowed = false
    self._isDragging = true
end

function Dragging:getCurrAlignAnchor(position)
    position = self.node:convertToNodeSpace(position)
    if self._alignType == TouchConstants.DRAG_ALIGN_TYPES.CUSTOM then
        if self._alignAnchor then
            return self._alignAnchor
        else
            return cc.p(position.x / self._nodeOriginalSize.width, position.y / self._nodeOriginalSize.height)
        end
    else
        return TouchConstants.DRAG_ALIGN_ANCHOR[self._alignType]
    end
end

function Dragging:drag(position)
    position = self.node:getParent():convertToNodeSpace(position)
    local size = self.node:getRealSize()
    local offX = size.width * (self._nodeOriginalAnchor.x - self._currAlignAnchor.x)
    local offY = size.height * (self._nodeOriginalAnchor.y - self._currAlignAnchor.y)

    self._dstPosition.x = position.x + offX
    self._dstPosition.y = position.y + offY
    self._followSpeed.x = (self._dstPosition.x - self._nodeCurrPosition.x) / DEFAULT_FOLLOW_FRAME
    self._followSpeed.y = (self._dstPosition.y - self._nodeCurrPosition.y) / DEFAULT_FOLLOW_FRAME
    self._followSpeed.x = self:standardizing(self._followSpeed.x)
    self._followSpeed.y = self:standardizing(self._followSpeed.y)

    self:move()
end

function Dragging:standardizing(f)
    return f < 0 and math.min(f, -1) or math.max(f, 1)
end

function Dragging:move()
    if self._isStartFollowEnabled and not self._isStartFollowed then
        if self._onFollowFunc then
            self._isStartFollowed = doCallback(self._onFollowFunc, self._dstPosition)
            self._nodeCurrPosition = cc.p(self.node:getPosition())
        else
            self:follow()
        end
    elseif self._onMoveFunc then
        doCallback(self._onMoveFunc, self._dstPosition)
        self._nodeCurrPosition = cc.p(self.node:getPosition())
    elseif self._isMoveFollowEnabled then
        self:follow()
    else
        self.node:move(self._dstPosition)
        self._nodeCurrPosition.x, self._nodeCurrPosition.y = self._dstPosition.x, self._dstPosition.y
    end
end

function Dragging:ended()
    self._isDragging = false
    self:stopFollow()
    self:rebound()
end

function Dragging:follow()
    if not self._isFollowing then
        self._isFollowing = true
        self.node:onUpdate(handler(self, self.doFollow))
    end
end

function Dragging:doFollow()
    local x = self._nodeCurrPosition.x + self._followSpeed.x
    local y = self._nodeCurrPosition.y + self._followSpeed.y
    local followedN = 0
    if math.abs(x - self._dstPosition.x) <= 1 then
        x, followedN = self._dstPosition.x, followedN + 1
    end
    if math.abs(y - self._dstPosition.y) <= 1 then
        y, followedN = self._dstPosition.y, followedN + 1
    end
    self.node:move(x, y)
    self._nodeCurrPosition.x, self._nodeCurrPosition.y = x, y
    if followedN == 2 then
        self:stopFollow()
    end
end

function Dragging:stopFollow()
    if self._isStartFollowEnabled and not self._isStartFollowed then
        self._isStartFollowed = true
    end
    self._isFollowing = false
    self.node:unUpdate()
end

function Dragging:rebound()
    if not self._reboundEnabled then return end

    if self._onReboundFunc then
        self._isRebounding = true
        doCallback(self._onReboundFunc)
    else
        self:doRebound()
    end
end

function Dragging:doRebound()
    self._isRebounding = true
    self._reboundAction = self.node:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.5, self._nodeOriginalPosition),
            cc.CallFunc:create(function()
                self._reboundAction = nil
                self._isRebounding = false
            end)
    ))
end

function Dragging:stopRebound()
    if self._reboundAction then
        self.node:stopAction(self._reboundAction)
    end
    self._reboundAction = nil
    self._isRebounding = false
end

function Dragging:isRebounding()
    return self._isRebounding
end

function Dragging:isDragCompleted()
    return not self._isFollowing and not self._isRebounding and not self._isDragging
end

function Dragging:updateOriginalData()
    self._nodeOriginalAnchor = self.node:getAnchorPoint()
    self._nodeOriginalSize = self.node:getContentSize()
    self._nodeOriginalPosition = cc.p(self.node:getPosition())
    self._isNodeOriginalSaved = true
end

function Dragging:onDestroy()
    self:stopFollow()
    self:stopRebound()
end

return Dragging