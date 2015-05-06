-- RUNS ON PECS CHAIR BOARD
Settings = require "settings"
Settings.startup()
Settings = nil

require "cord"
ChairSettings = require "chairsettings"

storm.n.enable_reset()

server = storm.n.RNQServer:new(60004, storm.n.actuation_handler)

cord.new(function ()
    storm.n.bl_PECS_init()
    storm.n.bl_PECS_receive_cb_init()
    storm.n.bl_PECS_clear_recv_buf()
    while true do
        local bytes = cord.await(storm.n.bl_PECS_receive_cb, 5)
        b1, b2, b3, b4, b5 = storm.n.interpret_string(bytes)
        storm.n.bl_handler(b1, b2, b3, b4, b5)
        print("Got", b1, b2, b3, b4, b5)
    end
end)

sh = require "stormsh"
sh.start()
cord.enter_loop()
