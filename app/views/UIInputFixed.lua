
local UIInputFixed = class("UIInputFixed", function()
    return display.newNode()
end)

function UIInputFixed:ctor(options)
    -- self:setCascadeOpacityEnabled(true)

    self._input = cc.ui.UIInput.new(options)
        :addTo(self)
    -- self._input:setTouchEnabled(true)
    -- self._input:setCascadeOpacityEnabled(true)

    self._button = cc.ui.UIPushButton.new("image/transparent_unit.png")
        :setButtonSize(options.size.width, options.size.height)
        -- :opacity(100)
        :align(display.CENTER, 0, 0)
        :onButtonClicked(function()
            print(111)
            self._input:touchDownAction(self._input, ccui.TouchEventType.ended)
        end)
        :addTo(self)
end

UIInputFixed.originSetCascadeOpacityEnabled = cc.Node.setCascadeOpacityEnabled
function UIInputFixed:setCascadeOpacityEnabled(enabled)
    self._button:setCascadeOpacityEnabled(enabled)
    self._input:setCascadeOpacityEnabled(enabled)
    UIInputFixed.originSetCascadeOpacityEnabled(self, enabled)
    return self
end

UIInputFixed.originAlign = cc.Node.align
function UIInputFixed:align(anchorPoint, x, y)
    self._button:align(anchorPoint, 0, 0)
    self._input:align(anchorPoint, 0, 0)
    UIInputFixed.originAlign(self, anchorPoint, x, y)
    return self
end

UIInputFixed.originSetAnchorPoint = cc.Node.setAnchorPoint
function UIInputFixed:setAnchorPoint(...)
    self._button:setAnchorPoint(...)
    self._input:setAnchorPoint(...)
    UIInputFixed.originSetAnchorPoint(self, ...)
    return self
end

UIInputFixed.originPos = cc.Node.pos
function UIInputFixed:pos(x, y)
    self._button:pos(0, 0)
    self._input:pos(0, 0)
    UIInputFixed.originPos(self, x, y)
    return self
end

function UIInputFixed:getUIInput()
    return self._input
end

function UIInputFixed:getText()
    return self._input:getText()
end

function UIInputFixed:setText(...)
    self._input:setText(...)
end

function UIInputFixed:setReturnType(...)
    self._input:setReturnType(...)
end

function UIInputFixed:setFontColor(...)
    self._input:setFontColor(...)
end

function UIInputFixed:setPlaceHolder(...)
    self._input:setPlaceHolder(...)
end

function UIInputFixed:setPlaceholderFontColor(...)
    self._input:setPlaceholderFontColor(...)
end

function UIInputFixed:setInputFlag(...)
    self._input:setInputFlag(...)
end

function UIInputFixed:setInputMode(...)
    self._input:setInputMode(...)
end

function UIInputFixed:touchDownAction(...)
    self._input:touchDownAction(...)
end

function UIInputFixed:setMaxLength(...)
    self._input:setMaxLength(...)
end

return UIInputFixed