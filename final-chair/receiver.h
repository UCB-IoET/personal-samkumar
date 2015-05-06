int actuation_handler(lua_State* L);

#define RECEIVER_SYMBOLS \
    { LSTRKEY( "actuation_handler" ), LFUNCVAL( actuation_handler ) }, \
    { LSTRKEY( "bl_handler" ), LFUNCVAL( bl_handler ) }, \
    { LSTRKEY( "to_hex_str" ), LFUNCVAL( to_hex_str ) },
