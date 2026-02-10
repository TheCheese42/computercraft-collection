local dirs = { ... }

for _, dir in ipairs(dirs) do
    local finalPart = dir:match([[[%w\.]+$]])
    if finalPart then
        local isLib = dir:match([[/libs/]]) ~= nil or dir:match([[/lib/]]) ~= nil
        fs.copy("/disk/contents/" .. dir, "/" .. (isLib and "libs/" or "") .. finalPart)
    end
end
