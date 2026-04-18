local Player = require("singleplayer.player")

local Game = {}

function Game.load()
    Game.player = Player.new()
end

function Game.update(dt)
    Game.player:update(dt)
end


function Game.draw()
    Game.player:draw()
end
return Game