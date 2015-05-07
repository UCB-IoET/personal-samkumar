require "cord"
require "storm"
RNQC = storm.n.RNQClient
RNQS = storm.n.RNQServer

local rnqcl = RNQC:new(60000)

local shell_ip = "2001:470:1f04:5f2::2"

TOPORT = 60004

function sendActuationMessage(payload, address, ip)
   print("Got actuation message")
   payload = storm.mp.unpack(payload)
   local toIP = payload["toIP"]
   payload["toIP"] = nil
   print("Actuating " .. toIP)
   rnqcl:sendMessage(payload, toIP, TOPORT, nil, nil, function () print("trying") end, function (payload, address, port)
			if payload == nil then
			   print("Send FAILS.")
			else
			   print("Response received.")
			end
							   end)
end

server = storm.net.udpsocket(60001, sendActuationMessage)

forwardSocket = storm.net.udpsocket(30001, function (payload, ip, port)
                        print("Got data on forward socket")
                        print(payload)
				       return nil
					   end)

pt = function (t) for k, v in pairs(t) do print(k, v) end end

chairForwarder = RNQS:new(30002, function (payload, ip, port)
                     print(ip)
                     
                     local msg = storm.mp.pack(payload)
                     print(#msg)
                     
                     storm.net.sendto(forwardSocket, msg, shell_ip, 38003)
                     storm.os.invokeLater(250 * storm.os.MILLISECOND, storm.net.sendto, forwardSocket, msg, shell_ip, 38003)
                     storm.os.invokeLater(500 * storm.os.MILLISECOND, storm.net.sendto, forwardSocket, msg, shell_ip, 38003)
                     storm.os.invokeLater(1000 * storm.os.MILLISECOND, storm.net.sendto, forwardSocket, msg, shell_ip, 38003)
                     storm.os.invokeLater(1500 * storm.os.MILLISECOND, storm.net.sendto, forwardSocket, msg, shell_ip, 38003)
                     storm.os.invokeLater(2000 * storm.os.MILLISECOND, storm.net.sendto, forwardSocket, msg, shell_ip, 38003)
                     storm.os.invokeLater(2500 * storm.os.MILLISECOND, storm.net.sendto, forwardSocket, msg, shell_ip, 38003)
                     storm.os.invokeLater(3000 * storm.os.MILLISECOND, storm.net.sendto, forwardSocket, msg, shell_ip, 38003)
                     
                     return {rv = "ok"}
				 end)
				 
sh = require "stormsh"
sh.start()

cord.enter_loop()
