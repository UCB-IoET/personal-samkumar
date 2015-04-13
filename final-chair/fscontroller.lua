require "cord"
RNQC = require "rnqClient"
RNQS = require "rnqServer"
LED = require "led"

local brd = LED:new("GP0")

local rnqcl = RNQC:new(60000)

TOPORT = 60004

TEST_IP = "ff02::beef"

MY_IP = "2001:470:4956:2:212:6d02:0:3109"

function sendActuationMessage(payload, address, ip)
   brd:flash()
   local toIP = payload["toIP"]
   payload["toIP"] = nil
   rnqcl:sendMessage(payload, TEST_IP, TOPORT, nil, nil, function () print("trying") end, function (payload, address, port)
			if payload == nil then
			   print("Send FAILS.")
			else
			   print("Response received.")
			end
							   end)
end

server = RNQS:new(60001, sendActuationMessage)

sh = require "stormsh"
sh.start()

cord.enter_loop()
