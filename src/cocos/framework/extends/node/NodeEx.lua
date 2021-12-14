--[[

Copyright (c) 2014-2017 Chukong Technologies Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local Node = cc.Node

function Node:add(child, zOrder, tag)
    if tag then
        self:addChild(child, zOrder, tag)
    elseif zOrder then
        self:addChild(child, zOrder)
    else
        self:addChild(child)
    end
    return self
end

function Node:addTo(parent, zOrder, tag)
    if tag then
        parent:addChild(self, zOrder, tag)
    elseif zOrder then
        parent:addChild(self, zOrder)
    else
        parent:addChild(self)
    end
    return self
end

function Node:removeSelf()
    self:removeFromParent()
    return self
end

function Node:align(anchorPoint, x, y)
    self:setAnchorPoint(anchorPoint)
    return self:move(x, y)
end

function Node:show()
    self:setVisible(true)
    return self
end

function Node:hide()
    self:setVisible(false)
    return self
end

function Node:move(x, y)
    if y then
        self:setPosition(x, y)
    else
        self:setPosition(x)
    end
    return self
end

function Node:moveX(x)
    self:setPositionX(x)
    return self
end

function Node:moveY(y)
    self:setPositionY(y)
    return self
end

function Node:x()
    return self:getPositionX()
end

function Node:y()
    return self:getPositionY()
end

function Node:moveOffset(x, y)
    self:moveOffsetX(x)
    self:moveOffsetY(y)
    return self
end

function Node:moveOffsetX(x)
    self:setPositionX(self:getPositionX() + x)
    return self
end

function Node:moveOffsetY(y)
    self:setPositionY(self:getPositionY() + y)
    return self
end

function Node:center()
    local size = self:getSize()
    return cc.p(size.width / 2, size.height / 2)
end

function Node:moveCenter()
    self:move(self:getParent():center())
    return self
end

function Node:getCascadeScale()
    return self:getNodeToWorldTransform()[1]
end

function Node:getWorldPosition()
    return self:getParent():convertToWorldSpace(cc.p(self:getPosition()))
end

function Node:getSize()
    return self:getContentSize()
end

function Node:getRealSize()
    local size = self:getSize()
    return cc.size(size.width * self:getScaleX(), size.height * self:getScaleY())
end

function Node:getHeight()
    return self:getContentSize().height
end

function Node:getWidth()
    return self:getContentSize().width
end

function Node:setWidth(w)
    self:setContentSize(cc.size(w, self:getHeight()))
end

function Node:setHeight(h)
    self:setContentSize(cc.size(self:getWidth(), h))
end

function Node:moveTo(args)
    transition.moveTo(self, args)
    return self
end

function Node:moveBy(args)
    transition.moveBy(self, args)
    return self
end

function Node:fadeIn(args)
    transition.fadeIn(self, args)
    return self
end

function Node:fadeOut(args)
    transition.fadeOut(self, args)
    return self
end

function Node:fadeTo(args)
    transition.fadeTo(self, args)
    return self
end

function Node:rotate(rotation)
    self:setRotation(rotation)
    return self
end

function Node:rotateTo(args)
    transition.rotateTo(self, args)
    return self
end

function Node:rotateBy(args)
    transition.rotateBy(self, args)
    return self
end

function Node:scaleTo(args)
    transition.scaleTo(self, args)
    return self
end

function Node:onUpdate(callback)
    self:scheduleUpdateWithPriorityLua(callback, 0)
    return self
end

function Node:getBoundingBoxToWorld()
    local cascadeScale = self:getNodeToWorldTransform()[1]
    local size, anchor, scale = self:getContentSize(), self:getAnchorPoint(), self:getScale()
    local x = self:getPositionX() - size.width * scale * anchor.x
    local y = self:getPositionY() - size.height * scale * anchor.y
    local position = self:getParent():convertToWorldSpace(cc.p(x, y))
    return cc.rect(position.x, position.y, size.width * cascadeScale, size.height * cascadeScale)
end

function Node:getCascadeBoundingBox()
    local rect = self:getCascadeBoundingBoxToWorld()
    return self:getParent():convertRectToNodeSpace(rect)
end

function Node:getCascadeBoundingBoxToWorld()
    local children, total = self:getChildren()
    table.walk(children, function(child)
        local box = child:getCascadeBoundingBoxToWorld()
        total = total and cc.rectUnion(total, box) or box
    end)
    local box = self:getBoundingBoxToWorld()
    total = total and cc.rectUnion(total, box) or box
    return total
end

function Node:convertRectToNodeSpace(rect)
    local lb = self:convertToNodeSpace(cc.p(rect.x, rect.y))
    local rt = self:convertToNodeSpace(cc.p(rect.x + rect.width, rect.y + rect.height))
    return cc.rect(lb.x, lb.y, rt.x - lb.x, rt.y - lb.y)
end

function Node:delayAction(callback, delay)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(delay or 0), cc.CallFunc:create(function()
        doCallback(callback)
    end)))
end

function Node:repeatAction(callback, delay, num)
    if num and type(num) == "number" then
        self:runAction(cc.Repeat:create(cc.Sequence:create(
                cc.CallFunc:create(function()
                    num = num - 1
                    doCallback(callback, num)
                end), cc.DelayTime:create(delay)
        )), num)
    else
        self:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.CallFunc:create(callback), cc.DelayTime:create(delay)
        )))
    end
end

function Node:isAncestorsVisible()
    local node = self
    while (node) do
        if not node:isVisible() then
            return false
        end
        node = node:getParent()
    end
    return true
end
