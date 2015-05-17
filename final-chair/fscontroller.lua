require "cord"
require "storm"
RNQC = storm.n.RNQClient
RNQS = storm.n.RNQServer

rnqcl = RNQC:new(60000)

shell_ip = "2001:470:1f04:5f2::2"
proj_ip = "2001:470:66:3f9::2"

server_ip = proj_ip

TOPORT = 60004

function sendActuationMessage(payload, address, ip)
   print("Got actuation message")
   payload = storm.mp.unpack(payload)
   local toIP = payload["toIP"]
   payload["toIP"] = nil
   print("Actuating " .. toIP)
   rnqcl:sendMessage(payload,
		     toIP,
		     TOPORT,
		     nil,
		     nil,
		     function ()
			print("trying")
		     end,
		     function (payload, address, port)
			if payload == nil then
			   print("Send FAILS.")
			else
			   print("Response received.")
			end
		     end)
end

from_server = storm.net.udpsocket(60001, sendActuationMessage)

to_server = RNQC:new(30001)

pt = function (t) for k, v in pairs(t) do print(k, v) end end

chairForwarder = RNQS:new(30002,
			  function (payload, ip, port)
			     print(ip)
                     
			     local msg = storm.mp.pack(payload)
			     print(#msg)
                     
			     to_server:sendMessage(msg,
						   sever_ip,
						   38003,
						   1000,
						   100 * storm.os.MILLISECOND,
						   nil,
						   function (msg)
						      if msg == nil then
							 print("Failure")
						      else
							 print("Success")
						      end
						   end)
			     return {rv = "ok"}
			  end)
				 
sh = require "stormsh"
sh.start()

cord.enter_loop()
