local GameConfig = require("app.core.GameConfig")
local GameMapConfig = require("app.core.Game.AddPuzzleGameConfig")
local GameUtils = require("app.core.GameUtils")

local GameRockNode = class("GameRockNode", function()
    return display.newNode()
end)

local _Zorder_Rock_Touch = 10
local _Zorder_Rock_Light = 15
local _Zorder_Rock_Sprite = 20
local _Zorder_Score = 22

function GameRockNode:ctor(len, color, xid, yid, dir)
	self._GameController = APP:getObject("AddPuzzleGameController")
	table.insert(self._GameController._rocks, self)
	self._len = len
	self._color = color
	self._xid = xid
	self._yid = yid
	self._x = self._GameController._MAP_XY[self._id].x
	self._y = self._GameController._MAP_XY[self._id].y
	self._lightNode = nil
	self._dir = dir

	self._moveX = 0
	self._moveY = 0
	self._startX = 0
	
	self._width = GameMapConfig.ROCK_WIDTH*self._len+GameMapConfig.ROCK_D*(self._len-1)
	self._height = GameMapConfig.ROCK_HEIGHT


    if GameAddPuzzle_DEBUG then
		
	end

	display.newScale9Sprite("image/game/rock_"..self._color..".png", 0, 0, 
		cc.size(self._width, self._height), 
		cc.rect(50, 50, 2, 2))
		:pos(self._x, self._y)
		:addTo(self, _Zorder_Rock_Sprite)
end



return GameRockNode