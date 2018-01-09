--
-- Author: gerry
-- Date: 2016-06-21 16:09:36
--

local GameConfig = require("app.core.GameConfig")
local SocketManager = require("app.core.SocketManager")
local protocols = require("app.protocol.init")

local GetRoomsCommand = {}

function GetRoomsCommand.execute(options)
    local request = protocols.base_pb.GetRoomsRequest()
    request.game_type = options.game_type
    SocketManager.send(protocols.command_pb.CMD_GET_ROOMS_REQ, request)
	APP:getCurrentController():showWaiting()
end

return GetRoomsCommand