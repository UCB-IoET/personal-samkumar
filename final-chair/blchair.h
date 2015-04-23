int bl_PECS_write(lua_State* L);
int bl_PECS_setname(lua_State* L);
int bl_PECS_send(lua_State* L);
int bl_PECS_receive(lua_State* L);

#define BLCHAIR_SYMBOLS \
    { LSTRKEY( "bl_PECS_init" ), LFUNCVAL( bl_PECS_init) }, \
    { LSTRKEY( "bl_PECS_setname" ), LFUNCVAL( bl_PECS_setname ) }, \
    { LSTRKEY( "bl_PECS_send" ), LFUNCVAL( bl_PECS_send) }, \
    { LSTRKEY( "bl_PECS_receive" ), LFUNCVAL( bl_PECS_receive) },
