shield = require "starter"
song = require "song"

function playmusicbox(length)
    local mysong = song.generate(length)
    song.play(mysong)
    local next_note = 1 -- the index of the note we expect the user to press next
    local correct = true
    local eval_press = function (note)
        local expected_note = song[next_note]
        if note == expected_note then
            song.play_note(note)
            next_note = next_note + 1
        else
            print("You played the wrong")
            correct = false
            next_note = #song
        end
    end
    shield.Button.start()
    button_handlers = {}
    button_handlers[1] = shield.Button.whenever_gap("left", "FALLING", function ()
        eval_press(1)
    end)
    button_handlers[2] = shield.Button.whenever_gap("middle", "FALLING", function ()
        eval_press(2)
    end)
    button_handlers[3] = shield.Button.whenever_gap("right", "FALLING", function ()
        eval_press(3)
    end)
    while next_note < #song do
        cord.yield()
    end
    local i = 1
    while i <= 3 do
        storm.io.watch_cancel(button_handlers[i][0])
        if button_handlers[i][1] ~= nil then
            storm.os.cancel(button_handlers[i][1])
        end
        i = i + 1
    end
    if correct then
        song.play(mysong)
    end
    return correct
end
