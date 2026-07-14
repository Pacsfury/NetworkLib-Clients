local nl = require("NetworkLib")

local dt = 1 

print(nl:init("127.0.0.1", 8080))

while true do
    local network_status = nl:update_game_network(dt)
    if network_status then
        print("[NL] " .. network_status)
    end

    nl:SET("PlayerHP", "100")
    nl:GET("PlayerHP")
    nl:SIGNAL("MatchStart", "true")

    local socket = require("socket")
    socket.sleep(1)
end
