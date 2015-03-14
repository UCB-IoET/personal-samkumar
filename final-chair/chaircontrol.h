#define GPIO_BASE 0x400E1000
#define GPIO_ENABLE_SET 0x004
#define GPIO_ENABLE_CLEAR 0x008
#define GPIO_OUTPUT_ENABLE_SET 0x044
#define GPIO_OUTPUT_ENABLE_CLEAR 0x048
#define GPIO_OUTPUT_SET 0x054
#define GPIO_OUTPUT_CLEAR 0x058
#define GPIO_OUTPUT_TOGGLE 0x05C

#define STORM_GP12 0x00001000 // PA12 on microcontroller
#define STORM_PWM0 0x00000100 // PA08 on microcontroller

#define BOTTOM_HEATER 0 // storm.n.BOTTOM_HEATER
#define BACK_HEATER 1 // storm.n.BACK_HEATER

#define DISABLE 0
#define ENABLE 1

#define OFF 0
#define ON 1
#define TOGGLE 2

int set_heater_mode(lua_State* L);
int set_heater_state(lua_State* L);

#define CHAIRCONTROL_SYMBOLS \
    { LSTRKEY( "BOTTOM_HEATER" ), LNUMVAL( BOTTOM_HEATER ) }, \
    { LSTRKEY( "BACK_HEATER" ), LNUMVAL( BACK_HEATER ) }, \
    { LSTRKEY( "DISABLE" ), LNUMVAL( DISABLE ) }, \
    { LSTRKEY( "ENABLE" ), LNUMVAL( ENABLE ) }, \
    { LSTRKEY( "OFF" ), LNUMVAL( OFF ) }, \
    { LSTRKEY( "ON" ), LNUMVAL( ON ) }, \
    { LSTRKEY( "TOGGLE" ), LNUMVAL( TOGGLE ) }, \
    { LSTRKEY( "set_heater_mode" ), LFUNCVAL( set_heater_mode ) }, \
    { LSTRKEY( "set_heater_state" ), LFUNCVAL( set_heater_state ) },
