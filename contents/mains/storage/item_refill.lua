local storage = require(".libs.storage")

local target = settings.get("storage_target")
if target == nil then
    print("No storage target was specified. Use `set storage_target <target>`.")
    error()
end
local item = settings.get("storage_item")
if item == nil then
    print("No item was specified. Use `set storage_item <item_id>`.")
    error()
end

while true do
    if storage.checkItemAmountFor(target, item) < 64 then
        storage.requestItems(target, item)
    end
    sleep(0.1)
end
