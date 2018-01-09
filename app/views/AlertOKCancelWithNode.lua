
local AlertOKCancelWithNode = class("AlertOKCancelWithNode", function()
    return display.newNode()
end)

function AlertOKCancelWithNode:ctor(options)

    local title = options.title or "温馨提示"
    local descNode = options.descNode or display.newNode()
    local okText = options.ok or "确 定"
    local cancelText = options.cancel or "取 消"
    local okCallback = options.okCallback or nil
    local cancelCallback = options.cancelCallback or nil

    local bg = cc.ui.UIPushButton.new("image/white_unit.png")
        :setButtonSize(display.width, display.height)
        :align(display.CENTER, 0, 0)
        :addTo(self,-1)
    bg:setColor(cc.c3b(0, 0, 0))
    bg:setOpacity(150)

    -- desc
    descNode:align(display.CENTER, 0, 16)
        :addTo(self,2)

    -- title
        cc.ui.UILabel.new({
            text = title, 
            size = 30,
            color = cc.c3b(10, 85, 80),
            align = cc.ui.TEXT_ALIGN_CENTER})
        :align(display.CENTER, 0, 142)
        :addTo(self)    

    -- 框
    -- self._alertBG = display.newSprite("image/com_form_tips.png")
    --     :align(display.CENTER, 0, 0)
    --     :addTo(self,-1)

    self._alertBG = display.newScale9Sprite("image/com_form_tips.png", 0, 0, 
        cc.size(options.width or 661, 353),
        cc.rect(330, 150, 1, 1))
        :align(display.CENTER, 0, 0)
        :addTo(self,-1)

    -- ok button
    cc.ui.UIPushButton.new("image/com_button_yellow.png")
        :onButtonClicked(function() 
            if okCallback then
                okCallback()
            end
            self:removeFromParent()
        end)
        :align(display.CENTER, 110, -115)
        :addTo(self)

    local okLabel = cc.ui.UILabel.new({text = okText, size = 30,
        color = cc.c3b(138, 80, 45)})
        :align(display.CENTER, 110, -115)
        :addTo(self)

    -- cancel
    cc.ui.UIPushButton.new("image/com_button_cyan.png")
        :onButtonClicked(function() 
            if cancelCallback then
                cancelCallback()
            end
            self:removeFromParent()
        end)
        :align(display.CENTER, -110, -115)
        :addTo(self)

    local okLabel = cc.ui.UILabel.new({text = cancelText, size = 30,
        color = cc.c3b(10, 85, 85)})
        :align(display.CENTER, -110, -115)
        :addTo(self)    

end

function AlertOKCancelWithNode:actionEnter()
    
end

function AlertOKCancelWithNode:actionExit()
    self:removeSelf()
end

return AlertOKCancelWithNode