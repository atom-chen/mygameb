--
-- Author: gerry
-- Date: 2016-01-11 13:47:00
--

local AlertFade = class("AlertFade", function()
    return display.newNode()
end)

function AlertFade:ctor(options)
    local descText = options.desc or ""
    local fail = options.fail

    self._alertBG = display.newScale9Sprite("image/alert_fade_back.png", 
        0, 0, cc.size(338,320), cc.rect(30,30,10,10))
        :align(display.CENTER, display.cx, display.cy+70)
        :opacity(0)
        :addTo(self,-1)
    self._alertBG:setCascadeOpacityEnabled(true)

    if fail then
        display.newSprite("image/alert_fade_fail.png")
            :align(display.CENTER, self._alertBG:getContentSize().width/2, 
                self._alertBG:getContentSize().height/2 + 15)
            :addTo(self._alertBG)            
    else
        display.newSprite("image/alert_fade_ok.png")
            :align(display.CENTER, self._alertBG:getContentSize().width/2, 
                self._alertBG:getContentSize().height/2 + 15)
            :addTo(self._alertBG)
    end

    -- desc
    local descLabel = cc.ui.UILabel.new({
            text = descText, 
            size = 30,
            align = cc.ui.TEXT_ALIGN_CENTER})
        :align(display.CENTER, self._alertBG:getContentSize().width/2, 56)
        :addTo(self._alertBG)

    self._alertBG:runAction(cca.seq({cca.fadeIn(0.1),cca.delay(3.0),
            cca.fadeOut(1.0),cca.removeSelf()}))
end



return AlertFade