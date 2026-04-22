local PlayerLogic = require("multiplayer.shared.playerLogic")
local enet = require("enet")
local serpent = require("multiplayer.libraries.serpent")

local Client = {
    loaded = false
}

function Client.load()
    Client.host = enet.host_create()
    Client.server = Client.host:connect("localhost:6789")

    Client.loaded = true
    print("Connecting on", Client.server)
end

function Client.pollNetwork()
    local event = Client.host:service(0)
    while event do
        if event.type == "receive" then
            print("Message arrived on client: ", event.data)
            local ok, data = serpent.load(event.data)

            if ok then     
                if data.type == "initial" then
                    Client.player = PlayerLogic.new(
                        data.player.id,
                        data.player.position.grid.x,
                        data.player.position.grid.y,
                        data.player.speed
                    )
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

function Client.update(dt)
    if Client.loaded then
        Client.pollNetwork()
    end
end


function Client.draw()
    if Client.player then
        Client.player:draw()
    end
end

return Client