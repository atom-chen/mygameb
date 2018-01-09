--
-- Author: gerry
-- Date: 2016-06-22 18:59:20
--
local GameConfig = require("app.core.GameConfig")
local GameUtils = require("app.core.GameUtils")
local SocketManager = require("app.core.SocketManager")
local HttpManager = require("app.core.HttpManager")
local protocols = require("app.protocol.init")
local json = require("framework.json")
local utils = require("app.common.utils")

local WeixinLoginCommand = {}

function WeixinLoginCommand.execute(code)
	dump(HttpManager.urlWeixinAccessToken(code))
	
    local request = z.CurlManager:getInstance():sendCommandForLua(
        HttpManager.urlWeixinAccessToken(code), GameConfig.METHOD_GET, "")
    GameUtils.registerHttpHandler(request, WeixinLoginCommand.accessTokenCallback)
end

function WeixinLoginCommand.accessTokenCallback(request)
    if request:getCode() ~= 0 then 
        WeixinLoginCommand.registerFailed(request:getCode())
        return 
    end

    local response = json.decode(request:getResult())
    if response.access_token == nil or response.access_token == "" then
        WeixinLoginCommand.registerFailed(-1)
        return
    end

    printInfo("[WeixinLoginCommand] get access_token succ, [access_token|%s] [openid|%s]", 
        response.access_token, response.openid)


    local request = z.CurlManager:getInstance():sendCommandForLua(
        HttpManager.urlWeixinUserInfo(response.access_token, response.openid), GameConfig.METHOD_GET, "")
    GameUtils.registerHttpHandler(request, WeixinLoginCommand.userInfoCallback)    
end

function WeixinLoginCommand.userInfoCallback(request)
    if request:getCode() ~= 0 then 
        WeixinLoginCommand.registerFailed(request:getCode())
        return 
    end

    local response = json.decode(request:getResult())
    if response.nickname == nil or response.nickname == "" then
        WeixinLoginCommand.registerFailed(-1)
        return
    end

    dump(response)

    printInfo("[WeixinLoginCommand] get user_info succ, [nickname|%s] [openid|%s]", 
        response.nickname, response.openid)
    local gender = 0
    if response.sex == 2 then
        gender = 1
    end

    local deviceId = ""--GameUtils.getFinalIdentifier()

    APP:command("RegisterAccountCommand", {
        userType = protocols.defines_pb.UT_WX, 
        account = response.openid,
        password = crypto.md5(response.openid .. "(@&is71h^Fb2s)"),
        avatar = response.headimgurl,
        nickname = response.nickname,
        gender = gender,
        device_id = deviceId,
        device_type = device.platform,
        sign = crypto.md5(device.platform .. deviceId .. "(*@638&8I*H@s2)"),
    })
end



function WeixinLoginCommand.registerFailed(code)
    printInfo("[WeixinLoginCommand] register failed, [code|%d]", code)
    APP:getCurrentController():hideWaiting()
    APP:getCurrentController():showAlertOK({desc = "微信注册失败"})
end

return WeixinLoginCommand