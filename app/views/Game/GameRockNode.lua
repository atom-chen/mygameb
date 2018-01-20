local GameConfig = require("app.core.GameConfig")
local GameMapConfig = require("app.core.Game.GameMapConfig")
local GameUtils = require("app.core.GameUtils")

local GameRockNode = class("GameRockNode", function()
    return display.newNode()
end)

local _Zorder_Rock_Touch = 10
local _Zorder_Rock_Light = 15
local _Zorder_Rock_Sprite = 20
local _Zorder_Score = 22

function GameRockNode:ctor(len, color, xid, yid)
	self._GameController = APP:getObject("GameController")
	table.insert(self._GameController._rocks, self)
	self._len = len
	self._color = color
	self._xid = xid
	self._yid = yid
	self._id =(yid-1)*GameMapConfig.ROCK_X+xid
	self._x = self._GameController._MAP_XY[self._id].x
	self._y = self._GameController._MAP_XY[self._id].y
	self._lightNode = nil
	-- 暂时分数等于len
	self._score = self._len*10

	self._moveX = 0
	self._moveY = 0
	self._startX = 0
	
	self._width = GameMapConfig.ROCK_WIDTH*self._len+GameMapConfig.ROCK_D*(self._len-1)
	self._height = GameMapConfig.ROCK_HEIGHT

	self._rockSpTouch = display.newScale9Sprite(GameMapConfig.ROCK_SHADOW_UNIT_PATH, 0, 0, 
        cc.size(self._width, self._height), 
        cc.rect(1, 1, 1, 1))
        :opacity(0)
        :align(display.BOTTOM_LEFT, self._x, self._y)
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

    if M_DEBUG then
		-- test
		display.newRect(cc.rect(0, 0, self._width, self._height),{
				fillColor = GameMapConfig.ROCK_COLOR[self._color], 
				borderColor = GameMapConfig.ROCK_COLOR_BORDER, 
				borderWidth = 1
			})
			:addTo(self._rockSpTouch, 255)
	end

	display.newScale9Sprite("image/game/rock_"..self._color..".png", 0, 0, 
		cc.size(self._width, self._height), 
		cc.rect(50, 50, 2, 2))
		:pos(self._width/2, self._height/2)
		:addTo(self._rockSpTouch, _Zorder_Rock_Sprite)
end

function GameRockNode:checkPos()
	for i,_x in ipairs(self._GameController._MAP_CELL_X) do
		-- 头部
		if (self._moveX-_x) > 0 and (self._moveX-_x) <= GameMapConfig.ROCK_WIDTH/3 then
			self._moveX = _x
			self._rockSpTouch:setPositionX(self._moveX)
			self._GameController._canCheckRocks = false
		end
		-- 尾部
		if (_x-(self._moveX+self._width)) > 0 and (_x-(self._moveX+self._width)) <= GameMapConfig.ROCK_WIDTH/3 then
			self._moveX = _x - self._width - GameMapConfig.ROCK_D
			self._rockSpTouch:setPositionX(self._moveX)
			self._GameController._canCheckRocks = false
		end
	end
end

function GameRockNode:checkPosEnd()
	for i,_x in ipairs(self._GameController._MAP_CELL_X) do
		-- 头部
		if (self._moveX-_x) >= 0 and (self._moveX-_x) <= GameMapConfig.ROCK_WIDTH then
			if (self._moveX-_x) <= GameMapConfig.ROCK_WIDTH/3 then
				self._moveX = _x
				self._rockSpTouch:setPositionX(self._moveX)
				self._x = self._moveX
				break
			else
				self._moveX = self._GameController._MAP_CELL_X[i+1]
				self._rockSpTouch:setPositionX(self._moveX)
				self._x = self._moveX
				break
			end
		end
	end
end

function GameRockNode:checkMinMaxPosX(x)
	local _compList = {}
	for _,v in ipairs(self._GameController._rocks) do
		if v._yid == self._yid then 
			table.insert(_compList, v)
		end
	end

	table.sort(_compList, function(a, b)
			return b._xid > a._xid
		end)

	local __minX, __maxX = 0, 0

	for i,v in ipairs(_compList) do
		if v._xid == self._xid then 
			local _minid = i-1
			local _maxid = i+1

			if _minid == 0 then
				__minX = self._GameController._MAP_MIN_X 
			else
				__minX = _compList[_minid]._x+_compList[_minid]._width+GameMapConfig.ROCK_D
			end

			if _maxid > #_compList then
				__maxX = self._GameController._MAP_MAX_X-self._width
			else
				__maxX = _compList[_maxid]._x-GameMapConfig.ROCK_D-self._width
			end
		end
	end


	x = math.max(x, __minX)
	x = math.min(x, __maxX)
	return x
end

function GameRockNode:touchStart(x,y)
	if not self._GameController._MOVE_LOCK then
		self._moveX = self._x
		self._moveY = self._y
		self._GameController._canCheckRocks = true
		self._GameController._checkRock = self
		self:initLightNode(self._xid, self._len)
		self._startX = x
		return true
	else
		return false
	end
end

function GameRockNode:touchMove(x,y)
	if not self._GameController._MOVE_LOCK then
		self._GameController._canCheckRocks = true
		local _dsX = x - self._startX
		self._moveX = self:checkMinMaxPosX(self._x+_dsX)
		self._rockSpTouch:setPositionX(self._moveX)
	end
end

function GameRockNode:touchEnded(x,y)
	if not self._GameController._MOVE_LOCK then
		self:removeLightNode()
		self._GameController._canCheckRocks = false
		self._GameController._checkRock = nil
		self:checkPosEnd()

		-- over
		local _canRoundOver = false
		for _id, _xy in ipairs(self._GameController._MAP_XY) do
			if _xy.x == self._x and _xy.y == self._y then
				if _id ~= self._id then
					_canRoundOver = true
					self._id = _id
					break
				end
			end
		end

		if _canRoundOver then
			self._xid = self._id%8
			if self._xid == 0 then self._xid = 8 end
			self._yid = math.ceil(self._id/8)

			self._GameController:roundOver()
		end
	end
end

function GameRockNode:updatePosA(xid, yid)
	self._xid = xid
	self._yid = yid
	self._id =(yid-1)*GameMapConfig.ROCK_X+xid
	self._x = self._GameController._MAP_XY[self._id].x
	self._y = self._GameController._MAP_XY[self._id].y

end

function GameRockNode:updatePosB(time)
	self._rockSpTouch:runAction(cca.seq({
			cca.moveTo(time*GameMapConfig.MOVE_SPEED, self._x, self._y)
		}))
	-- self._rockSpTouch:pos(self._x, self._y)
end

function GameRockNode:checkDown(_res)
	if self._yid > 1 then
		local _compList = {}
		for _,v in ipairs(self._GameController._rocks) do
			if v._yid == (self._yid-1) then 
				table.insert(_compList, v)
			end
		end

		table.sort(_compList, function(a, b)
				return b._xid > a._xid
			end)

		local _myPosMinX = self._xid
		local _myPosMaxX = self._xid+self._len-1

		local _voo = {}
		for i=1, GameMapConfig.ROCK_X do
			table.insert(_voo, 0)
		end
		for _,v in ipairs(_compList) do
			local _voPosMinX = v._xid
			local _voPosMaxX = v._xid+v._len-1
			for i=_voPosMinX, _voPosMaxX do
				_voo[i] = 1
			end
		end

		local _canDown = true
		for i=_myPosMinX,_myPosMaxX do
			if _voo[i] == 1 then
				_canDown = false
			end
		end

		if _canDown then
			_res._times = _res._times+1
			self:updatePosA(self._xid, self._yid-1)
			self:checkDown(_res)
		else
			if _res._times > 0 then
				self:updatePosB(_res._times)
			end
		end
	else
		if _res._times > 0 then
			self:updatePosB(_res._times)
		end
	end
	return 0
end

function GameRockNode:clean(delay)
	for i,v in ipairs(self._GameController._rocks) do
		if v._xid == self._xid and v._yid == self._yid then 
			table.remove(self._GameController._rocks, i)
			self._rockSpTouch:runAction(cca.seq({
				cca.delay(delay),
				cca.moveTo(0.05, self._x-10, self._y),
				cca.moveTo(0.05, self._x+10, self._y),
				cca.moveTo(0.05, self._x-10, self._y),
				cca.moveTo(0.05, self._x+10, self._y),
				cca.moveTo(0.05, self._x-10, self._y),
				cca.moveTo(0.05, self._x+10, self._y),
				cca.moveTo(0.05, self._x-10, self._y),
				cca.moveTo(0.05, self._x+10, self._y),
				cca.hide(),
			}))
			self:runAction(cca.seq({
				cca.delay(delay+1),
				cca.removeSelf(),
			}))
		end
	end
end


-- 背景发光
function GameRockNode:initLightNode(xId, len)
	if self._lightNode then
		self._lightNode:removeSelf()
		self._lightNode = nil
	end

	local _lenY = GameMapConfig.ROCK_Y-self._yid+1
	local _width = GameMapConfig.ROCK_WIDTH*len+GameMapConfig.ROCK_D*(len-1)
	local _height = GameMapConfig.ROCK_HEIGHT*_lenY+GameMapConfig.ROCK_D*(_lenY-1)

	
	self._lightNode = display.newScale9Sprite(GameMapConfig.ROCK_SHADOW_UNIT_PATH, 0, 0, 
        cc.size(_width, _height), 
        cc.rect(1, 1, 1, 1))
        :opacity(120)
        :align(display.BOTTOM_LEFT, 0, 0)
        :addTo(self._rockSpTouch, _Zorder_Rock_Light)

    self:setLocalZOrder(GameMapConfig._GameRockNode_Zorder_Min)
end


function GameRockNode:moveLightNode(moveX)
	self._lightNode:setPositionX(moveX)

end


function GameRockNode:removeLightNode()
	if self._lightNode then
		self._lightNode:removeSelf()
	end
	self._lightNode = nil
	self:setLocalZOrder(GameMapConfig._GameRockNode_Zorder)
end


-- 得分显示
function GameRockNode:showGetScore()
    local params = 
    {
        type = GameConfig._TOOLS_LABEL_TYPE[4],
        text = "+"..tostring(self._score),
        -- num = self._score,
        size = 50,
        isEnglishType = true,
        color = GameConfig._COLOR["Snow"], 
        borderColor = GameConfig._COLOR["Purple1"], 
        bordWidth = 2,
        shadowWidth = 4,
        fontPath = "effect/BRITANIC.TTF"
    }
    local _scoreVo = APP:createView("ToolsWordLabelNode",params)
            :pos(self._x+self._width/2, self._y+self._height/2)
            :addTo(self, _Zorder_Score)
    GameUtils.onePopAndRaiseOutNode(_scoreVo)
end




return GameRockNode