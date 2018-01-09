
require("config")
require("cocos.init")
require("framework.init")

local GameConfig = require("app.core.GameConfig")
local models = require("app.models.init")
local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
    self.objects_ = {}
    self.currentController = nil

    -- set global APP
    GAME_MODE = "GM"
    APP = self
end

function MyApp:run()
    local globalStatus = models.GlobalStatus.new()
    APP:setObject("GlobalStatus", globalStatus)
    require("app.core.GameFSM").new()
    FSM:doEvent("start")
    
    -- APP:enterScene("MJLYGameScene")
end

function MyApp:removeObject(id)
    printInfo("[APP] removeObject: %s", id)
    if self:isObjectExists(id) then
        self.objects_[id] = nil
    end
end

function MyApp:setObject(id, object)
    printInfo("[APP] setObject: %s", id)
    assert(self.objects_[id] == nil, string.format("MyApp:setObject() - id \"%s\" already exists", id))
    self.objects_[id] = object
end

function MyApp:getObject(id)
    assert(self.objects_[id] ~= nil, string.format("MyApp:getObject() - id \"%s\" not exists", id))
    return self.objects_[id]
end

function MyApp:isObjectExists(id)
    return self.objects_[id] ~= nil
end

function MyApp:getCurrentController()
    return self.currentController
end

function MyApp:setCurrentController(controller)
    self.currentController = controller
end

function MyApp:onEnterBackground()
    display.pause()
    self.pauseTimestamp = socket.gettime()
end

function MyApp:onEnterForeground()
    display.resume()
    self.resumeTimestamp = socket.gettime()
    if self.resumeTimestamp - self.pauseTimestamp >= 30 then
        printInfo("[MyApp] #################### Enter Background too long: %f, reconnect.", self.resumeTimestamp - self.pauseTimestamp)
        local SocketManager = require("app.core.SocketManager")
        if SocketManager and SocketManager.getStatus() == SocketManager.S_CONNECTED then
            SocketManager.disconnect()
        end
    end

    -- if self.currentController then
    --     local localDataManager = z.LocalDataManager:getInstance()
    --     local swSound = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_Sound)
    --     if swSound ~= GameConfig.SW_OFF then
    --         localDataManager:setIntegerForKey(GameConfig.LocalData_SW_Sound, GameConfig.SW_OFF)       
    --         self.currentController:runAction(cca.seq({
    --             cca.delay(3.0),
    --             cca.cb(function() 
    --                 localDataManager:setIntegerForKey(GameConfig.LocalData_SW_Sound, GameConfig.SW_ON) 
    --             end),
    --         }))
    --     end
    -- end
end

return MyApp
