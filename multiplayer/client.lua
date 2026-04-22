local PlayerLogic = require("multiplayer.shared.playerLogic")
local enet = require("enet")
local serpent = require("multiplayer.libraries.serpent")

local Client = {
    loaded = false
}

function Client.load()
    Client.host = enet.host_create()
    Client.server = Client.host:connect("localhost:6789")
    Client.accumulator = 0

    Client.loaded = true
    print("Connecting on", Client.server)
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
                    --BLUE: Client predicted state without reconciliation
                    Client.clientPredictedPlayerState = PlayerLogic.new(
                        data.player.id,
                        data.player.position.grid.x,
                        data.player.position.grid.y,
                        data.player.speed
                    )
                elseif data.type == "update" then
                    Client.player.position.grid.x = data.player.position.grid.x
                    Client.player.position.grid.y = data.player.position.grid.y
                    Client.player.position.draw.x = data.player.position.draw.x
                    Client.player.position.draw.y = data.player.position.draw.y
                    Client.player.targetPosition.grid.x = data.player.targetPosition.grid.x
                    Client.player.targetPosition.grid.y = data.player.targetPosition.grid.y
                    Client.player.moving = data.player.moving
                    Client.player.facing = data.player.facing
                    Client.player.desiredDirection = data.player.desiredDirection
                    
                    Client.serverPlayerState.position.grid.x = data.player.position.grid.x
                    Client.serverPlayerState.position.grid.y = data.player.position.grid.y
                    Client.serverPlayerState.position.draw.x = data.player.position.draw.x
                    Client.serverPlayerState.position.draw.y = data.player.position.draw.y
                    Client.serverPlayerState.targetPosition.grid.x = data.player.targetPosition.grid.x
                    Client.serverPlayerState.targetPosition.grid.y = data.player.targetPosition.grid.y
                    Client.serverPlayerState.moving = data.player.moving
                    Client.serverPlayerState.facing = data.player.facing
                    Client.serverPlayerState.desiredDirection = data.player.desiredDirection
                    --print("end update")
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
    Client.server:send(serpent.dump({
        type = "input",
        playerId = Client.player.id,
        desiredDirection = Client.player.desiredDirection
    }))
end

local CLIENT_TICKRATE = 1/60
function Client.update(dt)
    if Client.loaded then
        Client.pollNetwork()
    end

    if Client.player then
        Client.handleInput(Client.player)
        Client.handleInput(Client.clientPredictedPlayerState)

        Client.player:update(dt)
        Client.clientPredictedPlayerState:update(dt)
        --print("end prediction")

        Client.accumulator = Client.accumulator + dt
        while Client.accumulator >= CLIENT_TICKRATE do
            Client.accumulator = Client.accumulator - CLIENT_TICKRATE
            Client.fixedUpdate()
        end
    end
end


function Client.draw()
    if Client.player then
        love.graphics.setColor(1, 0, 0)
        Client.serverPlayerState:draw()
        love.graphics.setColor(0, 0, 1)
        Client.clientPredictedPlayerState:draw()
        love.graphics.setColor(1, 1, 1)

        
        Client.player:draw()

        
        love.graphics.print("Player (x = " .. Client.player.position.grid.x .. ", y = " ..  Client.player.position.grid.y .. " | dx = " .. Client.player.position.draw.x .. ", dy = " .. Client.player.position.draw.y .. ")\n" ..
        "Red (x = " .. Client.serverPlayerState.position.grid.x .. ", y = " ..  Client.serverPlayerState.position.grid.y .. " | dx = " .. Client.serverPlayerState.position.draw.x .. ", dy = " .. Client.serverPlayerState.position.draw.y .. ")\n" ..
        "Blue (x = " .. Client.clientPredictedPlayerState.position.grid.x .. ", y = " ..  Client.clientPredictedPlayerState.position.grid.y .. " | dx = " .. Client.clientPredictedPlayerState.position.draw.x .. ", dy = " .. Client.clientPredictedPlayerState.position.draw.y .. ")", 0, 225)
    end
end

return Client