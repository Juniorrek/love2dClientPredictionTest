local PlayerLogic = require("multiplayer.shared.playerLogic")
local enet = require("enet")
local serpent = require("multiplayer.libraries.serpent")

local Server = {
    loaded = false,
    tickRate = 1/60
}

function Server.load()
    Server.host = enet.host_create("localhost:6789")
    Server.accumulator = 0
    Server.players = {}

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
                    local nextInput = #Server.players[data.playerId].inputQueue
                    Server.players[data.playerId].inputQueue[nextInput+1] = data.input
                end 
            end
        elseif event.type == "connect" then
            local playerServer = {
                player = PlayerLogic.new(),
                inputQueue = {},
                lastProcessedInput = 0,
                peer = event.peer
            }

            Server.players[playerServer.player.id] = playerServer

            event.peer:send(serpent.dump({
                type = "initial",
                player = playerServer.player:dump()
            }))

            print(event.peer, "connected.")
        elseif event.type == "disconnect" then
            print(event.peer, "disconnected.")
        end
        event = Server.host:service(0)
    end
end

function Server.fixedUpdate()
    -- Proccess Inputs and Simulate    
    for k, playerServer in pairs(Server.players) do
        for i = 1, #playerServer.inputQueue do
            local input = playerServer.inputQueue[i]
            playerServer.player.desiredDirection = input.desiredDirection
            playerServer.lastProcessedInput = input.seq
            --playerServer.player:update() -- change to simulation tick
        end
        playerServer.inputQueue = {}

        -- ??Drawback of updating simulation state within fixed tick rate insted update loop??
        playerServer.player:update()
        --one step per  tick instead per input queued
    end
        
    for k, playerServer in pairs(Server.players) do
        playerServer.peer:send(serpent.dump({
            type = "update",
            player = playerServer.player:dump(),
            lastProcessedInput = playerServer.lastProcessedInput
        }))
    end
end

function Server.update(dt)
    if Server.loaded then
        -- Poll network
        Server.pollNetwork()

        -- Fixed updates & Broadcast snapshots
        Server.accumulator = Server.accumulator + dt
        while Server.accumulator >= Server.tickRate do
            Server.accumulator = Server.accumulator - Server.tickRate
            Server.fixedUpdate()
        end
    end
end

return Server