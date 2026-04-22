local PlayerLogic = require("multiplayer.shared.playerLogic")
local enet = require("enet")
local serpent = require("multiplayer.libraries.serpent")

local Server = {
    loaded = false
}

function Server.load()
    Server.host = enet.host_create("localhost:6789")
    Server.accumulator = 0
    Server.players = {}
    Server.peers = {}

    Server.loaded = true
end

function Server.pollNetwork()
    local event = Server.host:service(0)
    while event do
        if event.type == "receive" then
            --print("Message arrived on server: ", event.data, event.peer)
            local ok, data = serpent.load(event.data)

            if ok then     
                if data.type == "input" then
                    Server.players[data.playerId].desiredDirection = data.desiredDirection
                end 
            end
        elseif event.type == "connect" then
            local player = PlayerLogic.new()
            Server.players[player.id] = player
            Server.peers[player.id] = event.peer

            event.peer:send(serpent.dump({
                type = "initial",
                player = player:dump()
            }))

            print(event.peer, "connected.")
        elseif event.type == "disconnect" then
            print(event.peer, "disconnected.")
        end
        event = Server.host:service(0)
    end
end

function Server.fixedUpdate(dt)
    -- Simulate    
    for k, player in pairs(Server.players) do
        -- ??Drawback of updating simulation state within fixed tick rate insted update loop??
        player:update(dt)
    end
        
    for k, player in pairs(Server.players) do
        Server.peers[k]:send(serpent.dump({
            type = "update",
            player = player:dump()
        }))
    end
end

function Server.update(dt)
    if Server.loaded then
        -- Poll network
        Server.pollNetwork()

        -- Fixed updates & Broadcast snapshots
        Server.accumulator = Server.accumulator + dt
        while Server.accumulator >= 1 / 60 do
            Server.accumulator = Server.accumulator - 1 / 60
            Server.fixedUpdate(1 / 60)
        end
    end
end

return Server