--[[

Copyright (c) 2014-2017 Chukong Technologies Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

require "src.cocos.cocos2d.Cocos2d"
require "src.cocos.cocos2d.Cocos2dConstants"
require "src.cocos.cocos2d.functions"

-- opengl
require "src.cocos.cocos2d.Opengl"
require "src.cocos.cocos2d.OpenglConstants"
-- audio
require "src.cocos.cocosdenshion.AudioEngine"
-- cocosstudio
if nil ~= ccs then
    require "src.cocos.cocostudio.CocoStudio"
end
-- ui
if nil ~= ccui then
    require "src.cocos.ui.GuiConstants"
    require "src.cocos.ui.experimentalUIConstants"
end

-- extensions
require "src.cocos.extension.ExtensionConstants"
-- network
require "src.cocos.network.NetworkConstants"
-- Spine
if nil ~= sp then
    require "src.cocos.spine.SpineConstants"
end

require "src.cocos.cocos2d.DrawPrimitives"

-- Lua extensions
require "cocos.cocos2d.bitExtend"

-- cocosbuilder
require "src.cocos.cocosbuilder.CCBReaderLoad"

-- physics3d
require "src.cocos.physics3d.physics3d-constants"

if CC_USE_FRAMEWORK then
    require "src.cocos.framework.init"
end
