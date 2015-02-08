----------------------------------------------
-- Morse Code module
----------------------------------------------

require("storm") -- libraries for interfacing with the board and kernel
require("cord") -- scheduler / fiber library
----------------------------------------------
-- Morse code module
----------------------------------------------
local morse = {}

Alphabet = {
   ["A"] = {false,true},
   ["B"] = {true,false,false,false},
   ["C"] = {true,false,true,false},
   ["D"] = {true,false,false},
   ["E"] = {false},
   ["F"] = {false,false,true,false},
   ["G"] = {true,true,false},
   ["H"] = {false,false,false,false},
   ["I"] = {false,false},
   ["J"] = {false,true,true,true},
   ["K"] = {true,false,true},
   ["L"] = {false,true,false,false},
   ["M"] = {true,true},
   ["N"] = {true,false},
   ["O"] = {true,true,true},
   ["P"] = {false,true,true,false},
   ["Q"] = {true,true,false,true},
   ["R"] = {false,true,false},
   ["S"] = {false,false,false},
   ["T"] = {true},
   ['U'] = {false,false,true},
   ['V'] = {false,false,false,true},
   ['W'] = {false,true,true},
   ['X'] = {true,false,false,true},
   ['Y'] = {true,false,true,true},
   ['Z'] = {true,true,false,false},
   [" "] = {nil},
}

local MorseToAlpha = {}
morse.computeMorseToAlpha = function ()
    local i
    local curr_table
    for letter, code in pairs(Alphabet) do
        curr_table = MorseToAlpha
        for i = 1, #code do
            if curr_table[code[i]] == nil then
                curr_table[code[i]] = {}
            end
            curr_table = curr_table[code[i]]
        end
        curr_table['end'] = letter
    end
end

morse.MorseToAlpha = MorseToAlpha

return morse
