
local ViewBase = class("ViewBase", function()
    return display.newNode()
end)

function ViewBase:ctor()
    if self._setObject == nil then
        self._setObject = true
    end

    self:setNodeEventEnabled(true)
    self:setCascadeOpacityEnabled(true)
end

function ViewBase:onEnter()
    if self._setObject then
        APP:setObject(self.__cname, self)
    end
end

function ViewBase:onExit()
    if self._setObject then
        APP:removeObject(self.__cname)
    end
end

return ViewBase