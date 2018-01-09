
local ViewBase = require("app.views.ViewBase")

local FullScreenBase = class("FullScreenBase", ViewBase)

function FullScreenBase:ctor(options)
    FullScreenBase.super.ctor(self)

    self._exiting = false
    self:hide()

    self._bg = cc.ui.UIPushButton.new("image/white_unit.png")
        :setButtonSize(display.width, display.height)
        :align(display.CENTER, 0, 0)
        :addTo(self,-1)
    self._bg:setColor(cc.c3b(0, 0, 0))
    self._bg:setOpacity(150)

    self._ContentNode = display.newNode():addTo(self)
    self._ContentNode:pos(0, display.height)
end

function FullScreenBase:actionEnter()
    self._exiting = false

    self:show()

    self._ContentNode:stopAllActions()
    self._ContentNode:runAction(cca.sineOut(cca.moveTo(0.2, 0, 0)))
end

function FullScreenBase:actionExit(needRemove)
    local needRemove = needRemove
    if needRemove == nil then needRemove = true end

    if self._exiting then return end
    self._exiting = true

    self._ContentNode:stopAllActions()
    self._ContentNode:runAction(cca.sineIn(cca.moveTo(0.2, 0, display.height)))
    
    if needRemove then
        self:stopAllActions()
        self:runAction(cca.seq({
            cca.delay(0.2),
            cca.removeSelf(),
            }))
    else
        self:stopAllActions()
        self:runAction(cca.seq({
            cca.delay(0.2),
            cca.hide(),
            }))
    end
end

function FullScreenBase:getContentNode()
    return self._ContentNode
end

return FullScreenBase