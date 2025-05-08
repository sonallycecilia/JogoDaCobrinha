if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    local lldebugger = require "lldebugger"
    lldebugger.start()
    local run = love.run
    function love.run(...)
        local f = lldebugger.call(run, false, ...)
        return function(...) return lldebugger.call(f, false, ...) end
    end
end

Direction = { Up = "up", Right = "right", Down = "down", Left = "left" }

function love.load()
    grid_size = 20
    snake = { { x = 3, y = 1 }, { x = 2, y = 1 }, { x = 1, y = 1 } }
    direction = Direction.Right
    food = { x = 10, y = 10 }
    game_over = false
    score = 0
    timer = 0
end

function love.update(dt)
    if not game_over then
        timer = timer + dt
        if timer >= 0.15 then
            timer = 0
            local new_x, new_y
            if direction == Direction.Up then
                new_x, new_y = snake[1].x, snake[1].y - 1
            elseif direction == Direction.Down then
                new_x, new_y = snake[1].x, snake[1].y + 1
            elseif direction == Direction.Left then
                new_x, new_y = snake[1].x - 1, snake[1].y
            elseif direction == Direction.Right then
                new_x, new_y = snake[1].x + 1, snake[1].y
            end

            table.insert(snake, 1, { x = new_x, y = new_y })

            if snake[1].x == food.x and snake[1].y == food.y then
                score = score + 1
                food.x = love.math.random(1, (love.graphics.getWidth() / grid_size) - 1)
                food.y = love.math.random(1, (love.graphics.getHeight() / grid_size) - 1)
            else
                table.remove(snake)
            end

            for i = 2, #snake do
                if snake[i].x == snake[1].x and snake[i].y == snake[1].y then
                    game_over = true
                end
            end

            if snake[1].x < 1 or snake[1].x > (love.graphics.getWidth() / grid_size) - 1 or
                snake[1].y < 1 or snake[1].y > (love.graphics.getHeight() / grid_size) - 1 then
                game_over = true
            end
        end
    end
end

function love.draw()
    love.graphics.setColor(0, 1, 0) -- Snake color
    for _, segment in ipairs(snake) do
        love.graphics.rectangle("fill", (segment.x - 1) * grid_size, (segment.y - 1) * grid_size, grid_size, grid_size)
    end

    love.graphics.setColor(1, 0, 0) -- Food color
    love.graphics.rectangle("fill", (food.x - 1) * grid_size, (food.y - 1) * grid_size, grid_size, grid_size)

    if game_over then
        love.graphics.setColor(1, 1, 1) -- Text color
        love.graphics.print("Game Over! Score: " .. score, love.graphics.getWidth() / 2 - 60, love.graphics.getHeight() / 2 - 10)
    end
end

function love.keypressed(key)
    if key == Direction.Up and direction ~= Direction.Down then
        direction = Direction.Up
    elseif key == Direction.Down and direction ~= Direction.Up then
        direction = Direction.Down
    elseif key == Direction.Left and direction ~= Direction.Right then
        direction = Direction.Left
    elseif key == Direction.Right and direction ~= Direction.Left then
        direction = Direction.Right
    end
end