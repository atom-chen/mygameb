

local GameConfig = require("app.core.GameConfig")

local GlobalStatus = class("GlobalStatus", cc.mvc.ModelBase)

-- 定义属性
GlobalStatus.schema = clone(cc.mvc.ModelBase.schema)
GlobalStatus.schema["loading_progress_net"]     = {"number", 0}
GlobalStatus.schema["loading_progress_resource"]= {"number", 0}
GlobalStatus.schema["load_to_scene"]            = {"string", nil}
GlobalStatus.schema["is_auto_login"]            = {"number", 0}
GlobalStatus.schema["is_logined"]               = {"boolean", false}
GlobalStatus.schema["last_enter_room_code"]     = {"number", 0}

GlobalStatus.schema["user_id"]                  = {"number", 0}
GlobalStatus.schema["user_type"]                = {"number", 0}
GlobalStatus.schema["account"]                  = {"string", ""}
GlobalStatus.schema["password"]                 = {"string", ""}
GlobalStatus.schema["room"]                     = {"table", {}}



function GlobalStatus:ctor(properties)
    GlobalStatus.super.ctor(self, properties)
end



function GlobalStatus:getLoadingProgress()
    return self.loading_progress_net_ + self.loading_progress_resource_
end

function GlobalStatus:getLoadToScene()
    return self.load_to_scene_
end



function GlobalStatus:getAutoLogin()
    return self.is_auto_login_
end

function GlobalStatus:getIsLogined()
    return self.is_logined_
end

function GlobalStatus:getLastEnterRoomCode()
    return self.last_enter_room_code_
end

function GlobalStatus:getLoginOptions()
    return self.login_options_
end

function GlobalStatus:getUserId()
    return self.user_id_
end

function GlobalStatus:getUserType()
    return self.user_type_
end

function GlobalStatus:getAccount()
    return self.account_
end

function GlobalStatus:getPassword()
    return self.password_
end

function GlobalStatus:getRoom()
    return self.room_
end










return GlobalStatus