-- This is meant to be run on the server Firestorm. No shield is required.

NQS = require "nqserver"
LCD = require "lcd"

lcd = LCD:new(storm.i2c.EXT, 0x7c, storm.i2c.EXT, 0xc4)

cord.new(function ()
	lcd:init(2, 1)
	lcd:setBackColor(255, 255, 255)
end)

server = NQS:new(50004, function (payload, address, ip)
    cord.new(function ()
	    lcd:writeString(payload.message)
	end)
	print("Received " .. payload.message)
	return {}
end)

cord.enter_loop()
