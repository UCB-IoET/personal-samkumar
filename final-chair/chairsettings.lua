require "cord"
RNQC = require "rnqClient"
local Settings = {}

storm.n.set_occupancy_mode(storm.n.ENABLE)
storm.n.set_heater_mode(storm.n.BOTTOM_HEATER, storm.n.ENABLE)
storm.n.set_heater_mode(storm.n.BACK_HEATER, storm.n.ENABLE)
storm.n.set_fan_mode(storm.n.ENABLE)

storm.n.set_heater_state(storm.n.BOTTOM_HEATER, storm.n.OFF)
storm.n.set_heater_state(storm.n.BACK_HEATER, storm.n.OFF)
storm.n.set_fan_state(storm.n.BOTTOM_FAN, storm.n.OFF)
storm.n.set_fan_state(storm.n.BACK_FAN, storm.n.OFF)

heaterSettings = {[storm.n.BOTTOM_HEATER] = 0, [storm.n.BACK_HEATER] = 0}
fanSettings = {[storm.n.BOTTOM_FAN] = 0, [storm.n.BACK_FAN] = 0}

heaters = {storm.n.BOTTOM_HEATER, storm.n.BACK_HEATER}

for _, heater in pairs(heaters) do
   (function (heater)
       cord.new(function ()
		   local setting = nil
		   while true do
		      setting = 10 * heaterSettings[heater] * storm.os.MILLISECOND
		      if setting <= 0 then
			 cord.yield()
		      else
			 storm.n.set_heater_state(heater, storm.n.ON)
			 cord.await(storm.os.invokeLater, setting)
		      end
		      if setting >= storm.os.SECOND then
			 cord.yield()
		      else
			 storm.n.set_heater_state(heater, storm.n.OFF)
			 cord.await(storm.os.invokeLater, storm.os.SECOND - setting)
		      end
		   end
		end)
    end)(heater)
end

-- SETTING is from 0 to 100
function setHeater(heater, setting)
   heaterSettings[heater] = setting
end

-- SETTING is from 0 to 100
function setFan(fan, setting)
   fanSettings[fan] = setting
   local quantized = nil
   if setting == 0 then
      quantized = storm.n.OFF
   elseif setting < 25 then
      quantized = storm.n.LOW
   elseif setting < 50 then
      quantized = storm.n.MEDIUM
   elseif setting < 75 then
      quantized = storm.n.HIGH
   else
      quantized = storm.n.MAX
   end
   storm.n.set_fan_state(fan, quantized)
end

rnqcl = RNQC:new(30000)
function updateSMAP(full)
   local payload = {
      macaddr = "12345",
      occupancy = storm.n.check_occupancy()
   }
   if full then
      payload.backh = heaterSettings[storm.n.BACK_HEATER]
      payload.bottomh = heaterSettings[storm.n.BOTTOM_HEATER]
      payload.backf = fanSettings[storm.n.BACK_FAN]
      payload.bottomf = fanSettings[storm.n.BOTTOM_FAN]
   end
   rnqcl:sendMessage(payload, "ff02::3109", 30002)
end

storm.os.invokePeriodically(10 * storm.os.SECOND, updateSMAP, false)

Settings.setHeater = setHeater
Settings.setFan = setFan
Settings.updateSMAP = updateSMAP

return Settings
