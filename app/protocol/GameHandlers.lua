local GameConfig = require("app.core.GameConfig")
local GameUtils = require("app.core.GameUtils")
local protocols = require("app.protocol.init")
local Protocol = protocols.Protocol
local models = require("app.models.init")
local GameHandlers = {}

GameHandlers.poorNotify = {}

function GameHandlers.isGameMessage(type)
    
    return false    
end

function GameHandlers.handleGameMoveResponse(payload)

end

function GameHandlers.handleGameNotifyMove(payload)
    local response = protocols.game_pb.NotifyMove()
    response:ParseFromString(payload)
    if APP:isObjectExists("TestController") then
        APP:getObject("TestController"):handleGameNotifyMove(response)
    end
end







return GameHandlers