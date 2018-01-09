
cc.utils = require("framework.cc.utils.init")
cc.net = require("framework.cc.net.init")
local utils = require("app.common.utils")
local GameEnv = require("app.core.GameEnv")
local GameConfig = require("app.core.GameConfig")
local GameUtils = require("app.core.GameUtils")
local protocols = require("app.protocol.init")
local Protocol = protocols.Protocol
local SocketHandlers = require("app.protocol.SocketHandlers")
local scheduler = require("framework.scheduler")

local SocketManager = {}

SocketManager.S_NONE = 1
SocketManager.S_INITED = 2
SocketManager.S_CONNECTING = 3
SocketManager.S_CONNECTED = 4
SocketManager.S_DISCONNECTING = 5
SocketManager.S_DISCONNECTED = 6

SocketManager.SEQUENCE = 0

SocketManager.STATUS_PRINTS = {
    "NONE",
    "INITED",
    "CONNECTING",
    "CONNECTED",
    "DISCONNECTING",
    "DISCONNECTED"
}

SocketManager._socket = nil
SocketManager._status = SocketManager.S_NONE
SocketManager._packetBuffer = nil
SocketManager._msgQueue = {}
SocketManager._blocked = false

function SocketManager.getStatus()
    return SocketManager._status
end

function SocketManager.isNotPrintCmd(cmd)
    if cmd == 1001 or cmd == 1002 or cmd == 1003 then
        return true
    end
    return false
end

function SocketManager.getStatusString()
    return SocketManager.STATUS_PRINTS[SocketManager._status]
end

function SocketManager.switchStatus(newStatus)
    printInfo("[SocketManager] switch status [%s] -> [%s]", 
        SocketManager.STATUS_PRINTS[SocketManager._status], 
        SocketManager.STATUS_PRINTS[newStatus])
    SocketManager._status = newStatus
end

function SocketManager.init()
    assert(SocketManager._status == SocketManager.S_NONE)
    assert(SocketManager._socket == nil)

    local env = GameEnv.getSocketEnv()
    SocketManager._socket = cc.net.SocketTCP.new(env.host, env.port, false)
    SocketManager._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, SocketManager.onSocketEvent)
    SocketManager._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, SocketManager.onSocketEvent)
    SocketManager._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, SocketManager.onSocketEvent)
    SocketManager._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, SocketManager.onSocketEvent)
    SocketManager._socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, SocketManager.onSocketData)

    SocketManager._packetBuffer = protocols.PacketBuffer.new()

    SocketManager.switchStatus(SocketManager.S_INITED)

    -- 设置一个全局入口
    SOCKET_MANAGER = SocketManager

    scheduler.scheduleGlobal(function() SocketManager.handleMessages() end, 0.01)
end

function SocketManager.connect()
    assert(SocketManager._socket ~= nil)
    assert(SocketManager._status == SocketManager.S_INITED or
        SocketManager._status == SocketManager.S_DISCONNECTED)
    printInfo("[SocketManager] [%s] connect", utils.timeStr())
    SocketManager.switchStatus(SocketManager.S_CONNECTING)
    SocketManager._socket:connect()
end

function SocketManager.disconnect()
    assert(SocketManager._socket ~= nil)
    assert(SocketManager._status ~= SocketManager.S_NONE)
    printInfo("[SocketManager] [%s] disconnect", utils.timeStr())
    SocketManager.switchStatus(SocketManager.S_DISCONNECTING)
    SocketManager._socket:disconnect()
end

function SocketManager.send(type, data)
    if SocketManager._status == SocketManager.S_CONNECTED then
        assert(SocketManager._socket ~= nil)
        if not SocketManager.isNotPrintCmd(type) then
            printInfo("[SocketManager] [%s] send packet: %s", 
                utils.timeStr(),
                protocols.Protocol[type] or type)
        end
        local packetBuffer = protocols.PacketBuffer.createPacket(type, data)
        local sendError = SocketManager._socket:send(packetBuffer:getPack())

        --如果发送失败
        if sendError == nil then
            SocketHandlers.handleSendFail(type, data)
        end
    else
        --回调当网络已经不在连接状态下发包
        SocketHandlers.handleSendWithClose(type, data)

        printInfo("[SocketManager] [%s] cannot send packet: %s, invalid status: %s", 
            utils.timeStr(),
            protocols.Protocol[type],
            SocketManager.getStatusString())
    end
end

function SocketManager.onSocketEvent(event)
    printInfo("[SocketManager] [%s] event: %s", utils.timeStr(), event.name)
    if event.name == cc.net.SocketTCP.EVENT_CONNECTED then
        printInfo("[SocketManager] ################### [%s]", SocketManager._socket.tcp:getsockname())
        SocketManager.switchStatus(SocketManager.S_CONNECTED)
        FSM:doEvent(FSM.E_CONNECTED)
    elseif event.name == cc.net.SocketTCP.EVENT_CLOSE then
        local GlobalStatus = APP:getObject("GlobalStatus")
        GlobalStatus:setProperties({
            is_logined = false,
        })        
    elseif event.name == cc.net.SocketTCP.EVENT_CLOSED then
        local GlobalStatus = APP:getObject("GlobalStatus")
        GlobalStatus:setProperties({
            is_logined = false,
        }) 
        local msg = {}
        msg.socket_close = true
        table.insert(SocketManager._msgQueue, msg)
        -- SocketManager.switchStatus(SocketManager.S_DISCONNECTED)
        -- FSM:doEvent(FSM.E_DISCONNECTED)
        -- APP:getCurrentController():hideWaiting()
    elseif event.name == cc.net.SocketTCP.EVENT_CONNECT_FAILURE then
    else
        assert(0, "[SocketManager] unknown event")
    end
end

function SocketManager.onSocketData(event)
    -- printInfo("[SocketManager] receive data")
    local __msgs = SocketManager._packetBuffer:parsePackets(event.data)
    local __msg = nil
    for i = 1, #__msgs do
        __msg = __msgs[i]
        -- printInfo("[SocketManager] [%s] receive packet: %s", 
        --     utils.timeStr(),
        --     protocols.Protocol[__msg.type])
        table.insert(SocketManager._msgQueue, __msg)
    end
end

function SocketManager.handleMessages()
    if SocketManager._blocked then
        return
    end
    
    SocketManager.SEQUENCE = SocketManager.SEQUENCE + 1
    if #SocketManager._msgQueue > 0 then
        local __msg = SocketManager._msgQueue[1]
        table.remove(SocketManager._msgQueue, 1)
        if __msg.socket_close then
            APP:getCurrentController():hideWaiting()
            if SocketManager.getStatus() ~= SocketManager.S_DISCONNECTED then
                SocketManager.switchStatus(SocketManager.S_DISCONNECTED)
                FSM:doEvent(FSM.E_DISCONNECTED)
            end
        else
            if not SocketManager.isNotPrintCmd(__msg.type) then
                printInfo("[SocketManager] [%d] [%s] handle packet: %s", 
                    SocketManager.SEQUENCE,
                    utils.timeStr(),
                    protocols.Protocol[__msg.type] or __msg.type)
            end
            SocketHandlers.handleMessage(__msg)
        end
    end
end

function SocketManager.blockMessage()
    SocketManager._blocked = true
end

function SocketManager.unblockMessage()
    SocketManager._blocked = false
end

return SocketManager