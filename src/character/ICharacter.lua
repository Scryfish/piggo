local ShapeUtils = require 'src.util.shapeutils'
local DrawUtils = require 'src.util.DrawUtils'

local ICharacter = {}

local update, draw, submitHurtboxPoly, submitHurtboxCircle

function ICharacter.new(charUpdate, charDraw, x, y, hp, maxhp, speed, size, abilities)
    assert(type(x) == "number")
    assert(type(y) == "number")
    assert(type(hp) == "number")
    assert(maxhp ~= nil and maxhp > 0)
    assert(speed ~= nil and speed > 0)
    assert(size ~= nil and size > 0)
    assert(abilities ~= nil)

    local body = love.physics.newBody(state.world, x, y, "dynamic")
    local fixture = love.physics.newFixture(body, love.physics.newCircleShape(size))

    return {
        meta = {
            hp = hp, maxhp = maxhp, speed = speed, size = size,
            canMove = true, marker = nil
        },
        charUpdate = charUpdate, charDraw = charDraw,
        update = update, draw = draw,
        submitHurtboxPoly = submitHurtboxPoly, submitHurtboxCircle = submitHurtboxCircle,
        abilities = abilities, effects = {}, hurtboxes = {}, facingRight = 1, dt = 0,
        body = body, fixture = fixture,
        team = 2, -- TODO
        target = nil,
        range = 50, ranged = false
    }
end

function update(self, dt)
    self.charUpdate(self)

    if self.target ~= nil and self.target.body == nil then
        self.target = nil
    end

    -- velocity to 0
    self.body:setLinearVelocity(0, 0)

    -- accumulate total dt
    self.dt = self.dt + dt

    -- if i'm targeting, check if i can auto attack them
    if self.target ~= nil then
        -- remove marker since we are in range
        self.meta.marker = nil

        if ShapeUtils.circleInCircle(
            self.target.body:getX(), self.target.body:getY(), self.target.meta.size,
            self.body:getX(), self.body:getY(), self.range
        ) then
            self.body:setLinearVelocity(0, 0)

            if self.ranged then -- ranged auto attack
                -- table.insert(state.objects, AutoAttack.new(self.range, 70))
                debug("create ranged auto attack")
            else -- melee auto attack
                self.target.meta.hp = self.target.meta.hp - 1
            end
        else -- walk toward the target
            self.meta.marker = {x = self.target.body:getX(), y = self.target.body:getY()}
        end
    end

    -- move toward marker
    if self.meta.marker and self.meta.canMove then
        local xdiff = self.meta.marker.x - self.body:getX()
        local ydiff = self.meta.marker.y - self.body:getY()

        if math.abs(xdiff) <= 1 and math.abs(ydiff) <= 1 then
            self.meta.marker = nil
            -- self.body:setLinearVelocity(0, 0)
        else
            local xRatio = .0 + xdiff / (math.abs(xdiff) + math.abs(ydiff))
            local yRatio = .0 + ydiff / (math.abs(xdiff) + math.abs(ydiff))

            local xComponent = self.meta.speed * xRatio
            local yComponent = self.meta.speed * yRatio

            self.body:setLinearVelocity(xComponent, yComponent)
        end
    end

    -- update where character is facing
    if self.meta.marker and self.meta.marker.x < self.body:getX() then
        self.facingRight = -1
    elseif self.meta.marker and self.meta.marker.x > self.body:getX() then
        self.facingRight = 1
    end

    -- increment ability dt
    for i, ability in pairs(self.abilities) do
        ability.dt = ability.dt + dt

        -- handle abilities with charges
        if ability.charges and ability.maxCharges then

            -- recharge
            if ability.chargeDt >= ability.chargeCd then
                ability.charges = ability.charges + 1
                ability.chargeDt = 0
            end

            -- increment chargeDt if not at max
            if ability.charges < ability.maxCharges then
                ability.chargeDt = ability.chargeDt + dt
            end
        end
    end

    -- update each effect
    for i, effect in pairs(self.effects) do
        effect.dt = effect.dt + dt

        for _, segment in pairs(effect.segments) do
            if not segment.done and segment.time <= effect.dt then
                segment:run(self, effect)
                segment.done = true
            end
        end

        if effect.dt > effect.duration then
            table.remove(self.effects, i)
        end
    end
end

function draw(self)
    -- draw line to marker
    if debug() then
        love.graphics.setColor(0.6, 0.6, 0.6)
        if self.meta.marker then
            love.graphics.line(
                self.body:getX(), self.body:getY(),
                self.meta.marker.x, self.meta.marker.y
            )
        end
    end

    -- draw line to targeted enemy
    -- if debug() then
    --     love.graphics.setColor(self.team == 1 and 1 or 0, self.team == 2 and 1 or 0, 0)
    --     if self.target ~= nil and self.target.body ~= nil then
    --         love.graphics.line(
    --             self.body:getX(), self.body:getY(),
    --             self.target.body:getX(), self.target.body:getY()
    --         )
    --     end
    -- end

    -- draw each effect
    for _, effect in pairs(self.effects) do
        if effect.drawable then
            effect:draw(self)
        end
    end

    -- draw healthbar
    DrawUtils.drawHealthbar(
        self.body:getX(), self.body:getY(),
        self.meta.size, self.meta.hp, self.meta.maxhp
    )

    self.charDraw(self)

    if debug() then
        love.graphics.setColor(0, 0, 1, 0.6)
        love.graphics.circle("line", self.body:getX(), self.body:getY(), self.meta.size)
    end
end

function submitHurtboxPoly(self, name, damage, poly)
    table.insert(self.hurtboxes,
        {type = "poly", name = name, damage = damage, poly = poly}
    )
end

function submitHurtboxCircle(self, name, damage, x, y, radius)
    table.insert(self.hurtboxes,
        {type = "circle", name = name, damage = damage, x = x, y = y, radius = radius}
    )
end

return ICharacter
