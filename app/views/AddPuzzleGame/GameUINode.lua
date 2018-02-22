local GameConfig = require("app.core.GameConfig")

local GameUINode = class("GameUINode", function()
    return display.newNode()
end)

function GameUINode:ctor()
	self._GameController = APP:getObject("AddPuzzleGameController")

	self:initUI()
end

function GameUINode:initUI()
	-- test btn
	local btnImage = 
		{
		    normal = "image/ui/lobby_button_ranking.png",
		    pressed = "image/ui/lobby_button_ranking.png",
		    disabled = "image/ui/lobby_button_ranking.png"
		}
	self._btnRank = cc.ui.UIPushButton.new(btnImage)
		:onButtonPressed(function(event) event.target:scale(1.1) end)
		:onButtonRelease(function(event) event.target:scale(1) end)
		:onButtonClicked(function()
			
			self._GameController:restartGame()
			
		end)
		:align(display.CENTER, 90, 90)
		:addTo(self, 1)

end


return GameUINode