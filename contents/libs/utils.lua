local function nameFromUuid(uuid)
    local url = "https://sessionserver.mojang.com/session/minecraft/profile/" .. uuid
    if not http.checkURL(url) then
        return uuid
    end
    local response = http.get(url)
    if not response then
        return nil
    end
    response.readLine()
    response.readLine()
    local nameLine = response.readLine()
    response.close()
    if not nameLine then
        return nil
    end
    return string.sub(nameLine, 13, string.len(nameLine) - 2)
end

return {
    nameFromUuid = nameFromUuid,
}
