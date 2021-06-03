﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/6/1 17:53
---
local BaseNode = class("BaseNode", ccui.Widget)

function BaseNode:ctor(...)
    self._globalListeners = {}
    self:enableNodeEvents()
end

function BaseNode:onExit(...)
    self:disableNodeEvents()
    self:removeAllGlobalListeners()
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