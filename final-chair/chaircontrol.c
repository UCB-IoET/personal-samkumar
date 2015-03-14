#include "chaircontrol.h"

uint32_t heaters[] = {STORM_GP12, STORM_PWM0};

volatile uint32_t* const gpio_enable_set = (volatile uint32_t* const) (GPIO_BASE + GPIO_ENABLE_SET);
volatile uint32_t* const gpio_enable_clear = (volatile uint32_t* const) (GPIO_BASE + GPIO_ENABLE_CLEAR);
volatile uint32_t* const gpio_output_enable_set = (volatile uint32_t* const) (GPIO_BASE + GPIO_OUTPUT_ENABLE_SET);
volatile uint32_t* const gpio_output_enable_clear = (volatile uint32_t* const) (GPIO_BASE + GPIO_OUTPUT_ENABLE_CLEAR);
volatile uint32_t* const gpio_output_set = (volatile uint32_t* const) (GPIO_BASE + GPIO_OUTPUT_SET);
volatile uint32_t* const gpio_output_clear = (volatile uint32_t* const) (GPIO_BASE + GPIO_OUTPUT_CLEAR);
volatile uint32_t* const gpio_output_toggle = (volatile uint32_t* const) (GPIO_BASE + GPIO_OUTPUT_TOGGLE);

/* storm.n.set_heater_mode(heater, mode)
   heater is in {storm.n.BOTTOM_HEATER, storm.n.BACK_HEATER}
   mode is in {storm.n.ENABLE, storm.n.DISABLE} */
int set_heater_mode(lua_State* L) {
    uint32_t heater_pin = heaters[luaL_checkint(L, 1)];
    int mode = luaL_checkint(L, 2);

    switch(mode) {
    case DISABLE:
	*gpio_output_enable_clear = heater_pin;
	*gpio_enable_clear= heater_pin;
	break;
    case ENABLE:
	*gpio_enable_set = heater_pin;
	*gpio_output_enable_set = heater_pin;
	break;
    }

    return 0;
}

/* storm.n.set_heater_mode(heater, state)
   heater is in {storm.n.BOTTOM_HEATER, storm.n.BACK_HEATER}
   state is in {storm.n.ON, storm.n.OFF, storm.n.TOGGLE}
   Heater must be enabled first. */
int set_heater_state(lua_State* L) {
    uint32_t heater_pin = heaters[luaL_checkint(L, 1)];
    int state = luaL_checkint(L, 2);

    switch(state) {
    case OFF:
	*gpio_output_clear = heater_pin;
	break;
    case ON:
	*gpio_output_set = heater_pin;
	break;
    case TOGGLE:
	*gpio_output_toggle = heater_pin;
	break;
    }

    return 0;
}
