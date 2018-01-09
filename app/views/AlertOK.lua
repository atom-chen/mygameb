
local AlertOK = class("AlertOK", function()
    return display.newNode()
end)

function AlertOK:ctor(options)
    local title = options.title or "温馨提示"
    local descText = options.desc or ""
    local okText = options.ok or "ok"
    local okCallback = options.okCallback or nil

    local bg = cc.ui.UIPushButton.new("image/white_unit.png")
        :setButtonSize(display.width, display.height)
        :align(display.CENTER, 0, 0)
        :addTo(self,-1)
    bg:setColor(cc.c3b(0, 0, 0))
    bg:setOpacity(150)

    -- desc
    local descLabel = cc.ui.UILabel.new({
            text = descText, 
            size = 28,
            color = cc.c3b(166, 98, 0),
            align = cc.ui.TEXT_ALIGN_CENTER})
        :align(display.CENTER, 0, 50)
        :addTo(self,2)
    descLabel:setDimensions(450, 0)
    local descHeight = 0--descLabel:getContentSize().height

    -- 框
    self._alertBG = display.newSprite("image/ui/tips_comform.png")
        :align(display.CENTER, 0, 0)
        :addTo(self)

    -- ok button
    cc.ui.UIPushButton.new("image/ui/tips_btn_green.png")
        :onButtonClicked(function() 
            if okCallback then
                okCallback()
            end
            self:actionExit()
        end)
        :align(display.CENTER, 0, -95- descHeight/2)
        :addTo(self)

    local okLabel = cc.ui.UILabel.new({text = okText, size = 30,
        color = cc.c3b(138, 80, 45)})
        :align(display.CENTER, 0, -95- descHeight/2)
        :addTo(self)

end

function AlertOK:actionEnter()
    
end

function AlertOK:actionExit()
    self:removeSelf()
end


return AlertOK