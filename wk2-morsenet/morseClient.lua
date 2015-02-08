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
local curr_letter = morse.MorseToAlpha

shield.LED.start()

print("Begin Morse Coding")

shield.Button.start()


shield.Button.whenever_gap(3, "FALLING", function() 
                           curr_letter = curr_letter[false]
                           if curr_letter == nil then
                               curr_letter = morse.MorseToAlpha
                           end
                       end)

shield.Button.whenever_gap(2, "FALLING", function() 
                           curr_letter = curr_letter[true]
                           if curr_letter == nil then
                               curr_letter = morse.MorseToAlpha
                           end
                       end)
                           
function success(payload, address, port)
    shield.LED.flash("red")
    print("Successfully sent!")
end

function failure()
    print("Message could not be sent")
end

function try()
    shield.LED.flash("green")
end

shield.Button.whenever_gap(1, "FALLING", function()
    if curr_letter["end"] ~= nil then
        local letter = curr_letter['end']
        print("LETTER: "..letter)
        collectgarbage()
        shield.LED.flash("blue")
        nqcl:sendMessage({["message"] = letter}, "ff02::1", 50004, success, failure, try)
    end
    curr_letter = morse.MorseToAlpha
end)

cord.enter_loop()
