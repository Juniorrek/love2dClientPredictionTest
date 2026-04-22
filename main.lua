local Singleplayer = require("singleplayer.game")
local Multiplayer = require("multiplayer.game")

if arg[2] == "debug" then
    require("lldebugger").start()
end

local game = nil
function love.load()
    love.graphics.setBackgroundColor(0, 0.4, 0.7)
end

local firstInstructions = true
local secondInstructions = false
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    
    if firstInstructions then
        if key == "f1" then
            firstInstructions = false

            Singleplayer.load()
            game = Singleplayer
        elseif key == "f2" then
            firstInstructions = false
            secondInstructions = true

            game = Multiplayer
        end
    elseif secondInstructions then
        if key == "f1" or key == "f2" then
            secondInstructions = false

            Multiplayer.handleKeypressed(key)
        end
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
local function drawInstructions()
    if firstInstructions then
        love.graphics.print("F1 - Singleplayer", 100, 100, 0, 3, 3)
        love.graphics.print("F2 - Multiplayer", 100, 200, 0, 3, 3)
    elseif secondInstructions then
        love.graphics.print("F1 - Server + Client", 100, 100, 0, 3, 3)
        love.graphics.print("F2 - Only client", 100, 200, 0, 3, 3)
    else
        if game.player then
            love.graphics.print("Singleplayer", 0, 0, 0, 2, 2)
        elseif game.server then
            love.graphics.print("Server + Client\nNormal - Client prediction + dumb reconciliation\nRed - Server state\nBlue - Client prediction without reconciliation", 0, 0, 0, 2, 2)
        else 
            love.graphics.print("Only client", 0, 0, 0, 2, 2)
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
    drawInstructions()
end