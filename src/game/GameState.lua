local Camera = require 'lib.Camera'

local GameState = {}

state = nil

-- places instance of GameState into global scope
-- TODO refactor load and rename this class
function GameState.load()
    state = {
        players = {}, npcs = {}, hurtboxes = {}, objects = {}, terrains = {},
        camera = Camera(), world = love.physics.newWorld(),
        dt = 0
    }
end

return GameState
