local nl = require("NetworkLib")
local socket = require("socket")

local player_x = 0
local player_y = 0
local GRID_SIZE = 32

function love.load()
    os.execute('start "" network.exe')

    local success, msg = nl:init("127.0.0.1", 8080)
    print("[NL] " .. msg)

    love.graphics.setNewFont(16)

    local waited = 0
    while not nl.is_connected and waited < 2 do
        nl:update_game_network()
        socket.sleep(0.05)
        waited = waited + 0.05
    end

    if nl.is_connected then
        
        local server_x = nl:GET("px")
        
        if not server_x or server_x:find("ERROR") then
            nl:SET("px", "0")
            player_x = 0
        else
            player_x = tonumber(server_x) or 0
        end

        local server_y = nl:GET("py")
        
        if not server_y or server_y:find("ERROR") then
            nl:SET("py", "0")
            player_y = 0
        else
            player_y = tonumber(server_y) or 0
        end
        

        nl:SUB("px")
        nl:SUB("py")

        print("[NL] Syncronized positions: (" .. player_x .. ", " .. player_y .. ")")
    end
end

function love.keypressed(key)
    if not nl.is_connected then return end

    if key == "w" or key == "up" then
        player_y = player_y - 1
        nl:SET("py", tostring(player_y))
    elseif key == "s" or key == "down" then
        player_y = player_y + 1
        nl:SET("py", tostring(player_y))
    elseif key == "a" or key == "left" then
        player_x = player_x - 1
        nl:SET("px", tostring(player_x))
    elseif key == "d" or key == "right" then
        player_x = player_x + 1
        nl:SET("px", tostring(player_x))
    end

    player_x = tonumber(nl:GET("px")) or player_x
    player_y = tonumber(nl:GET("py")) or player_y
end

function love.update(dt)
    if not nl.is_connected then return end

    local safety_counter = 0
    while safety_counter < 10 do
        local server_msg = nl:update_game_network()
        if server_msg then
            print("[Server]: " .. server_msg)
            
            local varName, varValue = server_msg:match("#subscribed_var_changed%s+(%S+)%s+(%S+)")
            if varName and varValue then
                if varName == "px" then
                    player_x = tonumber(varValue) or player_x
                elseif varName == "py" then
                    player_y = tonumber(varValue) or player_y
                end
            end
        else
            break
        end
        safety_counter = safety_counter + 1
    end
end

function love.draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    local status = nl.is_connected and "Connected" or "Disconnedcted (try rerunning game)"
    local status_color = nl.is_connected and {0, 1, 0} or {1, 0, 0}
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Net: ", 20, 20)
    love.graphics.setColor(status_color)
    love.graphics.print(status, 80, 20)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Syncronized position: (" .. player_x .. ", " .. player_y .. ")", 20, 50)

    local draw_x = (windowWidth / 2) + (player_x * GRID_SIZE) - (GRID_SIZE / 2)
    local draw_y = (windowHeight / 2) + (player_y * GRID_SIZE) - (GRID_SIZE / 2)

    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.rectangle("fill", draw_x, draw_y, GRID_SIZE, GRID_SIZE)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", draw_x, draw_y, GRID_SIZE, GRID_SIZE)
end
