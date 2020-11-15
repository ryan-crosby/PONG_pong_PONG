WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

Class = require 'class'
push= require 'push'

require 'Ball'
require 'Paddle'

function love.load()
    
    math.randomseed(os.time())
    love.window.setTitle('Pong')
    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont('04B_03__.TTF', 12)
    
    scoreFont = love.graphics.newFont('04B_03__.TTF', 32)
    
    victoryFont = love.graphics.newFont('04B_03__.TTF', 24)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static'),
    }

    push:setupScreen (VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
      fullscreen = false,
      vsync = true,
      reziable = true
    })

    player1Score = 0
    player2Score = 0

    servingPlayer= 1

    paddle1 = Paddle(10, 30, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball= Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)
  

    gameState = 'start' 
    PADDLE_SPEED = 200
    
end

function love.resize(w, h)
    push:resize(w, h)
end

--moves paddles
function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then


        if ball:collides(paddle1) then
            --deflect ball to the right
            ball.dx = -ball.dx * 1.03
            ball.x = paddle1.x + 5
            
            if ball.dy< 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']: play()
        end

        if ball:collides(paddle2) then
            --delfect ball to the left
            ball.dx = -ball.dx * 1.03
            ball.x = paddle2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']: play()
            
        end

        if ball.y <= 0 then 
            --deflect ball down
            ball.y = 0
            ball.dy = -ball.dy

            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy 
            sounds['wall_hit']:play()       
        end


        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['point_scored']:play()

            if player2Score == 3 then
                winningPlayer = 1
                gameState = 'victory'

            else 
                gameState = 'serve'
                ball:reset()
            end
        end
    
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['point_scored']:play()
            
            if player1Score == 3 then
                winningPlayer = 2
                gameState = 'victory'
            else 
                gameState = 'serve'
                ball:reset()
            end       
        end
    end
    --if love.keyboard.isDown('w') then
    --    paddle1.dy = -PADDLE_SPEED
    --elseif love.keyboard.isDown('s') then
    --    paddle1.dy = PADDLE_SPEED
    --else
    --    paddle1.dy = 0
    --end
       
    if love.keyboard.isDown('up') then
        paddle2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        paddle2.dy = PADDLE_SPEED
    else
        paddle2.dy = 0
    end


    if gameState == 'play' then
        ball:update(dt)       
    end
    paddle1:updateAI(ball)
    paddle2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end        
        end
    end
end
function love.draw()
    push:apply('start')

    love.graphics.clear(40 / 255, 45/ 255, 52/ 255, 245/ 255)
    love.graphics.setFont(smallFont)
    displayScore()
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('welcome to Pong!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Play!', 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player' .. tostring(servingPlayer) .. "'s turn!" , 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Serve!', 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then

    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf('Player' .. tostring(winningPlayer) .. " wins!" , 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to Restart!', 0, 42, VIRTUAL_WIDTH, 'center')
    end

    -- first paddle render
    paddle1:render()
    --second paddle render
    paddle2:render()

    -- ball render
    ball.render()
    -- First paddle (left side)
        
    -- second paddle (right side)
    
    displayFPS()

    push:apply('end')


end

function displayScore()
    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: '.. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end
