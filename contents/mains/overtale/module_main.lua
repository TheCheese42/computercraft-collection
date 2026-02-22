local sc = require(".libs.simple_commands")

local serverName = settings.get("server_name")
if not serverName then
    error("Please specify a server name using e.g. 'set server_name OvertaleModuleBl'.")
end

local peripherals = peripheral.getNames()
local thrusters = {}
for _, peripheral_ in ipairs(peripherals) do
    if peripheral_:match("propulsion_thruster_%d+") then
        table.insert(thrusters, peripheral_)
    end
end
table.sort(thrusters)

local function listener(distribution)
    for i = 1, #distribution do
        local strength = distribution[i]
        local thruster = peripheral.wrap(thrusters[i])
        thruster.setPower(strength)
    end
end

local function hostServerWrapped()
    peripheral.find(
        "modem",
        function(name, modem) if modem.isWireless() then sc.hostServer(serverName, listener, name) end end
    )
end

local function refuelThrusters()
    while true do
        for _, thruster in ipairs(thrusters) do
            peripheral.call(thruster, "pullFluid", peripheral.getName(peripheral.find("tfmg:steel_fluid_tank")))
        end
        sleep(1)
    end
end

parallel.waitForAny(hostServerWrapped, refuelThrusters)
