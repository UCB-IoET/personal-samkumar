-- RUNS ON PECS CHAIR BOARD

require "cord"
RNQS = require "rnqServer"

storm.n.set_heater_mode(storm.n.BOTTOM_HEATER, storm.n.ENABLE)
storm.n.set_heater_mode(storm.n.BACK_HEATER, storm.n.ENABLE)
storm.n.set_fan_mode(storm.n.ENABLE)
storm.n.set_occupancy_mode(storm.n.ENABLE)

storm.n.set_heater_state(storm.n.BOTTOM_HEATER, storm.n.OFF)
storm.n.set_heater_state(storm.n.BACK_HEATER, storm.n.OFF)
storm.n.set_fan_state(storm.n.BOTTOM_FAN, storm.n.OFF)
storm.n.set_fan_state(storm.n.BACK_FAN, storm.n.OFF)

pt = function (t) for k, v in pairs(t) do print(k, v) end end

server = RNQS:new(60004, function (msgTable, ip, port)
		     print("got")
		     pt(msgTable)
		     local retTable = {}
		     local cmd = 0
		     if msgTable["heaters"] ~= nil then
			cmd = msgTable["heaters"]
			if cmd == "OFF" or cmd == "ON" or cmd == "TOGGLE" then
			   storm.n.set_heater_state(storm.n.BOTTOM_HEATER, storm.n[cmd])
			   storm.n.set_heater_state(storm.n.BACK_HEATER, storm.n[cmd])
			   retTable["heaters"] = "ok"
			else
			   retTable["heaters"] = "fail"
			end
		     end
		     if msgTable["fans"] ~= nil then
			cmd = msgTable["fans"]
			if cmd == "OFF" or cmd == "LOW" or cmd == "MEDIUM" or cmd =="HIGH" or cmd == "MAX" then
			   storm.n.set_fan_state(storm.n.BOTTOM_FAN, storm.n[cmd])
			   storm.n.set_fan_state(storm.n.BACK_FAN, storm.n[cmd])
			   retTable["fans"] = "ok"
			else
			   retTable["fans"] = "fail"
			end
		     end
		     if msgTable["occupancy"] ~= nil then
			retTable["occupancy"] = storm.n.check_occupancy()
		     end
		     print("returning")
		     pt(retTable)
		     return retTable
			 end)

sh = require "stormsh"
sh.start()
cord.enter_loop()
