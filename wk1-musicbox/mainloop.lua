shield = require "starter"
song = require "song"
buttons = {[1] = "right", [2] = "middle", [3] = "left"}
local mysong = nil
local next_note = 1 -- the index of the note we expect the user to press next
local correct = true
local game_in_progress = true
local length = 4
local eval_press = function (note)
    local expected_note = mysong[next_note]
    if note == expected_note then
        -- print("you played right")
        cord.new(function() 
          song.play_note(note)
        end)
        next_note = next_note + 1
        print(mysong[next_note])
    else
        print("You played wrong")
        correct = false
        next_note = #mysong + 1
    end
    if next_note == #mysong + 1 then
        if correct then
            -- song.play(mysong)
            print("Won")
            length = length + 1
        else
            print("You lost")
            print("Try again")
        end
        print("Starting new game: length "..length)
        game_in_progress = false
    end
end

function playmusicbox(length)
    print("Playing level length "..length)
    mysong = song.generate(length)
    song.play(mysong)
    next_note = 1
    correct = true
    print(mysong[1])
end

for i = 1, 3 do
    shield.Button.whenever_gap(buttons[i], "FALLING", function ()
        eval_press(i)
    end)
end

song.setup()
cord.new(function ()
    while true do
        game_in_progress = true
        cord.new(function () playmusicbox(length) end)
        while game_in_progress do
            cord.yield()
        end
    end
end)


cord.enter_loop()
