-- Exposes three functions: promptPwdForRead(), readCrypt(), writeCrypt().
-- It also provides a CLI, call the file without arguments to view the usage.

-- These two comments exist to make the flash script actually flash these libs.
-- local aes = require(".libs.aes")
-- local mt_isaac = require(".libs.mt_isaac")
dofile("/libs/aes.lua")      -- Library doesn't return anything... :(
dofile("/libs/mt_isaac.lua") -- Library doesn't return anything... :(
local sha256_hmac_pbkdf2 = require(".libs.sha256_hmac_pbkdf2")

local args = { ... }

seed_from_mt()

local function keyFromPwd(pwd)
    return sha256_hmac_pbkdf2.digest(pwd)
end

-- Returns the contents of the file as string.
local function readCrypt(filename, pwd)
    local key = keyFromPwd(pwd)
    local handle = fs.open(filename, "r")
    local str = handle.readAll()
    handle.close()
    local iv = table.pack(str:byte(1, 32))
    local decrypted = decrypt_str(str:sub(33), key, iv)
    --[[local d_string = ""
    for i = 33, #decrypted do
        d_string = d_string .. string.char(decrypted[i])
    end]]
    local signature = table.pack(decrypted:byte(1, 32))
    local d_string = decrypted:sub(33)
    if table.concat(signature) ~= table.concat(sha256_hmac_pbkdf2.digest(d_string)) then
        return nil
    end
    return d_string
end

-- Returns a boolean to determine whether the write was successful.
local function writeCrypt(filename, data_string, pwd)
    local key = keyFromPwd(pwd)
    local signature = sha256_hmac_pbkdf2.digest(data_string)
    local bytes = table.pack(string.byte(data_string, 1, #data_string))
    local iv = {}
    for i = 1, 32 do
        table.insert(iv, random(0, 255))
        table.insert(bytes, i, signature[i])
    end
    local e_bytes = encrypt_bytestream(bytes, key, iv)
    local handle = fs.open(filename, "wb")
    if not handle then
        return false
    end
    for i = 1, 32 do
        handle.write(iv[i])
    end
    for i = 1, #e_bytes do
        handle.write(e_bytes[i])
    end
    handle.close()
    return true
end

if args[1] == "decrypt" then
    local usage = "Usage: " .. shell.getRunningProgram() .. " decrypt <source> <password> <dest>"
    if not args[4] then
        error(usage)
    elseif not args[2] or not fs.exists(args[2]) then
        print(usage)
        error("Please provide an existing source file.")
    end
    local data = readCrypt(args[2], args[3])
    if data == nil then
        error("Wrong password.")
    end
    local handle = fs.open(args[4], "w")
    if not handle then
        print(usage)
        error("Please provide a valid destination path.")
    end
    handle.write(data)
    handle.close()
elseif args[1] == "encrypt" then
    local usage = "Usage: " .. shell.getRunningProgram() .. " encrypt <source> <password> <dest>"
    if not args[4] then
        error(usage)
    elseif not args[2] or not fs.exists(args[2]) then
        print(usage)
        error("Please provide an existing source file.")
    end
    local handle = fs.open(args[2], "r")
    local data = handle.readAll()
    handle.close()
    if not writeCrypt(args[4], data, args[3]) then
        print(usage)
        error("Please provide a valid destination path.")
    end
else
    print("Usage: " .. shell.getRunningProgram() .. " encrypt/decrypt <source> <password> <dest>")
end

-- Returns the contents of the file as string.
-- Blocks until the user enters the correct password.
local function promptPwdForRead(filename)
    while true do
        write("Password: ")
        local pwd = read("*")
        local result = readCrypt(filename, pwd)
        if result ~= nil then
            return result
        end
        print("Incorrect password.")
        sleep(0.5)
    end
end

return {
    readCrypt = readCrypt,
    writeCrypt = writeCrypt,
    promptPwdForRead = promptPwdForRead,
}
