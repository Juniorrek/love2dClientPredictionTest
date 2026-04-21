local PlayerLogic = {
    counter = 0
}

function PlayerLogic.nextId()
    PlayerLogic.counter = PlayerLogic.counter + 1
    return PlayerLogic.counter
end

--used only by server, so not "shared"
function PlayerLogic.new()
    local spritesheet = love.graphics.newImage("assets/link_outfit1.png")
    local player = {

        position = {
            id = PlayerLogic.nextId(),
            draw = {
                x = (4-1) * 32,
                y = (4-1) * 32
            },
            grid = {
                x = 4,
                y = 4
            }
        },
        speed = 2,
        targetPosition = {
            grid = {
                x = 4,
                y = 4
            }
        },
        moving = false,
        facing = "down",
        desiredDirection = nil,
        spritesheet = spritesheet,
        quad = love.graphics.newQuad(110, 270, 32, 32, spritesheet:getDimensions())
    }

    return player
end

return PlayerLogic