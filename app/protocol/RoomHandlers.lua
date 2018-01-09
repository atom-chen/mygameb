local GameConfig = require("app.core.GameConfig")
local GameUtils = require("app.core.GameUtils")
local protocols = require("app.protocol.init")
local Protocol = protocols.Protocol
local models = require("app.models.init")
local RoomHandlers = {}

RoomHandlers.poorNotify = {}

function RoomHandlers.isRoomMessage(type)
    
    return false    
end



function RoomHandlers.handleRoomEnterResponse(payload)
    local response = protocols.base_pb.EnterRoomResponse()
    response:ParseFromString(payload)
    
    if response.code == Protocol.CODE_SUCCESS then
    	local GlobalStatus = APP:getObject("GlobalStatus")
		local RoomProxy = models.RoomProxy.new()
		RoomProxy:loadByPB(response)
        GlobalStatus:setProperties({
            room = RoomProxy,
        })

    	APP:enterScene("TestScene")
    end
end

function RoomHandlers.handleRoomNotifyEnter(payload)
	local response = protocols.base_pb.NotifyEnterRoom()
    response:ParseFromString(payload)

    local GlobalStatus = APP:getObject("GlobalStatus")
    local RoomProxy = GlobalStatus:getRoom()
    RoomProxy._RoomUsers = response.room_users

    if APP:isObjectExists("TestController") then
        APP:getObject("TestController"):handleRoomNotifyEnter(response.user)
    end 
end

function RoomHandlers.handleRoomNotifyLeave(payload)
	print("================ handleRoomNotifyLeave ")
	local response = protocols.base_pb.NotifyLeaveRoom()
    response:ParseFromString(payload)

    local GlobalStatus = APP:getObject("GlobalStatus")
    local RoomProxy = GlobalStatus:getRoom()
    RoomProxy._RoomUsers = response.room_users

    if APP:isObjectExists("TestController") then
        APP:getObject("TestController"):handleRoomNotifyLeave(response.user)
    end 
end




return RoomHandlers