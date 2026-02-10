local util = require(".libs.util")

local function getRadarTrackInfo(track)
    return {
        type = track.entityType:match("[:.](%w+)$"):gsub("^%l", string.upper),
        name = util.nameFromUuid(track.id) or "---",
        position = track.position,
    }
end

local function getRadarTarget(radar)
    local track = radar.getSelectedTrack()
    return getRadarTrackInfo(track)
end


return {
    getRadarTrackInfo = getRadarTrackInfo,
    getRadarTarget = getRadarTarget,
}
