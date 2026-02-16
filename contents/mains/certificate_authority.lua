-- The files created by flashing this should be copied to a Floppy Disk.
-- Boot a Computer from this Floppy Disk to sign its certificate.
-- A special shell will load, with only two commands: ls and signCert.
-- Usage: signCert <file>

local function cleanup()
    if fs.exists("cryptoNet.lua") then
        fs.delete("cryptoNet.lua")
    end
end

local privateKeyPath = fs.combine(
    fs.getDir(shell.getRunningProgram()), "certAuth_private.key"
)
if not fs.exists(privateKeyPath) then
    error("certAuth_private.key not found. Please generate and copy it to the disk.")
end

local response = http.get("https://github.com/TheCheese42/CryptoNet/raw/refs/heads/master/cryptoNet.lua")
local success = false
if response and response.getResponseCode() == 200 then
    local file = io.open("cryptoNet.lua", "w")
    if file then
        file:write(response:readAll())
        file:close()
        success = true
    end
end
if response then
    response.close()
end
if not success then
    cleanup()
    error("Failed to acquire CryptoNet. Exiting.")
end

term.setTextColor(colors.magenta)
print("\nCertAuth Shell")
local instructions = "Commands: ls <file>; signCert <file>; exit"
print(instructions)
term.setTextColor(colors.white)
while true do
    write("> ")
    local command = read()
    if command:match("^ls%s?[%w._/-]*$") then
        shell.run(command)
    elseif command:match("^signCert%s[%w._/-]+$") then
        local certPath = command:match("^signCert%s([%w._/-]+)$")
        shell.run("cryptoNet signCert " .. certPath .. " " .. privateKeyPath)
    elseif command == "exit" then
        cleanup()
        os.shutdown()
    else
        printError("Invalid command. " .. instructions)
    end
end
