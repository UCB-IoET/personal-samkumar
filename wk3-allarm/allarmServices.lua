Advertiser = require "advertiser"
LED = require "led"
Buzzer = require "buzzer"

d4led = LED:new("D4")
d6buzzer = Buzzer:new("D6")

adv = Advertiser:new("lightbuzzer")

adv:addService("setLed", "setBool", "sets LED at pin D4", function (val)
    if val then
        d4led:on()
    else
        d4led:off()
    end
end)

adv:addService("setBuzzer", "setBool", "sets Buzzer at pin D6", function (val)
    if val then
        d6buzzer.start(7 * storm.os.MILLISECOND)
    else
        d6buzzer.stop()
    end
end)

adv:advertiseRepeatedly(storm.os.SECOND)

cord.enter_loop()
