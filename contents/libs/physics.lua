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

return {
    getMass = getMass,
    getLocation = getLocation,
    getAngle = getAngle,
    getWeight = getWeight,
    calcThrusterForce = calcThrusterForce,
}
