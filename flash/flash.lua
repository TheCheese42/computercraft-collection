local mains = { ... }

local webLibs = {
    ["cryptoNet"] = "https://raw.githubusercontent.com/SiliconSloth/CryptoNet/refs/heads/master/cryptoNet.lua",
}

local function downloadLibrary(name, target)
    local url = webLibs[name]
    if not url then
        return nil
    end
    write("Downloading " .. name .. " to " .. target .. "...")
    local response = http.get(url)
    if response and response.getResponseCode() == 200 then
        local file = io.open(target, "w")
        if file then
            file:write(response:readAll())
            file:close()
            term.setTextColor(colors.green)
            print(" Done.")
            term.setTextColor(colors.white)
        else
            term.setTextColor(colors.red)
            print(" Failed.")
            term.setTextColor(colors.white)
        end
    else
        term.setTextColor(colors.red)
        print(" Failed.")
        term.setTextColor(colors.white)
    end
    if response then
        response.close()
    end
end

local function deepFlash(path, target, libsDir)
    for line in io.lines(path) do
        local libRequire = line:match("require[(]\"[.]libs[.]([._%w]+)\"[)]$")
        if libRequire then
            local lib = libRequire:gsub("[.]", "/") .. ".lua"
            local libPath = fs.combine(libsDir, lib)
            local libTargetPath = fs.combine("/libs", lib)
            if fs.exists(libPath) then
                deepFlash(libPath, libTargetPath, libsDir)
            else
                downloadLibrary(libRequire, libTargetPath)
            end
        end
    end
    write("Copying " .. path .. " to " .. target .. "...")
    fs.copy(path, target)
    term.setTextColor(colors.green)
    print(" Done.")
    term.setTextColor(colors.white)
end

local function saveDelete(dir)
    for _, item in ipairs(fs.list(dir)) do
        local path = fs.combine(dir, item)
        if not fs.isDriveRoot(path) and not fs.isReadOnly(path) then
            fs.delete(path)
        end
    end
end

for _, main in ipairs(mains) do
    local path = fs.combine("/disk/contents/mains/", main .. (main:match("[.]lua$") and "" or ".lua"))
    if not fs.exists(path) then
        print("Invalid path to main. Should be relative to /disk/contents/mains.")
        os.exit(1)
    end
    write("Erasing drive...")
    saveDelete("/")
    term.setTextColor(colors.green)
    print(" Done.")
    term.setTextColor(colors.white)
    deepFlash(path, "/startup.lua", "/disk/contents/libs/")
    print("Flashing finished.")
    break
end
