require("cord")
require("storm")
shield = require("starter") -- interfaces for resources on starter shield
morse = require("morse") -- interfaces for resources on starter shield

local morse_code = {}
local num_code = 0
local press_threshold = 40000
local start_time = 0
local end_time = 0

local first_edge = 0

print("Begin Morse Coding")

shield.Button.start()
morse.computeMorseToAlpha()
                                
shield.Button.whenever_gap(3, "CHANGE", function()
                               if (first_edge == 0) then
                                 print("F")
				 start_time = storm.os.now(storm.os.SHIFT_0)
                                 num_code = num_code + 1
                                 print("FALLING: "..start_time)
                                 first_edge = 1
                               else
                                 print("R")
                                 end_time = storm.os.now(storm.os.SHIFT_0)
                                 press_time = end_time - start_time
                                 print("RISING: "..end_time)
                                 if (press_time > press_threshold) then
                                    morse_code[num_code] = true
                                 else
                                    morse_code[num_code] = false
                                 end
                                  first_edge = 0
                               end
				end)

shield.Button.whenever_gap(2, "FALLING", function()
				local curr_table = morse.MorseToAlpha
                                for i = 1, num_code do
                                    curr_table = curr_table[morse_code[i]]
                                end
                                local letter = curr_table['end']
                                num_code = 0
                                print("LETTER: "..letter)
                                end)

cord.enter_loop()
