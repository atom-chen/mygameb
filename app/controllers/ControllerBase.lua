local utils = require("app.common.utils")
local GameConfig = require("app.core.GameConfig")


local ControllerBase = class("ControllerBase", function()
    return display.newNode()
end)

function ControllerBase:ctor()
    APP:setObject(self.__cname, self)
    
    self._gamePlayerLayer = nil
    self._views = {}
    self:setNodeEventEnabled(true)
    self._msgBlocked = false

    --消息队列
    self._msgQueue = {}

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
    self:scheduleUpdate()
end

function ControllerBase:update(dt)
    self:onUpdate(dt)
    self:handleMessage(dt)
end

-- 子类需要使用update功能时通过override onUpdate来实现
function ControllerBase:onUpdate(dt)
    -- body
end

function ControllerBase:blockMessage()
    self._msgBlocked = true
end

function ControllerBase:unblockMessage()
    self._msgBlocked = false
end

function ControllerBase:pushMessage(msg)
    table.insert(self._msgQueue, msg)
end

function ControllerBase:handleMessage(dt)
    -- print("!@@@@ self._msgBlocked ", self._msgBlocked)
    if self._msgBlocked == true then return end
    if #self._msgQueue == 0 then return end

    local msg = self._msgQueue[1]
    table.remove(self._msgQueue, 1)

    local handler = msg.handler
    local payload = msg.payload
    handler(payload)     
end

function ControllerBase:onEnter()
    APP:setCurrentController(self)
end

function ControllerBase:onExit()
    APP:setCurrentController(nil)
    APP:removeObject(self.__cname)
end

function ControllerBase:showWaiting()
    if not self._waitingNode then
        self._waitingNode = APP:createView("WaitingNode")
            :pos(display.cx, display.cy)
            :zorder(GameConfig.Waiting_Z)
            :addTo(self)
    end
end

function ControllerBase:showBlankWaiting()
    if not self._waitingNode then
        self._waitingNode = APP:createView("WaitingNode", {blank = true})
            :pos(display.cx, display.cy)
            :zorder(GameConfig.Waiting_Z)
            :addTo(self)
    end
end

function ControllerBase:hideWaiting()
    if self._waitingNode then
        self._waitingNode:removeSelf()
        self._waitingNode = nil
    end
end

function ControllerBase:showAlertOKCancel(options)
    local alertView = APP:createView("AlertOKCancel", options)
        :pos(display.cx, display.cy)
        :zorder(GameConfig.Alert_Z)
        :addTo(self)
    alertView:actionEnter()
end

function ControllerBase:showAlertOKCancelWithNode(options)
    local alertView = APP:createView("AlertOKCancelWithNode", options)
        :pos(display.cx, display.cy)
        :zorder(GameConfig.Alert_Z)
        :addTo(self)
    alertView:actionEnter()
end

function ControllerBase:showAlertOK(options)
    local alertView = APP:createView("AlertOK", options)
        :pos(display.cx, display.cy)
        :zorder(GameConfig.Alert_Z)
        :addTo(self)
    alertView:actionEnter()
end

function ControllerBase:showAlertOKWithNode(options)
    local alertView = APP:createView("AlertOKWithNode", options)
        :pos(display.cx, display.cy)
        :zorder(GameConfig.Alert_Z)
        :addTo(self)
    alertView:actionEnter()
end

function ControllerBase:showFullScreen(fullscreenView)
    fullscreenView:pos(display.cx, display.cy)
        :zorder(GameConfig.Alert_Z)
        :addTo(self)
    fullscreenView:actionEnter()
end

function ControllerBase:showAlert(alertView)
    alertView:pos(display.cx, display.cy)
        :zorder(GameConfig.Alert_Z)
        :addTo(self)
    alertView:actionEnter()
end



--刷新用户的金币显示
function ControllerBase:refreshMyChips()

end


function ControllerBase:showMessage(userId, text)
    if self._gamePlayerLayer then
        self._gamePlayerLayer:showMessage(userId, text)
    end
end

function ControllerBase:showMessageAnim(userId, animId)
    if self._gamePlayerLayer then
        self._gamePlayerLayer:showMessageAnim(userId, animId)
    end
end

function ControllerBase:showAvatarAnim(msg)
    if self._gamePlayerLayer then
        self._gamePlayerLayer:showAvatarAnim(msg)
    end
end


return ControllerBase