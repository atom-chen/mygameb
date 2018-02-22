
local GameUtils = require("app.core.GameUtils")
local GameConfig = require("app.core.GameConfig")
local HttpManager = require("app.core.HttpManager")
local json = require("framework.json")
local protocols = require("app.protocol.init")

local UserManager = {}

function UserManager.init()
    -- 取一个全局共享node当绑定载体
    local node = cc.Director:getInstance():getNotificationNode()
    
    GameUtils.registerScriptHandler(node, UserManager.onGCLoginSucc,
        GameConfig.Handler.EVENT_CHANNEL_GC_LOGIN_SUCCESS)
    GameUtils.registerScriptHandler(node, UserManager.onGCLoginFail,
        GameConfig.Handler.EVENT_CHANNEL_GC_LOGIN_FAILED)
    GameUtils.registerScriptHandler(node, UserManager.dataSucc,
        GameConfig.Handler.EVENT_CHANNEL_GC_DATA_SUCCESS)
    GameUtils.registerScriptHandler(node, UserManager.dataFail,
        GameConfig.Handler.EVENT_CHANNEL_GC_DATA_FAILED)

end

function UserManager.GCLogin()
    z.IOSManager:getInstance():GameCenterLogin()
end

function UserManager.onGCLoginSucc(data)
    printInfo("[UserManager] ---------> onGCLoginSucc")
    local _data = json.decode(data)
    local user = APP:getObject("User")
    user:setNickName(_data.nickname)

    z.IOSManager:getInstance():getData("game_1")


    --test
    -- z.IOSManager:getInstance():loadLocalPlayerPhoto();
    -- z.IOSManager:getInstance():loadFriendPlayersWithCompletionHandler();
    
end

function UserManager.onGCLoginFail(data)
    printInfo("[UserManager] ---------> onGCLoginFail")
    local dataObject = json.decode(data)
    APP:getCurrentController():hideWaiting()
    APP:getCurrentController():showAlertOK({
        desc = "login fail domain:".. tostring(dataObject.domain),
    })
    -- 登录失败，启动重登流程
end

function UserManager.setData(data)
    local data_json = json.encode(data)
    local data_base64 = GameUtils.encodeBase64(_a)
    z.IOSManager:getInstance():setData("game_1", data_base64)
end

function UserManager.dataSucc(data_base64)
    printInfo("[UserManager] ---------> dataSucc")
    local data_json = GameUtils.decodeBase64(data_base64)
    local data = json.decode(data_json)

    local user = APP:getObject("User")
    -- 修复 data
    data = user:fixData(data)
    -- load data
    user:loadData(data)

    if APP:isObjectExists("RegiseterController") then
        APP:getObject("RegiseterController"):userLogin()
    end
end

function UserManager.dataFail(data)
    printInfo("[UserManager] ---------> dataFail")
    local _data = json.decode(data)
    local _type = _data.type
    local _domain = _data.domain
    if _type == "get" then
        if _domain == "type_empty" then
            -- init data
            local user = APP:getObject("User")
            local initdata = user:getInitData()

            UserManager.setData(initdata)

        else
            APP:getCurrentController():hideWaiting()
            APP:getCurrentController():showAlertOK({
                desc = "get data fail: ".. tostring(_domain),
            })
        end
    elseif _type == "set" then
        APP:getCurrentController():hideWaiting()
        APP:getCurrentController():showAlertOK({
            desc = "set data fail: ".. tostring(_domain),
        })
    end
end

return UserManager