#include <interface.h>
#include "blchair.h"

volatile int32_t bl_receive_flag;
char bl_receive_buffer[20];

// Inspired by syscall types in libstorm.c
int32_t __attribute__((naked)) k_syscall_ex_ri32(uint32_t id) {
    __syscall_body(ABI_ID_SYSCALL_EX);
}
int32_t __attribute__((naked)) k_syscall_ex_ri32_ccptr_u32(uint32_t id, const char* string, uint32_t len) {
    __syscall_body(ABI_ID_SYSCALL_EX);
}
int32_t __attribute__((naked)) k_syscall_ex_ri32_cptr_u32_vi32ptr(uint32_t id, char* buffer, uint32_t len, volatile int32_t* flag) {
    __syscall_body(ABI_ID_SYSCALL_EX);
}

// Define syscalls for using the PECS Bluetooth
#define bl_PECS_init_syscall() k_syscall_ex_ri32(0x800)
#define bl_PECS_send_syscall(data, len) k_syscall_ex_ri32_ccptr_u32(0x802, (data), (len))
#define bl_PECS_receive_syscall(buffer, len, flag) k_syscall_ex_ri32_cptr_u32_vi32ptr(0x803, (buffer), (len), (flag))
#define bl_PECS_clearbuf_syscall() k_syscall_ex_ri32(0x804)

void print_byte(uint8_t byte) {
    printf("%d\n", byte);
}

int bl_PECS_init(lua_State* L) {
    int32_t result = bl_PECS_init_syscall();
    lua_pushnumber(L, result);
    return 1;
}

int bl_PECS_send(lua_State* L) {
    size_t length;
    const char* data = luaL_checklstring(L, 1, &length);
    lua_pushnumber(L, length);
    bl_PECS_send_syscall(data, (int) length);
    return 1;
}

int bl_PECS_receive_tail(lua_State* L);
int bl_PECS_receive(lua_State* L) {
    int toRead = luaL_checkint(L, 1);
    if (toRead > 20) {
        return 0;
    }
    bl_receive_flag = 0;
    bl_PECS_receive_syscall(bl_receive_buffer, toRead, &bl_receive_flag);
    cord_set_continuation(L, bl_PECS_receive_tail, 0);
    return nc_invoke_sleep(L, 250 * MILLISECOND_TICKS);
}

int bl_PECS_receive_tail(lua_State* L) {
    if (bl_receive_flag) {
        lua_pushlstring(L, bl_receive_buffer, bl_receive_flag);
        return cord_return(L, 1);
    } else {
        cord_set_continuation(L, bl_PECS_receive_tail, 0);
        return nc_invoke_sleep(L, 250 * MILLISECOND_TICKS);
    }
}

int bl_PECS_clear_recv_buf(lua_State* L) {
    bl_PECS_clearbuf_syscall();
    return 0;
}

int interpret_string(lua_State* L) {
    size_t length;
    int i;
    const char* string = luaL_checklstring(L, 1, &length);
    for (i = 0; i < length; i++) {
        lua_pushnumber(L, string[i]);
    }
    return (int) length;
}

char strbuf[5];
int pack_string_5(lua_State* L) {
    strbuf[0] = luaL_checkint(L, 1);
    strbuf[1] = luaL_checkint(L, 2);
    strbuf[2] = luaL_checkint(L, 3);
    strbuf[3] = luaL_checkint(L, 4);
    strbuf[4] = luaL_checkint(L, 5);
    lua_pushlstring(L, strbuf, 5);
    return 1;
}
