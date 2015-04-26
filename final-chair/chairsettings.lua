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
   fanSettings[fan] = quantized
   if storm.n.check_occupancy() then
     storm.n.set_fan_state(fan, quantized)
   end
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

local callbacks = {}

function on_occupancy_changed(callback)
   callbacks[#callbacks + 1] = callback
end

function poll_chair_state()
   local last_state = storm.n.check_occupancy()
   storm.os.invokePeriodically(
      500*storm.os.MILLISECOND,
      function()
         local current_state = storm.n.check_occupancy()
         local temp_last_state = last_state
         last_state = current_state
         if temp_last_state ~= current_state then
            for i=1,#callbacks do
               callback(current_state)
            end            
         end
      end
   )
end

function chair_state_callback(occupied)
   if occupied then
      for i = 1,#fans do
            fan = fans[i]
            storm.n.set_fan_state(fan, fanSettings[fan])
      end
   else
      for i = 1,#fans do
         fan = fans[i]
         storm.n.set_fan_state(fan, storm.n.OFF)
      end
   end
end

on_occupancy_changed(chair_state_callback)

Settings.setHeater = setHeater
Settings.setFan = setFan
Settings.updateSMAP = updateSMAP
Settings.on_occupancy_changed = on_occupancy_changed

return Settings
