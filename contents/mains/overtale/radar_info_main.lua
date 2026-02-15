local radar = require(".libs.radar")
local sm = require(".libs.simple_monitor")

local monitor = sm.Monitor.new(peripheral.wrap("front"), 0.5)

while true do
    local target = radar.getRadarTarget(peripheral.wrap("bottom"))

    monitor:clear()
    monitor:println()
    monitor:println()

    monitor:print("Type: ")
    monitor:println(target.type)

    monitor:print("Name: ")
    if target.name and #target.name > 8 then
        monitor:println()
    end
    monitor:println(target.name or "---")
    monitor:println()

    monitor:print("X: ")
    monitor:println(target.position.x)
    monitor:print("Y: ")
    monitor:println(target.position.y)
    monitor:print("Z: ")
    monitor:println(target.position.z)
    sleep(0.2)
end
