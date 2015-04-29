#include "libstormarray.h"

// fs: 23bit address, 1 byte boolean clean, and this is one time redundant

#define SP_LEN 6 // 6 byte fs top
#define ERROR 0

#define get_sp_bits(a) (a & (1 << 23))

uint32_t get_sp(lua_State *L, uint32_t ptr)
{
	lua_pushnumber(L, 0);
	storm_array_nc_create(L, 1, ARR_TYPE_UINT32);
	lua_pushnumber(L, 0);
	lua_pushlightfunction(L, libstorm_flash_read);
	lua_call(L, 3, 0);
	lua_pop(L, 1);
	lua_pushnumber(L, 1);
	lua_pushlightfunction(L, arr_get);
	lua_call(L, 2, 1);
	uint32_t addr = lua_tonumber(L, -1);
	lua_pop(L, 1);
	return addr;
}

uint32_t find_top_of_stack(lua_State *L)
{
	//returns pointer to top of stack
	uint32_t addr = get_sp(0);
	uint32_t valid = (addr >> 23) & 1;
	if (valid) {
		return get_sp_bits(addr);
	} else {
		addr = get_sp(SP_LEN);
		valid = (addr >> 23) & 1;
		if (valid) {
			return get_sp_bits(addr);
		}
	}

	//panic: should not get here!
	//TODO: what to do if neither sp is valid?
	return ERROR;
}

int lua_get_tos(lua_State *L)
{
	lua_pushnumber(L, find_top_of_stack(L));
	return 1;
}

int write_top_of_stack(lua_State *L)
{
	flash_xfer_t *t;
    int rv;
    uint32_t addr = lua_tonumber(L, 1);
    storm_array_t *txarr = lua_touserdata(L, 2);
    t = malloc(sizeof(flash_xfer_t));
    if (!t)
    {
        return luaL_error( L, "out of memory");
    }
    t->cb_ref = luaL_ref(L, LUA_REGISTRYINDEX);
    t->buf_ref = luaL_ref(L, LUA_REGISTRYINDEX);
    rv = flash_write(addr, ARR_START(txarr), txarr->len, flash_xfer_cb, t);
    if (rv != 0)
    {
        free(t);
        return luaL_error( L, "bad flash tx");
    }
    return 0;
}