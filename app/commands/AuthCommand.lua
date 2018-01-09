--
-- Author: gerry
-- Date: 2016-01-11 16:32:06
--
local protocols = require("app.protocol.init")
local GameConfig = require("app.core.GameConfig")
local GameUtils = require("app.core.GameUtils")
local SocketManager = require("app.core.SocketManager")
local HttpManager = require("app.core.HttpManager")
local json = require("framework.json")
local utils = require("app.common.utils")

local AuthCommand = {}

function AuthCommand.execute()
    local GlobalStatus = APP:getObject("GlobalStatus")
    local user_type = GlobalStatus:getUserType()
    local account = GlobalStatus:getAccount()
    local password = GlobalStatus:getPassword()

    local authRequest = protocols.base_pb.AuthRequest()
    authRequest.user_type = user_type
    authRequest.account = account
    authRequest.password = password
    SocketManager.send(protocols.command_pb.CMD_AUTH_REQ, authRequest)
    
    printInfo("[userType|%d] [account|%s] [password|%s]", authRequest.user_type, authRequest.account, authRequest.password)

    -- local options = options or {}
    -- local localDataManager = z.LocalDataManager:getInstance()

    -- if options.useGuest then
    --     if localDataManager:getStringForKey(GameConfig.LocalData_GuestAccount) == "" or
    --         localDataManager:getStringForKey(GameConfig.LocalData_GuestPassword) == "" then
    --         -- AuthCommand.registerGuest()
    --     else
    --         -- 用游客登录
    --         local authRequest = protocols.base_pb.AuthRequest()
    --         authRequest.user_type = GameConfig.UT_Guest
    --         authRequest.account = localDataManager:getStringForKey(GameConfig.LocalData_GuestAccount)
    --         authRequest.password = localDataManager:getStringForKey(GameConfig.LocalData_GuestPassword)
    --         SocketManager.send(protocols.command_pb.CMD_AUTH_REQ, authRequest)

    --         GlobalStatus:setProperties({
    --             account = authRequest.account,
    --             user_type = authRequest.user_type,
    --             password = authRequest.password,
    --         })

    --         printInfo("[userType|%d] [account|%s] [password|%s]", authRequest.user_type, authRequest.account, authRequest.password)
    --     end
    -- elseif options.userType == nil or options.account == nil or options.password == nil then
    --     printInfo("xxxxxxxxxxxxxxx %d", 1)
    --     -- 检查上次登录账户
    --     if localDataManager:getStringForKey(GameConfig.LocalData_Account) == "" or
    --         localDataManager:getStringForKey(GameConfig.LocalData_Password) == "" then
    --             -- AuthCommand.registerGuest()
    --     else
    --         -- auth
    --         local authRequest = protocols.base_pb.AuthRequest()
    --         authRequest.user_type = localDataManager:getIntegerForKey(GameConfig.LocalData_UserType)
    --         authRequest.account = localDataManager:getStringForKey(GameConfig.LocalData_Account)
    --         authRequest.password = localDataManager:getStringForKey(GameConfig.LocalData_Password)
    --         SocketManager.send(protocols.command_pb.CMD_AUTH_REQ, authRequest)
            
    --         GlobalStatus:setProperties({
    --             account = authRequest.account,
    --             user_type = authRequest.user_type,
    --             password = authRequest.password,
    --         })
            
    --         printInfo("[userType|%d] [account|%s] [password|%s]", authRequest.user_type, authRequest.account, authRequest.password)
    --     end
    -- else
    --     -- auth
    --     local authRequest = protocols.base_pb.AuthRequest()
    --     authRequest.user_type = options.userType
    --     authRequest.account = options.account
    --     authRequest.password = options.password
    --     SocketManager.send(protocols.command_pb.CMD_AUTH_REQ, authRequest)

    --     GlobalStatus:setProperties({
    --         account = options.account,
    --         user_type = options.userType,
    --         password = options.password,
    --     })
        
    --     printInfo("[userType|%d] [account|%s] [password|%s]", authRequest.user_type, authRequest.account, authRequest.password)
    -- end
end

function AuthCommand.registerGuest()
    -- 生成游客账户
    -- local account = ""
    -- local password = ""
    -- local nickname = z.DeviceUtility:getInstance():getDeviceName()
    -- if device.platform == "android" then
    --     account = crypto.md5(z.DeviceUtility:getInstance():getDeviceIdentifier())
    --     password = crypto.md5(account .. "(@&is71h^Fb2s)")
    -- else
    --     account = z.MyUUID:new():get32CharString()
    --     password = z.MyUUID:new():get32CharString()
    -- end
    -- printInfo("platform %s, account %s", device.platform, account)
    -- APP:command("RegisterAccountCommand", {
    --     userType = 0, 
    --     account = account,
    --     password = password
    -- })
end

function AuthCommand.registerPlatformAccount(platform)
    if platform == GameConfig.UT_QQ then
        local account = ""--z.XYSDKManager:getInstance():getUserId()
        local name = ""--z.TuTwIosSDKManager:getInstance():getName()
        local password = crypto.md5(account .. "(&U2nfj2s912j)")
        APP:command("RegisterAccountCommand", {
            userType = GameConfig.UT_QQ, 
            account = account,
            password = password,
            nickname = name
        })

    elseif platform == GameConfig.UT_Wechat then
        local account = ""--z.XYSDKManager:getInstance():getUserId()
        local name = ""--z.TuTwIosSDKManager:getInstance():getName()
        local password = crypto.md5(account .. "(&U2nfj2s912j)")
        APP:command("RegisterAccountCommand", {
            userType = GameConfig.UT_Wechat, 
            account = account,
            password = password,
            nickname = name
        })

    
    end
end


return AuthCommand