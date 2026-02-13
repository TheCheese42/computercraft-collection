local GRAVITY_ACCELERATION = 10
local THRUSTER_FORCE = 600000

local function getMass()
    return ship.getMass()
end

local function getLocation()
    return ship.getWorldspacePosition()
end

local function getAngle()
    local _, yaw, _ = ship.getQuaternion():toEuler()
    return math.pi + (yaw < 0 and math.pi + yaw or -math.pi + yaw)
end

local function getWeight()
    return getMass() * GRAVITY_ACCELERATION
end

local function calcThrusterForce(thrusterForceMultiplier)
    return THRUSTER_FORCE * thrusterForceMultiplier
end

local function multiplierForRedstone(value, level, maxLevel)
    return level * 1 / (maxLevel or 15) * value
end

local function redstoneForTargetValue(maxValue, targetValue, maxLevel)
    return (maxLevel or 15) * targetValue / maxValue
end

local function distributeRedstoneOverAmount(level, amount)
    local distribution = {}
    for i = amount, 1, -1 do
        local levelForObject = level / i
        if levelForObject % 1 ~= 0 then
            levelForObject = math.ceil(levelForObject)
        end
        level = level - levelForObject
        table.insert(distribution, levelForObject)
    end
    return distribution
end

return {
    getMass = getMass,
    getLocation = getLocation,
    getAngle = getAngle,
    getWeight = getWeight,
    calcThrusterForce = calcThrusterForce,
    multiplierForRedstone = multiplierForRedstone,
    redstoneForTargetValue = redstoneForTargetValue,
    distributeRedstoneOverAmount = distributeRedstoneOverAmount,
}
