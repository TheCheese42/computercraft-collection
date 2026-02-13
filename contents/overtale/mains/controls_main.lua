local physics = require(".libs.physics")

local THRUSTER_FORCE_MULTIPLIER = 1.2
local MODULE_COUNT = 4
local THRUSTERS_PER_MODULE = 8

local function getForcePerModuleToHold()
    return physics.getWeight() / MODULE_COUNT
end

local function calcModuleForce()
    return physics.calcThrusterForce(THRUSTER_FORCE_MULTIPLIER) * THRUSTERS_PER_MODULE
end

local function redstonePerModuleToHold()
    local maxForcePerThruster = physics.calcThrusterForce(THRUSTER_FORCE_MULTIPLIER)
    local maxForcePerModule = maxForcePerThruster * THRUSTERS_PER_MODULE
    return physics.redstoneForTargetValue(calcModuleForce(), getForcePerModuleToHold(), 15 * THRUSTERS_PER_MODULE)
end

local function applyRedstoneDistribution(distribution)
    local relay1, relay2 = peripheral.find("redstone_relay")
    for i, strength in ipairs(distribution) do
        if i == 1 then
            relay1.setAnalogOutput("front", strength)
        elseif i == 2 then
            relay2.setAnalogOutput("front", strength)
        elseif i == 3 then
            relay1.setAnalogOutput("back", strength)
        elseif i == 4 then
            relay2.setAnalogOutput("back", strength)
        elseif i == 5 then
            relay1.setAnalogOutput("bottom", strength)
        elseif i == 6 then
            relay2.setAnalogOutput("bottom", strength)
        elseif i == 7 then
            relay1.setAnalogOutput("left", strength)
        elseif i == 8 then
            relay2.setAnalogOutput("right", strength)
        end
    end
end

while true do
    peripheral.find(
        "modem",
        function(name, modem) if modem.isWireless() then return rednet.open(name) end end
    )
    local _, command = rednet.receive("control_tick")
    local i = 1
    local action
    local param
    for part in command:gmatch("%S+") do
        if i == 1 then
            action = part
        elseif i == 2 then
            param = part
        end
        i = i + 1
    end

    if action == "UP" then
        applyRedstoneDistribution(physics.distributeRedstoneOverAmount(15 * THRUSTERS_PER_MODULE, THRUSTERS_PER_MODULE))
    elseif action == "STOP" then
        applyRedstoneDistribution(physics.distributeRedstoneOverAmount(0, THRUSTERS_PER_MODULE))
    end
end
