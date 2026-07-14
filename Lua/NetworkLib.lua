local nl = {}
local socket = require("socket")

function nl:init(ip, port)
    self.client = socket.tcp()
    self.is_connected = false
    self.rx_buffer = ""
    
    self.client:settimeout(0)
    
    local success, err = self.client:connect(ip, port)
    
    if success then
        self.is_connected = true
        return "Connected instantly!"
    else
        return "Connection initiated, waiting for handshake... Status: " .. tostring(err)
    end
end

function nl:update_game_network(dt)
    if not self.client then return nil end

    if not self.is_connected then
        local _, writable, err = socket.select(nil, {self.client}, 0)
        
        if writable and writable[1] == self.client then
            local _, send_err = self.client:send("")
            if send_err then
                self.client:close()
                self.client = nil
                return "Connection failed during handshake: " .. tostring(send_err)
            end
            
            self.is_connected = true
            return "Connection fully established!"
        elseif err == "timeout" then
            return nil
        else
            self.client:close()
            self.client = nil
            return "Connection failed: " .. tostring(err)
        end
    end

    local data, err, partial = self.client:receive(1024)
    local chunk = data or partial

    if chunk and #chunk > 0 then
        self.rx_buffer = self.rx_buffer .. chunk
    end

    if err == "closed" then
        self.client:close()
        self.client = nil
        self.is_connected = false
        return "Server disconnected."
    end

    local line, rest = self.rx_buffer:match("^([^\n]*)\n(.*)$")
    if line then
        self.rx_buffer = rest
        return "Received complete message: " .. line
    end

    return nil
end

function nl:_send(action_string)
    if not self.is_connected or not self.client then return end

    local bytes_sent, err, bytes_sent_so_far = self.client:send(action_string .. "\n")
    
    if err == "timeout" then
        return "Network buffer full, sent partial: " .. tostring(bytes_sent_so_far)
    elseif err then
        return "Send error: " .. tostring(err)
    end
end

function nl:SET(var, value)    self:_send("SET " .. var .. " " .. value) end
function nl:GET(var)           self:_send("GET " .. var) end
function nl:TEMP(var, value)   self:_send("TEMP " .. var .. " " .. value) end
function nl:CONST(var, value)  self:_send("CONST " .. var .. " " .. value) end
function nl:SIGNAL(var, value) self:_send("SIGNAL " .. var .. " " .. value) end
function nl:SUB(var)           self:_send("SUB " .. var) end

return nl
