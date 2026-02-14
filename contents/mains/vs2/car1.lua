local strength = 0

while true do
    if (rs.getInput("left")) then
        strength = math.max(strength - 1, -15)
    elseif (rs.getInput("right")) then
        strength = math.min(strength + 1, 15)
    end
    rs.setOutput("back", strength ~= 0)
    rs.setOutput("front", strength < 0 and true or false)
    rs.setAnalogOutput("bottom", math.abs(strength))
    os.pullEvent("redstone")
end
