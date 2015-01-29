require("math")
math.randomseed(os.time())

function generate_song(length)
   local song = {}
   for i=1,length do
      song[i] = math.random(3)
   end
   return song
end

song = generate_song(3)
for i=1,3 do
   print(song[i])
end
