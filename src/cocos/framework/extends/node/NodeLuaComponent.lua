﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/12/13 16:26
---
local Node = cc.Node

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
