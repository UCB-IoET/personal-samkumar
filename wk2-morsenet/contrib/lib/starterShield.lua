----------------------------------------------
-- Starter Shield Module
--
-- Provides a module for each resource on the starter shield
-- in a cord-based concurrency model
-- and mapping to lower level abstraction provided
-- by storm.io @ toolchains/storm_elua/src/platform/storm/libstorm.c
----------------------------------------------

require("storm") -- libraries for interfacing with the board and kernel
require("cord") -- scheduler / fiber library
----------------------------------------------
-- Shield module for starter shield
----------------------------------------------
local shield = {}

----------------------------------------------
-- LED module
-- provide basic LED functions
----------------------------------------------
local LED = {}

LED.pins = {["blue"]="D2",["green"]="D3",["red"]="D4",["red2"]="D5"}

LED.start = function()
-- configure LED pins for output
   storm.io.set_mode(storm.io.OUTPUT, storm.io.D2, 
		     storm.io.D3, 
		     storm.io.D4,
		     storm.io.D5)
end

LED.stop = function()
-- configure pins to a low power state
end

-- Flash an LED pin for a period of time
--    unspecified duration is default of 10 ms
--    this is dull for green, but bright for read and blue
--    assumes cord.enter_loop() is in effect to schedule filaments
LED.flash=function(color,duration)
   local pin = LED.pins[color] or LED.pins["red2"]
   duration = duration or 10
   storm.io.set(1,storm.io[pin])
   storm.os.invokeLater(duration*storm.os.MILLISECOND,
			function() 
			   storm.io.set(0,storm.io[pin]) 
			end)
end


----------------------------------------------
-- Button module
-- provide basic button functions
----------------------------------------------
local Button = {}

Button.pins = {"D9","D10","D11"}

Button.start = function() 
   -- set buttons as inputs
   storm.io.set_mode(storm.io.INPUT,   
		     storm.io.D9, storm.io.D10, storm.io.D11)
   -- enable internal resistor pullups (none on board)
   storm.io.set_pull(storm.io.PULL_UP, 
		     storm.io.D9, storm.io.D10, storm.io.D11)
end

-- A version of Button.whenever that is more reliable. Whenever a button is pressed, waits
-- for a fixed time before registering any additional events, largely preventing the
-- action from ocurring multiple times.
-- The watch is returned in an array-like table. To cancel the watch, cancel the first
-- element with storm.io.watch_cancel and cancel the second element IF IT IS NOT NIL
-- with storm.os.cancel.
-- If your application requires multiple button presses in quick succession, you should
-- consider lowering Button.GAP
Button.GAP = 250
Button.whenever_gap = function(button, transition, action)
    local pin = storm.io[Button.pins[button]]
    local a = {[0]=nil, [1]=nil}
    a[0] = storm.io.watch_single(storm.io[transition], pin, function ()
        action()
        a[1] = storm.os.invokeLater(Button.GAP * storm.os.MILLISECOND, function ()
            local new = Button.whenever_gap(button, transition, action)
            a[0] = new[0]
            a[1] = new[1]
            end)
    end)
    return a
end
----------------------------------------------
shield.LED = LED
shield.Button = Button
return shield


