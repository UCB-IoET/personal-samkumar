-- RUNS ON PECS CHAIR BOARD

-- Turn off the backlight
BL_CTL = storm.io.D5
storm.io.set_mode(storm.io.OUTPUT, BL_CTL)
storm.io.set(0, BL_CTL)

ChairSettings = require "chairsettings"

-- Store saved settings in flash and reset
storm.os.invokePeriodically(1213 * storm.os.SECOND, function ()
    local h = heaterSettings
    local f = fanSettings
    local timediff = storm.n.get_time_diff()
    if timediff == nil then
        timediff = 0
    end
    storm.n.flash_save_settings(h[storm.n.BACK_HEATER],
                          h[storm.n.BOTTOM_HEATER],
                          f[storm.n.BACK_FAN],
                          f[storm.n.BOTTOM_FAN],
                          timediff,
                          storm.os.reset)
end)

storm.n.enable_reset()

server = storm.n.RNQServer:new(60004, storm.n.actuation_handler)

-- Synchronize time with firestorm every minute
time_sync = storm.n.RNQClient:new(70000)
empty = {}
storm.os.invokePeriodically(12 * storm.os.SECOND, function ()
    local send_time = storm.n.get_time_always()
    print("asking for time")
    time_sync:sendMessage(empty,
                          "ff02::1",
                          30004,
                          250,
                          200 * storm.os.MILLISECOND,
                          nil,
                          function (msg)
                             if msg ~= nil and msg.time ~= nil then
                                 local recv_time = storm.n.get_time_always()
                                 local diff = storm.n.compute_time_diff(send_time, msg.time, msg.time, recv_time)
                                 print("Calculated diff " .. diff)
                                 storm.n.set_time_diff(diff)
                             end
                          end)
    end)

storm.n.bl_PECS_init()
storm.n.bl_PECS_receive_cb_init()
storm.n.bl_PECS_clear_recv_buf()

function handle_bl_msg(bytes)
    b1, b2, b3, b4, b5 = storm.n.interpret_string(bytes)
    print("using bl handler")
    storm.n.bl_handler(b1, b2, b3, b4, b5)
    print("Got", b1, b2, b3, b4, b5)
    storm.n.bl_PECS_receive_cb(5, handle_bl_msg)
end

storm.os.invokePeriodically(10 * storm.os.SECOND, function ()
    print("Imageram " .. storm.os.imageram())
    print("Using " .. gcinfo())
    collectgarbage("collect")
end)

storm.n.bl_PECS_receive_cb(5, handle_bl_msg)

while true do
    storm.os.wait_callback()
end
