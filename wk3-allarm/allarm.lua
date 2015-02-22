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

now = 0 -- replace
mode = 0 -- 0 = clock, 1 = set

starter.Button.start()
starter.button.whenever(1, "FALLING", function() 
	if mode == 0 then
		printServices()
	else
		mode = 0
		time_until = alarm_time - now
		cur_alarm = storm.os.invokeLater(time_until * storm.os.MINUTE, function() allarm() end)
	end
end)
starter.button.whenever(2, "RISING", function() 
	if mode == 0 then
		if starter.Button.pressed("D11") then
			mode = 1
			alarm_time = now;
		end
	else
		alarm_time = alarm_time - 1
	end
end)
starter.button.whenever(3, "RISING", function() 
	if mode == 0 then
		if starter.Button.pressed("D10") then
			mode = 1
			alarm_time = now;
		end
	else
		alarm_time = alarm_time + 1
	end
end)

function printServices()
	--print info about discovered services
	for ip, payload in pairs(discovered_services) do
		for id, serv_list in pairs(payload) do
			print("ID " .. id .. "," .. ip)
			for i, service in pairs(serv_list) do
				print("   "	.. i .. ":" .. service)
			end
		end
	end
end



--send alarm signal!
function allarm()
	led_services = discoverer.resolve("setLED")
	buzz_services = discoverer.resolve("setBuzzer")
	for ip, services in pairs(led_services) do
		for service in services do
			discoverer.invoke(ip, service, {1}, function() end)
		end
	end
end

cord.enter_loop()
