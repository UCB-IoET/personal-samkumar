require "cord"
require "storm"
RNQC = storm.n.RNQClient
RNQS = storm.n.RNQServer

rnqcl = RNQC:new(60000)

shell_ip = "2001:470:1f04:5f2::2"
proj_ip = "2001:470:66:3f9::2"

server_ip = proj_ip

function sendActuationMessage(payload, srcip, srcport)
   print("Got actuation message")
   payload = storm.mp.unpack(payload)
   local toIP = payload["toIP"]
   payload["toIP"] = nil
   print("Actuating " .. toIP)
   rnqcl:sendMessage(payload,
                     toIP,
                     60004,
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

from_server = RNQS:new(60001, sendActuationMessage)
to_server = RNQC:new(30001)

pt = function (t) for k, v in pairs(t) do print(k, v) end end

currport = 10000

chairForwarder = RNQS:new(30002,
                          function (payload, ip, port)
                             print(ip)
                     
                             local msg = storm.mp.pack(payload)
                             print(#msg)
                     
                             to_server:sendMessage(payload,
                                                   server_ip,
                                                   38003,
                                                   30,
                                                   100 * storm.os.MILLISECOND,
                                                   nil,
                                                   function (msg)
                                                      if msg == nil then
                                                         print("Failure")
                                                      else
                                                         print("Success")
                                                         local sender = RNQC:new(currport)
                                                         sender:sendMessage({"rv": "success"},
                                                                            ip,
                                                                            29000,
                                                                            300,
                                                                            25 * storm.os.MILLISECOND,
                                                                            nil,
                                                                            function ()
                                                                                sender:close()
                                                                            end)
                                                      end
                                                   end)
                             return {rv = "ok"}
                          end)
                                 
-- Synchronize time with server every 20 seconds
time_sync = RNQC:new(30003)
empty = {}
function synctime()
    local send_time = storm.n.get_time_always()
    print("asking for time")
    time_sync:sendMessage(empty,
                          server_ip,
                          38002,
                          30,
                          100 * storm.os.MILLISECOND,
                          nil,
                          function (msg)
                             if msg ~= nil then
                                 print ("got time message " .. msg.time)
                                 local recv_time = storm.n.get_time_always()
                                 local diff = storm.n.compute_time_diff(send_time, msg.time, msg.time, recv_time)
                                 print("Calculated diff " .. diff)
                                 storm.n.set_time_diff(diff)
                             else
                                 print("No time response received")
                             end
                          end)
end
synctime()
storm.os.invokePeriodically(20 * storm.os.SECOND, synctime)
    
-- Allow chairs to synchronize time with firestorm
synchronizer = RNQS:new(30004, function () print("Got synchronization request") return {["time"] = storm.n.get_time()} end)
                                 
sh = require "stormsh"
sh.start()

cord.enter_loop()
