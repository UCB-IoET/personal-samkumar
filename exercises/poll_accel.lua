storm = require "storm"
cord = require "cord"

ACCEL_ADDR = 0x3c
function poll_accel()
    local arr = storm.array.create(15, storm.array.UINT8)
    local rv = cord.await(storm.i2c.read, storm.i2c.INT + ACCEL_ADDR, storm.i2c.START + storm.i2c.STOP, arr)
    if rv == storm.i2c.OK then
        print("Start")
        for i = 1, #arr do
            print(arr[i])
        end
        print("Stop")
    end
end

function init_accel()
end
        
cord.new(function ()
    while true do
        poll_accel()
        cord.await(storm.os.invokeLater, 100 * storm.os.MILLISECOND)
    end
end)

cord.enter_loop()
