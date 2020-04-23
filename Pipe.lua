Class = require 'class'

Pipe = Class{}

--why make it outside of init class coz unlike bird there are gonna be more than one pipe
--unlike Bird.lua where evry time a new bird image is allocated in memory
local PIPE_IMAGE = love.graphics.newImage('pipe.png')
PIPE_SCROLL = -60 --same as scroll of ground

--global access
PIPE_HEIGHT = PIPE_IMAGE:getHeight()
PIPE_WIDTH = PIPE_IMAGE:getWidth()

function Pipe:init(orientation, y)
    self.x = VIRTUAL_WIDTH --right edge on screen as soon as pipe gets initialized it's invisible
    self.y = y--math.random(VIRTUAL_HEIGHT / 4, VIRTUAL_HEIGHT - 10)

    self.orientation = orientation
    
    self.width = PIPE_IMAGE:getWidth()
    self.height = PIPE_IMAGE:getHeight()
end

function Pipe:update(dt)
    self.x = self.x + PIPE_SCROLL * dt
end

function Pipe:render()
    local mirror = 1
    
    love.graphics.draw(PIPE_IMAGE, self.x, 
        (self.orientation == 'top' and self.y + PIPE_HEIGHT or self.y),
        0, 1, self.orientation == 'top' and -1 or 1) --yaxis scale if -1 then mirrored
end