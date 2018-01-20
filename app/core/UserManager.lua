
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

end

function UserManager.onGCLoginSucc(data)
    printInfo("[UserManager] ---------> onGCLoginSucc")
    APP:getCurrentController():hideWaiting()
    APP:getCurrentController():showAlertOK({
        desc = "game center 登录成功"
    })

    z.IOSManager:getInstance():loadLocalPlayerPhoto();
    z.IOSManager:getInstance():loadFriendPlayersWithCompletionHandler();
end

function UserManager.onGCLoginFail(data)
    printInfo("[UserManager] ---------> onGCLoginFail")
    local dataObject = json.decode(data)

    APP:getCurrentController():hideWaiting()
    APP:getCurrentController():showAlertOK({
        desc = "Game Center domain:".. tostring(dataObject.domain),
    })
end

-- <key>CFBundleURLTypes</key>
-- <array>
--   <dict>
--   <key>CFBundleURLSchemes</key>
--   <array>
--     <string>fb2306274129398683</string>
--   </array>
--   </dict>
-- </array>
-- <key>FacebookAppID</key>
-- <string>2306274129398683</string>
-- <key>FacebookDisplayName</key>
-- <string>欧拉拉小星球</string>

return UserManager