-- RUNS ON PECS CHAIR BOARD
Settings = require "settings"
Settings.startup()
Settings = nil

-- Turn off the backlight
BL_CTL = storm.io.D5
storm.io.set_mode(storm.io.OUTPUT, BL_CTL)
storm.io.set(0, BL_CTL)

require "cord"
ChairSettings = require "chairsettings"

storm.n.enable_reset()

server = storm.n.RNQServer:new(60004, storm.n.actuation_handler)

-- Synchronize time with firestorm every 20 seconds
time_sync = storm.n.RNQClient:new(70000)
empty = {}
storm.os.invokePeriodically(20 * storm.os.SECOND, function ()
    local send_time = storm.n.get_time_always()
    print("asking for time")
    time_sync:sendMessage(empty,
                          "ff02::1",
                          30004,
                          300,
                          25 * storm.os.MILLISECOND,
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

cord.new(function ()
    storm.n.bl_PECS_init()
    storm.n.bl_PECS_receive_cb_init()
    storm.n.bl_PECS_clear_recv_buf()
    while true do
        local bytes = cord.await(storm.n.bl_PECS_receive_cb, 5)
        b1, b2, b3, b4, b5 = storm.n.interpret_string(bytes)
        print("using bl handler")
        storm.n.bl_handler(b1, b2, b3, b4, b5)
        print("Got", b1, b2, b3, b4, b5)
    end
end)

sh = require "stormsh"
sh.start()
cord.enter_loop()
