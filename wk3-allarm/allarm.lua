require "storm"
require "cord"
starter = require "starterShield"
discoverer = require "discoverer"

function found()
	printServices()
end

function lost()
	printServices()
end

discoverer:new(found, lost)

starter.Button.start()
starter.button.whenever(1, "RISING", function() printServices() end)
function printServices()
	--print info about discovered services
	for ip, payload in pairs(discovered_services) do
		for id, serv_list in pairs(payload) do
			print("ID " .. id .. "," .. ip)
			for i, service in pairs(serv_list) do
				print("  " i .. ":" .. service)
			end
		end
	end
end

cord.enter_loop()
