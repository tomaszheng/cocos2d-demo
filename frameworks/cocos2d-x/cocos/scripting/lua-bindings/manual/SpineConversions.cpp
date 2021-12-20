
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "scripting/lua-bindings/manual/SpineConversions.h"
#include "scripting/lua-bindings/manual/tolua_fix.h"

bool luaval_to_size_t(lua_State* L, int lo, size_t* outValue, const char* funcName)
{
    return luaval_to_uint32(L, lo, reinterpret_cast<unsigned int*>(outValue), funcName);
}

bool luaval_to_spine_color(lua_State* L, int lo, spine::Color* outValue, const char* funcName)
{
    if (NULL == L || NULL == outValue)
        return false;

    bool ok = true;

    tolua_Error tolua_err;
    if (!tolua_istable(L, lo, 0, &tolua_err))
    {
#if COCOS2D_DEBUG >=1
        luaval_to_native_err(L, "#ferror:", &tolua_err, funcName);
#endif
        ok = false;
    }

    if (ok)
    {
        lua_pushstring(L, "r");
        lua_gettable(L, lo);
        outValue->r = lua_isnil(L, -1) ? 0 : lua_tonumber(L, -1);
        lua_pop(L, 1);

        lua_pushstring(L, "g");
        lua_gettable(L, lo);
        outValue->g = lua_isnil(L, -1) ? 0 : lua_tonumber(L, -1);
        lua_pop(L, 1);

        lua_pushstring(L, "b");
        lua_gettable(L, lo);
        outValue->b = lua_isnil(L, -1) ? 0 : lua_tonumber(L, -1);
        lua_pop(L, 1);

        lua_pushstring(L, "a");
        lua_gettable(L, lo);
        outValue->b = lua_isnil(L, -1) ? 0 : lua_tonumber(L, -1);
        lua_pop(L, 1);
    }

    return ok;
}

bool luaval_to_spine_string(lua_State* L, int lo, spine::String* outValue, const char* funcName)
{
    if (NULL == L || NULL == outValue)
        return false;

    bool ok = true;

    tolua_Error tolua_err;
    if (!tolua_iscppstring(L, lo, 0, &tolua_err))
    {
#if COCOS2D_DEBUG >=1
        luaval_to_native_err(L, "#ferror:", &tolua_err, funcName);
#endif
        ok = false;
    }

    if (ok)
    {
        size_t size;
        auto rawString = lua_tolstring(L, lo, &size);
        *outValue = spine::String(rawString);
    }

    return ok;
}

void spine_color_to_luaval(lua_State* L, const spine::Color& cc)
{
    if (NULL == L)
        return;
    lua_newtable(L);                                    /* L: table */
    lua_pushstring(L, "r");                             /* L: table key */
    lua_pushnumber(L, (lua_Number)cc.r);               /* L: table key value*/
    lua_rawset(L, -3);                                  /* table[key] = value, L: table */
    lua_pushstring(L, "g");                             /* L: table key */
    lua_pushnumber(L, (lua_Number)cc.g);               /* L: table key value*/
    lua_rawset(L, -3);                                  /* table[key] = value, L: table */
    lua_pushstring(L, "b");                             /* L: table key */
    lua_pushnumber(L, (lua_Number)cc.b);               /* L: table key value*/
    lua_rawset(L, -3);                                  /* table[key] = value, L: table */
    lua_pushstring(L, "a");                             /* L: table key */
    lua_pushnumber(L, (lua_Number)cc.b);               /* L: table key value*/
    lua_rawset(L, -3);                                  /* table[key] = value, L: table */
}

void spine_vector_int_to_luaval(lua_State* L, spine::Vector<int>& inValue)
{
    if (nullptr == L)
        return;

    lua_newtable(L);

    spine::Vector<int> tmpv = inValue;
    for (size_t i = 0, count = (size_t)tmpv.size(); i < count; i++)
    {
        lua_pushnumber(L, (lua_Number)(i + 1));
        lua_pushnumber(L, (lua_Number)tmpv[i]);
        lua_rawset(L, -3);
    }
}

void spine_vector_uint_to_luaval(lua_State* L, spine::Vector<unsigned int>& inValue)
{
    if (nullptr == L)
        return;

    lua_newtable(L);

    spine::Vector<unsigned int> tmpv = inValue;
    for (size_t i = 0, count = (size_t)tmpv.size(); i < count; i++)
    {
        lua_pushnumber(L, (lua_Number)(i + 1));
        lua_pushnumber(L, (lua_Number)tmpv[i]);
        lua_rawset(L, -3);
    }
}

void spine_vector_short_to_luaval(lua_State* L, spine::Vector<short>& inValue)
{
    if (nullptr == L)
        return;

    lua_newtable(L);

    spine::Vector<short> tmpv = inValue;
    for (size_t i = 0, count = (size_t)tmpv.size(); i < count; i++)
    {
        lua_pushnumber(L, (lua_Number)(i + 1));
        lua_pushnumber(L, (lua_Number)tmpv[i]);
        lua_rawset(L, -3);
    }
}

void spine_vector_ushort_to_luaval(lua_State* L, spine::Vector<unsigned short>& inValue)
{
    if (nullptr == L)
        return;

    lua_newtable(L);

    spine::Vector<unsigned short> tmpv = inValue;
    for (size_t i = 0, count = (size_t)tmpv.size(); i < count; i++)
    {
        lua_pushnumber(L, (lua_Number)(i + 1));
        lua_pushnumber(L, (lua_Number)tmpv[i]);
        lua_rawset(L, -3);
    }
}

void spine_vector_float_to_luaval(lua_State* L, spine::Vector<float>& inValue)
{
    if (nullptr == L)
        return;

    lua_newtable(L);

    spine::Vector<float> tmpv = inValue;
    for (size_t i = 0, count = (size_t)tmpv.size(); i < count; i++)
    {
        lua_pushnumber(L, (lua_Number)(i + 1));
        lua_pushnumber(L, (lua_Number)tmpv[i]);
        lua_rawset(L, -3);
    }
}

void spine_vector_spine_string_to_luaval(lua_State* L, spine::Vector<spine::String>& inValue)
{
    if (nullptr == L)
        return;

    lua_newtable(L);

    spine::Vector<spine::String> tmpv = inValue;
    for (size_t i = 0, count = (size_t)tmpv.size(); i < count; i++)
    {
        lua_pushnumber(L, (lua_Number)(i + 1));
        lua_pushstring(L, tmpv[i].buffer());
        lua_rawset(L, -3);
    }
}