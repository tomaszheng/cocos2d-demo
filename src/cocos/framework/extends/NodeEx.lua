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

function Node:add(child, zorder, tag)
    if tag then
        self:addChild(child, zorder, tag)
    elseif zorder then
        self:addChild(child, zorder)
    else
        self:addChild(child)
    end
    return self
end

function Node:addTo(parent, zorder, tag)
    if tag then
        parent:addChild(self, zorder, tag)
    elseif zorder then
        parent:addChild(self, zorder)
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

function Node:moveCenter(parent)
    parent = parent or self:getParent()
    self:move(parent:center())
    return self
end

function Node:getCascadeScale()
    local scale, node = 1, self
    while node do
        scale = scale * node:getScale()
        node = node:getParent()
    end
    return scale
end

function Node:getWorldPosition()
    return self:getParent():convertToWorldSpace(self:getPosition())
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
    local size, anchor = self:getContentSize() , self:getAnchorPoint()
    local scale = self:getNodeToWorldTransform()[1]
    local x = self:getPositionX() - size.width * anchor.x
    local y = self:getPositionY() - size.height * anchor.y
    local position = self:getParent():convertToWorldSpace(cc.p(x, y))
    return cc.rect(position.x, position.y, size.width * scale, size.height * scale)
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

Node.scheduleUpdate = Node.onUpdate

function Node:onNodeEvent(eventName, callback)
    if "enter" == eventName then
        self.onEnterCallback_ = callback
    elseif "exit" == eventName then
        self.onExitCallback_ = callback
    elseif "enterTransitionFinish" == eventName then
        self.onEnterTransitionFinishCallback_ = callback
    elseif "exitTransitionStart" == eventName then
        self.onExitTransitionStartCallback_ = callback
    elseif "cleanup" == eventName then
        self.onCleanupCallback_ = callback
    end
    self:enableNodeEvents()
end

function Node:enableNodeEvents()
    if self.isNodeEventEnabled_ then
        return self
    end

    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter_()
        elseif state == "exit" then
            self:onExit_()
        elseif state == "enterTransitionFinish" then
            self:onEnterTransitionFinish_()
        elseif state == "exitTransitionStart" then
            self:onExitTransitionStart_()
        elseif state == "cleanup" then
            self:onCleanup_()
        end
    end)
    self.isNodeEventEnabled_ = true

    return self
end

function Node:disableNodeEvents()
    self:unregisterScriptHandler()
    self.isNodeEventEnabled_ = false
    return self
end

function Node:onEnter()
end

function Node:onExit()
end

function Node:onEnterTransitionFinish()
end

function Node:onExitTransitionStart()
end

function Node:onCleanup()
end

function Node:onEnter_()
    self:onEnter()
    if not self.onEnterCallback_ then
        return
    end
    self:onEnterCallback_()
end

function Node:onExit_()
    self:onExit()
    self:removeAllLuaComponents()
    if not self.onExitCallback_ then
        return
    end
    self:onExitCallback_()
end

function Node:onEnterTransitionFinish_()
    self:onEnterTransitionFinish()
    if not self.onEnterTransitionFinishCallback_ then
        return
    end
    self:onEnterTransitionFinishCallback_()
end

function Node:onExitTransitionStart_()
    self:onExitTransitionStart()
    if not self.onExitTransitionStartCallback_ then
        return
    end
    self:onExitTransitionStartCallback_()
end

function Node:onCleanup_()
    self:onCleanup()
    if not self.onCleanupCallback_ then
        return
    end
    self:onCleanupCallback_()
end

function Node:addTouchEvent(funcBegan, funcMoved, funcEnded, funcCancelled)
    local listener = cc.EventListenerTouchOneByOne:create();
    if funcBegan then
        listener:registerScriptHandler(funcBegan, cc.Handler.EVENT_TOUCH_BEGAN);
    end

    funcMoved = funcMoved or funcBegan
    if funcMoved then
        listener:registerScriptHandler(funcMoved, cc.Handler.EVENT_TOUCH_MOVED);
    end

    funcEnded = funcEnded or funcBegan
    if funcEnded then
        listener:registerScriptHandler(funcEnded, cc.Handler.EVENT_TOUCH_ENDED);
    end

    funcCancelled = funcCancelled or funcBegan
    if funcCancelled then
        listener:registerScriptHandler(funcCancelled, cc.Handler.EVENT_TOUCH_CANCELLED);
    end

    local eventDispatcher = self:getEventDispatcher();
    if self.__listener__  and type(self.__listener__) == "userdata" then
        eventDispatcher:removeEventListener(self.__listener__)
        self.__listener__ = nil
    end
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
    self.__listener__ = listener
    return listener
end

--@summary 移除node上的EventListener
--@summary 增加EventListener之前先把以前绑定的EventListener取消注册
function Node:removeTouchEvent()
    local eventDispatcher = self:getEventDispatcher();
    local listener = self.__listener__
    if listener  and type(listener) == "userdata" then
        eventDispatcher:removeEventListener(listener)
        self.__listener__ = nil
    end
    
end
function Node:isAncestorsVisible()
    local node = self
    while (node) do
        if not node:isVisible() then
            return false
        end
        node = self:getParent()
    end
    return true
end

---添加组件
---@param component component
function Node:addLuaComponent(component, data)
    self._luaComponents = self._luaComponents or {}
    local cname = component.__cname
    if not self._luaComponents[cname] then
        self._luaComponents[cname] = component.new(self, data)
        self:enableNodeEvents()
    end
    return self._luaComponents[cname]
end

---获取组件
---@param component component
---@return component
function Node:getLuaComponent(component)
    self._luaComponents = self._luaComponents or {}
    local cname = type(component) == "string" and component or component.__cname
    if self._luaComponents[cname] then
        return self._luaComponents[cname]
    else
        -- 用基类可以获取子类
        for _, value in pairs(self._luaComponents) do
            if iskindof(rawget(value, "class"), cname) then
                return value
            end
        end
    end
    return self._luaComponents[cname]
end

---移除组件
---@param component component
function Node:removeLuaComponent(component)
    self._luaComponents = self._luaComponents or {}
    local cname = type(component) == "string" and component or component.__cname
    if self._luaComponents[cname] then
        self._luaComponents[cname]:destroy()
        self._luaComponents[cname] = nil
    end
end

function Node:removeAllLuaComponents()
    self._luaComponents = self._luaComponents or {}
    if type(self._luaComponents) == "table" then
        for _, component in pairs(self._luaComponents) do
            component:destroy()
        end
        self._luaComponents = {}
    end
end