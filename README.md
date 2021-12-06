使用Cocos2d-x做一些有意思的demo

## 一、搭建环境

1，创建工程

```powershell
mkdir win32-build
cd win32-build
cmake .. -G"Visual Studio 16 2019" -Tv142 -A win32
```

2，编译

```powershell
cmake --build . --config Debug
```

3，Sublime 启动配置

```
{
    "cmd": ["D:\\XXX\\cocos2d-demo\\win32-build\\bin\\cocos2d-demo\\Debug\\cocos2d-demo.exe"],
    "file_regex": "^(?:lua:)?[\t ](...*?):([0-9]*):?([0-9]*)",
    "selector": "source.lua",
    "encoding": "cp936",
    "shell": true,
    "working_dir" : "D:\\XXX\\cocos2d-demo\\win32-build\\bin\\cocos2d-demo\\Debug"
}
```

