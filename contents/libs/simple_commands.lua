-- One-way command api; clients control a server
-- Usage:
-- [Client]
-- local send = clientConnect("testServer")
-- send("Greetings.")
-- [Server]
-- local function listener(message)
--     print("Received: " .. message)
-- end
-- hostServer("testServer", listener)

local cryptoNet = require(".libs.cryptoNet")

local function hostServer(serverName, listener, modemName)
    local function onStartServer()
        cryptoNet.host(serverName, false, true, modemName)
    end

    local function onEventServer(event)
        if event[1] == "encrypted_message" then
            local message = event[2]
            local socket = event[3]
            if socket.permissionLevel > 0 then
                listener(message)
            end
        end
    end

    cryptoNet.startEventLoop(onStartServer, onEventServer)
end

local function clientConnect(serverName, modemName)
    local socket = cryptoNet.connect(serverName, nil, nil, nil, modemName)
    local user = settings.get("sc_username")
    if not user then
        error("Please set a username (set sc_username ...)")
    end
    local pass = settings.get("sc_password")
    if not pass then
        error("Please set a password (set sc_password ...)")
    end
    local loginResult = cryptoNet.login(socket, user, pass)
    if loginResult == "login_failed" then
        error("User credentials are incorrect.")
    end
    return function(message)
        cryptoNet.send(socket, message)
    end
end

return {
    hostServer = hostServer,
    clientConnect = clientConnect,
}
