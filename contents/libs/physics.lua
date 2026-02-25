local GRAVITY_ACCELERATION = 10 -- 9.81
local THRUSTER_FORCE = 600000

local function getMass(extraMass)
    return ship.getMass() + extraMass
end

local function getLocation()
    return ship.getWorldspacePosition()
end

local function getAngle()
    local _, yaw, _ = ship.getQuaternion():toEuler()
    return math.pi + (yaw < 0 and math.pi + yaw or -math.pi + yaw)
end

local function getWeight(extraMass)
    return getMass(extraMass) * GRAVITY_ACCELERATION
end

local function calcThrusterForce(thrusterForceMultiplier)
    return THRUSTER_FORCE * thrusterForceMultiplier
end

return {
    GRAVITY_ACCELERATION = GRAVITY_ACCELERATION,
    getMass = getMass,
    getLocation = getLocation,
    getAngle = getAngle,
    getWeight = getWeight,
    calcThrusterForce = calcThrusterForce,
}
