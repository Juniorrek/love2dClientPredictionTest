local Singleplayer = require("singleplayer.game")

if arg[2] == "debug" then
    require("lldebugger").start()
end

local game = nil
function love.load()
    love.graphics.setBackgroundColor(0, 0.4, 0.7)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    
    if key == "f1" then
        Singleplayer.load()
        game = Singleplayer
    end
end

function love.update(dt)
    if game then
        game.update(dt)
    end
end

local tileSpritesheet = love.graphics.newImage("assets/otsp_tiles_01.png")
local tileQuads = {
    love.graphics.newQuad(384, 544, 32, 32, tileSpritesheet:getDimensions()),
    love.graphics.newQuad(448, 544, 32, 32, tileSpritesheet:getDimensions()),
    love.graphics.newQuad(480, 544, 32, 32, tileSpritesheet:getDimensions()),
    love.graphics.newQuad(416, 544, 32, 32, tileSpritesheet:getDimensions())
}
local function drawGrid()
    local i = 1
    for y = 1, 9 do
        for x = 1, 12 do
            love.graphics.draw(
                tileSpritesheet,
                tileQuads[i],
                (x-1)*32,
                (y-1)*32
            )
            i = i + 1
            if i > 4 then
                i = 1
            end
        end
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(2, 2)
    drawGrid()
    if game then
        game.draw()
    end
    love.graphics.pop() 
end