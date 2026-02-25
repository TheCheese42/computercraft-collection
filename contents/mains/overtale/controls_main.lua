local physics = require(".libs.physics")
local redstoneUtils = require(".libs.redstone_utils")
local sc = require(".libs.simple_commands")
local cn = require(".libs.cryptoNet")
local utils = require(".libs.utils")

local THRUSTER_FORCE_MULTIPLIER = 1.2
local MODULE_COUNT = 4
local THRUSTERS_PER_MODULE = 9

local sendModuleBl
local sendModuleBr
local sendModuleFl
local sendModuleFr

local extraMass = 0
local isEngineOn = false

local commandQueue = {} -- FIFO Queue
local commandsToCancel = {}
local lastLocation = nil
local currentVelocity = { x = 0, y = 0, z = 0 }

peripheral.find("modem",
    function(name, modem)
        if modem.isWireless() then
            sendModuleBl = sc.clientConnect("OvertaleModuleBl", name)
        end
    end)
local event_type, event_msg = cn.listen()
local event_type, event_msg = cn.listen()
if event_type == "encrypted_message" then
    extraMass = extraMass + event_msg
end
peripheral.find("modem",
    function(name, modem)
        if modem.isWireless() then
            sendModuleBr = sc.clientConnect("OvertaleModuleBr", name)
        end
    end)
event_type, event_msg = cn.listen()
event_type, event_msg = cn.listen()
if event_type == "encrypted_message" then
    extraMass = extraMass + event_msg
end
peripheral.find("modem",
    function(name, modem)
        if modem.isWireless() then
            sendModuleFl = sc.clientConnect("OvertaleModuleFl", name)
        end
    end)
event_type, event_msg = cn.listen()
event_type, event_msg = cn.listen()
if event_type == "encrypted_message" then
    extraMass = extraMass + event_msg
end
peripheral.find("modem",
    function(name, modem)
        if modem.isWireless() then
            sendModuleFr = sc.clientConnect("OvertaleModuleFr", name)
        end
    end)
event_type, event_msg = cn.listen()
event_type, event_msg = cn.listen()
if event_type == "encrypted_message" then
    print(event_type, event_msg)
    extraMass = extraMass + event_msg
end

local function getForcePerModuleToHold()
    return physics.getWeight(extraMass) / MODULE_COUNT
end

local function calcMaxModuleForce()
    return physics.calcThrusterForce(THRUSTER_FORCE_MULTIPLIER) * THRUSTERS_PER_MODULE
end

local function calcMaxShipForce()
    return calcMaxModuleForce() * MODULE_COUNT
end

local function redstonePerModuleToHold()
    return redstoneUtils.redstoneForTargetValue(calcMaxModuleForce(), getForcePerModuleToHold(),
        15 * THRUSTERS_PER_MODULE)
end

-- Takes a distribution from redstone_utils and an integer signalizing
-- which modules to apply it to (bit flags, see setThrustersAngle())
local function applyRedstoneDistribution(distribution, which)
    which = which or 15
    if bit.band(which, 1) then
        sendModuleBl(distribution)
    end
    if bit.band(which, 2) then
        sendModuleBr(distribution)
    end
    if bit.band(which, 4) then
        sendModuleFl(distribution)
    end
    if bit.band(which, 8) then
        sendModuleFr(distribution)
    end
end

-- Positive angle means pointing to the back, negative means pointing to the front
-- Which is represented as bit flags
-- 1, 2, 4 and 8 stand for back-left, back-right, front-left and front-right, respectively
-- Example: 1 = back-left; 3 = back-left and back-right; 15 = all of them
-- Defaults to 15 (all)
local function setThrustersAngle(angle, which)
    local module_bl = settings.get("thruster_module_bl")
    local module_br = settings.get("thruster_module_br")
    local module_fl = settings.get("thruster_module_fl")
    local module_fr = settings.get("thruster_module_fr")
    if not (module_bl and module_br and module_fl and module_fr) then
        error(
            "Not all thruster modules were specified in the settings. " ..
            "Please use 'set thruster_module_bl', -br, -fl and -fr " ..
            "(b=back, f=front, l=left, r=right) to specify the peripheral " ..
            "names of the Phys Bearings (e.g. 'cw_phys_bearing_0')."
        )
    end
    which = which or 15
    if bit.band(which, 1) then
        peripheral.call(module_bl, "setAngle", angle)
    end
    if bit.band(which, 2) then
        peripheral.call(module_br, "setAngle", angle)
    end
    if bit.band(which, 4) then
        peripheral.call(module_fl, "setAngle", angle)
    end
    if bit.band(which, 8) then
        peripheral.call(module_fr, "setAngle", angle)
    end
end

local function enableEngine(state)
    isEngineOn = state
    local redstoneRelay = peripheral.find("redstone_relay")
    redstoneRelay.setOutput("bottom", not state)
end

local function cancelCommand(id)
    for i = 1, #commandsToCancel do
        if id == commandsToCancel[i] then
            table.remove(commandsToCancel, i)
            for j = 1, #commandQueue do
                if id == commandQueue[j] then
                    table.remove(commandQueue, j)
                end
            end
            return true
        end
    end
    return false
end

--[[
API:
ON - Turn on the engine.
OFF - Turn off the engine.
UP <int blocks> - Move up x blocks.
DOWN <int blocks> - Drop down x blocks.
HOLD - Hold current position and momentum.
LAND [int force] - Attempt to land. If force>0 it will land even if the spot is not suitable for landing.
TURN <int degrees> - Turn clockwise by the specified degrees (can be negative).
MOVE <int blocks> - Move forward by x blocks (can be negative).
BRAKE - Bring horizontal momentum down to zero.
SPEED - Set horizontal speed on a scale from 0 to 15.
STABILIZE - Make sure that the ship floats upright.
CANCEL - Cancels any running operation.

When a command is running, new ones will be queued. Only HOLD will be canceled if running.
If nothing to do and in the air, HOLD will execute automatically.
If the engine is turned off, only the ON command will work.
]]
local function listener(command)
    local action, param1 = table.unpack(utils.split(command))
    if action == "CANCEL" then
        applyRedstoneDistribution(redstoneUtils.distributeRedstoneOverAmount(0, THRUSTERS_PER_MODULE))
        setThrustersAngle(0)
        for i = 1, #commandQueue do
            table.insert(commandsToCancel, commandQueue[i])
        end
        return
    end
    local id = math.random(999999999) -- Guess that works
    table.insert(commandQueue, #commandQueue + 1, id)
    while commandQueue[1] ~= id do
        sleep(0.5)
        if cancelCommand(id) then return end
    end
    if not isEngineOn and action ~= "ON" then
        table.remove(commandQueue, 1)
        return
    elseif action == "ON" then
        enableEngine(true)
    elseif action == "OFF" then
        enableEngine(false)
    elseif action == "HOLD" then
        local redstoneToHold = redstonePerModuleToHold()
        applyRedstoneDistribution(redstoneUtils.distributeRedstoneOverAmount(redstoneToHold, THRUSTERS_PER_MODULE))
        local targetHeight = physics.getLocation().y
        while true do
            sleep(0.5)
            if cancelCommand(id) then return end
            local currentHeight = physics.getLocation().y
            if currentHeight > targetHeight then
                applyRedstoneDistribution(redstoneUtils.distributeRedstoneOverAmount(redstoneToHold - 1,
                    THRUSTERS_PER_MODULE))
            elseif currentHeight < targetHeight then
                applyRedstoneDistribution(redstoneUtils.distributeRedstoneOverAmount(redstoneToHold + 1,
                    THRUSTERS_PER_MODULE))
            end
        end
    elseif action == "UP" then
        local targetHeight = physics.getLocation().y + param1
        setThrustersAngle(0)
        applyRedstoneDistribution(redstoneUtils.distributeRedstoneOverAmount(15 * THRUSTERS_PER_MODULE,
            THRUSTERS_PER_MODULE))
        local upwardsAcceleration = 0
        local timeUntilNeutral = 0
        local displacement = 0
        while physics.getLocation().y + displacement < targetHeight do
            sleep(0.05)
            upwardsAcceleration = currentVelocity.y
            timeUntilNeutral = upwardsAcceleration / physics.GRAVITY_ACCELERATION
            displacement = upwardsAcceleration * timeUntilNeutral +
                0.5 * -physics.GRAVITY_ACCELERATION * (timeUntilNeutral ^ 2)
            if cancelCommand(id) then return end
        end
        applyRedstoneDistribution(redstoneUtils.distributeRedstoneOverAmount(0, THRUSTERS_PER_MODULE))
        sleep(timeUntilNeutral - 0.05)
    end
    table.remove(commandQueue, 1)
end

enableEngine(false)

local function openListener()
    peripheral.find(
        "modem",
        function(name, modem) if modem.isWireless() then sc.hostServer("OvertaleControls", listener, name) end end
    )
end

local function measure()
    while true do
        local thisLocation = physics.getLocation()
        if lastLocation then
            currentVelocity.x = thisLocation.x - lastLocation.x
            currentVelocity.y = thisLocation.y - lastLocation.y
            currentVelocity.z = thisLocation.z - lastLocation.z
        end
        lastLocation = thisLocation
        sleep(1)
    end
end

parallel.waitForAny(openListener, measure)
