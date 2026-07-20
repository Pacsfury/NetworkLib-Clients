--Reference Version: A0.1.0
local socket = require("socket")

local SET = 1
local GET = 2
local TEMP = 3
local CONST = 4
local SIGNAL = 5
local SUB = 6

local DEL = string.char(0x1F)
local END = string.char(0x00)

local nl = {
    is_connected = false,
    conn = nil,
    buffer = ""
}

function nl:init(host, port)
    local conn, err = socket.tcp()
    if not conn then
        return false, "Error creating socket: " .. tostring(err)
    end

    conn:settimeout(1.0)
    local res, conn_err = conn:connect(host, port)

    if not res then
        self.is_connected = false
        return false, "ERROR connectiong: " .. tostring(conn_err)
    end

    conn:settimeout(0)

    self.conn = conn
    self.is_connected = true
    self.buffer = ""
    return true, "Connected Sucessfully"
end

function nl:sendCmd(opcode, args, is_signal)
    if not self.is_connected or not self.conn then
        return
    end

    local msg = string.char(opcode)

    for _, a in ipairs(args) do
        msg = msg .. tostring(a) .. DEL
    end

    if is_signal then
        msg = msg .. END
    end

    self.conn:send(msg)
end

function nl:GET(key)
    if not self.is_connected or not self.conn then
        return nil
    end

    self:sendCmd(GET, {key})

    self.conn:settimeout(0.1)

    local temp_buffer = ""
    while true do
        local byte, err = self.conn:receive(1)
        if err then
            self.conn:settimeout(0)
            return nil
        end

        if byte == DEL then
            self.conn:settimeout(0)
            return temp_buffer
        else
            temp_buffer = temp_buffer .. byte
        end
    end
end

function nl:SET(key, val)
    self:sendCmd(SET, {key, val})
end
function nl:TEMP(key, val)
    self:sendCmd(TEMP, {key, val})
end
function nl:CONST(key, val)
    self:sendCmd(CONST, {key, val})
end
function nl:SUB(key)
    self:sendCmd(SUB, {key})
end

function nl:SIGNAL(...)
    self:sendCmd(SIGNAL, {...}, true)
end

function nl:update_game_network()
    if not self.is_connected or not self.conn then
        return nil, "Not Connected"
    end

    while true do
        local byte, err = self.conn:receive(1)
        if err == "timeout" then
            return nil
        elseif err then
            self.is_connected = false
            if self.conn then
                self.conn:close()
            end
            return nil, err
        end

        if byte == DEL then
            local msg = self.buffer
            self.buffer = ""
            return msg
        else
            self.buffer = self.buffer .. byte
        end
    end
end

return nl

