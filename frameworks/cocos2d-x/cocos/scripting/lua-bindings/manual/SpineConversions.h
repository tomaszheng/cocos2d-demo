#pragma once

extern "C" {
#include "lua.h"
#include "tolua++.h"
}
#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/Lua-BindingsExport.h"
#include "editor-support/spine/Color.h"
#include "editor-support/spine/SpineString.h"
#include "editor-support/spine/Vector.h"

extern bool luaval_to_size_t(lua_State* L, int lo, size_t* outValue, const char* funcName = "");

extern bool luaval_to_spine_color(lua_State* L, int lo, spine::Color* outValue, const char* funcName);

extern bool luaval_to_spine_string(lua_State* L, int lo, spine::String* outValue, const char* funcName);

extern void spine_color_to_luaval(lua_State* L, const spine::Color& cc);

extern void spine_vector_int_to_luaval(lua_State* L, spine::Vector<int>& inValue);

extern void spine_vector_uint_to_luaval(lua_State* L, spine::Vector<unsigned int>& inValue);

extern void spine_vector_short_to_luaval(lua_State* L, spine::Vector<short>& inValue);

extern void spine_vector_ushort_to_luaval(lua_State* L, spine::Vector<unsigned short>& inValue);

extern void spine_vector_float_to_luaval(lua_State* L, spine::Vector<float>& inValue);

extern void spine_vector_spine_string_to_luaval(lua_State* L, spine::Vector<spine::String>& inValue);

template <class T>
void spine_vector_to_luaval(lua_State* L, const spine::Vector<T>& inValue)
{
    lua_newtable(L);

    if (nullptr == L)
        return;

    int indexTable = 1;
    spine::Vector<T> tmpv = inValue;
    for (size_t i = 0, count = (size_t)tmpv.size(); i < count; i++)
    {
        std::string typeName = typeid(tmpv[i]).name();
        auto iter = g_luaType.find(typeName);
        if (g_luaType.end() != iter)
        {
            lua_pushnumber(L, (lua_Number)indexTable);
            tolua_pushusertype(L, (void*)tmpv[i], iter->second.c_str());
            lua_rawset(L, -3);
            ++indexTable;
        }
    }
}

template <class T>
void spine_vector_ptr_to_luaval(lua_State* L, const spine::Vector<T*>& inValue)
{
    lua_newtable(L);

    if (nullptr == L)
        return;

    int indexTable = 1;
    spine::Vector<T*> tmpv = inValue;
    for (size_t i = 0, count = (size_t)tmpv.size(); i < count; i++)
    {
        std::string typeName = typeid(*tmpv[i]).name();
        auto iter = g_luaType.find(typeName);
        if (g_luaType.end() != iter)
        {
            lua_pushnumber(L, (lua_Number)indexTable);
            tolua_pushusertype(L, (void*)tmpv[i], iter->second.c_str());
            lua_rawset(L, -3);
            ++indexTable;
        }
    }
}