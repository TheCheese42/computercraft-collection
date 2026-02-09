local function fetchInventories()
    local connectedInventories = {}
    for _, name in ipairs(peripheral.getNames()) do
        local types = { peripheral.getType(name) }
        for _, type_ in ipairs(types) do
            if type_ == "inventory" then
                table.insert(connectedInventories, name)
            end
        end
    end
    return connectedInventories
end

local function checkItemAmountFor(inventory, itemName)
    local amount = 0
    for _, item in pairs(peripheral.call(inventory, "list")) do
        if item.name == itemName then
            amount = amount + item.count
        end
    end
    return amount
end

local function checkItemAmount(itemName)
    local amount = 0
    for _, inv in pairs(fetchInventories()) do
        amount = amount + checkItemAmountFor(inv, itemName)
    end
    return amount
end

local function requestItems(targetName, itemName, itemAmount, targetSlot)
    itemAmount = itemAmount or 64
    for _, inv in pairs(fetchInventories()) do
        for slot, item in pairs(peripheral.call(inv, "list")) do
            if item.name == itemName then
                local orderAmount = math.min(itemAmount, item.count)
                itemAmount = itemAmount - orderAmount
                peripheral.call(inv, "pushItems", targetName, slot, orderAmount, targetSlot)
                if itemAmount <= 0 then
                    break
                end
            end
        end
        if itemAmount <= 0 then
            break
        end
    end
end

return {
    checkItemAmountFor = checkItemAmountFor,
    checkItemAmount = checkItemAmount,
    requestItems = requestItems,
}
