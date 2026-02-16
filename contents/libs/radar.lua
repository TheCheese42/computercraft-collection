local util = require(".libs.utils")

local function getRadarTrackInfo(track)
    return {
        type = track.entityType:match("[:.](%w+)$"):gsub("^%l", string.upper),
        name = util.nameFromUuid(track.id),
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
