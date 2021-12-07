--[[
  console debug utils
]]--

function printf(fmt, ...)
    print(string.format(tostring(fmt), ...))
end

--[[
  auto add tag to print line's head
  @function printLog
  @param string tag, like "WARN" etc.
  @param string fmt, print format
  @param ..., format's params

  example:
  printLog("WARN", "Network connection lost at %d", os.time())
]]--
function printLog(tag, fmt, ...)
    local t = {
        "[",
        tostring(tag),
        "] ",
        string.format(tostring(fmt), ...)
    }
    print(table.concat(t))
end

--[[
  auto add "ERR" to print line's head, auto print debug.traceback
  @function printError
  @param string fmt, print format
  @param ..., format's params
]]--
function printError(fmt, ...)
    printLog("ERR", fmt, ...)
    print(debug.traceback("", 2))
end

--[[
  auto add "INFO" to print line's head
  @function printInfo
  @param string fmt, print format
  @param ..., format's params
]]--
function printInfo(fmt, ...)
    printLog("INFO", fmt, ...)
end

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

--[[
  print struct info of a Lua value.
  @function dump
  @param mixed value, Lua value to print.
  @param string desciption, print desciption before Lua value.
  @parma integer nesting, print MAX nesting on a table.

  example:
  dump({[1] = 1, a = 2})
  dump({a = 1, b = 2}, "TableDump", 3)
]]--
function dump(value, description, nesting)
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 2), "\n")
    print("dump from: " .. string.trim(traceback[3]))

    local function dump_(value, description, indent, nest, keylen)
        description = description or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(description)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(description), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(description), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(description))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(description))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, description, "- ", 1)

    for i, line in ipairs(result) do
        print(line)
    end
end
