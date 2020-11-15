Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height= height

    self.dy = 0
end

function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    elseif self.dy > 0 then
        self.y = math.min(VIRTUAL_HEIGHT - 20, self.y + self.dy * dt)
    end
end

function Paddle:updateAI(ball)
    if ball.dy < 0 then
        self.y = math.max (0, ball.y + (ball.height / 2) - (self.height / 2))
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, ball.y + (ball.height / 2) - (self.height / 2))
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end