WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432

VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

function love.load()
    math.randomseed(os.time())


    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Definitivamente o melhor jogo já criado até hoje')

    smallFont = love.graphics.newFont('font.ttf', 8)

    scoreFont = love.graphics.newFont('font.ttf', 32)

    victoryFont = love.graphics.newFont('font.ttf', 24)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('point.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('border_hit.WAV', 'static'),
        ['theme'] = love.audio.newSource('Theme.mp3', 'static'),
        ['win'] = love.audio.newSource('win.mp3', 'static')
    }

    player1Score = 0
    player2Score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2

    winningPlayer = 0

    paddle1 = Paddle(5, 20, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2- 2, 5, 5)

    if servingPlayer == 2 then
        ball.dx = 100
    else
        ball.dx = -100
    end

    gameState = 'start' 

    sounds['theme']:play()

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        vsync = true,
        resizeble = true
    })
end

    function love.resize(w,h)
        push:resize(w, h)
    end

function love.update(dt)
    if gameState == 'play' then

        if ball.x <= 0 then
            sounds['point_scored']:play()
            servingPlayer = 1
            player2Score = player2Score + 1
            ball:reset()
            ball.dx = -100
            if player2Score >= 5 then 
                gameState = 'victory'
                sounds['theme']:stop()
                sounds['win']:play()
                winningPlayer = 2
            else
            gameState = 'serve'
            end
        end

        if ball.x >= VIRTUAL_WIDTH - 4 then
            sounds['point_scored']:play()
            servingPlayer = 2
            player1Score = player1Score + 1
            ball:reset()
            ball.dx = 100
            if player1Score >= 5 then 
                gameState = 'victory'
                sounds['theme']:stop()
                sounds['win']:play()
                winningPlayer = 1
            else
            gameState = 'serve'
            end
        end

        if ball:collides(paddle1) then
        --deflect ball to the right
        ball.dx = -ball.dx
            sounds['paddle_hit']:play()
        end

     if ball:collides(paddle2) then
        --deflect the ball to the left
        ball.dx = -ball.dx
        sounds['paddle_hit']:play()
     end

     if ball.y <= 0 then
        --deflect the ball down
        ball.dy = -ball.dy
        ball.y = 0
        sounds['wall_hit']:play()
     end

     if ball.y >= VIRTUAL_HEIGHT - 4 then
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - 4
        sounds['wall_hit']:play()
        end

        paddle1:update(dt)
        paddle2:update(dt)

        if love.keyboard.isDown('w') then

            paddle1.dy = -PADDLE_SPEED

        elseif love.keyboard.isDown('s') then

        paddle1.dy = PADDLE_SPEED
        else
            paddle1.dy = 0
        end   
        
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

    end
end



function love.keypressed(key)
    if key ==  'escape' then
        love.event.quit()
        elseif key == 'enter' or key == 'return' then
            if gameState == 'start' then
                gameState = 'serve'
            elseif gameState == 'victory' then
               
                gameState = 'start'
                sounds['win']:stop()
                sounds['theme']:play()
                player1Score = 0
                player2Score = 0
            elseif gameState == 'serve' then
                gameState = 'play'
    
            end
        
    end
end    

function love.draw()

    push:apply('start')

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)


    paddle1:render()
    paddle2:render()

    ball:render()

    displayFps()

    love.graphics.setFont(smallFont)

    if gameState == 'start' then
        love.graphics.printf('Bem-vindos a Pong', 0, 20,  VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Pressione Enter para jogar!', 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf("Vez do jogador ".. tostring(servingPlayer)..'', 0, 20,  VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Pressione Enter para sacar"'  , 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("O jogador ".. tostring(winningPlayer).." Venceu!!!",
         0, 20,  VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Pressione Enter para reiniciar o jogo"'  , 0, 42, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'play' then

    end
     

    love.graphics.setFont(scoreFont)
    love.graphics.print(player1Score,VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3 )
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    push:apply('end')
end

function displayFps()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end