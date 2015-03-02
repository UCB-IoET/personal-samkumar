-- Heavily based on group MESH's week 3 miniproject

require "storm"
require "cord"
d = require "starterShieldDisplay"
Button = require "button"
require "svcd"

d:new()

coffee_machine = nil

cord.new(function()
	    cord.await(SVCD.init, "coffee_client")
	    SVCD.advert_received = function(pay, srcip, srcprt)
	       local adv = storm.mp.unpack(pay)
	       for k,v in pairs(adv) do
		  if k == 0x3004 then
		     coffee_machine = srcip
		     print("Detected coffee machine!")
		  end
	       end
	    end
	 end)

button1 = Button:new("D11")
button2 = Button:new("D10")
button3 = Button:new("D9")

Button.GAP = 100 * storm.os.MILLISECOND

mode = 0 -- 0 = clock, 1 = set, 2 = ringing
button3:whenever_debounced("RISING", function() 
	if mode == 1 then
		changeMode(0)
		alarm_hour = alarm_time / 60
		alarm_min = alarm_time % 60
	else
		changeMode(0)
		allunarm()
	end
end)

button1:whenever_debounced("FALLING", function() 
	if mode == 0 then
		if button2:pressed() == 1 then
			changeMode(1)
			alarm_time = hour * 60 + min;
		end
	else
		alarm_time = alarm_time - 1
		d:time(alarm_time / 60, alarm_time % 60)
	end
end)

button2:whenever_debounced("FALLING", function() 
	if mode == 0 then
		if button1:pressed() == 1 then
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

--send alarm signal!
function allarm()
	changeMode(2)
	if mode == 0 then
		d:num(8888)
	end
end

function allunarm()
	changeMode(0)
	if not coffee_machine then
	   return
	end
	cord.new(function()
		    local cmd = storm.array.create(1, storm.array.UINT16)
		    cmd:set(1, 2000)
		    local triesLeft = 1000
		    local write = SVCD.TIMEOUT
		    while write == SVCD.TIMEOUT and triesLeft > 0 do
		       print("trying to turn on coffee machine")
		       write = cord.await(SVCD.write, coffee_machine, 0x3004, 0x4c0f, cmd:as_str(), 2000)
		       print(write)
		       triesLeft = triesLeft - 1
		    end
		    if triesLeft == 0 then
		       print("gave up turning on coffee machine")
		    else
		       print("finished turning on coffee machine")
		    end
		 end)
	show_time()
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
	if alarm_hour == hour and alarm_min == min then
		allarm()
	elseif mode == 0 then
		show_time()
	end
	storm.os.invokePeriodically(storm.os.MINUTE, function()
		min = min + 1
		if alarm_hour == hour and alarm_min == min then
			allarm()
		elseif mode == 0 then
			show_time()
		end
	end)
end)

cord.enter_loop()
