local GameConfig = require("app.core.GameConfig")
local GameMapConfig = require("app.core.Game.PokerPuzzleGameConfig")
local GameUtils = require("app.core.GameUtils")

local GameRockNode = class("GameRockNode", function()
    return display.newNode()
end)

local _Zorder_Rock_Touch = 10
local _Zorder_Rock_Light = 15
local _Zorder_Rock_Sprite = 20
local _Zorder_Score = 22

function GameRockNode:ctor(len, color, xid, yid, dir, index)
	self._GameController = APP:getObject("PokerPuzzleGameController")

	self._len = len
	self._color = color
	self._xid = xid
	self._yid = yid
	self._id = (yid-1)*GameMapConfig.ROCK_X+xid
	self._endNum = 0

	self._PokerList = {}
	self._endAnimHandle = nil
	
	--瘦身
	local __s = 20+index*18
	
	self._dir = dir

	if self._dir == GameMapConfig.DIR_TORIGHT then
		self._arp = display.LEFT_CENTER
		self._width = GameMapConfig.ROCK_WIDTH*self._len+GameMapConfig.ROCK_D*(self._len-1)-__s
		self._height = GameMapConfig.ROCK_HEIGHT-__s
		self._xA = self._GameController._MAP_XY[self._id].x+__s/2
		self._yA = self._GameController._MAP_XY[self._id].y+GameMapConfig.ROCK_HEIGHT/2
		
		for i=1,self._len do
			local __id = self._id+i
			table.insert(self._PokerList, {id=__id,poker=nil})
		end

	elseif self._dir == GameMapConfig.DIR_TOLEFT then
		self._arp = display.RIGHT_CENTER
		self._width = GameMapConfig.ROCK_WIDTH*self._len+GameMapConfig.ROCK_D*(self._len-1)-__s
		self._height = GameMapConfig.ROCK_HEIGHT-__s
		self._xA = self._GameController._MAP_XY[self._id].x+GameMapConfig.ROCK_WIDTH-__s/2
		self._yA = self._GameController._MAP_XY[self._id].y+GameMapConfig.ROCK_HEIGHT/2
		
		for i=1,self._len do
			local __id = self._id-i
			table.insert(self._PokerList, {id=__id,poker=nil})
		end

	elseif self._dir == GameMapConfig.DIR_TOUP then
		self._arp = display.CENTER_BOTTOM
		self._width = GameMapConfig.ROCK_WIDTH-__s
		self._height = GameMapConfig.ROCK_HEIGHT*self._len+GameMapConfig.ROCK_D*(self._len-1)-__s
		self._xA = self._GameController._MAP_XY[self._id].x+GameMapConfig.ROCK_WIDTH/2
		self._yA = self._GameController._MAP_XY[self._id].y+__s/2
		
		for i=1,self._len do
			local __id = self._id+i*GameMapConfig.ROCK_X
			table.insert(self._PokerList, {id=__id,poker=nil})
		end

	elseif self._dir == GameMapConfig.DIR_TODOWN then
		self._arp = display.CENTER_TOP
		self._width = GameMapConfig.ROCK_WIDTH-__s
		self._height = GameMapConfig.ROCK_HEIGHT*self._len+GameMapConfig.ROCK_D*(self._len-1)-__s
		self._xA = self._GameController._MAP_XY[self._id].x+GameMapConfig.ROCK_WIDTH/2
		self._yA = self._GameController._MAP_XY[self._id].y+GameMapConfig.ROCK_HEIGHT-__s/2
		
		for i=1,self._len do
			local __id = self._id-i*GameMapConfig.ROCK_X
			table.insert(self._PokerList, {id=__id,poker=nil})
		end

	end



    if GameAddPuzzle_DEBUG then
		
	end

	
	local params = 
	{
		type = GameConfig._TOOLS_LABEL_TYPE[2],
		num = 0,
		size = 88,
		isEnglishType = false,
		color = GameConfig._COLOR["Red"], 
		borderColor = GameConfig._COLOR["Purple1"], 
		bordWidth = 4,
		shadowWidth = 4,
		fontPath = "effect/BRITANIC.TTF"
	}
	self._endNum = APP:createView("ToolsNumLabelNode",params)
						:align(display.CENTER, self._xA, self._yA)
						:addTo(self, _Zorder_Score)

	self._mainBG = display.newScale9Sprite("image/game/rock_"..self._color..".png", 0, 0, 
		cc.size(self._width, self._height), 
		cc.rect(50, 50, 2, 2))
		:align(self._arp, self._xA, self._yA)
		:addTo(self, _Zorder_Rock_Sprite)
	
end


































return GameRockNode