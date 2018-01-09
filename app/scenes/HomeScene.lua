
local HomeController = require("app.controllers.HomeController")

local HomeScene = class("HomeScene", function()
    -- return display.newPhysicsScene("HomeScene")
    return display.newScene("HomeScene")
end)

function HomeScene:ctor()
	-- local _world = self:getPhysicsWorld()
    self:addChild(HomeController.new())
end

function HomeScene:onEnter()
end

function HomeScene:onExit()
end

return HomeScene
