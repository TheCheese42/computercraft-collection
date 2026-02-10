local dirs = { ... }

for _, dir in ipairs(dirs) do
    local finalPart = dir:match([[[%w\._]+$]])
    if finalPart then
        local isLib = dir:match([[/libs/]]) ~= nil or dir:match([[/lib/]]) ~= nil
        local target = "/" .. (isLib and "libs/" or "") .. finalPart
        if fs.exists(target) then
            fs.delete(target)
        end
        fs.copy("/disk/contents/" .. dir, target)
    end
end
