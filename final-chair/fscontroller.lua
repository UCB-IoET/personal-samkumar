require "cord"
require "storm"
RNQC = require "rnqClient"
RNQS = require "rnqServer"
LED = require "led"

local brd = LED:new("GP0")

local rnqcl = RNQC:new(60000)

local shell_ip = "2001:470:1f04:5f2::2"

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

forwardSocket = storm.net.udpsocket(30001, function (payload, ip, port)
				       return nil
					   end)

pt = function (t) for k, v in pairs(t) do print(k, v) end end

chairForwarder = RNQS:new(30002, function (payload, ip, port)
			     storm.net.sendto(forwardSocket, storm.mp.pack(payload), shell_ip, 38003)
			     return {rv = "ok"}
				 end)

local ip_arr = storm.os.getipaddr()
storm.net.sendto(forwardSocket, storm.mp.pack(ip_arr), shell_ip, 38003)

sh = require "stormsh"
sh.start()

cord.enter_loop()
