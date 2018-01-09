local GameConfig = require("app.core.GameConfig")


local YaoGanNode = class("YaoGanNode", function()
    return display.newNode()
end)

function YaoGanNode:ctor()
	self._GameController = APP:getObject("TestController")

    self._viewX, self._viewY = 200, 200

    self._yaoganA = display.newSprite("image/yaogan/out.png")
        :pos(self._viewX, self._viewY)
        :addTo(self)
    
    self._yaoganB = display.newSprite("image/yaogan/x.png")
        :pos(self._viewX, self._viewY)
        :addTo(self)

    self._yaoganB:setTouchEnabled(true)
    self._yaoganB:setTouchSwallowEnabled(true)
    self._yaoganB:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            -- print("---------", event.name, event.x, event.y)
            if event.name == "began" then
                self._ao = 0
                self._GameController:_pointStart()
                self:_setPos(event.x, event.y)
                return true
            elseif event.name == "moved" then
                self:_setPos(event.x, event.y)
            elseif event.name == "ended" then
                self._ao = 0
                self._GameController:_pointEnd()
                self:_setPos(self._viewX, self._viewY)
            end
        end)
end

function YaoGanNode:_setPos(x, y)
    local _startPos = cc.p(self._viewX, self._viewY)
    local _endedPos = cc.p(x, y)
    local _dis = cc.pGetDistance(_startPos, _endedPos)
    local _r = 90
    local _pai = 3.14159
    self._ao = math.atan2(_endedPos.y-_startPos.y, _endedPos.x-_startPos.x) *180/_pai

    if _dis <= _r then
        self._yaoganB:setPosition(x, y)
    else
        local _newX = _startPos.x + _r * math.cos(self._ao * _pai/180) 
        local _newY = _startPos.y + _r * math.sin(self._ao * _pai/180) 
        self._yaoganB:setPosition(_newX, _newY)
    end

    -- 传输
    self._GameController:_pointAo(self._ao)
end














return YaoGanNode