LED = require "led"
require "cord"
require "svcd"

-- Actuate the relay like an LED
button = LED:new("D8")

COFFEE_SERVICE = 0x3004
MKCOFFEE_ATTR = 0x4C0F
CLNSELF_ATTR = 0x4CAF

cord.new(function ()
	    cord.await(SVCD.init, "THE ULTRA-EPIC COFFEE MAKER")
	    SVCD.add_service(COFFEE_SERVICE)
	    SVCD.add_attribute(COFFEE_SERVICE, MKCOFFEE_ATTR, function (payload, source_ip, source_port)
				  args = storm.array.fromstr(payload)                  
				  print("making coffee " .. args:get(1))
				  button:flash(1, 10000 + (args:get(1) * 100))
				  print("finished")
							      end)
	    SVCD.add_attribute(COFFEE_SERVICE, CLNSELF_ATTR, function (payload, source_ip, source_port)
				  cord.new(function ()
					      local i
					      for i = 1, 3 do
						 button:on()
						 cord.await(storm.os.invokeLater, 300 * storm.os.MILLISECOND)
						 button:off()
						 cord.await(storm.os.invokeLater, 300 * storm.os.MILLISECOND)
					      end
					   end)
							      end)
	    --[[while true do
	       SVCD.notify(COFFEE_SERVICE, MKCOFFEE_ATTR, "I can make coffee!")
	       cord.await(storm.os.invokeLater, 100 * storm.os.MILLISECOND)
	       SVCD.notify(COFFEE_SERVICE, CLNSELF_ATTR, "I can clean myself!")
	       cord.await(storm.os.invokeLater, 100 * storm.os.MILLISECOND)
	       end]]--
	 end)

cord.enter_loop()
