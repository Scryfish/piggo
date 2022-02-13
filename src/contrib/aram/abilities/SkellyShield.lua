local SkellyShield = {}
local IAbility = require "src.piggo.core.IAbility"
local ShapeUtils = require "src.piggo.util.ShapeUtils"

local cast, update, draw

local rgb = {1, 0, 0, 0.6}

function SkellyShield.new()
    local skellyShield = IAbility.new("Skelly Shield", cast, update, draw, 300)

    return skellyShield
end

function cast(self, character)
    if self.frame < self.cd then return end

    table.insert(character.effects, {
        name = "Shield",
        drawable = true,
        duration = 80,
        frame = 0,
        shield = {
            color = {r = 0.8, g = 0.8, b = 0.8, alpha = 1},
            radius = 2,
            width = 4
        },
        segments = {
            {
                time = 70,
                done = false,
                cast = function(self, me, effect)
                    effect.shield = {
                        color = {r = 1, g = 0.2, b = 0.2, alpha = 0.2},
                        radius = 25,
                        width = 50
                    }
                end
            },
            {
                time = 75,
                done = false,
                cast = function(self, me)
                    me:submitHurtboxCircle("Shield", 140, character.body:getX(), character.body:getY(), 50)
                end
            }
        },
        draw = function(self, me)
            love.graphics.setColor(
                self.shield.color.r,
                self.shield.color.g - self.shield.color.g * self.frame / self.duration,
                self.shield.color.b - self.shield.color.b * self.frame / self.duration
            )
            love.graphics.setLineWidth(self.shield.width)
            love.graphics.circle("line", character.body:getX(), character.body:getY(), character.state.size + self.shield.radius)
            love.graphics.setLineWidth(1)
        end
    })
end

function update(self) end

function draw(self) end

return SkellyShield
