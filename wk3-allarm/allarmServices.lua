Advertiser = require "advertiser"
LED = require "led"
Buzzer = require "buzzer"

d4led = LED:new("D4")
d6buzzer = Buzzer:new("D6")

adv = Advertiser:new("lightbuzzer")

adv:addService("setLed", "setBool", "D4", function (val)
    if val then
        d4led:on()
        return true
    else
        d4led:off()
        return false
    end
end)

adv:addService("setBuzzer", "setBool", "D6", function (val)
    if val then
        d6buzzer:start(7 * storm.os.MILLISECOND)
        return true
    else
        d6buzzer:stop()
        return false
    end
end)

adv:advertiseRepeatedly(storm.os.SECOND)

cord.enter_loop()
