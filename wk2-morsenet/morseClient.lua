require("cord")
require("storm")
shield = require("starter") -- interfaces for resources on starter shield
morse = require("morse") -- interfaces for resources on starter shield
NQC = require("nqclient")

morse.computeMorseToAlpha()
morse.Alphabet = nil
collectgarbage()

nqcl = NQC:new(50001)

local morse_code = {}
local num_code = 0
local got_something = 0

shield.LED.start()

print("Begin Morse Coding")

shield.Button.start()


shield.Button.whenever_gap(3, "FALLING", function() 
                           num_code = num_code + 1
                           morse_code[num_code] = false end)

shield.Button.whenever_gap(2, "FALLING", function() 
                           num_code = num_code + 1
                           morse_code[num_code] = true end)

shield.Button.whenever_gap(1, "FALLING", function()
	local curr_table = morse.MorseToAlpha
    for i = 1, num_code do
        curr_table = curr_table[morse_code[i]]
        if curr_table == nil then
            num_code = 0
            return
        end
    end
    if curr_table["end"] ~= nil then
        local letter = curr_table['end']
        print("LETTER: "..letter)
        shield.LED.flash("blue")
        nqcl:sendMessage({["message"] = letter}, "ff02::1", 50004, function (payload, address, port)
		    shield.LED.flash("red")
		    print("Successfully sent! Response received: " .. payload.message)
		end, function ()
		    print("Message could not be sent")
		end, function ()
		    shield.LED.flash("green")
		end)
    end
    num_code = 0
end)

cord.enter_loop()
