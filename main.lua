-- VARIABLES
local gamestate
local paddle
local paddle2
local ball

-- HELPER FUNCTIONS
-- custom clamp function
function clamp(value, min, max)
    if value < min then
        value = min
    elseif value > max then
        value = max
    end
    return value
end

-- function for figuring out where the ball hits on the paddle
-- and how it should bounce back
local function map_range(value, low1, high1, low2, high2)
    local relative_pos = (value - low1) / (high1 - low1)
    return low2 + (relative_pos * (high2 - low2))
end

function love.load()
    math.randomseed(os.time())
    love.graphics.setNewFont(80)
    gamestate = 1
    paddle = {
        width = 20,
        height = 125,
        x = 50,
        y = 50,
        speed = 400,
        score = 0
    }

    paddle2 = {
        width = 20,
        height = 125,
        x = 730,
        y = 50,
        speed = 300,
        score = 0
    }

    ball = {
        width = 20,
        height = 20,
        x = 0,
        y = 0,
        xspeed = 0,
        yspeed = math.random(-300, 300),
        speed = 500
    }
end

function love.update(dt)
    -- Give ball and paddle some extra variables
    paddle.x2 = paddle.x + paddle.width
    paddle.y2 = paddle.y + paddle.height
    paddle.center = paddle.y + (paddle.height / 2)
    paddle2.x2 = paddle2.x + paddle2.width
    paddle2.y2 = paddle2.y + paddle2.height
    paddle2.center = paddle2.y + (paddle2.height / 2)
    ball.x2 = ball.x + ball.width
    ball.y2 = ball.y + ball.height
    ball.center = ball.y + (ball.height / 2)

    -- USER INPUT
    if love.keyboard.isDown("up") then
        paddle.y = paddle.y - (paddle.speed * dt)
    end
    if love.keyboard.isDown("down") then
        paddle.y = paddle.y + (paddle.speed * dt)
    end
    if love.keyboard.isDown("r") then
        love.event.quit("restart")
    end

    -- Clamp the paddles
    paddle.y = clamp(paddle.y, 23, 577 - paddle.height)
    paddle2.y = clamp(paddle2.y, 23, 577 - paddle2.height)

    -- paddle2 movement
    -- Follow the ball center
    if paddle2.center < ball.center then
        paddle2.y = paddle2.y + (paddle2.speed * dt)
    elseif paddle2.center > ball.center then
        paddle2.y = paddle2.y - (paddle2.speed * dt)
    end

    -- PUTTING THE ball IN PLACE
    if gamestate == 1 then
        -- game is not started so keep ball attached to paddle
        ball.x = (paddle.x + paddle.width)
        ball.y = (paddle.y + (paddle.height / 2) - (ball.height / 2))
        -- if pressed space, game starts
        if love.keyboard.isDown("space") then
            -- give the ball velocity
            ball.xspeed = ball.speed
            ball.yspeed = math.random(-300, 300)
            gamestate = 2
        end
    end

    if gamestate == 2 then
        -- do ball stuff
        ball.x = ball.x + (ball.xspeed * dt)
        ball.y = ball.y + (ball.yspeed * dt)

        -- ball bouncing off wall
        if ball.y < 20 then
            ball.y = 20
            ball.yspeed = ball.yspeed * -1
        end
        if ball.y + (ball.height) > 580 then
            ball.y = 580 - ball.height
            ball.yspeed = ball.yspeed * -1
        end

        -- ball colliding with paddle
        if ball.y2 >= paddle.y and ball.y <= paddle.y2 then
            if ball.x2 >= paddle.x and ball.x <= paddle.x2 and ball.xspeed < 0 then
                ball.x = paddle.x2
                ball.xspeed = ball.xspeed * -1
                -- give yspeed to where it touched the paddle
                ball.yspeed = map_range(ball.center, paddle.y, paddle.y2, -600, 600)
                -- increase ball speed on every hit
                ball.xspeed = ball.xspeed * 1.1
            end
        end

        -- ball colliding with paddle2
        if ball.y2 >= paddle2.y and ball.y <= paddle2.y2 then
            if ball.x <= paddle2.x2 and ball.x2 >= paddle2.x and ball.xspeed > 0 then
                ball.x = paddle2.x - ball.width
                ball.xspeed = ball.xspeed * -1
                local yspeed = map_range(ball.center, paddle2.y, paddle2.y2, -600, 600)
                -- give a bit of randomness to te angle
                ball.yspeed = yspeed + math.random(-150, 150)
            end
        end

        -- ball hit left wall, paddle loses
        if ball.x < 20 then
            ball.x = 20
            paddle2.score = paddle2.score + 1
            gamestate = 1
        end

        -- ball hit right wall, paddle2 loses
        if ball.x2 > 780 then
            ball.x = ball.x - ball.width
            paddle.score = paddle.score + 1
            gamestate = 1
        end
    end
end

function love.draw()
    love.graphics.setColor(255, 255, 255)

    love.graphics.setLineWidth(3)

    -- Make dotted line
    local dashgap = 540 / 10
    local dash = 0.6 * dashgap
    local gap = 0.4 * dashgap
    local x1 = 400
    local x2 = 400
    local y1 = 20 + gap
    local y2 = y1 + dash

    while y1 <= (580 - dash) do
        love.graphics.line(x1, y1, x2, y2)
        y1 = y1 + dash + gap
        y2 = y2 + dash + gap
    end

    --love.graphics.line(400, 20, 400, 580)
    love.graphics.rectangle("line", 20, 20, 760, 560)
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("fill", paddle.x, paddle.y, paddle.width, paddle.height)
    love.graphics.setColor(0, 255, 0)
    love.graphics.rectangle("fill", paddle2.x, paddle2.y, paddle2.width, paddle2.height)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)
    
    
    --love.graphics.setColor(255, 0, 0)
    love.graphics.printf(paddle.score, 50, 50, 200, "left")
    --love.graphics.setColor(0, 255, 0)
    love.graphics.printf(paddle2.score, 0, 50, 750, "right")
end
