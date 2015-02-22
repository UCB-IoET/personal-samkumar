require "storm"
require "cord"
d = require "starterShieldDisplay"
starter = require "starterShield"
discoverer = require "discoverer"

d:init()

function found()
	printServices()
end

function lost()
	printServices()
end

discoverer:new(found, lost)

mode = 0 -- 0 = clock, 1 = set, 2 = ringing
hour = 0
min = 0
starter.Button.start()
starter.button.whenever(1, "RISING", function() 
	if mode == 0 then
		printServices()
	elseif mode == 1 then
		mode = 0
		time_until = alarm_time - (hour * 60 + min)
		cur_alarm = storm.os.invokeLater(time_until * storm.os.MINUTE, function() allarm() end)
	else
		mode = 0
		allunarm()
	end
end)
starter.button.whenever(2, "FALLING", function() 
	if mode == 0 then
		if starter.Button.pressed("D11") then
			mode = 1
			alarm_time = hour * 60 + min;
		end
	else
		alarm_time = alarm_time - 1
	end
end)
starter.button.whenever(3, "FALLING", function() 
	if mode == 0 then
		if starter.Button.pressed("D10") then
			mode = 1
			alarm_time = hour * 60 + min;
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
	mode = 2
	led_services = discoverer.resolve("setLED")
	buzz_services = discoverer.resolve("setBuzzer")
	send_all(1)
end

function allunarm()
	mode = 0
	send_all(0)
	led_services = nil
	buzz_services = nil
end	

function send_all(arg)
	for ip, services in pairs(led_services) do
		for service in services do
			discoverer.invoke(ip, service, {arg}, function() end)
		end
	end
end

function show_time()
	d:time(hour, min)
end

storm.os.invokePeriodically(storm.os.MINUTE, function() if mode == 0 then show_time() end end)

cord.enter_loop()
