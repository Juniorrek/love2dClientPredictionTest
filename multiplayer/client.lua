local PlayerLogic = require("multiplayer.shared.playerLogic")
local enet = require("enet")

local Client = {
    loaded = false
}

function Client.load()
    Client.host = enet.host_create()
    Client.server = Client.host:connect("localhost:6789")

    Client.loaded = true
    print(Client.server)
end

function Client.pollNetwork()
    local event = Client.host:service(0)
    while event do
        if event.type == "receive" then
            --print("Message: ", event.data, event.peer)
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
end

return Client