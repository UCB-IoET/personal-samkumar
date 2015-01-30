shield = require "starter"
-- cord = require "cord"
math = require "math"

-- seed with current time
math.randomseed(storm.os.now(storm.os.SHIFT_0))
shield.LED.start()
shield.Buzz.start()

function generate(length)
   local song = {}
   for i=1,length do
      song[i] = math.random(3)
   end
   return song
end

-- song = generate(3)

-- for i=1,3 do
--    print(song[i])
-- end

function buzz(note)
   shield.Buzz.go(note)
   storm.os.invokeLater(10 * storm.os.MILLISECOND, function() shield.Buzz.stop() end)
end

local note_to_color = {[1]="blue", [2]="green", [3]="red"}

-- Wrapper around 
function flash(note)
   shield.LED.flash(note_to_color[note], 10)
end

-- Plays a note by buzzing and flashing
function play_note(note)
   buzz(note)
   flash(note)
end

--------------------------------------------
local song = {}

song.flash = flash
song.play_note = play_note
song.generate = generate
return song
