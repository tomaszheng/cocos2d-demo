local Component = class('Component')

function Component:ctor(node, data) 
    self.node = node
    self.data = data
    self._id = nil
    self._listeners = {}
end

function Component:setId(id)
    self._id = id
end

function Component:getId()
    return self._id and self._id or self.node.__cname
end

function Component:onDestroy()
    print('---------Component', self.__cname, 'onDestroy')
    self:removeAllListeners()
end

function Component:destroy()
    self:onDestroy()
end

function Component:addListener(eventName, callback)
    local event = eventMediator:listen(eventName, callback):bindHost(self)
    table.insert(self._listeners, event)
    return event
end

function Component:removeAllListeners()
    for _, event in pairs(self._listeners) do
        eventMediator:removeListener(event)
    end
end

return Component