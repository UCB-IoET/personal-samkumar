require "storm"
require "cord"
d = require "starterShieldDisplay"
starter = require "starterShield"
discoverer = require "discoverer"

d:new()

function found()
	printServices()
end

function lost()
	printServices()
end

disc = discoverer:new(found, lost)

mode = 0 -- 0 = clock, 1 = set, 2 = ringing
hour = 0
min = 0
starter.Button.start()
starter.Button.whenever(1, "RISING", function() 
	if mode == 0 then
		printServices()
	elseif mode == 1 then
		changeMode(0)
		time_until = alarm_time - (hour * 60 + min)
		cur_alarm = storm.os.invokeLater(time_until * storm.os.MINUTE, function() allarm() end)
	else
		changeMode(0)
		allunarm()
	end
end)
starter.Button.whenever(2, "FALLING", function() 
	if mode == 0 then
		if starter.Button.pressed("D11") then
			changeMode(1)
			alarm_time = hour * 60 + min;
		end
	else
		alarm_time = alarm_time - 1
	end
end)
starter.Button.whenever(3, "FALLING", function() 
	if mode == 0 then
		if starter.Button.pressed("D10") then
			changeMode(1)
			alarm_time = hour * 60 + min;
		end
	else
		alarm_time = alarm_time + 1
	end
end)

function changeMode(m)
	mode = m
	if mode == 2 then
		d:num(8888)
	else
		show_time()
	end
end

function printServices()
	--print info about discovered services
	print("Printing services")
	for ip, payload in pairs(discoverer.discovered_services) do
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
	changeMode(2)
	led_services = disc:resolve("setLed")
	buzz_services = disc:resolve("setBuzzer")
	send_all(true)
	d:num(8888)
end

function allunarm()
	changeMode(0)
	send_all(false)
	led_services = nil
	buzz_services = nil
	show_time()
end	

function send_all(arg)
	for ip, services in pairs(led_services) do
		for service in services do
			disc:invoke(ip, service, {arg}, function() end)
		end
	end
end

function show_time()
	d:time(hour, min)
end

--start clock running
hour = 0 --replace these three declarations with the first time upon initialization
min = 0
sec = 0
show_time()
storm.os.invokeLater((60 - sec) * storm.os.SECOND, function()
	min = min + 1
	show_time()
	storm.os.invokePeriodically(storm.os.MINUTE, function()
		min = min + 1
		if mode == 0 then
			show_time()
		end
	end)
end)

cord.enter_loop()
