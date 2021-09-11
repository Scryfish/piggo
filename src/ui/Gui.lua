local DrawUtils = require 'src.util.DrawUtils'

local Gui = {}

local draw, drawDebug, drawAbilityOutline, drawCooldownIndicator, drawConsole

local boxWidth, boxHeight, consoleHeight = 50, 50, 0.95

local chargeCounter = "%d / %d"

function Gui.new(player)
    return {
        player = player,
        draw = draw
    }
end

function draw(self)
    if debug() then drawDebug(self.player) end
    drawConsole(self.player)
end

function drawDebug(player)
    local debug = table.concat({
        "fps: %d",
        "hp: %s",
        "position x: %d y: %d",
        "effects: %d"
    }, "\n")

    love.graphics.setColor(1, 1, 0, 0.7)
    love.graphics.print(debug:format(
        love.timer.getFPS(),
        player.character.meta.hp,
        player.character.meta.pos.x,
        player.character.meta.pos.y,
        #player.character.effects
    ), 10, 10)
end

function drawConsole(player)
    local q = {x = love.graphics.getWidth() / 2 - 100, y = love.graphics.getHeight() * consoleHeight - boxHeight}
    local w = {x = love.graphics.getWidth() / 2 - 45, y = love.graphics.getHeight() * consoleHeight - boxHeight}
    local e = {x = love.graphics.getWidth() / 2 + 10, y = love.graphics.getHeight() * consoleHeight - boxHeight}
    local r = {x = love.graphics.getWidth() / 2 + 65, y = love.graphics.getHeight() * consoleHeight - boxHeight}

    -- ability outlines
    drawAbilityOutline(q.x, q.y, player.character.abilities.q.dt, player.character.abilities.q.cd)
    drawAbilityOutline(w.x, w.y, player.character.abilities.w.dt, player.character.abilities.w.cd)
    drawAbilityOutline(e.x, e.y, player.character.abilities.e.dt, player.character.abilities.e.cd)
    drawAbilityOutline(r.x, r.y, player.character.abilities.r.dt, player.character.abilities.r.cd)

    -- cooldown indicators
    drawCooldownIndicator(q.x, q.y, boxWidth, boxHeight, player.character.abilities.q.dt, player.character.abilities.q.cd)
    drawCooldownIndicator(w.x, w.y, boxWidth, boxHeight, player.character.abilities.w.dt, player.character.abilities.w.cd)
    drawCooldownIndicator(e.x, e.y, boxWidth, boxHeight, player.character.abilities.e.dt, player.character.abilities.e.cd)
    drawCooldownIndicator(r.x, r.y, boxWidth, boxHeight, player.character.abilities.r.dt, player.character.abilities.r.cd)

    -- keybinds
    love.graphics.setColor(.7, .7, .2)
    love.graphics.print("q", q.x + 5, q.y + 30)
    love.graphics.print("w", w.x + 5, w.y + 30)
    love.graphics.print("e", e.x + 5, e.y + 30)
    love.graphics.print("r", r.x + 5, r.y + 30)

    -- charge abilities
    love.graphics.setColor(.2, .7, .7)
    drawCharges(player.character.abilities.q, q.x + 20, q.y + 30)
    drawCharges(player.character.abilities.w, w.x + 35, w.y + 30)
    drawCharges(player.character.abilities.e, e.x + 35, e.y + 30)
    drawCharges(player.character.abilities.r, r.x + 35, r.y + 30)
end

function drawCharges(ability, x, y)
    if ability.charges then
        love.graphics.print(
            chargeCounter:format(ability.charges, ability.maxCharges),
            x, y
        )
    end
end

function drawAbilityOutline(x, y, dt, cd)
    if dt < cd then
        love.graphics.setColor(.8, .8, .2)
    else
        love.graphics.setColor(1, 1, 1)
    end
    DrawUtils.drawBox(x, y, boxWidth, boxHeight)
end

function drawCooldownIndicator(x, y, width, height, dt, cd)
    if dt < cd then
        love.graphics.setColor(.3, .3, .3)
        love.graphics.stencil(function() DrawUtils.drawBox(x, y, width, height) end)
        love.graphics.setStencilTest("greater", 0)
        love.graphics.arc("fill", "pie", x + width / 2, y + height / 2, height, 4.71, 10.99 - 6.28 * (dt / cd) )
        love.graphics.setStencilTest()
    end
end

return Gui
