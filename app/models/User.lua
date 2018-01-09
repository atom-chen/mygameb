local GameConfig = require("app.core.GameConfig")
local protocols = require("app.protocol.init")

local User = class("User")

function User:ctor()
    self.user_id = GameConfig.INVALID_ID
    self.name = ""
    self.avatar = ""
    self.signature = ""
    self.gender = 0
    self.coin = 0
    self.diamond = 0
    self.vip_level = 0
    self.vip_exp = 0
    self.voice_index = 1 
    self.token = ""
    self.oid = ""

    self.rec = 0
    self.back = 0
    self.tips = 0
    self.data = {}
end

function User:loadByPBBaseUser(pbBaseUser)
    self.user_id = pbBaseUser.user_id
    self.name = pbBaseUser.name
    self.avatar = pbBaseUser.avatar
    self.signature = pbBaseUser.signature
    self.gender = pbBaseUser.gender
    self.coin = pbBaseUser.coin
    self.diamond = pbBaseUser.diamond
    self.vip_level = pbBaseUser.vip_level

    if self.avatar == "" then
        self.avatar = "1"
    end
end

return User