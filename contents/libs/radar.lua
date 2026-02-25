local util = require(".libs.utils")

local function getRadarTrackInfo(track)
    local type_match = track.entityType:match("[:.](%w+)$")
    local type_ = (type_match and type_match or track.category):gsub("%L*", string.lower):gsub("^%l", string.upper)
    if #type_ > 8 then
        type_ = type_:sub(1, 8) .. "."
    end
    return {
        type = type_,
        name = type_ == "Ship" and track.id:gsub("^%l", string.upper) or util.nameFromUuid(track.id),
        position = { x = math.ceil(track.position.x), y = math.ceil(track.position.y), z = math.ceil(track.position.z) },
    }
end

local function getRadarTarget(radar)
    local track = radar.getSelectedTrack()
    if not track or next(track) == nil then
        return nil
    end
    return getRadarTrackInfo(track)
end


return {
    getRadarTrackInfo = getRadarTrackInfo,
    getRadarTarget = getRadarTarget,
}
