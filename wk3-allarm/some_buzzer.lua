require "cord"
require "storm"
advertiser = require "advertiser"

advertiser:new("some_buzzer")

advertiser:addService("set_buzzer", "setBuzzer", "sets this buzzer state.", function() set_buzzer end)

advertiser:advertise_repeatedly(storm.os.SECOND)

function set_buzzer(state)
	if state then
		Buzz.go()
	else
		Buzz.stop()
	end
end

----------------------------------------------
-- Buzz module
-- provide basic buzzer functions
----------------------------------------------
local Buzz = {}

Buzz.run = nil
Buzz.go = function(delay)
   delay = delay or 0
   -- configure buzzer pin for output
   storm.io.set_mode(storm.io.OUTPUT, storm.io.D6)
   Buzz.run = true
   -- create buzzer filament and run till stopped externally
   -- this demonstrates the await pattern in which
   -- the filiment is suspended until an asynchronous call 
   -- completes
   cord.new(function()
         while Buzz.run do
      storm.io.set(1,storm.io.D6)
      storm.io.set(0,storm.io.D6)
      if (delay == 0) then cord.yield()
      else cord.await(storm.os.invokeLater,
          delay*storm.os.MILLISECOND)
      end
         end
      end)
end

Buzz.stop = function()
   print ("Buzz.stop")
   Buzz.run = false   -- stop Buzz.go partner
-- configure pins to a low power state
end

-- enable a shell
sh = require "stormsh"
sh.start()
cord.enter_loop() -- start event/sleep loop

