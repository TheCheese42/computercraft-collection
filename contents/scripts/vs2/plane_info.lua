while true do
    local link1 = peripheral.wrap("left")
    link1.clear()
    link1.setCursorPos(1, 1)
    local link2 = peripheral.wrap("top")
    link2.clear()
    link2.setCursorPos(1, 1)

    local thrusterStrength = rs.getAnalogInput("back")
    link1.write("Thrust: ")
    link1.write(tostring(math.floor((thrusterStrength + 1) / 2)))
    link1.write("/8")
    local fluidStorage = peripheral.wrap("front")
    local fuelAmount = 0
    for k, tank in pairs(fluidStorage.tanks()) do
        fuelAmount = fuelAmount + tank.amount
    end
    link1.setCursorPos(1, 2)
    link1.write("Fuel: ")
    link1.write(tostring(math.floor(fuelAmount / 1000)))
    link1.write(" B")

    local groundDistance = rs.getAnalogInput("bottom")
    link2.write("Ground: ")
    link2.write(tostring(groundDistance ~= 15 and groundDistance or "--"))
    local altimeterValue = rs.getAnalogInput("right")
    local height = 60 + altimeterValue * 10
    link2.setCursorPos(1, 2)
    link2.write("Height: ")
    link2.write(tostring(height == 60 and "<60" or (height == 210 and ">210" or height)))

    link1.update()
    link2.update()
    os.sleep(1)
end
