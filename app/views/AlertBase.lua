local ViewBase = require("app.views.ViewBase")

local AlertBase = class("AlertBase", ViewBase)

function AlertBase:ctor(options)
    AlertBase.super.ctor(self)
    self:setNodeEventEnabled(true)
    self:setCascadeOpacityEnabled(true)

    self._exiting = false
    self:hide()

    self._bgNode = display.newNode():addTo(self)
    -- self._bgNode:setCascadeOpacityEnabled(true)
    -- self._bgNode:opacity(0)
    self._alertNode = display.newNode():addTo(self)
    -- self._alertNode:setCascadeOpacityEnabled(true)
    -- self._alertNode:opacity(0)
    -- self._alertNode:scale(0.5)

    local bg = display.newSprite("image/white_unit.png")
        :align(display.CENTER, 0, 0)
        :zorder(-10)
        :addTo(self)
    bg:setColor(cc.c3b(0, 0, 0))
    bg:setOpacity(100)
    bg:setScaleX(display.width)
    bg:setScaleY(display.height)
    bg:setTouchEnabled(true)
    bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
    end)
end

function AlertBase:actionEnter()
    self._exiting = false

    self:show()

    -- self._bgNode:stopAllActions()
    -- self._bgNode:runAction(
    --     cca.fadeTo(0.3, 1))

    -- self._alertNode:stopAllActions()
    -- self._alertNode:runAction(cca.spawn({
    --     cca.fadeTo(0.2, 1),
    --     cca.bounceOut(cca.scaleTo(0.3, 1)),
    --     }))
end

function AlertBase:actionExit(needRemove)
    local needRemove = needRemove
    if needRemove == nil then needRemove = true end

    if self._exiting then return end
    self._exiting = true

    -- self._bgNode:stopAllActions()
    -- self._bgNode:runAction(cca.fadeTo(0.3, 0))

    -- self._alertNode:stopAllActions()
    -- self._alertNode:runAction(cca.spawn({
    --     cca.fadeTo(0.2, 0),
    --     cca.sineIn(cca.scaleTo(0.3, 0.5))
    --     }))
    
    if needRemove then
        self:removeSelf()
        -- printInfo("---------------------needRemove11111")
        -- self:stopAllActions()
        -- self:runAction(cca.seq({
        --     cca.cb(function() printInfo("-------------11111") end),
        --     cca.delay(0.3),
        --     cca.cb(function() printInfo("-------------22222") end),
        --     cca.hide(),
        --     cca.cb(function() printInfo("-------------33333") end),
        --     cca.removeSelf(),
        --     }))
    else
        self:hide()
        -- printInfo("---------------------needRemove22222")
        -- self:stopAllActions()
        -- self:runAction(cca.seq({
        --     cca.delay(0.3),
        --     cca.hide(),
        --     }))
    end
end

function AlertBase:getBGNode()
    return self._bgNode
end

function AlertBase:getAlertNode()
    return self._alertNode
end

function AlertBase:setBGVisible(visible)
    self._bgNode:setVisible(visible)
end

return AlertBase