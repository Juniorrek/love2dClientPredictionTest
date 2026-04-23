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
    elseif key == "f5" then
        Client.prediction = not Client.prediction
    elseif key == "f6" then
        Client.reconciliation = not Client.reconciliation
    elseif key == "f7" then
        if Client.tickRate == 1/60 then
            Client.tickRate = 1 / 6
        else
            Client.tickRate = 1 / 60
        end
    elseif key == "f8" then
        if Server.tickRate == 1/60 then
            Server.tickRate = 1 / 6
        else
            Server.tickRate = 1 / 60
        end
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
        
        love.graphics.print("(F7 - Client Tickrate [" .. (1/(Client.tickRate)) .. "/s])", 60, 15)
        love.graphics.print("(F8 - Server Tickrate [" .. (1/(Server.tickRate)) .. "/s])", 225, 15)
    end
end

return Game