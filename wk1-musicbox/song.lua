require("storm")
require("cord")
require("math")

math.randomseed(os.time())

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
   Buzz.go(note)
   cord.await(storm.os.invokeLater, 10 * storm.os.millisecond)
   Buzz.stop()
end

local note_to_color = {[1]="blue", [2]="green", [3]="red"}

-- Wrapper around 
function flash(note)
   Led.flash(note_to_color[note], 10)
end

-- Plays a note by buzzing and flashing
function play_note(note)
   buzz(note)
   flash(note)
end
