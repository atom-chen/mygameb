local GameConfig = require("app.core.GameConfig")

local GameEnv = require("app.core.GameEnv")

local HttpManager = {}

HttpManager.PREFIX = ""

function HttpManager.restHttpPrefix()
    local env = GameEnv.getHttpRestEnv()
    return HttpManager.PREFIX .. env.host .. ":" .. env.port
end

function HttpManager.payHttpPrefix()
    local env = GameEnv.getHttpPayEnv()
    return HttpManager.PREFIX .. env.host .. ":" .. env.port
end

function HttpManager.urlEcho()
    return HttpManager.restHttpPrefix() .. "/api/echo"
end

function HttpManager.urlCheck()
    return HttpManager.restHttpPrefix() .. "/api/check"
end

function HttpManager.urlRegister()
    return HttpManager.restHttpPrefix() .. "/api/register"
end

function HttpManager.urlBind()
    return HttpManager.restHttpPrefix() .. "/api/bind"
end

function HttpManager.urlResetPassword()
    return HttpManager.restHttpPrefix() .. "/api/reset_password"
end

function HttpManager.urlChangePassword()
    return HttpManager.restHttpPrefix() .. "/api/change_password"
end

function HttpManager.urlIOSPay()
    return HttpManager.restHttpPrefix() .. "/api/ios_pay"
end

function HttpManager.urlGetFreeClientVersion()
    return HttpManager.restHttpPrefix() .. "/api/client_version"
end

function HttpManager.urlWeixinAccessToken(code)
    local url = "https://api.weixin.qq.com/sns/oauth2/access_token?" 
    url = url .."appid=".. GameConfig.WEI_XIN_APP_ID .."&secret=" .. GameConfig.WEI_XIN_APP_SECRET .. "&code=" .. code .."&grant_type=authorization_code"
    return url
end

function HttpManager.urlWeixinUserInfo(token,openId)
    local url = "https://api.weixin.qq.com/sns/userinfo?" 
    url = url .."access_token=".. token .."&openid=" .. openId
    return url
end


-----------------------------------------
function HttpManager.urlMain()
    return "http://jielong.zenistgame.com:7001" .. "/api/"
end

return HttpManager