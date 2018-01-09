
local scheduler = require("framework.scheduler")
local GameConfig = require("app.core.GameConfig")
local HttpManager = require("app.core.HttpManager")
local utils = require("app.common.utils")
local protocols = require("app.protocol.init")

local GameUtils = {}

GameUtils.CurrentMusic = nil
GameUtils.CurrentVolume = 1.0

function GameUtils.registerScriptHandler(object, handler, type)
    ScriptHandlerMgr:getInstance():registerScriptHandler(object, handler, type)
end

function GameUtils.registerHttpHandler(object, handler)
    ScriptHandlerMgr:getInstance():registerScriptHandler(object, handler, 
        GameConfig.Handler.EVENT_COMMON_HTTP_CALLBACK)
end

function GameUtils.registerHttpProgressHandler(object, handler)
    ScriptHandlerMgr:getInstance():registerScriptHandler(object, handler, 
        GameConfig.Handler.EVENT_COMMON_HTTP_PROGRESS_CALLBACK)
end

function GameUtils.upYunUrl(bucket, path, file)
    -- body
end

function GameUtils.changeSWMusic()
    local localDataManager = z.LocalDataManager:getInstance()
    local swMusic = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_Music)
    if swMusic == GameConfig.SW_DEFAULT or swMusic == GameConfig.SW_ON then
        localDataManager:setIntegerForKey(GameConfig.LocalData_SW_Music, GameConfig.SW_OFF)
        GameUtils.stopMusic()
    else
        localDataManager:setIntegerForKey(GameConfig.LocalData_SW_Music, GameConfig.SW_ON)
        GameUtils.playCurrentGameMusic()
    end
    localDataManager:flush()
end

function GameUtils.changeSWSound()
    local localDataManager = z.LocalDataManager:getInstance()
    local swSound = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_Sound)
    if swSound == GameConfig.SW_DEFAULT or swSound == GameConfig.SW_ON then
        localDataManager:setIntegerForKey(GameConfig.LocalData_SW_Sound, GameConfig.SW_OFF)
    else
        localDataManager:setIntegerForKey(GameConfig.LocalData_SW_Sound, GameConfig.SW_ON)
    end
    localDataManager:flush()
end

function GameUtils.changeSWVibrate()
    local localDataManager = z.LocalDataManager:getInstance()
    local swVibrate = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_Vibrate)
    if swVibrate == GameConfig.SW_DEFAULT or swVibrate == GameConfig.SW_ON then
        localDataManager:setIntegerForKey(GameConfig.LocalData_SW_Vibrate, GameConfig.SW_OFF)
    else
        localDataManager:setIntegerForKey(GameConfig.LocalData_SW_Vibrate, GameConfig.SW_ON)
    end
    localDataManager:flush()
end

function GameUtils.changeSWAutoPlayAudio()
    local localDataManager = z.LocalDataManager:getInstance()
    local swAutoPlayAudio = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_AutoPlayAudio)
    if swAutoPlayAudio == GameConfig.SW_DEFAULT or swAutoPlayAudio == GameConfig.SW_ON then
        localDataManager:setIntegerForKey(GameConfig.LocalData_SW_AutoPlayAudio, GameConfig.SW_OFF)
    else
        localDataManager:setIntegerForKey(GameConfig.LocalData_SW_AutoPlayAudio, GameConfig.SW_ON)
    end
    localDataManager:flush()
end

function GameUtils.stopMusic()
    if GameUtils._musicAudioId then
        ccexp.AudioEngine:stop(GameUtils._musicAudioId)
        GameUtils._musicAudioId = nil
    end
end

function GameUtils.playCurrentGameMusic()
    printInfo("playCurrentGameMusic")
    if GameUtils.CurrentMusic and not GameUtils._musicAudioId then
        GameUtils._musicAudioId = ccexp.AudioEngine:play2d(GameUtils.CurrentMusic, true)
        ccexp.AudioEngine:setVolume(GameUtils._musicAudioId, GameUtils.CurrentVolume)
    end
end

function GameUtils.playOutGameMusic()
    local music = "audio/bg_girl_1.mp3"
    local localDataManager = z.LocalDataManager:getInstance()
    local swMusic = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_Music)

    if not GameUtils.CurrentMusic or GameUtils.CurrentMusic ~= music then
        GameUtils.CurrentMusic = music
        if swMusic == GameConfig.SW_DEFAULT or swMusic == GameConfig.SW_ON then
            ccexp.AudioEngine:stopAll()
            GameUtils._musicAudioId = ccexp.AudioEngine:play2d(GameUtils.CurrentMusic, true, 1.0)
            ccexp.AudioEngine:setVolume(GameUtils._musicAudioId, GameUtils.CurrentVolume)
        end
    end
end

function GameUtils.playInGameMusic()
    local music = "audio/in_game_bg.mp3"
    local localDataManager = z.LocalDataManager:getInstance()
    local swMusic = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_Music)
    
    if not GameUtils.CurrentMusic or GameUtils.CurrentMusic ~= music then
        GameUtils.CurrentMusic = music
        if swMusic == GameConfig.SW_DEFAULT or swMusic == GameConfig.SW_ON then
            ccexp.AudioEngine:stopAll()
            GameUtils._musicAudioId = ccexp.AudioEngine:play2d(GameUtils.CurrentMusic, true, 1.0)
            ccexp.AudioEngine:setVolume(GameUtils._musicAudioId, GameUtils.CurrentVolume)
        end
    end
end

function GameUtils.playSifutouMusic()
    local music = "audio/sifutou/BG.mp3"
    local localDataManager = z.LocalDataManager:getInstance()
    local swMusic = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_Music)

    GameUtils.CurrentMusic = music
    if swMusic == GameConfig.SW_DEFAULT or swMusic == GameConfig.SW_ON then

        ccexp.AudioEngine:stopAll()
        GameUtils._musicAudioId = ccexp.AudioEngine:play2d(GameUtils.CurrentMusic, true, 1.0)
        ccexp.AudioEngine:setVolume(GameUtils._musicAudioId, GameUtils.CurrentVolume)
    end
end

function GameUtils.playSoundForce(...)
    local audioId = ccexp.AudioEngine:play2d(...)
    ccexp.AudioEngine:setVolume(audioId, 1.0)
end

function GameUtils.playSound(...)
    local localDataManager = z.LocalDataManager:getInstance()
    local swSound = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_Sound)
    if swSound == GameConfig.SW_DEFAULT or swSound == GameConfig.SW_ON then
        local audioId = ccexp.AudioEngine:play2d(...)
        ccexp.AudioEngine:setVolume(audioId, GameUtils.CurrentVolume)
    end
end

function GameUtils.playSoundAndRecord(...)
    local localDataManager = z.LocalDataManager:getInstance()
    local swSound = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_Sound)
    if swSound == GameConfig.SW_DEFAULT or swSound == GameConfig.SW_ON then
        GameUtils._recordSound = ccexp.AudioEngine:play2d(...)
        ccexp.AudioEngine:setVolume(GameUtils._recordSound, GameUtils.CurrentVolume)
        -- printInfo("GameUtils.playSoundAndRecord %d", GameUtils._recordSound)
    else
        GameUtils._recordSound = nil
    end
    return GameUtils._recordSound
end

function GameUtils.vibrate()
    local localDataManager = z.LocalDataManager:getInstance()
    local swVibrate = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_Vibrate)
    if swVibrate == GameConfig.SW_DEFAULT or swVibrate == GameConfig.SW_ON then
        z.DeviceUtility:getInstance():vibrate()
    end
end

function GameUtils.playCoinAnim(playEffect)
    if playEffect == nil or playEffect then
        GameUtils.playSound("audio/coins.mp3")
        GameUtils.playSound("audio/win.mp3")
    end
    local currentController = APP:getCurrentController()

    currentController:runAction(cca.seq({
        cca.cb(function() GameUtils._playCoinAnim() end),
        cca.delay(0.65),
        cca.cb(function() GameUtils._playCoinAnim() end),
        cca.delay(0.65),
        cca.cb(function() GameUtils._playCoinAnim() end),
        cca.delay(0.65),
        cca.cb(function() GameUtils._playCoinAnim() end),
        }))

end

function GameUtils._playCoinAnim()
    math.randomseed(socket.gettime())

    local currentController = APP:getCurrentController()

    local maxNumPerLine = 30
    for i = 1, maxNumPerLine do
        local moveSide = math.random(1, 6)
        local rotation = math.random(0, 180)
        local myrand = math.random(1, 20)
        local x = display.width / (maxNumPerLine + 2) * i
        local targetX = 0
        if moveSide % 2 == 0 then
            targetX = -math.random(1, 200)
        else
            targetX = math.random(1, 200)
        end

        local baseScale = 0.6
        local coinNode = display.newNode()
            :scale(baseScale)
            :rotation(rotation)
            :pos(x, display.height + 60)
            :zorder(GameConfig.Top_Z)
            :addTo(currentController)

        local anim1 = z.FrameAnimUtil:createAnim("cm-color", 12, -1)
        anim1:addTo(coinNode)

        local anim2 = z.FrameAnimUtil:createAnim("cm-glow", 12, -1)
        anim2:addTo(coinNode)

        local anim = z.FrameAnimUtil:createAnim("cm-specular", 12, -1)
        anim:addTo(coinNode)

        if i % 5 == 0 then
            anim1:setColor(cc.c3b(126, 0, 255))
            anim2:setColor(cc.c3b(255, 52, 229))
        elseif i % 5 == 1 then
            anim1:setColor(cc.c3b(230, 44, 19))
            anim2:setColor(cc.c3b(255, 106, 54))
        elseif i % 5 == 2 then
            anim1:setColor(cc.c3b(7, 129, 235))
            anim2:setColor(cc.c3b(68, 204, 255))
        elseif i % 5 == 3 then
            anim1:setColor(cc.c3b(26, 226, 125))
            anim2:setColor(cc.c3b(52, 237, 190))
        elseif i % 5 == 4 then
            anim1:setColor(cc.c3b(249, 147, 25))
            anim2:setColor(cc.c3b(255, 222, 0))
        end

        coinNode:runAction(cca.seq({
            cca.delay(myrand / 10),
            cca.spawn({
                cca.sineIn(cca.moveBy(1.6, targetX, - display.height - 100)),
                -- cca.scaleTo(0.5, baseScale + (myrand - 10) / 30)
                }),
            cca.removeSelf()
        }))
    end
end

-- 1: ios no-sse
-- 2: ios sse
-- 3: android
function GameUtils.getBallDataIndex(hardwareName)
    local index = 1
    local hnSplit = utils.stringSplit(hardwareName, " ")
    -- printInfo(">>>>>>>>>>>>> %s", hardwareName)
    if hardwareName == "" then
        return 3
    end

    -- for _, s in ipairs(hnSplit) do
    --     printInfo("     >>>> %s", s)
    -- end

    if hnSplit[1] == "android" then
        index = 3
    else
        if hnSplit[1] == "iPhone" then
            if hnSplit[2] == "1G" or hnSplit[2] == "3G" or hnSplit[2] == "3GS" or
                hnSplit[2] == "4" or hnSplit[2] == "4S" then
                index = 1
            else
                index = 2
            end

        elseif hnSplit[1] == "iPodTouch" then
            index = 1

        elseif hnSplit[1] == "iPad" then
            index = 1

        elseif hnSplit[1] == "Simulator" then
            index = 2
        end
    end
    printInfo("######################## ball index: %d", index)
    return index
end

function GameUtils.ScriptBridge_playEffect(filename)
    GameUtils.playSound(filename)
end

function GameUtils.ScriptBridge_playEffectAndRecord(filename)
    return GameUtils.playSoundAndRecord(filename)
end

function GameUtils.ScriptBridge_stopRecordedEffect()
    -- printInfo("GameUtils.ScriptBridge_stopRecordedEffect %d", GameUtils._recordSound)
    if GameUtils._recordSound then
        ccexp.AudioEngine:stop(GameUtils._recordSound)
        GameUtils._recordSound = nil
    end
end

function GameUtils.ScriptBridge_playAudio(filename)
    GameUtils.playSoundForce(filename)
end

function GameUtils.ScriptBridge_playAudioFailed(url)
    if APP:isObjectExists("TableMessagesNode") then
        local chatNode = APP:getObject("TableMessagesNode")
        chatNode:playAudioFailed(url)
    end
end

function GameUtils.ScriptBridge_playAudioBegin(url)
    if APP:isObjectExists("TableMessagesNode") then
        local chatNode = APP:getObject("TableMessagesNode")
        chatNode:finishLoadingAudio(url)
        chatNode:playingAudio(url)
    end

    z.AudioRecorder:getInstance():setAllVolumeLow()
    GameUtils.CurrentVolume = 0.1
end

function GameUtils.ScriptBridge_playAudioEnd(url)
    if APP:isObjectExists("TableMessagesNode") then
        local chatNode = APP:getObject("TableMessagesNode")
        chatNode:finishPlayingAudio(url)
    end

    z.AudioRecorder:getInstance():setAllVolumeHigh()
    GameUtils.CurrentVolume = 1.0
end

function GameUtils.ScriptBridge_playAudioStoped(url)
    if APP:isObjectExists("TableMessagesNode") then
        local chatNode = APP:getObject("TableMessagesNode")
        chatNode:finishPlayingAudio(url)
    end
    
    z.AudioRecorder:getInstance():setAllVolumeHigh()
    GameUtils.CurrentVolume = 1.0
end

function GameUtils.ScriptBridge_downloadAudio(url)
    if APP:isObjectExists("TableMessagesNode") then
        local chatNode = APP:getObject("TableMessagesNode")
        chatNode:loadingAudio(url)
    end
end

function GameUtils.startRecordAudio()
    z.AudioRecorder:getInstance():setAllVolumeLow()
    z.AudioRecorder:getInstance():startRecord()
    GameUtils.CurrentVolume = 0.1
end

function GameUtils.endRecordAudio()
    local result = z.AudioRecorder:getInstance():endRecord()
    z.AudioRecorder:getInstance():setAllVolumeHigh()
    GameUtils.CurrentVolume = 1.0
    return result
end

function GameUtils.getRecordVolume()
    return z.AudioRecorder:getInstance():getVolume()
end

function GameUtils.getPtNumStr(num)
    local out = ""
    local strNum = tostring(num)
    local len = string.len(strNum)
    if len >= 4 and len <= 6 then
        out = string.sub(strNum, 1, -4)..","..string.sub(strNum, len-2)
    elseif len >= 7 and len <= 9 then
        out = string.sub(strNum, 1, -7)..","..string.sub(strNum, len-5, -4)..","..string.sub(strNum, len-2)
    elseif len >= 10 and len <= 12 then
        out = string.sub(strNum, 1, -10)..","..string.sub(strNum, len-8, -7)..","..string.sub(strNum, len-5, -4)..","..string.sub(strNum, len-2)
    elseif len >= 13 and len <= 15 then
        out = string.sub(strNum, 1, -13)..","..string.sub(strNum, len-11, -10)..","..string.sub(strNum, len-8, -7)..","..string.sub(strNum, len-5, -4)..","..string.sub(strNum, len-2)
    else
        out = strNum
    end
    return out
end

function GameUtils.getAvatarImage(avatar)
    if avatar == "" then avatar = "1" end
    return string.format("image/%s.png", avatar)
end

function GameUtils.getChannel()
    if GAME_PLATFORM == GameConfig.GamePlatform_iOS then
        return "ios"
    elseif GAME_PLATFORM == GameConfig.GamePlatform_Android then
        return "android"
    end
end

function GameUtils.getChannelId()
    return GAME_PLATFORM
end

function GameUtils.getFinalIdentifier()
    local deviceId = z.DeviceUtility:getInstance():getDeviceIdentifier()
    if deviceId == "" then
        -- if device.platform ~= "mac" then
            local localDataManager = z.LocalDataManager:getInstance()
            deviceId = localDataManager:getStringForKey(GameConfig.LocalData_DEVICE_ID, "")
            if deviceId ~= "" then
                return deviceId
            end

            deviceId = z.MyUUID:new():get32CharString()

            localDataManager:setStringForKey(GameConfig.LocalData_DEVICE_ID, deviceId)
            localDataManager:flush()

            return deviceId
        -- end
    end
    return deviceId
end


-- size : 0 - 46
--        1 - 64
--        2 - 640
function GameUtils.getAvatar(avatar, size)
    local size = size or 0
    local s,_ = string.find(avatar, "http")

    if s == 1 then
        if size == 0 then
            avatar = string.sub(avatar, 1, #avatar-1) .. "46"
        elseif size == 1 then
            avatar = string.sub(avatar, 1, #avatar-1) .. "64"
        end
        return avatar,string.format("image/%s.png", "1")
    else
        if avatar == "" then avatar = "1" end
        return "",string.format("image/%s.png", avatar)
    end
end

function GameUtils.sendShareNew(stype,title,description,url,imagePath)
    APP:getCurrentController():showWaiting()
    APP:getCurrentController():runAction(cca.seq({cca.delay(0.1),cca.cb(function()
        local user = APP:getObject("User")
        url = url or "https://a.mlinks.cc/AKMV?user_id="..user.user_id
        title = title or "乐道溧阳3缺1"
        description = description or "第一款溧阳人自己的苹果&安卓手游！地道的溧阳规则麻将，地道的溧阳美女配音！"
        imagePath = imagePath or  "res/image/s7_120.png"
        local callbackLua = function(code) 
            if code == "no" then
                APP:getCurrentController():hideWaiting()
                APP:getCurrentController():showAlertOK({desc = "你没有安装微信，请安装微信使用这个功能"})
            else
                APP:getCurrentController():hideWaiting()
            end
        end 
        if device.platform == "android" then
            local className="com/jiyan/liyang/Weixin" --包名/类名 
            local args = {stype,url,title,description,imagePath,callbackLua}  
            local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V" --传入string参数，无返回值  

            local ok,ret = luaj.callStaticMethod(className,"weixinFenXiangNew",args,sigs)  
            if not ok then  
                APP:getCurrentController():hideWaiting()
                APP:getCurrentController():showAlertOK({desc = "您的版本过低，要使用房间分享功能请升级版本"})
            end  
        elseif device.platform == "ios" then
            local args = {
                stype = stype,
                listener = callbackLua,
                title = title,
                description = description,
                webpageUrl = url,
                imagePath = imagePath,
            }
            local ok, ret = luaoc.callStaticMethod("AppController", "sendLinkNew", args)
            if not ok then
                APP:getCurrentController():hideWaiting()
                APP:getCurrentController():showAlertOK({desc = "您的版本过低，要使用房间分享功能请升级版本"})
            end       
        end
    end)}))     
end

function GameUtils.sendShareImage(stype,imagePath)
    APP:getCurrentController():showWaiting()
    APP:getCurrentController():runAction(cca.seq({cca.delay(0.1),cca.cb(function()
        local callbackLua = function(code) 
                if code == "1" then
                    APP:getCurrentController():hideWaiting()
                elseif code == "2" then
                    APP:getCurrentController():hideWaiting()       
                else
                    APP:getCurrentController():hideWaiting()     
                end
            end 
        if device.platform == "android" then
            local className="com/zenist/jielong/FacebookSdkO" --包名/类名 
            local args = {stype, imagePath, callbackLua}  
            local sigs = "(Ljava/lang/String;Ljava/lang/String;I)V" --传入string参数，无返回值  

            local ok,ret = luaj.callStaticMethod(className,"shareImage",args,sigs)  
            if not ok then  
                dump("luaj failed") 
            end  
        elseif device.platform == "ios" then
           
        end
    end)}))     
end

function GameUtils.getParamFromUrl(url,key)
    local keyMap = {}
    local temp = utils.stringSplit(url, "?")
    temp = utils.stringSplit(temp[2], "&")
    for _,v in ipairs(temp) do
        local v2 = utils.stringSplit(v, "=")
        keyMap[v2[1]] = v2[2]
    end

    return keyMap[key]
end

function GameUtils.getFromUrl()
    local callbackLua = function(url)
        if url ~= "" then
            local code = GameUtils.getParamFromUrl(url,"room_code")
            if code ~= nil then
                dump(code)
                APP:getCurrentController():showWaiting()
                local request = protocols.private_room_pb.EnterPrivateRoomRequest()
                request.enter_code = code
                local result = SOCKET_MANAGER.send(protocols.command_pb.CMD_ENTER_PRIVATE_ROOM_REQ, request)
            end

            -- local uid = GameUtils.getParamFromUrl(url,"user_id")
            -- if uid ~= nil then
            --     local GlobalStatus = APP:getObject("GlobalStatus") 
            --     if GlobalStatus:getInviteUserId() == 0 and GlobalStatus:getIsCanSendInvite() then
            --         local request = protocols.base_pb.SetUserProfileRequest()
            --         request.invite_user_id = uid
            --         SOCKET_MANAGER.send(protocols.command_pb.CMD_SET_USER_PROFILE_REQ, request)  
            --     end
            -- end
        end
    end 
    if device.platform == "android" then
            local className="com/jiyan/liyang/MoWindow" --包名/类名 
            local args = {callbackLua}  
            local sigs = "(I)V" --传入string参数，无返回值  

            local ok,ret = luaj.callStaticMethod(className,"getOpenUrl",args,sigs)  
            if not ok then  
                dump("luaj failed") 
            end  
    elseif device.platform == "ios" then
        local args = {
                    listener = callbackLua,
                }
        local ok, ret = luaoc.callStaticMethod("AppController", "getOpenUrl", args)
        if not ok then
            print(string.format("AppController.getOpenUrl() - call API failure, error code: %s", tostring(ret)))
        end  
    end 
end

function GameUtils.setFromUrl()
    if device.platform == "android" then
        local className="com/jiyan/liyang/MoWindow" --包名/类名 
        local args = {"a"}  
        local sigs = "(Ljava/lang/String;)V" --传入string参数，无返回值  

        local ok,ret = luaj.callStaticMethod(className,"setOpenUrl",args,sigs)  
        if not ok then  
            dump("luaj failed") 
        end  
    elseif device.platform == "ios" then
        local args = {
                    desc = "",
                }
        local ok, ret = luaoc.callStaticMethod("AppController", "setOpenUrl", args)
        if not ok then
            print(string.format("AppController.getOpenUrl() - call API failure, error code: %s", tostring(ret)))
        end  
    end
end

function GameUtils.setFromUrlCallback()
    local callbackLua = function(url) 
        local GlobalStatus = APP:getObject("GlobalStatus")
        if GlobalStatus:getIsLogined() then
            GameUtils.setFromUrl()
            local code = GameUtils.getParamFromUrl(url,"room_code")
            if code ~= nil then
                if APP:isObjectExists("MJLYGameController") then
                else
                    dump("setFromUrlCallback:" ..code)
                    APP:getCurrentController():showWaiting()
                    local request = protocols.private_room_pb.EnterPrivateRoomRequest()
                    request.enter_code = code
                    SOCKET_MANAGER.send(protocols.command_pb.CMD_ENTER_PRIVATE_ROOM_REQ, request)                   
                end
            end

            -- local uid = GameUtils.getParamFromUrl(url,"user_id")
            -- if uid ~= nil then
            --     local GlobalStatus = APP:getObject("GlobalStatus") 
            --     if GlobalStatus:getInviteUserId() == 0 and GlobalStatus:getIsCanSendInvite() then
            --         local request = protocols.base_pb.SetUserProfileRequest()
            --         request.invite_user_id = uid
            --         SOCKET_MANAGER.send(protocols.command_pb.CMD_SET_USER_PROFILE_REQ, request)  
            --     end
            -- end
        end
    end 

    if device.platform == "android" then
            local className="com/jiyan/liyang/MoWindow" --包名/类名 
            local args = {callbackLua}  
            local sigs = "(I)V" --传入string参数，无返回值  

            local ok,ret = luaj.callStaticMethod(className,"setOpenUrlCallback",args,sigs)  
            if not ok then  
                dump("luaj failed") 
            end  
    elseif device.platform == "ios" then    
        local args = {
                    listener = callbackLua,
                }
        local ok, ret = luaoc.callStaticMethod("AppController", "setOpenUrlCallback", args)
        if not ok then
            print(string.format("AppController.getOpenUrl() - call API failure, error code: %s", tostring(ret)))
        end  
    end
end

function GameUtils.getMoWindowParam(key)
    if device.platform == "android" then
        local className="com/jiyan/baotou/MoWindow" --包名/类名 
        local args = {key}  
        local sigs = "(Ljava/lang/String;)Ljava/lang/String;" --传入string参数，无返回值  

        local ok,ret = luaj.callStaticMethod(className,"getParams",args,sigs)  
        if not ok then  
            dump("luaj failed") 
        end  

        dump(ret)

        return ret
    elseif device.platform == "ios" then    

    end  

    return ""  
end
function GameUtils.jumpToWeixinGZH()
    if device.platform == "android" then
            local className="com/jiyan/liyang/Weixin" --包名/类名 
            local args = {"乐道溧阳3缺1"}  
            local sigs = "(Ljava/lang/String;)V" --传入string参数，无返回值  

            local ok,ret = luaj.callStaticMethod(className,"jumpToWeixinGZH",args,sigs)  
            if not ok then  
                dump("luaj failed") 
            end  
    elseif device.platform == "ios" then    
        local args = {
                    gzh = "乐道溧阳3缺1",
                }
        local ok, ret = luaoc.callStaticMethod("AppController", "jumpToWeixinGZH", args)
        if not ok then
            print(string.format("AppController.getOpenUrl() - call API failure, error code: %s", tostring(ret)))
        end  
    end    
end

function GameUtils.setScreenCallback()
    local callback = function(code) 
        dump("--------------------setScreenCallback------------------------")
        if APP:isObjectExists("SifutouGameController") then
            local globalStatus = APP:getObject("GlobalStatus")
            local SifutouGameController = APP:getObject("SifutouGameController")
            if globalStatus:getWatchingSeatId() == -1 and SifutouGameController._gameSTAT >= 1 then
                local request = protocols.table_pb.GameScreenShotRequest()
                SOCKET_MANAGER.send(220, request)                                
            end
        end
    end

    if device.platform == "android" then
            local className="com/jiyan/liyang/Common" --包名/类名 
            local args = {callback}  
            local sigs = "(I)V" --传入string参数，无返回值  

            local ok,ret = luaj.callStaticMethod(className,"setScreenCallBack",args,sigs)  
            if not ok then  
                dump("luaj failed") 
            end  
    elseif device.platform == "ios" then    
        local args = {
                    listener = callback,
                }
        local ok, ret = luaoc.callStaticMethod("AppController", "setScreenCallBack", args)
        if not ok then
            print(string.format("AppController.setScreenCallBack() - call API failure, error code: %s", tostring(ret)))
        end  
    end  
end


------
function GameUtils.popNode(node)
    node:runAction(cca.seq({
            cca.scaleTo(0.1, 1.05),
            cca.scaleTo(0.1, 0.95),
            cca.scaleTo(0.1, 1),
        }))
end

function GameUtils.getClockTimeStr(_time)
    local _vM = math.floor(_time/60)
    local _vS = _time-60*math.floor(_time/60)

    if _vM < 10 then _vM = "0"..tostring(_vM) end
    if _vS < 10 then _vS = "0"..tostring(_vS) end

    return tostring(_vM..":".._vS)
end

--------------------------------------------------------------------

function GameUtils.sendCountableEvent(cat, act)
    if device.platform == "android" then
        local className="com/zenist/jielong/Ads" 
        

        local args = {cat, act, "", 1}  
        local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V" --传入string参数，无返回值  
        
        local ok,ret = luaj.callStaticMethod(className,"sendCountableEvent",args,sigs)  
        if not ok then  
            dump("luaj failed") 
        end 
    end
end

--------------------------------------------------------------------

function GameUtils.loadAd()
    if device.platform == "android" then

        local className="com/zenist/jielong/Ads" 
        local callbackLua = function(code) 

            if code == "101" then
                APP:getCurrentController():runAction(cca.seq({
                    cca.delay(0.1),
                    cca.cb(function()
                        local GlobalStatus = APP:getObject("GlobalStatus")
                        GlobalStatus.adBtn_ = true

                        if APP:isObjectExists("WorldController") then
                            local _WorldController = APP:getObject("WorldController")
                            _WorldController:setAdBtnTouch(true)
                        end


                    end),
                }))
                

            elseif code == "100" then
                
                APP:getCurrentController():runAction(cca.seq({
                    cca.delay(0.1),
                    cca.cb(function()
                        if APP:getCurrentController()._waitingNode then
                            APP:getCurrentController():hideWaiting()
                            APP:getCurrentController():showAlertOK({
                                desc="Sorry, Loading AD Failed",
                            })
                        end
                    end),
                }))
                
            else
                
            end
        end 

        local args = {callbackLua}  
        local sigs = "(I)V" --传入string参数，无返回值  
        
        local ok,ret = luaj.callStaticMethod(className,"loadAd",args,sigs)  
        if not ok then  
            dump("luaj failed") 
        end 

    end
end

function GameUtils.runAd(adfid)
    print("------ GameUtils.runAd >", adfid)
    if adfid == "15004" or adfid == "15005" then
        APP:getCurrentController():showWaiting()
    end
    
    if device.platform == "android" then

        local className="com/zenist/jielong/Ads" 
        local callbackLua = function(code) 

            if code == "1" then
                APP:getCurrentController():hideWaiting()
                APP:getCurrentController():runAction(cca.seq({
                    cca.delay(0.1),
                    cca.cb(function()
                        local _user = APP:getObject("User")
                        _user.coin = _user.coin+100

                        if APP:isObjectExists("WorldController") then
                            local _WorldController = APP:getObject("WorldController")
                            _WorldController._worldMainView:refreshCoin()
                        end
                        if APP:isObjectExists("GameController") then
                            local _GameController = APP:getObject("GameController")
                            _GameController._gameBg._coinLable:setString(tostring(_user.coin))
                        end


                    end),
                }))
                

            elseif code == "2" then
                APP:getCurrentController():hideWaiting()
                APP:getCurrentController():runAction(cca.seq({
                    cca.delay(0.1),
                    cca.cb(function()
                        local _user = APP:getObject("User")
                        -- _user.tips = 1
                        -- _user.back = 1
                        if _user.tips == 0 then
                            _user.tips = 1
                            if APP:isObjectExists("GameController") then
                                local GameController = APP:getObject("GameController")
                                GameController._gameBottomUINode:tipsOpen()
                                GameController._gameBottomUINode:refreshTipsLable(_user.tips)
                            end
                        end

                        if _user.back == 0 then
                            _user.back = 1
                            if APP:isObjectExists("GameController") then
                                local GameController = APP:getObject("GameController")
                                GameController._gameBottomUINode:backOpen()
                                GameController._gameBottomUINode:refreshBackLable(_user.back)
                            end
                        end

                        
                    end),
                }))

                

                

            elseif code == "100" then
                
                APP:getCurrentController():runAction(cca.seq({
                    cca.delay(0.1),
                    cca.cb(function()
                        if APP:getCurrentController()._waitingNode then
                            APP:getCurrentController():hideWaiting()
                            APP:getCurrentController():showAlertOK({
                                desc="Please,try it later.",
                            })
                        end
                    end),
                }))
                
            else
                APP:getCurrentController():hideWaiting()
            end
        end 

        local args = {tostring(adfid),callbackLua}  
        local sigs = "(Ljava/lang/String;I)V" --传入string参数，无返回值  
        
        local ok,ret = luaj.callStaticMethod(className,"buildAd",args,sigs)  
        if not ok then  
            dump("luaj failed") 
        end 


        APP:getCurrentController():runAction(cca.seq({
            cca.delay(30),
            cca.cb(function()
                if APP:getCurrentController()._waitingNode then
                    APP:getCurrentController():hideWaiting()
                    APP:getCurrentController():showAlertOK({
                        desc="Please,try it later.",
                    })
                end
            end),
        }))

    end
end

--------------------------------------------------------------------

function GameUtils.upload(dataJson)
    local json = require("framework.json")
    local _user = APP:getObject("User")
    local _oid = _user.oid
    local _token = _user.token
    local body = json.encode({
        Account = _oid, 
        Token = _token,
        Data = tostring(dataJson),
    })

    -- local _vo = HttpManager.urlMain().."?cmd=upload&data="..tostring(dataJson).."&uid="..tostring(UID)
    local _vo = HttpManager.urlMain().."set_user",
    print("curl==> ", _vo)
    local request = z.CurlManager:getInstance():sendCommandForLua(
            _vo, 
            GameConfig.METHOD_POST, body)
    GameUtils.registerHttpHandler(request, function(response)
                print("-========================================")
                print("···response:getCode() ", response:getCode())
                if response:getCode() == 0 then
                    local _resp = json.decode(response:getResult())
                    print("···", response:getResult())
                    print("_resp  : ", _resp.code)
                end
                print("-========================================")
            end)
end

--------------------------------------------------------------------

function GameUtils.getRank(levelId, friends, callback)
    local json = require("framework.json")
    local _user = APP:getObject("User")
    local _oid = _user.oid
    local _token = _user.token
    local body = json.encode({
        Account = _oid, 
        Token = _token,
        level_id = levelId,
        Friends = friends,--json.encode(friends)
    })

    -- local _vo = HttpManager.urlMain().."?cmd=rank&fuids="..tostring(_friendsJson).."&uid="..tostring(UID)
    local _vo = HttpManager.urlMain().."get_rank",
    print("curl==> ", _vo)
    local request = z.CurlManager:getInstance():sendCommandForLua(
            _vo, 
            GameConfig.METHOD_POST, body)
    GameUtils.registerHttpHandler(request, function(response)
                if response:getCode() == 0 then

                    local _resp = json.decode(response:getResult())
                    print("xxxxx1: ", response:getResult())
                    print("xxxxx : ", _resp)

                    callback(_resp.data.items)
                end
            end)
end

function GameUtils.setRank(levelId, sec)
    local json = require("framework.json")
    local _user = APP:getObject("User")
    local _oid = _user.oid
    local _token = _user.token
    local body = json.encode({
        Account = _oid, 
        Token = _token,
        level_id = levelId,
        Data = sec,
    })

    -- local _vo = HttpManager.urlMain().."?cmd=rank&fuids="..tostring(_friendsJson).."&uid="..tostring(UID)
    local _vo = HttpManager.urlMain().."set_rank",
    print("curl==> ", _vo)
    local request = z.CurlManager:getInstance():sendCommandForLua(
            _vo, 
            GameConfig.METHOD_POST, body)
    GameUtils.registerHttpHandler(request, function(response)
                
            end)

end

--------------------------------------------------------------------

function GameUtils.updateRec()
    local _user = APP:getObject("User")

    local _dataTable = {}
    _dataTable.coin = _user.coin
    _dataTable.rec = _user.rec
    _dataTable.back = _user.back
    _dataTable.tips = _user.tips
    _dataTable.data = _user.data

    local _dataJson = json.encode(_dataTable)
    print("_dataJson : ", _dataJson)
    GameUtils.upload(_dataJson)

end

--------------------------------------------------------------------


function GameUtils.getGameCfg()
    local _cfg = 
    {
        {x=360, y=190, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=450, y=260, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=430, y=380, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=550, y=390, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=650, y=440, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=590, y=500, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=450, y=520, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=520, y=550, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=600, y=600, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=420, y=620, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=370, y=650, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=320, y=680, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=280, y=750, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=230, y=850, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=89, y=890, s1=3600, s2=600, s3=240, gb=100, awd=50},
        {x=320, y=860, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=350, y=780, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=420, y=730, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=520, y=690, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=480, y=770, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=540, y=800, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=440, y=830, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=600, y=830, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=600, y=900, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=750, y=920, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=890, y=900, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=980, y=890, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=950, y=850, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=920, y=800, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=990, y=830, s1=3600, s2=600, s3=240, gb=200, awd=100},
        {x=1050, y=820, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1040, y=900, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1100, y=910, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1100, y=870, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1100, y=820, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1160, y=890, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1160, y=830, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1220, y=880, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1220, y=820, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1280, y=900, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1280, y=840, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1250, y=790, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1210, y=730, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1110, y=740, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1050, y=760, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=1000, y=760, s1=3600, s2=600, s3=240, gb=300, awd=150},
        {x=930, y=730, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=890, y=690, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=870, y=640, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=970, y=640, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1040, y=680, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1140, y=640, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1240, y=680, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1290, y=630, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1230, y=580, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1170, y=560, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1020, y=540, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1070, y=490, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1130, y=460, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1070, y=410, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1140, y=340, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1180, y=390, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1220, y=450, s1=3600, s2=600, s3=240, gb=400, awd=200},
        {x=1300, y=430, s1=3600, s2=600, s3=240, gb=400, awd=200},

        {x=1320, y=790, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1350, y=730, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1400, y=800, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1400, y=700, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1470, y=600, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1520, y=640, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1550, y=720, s1=3600, s2=600, s3=240, gb=500, awd=250},

        --china
        {x=1590, y=750, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1630, y=720, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1670, y=710, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1700, y=760, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1660, y=800, s1=3600, s2=600, s3=240, gb=500, awd=250},

        {x=1750, y=790, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1820, y=810, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1800, y=770, s1=3600, s2=600, s3=240, gb=500, awd=250},

        --taiwan
        {x=1750, y=700, s1=3600, s2=600, s3=240, gb=500, awd=250},

        {x=1690, y=650, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1640, y=640, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1610, y=610, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1670, y=560, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1720, y=590, s1=3600, s2=600, s3=240, gb=500, awd=250},
        {x=1800, y=640, s1=3600, s2=600, s3=240, gb=600, awd=300},
        {x=1750, y=520, s1=3600, s2=600, s3=240, gb=600, awd=300},
        {x=1820, y=550, s1=3600, s2=600, s3=240, gb=600, awd=300},
        {x=1920, y=570, s1=3600, s2=600, s3=240, gb=600, awd=300},
        {x=1970, y=540, s1=3600, s2=600, s3=240, gb=600, awd=300},
        {x=2000, y=490, s1=3600, s2=600, s3=240, gb=600, awd=300},

        {x=2090, y=440, s1=3600, s2=600, s3=240, gb=600, awd=300},
        {x=2140, y=390, s1=3600, s2=600, s3=240, gb=600, awd=300},
        {x=2100, y=330, s1=3600, s2=600, s3=240, gb=600, awd=300},
        {x=2140, y=280, s1=3600, s2=600, s3=240, gb=600, awd=300},
        {x=2200, y=410, s1=3600, s2=600, s3=240, gb=600, awd=300},

    }
    return _cfg
end

--------------------------------------------------------------------

function GameUtils.getGameStars(gid, time)
    local cfgList = GameUtils.getGameCfg()
    local _timeCfgS1 = cfgList[gid].s1
    local _timeCfgS2 = cfgList[gid].s2
    local _timeCfgS3 = cfgList[gid].s3

    print("_time,", time)

    print("_timeCfgS1,", _timeCfgS1)
    print("_timeCfgS2,", _timeCfgS2)
    print("_timeCfgS3,", _timeCfgS3)

    if time <= _timeCfgS3 then
        return 3
    elseif time <= _timeCfgS2 then
        return 2
    elseif time <= _timeCfgS1 then
        return 1
    else
        return 0
    end
end



------------------------------
--字的 跳动
--widthLists 为跳动字的切割width
---------------------------------
function GameUtils.jumpWordSprite(spritePath, widthLists)
    local _outNode = display.newNode()


    for i=1,#widthLists do
        local _Container = display.newNode()
            :addTo(_outNode)
        

        --
        local _sp = display.newSprite(spritePath)
        _sp:setAnchorPoint(cc.p(0, 0.5))


        local _stencilX, _ccx = 0, 0
        if i == 1 then
            _stencilX = widthLists[i]
        else
            _stencilX = widthLists[i]-widthLists[i-1]
            _ccx = widthLists[i-1]
        end
        local _stencilY = _sp:getContentSize().height
        local stencil = display.newScale9Sprite("image/white_unit.png", 0, 0, 
                cc.size(_stencilX, _stencilY), 
                cc.rect(1, 1, 1, 1))
        stencil:setAnchorPoint(cc.p(0, 0.5))
        stencil:setPosition(_ccx, 0)

        local stencilNode = cc.ClippingNode:create()
        stencilNode:setStencil(stencil)
        stencilNode:setAlphaThreshold(0.9)
        stencilNode:setInverted(false)
        stencilNode:addTo(_Container)
        stencilNode:setPosition(0, 0)


        _sp:addTo(stencilNode)

        _Container:runAction(cca.seq({
                cca.delay(0.3*(i-1)),
                cca.cb(function()
                        _Container:runAction(cca.repeatForever(cca.seq({
                                cca.delay(0.3*#widthLists),
                                cca.jumpTo(0.3, 0, 0, 30, 1)
                            })))
                    end),
            }))
        
    end
    


    return _outNode
end



------------------------------
--数字
--999,999,999
---------------------------------
function GameUtils.formatNumForEnglish(num)
    local str1 =""  
    local str = tostring(math.abs(num))
    local strLen = string.len(str)  
          
    for i=1,strLen do  
        str1 = string.char(string.byte(str,strLen+1 - i)) .. str1  
        if math.mod(i,3) == 0 then  
            if strLen - i ~= 0 then  
                str1 = ","..str1  
            end  
        end  
    end 

    if num > 0 then
        return str1
    else
        return "-"..str1
    end
end










return GameUtils