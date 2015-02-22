require "storm"
require "cord"
d = require "starterShieldDisplay"
Button = require "button"
Discoverer = require "discoverer"

d:new()

function found()
	printServices()
end

function lost()
	printServices()
end

disc = Discoverer:new(found, lost)

button1 = Button:new("D11")
button2 = Button:new("D10")
button3 = Button:new("D9")

mode = 0 -- 0 = clock, 1 = set, 2 = ringing
hour = 0
min = 0
button3:whenever_debounced("RISING", function() 
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

button2:whenever_debounced("FALLING", function() 
	if mode == 0 then
		if starter.Button.pressed(3) == 1 then
			changeMode(1)
			alarm_time = hour * 60 + min;
		end
	else
		alarm_time = alarm_time - 1
		d:time(alarm_time / 60, alarm_time % 60)
	end
end)

button1:whenever_debounced("FALLING", function() 
	if mode == 0 then
		if starter.Button.pressed(2) == 1 then
			changeMode(1)
			alarm_time = hour * 60 + min;
		end
	else
		alarm_time = alarm_time + 1
		d:time(alarm_time / 60, alarm_time % 60)
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
	print("mode = " .. mode)
	for ip, payload in pairs(disc.discovered_services) do
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
	send_all(led_services, true)
	send_all(buzz_services, true)
	d:num(8888)
end

function allunarm()
	changeMode(0)
	send_all(led_services, false)
	send_all(buzz_services, false)
	led_services = nil
	buzz_services = nil
	show_time()
end	

function send_all(dict, arg)
	for ip, services in pairs(dict) do
		for service in services do
			disc:invoke(ip, service, {arg}, nil, nil, nil, function() end)
		end
	end
end

function show_time()
	d:time(hour, min)
end

--start clock running
hour = 9 --replace these three declarations with the first time upon initialization
min = 10
sec = 20
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
