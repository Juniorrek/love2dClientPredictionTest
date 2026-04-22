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

    function player:tryMoveByDesiredDirection() 
        local desiredGridX = self.position.grid.x
        local desiredGridY = self.position.grid.y
        if self.desiredDirection == "up" then 
            desiredGridY = desiredGridY - 1
        elseif self.desiredDirection == "left" then
            desiredGridX = desiredGridX - 1
        elseif self.desiredDirection == "down" then
            desiredGridY = desiredGridY + 1
        elseif self.desiredDirection == "right" then
            desiredGridX = desiredGridX + 1
        end 

        self.facing = self.desiredDirection
        --if map.movableTile(x, y) and Entities.isFreeAt(x, y) then 
            self.moving = true 
            self.targetPosition.grid.x = desiredGridX
            self.targetPosition.grid.y = desiredGridY
        --[[ else
            self.moving = false
            self.animationFrame = 1
            self.animationTimer = 0
        end ]]
    end

    function player:update(dt)
        if not self.moving and self.desiredDirection then 
            self:tryMoveByDesiredDirection() 
        end

        if self.moving then
            local move = self.speed * dt * 32
            local targetDrawX = (self.targetPosition.grid.x - 1) * 32
            local targetDrawY = (self.targetPosition.grid.y - 1) * 32
            if self.facing == "up" then 
                self.position.draw.y = math.max(self.position.draw.y - move, targetDrawY) 
            elseif self.facing == "left" then 
                self.position.draw.x = math.max(self.position.draw.x - move, targetDrawX) 
            elseif self.facing == "down" then 
                self.position.draw.y = math.min(self.position.draw.y + move, targetDrawY) 
            elseif self.facing == "right" then 
                self.position.draw.x = math.min(self.position.draw.x + move, targetDrawX) 
            end

            if self.position.draw.x == targetDrawX and self.position.draw.y == targetDrawY then
                self.position.grid.x = self.targetPosition.grid.x
                self.position.grid.y = self.targetPosition.grid.y
                if not self.desiredDirection then
                    self.moving = false
                    self.animationFrame = 1
                    self.animationTimer = 0
                else 
                    self:tryMoveByDesiredDirection() 
                end
            end
        end
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