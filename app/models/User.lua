local GameConfig = require("app.core.GameConfig")
local protocols = require("app.protocol.init")

local User = class("User")

function User:ctor()
    self.user_id = GameConfig.INVALID_ID
    self.nickname = ""
    
    -- data
    self.data = {}
    self._checkDatakeyValue = 
    {
        Coin = 0,
        GuankaId = 0,
    }
end

function User:setNickName(nickname)
    self.nickname = nickname
end

function User:getInitData()
    local _data = {}
    return _data
end

function User:fixData(data)
    for checkKey, checkValue in pairs(self._checkDatakeyValue) do
        local _haveCheckKey = false
        for k,v in pairs(data) do
            if k == checkKey then
                _haveCheckKey = true
            end
        end
        if not _haveCheckKey then
            data[checkKey] = checkValue
        end
    end
    return data
end

function User:loadData(data)
    self.data = data
end

function User:getData()
    return self.data
end

return User