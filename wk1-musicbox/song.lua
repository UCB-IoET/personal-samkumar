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

-- function buzz_length(note, length)
--    Buzz.go(note)
--    cord.await(storm.os.invokeLater, length * storm.os.millisecond)
--    Buzz.stop()
-- end

local note_to_color = {[1]="blue", [2]="green", [3]="red"}

-- function flash_length(note, length)
--    Led.flash(note_to_color[note], length)
-- end

-- Wrapper around 
function flash(note)
   shield.LED.flash(note_to_color[note], 10)
end

-- Plays a note by buzzing and flashing
function play_note(note)
   buzz(note)
   flash(note)
end

-- function play_note_length(note, length)
--    flash_length(note, length)
--    buzz_length(note, length)
-- end

function play(s, index)
   index = index or 1
   play_note(s[index])
   if index < #s then
      storm.os.invokeLater(50 * storm.os.MILLISECOND, function() play(s, index + 1) end)
   end
end

-- function play_song_var_length(s, length_arr, index)
--    index = index or 1
--    play_note_length(s[index])
--    if index < #s then
--       storm.os.invokeLater(50 * storm.os.MILLISECOND, function() play_song_var_length(s, length_arr, index + 1) end)
--    end
-- end

--------------------------------------------
-- local song = {}

-- song.flash = flash
-- song.play_note = play_note
-- song.generate = generate
-- song.play = play
-- return song

while true do
   local s = generate(5)
   play(s)
end
