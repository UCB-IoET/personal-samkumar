#define SCL 0x00000001
#define SCL_BIT 0
#define SDA 0x00000002
#define SDA_BIT 1

int i2c_write_byte(int send_start, int send_stop, uint8_t byte);
uint8_t i2c_read_byte(int nack, int send_stop);

int lua_i2c_read_byte(lua_State* L);
int lua_i2c_write_byte(lua_State* L);
int lua_read_SDA(lua_State* L);
int lua_read_SCL(lua_State* L);
int lua_read_pins(lua_State* L);
int lua_set_SDA(lua_State* L);
int lua_set_SCL(lua_State* L);
int lua_write_register(lua_State* L);
int lua_read_register(lua_State* L);

#define I2CCHAIR_SYMBOLS \
    { LSTRKEY( "i2c_read_byte" ), LFUNCVAL( lua_i2c_read_byte ) }, \
    { LSTRKEY( "i2c_write_byte" ), LFUNCVAL( lua_i2c_write_byte ) }, \
    { LSTRKEY( "read_SDA" ), LFUNCVAL( lua_read_SDA ) }, \
    { LSTRKEY( "read_SCL" ), LFUNCVAL( lua_read_SCL ) }, \
    { LSTRKEY( "read_pins" ), LFUNCVAL( lua_read_pins ) }, \
    { LSTRKEY( "set_SDA" ), LFUNCVAL( lua_set_SDA ) }, \
    { LSTRKEY( "set_SCL" ), LFUNCVAL( lua_set_SCL ) },
