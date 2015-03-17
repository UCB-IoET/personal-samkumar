#include "chaircontrol.h"
#include "i2cchair.c"

int check_occupancy(lua_State* L) {
    uint32_t occ_pin = STORM_OCC;
    *gpio0_output_enable_clear = occ_pin;
    *gpio0_schmitt_enable_set = occ_pin;
    lua_pushnumber(L, ((occ_pin & *gpio0_pin_value) >> OCC_BIT));
    return 1;
}

/* storm.n.set_heater_mode(heater, mode)
   heater is in {storm.n.BOTTOM_HEATER, storm.n.BACK_HEATER}
   mode is in {storm.n.ENABLE, storm.n.DISABLE} */
int set_heater_mode(lua_State* L) {
    uint32_t heater_pin = heaters[luaL_checkint(L, 1)];
    int mode = luaL_checkint(L, 2);

    switch(mode) {
    case DISABLE:
	*gpio0_output_enable_clear = heater_pin;
	*gpio0_enable_clear= heater_pin;
	break;
    case ENABLE:
	*gpio0_enable_set = heater_pin;
	*gpio0_output_enable_set = heater_pin;
	break;
    }

    return 0;
}

/* storm.n.set_heater_state(heater, state)
   heater is in {storm.n.BOTTOM_HEATER, storm.n.BACK_HEATER}
   state is in {storm.n.ON, storm.n.OFF, storm.n.TOGGLE}
   Heater must be enabled first. */
int set_heater_state(lua_State* L) {
    uint32_t heater_pin = heaters[luaL_checkint(L, 1)];
    int state = luaL_checkint(L, 2);

    switch(state) {
    case OFF:
	*gpio0_output_clear = heater_pin;
	break;
    case ON:
	*gpio0_output_set = heater_pin;
	break;
    case TOGGLE:
	*gpio0_output_toggle = heater_pin;
	break;
    }
    return 0;
}

/** Writes BYTE to the fan controller at the specifed REGISTER_ADDR. */
int write_register(uint8_t register_addr, uint8_t byte) {
    return i2c_write_byte(1, 0, FAN_CONTROLLER_ADDR)
	|| i2c_write_byte(0, 0, register_addr)
	|| i2c_write_byte(0, 1, byte);
}

/** Reads BYTE from the fan controller at the specified REGISTER_ADDR.
    Returns -1 upon error. */
int16_t read_register(uint8_t register_addr) {
    if (i2c_write_byte(1, 0, FAN_CONTROLLER_ADDR | 0b00000001)
	|| i2c_write_byte(0, 0, register_addr)) {
	return -1;
    }
    return (int16_t) i2c_read_byte(1, 1);
}

/* storm.n.set_fan_mode(mode)
   mode is in {storm.n.ENABLE, storm.n.DISABLE} */
int set_fan_mode(lua_State* L) {
    int result;
    switch(luaL_checkint(L, 1)) {
    case ENABLE:
	*gpio1_enable_set = SDA;
	*gpio1_enable_set = SCL;
	result = write_register(FAN_CONTROLLER_IODIR_ADDR, 0b10001000);
	break;
    case DISABLE:
	*gpio1_enable_clear = SDA;
	*gpio1_enable_clear = SCL;
	result = write_register(FAN_CONTROLLER_IODIR_ADDR, 0b11111111);
	break;
    default:
	return 0;
    }
    lua_pushnumber(L, result);
    return 1;
}

/* storm.n.set_fan_state(state)
   state is in {storm.n.OFF, storm.n.LOW, storm.n.MEDIUM, storm.n.HIGH, storm.n.MAX}
   Fans must be enabled first. */
int set_fan_state(lua_State* L) {
    int state = luaL_checkint(L, 1);
    int result;
    switch(state) {
    case OFF:
	result = write_register(FAN_CONTROLLER_GPIO_ADDR, 0b00000000);
	break;
    case LOW:
	result = write_register(FAN_CONTROLLER_GPIO_ADDR, 0b00100010);
	break;
    case MEDIUM:
	result = write_register(FAN_CONTROLLER_GPIO_ADDR, 0b00010001);
	break;
    case HIGH:
	result = write_register(FAN_CONTROLLER_GPIO_ADDR, 0b00110011);
	break;
    case MAX:
	result = write_register(FAN_CONTROLLER_GPIO_ADDR, 0b01000100);
	break;
    default:
	return 0;
    }
    lua_pushnumber(L, result);
    return 1;
}

int lua_write_register(lua_State* L) {
    int reg = luaL_checkint(L, 1);
    int byte = luaL_checkint(L, 2);
    int ret = write_register((uint8_t) reg, (uint8_t) byte);
    lua_pushnumber(L, ret);
    return 1;
}

int lua_read_register(lua_State* L) {
    int reg = luaL_checkint(L, 1);
    int16_t ret = read_register((uint8_t) reg);
    lua_pushnumber(L, ret);
    return 1;
}
