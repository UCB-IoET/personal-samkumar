int read_chair_byte(lua_State* L);
int write_chair_byte(lua_State* L);

#define PB_OFFSET 0x200 // GPIO Port 1

#define SCL 0x00000001
#define SCL_BIT 0
#define SDA 0x00000002
#define SDA_BIT 1

#define FAN_CONTROLLER_ADDR 0x40
#define FAN_CONTROLLER_IODIR_ADDR 0x00
#define FAN_CONTROLLER_GPIO_ADDR 0x09

#define LOW 1
#define MEDIUM 2
#define HIGH 3
#define MAX 4

#define I2CCHAIR_SYMBOLS \
    { LSTRKEY( "LOW" ), LNUMVAL( LOW ) }, \
    { LSTRKEY( "MEDIUM" ), LNUMVAL( MEDIUM ) }, \
    { LSTRKEY( "HIGH" ), LNUMVAL( HIGH ) }, \
    { LSTRKEY( "MAX" ), LNUMVAL( MAX ) }, \
    { LSTRKEY( "enable_fans" ), LFUNCVAL( enable_fans ) }, \
    { LSTRKEY( "disable_fans" ), LFUNCVAL( disable_fans ) }, \
    { LSTRKEY( "read_chair_byte" ), LFUNCVAL( read_chair_byte ) }, \
    { LSTRKEY( "write_chair_byte" ), LFUNCVAL( write_chair_byte ) }, \
    { LSTRKEY( "set_fan_state" ), LFUNCVAL( set_fan_state ) }, \
    { LSTRKEY( "read_SDA" ), LFUNCVAL( lua_read_SDA ) }, \
    { LSTRKEY( "read_SCL" ), LFUNCVAL( lua_read_SCL ) }, \
    { LSTRKEY( "read_pins" ), LFUNCVAL( lua_read_pins ) }, \
    { LSTRKEY( "set_SDA" ), LFUNCVAL( lua_set_SDA ) }, \
    { LSTRKEY( "set_SCL" ), LFUNCVAL( lua_set_SCL ) }, \
    { LSTRKEY( "write_register" ), LFUNCVAL( lua_write_register ) }, \
    { LSTRKEY( "read_register" ), LFUNCVAL( lua_read_register ) },
