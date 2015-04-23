#include "i2cchair.h"

// Based largely on code from Wikipedia

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
int i2c_write_byte(int send_start, int send_stop, uint8_t byte) {
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

// Wrapper functions for Lua

int lua_i2c_read_byte(lua_State* L) {
    int nack = luaL_checkint(L, 1);
    int send_stop = luaL_checkint(L, 2);
    int result = (int) i2c_read_byte(nack, send_stop);
    lua_pushnumber(L, result);
    return 1;
}

int lua_i2c_write_byte(lua_State* L) {
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

