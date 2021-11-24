local BaseComponent = class('BaseComponent')

function BaseComponent:ctor(node, data)
    self.node = node
    self.data = data
    self._id = nil
    self._listeners = {}
end

function BaseComponent:setId(id)
    self._id = id
end

function BaseComponent:getId()
    return self._id and self._id or self.node.__cname
end

function BaseComponent:onDestroy()
    print('---------Component', self.__cname, 'onDestroy')
    self:removeAllListeners()
end

function BaseComponent:destroy()
    self:onDestroy()
end

function BaseComponent:addListener(eventName, callback)
    local event = eventManager:addEventListener(eventName, callback)
    table.insert(self._listeners, event)
    return event
end

function BaseComponent:removeAllListeners()
    table.walk(self._listeners, function(handle)
        eventManager:removeEventListener(handle)
    end)
    self._listeners = {}
end

return BaseComponent