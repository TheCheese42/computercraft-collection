local strength = 0

while true do
    if (rs.getInput("left")) then
        strength = math.max(strength - 2, 0)
    elseif (rs.getInput("right")) then
        -- Step size is 2, but we start from 1 so it ends at 15
        strength = math.min(strength + (strength == 0 and 1 or 2), 15)
    end
    rs.setAnalogOutput("bottom", math.abs(strength))
    os.pullEvent("redstone")
end
