shield = require "starter"
math = require "math"

-- seed with current time
math.randomseed(storm.os.now(storm.os.SHIFT_0))

shield.LED.start()
shield.Buzz.start()

function generate(length)
   local song = {}
   for i = 1, length do
      song[i] = math.random(3)
   end
   return song
end

local note_to_color = {[1]="blue", [2]="green", [3]="red"}
local note_to_period = {[1] = 1 * storm.os.MILLISECOND, [2] = 3 * storm.os.MILLISECOND, [3] = 7 * storm.os.MILLISECOND}

-- Plays a note by buzzing and flashing
function play_note(note)
   shield.Buzz.go(note_to_period[note])
   shield.LED.on(note_to_color[note])
   cord.await(storm.os.invokeLater, 500 * storm.os.MILLISECOND)
   shield.Buzz.stop()
   shield.LED.off(note_to_color[note])
end

function play(s)
   for i = 1, #s do
      play_note(s[i])
      cord.await(storm.os.invokeLater, 400 * storm.os.MILLISECOND)
   end
end

cord.new(function ()
    while true do
       local s = generate(5)
       play(s)
       cord.await(storm.os.invokeLater, storm.os.SECOND)
    end
end)

cord.enter_loop()
