local Server = require("multiplayer.server")
local Client = require("multiplayer.client")

local Game = {}

function Game.load()
end

function Game.handleKeypressed(key)
    if key == "f1" then
        Server.load()
        Client.load()

        Game.server = Server
        Game.client = Client
    elseif key == "f2" then
        --Client.load()

        --Game.client = Client
    end
end

function Game.update(dt)
    if Game.server then
        Game.server.update(dt)
    end

    if Game.client then
        Game.client.update(dt)
    end
end


function Game.draw()
    if Game.client then
        Game.client.draw()
    end
end

return Game