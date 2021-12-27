function __G__TRACKBACK__(msg)
    print('----------------------------------------')
    print('LOG DATE: ' .. os.date("%c"))
    print('LUA ERROR: ' .. tostring(msg))
    print(debug.traceback())
    print('----------------------------------------')

    if loge then
        loge(msg, false)
    end
end

cc.FileUtils:getInstance():setPopupNotify(false)

local function main()
    require("src.init")

    display.runScene(require("src.views.MainScene").new())
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
