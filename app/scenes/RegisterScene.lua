--
-- Author: gerry
-- Date: 2016-01-11 16:23:50
--

local RegisterController = require("app.controllers.RegisterController")

local RegisterScene = class("RegisterScene", function()
    return display.newScene("RegisterScene")
end)

function RegisterScene:ctor()
    self:addChild(RegisterController.new())
end

function RegisterScene:onEnter()
end

function RegisterScene:onExit()
end

return RegisterScene
