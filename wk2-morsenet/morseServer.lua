-- This is meant to be run on the server Firestorm. No shield is required.

NQS = require "nqserver"
LCD = require "lcd"

lcd = LCD:new(storm.i2c.EXT, 0x7c, storm.i2c.EXT, 0xc4)

cord.new(function ()
	lcd:init(2, 1)
	lcd:setBackColor(255, 255, 255)
end)

column = 0
row = 0
server = NQS:new(50004, function (payload, address, ip)
    cord.new(function ()
	    lcd:writeString(payload.message)
	    column = column + 1
	    if column == 16 then
	        column = 0
	        row = 1 - row
	        lcd:setCursor(row, column)
	        if row == 0 then
	            lcd:clear()
	        end
	    end
	end)
	print("Received " .. payload.message)
	return {}
end)

cord.enter_loop()
