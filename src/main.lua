function __G__TRACKBACK__(msg)
    print('----------------------------------------')
    print('LUA ERROR: ' .. tostring(msg) .. '\n')
    print(debug.traceback())
    print('----------------------------------------')
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
