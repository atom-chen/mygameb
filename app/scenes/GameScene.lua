
local GameController = require("app.controllers.GameController")

local GameScene = class("GameScene", function()
    -- return display.newPhysicsScene("GameScene")
    return display.newScene("GameScene")
end)

function GameScene:ctor()
	-- local _world = self:getPhysicsWorld()
    self:addChild(GameController.new())
end

function GameScene:onEnter()
end

function GameScene:onExit()
end

return GameScene
