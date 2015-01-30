--shield = require "starter"
song = require "song"
buttons = {[1] = "right", [2] = "middle", [3] = "left"}
function playmusicbox(length)
    local mysong = song.generate(length)
    song.play(mysong)
    local next_note = 1 -- the index of the note we expect the user to press next
    local correct = true
    local eval_press = function (note)
        local expected_note = mysong[next_note]
        if note == expected_note then
            cord.new(function ()
                song.play_note(note)
            end)
            next_note = next_note + 1
        else
            print("You played wrong")
            correct = false
            next_note = #mysong + 1
        end
    end
    button_handlers = {}
    for i = 1, 3 do
        button_handlers[i] = shield.Button.whenever_gap(buttons[i], "FALLING", function ()
            eval_press(i)
        end)
    end
    print("set up handlers")
    print(mysong[1])
    while next_note <= #mysong do
        cord.yield()
    end
    print("got past")
    for i = 1, 3 do
        storm.io.watch_cancel(button_handlers[i][0])
        if button_handlers[i][1] ~= nil then
            storm.os.cancel(button_handlers[i][1])
        end
    end
    if correct then
        song.play(mysong)
    end
    return correct
end

cord.new(function ()
    print("started")
    song.setup()
    while true do
        playmusicbox(4)
        cord.await(storm.os.invokeLater, 2 * storm.os.SECOND)
    end
end)

cord.enter_loop()
