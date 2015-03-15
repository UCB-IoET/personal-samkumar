int read_chair_byte(lua_State* L);
int write_chair_byte(lua_State* L);

#define I2CCHAIR_SYMBOLS \
    { LSTRKEY( "enable_fans" ), LFUNCVAL( enable_fans ) }, \
    { LSTRKEY( "disable_fans" ), LFUNCVAL( disable_fans ) }, \
    { LSTRKEY( "read_chair_byte" ), LFUNCVAL( read_chair_byte ) }, \
    { LSTRKEY( "write_chair_byte" ), LFUNCVAL( write_chair_byte ) }, \
    { LSTRKEY( "read_SDA" ), LFUNCVAL( lua_read_SDA ) }, \
    { LSTRKEY( "read_SCL" ), LFUNCVAL( lua_read_SCL ) }, \
    { LSTRKEY( "read_pins" ), LFUNCVAL( lua_read_pins ) }, \
    { LSTRKEY( "set_SDA" ), LFUNCVAL( lua_set_SDA ) }, \
    { LSTRKEY( "set_SCL" ), LFUNCVAL( lua_set_SCL ) },
