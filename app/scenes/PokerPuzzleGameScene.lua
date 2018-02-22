
local PokerPuzzleGameController = require("app.controllers.PokerPuzzleGame.PokerPuzzleGameController")

local AddPuzzleGameScene = class("AddPuzzleGameScene", function()
    -- return display.newPhysicsScene("AddPuzzleGameScene")
    return display.newScene("AddPuzzleGameScene")
end)

function AddPuzzleGameScene:ctor()
	-- local _world = self:getPhysicsWorld()
    self:addChild(PokerPuzzleGameController.new())
end

function AddPuzzleGameScene:onEnter()
end

function AddPuzzleGameScene:onExit()
end

return AddPuzzleGameScene
