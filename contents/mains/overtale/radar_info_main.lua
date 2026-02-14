local radar = require(".libs.radar")

local monitor = peripheral.wrap("front")
monitor.setTextScale(0.5)

while true do
    local target = radar.getRadarTarget(peripheral.wrap("bottom"))
    local line = 3
    monitor.clear()
    monitor.setCursorPos(1, line)
    line = line + 1
    monitor.write("Type: ")
    monitor.write(target.type)
    monitor.setCursorPos(1, line)
    line = line + 1
    monitor.write("Name: ")
    if target.name and #target.name > 8 then
        monitor.setCursorPos(1, line)
        line = line + 1
    end
    monitor.write(target.name or "---")
    line = line + 1
    monitor.setCursorPos(1, line)
    line = line + 1
    monitor.write("X: ")
    monitor.write(target.position.x)
    monitor.setCursorPos(1, line)
    line = line + 1
    monitor.write("Y: ")
    monitor.write(target.position.y)
    monitor.setCursorPos(1, line)
    line = line + 1
    monitor.write("Z: ")
    monitor.write(target.position.z)
    sleep(0.2)
end
