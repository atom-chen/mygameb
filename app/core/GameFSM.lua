
local GameConfig = require("app.core.GameConfig")
local StartCommand = require("app.commands.StartCommand")
local GameFSM = class("GameFSM")

-- events
GameFSM.E_START = "start"
GameFSM.E_CONNECTED = "connected"
GameFSM.E_DISCONNECTED = "disconnected"
GameFSM.E_LOGOUT = "logout"
GameFSM.E_AUTH = "auth"
GameFSM.E_LOAD = "load"

function GameFSM:ctor( ... )
    cc(self):addComponent("components.behavior.StateMachine")
    self._fsm = self:getComponent("components.behavior.StateMachine")

    local defaultEvents = {
        {name = "start",        from = "none",          to = "loading"},

        {name = "connected",    from = "loading",       to = "loading"},
        {name = "connected",    from = "logining",      to = "logining"},
        {name = "connected",    from = "part-normal",   to = "part-normal"},

        {name = "auth",         from = "loading",       to = "part-normal"},
        {name = "load",         from = "loading",       to = "part-normal"},

        -- {name = "auth",         from = "loading",   to = "normal"},
        {name = "auth",         from = "part-normal",   to = "normal"},
        {name = "load",         from = "part-normal",   to = "normal"},

        {name = "auth",         from = "logining",      to = "normal"},

        {name = "disconnected", from = "loading",       to = "loading"},
        {name = "disconnected", from = "logining",      to = "logining"},
        {name = "disconnected", from = "normal",        to = "part-normal"},
        {name = "disconnected", from = "part-normal",   to = "part-normal"},

        {name = "logout",       from = "normal",        to = "logining"},
    }

    local defaultCallbacks = {
        -- on change state
        onchangestate       = handler(self, self.onChangeState),

        -- on before/after events
        onbeforestart       = handler(self, self.on_B_Start),
        onafterstart        = handler(self, self.on_A_Start),
        onbeforeconnected   = handler(self, self.on_B_Connected),
        onbeforeauth        = handler(self, self.on_B_Auth),
        onbeforeload        = handler(self, self.on_B_Load),
        onbeforedisconnected= handler(self, self.on_B_Disconnected),

        onbeforelogout      = handler(self, self.on_B_Logout),
        onafterlogout       = handler(self, self.on_A_Logout),

        -- on enter/leave/be states
        onenternormal       = handler(self, self.on_E_Normal),
    }

    self._fsm:setupState({
        events = defaultEvents,
        callbacks = defaultCallbacks
    })

    self._eventQueue = {}

    cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        handler(self, self._doAsyncEvents), 0.01, false)

    -- set global fsm
    FSM = self
end

function GameFSM:doEvent(event, args)
    printInfo("[GameFSM] do event: %s", event)
    self._fsm:doEvent(event, args)
end

function GameFSM:pushAsyncEvent(event, args)
    printInfo("[GameFSM] push async event: %s", event) 
    table.insert(self._eventQueue, {event = event, args = args})
end

function GameFSM:_doAsyncEvents()
    for _, v in ipairs(self._eventQueue) do
        printInfo("[GameFSM] do async event: %s", v.event)
        self._fsm:doEvent(v.event, v.args)
    end
    self._eventQueue = {}
end

function GameFSM:onChangeState(event)
    printInfo("[GameFSM] change state: [%s] -> [%s]", event.from, event.to)
end

function GameFSM:on_B_Start(event, args)
end

function GameFSM:on_A_Start(event, args)
    APP:command("StartCommand")
    -- start
    if M2_DEBUG then
        APP:enterScene("TestScene")
    else
        APP:enterScene("RegisterScene")
    end
    
end

function GameFSM:on_B_Connected(event, args)
    local globalStatus = APP:getObject("GlobalStatus")
    APP:command("AuthCommand", globalStatus:getLoginOptions())
end

function GameFSM:on_B_Auth(event, args)
end

function GameFSM:on_B_Load(event, args)
end

function GameFSM:on_B_Disconnected(event, args)
    APP:enterScene("RegisterScene")

    if self._fsm:isState({"loading", "normal"}) then
        APP:getCurrentController():showAlertOK({desc = "网络连接失败，请重新登陆!!"})
    elseif self._fsm:isState("logining") then
        
    end
end

function GameFSM:on_B_Logout(event, args)
end

function GameFSM:on_A_Logout(event, args)
    local SocketManager = require("app.core.SocketManager")
    SocketManager.disconnect()
    APP:getCurrentController():showWaiting()
end

function GameFSM:on_E_Normal()
    if APP:isObjectExists("RegiseterController") then
        APP:enterScene("HomeScene")
        -- APP:enterScene("TestScene")
    end    
end

return GameFSM