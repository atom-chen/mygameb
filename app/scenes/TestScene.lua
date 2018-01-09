
local TestController = require("app.controllers.TestController")

local TestScene = class("TestScene", function()
    -- return display.newPhysicsScene("TestScene")
    return display.newScene("TestScene")
end)

function TestScene:ctor()
	-- local _world = self:getPhysicsWorld()
    self:addChild(TestController.new())
end

function TestScene:onEnter()
end

function TestScene:onExit()
end

return TestScene
