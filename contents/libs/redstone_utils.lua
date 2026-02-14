local function multiplierForRedstone(value, level, maxLevel)
    return level * 1 / (maxLevel or 15) * value
end

local function redstoneForTargetValue(maxValue, targetValue, maxLevel)
    return (maxLevel or 15) * targetValue / maxValue
end

local function distributeRedstoneOverAmount(level, amount)
    local distribution = {}
    for i = amount, 1, -1 do
        local levelForObject = level / i
        if levelForObject % 1 ~= 0 then
            levelForObject = math.ceil(levelForObject)
        end
        level = level - levelForObject
        table.insert(distribution, levelForObject)
    end
    return distribution
end

return {
    multiplierForRedstone = multiplierForRedstone,
    redstoneForTargetValue = redstoneForTargetValue,
    distributeRedstoneOverAmount = distributeRedstoneOverAmount,
}
