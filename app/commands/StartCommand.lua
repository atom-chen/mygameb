--
-- Author: gerry
-- Date: 2016-01-11 16:06:48
--
local protocols = require("app.protocol.init")
local scheduler = require("framework.scheduler")
local models = require("app.models.init")
local GameEnv = require("app.core.GameEnv")
local GameConfig = require("app.core.GameConfig")
local GameUtils = require("app.core.GameUtils")
local HttpManager = require("app.core.HttpManager")

local StartCommand = {}

function StartCommand.execute(...)
    ORIGIN_DESIGN_WIDTH_FIX = 720
    -- printInfo("------------------------------ %s", z.DeviceUtility:getInstance():getHardwareName())
    -- printInfo("------------------------------ %s", z.DeviceUtility:getInstance():getDeviceName())
    GAME_PLATFORM = z.GlobalDefines:getGamePlatform()
    dump(GAME_PLATFORM)

    MYSCALE = math.min(1, display.height / 1280)
    print("MYSCALE ----------------", MYSCALE)
    UID = "0"
    M_DEBUG = false
    M2_DEBUG = false

    NO_LESS_THAN_4_HEIGHT = math.max(display.height, 1125)

    StartCommand.initNotificationNode()
    StartCommand.initManagers()
    StartCommand.initModels()
    StartCommand.initEnv()
    StartCommand.initHttp()
    StartCommand.initPay()
    StartCommand.initGCUser()
    StartCommand.initScriptBridges()
    StartCommand.asyncLoadResources()

    -- StartCommand.initSocket()

end

function StartCommand.scheduleGC()
    scheduler.scheduleGlobal(function() collectgarbage("collect") end, 10)
    -- scheduler.scheduleGlobal(function() print(collectgarbage("count")) end, 10)
end

function StartCommand.schedulePing()
    scheduler.scheduleGlobal(function()    
        local request = protocols.base_pb.ReadyRequest()
        SOCKET_MANAGER.send(protocols.command_pb.CMD_PING, request)  
    end, 30)
end

function StartCommand.initManagers()
    z.CacheFilesManager:getInstance():init()
    z.LocalDataManager:getInstance():init()
    -- z.LocalMessagesManager:getInstance():init()
    z.ImageDownloadManager:getInstance():init()
    -- z.AudioDownloadManager:getInstance():init()
    -- z.AudioPlayManager:getInstance():init()
    -- z.UpYunManager:getInstance():init()
end

function StartCommand.initModels()
    if not APP:isObjectExists("GlobalStatus") then
        local globalStatus = models.GlobalStatus.new()
        APP:setObject("GlobalStatus", globalStatus)
        printInfo("create model - GlobalStatus")
    end

    if not APP:isObjectExists("User") then
        local User = models.User.new()
        APP:setObject("User", User)
        printInfo("create model - User")
    end
end

function StartCommand.initEnv()
-- GameEnv.Current = GameEnv.PRO
GameEnv.Current = GameEnv.DEV
end

function StartCommand.initSocket()
    StartCommand.schedulePing()
	local SocketManager = require("app.core.SocketManager")
    -- assert(SocketManager.getStatus() == SocketManager.S_NONE, 
    --     string.format("init socket at not none status: %u", SocketManager.getStatus()))
    if SocketManager.getStatus() == SocketManager.S_NONE then
        SocketManager.init()
    end
end

function StartCommand.initHttp()
    z.CurlManager:getInstance():start()
end

function StartCommand.initPay()
    local PayManager = require("app.core.PayManager")
    PayManager.init()
end

function StartCommand.initGCUser()
    local GCUser = require("app.core.UserManager")
    GCUser.init()
end

function StartCommand.initScriptBridges()
    -- 取一个全局共享node当绑定载体
    local node = cc.Director:getInstance():getNotificationNode()
    
    -- GameUtils.registerScriptHandler(node, GameUtils.ScriptBridge_playEffect,
    --     GameConfig.Handler.EVENT_PLAY_EFFECT)
    -- GameUtils.registerScriptHandler(node, GameUtils.ScriptBridge_playEffectAndRecord,
    --     GameConfig.Handler.EVENT_PLAY_EFFECT_AND_RECORD)
    -- GameUtils.registerScriptHandler(node, GameUtils.ScriptBridge_stopRecordedEffect,
    --     GameConfig.Handler.EVENT_STOP_RECORDED_EFFECT)
    -- GameUtils.registerScriptHandler(node, GameUtils.ScriptBridge_playAudio,
    --     GameConfig.Handler.EVENT_PLAY_AUDIO)
    -- GameUtils.registerScriptHandler(node, GameUtils.ScriptBridge_playAudioFailed,
    --     GameConfig.Handler.EVENT_PLAY_AUDIO_FAILED)
    -- GameUtils.registerScriptHandler(node, GameUtils.ScriptBridge_playAudioBegin,
    --     GameConfig.Handler.EVENT_PLAY_AUDIO_BEGIN)
    -- GameUtils.registerScriptHandler(node, GameUtils.ScriptBridge_playAudioEnd,
    --     GameConfig.Handler.EVENT_PLAY_AUDIO_END)
    -- GameUtils.registerScriptHandler(node, GameUtils.ScriptBridge_playAudioStoped,
    --     GameConfig.Handler.EVENT_PLAY_AUDIO_STOPED)
    -- GameUtils.registerScriptHandler(node, GameUtils.ScriptBridge_downloadAudio,
    --     GameConfig.Handler.EVENT_DOWNLOAD_AUDIO)
end

-------------------------------------------------------------------------------------------------------

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
    if APP:isObjectExists("ChatLobbyNode") then
        local chatNode = APP:getObject("ChatLobbyNode")
        chatNode:playAudioFailed(url)
    end
end

function GameUtils.ScriptBridge_playAudioBegin(url)
    if APP:isObjectExists("TableMessagesNode") then
        local chatNode = APP:getObject("TableMessagesNode")
        chatNode:finishLoadingAudio(url)
        chatNode:playingAudio(url)
    end
    if APP:isObjectExists("ChatLobbyNode") then
        local chatNode = APP:getObject("ChatLobbyNode")
        chatNode:finishLoadingAudio(url)
        chatNode:playingAudio(url)
    end
    if z.AudioRecorder then
        z.AudioRecorder:getInstance():setAllVolumeLow()
    end
    
    GameUtils.CurrentVolume = 0.1
end

function GameUtils.ScriptBridge_playAudioEnd(url)
    if APP:isObjectExists("TableMessagesNode") then
        local chatNode = APP:getObject("TableMessagesNode")
        chatNode:finishPlayingAudio(url)
    end
    if APP:isObjectExists("ChatLobbyNode") then
        local chatNode = APP:getObject("ChatLobbyNode")
        chatNode:finishPlayingAudio(url)
    end
    if z.AudioRecorder then
        z.AudioRecorder:getInstance():setAllVolumeHigh()
    end
    
    GameUtils.CurrentVolume = 1.0
end

function GameUtils.ScriptBridge_playAudioStoped(url)
    if APP:isObjectExists("TableMessagesNode") then
        local chatNode = APP:getObject("TableMessagesNode")
        chatNode:finishPlayingAudio(url)
    end
    if APP:isObjectExists("ChatLobbyNode") then
        local chatNode = APP:getObject("ChatLobbyNode")
        chatNode:finishPlayingAudio(url)
    end
    if z.AudioRecorder then
        z.AudioRecorder:getInstance():setAllVolumeHigh()
    end    
    
    GameUtils.CurrentVolume = 1.0
end

function GameUtils.ScriptBridge_downloadAudio(url)
    if APP:isObjectExists("TableMessagesNode") then
        local chatNode = APP:getObject("TableMessagesNode")
        chatNode:loadingAudio(url)
    end
    if APP:isObjectExists("ChatLobbyNode") then
        local chatNode = APP:getObject("ChatLobbyNode")
        chatNode:loadingAudio(url)
    end
end

function StartCommand.initNotificationNode()
    cc.Director:getInstance():setNotificationNode(display.newNode())
    -- local notificationNode = APP:createView("NotificationNode")
    --     :addTo(cc.Director:getInstance():getNotificationNode())
end

function StartCommand.asyncLoadResources()
    local files = {
        -- "effect/blackjack-icon-title.png",
    }
    StartCommand._loadedFileCount = 0
    StartCommand._totalFileCount = #files

    if StartCommand._totalFileCount == 0 then
        StartCommand.loadResourcesFinished()
    else
        for _, file in ipairs(files) do
            cc.Director:getInstance():getTextureCache():addImageAsync(file, StartCommand.loadResourcesCallback)
        end
    end
end

function StartCommand.loadResourcesCallback(texture2D)
    printInfo("[async] loaded: %s", texture2D:getDescription())

    StartCommand._loadedFileCount = StartCommand._loadedFileCount + 1
    assert(StartCommand._loadedFileCount <= StartCommand._totalFileCount)

    if StartCommand._loadedFileCount == StartCommand._totalFileCount then
        StartCommand.loadResourcesFinished()
    end
end

function StartCommand.loadResourcesFinished()
    printInfo("[async] loaded finished")
    FSM:doEvent(FSM.E_LOAD)
end

return StartCommand