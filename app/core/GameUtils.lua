
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


------
function GameUtils.getClockTimeStr(_time)
    local _vM = math.floor(_time/60)
    local _vS = _time-60*math.floor(_time/60)

    if _vM < 10 then _vM = "0"..tostring(_vM) end
    if _vS < 10 then _vS = "0"..tostring(_vS) end

    return tostring(_vM..":".._vS)
end

--------------------------------------------------------------------


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

    if num >= 0 then
        return str1
    else
        return "-"..str1
    end
end


------------------------------
--取最大值
---------------------------------
function GameUtils.getMaxValue(valueList)
    if #valueList > 0 then
        local maxOfT = math.max(unpack(valueList))
        return maxOfT
    end
    return 0
end


--------------------------------------
-- 粒子
-- --流星
-- local meteor = cc.ParticleMeteor:createWithTotalParticles(130)
-- -- meteor:setTexture(cc.Director:getInstance():getTextureCache():addImage("wsk1.png"))
-- meteor:setPosition(cc.p( 250, 200))
-- meteor:setLocalZOrder(9999)
-- meteor:setLife(5.0)
-- self:addChild(meteor)

--  --雨
-- local rain = cc.ParticleRain:createWithTotalParticles(130)
-- --  rain:setTexture(cc.Director:getInstance():getTextureCache():addImage("wsk1.png")) 
-- rain:setPosition(cc.p( 300, 200))
-- rain:setLocalZOrder(9999)
-- rain:setLife(5.0)
-- self:addChild(rain)


-- --雪
-- local snow = cc.ParticleSnow:createWithTotalParticles(130)
-- --   snow:setTexture(cc.Director:getInstance():getTextureCache():addImage("wsk1.png")) 
-- snow:setPosition(cc.p( 350, 200))
-- snow:setLocalZOrder(9999)
-- snow:setLife(5.0)
-- self:addChild(snow)


-- --爆炸
-- local explosion = cc.ParticleExplosion:createWithTotalParticles(130)
-- --   explosion:setTexture(cc.Director:getInstance():getTextureCache():addImage("wsk1.png")) 
-- explosion:setPosition(cc.p( 350, 200))
-- explosion:setLocalZOrder(9999)
-- explosion:setLife(5.0)
-- self:addChild(explosion)

-- --烟雾
-- local smoke = cc.ParticleSmoke:createWithTotalParticles(130)
--  --  smoke:setTexture(cc.Director:getInstance():getTextureCache():addImage("wsk1.png")) 
-- smoke:setPosition(cc.p( 350, 200))
-- smoke:setLocalZOrder(9999)
-- smoke:setLife(5.0)
-- self:addChild(smoke)


-- --旋涡
-- local spiral = cc.ParticleSpiral:createWithTotalParticles(130)
-- --   spiral:setTexture(cc.Director:getInstance():getTextureCache():addImage("wsk1.png")) 
-- spiral:setPosition(cc.p( 450, 200))
-- spiral:setLocalZOrder(9999)
-- spiral:setLife(5.0)
-- self:addChild(spiral)

-- local sun = cc.ParticleSun:createWithTotalParticles(130)
-- -- sun:setTexture(cc.Director:getInstance():getTextureCache():addImage("wsk1.png")) 
-- sun:setPosition(cc.p( 500, 200))
-- sun:setLocalZOrder(9999)
-- sun:setLife(1.0)
-- self:addChild(sun)


-- local fire = cc.ParticleFire:createWithTotalParticles(130)
-- --fire:setTexture(cc.Director:getInstance():getTextureCache():addImage("wsk1.png")) 
-- fire:setPosition(cc.p( 550, 200))
-- fire:setLocalZOrder(9999)
-- fire:setLife(1.0)
-- self:addChild(fire)

-- local fireworks = cc.ParticleFireworks:createWithTotalParticles(50)
-- --fireworks:setTexture(cc.Director:getInstance():getTextureCache():addImage("wsk1.png")) 
-- fireworks:setPosition(cc.p( 550, 200))
-- fireworks:setLocalZOrder(9999)
-- fireworks:setLife(1.0)
-- self:addChild(fireworks)

-- local galaxy = cc.ParticleGalaxy:createWithTotalParticles(130)
-- --galaxy:setTexture(cc.Director:getInstance():getTextureCache():addImage("wsk1.png")) 
-- galaxy:setPosition(cc.p( 550, 200))
-- galaxy:setLocalZOrder(9999)
-- galaxy:setLife(1.0)
-- self:addChild(galaxy)

--  local flower = cc.ParticleFlower:createWithTotalParticles(130)
--  --  flower:setTexture(cc.Director:getInstance():getTextureCache():addImage("wsk1.png")) 
-- flower:setPosition(cc.p( 600, 200))
-- flower:setLocalZOrder(9999)
-- flower:setLife(1.0)
-- self:addChild(flower)



--------------------------------------
-- 
function GameUtils.onePopAndRaiseOutNode(node)
    local _xyCcpX, _xyCcpY = node:getPosition()
    node:setScale(0)
    node:runAction(cca.seq({
            cca.scaleTo(0.1, 1),
            cca.moveTo(10, _xyCcpX, _xyCcpY+200),
        }))
    node:runAction(cca.seq({
            cca.delay(0.5),
            cca.fadeOut(2),
            cca.removeSelf(),
        }))
end

function GameUtils.popNode(node)
    node:runAction(cca.seq({
            cca.scaleTo(0.1, 1.05),
            cca.scaleTo(0.1, 0.95),
            cca.scaleTo(0.1, 1),
        }))
end



return GameUtils