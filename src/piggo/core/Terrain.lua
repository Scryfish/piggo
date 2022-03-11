local Terrain = {}
local Clickable = require "src.piggo.core.Clickable"

local update, draw, handleMouseMoved

function Terrain.new(world, x, y, poly)
    assert(#poly % 2 == 0)

    local body = love.physics.newBody(world, x, y, "static")
    local fixture = love.physics.newFixture(body, love.physics.newPolygonShape(poly))

    return {
        state = {
            poly = poly,
            body = body, fixture = fixture,
            clickable = Clickable.new(
                {body:getWorldPoints(unpack(poly))},
                function(terrain)
                    terrain.color = {1, 1, 1}
                end,
                function(terrain)
                    terrain.color = {0, 0, 0}
                end,
                nil
            )
        },
        update = update, draw = draw,
        handleMouseMoved = handleMouseMoved
    }
end

-- TODO maybe some terrain destruction?
function update(self, dt) end

function draw(self)
    -- draw terrain
    -- love.graphics.setColor(0.85, 0.65, 0.4, 0.3)
    love.graphics.setColor(246/256.0, 212/256.0, 100/256.0, 0.8)
    if self.color then love.graphics.setColor(self.color) end
    love.graphics.polygon("fill", self.state.body:getWorldPoints(unpack(self.state.poly)))

    -- draw terrain outlines
    if debug then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.polygon("line", self.state.body:getWorldPoints(unpack(self.state.poly)))
    end

    -- print the corner coordinates
    if debug then
        for i=1, #self.state.poly, 2 do
            local debugVertices = "%d,%d"

            love.graphics.setColor(1, 1, 1)
            love.graphics.print(
                debugVertices:format(self.state.body:getWorldPoints(self.state.poly[i], self.state.poly[i+1])),
                self.state.body:getWorldPoints(self.state.poly[i], self.state.poly[i+1] - 5)
            )
        end
    end
end

function handleMouseMoved(self, x, y, state)
    self.state.clickable:handleMouseMoved(x, y, state, self)
end

return Terrain
