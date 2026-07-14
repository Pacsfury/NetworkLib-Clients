--Refernce Version: A0.1.0
local nl = {}
local socket = require("socket")

local DEL = string.char(0x1F)
local END = string.char(0x00)

local OP = {
    SET    = 0x1,
    GET    = 0x2,
    TEMP   = 0x3,
    CONST  = 0x4,
    SIGNAL = 0x5,
    SUB    = 0x6,
}

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
        return "Connection initiated, waiting... Status: " .. tostring(err)
    end
end

function nl:update_game_network()
    if not self.client then return nil, "No client" end

    if not self.is_connected then
        local _, writable, err = socket.select(nil, {self.client}, 0)

        if writable and writable[1] == self.client then
            local _, send_err = self.client:send("")
            if send_err and send_err ~= "timeout" then
                self:close_connection()
                return nil, "Connection failed during handshake: " .. tostring(send_err)
            end

            self.is_connected = true
            return "Connection fully established!"
        elseif err == "timeout" then
            return nil
        else
            self:close_connection()
            return nil, "Connection failed: " .. tostring(err)
        end
    end

    local data, err, partial = self.client:receive("*a") 
    local chunk = data or partial

    if chunk and #chunk > 0 then
        self.rx_buffer = self.rx_buffer .. chunk
    end

    if err == "closed" then
        self:close_connection()
        return nil, "Server disconnected."
    end

    local field, rest = self.rx_buffer:match("^([^\031]*)\031(.*)$")
    if field then
        self.rx_buffer = rest
        return field
    end

    return nil
end

function nl:close_connection()
    if self.client then
        self.client:close()
        self.client = nil
    end
    self.is_connected = false
    self.rx_buffer = ""
end

function nl:_send_raw(msg)
    if not self.is_connected or not self.client then return nil, "Not connected" end

    local bytes_sent, err, bytes_sent_so_far = self.client:send(msg)

    if err then
        self:close_connection()
        return nil, "Send error (Stream desynced): " .. tostring(err)
    end
    return true
end

function nl:_send(opcode, ...)
    local parts = { string.char(opcode) }
    for _, arg in ipairs({ ... }) do
        table.insert(parts, tostring(arg))
        table.insert(parts, DEL)
    end
    return self:_send_raw(table.concat(parts))
end

function nl:_send_variadic(opcode, ...)
    local parts = { string.char(opcode) }
    for _, arg in ipairs({ ... }) do
        table.insert(parts, tostring(arg))
        table.insert(parts, DEL)
    end
    table.insert(parts, END)
    return self:_send_raw(table.concat(parts))
end

function nl:SET(var, value)    self:_send(OP.SET, var, value) end
function nl:GET(var)           self:_send(OP.GET, var) end
function nl:TEMP(var, value)   self:_send(OP.TEMP, var, value) end
function nl:CONST(var, value)  self:_send(OP.CONST, var, value) end
function nl:SIGNAL(...)        self:_send_variadic(OP.SIGNAL, ...) end
function nl:SUB(var)           self:_send(OP.SUB, var) end

return nl
