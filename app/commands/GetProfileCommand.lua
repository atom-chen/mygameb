--
-- Author: gerry
-- Date: 2016-06-21 16:09:36
--

local GameConfig = require("app.core.GameConfig")
local SocketManager = require("app.core.SocketManager")
local protocols = require("app.protocol.init")

local GetProfileCommand = {}

function GetProfileCommand.execute(options)
	local user = APP:getObject("User")
	options.option = options.option or 1 
	if options.option == 1 then
		if user.user_id == options.user_id then
			APP:getCurrentController():hideWaiting()
			APP:getCurrentController():showAlert(APP:createView("SelfPlayerProfile"))
			return
		end
	    local request = protocols.user_pb.GetUsersRequest()
	    request.user_ids:append(tonumber(options.user_id))
	    request.option = options.option
	    SocketManager.send(protocols.command_pb.CMD_GET_USERS_REQ, request)

	elseif options.option == 2 then
		local request = protocols.user_pb.GetUsersRequest()
		for i, user_id in ipairs(options.user_ids) do
		    request.user_ids:append(tonumber(user_id))
		end
		request.option = options.option
	    SocketManager.send(protocols.command_pb.CMD_GET_USERS_REQ, request)
	elseif options.option == 3 then
	    local request = protocols.user_pb.GetUsersRequest()
	    request.user_ids:append(tonumber(options.user_id))
	    request.option = options.option
	    SocketManager.send(protocols.command_pb.CMD_GET_USERS_REQ, request)
	end

	APP:getCurrentController():showWaiting()
end

return GetProfileCommand