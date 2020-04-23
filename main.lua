---we will be using parallyx illusion i.e fence moves faster relative to mountain when observed by you from a moving car

push = require 'push';
require 'Bird'
--require 'Pipe'
require 'PipePair'
require 'StateMachine'
require 'states/BaseState'
require 'states/PlayState'
require 'states/ScoreState'
require 'states/TitleScreenState'
require 'states/CountdownState'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

--cant access this variable outside main.lua
local background = love.graphics.newImage('background.png')
local backgroundScroll = 0 --to keep track of scrolling

local ground = love.graphics.newImage('ground.png')
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60 --to enable parallyx background has to move faster than foreground

local BACKGROUND_LOOPING_POINT = 413
--local GROUND_LOOPING_POINT = 413

local bird = Bird()

local pipePairs = {}
--local pipes = {} --to keep track of pipes to be spawned

--GAP_HEIGHT gives space between pair pipe
local GAP_HEIGHT = 90

local spawnTimer = 0 --to spawn allocated memory to pipePair

local lastY = -PIPE_HEIGHT + math.random(80) + 20

local scrolling = true

function love.load()
    --setting filter to nearest neighbour filtering which avoids blurry nature 
    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    math.randomseed(os.time()) --making it initialise globally

    love.window.setTitle('Flap Bird')

    smallfont = love.graphics.newFont('font.ttf', 8)
    mediumfont = love.graphics.newFont('flappy.ttf', 14)
    flappyfont = love.graphics.newFont('flappy.ttf', 28)
    hugefont = love.graphics.newFont('flappy.ttf', 56)

    audio = {
        ['jump'] = love.audio.newSource('audio/jump.wav', 'static'),
        ['explode'] = love.audio.newSource('audio/explode.wav', 'static'),
        ['hurt'] = love.audio.newSource('audio/hurt.wav', 'static'),
        ['score'] = love.audio.newSource('audio/score.wav', 'static'),
        ['music'] = love.audio.newSource('audio/marios_way.mp3', 'static'),
    }

    audio['music']:setLooping(true)
    audio['music']:play()

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen= false,
        resizable = true
    })

    ---g used to indicate global
    gStateMachine = StateMachine{
        ['title'] = function ()
            return TitleScreenState()
        end,
        ['play'] = function ()
            return PlayState()
        end,
        ['score'] = function ()
            return ScoreState()
        end,
        ['countdown'] = function ()
            return CountdownState()
        end
    }
    --keep state as title state
    gStateMachine:change('title')

    --empty global table to store keyPresses for each frame
    --why we doing this we can direcly write key Press logic in key pressed function, the reason is we want to actually write logic in Bird.lua
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)

    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end
end

--we query the keysPressed table we created to see if on the last frame was a particular key pressed
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)

    --if scrolling then --commented this since we use states now
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt)
        % BACKGROUND_LOOPING_POINT
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
        % VIRTUAL_WIDTH

    --[[
    bird:update(dt)

    spawnTimer = spawnTimer + dt 

    if spawnTimer > 2 then
        --10 is min depth from top of screen and (PIPE_HEIGHT + 90) is maximum depth of pipe from bottom
        --a max of 20 height difference is allowed between adjacent pipePair
        --detail explanation see image in root directory
        local y = math.max(-PIPE_HEIGHT + 10, math.min( lastY + math.random(-22,22), VIRTUAL_HEIGHT - PIPE_HEIGHT - GAP_HEIGHT))
        lastY = y

        table.insert(pipePairs, PipePair(y))
        spawnTimer = 0 
    end

    for k, pair in pairs(pipePairs) do 
        pair:update(dt)

        --check for collison with each upper and lower pipe of the concerned pair
        for l, pipe in pairs(pair.pipes) do
            if bird:collides(pipe) then
                scrolling = false
                gStateMachine:change('title')
            end
        end
    end

    ---to remove off screen pipes
    for k, pair in pairs(pipePairs) do 
        if pair.x < -PIPE_WIDTH then
            table.remove(pipePairs, k)
        end 
    end


    if bird.y > VIRTUAL_HEIGHT - 15 then
        gStateMachine:change('title')
    end
    ]]
    --current state i.e. play is updated code is written in PlayState.lua
    gStateMachine:update(dt)
    
    --empty the table each frame
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start() --alternative to push:apply('start')
    --backgroun, above it come pipes then come ground
    love.graphics.draw(background, -backgroundScroll, 0)
    gStateMachine:render()
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
    
    push:finish()
end