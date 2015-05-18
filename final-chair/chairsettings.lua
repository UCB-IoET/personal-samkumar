require "cord"
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

storm.n.flash_write_log(nil, 0, 0, 0, 0, 0, 0, 0, true, function () print("Logging reboot") end)

lastsent = false

for _, heater in pairs(heaters) do
    (function (heater)
        storm.os.invokePeriodically(storm.os.SECOND, function ()
            local setting = 10 * heaterSettings[heater] * storm.os.MILLISECOND
            if not storm.n.check_occupancy() then
                setting = 0
            end
            if setting > 0 then
                storm.n.set_heater_state(heater, storm.n.ON)
            end
            if setting < storm.os.SECOND then
                storm.os.invokeLater(setting, storm.n.set_heater_state, heater, storm.n.OFF)
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
    
rnqcl = storm.n.RNQClient:new(30000)
function updateSMAP()
   temp, humidity = storm.n.get_temp_humidity(storm.n.CELSIUS)
   local pyld = { storm.os.nodeid(), storm.n.check_occupancy(), heaterSettings[storm.n.BACK_HEATER], heaterSettings[storm.n.BOTTOM_HEATER], fanSettings[storm.n.BACK_FAN], fanSettings[storm.n.BOTTOM_FAN], temp, humidity }
   
   -- Update the phone
   local occ = 0
   if pyld[2] then
      occ = 1
   end
   local strpyld = storm.n.pack_string(pyld[3], pyld[4], pyld[5], pyld[6], occ, temp, humidity)
   storm.n.bl_PECS_send(strpyld)
   if storm.n.is_processing_backlog() then
       return
   end
   if not lastsent then
       lastsent = true
       storm.n.flash_read_sp(function (sp)
           storm.n.start_processing_backlog(sp - 1)
       end)
       return
   end
   -- Update via 15.4
   lastsent = false
   sendPayload(pyld)
   
   -- Log to Flash
   storm.n.flash_write_log(storm.n.get_time(), pyld[3], pyld[4], pyld[5], pyld[6], temp, humidity, occ, false, function () print("Logged") end)
   print("Updated")
end

function sendPayload(pyld)
    rnqcl:sendMessage(pyld,
                      "ff02::1",
                      30002,
                      300,
                      25 * storm.os.MILLISECOND,
                      function () end,
                      function (message)
                          if message ~= nil then
                              print("Success!")
                          else
                              print("15.4 Failed")
                          end
                      end)
end

ackReceiver = storm.n.RNQServer:new(29000, function (payload, ip, port)
                                          lastsent = true
                                          storm.n.process_next_backlog();
                                          print("Got confirmation")
                                      end)

storm.os.invokePeriodically(20 * storm.os.SECOND, updateSMAP)

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
