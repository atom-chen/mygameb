
local AddPuzzleGameController = require("app.controllers.AddPuzzleGameController")

local AddPuzzleGameScene = class("AddPuzzleGameScene", function()
    -- return display.newPhysicsScene("AddPuzzleGameScene")
    return display.newScene("AddPuzzleGameScene")
end)

function AddPuzzleGameScene:ctor()
	-- local _world = self:getPhysicsWorld()
    self:addChild(AddPuzzleGameController.new())
end

function AddPuzzleGameScene:onEnter()
end

function AddPuzzleGameScene:onExit()
end

return AddPuzzleGameScene
