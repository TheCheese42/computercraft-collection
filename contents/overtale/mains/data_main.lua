local data = require(".libs.data")

local idOpticalSensorLong = settings.get("idOpticalSensorLong")
local idOpticalSensorFluid = settings.get("idOpticalSensorFluid")
if idOpticalSensorLong == nil or idOpticalSensorFluid == nil then
    error("Not all optical sensor IDs were specified using the settings api.")
end

local opticalSensorLong = peripheral.wrap("idOpticalSensorLong")
local opticalSensorFluid = peripheral.wrap("idOpticalSensorFluid")
if opticalSensorLong == nil or opticalSensorFluid == nil then
    error("Couldn't find every specified optical sensor.")
end

while true do
    local distance = math.ceil(opticalSensorLong.getDistance())
    data.addRecord("distance", distance, 120)
    local distanceFluid = math.ceil(opticalSensorFluid.getDistance())
    data.addRecord("distance_fluid", distanceFluid, 120)
    sleep(0.5)
end
