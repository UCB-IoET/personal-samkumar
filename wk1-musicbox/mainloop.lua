shield = require "starter"
buttons = {[1] = "right", [2] = "middle", [3] = "left"}

function setup()
    -- seed with current time
    math.randomseed(storm.os.now(storm.os.SHIFT_0))

    shield.LED.start()
    shield.Buzz.start()
    shield.Button.start()
end

function generate(len, song)
   local i = 1
   for i = 1, len do
      song[i] = math.random(3)
   end
end

local note_to_color = {[1]="blue", [2]="green", [3]="red"}
local note_to_period = {[1] = 1 * storm.os.MILLISECOND, [2] = 3 * storm.os.MILLISECOND, [3] = 7 * storm.os.MILLISECOND}

local mysong = {}
local next_note = 1 -- the index of the note we expect the user to press next
local correct = true
local game_in_progress = true
local length = 4
local finish_game = nil
local continue_on = false
local eval_press = function (note)
    local expected_note = mysong[next_note]
    if note == expected_note then
        -- cord.new(function() 
        --   play_note(note)
        -- end)
        shield.Buzz.go(note_to_period[note])
        shield.LED.on(note_to_color[note])
        -- print("waiting")
        -- cord.await(storm.os.invokeLater, 500 * storm.os.MILLISECOND)
        storm.os.invokeLater(500 * storm.os.MILLISECOND, 
                             function () 
                                shield.Buzz.stop()
                                shield.LED.off(note_to_color[note])
                             end)
        -- print("finished waiting")
        next_note = next_note + 1
        print(mysong[next_note])
    else
        correct = false
        next_note = #mysong + 1
    end
    if next_note == #mysong + 1 then
        if correct then
            length = length + 1
            storm.os.invokeLater(storm.os.SECOND, function ()
                shield.LED.flash("green", 2000)
                shield.LED.flash("blue", 2000)
            end)
        else
            storm.os.invokeLater(storm.os.SECOND, function ()
                shield.Buzz.go(note_to_period[note])
                shield.LED.flash("red", 2000)
                shield.LED.flash("red2", 2000)
                storm.os.invokeLater(storm.os.MILLISECOND / 2, 
                                     function () 
                                        shield.Buzz.stop()
                                     end)
            end)
            -- print("Lost")
        end
        -- print("Starting new game: length "..length)
        -- finish_game()
        continue_on = true
    end
end

function playmusicbox(length, callback)
    print("hello")
    finish_game = callback
    generate(length, mysong)
    local i = 1
    for i = 1, #mysong do
       shield.Buzz.go(note_to_period[mysong[i]])
       shield.LED.on(note_to_color[mysong[i]])
       cord.await(storm.os.invokeLater, 500 * storm.os.MILLISECOND)
       shield.Buzz.stop()
       shield.LED.off(note_to_color[mysong[i]])
       cord.await(storm.os.invokeLater, 400 * storm.os.MILLISECOND)
    end
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

setup()
setup = nil
shield.Buzz.start = nil
shield.LED.start = nil
shield.Button.start = nil
cord.new(function() 
  while true do
    print("waiting 5 seconds")
    cord.await(storm.os.invokeLater, 5 * storm.os.SECOND)
    print("collecting garbage")
    collectgarbage()
    playmusicbox(length)
    continue_on = false
    while not continue_on do
       cord.yield()
    end
    -- cord.await(playmusicbox, length)
  end
end)

cord.enter_loop()
