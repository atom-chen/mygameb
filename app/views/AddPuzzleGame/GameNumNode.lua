local GameConfig = require("app.core.GameConfig")
local GameMapConfig = require("app.core.Game.AddPuzzleGameConfig")
local GameUtils = require("app.core.GameUtils")
local utils = require("app.common.utils")

local GameNumNode = class("GameNumNode", function()
    return display.newNode()
end)

local _Zorder_Rock_Touch = 10
local _Zorder_Rock_Light = 15
local _Zorder_Rock_Sprite = 20
local _Zorder_Score = 22

function GameNumNode:ctor(params)
	self._GameController = APP:getObject("AddPuzzleGameController")
	self._num = params.num
	self._id = params.id

	local _touchSizeWidth, _touchSizeHeight = 110, 110

	self._x = self._GameController._MAP_XY[self._id].x+GameMapConfig.ROCK_WIDTH/2
	self._y = self._GameController._MAP_XY[self._id].y+GameMapConfig.ROCK_HEIGHT/2

	self._rockSpTouch = display.newScale9Sprite(GameMapConfig.ROCK_SHADOW_UNIT_PATH, 0, 0, 
        cc.size(_touchSizeWidth, _touchSizeHeight), 
        cc.rect(1, 1, 1, 1))
        :opacity(0)
        :align(display.CENTER, self._x, self._y)
        :addTo(self, _Zorder_Rock_Touch)
    self._rockSpTouch:setTouchEnabled(true)
    self._rockSpTouch:setTouchSwallowEnabled(true)
    self._rockSpTouch:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            -- print("---------", event.name, event.x, event.y)
            if event.name == "began" then
            	return self:touchStart(event.x, event.y)
            elseif event.name == "moved" then
                self:touchMove(event.x, event.y)
            elseif event.name == "ended" then
                self:touchEnded(event.x, event.y)
            end
        end)


	self._bg = display.newSolidCircle(50, {x = 0, y = 0, color = utils.c3bToc4f(GameConfig._COLOR["Snow"], 1)})
	self._bg:align(display.CENTER, _touchSizeWidth/2, _touchSizeHeight/2)
	self._bg:addTo(self._rockSpTouch, _Zorder_Rock_Sprite)

    local params = 
    {
        type = GameConfig._TOOLS_LABEL_TYPE[2],
        num = self._num,
        size = 88,
        isEnglishType = false,
        color = GameConfig._COLOR["Snow"], 
        borderColor = GameConfig._COLOR["Black"], 
        bordWidth = 4,
        shadowWidth = 4,
        fontPath = "effect/BRITANIC.TTF"
    }
    self._NumLabel = APP:createView("ToolsNumLabelNode",params)
						:align(display.CENTER, _touchSizeWidth/2, _touchSizeHeight/2)
						:addTo(self._rockSpTouch, _Zorder_Rock_Sprite)

end

function GameNumNode:changeId(newid, withAnim)
	self._id = newid
	self._x = self._GameController._MAP_XY[self._id].x+GameMapConfig.ROCK_WIDTH/2
	self._y = self._GameController._MAP_XY[self._id].y+GameMapConfig.ROCK_HEIGHT/2

	if not withAnim then
		self._rockSpTouch:setPosition(self._x, self._y)
	else
		self._rockSpTouch:runAction(cca.sineIn(cca.moveTo(0.2, self._x, self._y)))
	end
end

function GameNumNode:touchStart(x,y)
	-- print(self._id)
	return true	
end

function GameNumNode:touchMove(x,y)
	
end

function GameNumNode:touchEnded(x,y)
	self._GameController:touchNum(self._id)
end

function GameNumNode:beChooseed()
	self._bg:runAction(cca.repeatForever(cca.seq({
										cca.scaleTo(0.2, 1.1),
										cca.scaleTo(0.2, 1),
									})))
end

function GameNumNode:unChooseed()
	self._bg:stopAllActions()
	self._bg:setScale(1)
end

return GameNumNode