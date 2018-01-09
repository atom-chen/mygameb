local GameConfig = require("app.core.GameConfig")
local GameUtils = require("app.core.GameUtils")
local SocketManager = require("app.core.SocketManager")
local HttpManager = require("app.core.HttpManager")
local protocols = require("app.protocol.init")
local json = require("framework.json")
local utils = require("app.common.utils")

local RegisterAccountCommand = {}

function RegisterAccountCommand.execute(options)
    local localDataManager = z.LocalDataManager:getInstance()
    local nickname = ""
    local rand = math.random 
    math.randomseed(utils.getRandomSeed())
    if options.nickname then
        nickname = options.nickname
    else
        nickname = "手机用户" .. rand(100000)
    end
    local deviceId = GameUtils.getFinalIdentifier()

    local gender = rand(2)
    if gender == 2 then
        gender = 0
    end
    
    local body = json.encode({
        user_type = options.userType, 
        account = options.account,
        password = options.password,
        device_id = options.deviceId or deviceId,
        name = nickname,
        gender = options.gender or gender,
        avatar = options.avatar or "",
        platform = GAME_PLATFORM,
        device_type = device.platform,
        sign = crypto.md5(device.platform .. deviceId .. "(*@638&8I*H@s2)"),
    })
    local request = z.CurlManager:getInstance():sendCommandForLua(
        HttpManager:urlRegister(), GameConfig.METHOD_POST, body)
    GameUtils.registerHttpHandler(request, RegisterAccountCommand.registerCallback)
end

function RegisterAccountCommand.registerCallback(request)
    if request:getCode() ~= 0 then 
        RegisterAccountCommand.registerFailed(request:getCode())
        return 
    end

    local response = json.decode(request:getResult())
    if response.code ~= protocols.Protocol.CODE_SUCCESS then
        RegisterAccountCommand.registerFailed(response.code)
        return
    end

    printInfo("[RegisterAccountCommand] register succ, [user|%d] [type|%d] [account|%s] [password|%s]", 
        response.data.user_id, response.data.user_type, response.data.account, response.data.password)

    local globalStatus = APP:getObject("GlobalStatus")
    globalStatus:setProperties({
        user_id = response.data.user_id,
        account = response.data.account,
        password = response.data.password,
        user_type = response.data.user_type,
    })
    local localDataManager = z.LocalDataManager:getInstance()
    -- if response.data.user_type ~= protocols.defines_pb.UT_WX then
        -- save to local data(xml)
        localDataManager:setIntegerForKey(GameConfig.LocalData_UserType, response.data.user_type)
        localDataManager:setStringForKey(GameConfig.LocalData_Account, response.data.account)
        localDataManager:setStringForKey(GameConfig.LocalData_Password, response.data.password)

    -- end

    if response.data.user_type == protocols.defines_pb.UT_GUEST then
        localDataManager:setStringForKey(GameConfig.LocalData_GuestAccount, response.data.account)
        localDataManager:setStringForKey(GameConfig.LocalData_GuestPassword, response.data.password)
        globalStatus:setProperties({
            login_options = {useGuest = true}
        })
    else    
        globalStatus:setProperties({
            login_options = {useGuest = false}
        })
    end

    localDataManager:flush()

    if SocketManager.getStatus() == SocketManager.S_CONNECTED then
        -- auth
        local authRequest = protocols.base_pb.AuthRequest()
        authRequest.user_type =response.data.user_type
        authRequest.account = response.data.account
        authRequest.password = response.data.password
        SocketManager.send(protocols.command_pb.CMD_AUTH_REQ, authRequest)
    else
        SocketManager.connect()
    end
end

function RegisterAccountCommand.registerFailed(code)
    printInfo("[RegisterAccountCommand] register failed, [code|%d]", code)
    APP:getCurrentController():hideWaiting()
    if code == 1 then
        APP:getCurrentController():showAlertOK({desc = "网络连接失败，请重新尝试登陆"})
    elseif code == 9 then
        APP:getCurrentController():showAlertOK({desc = "该用户名已经被注册"})
    else
        APP:getCurrentController():showAlertOK({desc = "注册失败"})
    end
end

return RegisterAccountCommand