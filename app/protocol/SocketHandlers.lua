
local protocols = require("app.protocol.init")
local UserHandlers = require("app.protocol.UserHandlers")
local GameHandlers = require("app.protocol.GameHandlers")
local RoomHandlers = require("app.protocol.RoomHandlers")

local c = require("command_pb")

local SocketHandlers = {}
SOCKET_HANDLERS = SocketHandlers

SocketHandlers.HANDLERS = {}

function SocketHandlers.handleMessage(packet)
    local handler = SocketHandlers.HANDLERS[packet.type]
    if handler then
        if UserHandlers.isUserMessage(packet.type) then
            handler(packet.payload)
        else
            APP:getCurrentController():pushMessage(
                {type = packet.type, handler = handler, payload = packet.payload}
            )
        end
    else
        printInfo("[SocketManager] handle unkwown message type: 0x%04X", 
            packet.type)
    end
end

function SocketHandlers.handleOfflineMessage(packet)
    local handler = SocketHandlers.HANDLERS[packet.type]
    if handler then
        handler(packet.payload, packet.timestamp)
    else
        printInfo("[SocketManager] handle unkwown message type: 0x%04X", 
            packet.type)
    end   
end

function SocketHandlers.handleSendFail(type, data)
    -- local response = {type = type, data = data, err = true}
    -- APP:getCurrentController():updateByMessage(response)
end 

function SocketHandlers.handleSendWithClose(type, data)
    -- local response = {type = type, data = data, err = true}
    -- APP:getCurrentController():updateByMessage(response)    
end

SocketHandlers.HANDLERS[c.CMD_PING] = UserHandlers.handlePing
SocketHandlers.HANDLERS[c.CMD_ECHO_RESP] = UserHandlers.handleEchoRsonse
SocketHandlers.HANDLERS[c.CMD_AUTH_RESP] = UserHandlers.handleAuthResponse
SocketHandlers.HANDLERS[c.CMD_MESSAGE_RESP] = UserHandlers.handleMessageResponse
SocketHandlers.HANDLERS[c.CMD_NOTIFY_MESSAGE] = UserHandlers.handleNotifyMessage
SocketHandlers.HANDLERS[c.CMD_NOTIFY_KICKED_OFF] = UserHandlers.handleNotifyKickedOff

--room
SocketHandlers.HANDLERS[c.CMD_ENTER_ROOM_RESP] = RoomHandlers.handleRoomEnterResponse
SocketHandlers.HANDLERS[c.CMD_NOTIFY_ROOM_ENTER] = RoomHandlers.handleRoomNotifyEnter
SocketHandlers.HANDLERS[c.CMD_NOTIFY_ROOM_LEAVE] = RoomHandlers.handleRoomNotifyLeave

--game
SocketHandlers.HANDLERS[c.CMD_GAME_MOVE_RESP] = GameHandlers.handleGameMoveResponse
SocketHandlers.HANDLERS[c.CMD_GAME_NOTIFY_MOVE] = GameHandlers.handleGameNotifyMove















return SocketHandlers