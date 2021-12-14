------------------------Promise---------------------------
---Api:
---     function Promise:tracking(fn)
---     function Promise:next(success,fail)
---     function Promise:catchError(fail)
---Trigger
---     function Promise:track(v)
---     function Promise:resolve(arg)
---     function Promise:reject(msg)
---Utils
---     function Promise.all(promiseList)

local PENDING = 0
local RESOLVED = 1
local REJECTED = 2

local call = function(fn, ...)
    if type(fn) == 'function' then
        return fn(...)
    end
end

local Promise = class('Promise')

function Promise:ctor(options)
    self.state = PENDING
    if type(options) == 'table' then
        self._successCb = options.success
        self._failCb = options.fail
    end
    self._isPromise = true
    self._queue = {}
end

function Promise:resolve(arg)
    local this = self
    self._successArg = arg

    if self.state == REJECTED then
        print('REJECTED!')
        return
    end

    local p = this:_getPromise()
    if p and p._successCb then
        p.state = RESOLVED
        local ret = call(p._successCb, arg)
        p.ret = ret
        if ret and ret._isPromise then
            ret:next(function(...)
                this:resolve(...)
            end, function(msg)
                this:reject(msg)
            end)
        else
            this:resolve(ret)
        end
    else
        this.state = RESOLVED
    end
end

function Promise:reject(msg)
    self._failMsg = msg
    if self.state ~= REJECTED then
        self._errMsg = msg
    end
    self.state = REJECTED
    local p = self:_getPromise()
    if p then
        local ret
        if p._failCb then
            ret = call(p._failCb, msg)
        end
        p.state = REJECTED
        self:reject(ret)
    else
        call(self._errCb, self._errMsg)
    end
end

function Promise:next(success, fail)
    local p = Promise.new({ success = success, fail = fail })
    local lp = self._queue[#self._queue]
    table.insert(self._queue, p)
    if not lp or
            (lp.state == RESOLVED and not lp.ret) or
            (lp.state == RESOLVED and lp.ret and not lp.ret._isPromise) or
            (lp.state == RESOLVED and lp.ret and lp.ret._isPromise and lp.ret.state == RESOLVED) or
            (lp.state == REJECTED) then
        self:_doExecute()
    end
    return self
end

function Promise:_doExecute()
    if self.state == RESOLVED then
        self:resolve(self._successArg)
    elseif self.state == REJECTED then
        self:reject(self._failMsg)
    end
end

function Promise:catchError(errCb)
    self._errCb = errCb
    if self.state == REJECTED then
        self:reject(self._failMsg)
    end
end

function Promise:track(...)
    if self.state == PENDING then
        call(self._trackingCb, ...)
    end
    return self
end

function Promise:_getPromise()
    for i, p in ipairs(self._queue) do
        if p.state == PENDING then
            return p, i
        end
    end
end

function Promise:tracking(fn)
    self._trackingCb = fn
    return self
end

---同时开始多个promise，所有promise均成功后，执行resolve；如果有失败的promise，则根据waitAllFinish指定执行reject的时机
---@param promises array promise列表
---@param waitAllFinish boolean 指定执行reject的时机，如果true，所有promise完成后，至少有一个失败，则执行reject；否则，在第一个失败时，执行reject
function Promise.all(promises, waitAllFinish)
    promises = promises or {}
    waitAllFinish = waitAllFinish == nil and true or waitAllFinish
    local p = Promise.new()
    if #promises < 1 then
        print('Warning!! Empty args, please check!')
        p:resolve()
        return p
    end

    local sNum, fNum = 0, 0
    local complete = function()
        if sNum + fNum < #promises then return end
        if sNum == #promises then
            p:resolve()
        elseif p.state ~= REJECTED then
            p:reject()
        end
    end

    local success = function()
        sNum = sNum + 1
        complete()
    end

    local fail = function()
        fNum = fNum + 1
        if waitAllFinish then
            complete()
        elseif p.state ~= REJECTED then
            p:reject()
        end
    end

    for _, v in ipairs(promises) do
        v:next(success, fail)
    end

    return p
end

function Promise.first(promises)
    promises = promises or {}
    local p = Promise.new()
    if #promises < 1 then
        print('Warning!! Empty args, please check!')
        p:resolve()
        return p
    end

    local done = false
    local success = function()
        if done then return end
        p:resolve()
        done = true
    end

    local fail = function()
        if done then return end
        p:reject()
        done = true
    end

    for _, v in ipairs(promises) do
        v:next(success, fail)
    end

    return p
end

return Promise

--[[ usage cases
function async()
    --track(1),track(2)
    --resolve/reject
end
case1:
    01  async():next(onSuccess,onFail)
    02  async():next(onSuccess):catchError(onFail)

case2:
    async()
        :next(doSth1)
        :next(doSth2)
        :next(function() return async() end)
        :next(onSuccess)
        :catchError(onFail)

case3:
    Promise.all():next(onSuccess,onFail)

case4:
    async():tracking(onTracking):next(onSuccess)
]]--