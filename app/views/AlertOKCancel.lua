
local AlertOKCancel = class("AlertOKCancel", function()
    return display.newNode()
end)

function AlertOKCancel:ctor(options)
    -- local title = options.title or "温馨提示"
    local descText = options.desc or ""
    local okText = options.ok or "ok"
    local cancelText = options.cancel or "cancel"
    local okCallback = options.okCallback or nil
    local cancelCallback = options.cancelCallback or nil

    local bg = cc.ui.UIPushButton.new("image/white_unit.png")
        :setButtonSize(display.width, display.height)
        :align(display.CENTER, 0, 0)
        :addTo(self,-1)
    bg:setColor(cc.c3b(0, 0, 0))
    bg:setOpacity(150)

    -- desc
    local descLabel = cc.ui.UILabel.new({
            text = descText, 
            size = 34,
            color = cc.c3b(166, 98, 0),
            align = cc.ui.TEXT_ALIGN_CENTER})
        :align(display.CENTER, 0, 20)
        :addTo(self,2)
    descLabel:setDimensions(450, 120)
    local descHeight = 0--descLabel:getContentSize().height

    -- 框
    self._alertBG = display.newSprite("image/ui/tips_comform.png")
        :align(display.CENTER, 0, 0)
        :addTo(self)

    -- title
        -- cc.ui.UILabel.new({
        --     text = title, 
        --     size = 30,
        --     color = cc.c3b(10, 85, 80),
        --     align = cc.ui.TEXT_ALIGN_CENTER})
        -- :align(display.CENTER, 0, 142 + descHeight/2)
        -- :addTo(self)     

    -- ok button
    cc.ui.UIPushButton.new("image/ui/tips_btn_green.png")
        :onButtonClicked(function() 
            if okCallback then
                okCallback()
            end
            self:actionExit()
        end)
        :align(display.CENTER, 150, -90- descHeight/2)
        :addTo(self)

    local okLabel = cc.ui.UILabel.new({text = okText, size = 30,
        color = cc.c3b(10, 85, 85)})
        :align(display.CENTER, 150, -90- descHeight/2)
        :addTo(self)

    -- cancel
    cc.ui.UIPushButton.new("image/ui/tips_btn_red.png")
        :onButtonClicked(function() 
            if cancelCallback then
                cancelCallback()
            end
            self:actionExit()
        end)
        :align(display.CENTER, -150, -90- descHeight/2)
        :addTo(self)

    local okLabel = cc.ui.UILabel.new({text = cancelText, size = 30,
        color = cc.c3b(138, 80, 45)})
        :align(display.CENTER, -150, -90- descHeight/2)
        :addTo(self)    

end

function AlertOKCancel:actionEnter()
    
end

function AlertOKCancel:actionExit()
    self:removeSelf()
end

return AlertOKCancel