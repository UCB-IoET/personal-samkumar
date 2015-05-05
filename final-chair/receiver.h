int actuation_handler(lua_State* L);

#define RECEIVER_SYMBOLS \
    { LSTRKEY( "actuation_handler" ), LFUNCVAL( actuation_handler ) },
