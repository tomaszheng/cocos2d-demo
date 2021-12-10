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

function string.utf8len(str)
    local len = 0
    local aNum = 0 --字母个数
    local hNum = 0 --汉字个数
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        local cs = charSize(char)
        currentIndex = currentIndex + cs
        len = len + 1
        if cs == 1 then
            aNum = aNum + 1
        elseif cs >= 2 then
            hNum = hNum + 1
        end
    end
    return len, aNum, hNum
end

function string.utf8sub(str, begin, length)
    local startIndex = 1
    while begin > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + charSize(char)
        begin = begin - 1
    end

    local currentIndex = startIndex

    while length > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + charSize(char)
        length = length - 1
    end
    return str:sub(startIndex, currentIndex - 1)
end

function string.utf8slice(str, len)
    len = len or 1
    local chars = {}
    for i = 1, math.ceil(string.utf8len(str) / len) do
        chars[i] = string.utf8sub(str, (i - 1) * len + 1, len)
    end
    return chars
end

function string.isAllAscii(str)
    local currentIndex, len = 1, #str
    while currentIndex <= len do
        local byte = string.byte(str, currentIndex)
        if byte < 0 or byte > 127 then return false end
        currentIndex = currentIndex + charSize(byte)
    end
    return true
end

function string.isValid(str)
    return str ~= nil and str ~= ""
end

function string.delete(str, start, ended, isUtf8)
    local len = string.utf8len(str)
    start = math.max(start, 1)
    ended = math.min(ended, len)
    if start > ended then
        start, ended = ended, start
    end
    local startStr, endedStr = "", ""
    if start ~= 1 then
        if isUtf8 then
            startStr = string.utf8sub(str, 1, start -1 )
        else
            startStr = string.sub(str, 1, start - 1)
        end
    end
    if ended ~= len then
        if isUtf8 then
            endedStr = string.utf8sub(str, ended + 1, len - ended + 1)
        else
            endedStr = string.sub(str, ended + 1)
        end
    end
    return startStr .. endedStr
end

function string.insert(str, pos, char, isUtf8)
    local len = #str
    if pos < 0 then
        pos = pos + len + 1
    elseif pos <= 1 then
        return string.push(char, str)
    elseif pos > len then
        return string.push(str, char)
    end
    local slices = {}
    if isUtf8 then
        table.insert(slices, string.utf8sub(str, 1, pos - 1))
        table.insert(slices, char)
        table.insert(slices, string.utf8sub(str, pos, len - pos + 1))
    else
        table.insert(slices, string.sub(str, 1, pos - 1))
        table.insert(slices, char)
        table.insert(slices, string.sub(str, pos))
    end
    return table.concat(slices)
end

function string.push(str, char)
    return str .. char
end

function string.toTable(s)
    local tb = {}
    for utfChar in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(tb, utfChar)
    end
    return tb
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
