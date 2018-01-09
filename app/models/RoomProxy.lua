local GameConfig = require("app.core.GameConfig")
local protocols = require("app.protocol.init")
local RoomProxy = class("RoomProxy")

function RoomProxy:ctor()
    self._RoomId = 0
    self._RoomUsers = {}
end

function RoomProxy:loadByPB(pb)
    self._RoomId = pb.room_id
    self._RoomUsers = pb.room_users
end

function RoomProxy:getMyRoomInfo()
    local _out = nil
    local User = APP:getObject("User")
    for _,v in ipairs(self._RoomUsers) do
        if v.base_user.user_id == User.user_id then
            _out = v
            break
        end
    end
    return _out
end

function RoomProxy:getPlayerRoomInfo()
    local _out = {}
    local User = APP:getObject("User")
    for _,v in ipairs(self._RoomUsers) do
        if v.base_user.user_id ~= User.user_id then
            table.insert(_out, v)
        end
    end
    return _out
end

return RoomProxy