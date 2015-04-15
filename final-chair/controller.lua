-- RUNS ON PECS CHAIR BOARD

require "cord"
RNQS = require "rnqServer"
ChairSettings = require "chairsettings"

pt = function (t) for k, v in pairs(t) do print(k, v) end end

controls = {"backh", "bottomh", "backf", "bottomf"}
fnmap = {backh = ChairSettings.setHeater, bottomh = ChairSettings.setHeater,
	 backf = ChairSettings.setFan, bottomf = ChairSettings.setFan}
instmap = {backh = storm.n.BACK_HEATER, bottomh = storm.n.BOTTOM_HEATER,
	   backf = storm.n.BACK_FAN, bottomf = storm.n.BOTTOM_FAN}

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
			   if cmd >= 0 and cmd <= 100 then
			      fnmap[control](instmap[control], cmd)
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
