#include "chaircontrol.h"
#include "i2cchair.h"

volatile uint32_t* const gpio1_enable_set = (volatile uint32_t* const) (GPIO_BASE + PB_OFFSET + GPIO_ENABLE_SET);
volatile uint32_t* const gpio1_enable_clear = (volatile uint32_t* const) (GPIO_BASE + PB_OFFSET + GPIO_ENABLE_CLEAR);
volatile uint32_t* const gpio1_output_enable_set = (volatile uint32_t* const) (GPIO_BASE + PB_OFFSET + GPIO_OUTPUT_ENABLE_SET);
volatile uint32_t* const gpio1_output_enable_clear = (volatile uint32_t* const) (GPIO_BASE + PB_OFFSET + GPIO_OUTPUT_ENABLE_CLEAR);
volatile uint32_t* const gpio1_output_set = (volatile uint32_t* const) (GPIO_BASE + PB_OFFSET + GPIO_OUTPUT_SET);
volatile uint32_t* const gpio1_output_clear = (volatile uint32_t* const) (GPIO_BASE + PB_OFFSET + GPIO_OUTPUT_CLEAR);
volatile uint32_t* const gpio1_output_toggle = (volatile uint32_t* const) (GPIO_BASE + PB_OFFSET + GPIO_OUTPUT_TOGGLE);
volatile uint32_t* const gpio1_schmitt_enable_set = (volatile uint32_t* const) (GPIO_BASE + PB_OFFSET + GPIO_SCHMITT_ENABLE_SET);
volatile uint32_t* const gpio1_schmitt_enable_clear = (volatile uint32_t* const) (GPIO_BASE + PB_OFFSET + GPIO_SCHMITT_ENABLE_CLEAR);
volatile const uint32_t* const gpio1_pin_value = (volatile const uint32_t* const) (GPIO_BASE + PB_OFFSET + GPIO_PIN_VALUE);

// Based on code from Wikipedia

int I2C_delay() {
    volatile int v = 0;
    int i;
    for (i = 0; i < 10000; i++) {
	v = v + 1;
    }
    return v;
}

int read_SCL() {
    *gpio1_output_enable_clear = SCL;
    *gpio1_schmitt_enable_set = SCL;
    return (int) ((SCL & *gpio1_pin_value) >> SCL_BIT);
}

int read_SDA() {
    *gpio1_output_enable_clear = SDA;
    *gpio1_schmitt_enable_set = SDA;
    return (int) ((SDA & *gpio1_pin_value) >> SDA_BIT);
}

void clear_SCL() {
    *gpio1_schmitt_enable_clear = SCL;
    *gpio1_output_enable_set = SCL;
    *gpio1_output_clear = SCL;
}

void clear_SDA() {
    *gpio1_schmitt_enable_clear = SDA;
    *gpio1_output_enable_set = SDA;
    *gpio1_output_clear = SDA;
}

void arbitration_lost() {
    printf("arbitration lost\n");
}

int started = 0; // global data
void i2c_start_cond(void) {
    if (started) { // if started, do a restart cond
	// set SDA to 1
	read_SDA();
	I2C_delay();
	while (read_SCL() == 0) {  // Clock stretching
	    // You should add timeout to this loop
	}
	// Repeated start setup time, minimum 4.7us
	I2C_delay();
    }
    if (read_SDA() == 0) {
        printf("Read SDA returned 0\n");
	arbitration_lost();
	return;
    }
    // SCL is high, set SDA from 1 to 0.
    clear_SDA();
    I2C_delay();
    clear_SCL();
    started = 1;
}

void i2c_stop_cond(void){
    // set SDA to 0
    clear_SDA();
    I2C_delay();
    // Clock stretching
    while (read_SCL() == 0) {
	// add timeout to this loop.
    }
    // Stop bit setup time, minimum 4us
    I2C_delay();
    // SCL is high, set SDA from 0 to 1
    if (read_SDA() == 0) {
	arbitration_lost();
	return;
    }
    I2C_delay();
    started = 0;
}

// Write a bit to I2C bus
void i2c_write_bit(int bit) {
    if (bit) {
	read_SDA();
    } else {
	clear_SDA();
    }
    I2C_delay();
    while (read_SCL() == 0) { // Clock stretching
	// You should add timeout to this loop
    }
    // SCL is high, now data is valid
    // If SDA is high, check that nobody else is driving SDA
    if (bit && read_SDA() == 0) {
	arbitration_lost();
	return;
    }
    I2C_delay();
    clear_SCL();
}

// Read a bit from I2C bus
int i2c_read_bit(void) {
    int bit;
    // Let the slave drive data
    read_SDA();
    I2C_delay();
    while (read_SCL() == 0) { // Clock stretching
	// You should add timeout to this loop
    }
    // SCL is high, now data is valid
    bit = read_SDA();
    I2C_delay();
    clear_SCL();
    return bit;
}

// Write a byte to I2C bus. Return 0 if ack by the slave.
int i2c_write_byte(int send_start,
                    int send_stop,
                    uint8_t byte) {
    unsigned bit;
    int nack;
    if (send_start) {
	i2c_start_cond();
    }
    for (bit = 0; bit < 8; bit++) {
	i2c_write_bit((byte & 0x80) != 0);
	byte <<= 1;
    }
    nack = i2c_read_bit();
    if (send_stop) {
	i2c_stop_cond();
    }
    return nack;
}

// Read a byte from I2C bus
uint8_t i2c_read_byte(int nack, int send_stop) {
    uint8_t byte = 0;
    unsigned bit;
    for (bit = 0; bit < 8; bit++) {
	byte = (byte << 1) | i2c_read_bit();
    }
    i2c_write_bit(nack);
    if (send_stop) {
	i2c_stop_cond();
    }
    return byte;
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
    if (i2c_write_byte(1, 0, FAN_CONTROLLER_ADDR)
	|| i2c_write_byte(0, 0, register_addr)) {
	return -1;
    }
    return (int16_t) i2c_read_byte(1, 1);
}


// Wrapper functions for Lua

void enable_fans(lua_State* L) {
    *gpio1_enable_set = SDA;
    *gpio1_enable_set = SCL;
    write_register(FAN_CONTROLLER_IODIR_ADDR, 0b10001000);
}

void disable_fans(lua_State* L) {
    *gpio1_enable_clear = SDA;
    *gpio1_enable_clear = SCL;
    write_register(FAN_CONTROLLER_IODIR_ADDR, 0b11111111);
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

int read_chair_byte(lua_State* L) {
    int nack = luaL_checkint(L, 1);
    int send_stop = luaL_checkint(L, 2);
    int result = (int) i2c_read_byte(nack, send_stop);
    lua_pushnumber(L, result);
    return 1;
}

int write_chair_byte(lua_State* L) {
    int send_start = luaL_checkint(L, 1);
    int send_stop = luaL_checkint(L, 2);
    uint8_t byte = (uint8_t) luaL_checkint(L, 3);
    int nack = i2c_write_byte(send_start, send_stop, byte);
    lua_pushnumber(L, nack);
    return 1;
}



int lua_read_SDA(lua_State* L) {
    int sda = read_SDA();
    lua_pushnumber(L, sda);
    return 1;
}

int lua_read_SCL(lua_State* L) {
    int scl = read_SCL();
    lua_pushnumber(L, scl);
    return 1;
}

int lua_set_SDA(lua_State* L) {
    *gpio1_output_enable_set = SDA;
    if (luaL_checkint(L, 1)) {
	*gpio1_output_set = SDA;
    } else {
	*gpio1_output_clear = SDA;
    }
    return 1;
}

int lua_set_SCL(lua_State* L) {
    *gpio1_output_enable_set = SCL;
    if (luaL_checkint(L, 1)) {
	*gpio1_output_set = SCL;
    } else {
	*gpio1_output_clear = SCL;
    }
    return 1;
}

int lua_read_pins(lua_State* L) {
    lua_pushnumber(L, *gpio1_pin_value);
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
