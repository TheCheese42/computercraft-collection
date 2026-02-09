local function nameFromUuid(uuid)
    local url = "https://sessionserver.mojang.com/session/minecraft/profile/" .. uuid
    if not http.checkURL(url) then
        return uuid
    end
    local request = http.get(url)
    request.readLine()
    request.readLine()
    local nameLine = request.readLine()
    request.close()
    return string.sub(nameLine, 13, string.len(nameLine) - 2)
end
