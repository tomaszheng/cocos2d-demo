﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/11/24 11:36
---
local BaseScene = class("BaseScene", function()
    return display.newScene()
end)

function BaseScene:ctor()
    self._globalListeners = {}
    self:enableNodeEvents()
end

function BaseScene:onEnter(...)
    printLog(self.__cname, "onEnter")
    if device.platform == "windows" or device.platform == "mac" then
        cc.Director:getInstance():getOpenGLView():setFrameSize(CC_FRAME_SIZE.width, CC_FRAME_SIZE.height)
    end
end

function BaseScene:onExit()
    printLog(self.__cname, "onExit")

    self:disableNodeEvents()
    self:removeAllGlobalListeners()
    display.removeUnusedSpriteFrames()
end

function BaseScene:addGlobalListener(eventName, callback)
    local handle = EventManager.instance:addEventListener(eventName, callback)
    table.insert(self._globalListeners, handle)
    return handle
end

function BaseScene:removeAllGlobalListeners()
    table.walk(self._globalListeners, function(handle)
        EventManager.instance:removeEventListener(handle)
    end)
    self._globalListeners = {}
end

return BaseScene