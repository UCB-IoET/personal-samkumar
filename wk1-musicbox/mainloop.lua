shield = require "starter"
song = require "song"
buttons = {[1] = "right", [2] = "middle", [3] = "left"}
local mysong = nil
local next_note = 1 -- the index of the note we expect the user to press next
local correct = true
local button_handlers = {}
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
        -- print("Canceling watchers")
        -- for i = 1, 3 do
        --     storm.io.cancel_watch(button_handlers[i][0])
        --     if button_handlers[i][1] ~= nil then
        --         storm.os.cancel(button_handlers[i][1])
        --     end
        -- end
        print("Checking state")
        if correct then
            -- song.play(mysong)
            print("Won")
            print("Next length"..(length + 1))
            playmusicbox(length + 1)
        else
            print("Loss level"..(length))
            print("Try Again")
            playmusicbox(length)
        end
    end
end

function playmusicbox(length)
    print("Playing level length "..length)
    mysong = song.generate(length)
    song.play(mysong)
    next_note = 1
    correct = true
    -- print("set up handlers")
    print(mysong[1])
    -- while next_note <= #mysong do
    --     -- cord.yield()
    --     cord.await(storm.os.invokeLater, storm.os.MILLISECOND * 250)
    --     -- print("yielding")
    -- end
    -- print("got past")
end

for i = 1, 3 do
    button_handlers[i] = shield.Button.whenever_gap(buttons[i], "FALLING", function ()
        -- print("pressed")
        eval_press(i)
    end)
end

cord.new(function ()
    song.setup()
    -- while true do
    --     playmusicbox(4)
    --     cord.await(storm.os.invokeLater, 2 * storm.os.SECOND)
    -- end
    playmusicbox(4)
    print("done")
end)


cord.enter_loop()
