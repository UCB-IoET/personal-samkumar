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

controls = {"backh", "bottomh", "backf", "bottomf"}
fnmap = {backh = storm.n.set_heater_state, bottomh = storm.n.set_heater_state,
	 backf = storm.n.set_fan_state, bottomf = storm.n.set_fan_state}
instmap = {backh = storm.n.BACK_HEATER, bottomh = storm.n.BOTTOM_HEATER,
	   backf = storm.n.BACK_FAN, bottomf = storm.n.BOTTOM_FAN}
states = {
   backh = {OFF = true, ON = true},
   backf = {OFF = true, LOW = true, MEDIUM = true, HIGH = true, MAX = true}
}
states.bottomh = states.backh
states.bottomf = states.backf

server = RNQS:new(60004, function (msgTable, ip, port)
		     print("got")
		     pt(msgTable)
		     local retTable = {}
		     local cmd = 0
		     if msgTable["heaters"] ~= nil then
			msgTable["backh"] = msgTable["heaters"]
			msgTable["bottomh"] = msgTable["heaters"]
			msgTable["heaters"] = nil
		     end
		     if msgTable["fans"] ~= nil then
			msgTable["backf"] = msgTable["fans"]
			msgTable["bottomf"] = msgTable["fans"]
			msgTable["fans"] = nil
		     end

		     for _, control in pairs(controls) do
			if msgTable[control] ~= nil then
			   cmd = msgTable[control]
			   if states[control][cmd] ~= nil then
			      fnmap[control](instmap[control], storm.n[cmd])
			      retTable[control] = "ok"
			   else
			      retTable[control] = "fail"
			   end
			end
		     end
		     print("returning")
		     pt(retTable)
		     return retTable
			 end)

sh = require "stormsh"
sh.start()
cord.enter_loop()
