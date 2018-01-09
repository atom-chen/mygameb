
local GameConfig = require("app.core.GameConfig")
local SocketManager = require("app.core.SocketManager")
local protocols = require("app.protocol.init")

local SendMessageCommand = {}

function SendMessageCommand.execute(options)
    local request = protocols.message_pb.MessageRequest()
    request.type = options.type
    request.content = options.content
    request.to = options.to
    if options.record_time ~= nil then
	    request.record_time = options.record_time
    end
    SocketManager.send(protocols.command_pb.CMD_MESSAGE_REQ, request)
end

return SendMessageCommand