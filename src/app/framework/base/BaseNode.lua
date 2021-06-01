local BaseNode = class("BaseNode", ccui.Widget)

function BaseNode:ctor(...)
    self._globalListeners = {}
    self:enableNodeEvents()
end

function BaseNode:onExit(...)
    self:disableNodeEvents()
    self:removeAllGlobalListeners()
end

function BaseNode:delayAction(call, delay)
    return self:runAction(cc.Sequence:create(
        cc.DelayTime:create(delay or 0), 
        cc.CallFunc:create(function()
            doCallback(call)
        end)))
end

function BaseNode:repeatAction(call, duration)
    return self:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.CallFunc:create(call), 
        cc.DelayTime:create(duration)
    )))
end

function BaseNode:addGlobalListener(eventName, callback)
    local handle = eventManager:addEventListener(eventName, callback)
    table.insert(self._globalListeners, handle)
    return handle
end

function BaseNode:removeAllGlobalListeners()
    table.walk(self._globalListeners, function(handle)
        eventManager:removeEventListener(handle)
    end)
end

return BaseNode
