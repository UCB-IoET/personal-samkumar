-- RUNS ON PECS CHAIR BOARD
Settings = require "settings"
Settings.startup()
Settings = nil

require "cord"
RNQS = require "rnqServer"
ChairSettings = require "chairsettings"

pt = function (t) for k, v in pairs(t) do print(k, v) end end

server = RNQS:new(60004, storm.n.actuation_handler)

cord.new(function ()
    storm.n.bl_PECS_init()
    storm.n.bl_PECS_receive_cb_init()
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
