local function findDataDrive()
    local drives = { peripheral.find("drive") }
    for _, drive in pairs(drives) do
        if drive.getDiskLabel() == "ot_disk_data" then
            return drive
        end
    end
end

local function fetchRecords(name)
    local drive = findDataDrive()
    local recordFile = io.open(drive.getMountPath() .. "/records/" .. name .. ".txt", "r")
    local records = {}
    if recordFile then
        for record in recordFile:lines() do
            table.insert(records, record)
        end
        recordFile:close()
        return records
    end
end

local function fetchLatestRecord(name, offset)
    local records = fetchRecords(name)
    return records[#records - (offset or 0)]
end

local function addRecord(name, data, maxEntries)
    local drive = findDataDrive()
    local recordFile = io.open(drive.getMountPath() .. "/records/" .. name .. ".txt", "r")
    if recordFile then
        recordFile:write(data or "", "\n")
        recordFile:close()
    end
    if (maxEntries or 0) > 0 then
        local records = fetchRecords()
        if #records > maxEntries then
            local recordFile = io.open(drive.getMountPath() .. "/records/" .. name .. ".txt", "r")
            if recordFile then
                for i = 2, #records do
                    recordFile:write(records[i])
                end
                recordFile:close()
            end
        end
    end
end
