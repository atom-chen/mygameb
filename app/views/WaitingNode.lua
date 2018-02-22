
local WaitingNode = class("WaitingNode", function()
    return display.newNode()
end)

function WaitingNode:ctor(options)

    local options = options or {}
    local blank = options.blank or false

    local bg = display.newSprite("image/white_unit.png")
        :align(display.CENTER, 0, 0)
        :addTo(self)
    bg:setColor(cc.c3b(0, 0, 0))
    bg:setScaleX(display.width)
    bg:setScaleY(display.height)
    bg:setTouchEnabled(true)
    bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
    end)

    if blank then
        bg:opacity(0)
    else
        bg:opacity(120)
    end

    if not blank then
        
        local jh = display.newSprite("image/game/bg_3.png")
            :align(display.CENTER, 0, 0)
            :addTo(self,11)
        jh:runAction(cca.repeatForever(cca.seq({
                cca.rotateBy(1, 360)
            })))
    end
end

return WaitingNode