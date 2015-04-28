require "cord"
RNQC = require "rnqClient"
local Settings = {}

storm.n.set_occupancy_mode(storm.n.ENABLE)
storm.n.set_heater_mode(storm.n.BOTTOM_HEATER, storm.n.ENABLE)
storm.n.set_heater_mode(storm.n.BACK_HEATER, storm.n.ENABLE)
storm.n.set_fan_mode(storm.n.ENABLE)
storm.n.set_temp_mode(storm.n.ENABLE)

storm.n.set_heater_state(storm.n.BOTTOM_HEATER, storm.n.OFF)
storm.n.set_heater_state(storm.n.BACK_HEATER, storm.n.OFF)
storm.n.set_fan_state(storm.n.BOTTOM_FAN, storm.n.OFF)
storm.n.set_fan_state(storm.n.BACK_FAN, storm.n.OFF)

heaterSettings = {[storm.n.BOTTOM_HEATER] = 0, [storm.n.BACK_HEATER] = 0}
fanSettings = {[storm.n.BOTTOM_FAN] = 0, [storm.n.BACK_FAN] = 0}
fans = {storm.n.BOTTOM_FAN, storm.n.BACK_FAN}

heaters = {storm.n.BOTTOM_HEATER, storm.n.BACK_HEATER}

for _, heater in pairs(heaters) do
   (function (heater)
         cord.new(function ()
               local setting = nil
               while true do
                  setting = 10 * heaterSettings[heater] * storm.os.MILLISECOND
                  if not storm.n.check_occupancy() then
                     setting = 0
                  end
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
   if storm.n.check_occupancy() then
         storm.n.set_fan_state(fan, storm.n.quantize_fan(setting))
   end
end
    

rnqcl = RNQC:new(30000)
function updateSMAP(full)
   local payload = {
      macaddr = "12345",
      occupancy = storm.n.check_occupancy()
   }
   temp, humidity = storm.n.get_temp_humidity(storm.n.CELSIUS)
   if full then
      payload.backh = heaterSettings[storm.n.BACK_HEATER]
      payload.bottomh = heaterSettings[storm.n.BOTTOM_HEATER]
      payload.backf = storm.n.quantize_fan(fanSettings[storm.n.BACK_FAN])
      payload.bottomf = storm.n.quantize_fan(fanSettings[storm.n.BOTTOM_FAN])
      payload.temperature = temp
      payload.humidity = humidity
   end
   --rnqcl:sendMessage(payload, "ff02::3109", 30002, 600, 15 * storm.os.MILLISECOND)
   
   -- Update the phone
   local occ = 0
   if payload.occupancy then
      occ = 1
   end
   local strpayload = storm.n.pack_string(heaterSettings[storm.n.BACK_HEATER], heaterSettings[storm.n.BOTTOM_HEATER], fanSettings[storm.n.BACK_FAN], fanSettings[storm.n.BOTTOM_FAN], occ, temp, humidity)
   storm.n.bl_PECS_send(strpayload)
   
   print("Updated")
end

storm.os.invokePeriodically(10 * storm.os.SECOND, updateSMAP, false)

local last_occupancy_state = false
storm.os.invokePeriodically(
   3 * storm.os.SECOND,
   function ()
      print("checking fan")
      local current_state = storm.n.check_occupancy()
      if current_state and not last_occupancy_state then
         for i = 1,#fans do
            fan = fans[i]
            storm.n.set_fan_state(fan, storm.n.quantize_fan(fanSettings[fan]))
         end
      elseif not current_state and last_occupancy_state then
         for i = 1,#fans do
            fan = fans[i]
            storm.n.set_fan_state(fan, storm.n.OFF)
         end
      end
      last_occupancy_state = current_state
   end
)

Settings.setHeater = setHeater
Settings.setFan = setFan
Settings.updateSMAP = updateSMAP

return Settings
