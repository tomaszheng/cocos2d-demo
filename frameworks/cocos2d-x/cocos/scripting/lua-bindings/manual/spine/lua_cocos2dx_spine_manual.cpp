/****************************************************************************
 Copyright (c) 2013-2016 Chukong Technologies Inc.
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
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
 ****************************************************************************/
#include "scripting/lua-bindings/manual/spine/lua_cocos2dx_spine_manual.hpp"
#include "scripting/lua-bindings/auto/lua_cocos2dx_spine_auto.hpp"

#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "scripting/lua-bindings/manual/cocos2d/LuaScriptHandlerMgr.h"
#include "scripting/lua-bindings/manual/CCLuaValue.h"
#include "editor-support/spine/spine.h"
#include "editor-support/spine/spine-cocos2dx.h"
#include "scripting/lua-bindings/manual/spine/LuaSkeletonAnimation.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "scripting/lua-bindings/manual/SpineConversions.h"

using namespace spine;

int executeSpineEvent(LuaSkeletonAnimation* skeletonAnimation, int handler, EventType eventType, TrackEntry* entry, spine::Event* event = nullptr )
{
    if (nullptr == skeletonAnimation || 0 == handler)
        return 0;
    
    LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
    if (nullptr == stack)
        return 0;
    
    lua_State* L = LuaEngine::getInstance()->getLuaStack()->getLuaState();
    if (nullptr == L)
        return 0;
    
    int ret = 0;
    
    std::string animationName = (entry && entry->getAnimation()) ? entry->getAnimation()->getName().buffer() : "";
    std::string eventTypeName = "";
    
    switch (eventType) {
        case EventType::EventType_Start:
            {
                eventTypeName = "start";
            }
            break;
        case EventType::EventType_Interrupt:
            {
                eventTypeName = "interrupt";
            }
                break;
        case EventType::EventType_End:
            {
                eventTypeName = "end";
            }
            break;
        case EventType::EventType_Dispose:
            {
                eventTypeName = "dispose";
            }
            break;
        case EventType::EventType_Complete:
            {
                eventTypeName = "complete";
            }
            break;
        case EventType::EventType_Event:
            {
                eventTypeName = "event";
            }
            break;
            
        default:
            break;
    }
    
    LuaValueDict spineEvent;
    spineEvent.insert(spineEvent.end(), LuaValueDict::value_type("type", LuaValue::stringValue(eventTypeName)));
    spineEvent.insert(spineEvent.end(), LuaValueDict::value_type("trackIndex", LuaValue::intValue(entry->getTrackIndex())));
    spineEvent.insert(spineEvent.end(), LuaValueDict::value_type("animation", LuaValue::stringValue(animationName)));
    spineEvent.insert(spineEvent.end(), LuaValueDict::value_type("loopCount", LuaValue::intValue(std::floor(entry->getTrackTime() / entry->getAnimationEnd()))));
    
    if (nullptr != event)
    {
        LuaValueDict eventData;
        eventData.insert(eventData.end(), LuaValueDict::value_type("name", LuaValue::stringValue(event->getData().getName().buffer())));
        eventData.insert(eventData.end(), LuaValueDict::value_type("intValue", LuaValue::intValue(event->getIntValue())));
        eventData.insert(eventData.end(), LuaValueDict::value_type("floatValue", LuaValue::floatValue(event->getFloatValue())));
        eventData.insert(eventData.end(), LuaValueDict::value_type("stringValue", LuaValue::stringValue(event->getStringValue().buffer())));
        spineEvent.insert(spineEvent.end(), LuaValueDict::value_type("eventData", LuaValue::dictValue(eventData)));
    }
    
    stack->pushLuaValueDict(spineEvent);
    ret = stack->executeFunctionByHandler(handler, 1);
    return ret;
}

static int handleSpineUpdateEvent(int handler, spine::SkeletonAnimation* skeletonAnimation)
{
    LuaStack* stack = LuaEngine::getInstance()->getLuaStack();

    stack->pushObject(skeletonAnimation, "sp.SkeletonAnimation");

    stack->executeFunctionByHandler(handler, 1);
    stack->clean();

    return 0;
}

int tolua_Cocos2d_CCSkeletonAnimation_registerSpineEventHandler00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isusertype(tolua_S,1,"sp.SkeletonAnimation",0,&tolua_err) ||
        !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err) ||
        !tolua_isnumber(tolua_S, 3, 0, &tolua_err)                  ||
        !tolua_isnoobj(tolua_S,4,&tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
    	LuaSkeletonAnimation* self    = (LuaSkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
        if (NULL != self ) {
            int handler = (  toluafix_ref_function(tolua_S,2,0));
            EventType eventType = static_cast<EventType>((int)tolua_tonumber(tolua_S, 3, 0));
            
            switch (eventType) {
                case EventType::EventType_Start:
                    {
                        self->setStartListener([=](TrackEntry* entry){
                            executeSpineEvent(self, handler, eventType, entry);
                        });
                        ScriptHandlerMgr::getInstance()->addObjectHandler((void*)self, handler, ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_START);
                    }
                    break;
                case EventType::EventType_Interrupt:
                    {
                        self->setInterruptListener([=](TrackEntry* entry){
                            executeSpineEvent(self, handler, eventType, entry);
                        });
                        ScriptHandlerMgr::getInstance()->addObjectHandler((void*)self, handler, ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_INTERRUPT);
                    }
                    break;
                case EventType::EventType_End:
                    {
                        self->setEndListener([=](TrackEntry* entry){
                            executeSpineEvent(self, handler, eventType, entry);
                        });
                        ScriptHandlerMgr::getInstance()->addObjectHandler((void*)self, handler, ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_END);
                    }
                    break;
                case EventType::EventType_Dispose:
                {
                    self->setDisposeListener([=](TrackEntry* entry){
                        executeSpineEvent(self, handler, eventType, entry);
                    });
                    ScriptHandlerMgr::getInstance()->addObjectHandler((void*)self, handler, ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_DISPOSE);
                }
                    break;
                case EventType::EventType_Complete:
                    {
                        self->setCompleteListener([=](TrackEntry* entry){
                            executeSpineEvent(self, handler, eventType, entry);
                        });
                        ScriptHandlerMgr::getInstance()->addObjectHandler((void*)self, handler, ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_COMPLETE);
                    }
                    break;
                case EventType::EventType_Event:
                    {
                        self->setEventListener([=](TrackEntry* entry, spine::Event* event){
                            executeSpineEvent(self, handler, eventType, entry, event);
                        });
                        ScriptHandlerMgr::getInstance()->addObjectHandler((void*)self, handler, ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_EVENT);
                    }
                    break;
                case EventType::EventType_PreUpdate: {
                    self->setPreUpdateWorldTransformsListener([=](SkeletonAnimation* skeletonAnimation) {
                        handleSpineUpdateEvent(handler, skeletonAnimation);
                    });
                    ScriptHandlerMgr::getInstance()->addObjectHandler((void*)self, handler, ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_PRE_UPDATE);
                    break;
                }
                case EventType::EventType_PostUpdate: {
                    self->setPostUpdateWorldTransformsListener([=](SkeletonAnimation* skeletonAnimation) {
                        handleSpineUpdateEvent(handler, skeletonAnimation);
                    });
                    ScriptHandlerMgr::getInstance()->addObjectHandler((void*)self, handler, ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_POST_UPDATE);
                    break;
                }
                default:
                    break;
            }
        }
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'registerSpineEventHandler'.",&tolua_err);
    return 0;
#endif
}

int tolua_Cocos2d_CCSkeletonAnimation_unregisterSpineEventHandler00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isusertype(tolua_S,1,"sp.SkeletonAnimation",0,&tolua_err) ||
        !tolua_isnumber(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isnoobj(tolua_S,3,&tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
    	LuaSkeletonAnimation* self    = (LuaSkeletonAnimation*)  tolua_tousertype(tolua_S,1,0);
        if (NULL != self ) {
            EventType eventType = static_cast<EventType>((int)tolua_tonumber(tolua_S, 2, 0));
            ScriptHandlerMgr::HandlerType handlerType = ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_START;
            switch (eventType) {
                case EventType::EventType_Start:
                    handlerType = ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_START;
                    break;
                case EventType::EventType_Interrupt:
                    handlerType = ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_INTERRUPT;
                    break;
                case EventType::EventType_End:
                    handlerType = ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_END;
                    break;
                case EventType::EventType_Dispose:
                    handlerType = ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_DISPOSE;
                    break;
                case EventType::EventType_Complete:
                    handlerType = ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_COMPLETE;
                    break;
                case EventType::EventType_Event:
                    handlerType = ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_EVENT;
                    break;
                case EventType::EventType_PreUpdate:
                    handlerType = ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_PRE_UPDATE;
                    break;
                case EventType::EventType_PostUpdate:
                    handlerType = ScriptHandlerMgr::HandlerType::EVENT_SPINE_ANIMATION_POST_UPDATE;
                    break;

                default:
                    break;
            }
            ScriptHandlerMgr::getInstance()->removeObjectHandler((void*)self, handlerType);
        }
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'unregisterScriptHandler'.",&tolua_err);
    return 0;
#endif
}

int lua_cocos2dx_spine_SkeletonAnimation_createWithFile(lua_State* tolua_S)
{
    int argc = 0;
    bool ok = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S, 1, "sp.SkeletonAnimation", 0, &tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    do
    {
        if (argc == 2)
        {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2, &arg0, "sp.SkeletonAnimation:createWithFile");
            if (!ok) { break; }
            std::string arg1;
            ok &= luaval_to_std_string(tolua_S, 3, &arg1, "sp.SkeletonAnimation:createWithFile");
            if (!ok) { break; }
            LuaSkeletonAnimation* ret = LuaSkeletonAnimation::createWithFile(arg0, arg1);
            object_to_luaval<LuaSkeletonAnimation>(tolua_S, "sp.SkeletonAnimation", (LuaSkeletonAnimation*)ret);
            return 1;
        }
    } while (0);
    ok = true;
    do
    {
        if (argc == 3)
        {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2, &arg0, "sp.SkeletonAnimation:createWithFile");
            if (!ok) { break; }
            std::string arg1;
            ok &= luaval_to_std_string(tolua_S, 3, &arg1, "sp.SkeletonAnimation:createWithFile");
            if (!ok) { break; }
            double arg2;
            ok &= luaval_to_number(tolua_S, 4, &arg2, "sp.SkeletonAnimation:createWithFile");
            if (!ok) { break; }
            LuaSkeletonAnimation* ret = LuaSkeletonAnimation::createWithFile(arg0, arg1, arg2);
            object_to_luaval<LuaSkeletonAnimation>(tolua_S, "sp.SkeletonAnimation", (LuaSkeletonAnimation*)ret);
            return 1;
        }
    } while (0);
    ok = true;
    do
    {
        if (argc == 2)
        {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2, &arg0, "sp.SkeletonAnimation:createWithFile");
            if (!ok) { break; }
            spine::Atlas* arg1;
            ok &= luaval_to_object<spine::Atlas>(tolua_S, 3, "sp.Atlas", &arg1, "sp.SkeletonAnimation:createWithFile");
            if (!ok) { break; }
            LuaSkeletonAnimation* ret = LuaSkeletonAnimation::createWithFile(arg0, arg1);
            object_to_luaval<LuaSkeletonAnimation>(tolua_S, "sp.SkeletonAnimation", (LuaSkeletonAnimation*)ret);
            return 1;
        }
    } while (0);
    ok = true;
    do
    {
        if (argc == 3)
        {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2, &arg0, "sp.SkeletonAnimation:createWithFile");
            if (!ok) { break; }
            spine::Atlas* arg1;
            ok &= luaval_to_object<spine::Atlas>(tolua_S, 3, "sp.Atlas", &arg1, "sp.SkeletonAnimation:createWithFile");
            if (!ok) { break; }
            double arg2;
            ok &= luaval_to_number(tolua_S, 4, &arg2, "sp.SkeletonAnimation:createWithFile");
            if (!ok) { break; }
            LuaSkeletonAnimation* ret = LuaSkeletonAnimation::createWithFile(arg0, arg1, arg2);
            object_to_luaval<LuaSkeletonAnimation>(tolua_S, "sp.SkeletonAnimation", (LuaSkeletonAnimation*)ret);
            return 1;
        }
    } while (0);
    ok = true;
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d", "sp.SkeletonAnimation:createWithFile", argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
                tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_spine_SkeletonAnimation_createWithFile'.", &tolua_err);
#endif
                return 0;
}

static void extendCCSkeletonAnimation(lua_State* L)
{
    lua_pushstring(L, "sp.SkeletonAnimation");
    lua_rawget(L, LUA_REGISTRYINDEX);
    if (lua_istable(L,-1))
    {
        tolua_function(L, "create", lua_cocos2dx_spine_SkeletonAnimation_createWithFile);
        tolua_function(L, "registerSpineEventHandler", tolua_Cocos2d_CCSkeletonAnimation_registerSpineEventHandler00);
        tolua_function(L, "unregisterSpineEventHandler", tolua_Cocos2d_CCSkeletonAnimation_unregisterSpineEventHandler00);
    }
    lua_pop(L, 1);
    
    /*Because sp.SkeletonAnimation:create create a LuaSkeletonAnimation object,so we need use LuaSkeletonAnimation typename for g_luaType*/
    const auto* typeName = typeid(LuaSkeletonAnimation).name();
    g_luaType[typeName] = "sp.SkeletonAnimation";
    g_typeCast["SkeletonAnimation"] = "sp.SkeletonAnimation";
}

static int tolua_cocos2dx_spine_Skin_findNamesForSlot(lua_State* tolua_S)
{
    int argc = 0;
    spine::Skin* cobj = nullptr;
    bool ok = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S, 1, "sp.Skin", 0, &tolua_err)) goto tolua_lerror;
#endif

    cobj = (spine::Skin*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S, "invalid 'cobj' in function 'tolua_cocos2dx_spine_Skin_findNamesForSlot'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S) - 1;
    if (argc == 1)
    {
        int slotIndex;
        ok &= luaval_to_int32(tolua_S, 2, (int *)&slotIndex, "sp.Skin:findNamesForSlot");

        if (!ok)
        {
            tolua_error(tolua_S, "invalid arguments in function 'tolua_cocos2dx_spine_Skin_findNamesForSlot'", nullptr);
            return 0;
        }
        spine::Vector<spine::String> ret;
        cobj->findNamesForSlot(slotIndex, ret);
        spine_vector_spine_string_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sp.Skin:findNamesForSlot", argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
                tolua_error(tolua_S, "#ferror in function 'tolua_cocos2dx_spine_Skin_findNamesForSlot'.", &tolua_err);
#endif

                return 0;
}

static void extendSpineSkin(lua_State* tolua_S)
{
    lua_pushstring(tolua_S, "sp.Skin");
    lua_rawget(tolua_S, LUA_REGISTRYINDEX);
    if (lua_istable(tolua_S, -1))
    {
        tolua_function(tolua_S, "findNamesForSlot", tolua_cocos2dx_spine_Skin_findNamesForSlot);
    }
    lua_pop(tolua_S, 1);
}

int register_all_cocos2dx_spine_manual(lua_State* L)
{
    if (nullptr == L)
        return 0;

    extendCCSkeletonAnimation(L);
    extendSpineSkin(L);
    
    return 0;
}


int register_spine_module(lua_State* L)
{
    lua_getglobal(L, "_G");
    if (lua_istable(L,-1))//stack:...,_G,
    {
        register_all_cocos2dx_spine(L);
        register_all_cocos2dx_spine_manual(L);
    }
    lua_pop(L, 1);

    return 1;
}
