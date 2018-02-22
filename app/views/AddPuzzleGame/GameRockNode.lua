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

	self._len = len-1
	self._color = color
	self._xid = xid
	self._yid = yid
	self._id =(yid-1)*GameMapConfig.ROCK_X+xid
	self._endNum = 0

	self._IDLIST = {}
	self._endAnimHandle = nil
	
	--瘦身
	local __s = 80
	
	self._lightNode = nil
	self._dir = dir

	if self._dir == GameMapConfig.DIR_TORIGHT then
		self._arp = display.LEFT_CENTER
		self._width = GameMapConfig.ROCK_WIDTH*self._len+GameMapConfig.ROCK_D*(self._len-1)-__s
		self._height = GameMapConfig.ROCK_HEIGHT-__s
		self._xA = self._GameController._MAP_XY[self._id].x+GameMapConfig.ROCK_WIDTH/2
		self._yA = self._GameController._MAP_XY[self._id].y+GameMapConfig.ROCK_HEIGHT/2
		self._xB = self._GameController._MAP_XY[self._id].x+GameMapConfig.ROCK_WIDTH/2+GameMapConfig.ROCK_WIDTH
		self._yB = self._GameController._MAP_XY[self._id].y+GameMapConfig.ROCK_HEIGHT/2

		for i=1,self._len do
			local __id = self._id+i
			table.insert(self._IDLIST, {id=__id,num=0})
		end

	elseif self._dir == GameMapConfig.DIR_TOLEFT then
		self._arp = display.RIGHT_CENTER
		self._width = GameMapConfig.ROCK_WIDTH*self._len+GameMapConfig.ROCK_D*(self._len-1)-__s
		self._height = GameMapConfig.ROCK_HEIGHT-__s
		self._xA = self._GameController._MAP_XY[self._id].x-GameMapConfig.ROCK_WIDTH/2+GameMapConfig.ROCK_WIDTH
		self._yA = self._GameController._MAP_XY[self._id].y+GameMapConfig.ROCK_HEIGHT/2
		self._xB = self._GameController._MAP_XY[self._id].x-GameMapConfig.ROCK_WIDTH/2+GameMapConfig.ROCK_WIDTH-GameMapConfig.ROCK_WIDTH
		self._yB = self._GameController._MAP_XY[self._id].y+GameMapConfig.ROCK_HEIGHT/2

		for i=1,self._len do
			local __id = self._id-i
			table.insert(self._IDLIST, {id=__id,num=0})
		end

	elseif self._dir == GameMapConfig.DIR_TOUP then
		self._arp = display.CENTER_BOTTOM
		self._width = GameMapConfig.ROCK_WIDTH-__s
		self._height = GameMapConfig.ROCK_HEIGHT*self._len+GameMapConfig.ROCK_D*(self._len-1)-__s
		self._xA = self._GameController._MAP_XY[self._id].x+GameMapConfig.ROCK_WIDTH/2
		self._yA = self._GameController._MAP_XY[self._id].y+GameMapConfig.ROCK_HEIGHT/2
		self._xB = self._GameController._MAP_XY[self._id].x+GameMapConfig.ROCK_WIDTH/2
		self._yB = self._GameController._MAP_XY[self._id].y+GameMapConfig.ROCK_HEIGHT/2+GameMapConfig.ROCK_HEIGHT

		for i=1,self._len do
			local __id = self._id+i*GameMapConfig.ROCK_X
			table.insert(self._IDLIST, {id=__id,num=0})
		end

	elseif self._dir == GameMapConfig.DIR_TODOWN then
		self._arp = display.CENTER_TOP
		self._width = GameMapConfig.ROCK_WIDTH-__s
		self._height = GameMapConfig.ROCK_HEIGHT*self._len+GameMapConfig.ROCK_D*(self._len-1)-__s
		self._xA = self._GameController._MAP_XY[self._id].x+GameMapConfig.ROCK_WIDTH/2
		self._yA = self._GameController._MAP_XY[self._id].y-GameMapConfig.ROCK_HEIGHT/2+GameMapConfig.ROCK_HEIGHT
		self._xB = self._GameController._MAP_XY[self._id].x+GameMapConfig.ROCK_WIDTH/2
		self._yB = self._GameController._MAP_XY[self._id].y-GameMapConfig.ROCK_HEIGHT/2+GameMapConfig.ROCK_HEIGHT-GameMapConfig.ROCK_HEIGHT
	
		for i=1,self._len do
			local __id = self._id-i*GameMapConfig.ROCK_X
			table.insert(self._IDLIST, {id=__id,num=0})
		end

	end



    if GameAddPuzzle_DEBUG then
		
	end

	self._mainBG_A = display.newScale9Sprite("image/game/rock_"..self._color..".png", 0, 0, 
		cc.size(130, 130), 
		cc.rect(50, 50, 2, 2))
		:align(display.CENTER, self._xA, self._yA)
		:addTo(self, _Zorder_Rock_Sprite)

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

	self._mainBG_B = display.newScale9Sprite("image/game/rock_"..self._color..".png", 0, 0, 
		cc.size(self._width, self._height), 
		cc.rect(50, 50, 2, 2))
		:align(self._arp, self._xB, self._yB)
		:addTo(self, _Zorder_Rock_Sprite)
	
end

function GameRockNode:setNum(id, num)
	for _,v in ipairs(self._IDLIST) do
		if v.id == id then
			v.num = num
		end
	end
end

function GameRockNode:makeNumEnd()
	local _result = 0
	for _,v in ipairs(self._IDLIST) do
		_result = _result+v.num
	end
	self._endNum:updateNum(_result, false)
	self._endNum = _result
end


function GameRockNode:checkEnd()
	local _result = 0
	for _,v in ipairs(self._IDLIST) do
		_result = _result+v.num
	end
	if _result == self._endNum then
		-- ok
		if not self._endAnimHandle then
			self._endAnimHandle = self._mainBG_A:runAction(cca.repeatForever(cca.seq({
										cca.rotateBy(0.5, 60),
									})))
		end
	else
		if self._endAnimHandle then
			self._mainBG_A:stopAction(self._endAnimHandle)
			self._endAnimHandle = nil
		end
		self._mainBG_A:setRotation(0)
	end
end














return GameRockNode