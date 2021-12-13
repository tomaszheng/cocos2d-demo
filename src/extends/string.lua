string._htmlSpecialChars_set = {}
string._htmlSpecialChars_set["&"] = "&amp;"
string._htmlSpecialChars_set["\""] = "&quot;"
string._htmlSpecialChars_set["'"] = "&#039;"
string._htmlSpecialChars_set["<"] = "&lt;"
string._htmlSpecialChars_set[">"] = "&gt;"

function string.htmlSpecialChars(str)
    for k, v in pairs(string._htmlSpecialChars_set) do
        str = string.gsub(str, k, v)
    end
    return str
end

function string.restoreHtmlSpecialChars(str)
    for k, v in pairs(string._htmlSpecialChars_set) do
        str = string.gsub(str, v, k)
    end
    return str
end

function string.nl2br(str)
    return string.gsub(str, "\n", "<br />")
end

function string.text2html(st2)
    st2 = string.gsub(st2, "\t", "    ")
    st2 = string.htmlSpecialChars(st2)
    st2 = string.gsub(st2, " ", "&nbsp;")
    st2 = string.nl2br(st2)
    return st2
end

function string.split(str, delimiter)
    str = tostring(str)
    delimiter = tostring(delimiter)
    if (delimiter == '') then
        return false
    end
    local pos, arr = 0, {}
    -- for each divider found
    for st, sp in function()
        return string.find(str, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function string.ltrim(str)
    return string.gsub(str, "^[ \t\n\r]+", "")
end

function string.rtrim(str)
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.trim(str)
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.upFirst(str)
    return string.gsub(str, "^%l", string.upper)
end

local function urlEncodeChar(char)
    return "%" .. string.format("%02X", string.byte(char))
end
function string.urlEncode(str)
    -- convert line endings
    str = string.gsub(tostring(str), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    str = string.gsub(str, "([^%w%.%- ])", urlEncodeChar)
    -- convert spaces to "+" symbols
    return string.gsub(str, " ", "+")
end

function string.urlDecode(str)
    str = string.gsub(str, "+", " ")
    str = string.gsub(str, "%%(%x%x)", function(h)
        return string.char(tonumber(h, 16) or 0)
    end)
    str = string.gsub(str, "\r\n", "\n")
    return str
end

function string.formatNumberThousands(num)
    local formatted = tostring((tonumber(num) or 0))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

local function charSize(ch)
    if not ch then
        return 0
    elseif ch >= 252 then
        return 6
    elseif ch >= 248 and ch < 252 then
        return 5
    elseif ch >= 240 and ch < 248 then
        return 4
    elseif ch >= 224 and ch < 240 then
        return 3
    elseif ch >= 192 and ch < 224 then
        return 2
    elseif ch < 192 then
        return 1
    end
end

--- 返回字符串长度，以utf8格式
--- @param source string 源字符串
--- @return number, number 字符串长度，ascii字符个数
function string.utf8len(source)
    local len, ascii, currentIndex, total = 0, 0, 1, #source
    while currentIndex <= total do
        local size = charSize(string.byte(source, currentIndex))
        currentIndex = currentIndex + size
        len = len + 1
        if size == 1 then
            ascii = ascii + 1
        end
    end
    return len, ascii
end

--- 以utf8方式截取字符串的一部分
--- @param source string 原始字符串
--- @param from number 开始位置
--- @param len number 截取的长度，以字符记，特殊的：len=0，截取到字符串尾部
--- @param isBytes boolean begin是否是字节数，默认为false
function string.utf8sub(source, from, len, isBytes)
    local byteNum = #source
    local startIndex, currentIndex = from, from
    if not isBytes then
        while from > 1 do
            local char = string.byte(source, startIndex)
            startIndex = startIndex + charSize(char)
            from = from - 1
        end
        currentIndex = startIndex
    end

    if len <= 0 then
        currentIndex = byteNum + 1
    else
        while len > 0 and currentIndex <= byteNum do
            local char = string.byte(source, currentIndex)
            currentIndex = currentIndex + charSize(char)
            len = len - 1
        end
    end
    local str = source:sub(startIndex, currentIndex - 1)
    return str, startIndex, currentIndex - 1
end

function string.utf8slice(source, len)
    len = len or 1
    local chars, from, to = {}, 1, 1
    local num = math.ceil(string.utf8len(source) / len)
    for i = 1, num do
        chars[i], from, to = string.utf8sub(source, from, len, true)
        from = to + 1
    end
    return chars
end

function string.utf8delete(source, from, to)
    local len, head, tail = string.utf8len(source), "", ""
    from = math.max(from < 0 and from + len + 1 or from, 1)
    to = math.min(to < 0 and to + len + 1 or to, len)
    if from > to then
        from, to = to, from
    end
    if from ~= 1 then
        head = string.utf8sub(source, 1, from - 1)
    end
    if to ~= len then
        tail = string.utf8sub(source, to + 1, len - to + 1)
    end
    return head .. tail
end

function string.utf8insert(source, pos, str)
    local len = string.utf8len(source)
    pos = pos < 0 and pos + len + 1 or pos
    if pos == 1 then
        return string.append(str, source)
    elseif pos > len then
        return string.append(source, str)
    end
    local head, _, to = string.utf8sub(source, 1, pos - 1)
    local tail = string.sub(source, to + 1)
    return table.concat({ head, str, tail })
end

function string.isAllAscii(source)
    local currentIndex, len = 1, #source
    while currentIndex <= len do
        local byte = string.byte(source, currentIndex)
        if byte < 0 or byte > 127 then return false end
        currentIndex = currentIndex + charSize(byte)
    end
    return true
end

function string.isValid(str)
    return str ~= nil and str ~= ""
end

function string.delete(source, from, to)
    local len, head, tail = #source, "", ""
    from = math.max(from < 0 and from + len + 1 or from, 1)
    to = math.min(to < 0 and to + len + 1 or to, len)
    if from > to then
        from, to = to, from
    end
    if from ~= 1 then
        head = string.sub(source, 1, from - 1)
    end
    if to ~= len then
        tail = string.sub(source, to + 1)
    end
    return head .. tail
end

function string.insert(source, pos, str)
    local len = #source
    pos = pos < 0 and pos + len + 1 or pos
    if pos <= 1 then
        return string.append(str, source)
    elseif pos > len then
        return string.append(source, str)
    end
    local head = string.sub(source, 1, pos - 1)
    local tail = string.sub(source, pos)
    return table.concat({head, str, tail})
end

function string.append(...)
    local strings = {...}
    return table.concat(strings)
end

function string.concat(...)
    local strings, splitter = {...}, ""
    if #strings > 2 then
        splitter = table.remove(strings)
    end
    return table.concat(strings, splitter)
end

function string.slice(source, len)
    len = len or 1
    local patterns, pattern = {}, "[%z\1-\127\194-\244][\128-\191]*"
    for _ = 1, len do
        table.insert(patterns, pattern)
    end
    pattern = table.concat(patterns)
    local ret, n = {}, 0
    string.gsub(source, pattern, function(str)
        n = n + #str
        table.insert(ret, str)
    end)
    if n < #source then
        table.insert(ret, string.sub(source, n + 1))
    end
    return ret
end

-- 可读的格式化字符串方法
-- 示例1: string.layout("uri/cocos/${version}/${lang}/", 4.0, "lua")
-- 示例1输出: uri/cocos/4/lua/
-- 示例2: string.layout("uri/cocos/${version}/${lang}/", {version = 4.0, lang = "lua"})
-- 示例2输出: uri/cocos/4/lua/
-- 示例3: string.layout("uri/cocos/${version:%.1f}/${lang}/", {version = 4.0, lang = "lua"})
-- 示例3输出: uri/cocos/4.0/lua/
function string.layout(pattern, ...)
    local args = {...}
    if #args == 1 and type(args[1]) == "table" then
        args = args[1]
    end

    local index = 0
    return string.gsub(pattern, "${([^{}]+)}", function(name)
        index = index + 1
        local key, fmt = unpack(string.split(name, ":"))
        local value = args[key] or args[index] or key
        return fmt and string.format(fmt, value) or value
    end)
end
