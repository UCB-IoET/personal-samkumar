-- RUNS ON PECS CHAIR BOARD

require "cord"
RNQS = require "rnqServer"
Settings = require "settings"
ChairSettings = require "chairsettings"

Settings.startup()

pt = function (t) for k, v in pairs(t) do print(k, v) end end

timediff = nil

controls = {"backh", "bottomh", "backf", "bottomf"}
fnmap = {
   backh = ChairSettings.setHeater,
   bottomh = ChairSettings.setHeater,
   backf = ChairSettings.setFan,
   bottomf = ChairSettings.setFan
}
instmap = {
   backh = storm.n.BACK_HEATER,
   bottomh = storm.n.BOTTOM_HEATER,
   backf = storm.n.BACK_FAN,
   bottomf = storm.n.BOTTOM_FAN
}

local chair_state = {
   backh = 0,
   bottomh = 0,
   backf = 0,
   bottomf = 0
}

server = RNQS:new(
   60004,
   function (msgTable, ip, port)
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

cord.new(function ()
    storm.n.bl_PECS_init()
    storm.n.bl_PECS_receive_cb_init();
    storm.n.bl_PECS_clear_recv_buf()
    while true do
        local bytes = cord.await(storm.n.bl_PECS_receive_cb, 5)
        b1, b2, b3, b4, b5 = storm.n.interpret_string(bytes)
        if b5 == 1 then
            ChairSettings.setHeater(storm.n.BACK_HEATER, b1)
            ChairSettings.setHeater(storm.n.BOTTOM_HEATER, b2)
            ChairSettings.setFan(storm.n.BACK_FAN, b3)
            ChairSettings.setFan(storm.n.BOTTOM_FAN, b4)
        else
            ChairSettings.setTimeDiff(storm.n.bytes_to_timestamp(b1, b2, b3, b4) - storm.n.get_kernel_secs())
        end
        print("Got", b1, b2, b3, b4, b5)
    end
end)

sh = require "stormsh"
sh.start()
cord.enter_loop()
