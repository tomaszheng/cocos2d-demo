function table.size(t)
    if type(t) ~= "table" then
        return 0;
    end
    local len = 0;
    for k, v in pairs(t) do
        len = len + 1
    end
    return len;
end

table.nums = table.size

function table.keys(hashTable)
    local keys = {}
    for k, v in pairs(hashTable) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.values(hashTable)
    local values = {}
    for k, v in pairs(hashTable) do
        values[#values + 1] = v
    end
    return values
end

function table.merge(dest, src)
    assert(type(dest) == type(src))
    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = dest[k] or {}
            table.merge(dest[k], v)
        else
            dest[k] = v
        end
    end
end

function table.insertTo(dest, src, begin)
    begin = tonumber(begin) or 0
    if begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

function table.indexOf(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then
            return i
        end
    end
    return false
end

function table.keyOf(hashTable, value)
    for k, v in pairs(hashTable) do
        if v == value then
            return k
        end
    end
    return nil
end

function table.removeByValue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then
                break
            end
        end
        i = i + 1
    end
    return c
end

function table.map(t, fn)
    for k, v in pairs(t or {}) do
        t[k] = fn(v, k)
    end
end

function table.walk(t, fn)
    for k, v in pairs(t or {}) do
        fn(v, k)
    end
end

--- 遍历数组，直到找到符合条件的值
--- @param t array 待遍历的数组
--- @param fn function 条件函数
--- @param begin number 起始位置
--- @param reverse boolean 是否从数组尾部开始遍历
--- @return boolean, any, number
function table.some(t, fn, begin, reverse)
    begin = begin or 1
    if begin < 0 then
        begin = begin + #t + 1
    end
    local tail = reverse and 1 or #t
    local step = reverse and -1 or 1
    for i = begin, tail, step do
        if fn(t[i], i) then
            return true, t[i], i
        end
    end
    return false
end

function table.filter(t, fn)
    for k, v in pairs(t or {}) do
        if not fn(v, k) then
            t[k] = nil
        end
    end
end

function table.unique(t, bArray)
    bArray = bArray == nil and true or bArray
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(t) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end

function table.reverse(array)
    local l = #array
    for i = 1, l / 2 do
        array[i], array[l - i + 1] = array[l - i + 1], array[i]
    end
    return array
end

--是否为纯数组
function table.isArray(t)
    if type(t) ~= "table" then
        return false
    end

    local n = #t
    for i, v in pairs(t) do
        if type(i) ~= "number" then
            return false
        end

        if i > n then
            return false
        end
    end

    return true
end

---查找map 中，指定的 table
---@param hashTable table  例如：{{a = value, b = xxxx}, {b = value2, b = xxxx}}
---@param keyName string a
---@param value any  value
---@return table  例如：{a = value, b = xxxx}
function table.findTable(hashTable, keyName, value)
    if not type(hashTable) == 'table' then
        return
    end
    for _, data in pairs(hashTable) do
        if data[keyName] == value then
            return data
        end
    end
end

function table.numList(from, to, step)
    local array = {}
    step = step or 1
    for i = from, to, step do
        table.insert(array, i)
    end
    return array
end

--打乱数组
function table.randomSort(array)
    local newArray = {}
    local count = 0
    for k, v in pairs(array) do
        count = count + 1
        newArray[count] = v
    end
    local length = #newArray
    for i = length, 2, -1 do
        local randomIndex = math.random(1, i)
        local item = newArray[randomIndex]
        newArray[randomIndex] = newArray[i]
        newArray[i] = item
    end
    return newArray
end

function table.arrayToMap(array)
    local map = {}
    for _, gameId in pairs(array) do
        map[gameId] = true
    end
    return map
end

---- join table, example: table.join({1,2,3},{'q',5})
function table.join(...)
    local dest = {}
    local args = { ... }
    for _, t in pairs(args or {}) do
        assert(type(t) == 'table')
        for i, v in pairs(t) do
            table.insert(dest, v)
        end
    end
    return dest
end

-- 对比 table
function table.compare(a, b)
    if type(a) == "table" and type(b) == "table" then
        if table.size(a) ~= table.size(b) then
            return false
        end
        for k, v in pairs(a) do
            if not table.compare(v, b[k]) then
                return false
            end
        end
        return true
    end
    return a == b
end
