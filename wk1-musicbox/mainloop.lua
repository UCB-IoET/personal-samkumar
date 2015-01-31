shield = require "starter"
song = require "song"
buttons = {[1] = "right", [2] = "middle", [3] = "left"}
local mysong = {}
local next_note = 1 -- the index of the note we expect the user to press next
local correct = true
local game_in_progress = true
local length = 4
local eval_press = function (note)
    local expected_note = mysong[next_note]
    if note == expected_note then
        cord.new(function() 
          song.play_note(note)
        end)
        next_note = next_note + 1
        print(mysong[next_note])
    else
        correct = false
        next_note = #mysong + 1
    end
    if next_note == #mysong + 1 then
        if correct then
            print("Won")
            length = length + 1
        else
            print("Lost")
        end
        print("Starting new game: length "..length)
        game_in_progress = false
    end
end

function playmusicbox(length)
    song.generate(length, mysong)
    song.play(mysong)
    next_note = 1
    correct = true
    print(mysong[1])
end

local i = 1
for i = 1, 3 do
    shield.Button.whenever_gap(buttons[i], "FALLING", function ()
        eval_press(i)
    end)
end

song.setup()
song.setup = nil
shield.Buzz.start = nil
shield.LED.start = nil
shield.Button.start = nil
cord.new(function ()
    while true do
        cord.await(storm.os.invokeLater, 5 * storm.os.SECOND)
        game_in_progress = true
        collectgarbage()
        cord.new(function () playmusicbox(length) end)
        while game_in_progress do
            cord.yield()
        end
    end
end)

cord.enter_loop()
