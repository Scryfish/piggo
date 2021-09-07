local Cmeta = {}
-- character metadata and validation

local posvalidate

function Cmeta.new(pos, hp, maxhp, speed, size)
    assert(pos.x ~= nil and pos.x > 0)
    assert(pos.y ~= nil and pos.y > 0)
    assert(hp ~= nil and hp > 0)
    assert(maxhp ~= nil and maxhp > 0)
    assert(speed ~= nil and speed > 0)
    assert(size ~= nil and size > 0)

    local cmeta = {
        canMove = true, -- not set by constructor
        pos = pos,
        hp = hp,
        maxhp = maxhp,
        speed = speed,
        size = size
    }

    return cmeta
end

local function testCmetaNew()
    assert(Cmeta.new(
        {x = 15, y = 15},
        15,
        20,
        300,
        20
    ))
end
testCmetaNew()

return Cmeta
