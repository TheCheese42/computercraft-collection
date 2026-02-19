local util = require(".libs.utils")

local function getRadarTrackInfo(track)
    local type_ = track.entityType:match("[:.](%w+)$"):gsub("^%l", string.upper)
    return {
        type = type_,
        name = type_ == "Ship" and track.id:gsub("^%l", string.upper) or util.nameFromUuid(track.id),
        position = { x = math.ceil(track.position.x), y = math.ceil(track.position.y), z = math.ceil(track.position.z) },
    }
end

local function getRadarTarget(radar)
    local track = radar.getSelectedTrack()
    if not track then
        return nil
    end
    return getRadarTrackInfo(track)
end


return {
    getRadarTrackInfo = getRadarTrackInfo,
    getRadarTarget = getRadarTarget,
}
