local data = require(".libs.data")

local idOpticalSensorLong = settings.get("id_optical_sensor_long")
local idOpticalSensorFluid = settings.get("id_optical_sensor_fluid")
if idOpticalSensorLong == nil or idOpticalSensorFluid == nil then
    error(
        "Please set id_optical_sensor_long and id_optical_sensor_fluid. " ..
        "Example: 'set id_optical_sensor_long optical_sensor_0'"
    )
end

local opticalSensorLong = peripheral.wrap(idOpticalSensorLong)
local opticalSensorFluid = peripheral.wrap(idOpticalSensorFluid)
if opticalSensorLong == nil or opticalSensorFluid == nil then
    error("Couldn't find every specified optical sensor.")
end

while true do
    local distance = math.ceil(opticalSensorLong.getDistance())
    data.addRecord("distance", distance, 120)
    local distanceFluid = math.ceil(opticalSensorFluid.getDistance())
    data.addRecord("distance_fluid", distanceFluid, 120)
    local fuelBiggestTank = peripheral.find("fluid_storage").tanks()[1].amount
    local fuelBigTanks = fuelBiggestTank * 4
    local fuelSmallTanks = math.min(fuelBiggestTank, 216000) * 4
    local fuel = fuelBigTanks + fuelSmallTanks
    data.addRecord("fuel", fuel, 120)
    data.recordHighest("max_fuel", fuel)
    sleep(0.5)
end
