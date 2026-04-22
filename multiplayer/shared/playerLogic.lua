local PlayerLogic = {
    counter = 0
}

function PlayerLogic.playerFromInitial(id, x, y, speed)
end

function PlayerLogic.nextId()
    PlayerLogic.counter = PlayerLogic.counter + 1
    return PlayerLogic.counter
end

--used only by server, so not "shared"
function PlayerLogic.new(id, x, y, speed)
    id = id or PlayerLogic.nextId()
    x = x or 4
    y = y or 4
    speed = speed or 2

    local spritesheet = love.graphics.newImage("assets/link_outfit1.png")
    local player = {
        id = id,
        position = {
            draw = {
                x = (x-1) * 32,
                y = (y-1) * 32
            },
            grid = {
                x = x,
                y = y
            }
        },
        speed = speed,
        targetPosition = {
            grid = {
                x = x,
                y = y
            }
        },
        moving = false,
        facing = "down",
        desiredDirection = nil,
        spritesheet = spritesheet,
        quad = love.graphics.newQuad(110, 270, 32, 32, spritesheet:getDimensions())
    }

    function player:dump()
        return {
            id = self.id,
            position = {
                draw = {
                    x = self.position.draw.x,
                    y = self.position.draw.y
                },
                grid = {
                    x = self.position.grid.x,
                    y = self.position.grid.y
                }
            },
            speed = self.speed,
            targetPosition = {
                grid = {
                    x = self.targetPosition.grid.x,
                    y = self.targetPosition.grid.y
                }
            },
            moving = self.moving,
            facing = self.facing,
            desiredDirection = self.desiredDirection
            --spritesheet = spritesheet,
            --quad = love.graphics.newQuad(110, 270, 32, 32, spritesheet:getDimensions())
        }
    end

    function player:draw()
        love.graphics.draw(
            self.spritesheet,
            self.quad,
            self.position.draw.x,
            self.position.draw.y
        )
    end

    return player
end

return PlayerLogic