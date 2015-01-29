require("storm")
require("cord")

function buzz(note)
   Buzz.go(note)
   cord.await(storm.os.invokeLater, 10 * storm.os.millisecond)
   Buzz.stop()
end

local note_to_color = {[1]="blue", [2]="green", [3]="red"}

function flash(note)
   Led.flash(note_to_color[note], 10)
end

function play_note(note)
   buzz(note)
   flash(note)
end
