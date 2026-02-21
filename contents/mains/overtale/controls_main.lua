local physics = require(".libs.physics")
local redstoneUtils = require(".libs.redstone_utils")
local sc = require(".libs.simple_commands")
local utils = require(".libs.utils")

local THRUSTER_FORCE_MULTIPLIER = 1.2
local MODULE_COUNT = 4
local THRUSTERS_PER_MODULE = 9

local sendModuleBl
local sendModuleBr
local sendModuleFl
local sendModuleFr


peripheral.find("modem",
    function(name, modem)
        if modem.isWireless() then
            sendModuleBl = sc.clientConnect("OvertaleModuleBl", name)
        end
    end)
peripheral.find("modem",
    function(name, modem)
        if modem.isWireless() then
            sendModuleBr = sc.clientConnect("OvertaleModuleBr", name)
        end
    end)
peripheral.find("modem",
    function(name, modem)
        if modem.isWireless() then
            sendModuleFl = sc.clientConnect("OvertaleModuleFl", name)
        end
    end)
peripheral.find("modem",
    function(name, modem)
        if modem.isWireless() then
            sendModuleFr = sc.clientConnect("OvertaleModuleFr", name)
        end
    end)

local function getForcePerModuleToHold()
    return physics.getWeight() / MODULE_COUNT
end

local function calcModuleForce()
    return physics.calcThrusterForce(THRUSTER_FORCE_MULTIPLIER) * THRUSTERS_PER_MODULE
end

local function redstonePerModuleToHold()
    local maxForcePerThruster = physics.calcThrusterForce(THRUSTER_FORCE_MULTIPLIER)
    local maxForcePerModule = maxForcePerThruster * THRUSTERS_PER_MODULE
    return redstoneUtils.redstoneForTargetValue(calcModuleForce(), getForcePerModuleToHold(), 15 * THRUSTERS_PER_MODULE)
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

--[[
API:
UP <int blocks> - Move up x blocks.
DOWN <int blocks> - Drop down x blocks.
HOLD - Hold current position and momentum.
LAND [int force] - Attempt to land. If force>0 it will land even if the spot is not suitable for landing.
TURN <int degrees> - Turn clockwise by the specified degrees (can be negative).
MOVE <int blocks> - Move forward by x blocks (can be negative).
STABILIZE - Make sure that the ship floats upright.
CANCEL - Cancels any running operation.

When a command is running, new ones will be queued. Only HOLD will be canceled if running.
If nothing to do and in the air, HOLD will execute automatically.
]]
local function listener(command)
    local action, param1, param2 = table.unpack(utils.split(command))
    if action == "UP" then
        setThrustersAngle(0)
        applyRedstoneDistribution(redstoneUtils.distributeRedstoneOverAmount(15 * THRUSTERS_PER_MODULE,
            THRUSTERS_PER_MODULE))
    elseif action == "CANCEL" then
        applyRedstoneDistribution(redstoneUtils.distributeRedstoneOverAmount(0, THRUSTERS_PER_MODULE))
        setThrustersAngle(0)
    end
end

peripheral.find(
    "modem",
    function(name, modem) if modem.isWireless() then sc.hostServer("OvertaleControls", listener, name) end end
)
