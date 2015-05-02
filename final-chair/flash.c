#include "libstormarray.h"
#include "flash.h"

// fs: 23bit address, 1 byte boolean clean, and this is one time redundant

#define SP_LEN 6 // 6 byte fs top
#define ERROR 0

#define get_sp_bits(a) (a & (1 << 23))

/* read_sp_index(index, cb)

   Gets the stack pointer value at INDEX, and returns it. */
/*int read_sp_index_async(lua_State* L) {
    int index = luaL_checkint(L, 1);
    lua_pushlightfunction(L, libstorm_flash_read);
    lua_pushnumber(L, index << PAGE_EXP);
    lua_pushvalue(L, 2);
    storm_array_nc_create(L, 1, ARR_TYPE_INT32); // seriously, why isn't there an ARR_TYPE_UINT32?
    lua_call(L, 2, 1);
}

int read_sp_index(lua_State* L) {
    storm_array_nc_create(L, 1, ARR_TYPE_INT32); // seriously, why isn't there an ARR_TYPE_UINT32?
    int arr_index = lua_gettop(L);
    lua_pushvalue(L, arr_index);
    cord_set_continuation(L, read_sp_index_tail, 1);
    lua_getglobal(L, "cord");
    lua_pushstring(L, "await");
    lua_rawget(L, -2);
    lua_remove(L, -2);
    lua_pushlightfunction(L, libstorm_flash_read);
    int index = luaL_checkint(L, 1);
    lua_pushnumber(L, index << PAGE_EXP);
    lua_pushvalue(L, arr_index);
    return cord_invoke_custom(L, 4);
}

int read_sp_index_tail(lua_State* L) {
    lua_pushvalue(L, lua_upvalueindex(1));
    return cord_return(L, 1);
}*/

int flash_write_delay() {
    volatile int i = 0;
    while (i < 10000) {
        i = i + 1;
    }
    return i;
}

int call_fn(lua_State* L) {
    printf("call fn\n");
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_pushvalue(L, lua_upvalueindex(2));
    lua_call(L, 1, 1);
    return 1;
}

int read_sp_2(lua_State* L);
int read_sp_3(lua_State* L);
int read_sp_tail(lua_State* L);
// read_sp(cb)
int read_sp(lua_State* L) {
    storm_array_nc_create(L, 1, ARR_TYPE_INT32);
    int arr_index = lua_gettop(L);
    lua_pushlightfunction(L, libstorm_flash_read);
    lua_pushnumber(L, 0 << PAGE_EXP);
    lua_pushvalue(L, arr_index);
    lua_pushvalue(L, 1); // the callback
    lua_pushvalue(L, arr_index);
    lua_pushcclosure(L, read_sp_2, 2);
    printf("Calling 1\n");
    lua_call(L, 3, 0);
    return 0;
}

int read_sp_2(lua_State* L) {
    storm_array_nc_create(L, 1, ARR_TYPE_INT32);
    int arr_index = lua_gettop(L);
    lua_pushlightfunction(L, libstorm_flash_read);
    lua_pushnumber(L, 1 << PAGE_EXP);
    lua_pushvalue(L, arr_index);
    lua_pushvalue(L, lua_upvalueindex(1)); // the callback
    lua_pushvalue(L, lua_upvalueindex(2));
    lua_pushvalue(L, arr_index);
    lua_pushcclosure(L, read_sp_3, 3);
    printf("Calling 2\n");
    lua_call(L, 3, 0);
    return 0;
}

int read_sp_3(lua_State* L) {
    storm_array_nc_create(L, 1, ARR_TYPE_INT32);
    int arr_index = lua_gettop(L);
    lua_pushlightfunction(L, libstorm_flash_read);
    lua_pushnumber(L, 2 << PAGE_EXP);
    lua_pushvalue(L, arr_index);
    lua_pushvalue(L, lua_upvalueindex(1)); // the callback
    lua_pushvalue(L, lua_upvalueindex(2));
    lua_pushvalue(L, lua_upvalueindex(3));
    lua_pushvalue(L, arr_index);
    lua_pushcclosure(L, read_sp_tail, 4);
    printf("Calling 3\n");
    lua_call(L, 3, 0);
    return 0;
}

int read_sp_tail(lua_State* L) {
    int i;
    for (i = 2; i < 5; i++) {
        lua_pushlightfunction(L, arr_get);
        lua_pushvalue(L, lua_upvalueindex(i));
        lua_pushnumber(L, 1);
        lua_call(L, 2, 1);
    }
    int sp1 = lua_tointeger(L, 1);
    int sp2 = lua_tointeger(L, 2);
    int sp3 = lua_tointeger(L, 3);
    int sp;
    if (sp1 == sp2 && sp2 == sp3) {
        lua_pushvalue(L, lua_upvalueindex(1));
        lua_pushnumber(L, sp1);
        lua_call(L, 1, 0);
    } else {
        printf("Corrupt log pointer: pointers %d %d %d conflict. Repairing...\n", sp1, sp2, sp3);
        if (sp1 == sp2) {
            sp = sp1;
        } else if (sp2 == sp3) {
            sp = sp2;
        } else if (sp1 == sp3) {
            sp = sp3;
        } else {
            sp = sp3;
        }
        lua_pushlightfunction(L, write_sp);
        lua_pushnumber(L, sp);
        lua_pushvalue(L, lua_upvalueindex(1));
        lua_pushnumber(L, sp);
        lua_pushcclosure(L, call_fn, 2);
        lua_call(L, 2, 0);
    }
    return 0;
}

int write_sp_2(lua_State* L);
int write_sp_3(lua_State* L);
int write_sp(lua_State* L) {
    int new_sp = luaL_checkint(L, 1);
    storm_array_nc_create(L, 1, ARR_TYPE_INT32);
    int arr_index = lua_gettop(L);
    lua_pushlightfunction(L, arr_set);
    lua_pushvalue(L, arr_index);
    lua_pushnumber(L, 1);
    lua_pushnumber(L, new_sp);
    lua_call(L, 3, 0);
    lua_pushlightfunction(L, libstorm_flash_write);
    lua_pushnumber(L, 0 << PAGE_EXP);
    lua_pushvalue(L, arr_index);
    lua_pushvalue(L, 2); // callback
    lua_pushvalue(L, arr_index);
    lua_pushcclosure(L, write_sp_2, 2);
    printf("Finished write 1\n");
    lua_call(L, 3, 0);
    return 0;
}

int write_sp_2(lua_State* L) {
    flash_write_delay();
    lua_pushlightfunction(L, libstorm_flash_write);
    lua_pushnumber(L, 1 << PAGE_EXP);
    lua_pushvalue(L, lua_upvalueindex(2));
    lua_pushvalue(L, lua_upvalueindex(1)); // callback
    lua_pushvalue(L, lua_upvalueindex(2));
    lua_pushcclosure(L, write_sp_3, 2);
    printf("Finished write 2\n");
    lua_call(L, 3, 0);
    return 0;
}

int write_sp_3(lua_State* L) {
    flash_write_delay();
    lua_pushlightfunction(L, libstorm_flash_write);
    lua_pushnumber(L, 2 << PAGE_EXP);
    lua_pushvalue(L, lua_upvalueindex(2));
    lua_pushvalue(L, lua_upvalueindex(1)); // callback
    printf("Finished write 3\n");
    lua_call(L, 3, 0);
    return 0;
}

/** FORMAT OF A LOG ENTRY
    Each log entry has the following format:
    1. Timestamp (32 bits)
    2. Back Heater Setting (8 bits)
    3. Bottom Heater Setting (8 bits)
    4. Back Fan Setting (8 bits)
    5. Bottom Fan Setting (8 bits)
    6. Temperature Reading (16 bits)
    7. Relative Humidity Reading (16 bits)
    8. Occupancy (1 bit)
    9. Reboot Indicator (1 bit)
    10. Known Time Indicator (1 bit)
    11. Extra Space (13 bits)
    Total of 112 bits (14 bytes) per entry
**/

// write_log_entry(time_offset, backh, bottomh, backf, 
int write_log_entry(lua_State* L) {
    return 0;
}

/*
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
*/
