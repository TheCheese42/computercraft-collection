local mains = { ... }

local function deepFlash(path, target, libsDir)
    for line in io.lines(path) do
        local libRequire = line:match("require[(]\"[.]libs[.]([.%w]+)\"[)]$")
        if libRequire then
            local lib = libRequire:gsub("[.]", "/") .. ".lua"
            local libPath = fs.combine(libsDir, lib)
            deepFlash(libPath, fs.combine("/libs", lib), libsDir)
        end
    end
    print("Flashing " .. path .. " to " .. target)
    fs.copy(path, target)
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
    saveDelete("/")
    deepFlash(path, "/startup.lua", "/disk/contents/libs/")
    print("Done.")
    break
end
