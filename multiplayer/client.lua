local PlayerLogic = require("multiplayer.shared.playerLogic")
local enet = require("enet")
local serpent = require("multiplayer.libraries.serpent")
local inputBuffer = require("multiplayer.client.inputBuffer")

local Client = {
    loaded = false,
    tickRate = 1/60
}

function Client.load()
    Client.host = enet.host_create()
    Client.server = Client.host:connect("localhost:6789")
    Client.accumulator = 0
    Client.prediction = true
    Client.reconciliation = true

    Client.loaded = true
    print("Connecting on", Client.server)
end

function Client.applyAuthoritativeState(player, auth)
    player.position.grid.x = auth.position.grid.x
    player.position.grid.y = auth.position.grid.y
    player.position.draw.x = auth.position.draw.x
    player.position.draw.y = auth.position.draw.y
    player.targetPosition.grid.x = auth.targetPosition.grid.x
    player.targetPosition.grid.y = auth.targetPosition.grid.y
    player.moving = auth.moving
    player.facing = auth.facing
    player.desiredDirection = auth.desiredDirection
end

function Client.pollNetwork()
    local event = Client.host:service(0)
    while event do
        if event.type == "receive" then
            --print("Message arrived on client: ", event.data)
            local ok, data = serpent.load(event.data)

            if ok then     
                if data.type == "initial" then
                    --NORMAL: Client predicted state to be reconcilated with the server state
                    Client.player = PlayerLogic.new(
                        data.player.id,
                        data.player.position.grid.x,
                        data.player.position.grid.y,
                        data.player.speed
                    )

                    --RED: Server state
                    Client.serverPlayerState = PlayerLogic.new(
                        data.player.id,
                        data.player.position.grid.x,
                        data.player.position.grid.y,
                        data.player.speed
                    )
                elseif data.type == "update" then
                    if Client.reconciliation then
                    -- RECONCILIATION
                    -- 1 Apply authoritative state
                    Client.applyAuthoritativeState(Client.player, data.player)
                    -- 2 Remove acknowledged input
                    inputBuffer.removeAcknowledged(data.lastProcessedInput)
                    -- 3 Replay remaining inputs
                        for i = 1, #inputBuffer.pending do
                            local input = inputBuffer.pending[i]
                            Client.player.desiredDirection = input.desiredDirection
                            Client.player:update()
                        end
                    end
                    
                    Client.applyAuthoritativeState(Client.serverPlayerState, data.player)
                end  
            end
        elseif event.type == "connect" then
            --print(event.peer, "connected.")
        elseif event.type == "disconnect" then
            --print(event.peer, "disconnected.")
        end
        event = Client.host:service(0)
    end
end

function Client.handleInput(player)
    player.desiredDirection = nil
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        player.desiredDirection = "up"
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        player.desiredDirection = "left"
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        player.desiredDirection = "down"
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        player.desiredDirection = "right"
    end
end

function Client.fixedUpdate()
    Client.handleInput(Client.player)

    inputBuffer.nextSeq = inputBuffer.nextSeq + 1
    local input = {
        seq = inputBuffer.nextSeq,
        desiredDirection = Client.player.desiredDirection
    }
    inputBuffer.push(input)
    local inputPacket =  {
        type = "input",
        playerId = Client.player.id,
        input = input
    }
    Client.server:send(serpent.dump(inputPacket))

    if Client.prediction then
        Client.player:update()
    end
end

function Client.update(dt)
    if Client.loaded then
        Client.pollNetwork()
    end

    if Client.player then
        Client.accumulator = Client.accumulator + dt
        while Client.accumulator >= Client.tickRate do
            Client.accumulator = Client.accumulator - Client.tickRate
            Client.fixedUpdate()
        end
    end
end

function Client.draw()
    if Client.player then
        love.graphics.setColor(1, 0, 0)
        Client.serverPlayerState:draw()
        love.graphics.setColor(1, 1, 1)
        
        Client.player:draw()
        
        love.graphics.print("(F5 - Prediction [" .. (Client.prediction and "ON" or "OFF") .. "])", 100, 0)
        love.graphics.print("(F6 - Reconciliation [" .. (Client.reconciliation and "ON" or "OFF") .. "])", 235, 0)

        love.graphics.print("Client (x = " .. Client.player.position.grid.x .. ", y = " ..  Client.player.position.grid.y .. " | dx = " .. Client.player.position.draw.x .. ", dy = " .. Client.player.position.draw.y .. ")\n" ..
        "Server (x = " .. Client.serverPlayerState.position.grid.x .. ", y = " ..  Client.serverPlayerState.position.grid.y .. " | dx = " .. Client.serverPlayerState.position.draw.x .. ", dy = " .. Client.serverPlayerState.position.draw.y .. ")", 0, 257)
    end
end

return Client