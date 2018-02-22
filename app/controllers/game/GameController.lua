--
-- Author: gerry
-- Date: 2015-11-26 15:08:53
--
local GameUtils = require("app.core.GameUtils")
local GameConfig = require("app.core.GameConfig")
local ControllerBase = require("app.controllers.ControllerBase")
local scheduler = require("framework.scheduler")
local GameController = class("GameController", ControllerBase)
local GlobalStatus = APP:getObject("GlobalStatus")
local utils = require("app.common.utils")
local GameMapConfig = require("app.core.Game.GameMapConfig")
local GameOneFSM = require("app.gamelogic.GameOneFSM")
local GameRocksLogic = require("app.gamelogic.GameRocksLogic")

function GameController:ctor()
	-- print("os time 1: ", os.time())
	-- print("os time 2: ", tostring(os.time()):reverse():sub(1, 6))
	-- print("socket time 1: ", socket.gettime())
	-- print("socket time 2: ", tostring(socket.gettime()):reverse():sub(1, 6))
    GameController.super.ctor(self)
    self._SCORE = 0
    self._MAP_XY = {}
    self._MAP_MIN_X = 0
    self._MAP_MIN_Y = 0
    self._MAP_MAX_X = 0
    self._MAP_MAX_Y = 0
    self._MAP_CELL_X = {}
    self._MOVE_LOCK = false
    self._rocks = {} -- controller 无需add
    self._canCheckRocks = false
    self._checkRock = nil
    self._nextRocks = {}
    
    self._bgView = APP:createView("Game.GameBgNode")
        :addTo(self, GameMapConfig._GameBgNode_Zorder)

    self._mapView = APP:createView("Game.GameMapNode")
        :addTo(self, GameMapConfig._GameMapNode_Zorder)

    self._nextView = APP:createView("Game.GameNextNode")
    	:addTo(self, GameMapConfig._GameNextNode_Zorder)

    self._uiView = APP:createView("Game.GameUINode")
    	:addTo(self, GameMapConfig._GameUINode_Zorder)

    self._fsm = GameOneFSM.new()


    -- self:gameStart()

    
end

function GameController:onEnter()
	GameController.super.onEnter(self)
    self._handelA = scheduler.scheduleGlobal(handler(self, self.onCollisionA), 0)
    self._handelB = scheduler.scheduleGlobal(handler(self, self.onCollisionB), 0)
end

function GameController:onExit()
    GameController.super.onExit(self)
    scheduler.unscheduleGlobal(self._handelA)
end




-------------------------------
-------- onCollision ----------
-------------------------------
function GameController:onCollisionA(dt)
	if self._canCheckRocks then
	    if self._checkRock then
	    	self._checkRock:checkPos()
	    end
	end
end

function GameController:onCollisionB(dt)
	self._bgView:onCollision(dt)
end
-------------------------------
-------- onCollision end ------
-------------------------------




function GameController:gameStart()
	self:autoCreateRocks(1)
	self:autoCreateRocks(2)
	self:autoCreateRocks(-1)
end


function GameController:autoCreateRocks(lineNum, isFirst)
	local _cb = function(res)
					if lineNum == -1 then
						self._nextRocks = res
						self._nextView:rest()
					end
					local _sid = 1
					for _,v in ipairs(res) do
						if v.color > 0 then
							if lineNum == -1 then
								self._nextView:addRocks(v.len, _sid)
							else
								APP:createView("Game.GameRockNode", v.len, v.color, _sid, lineNum)
									:addTo(self, GameMapConfig._GameRockNode_Zorder)
							end
						end
						_sid = _sid+v.len
					end
				end

	if not isFirst then
		self:autoCreateRocksA({}, lineNum, _cb)
	else
		self:autoCreateRocksB({}, lineNum, _cb)
	end
end


function GameController:autoCreateRocksA(res, lineNum, callBack)
	local _delayTime = 0
	if #res > 0 then
		_delayTime = 0.1
	end
	self:runAction(cca.seq({
		cca.delay(_delayTime),
		cca.cb(function()
				GameRocksLogic.autoCreateRocksTypeB(res, callBack)
		end),
	}))
end


function GameController:autoCreateRocksB(res, lineNum, callBack)
	local _delayTime = 0
	if #res > 0 then
		_delayTime = 0.1
	end
	local presetType = ""
	if lineNum == 2 then
		presetType = "_0_0000_"
	elseif lineNum == 1 then
		presetType = "_0000000"
	end
	self:runAction(cca.seq({
		cca.delay(_delayTime),
		cca.cb(function()
				GameRocksLogic.autoCreateRocksTypeB(res, callBack, presetType)
		end),
	}))
end


function GameController:roundOver()
	self._MOVE_LOCK = true
	self._fsmOP = true
	local _otAction = nil
	_otAction = self:runAction(cca.repeatForever(cca.seq({
				cca.delay(0.1),
				cca.cb(function() 
						if self._fsmOP then
							self._fsmOP = false
							local _nextState = self._fsm:getNextState()
							if _nextState == "down" then
								self:gotoDown()
							elseif _nextState == "clean" then
								self:gotoClean()
							elseif _nextState == "up" then
								self:gotoUp(self._cleanTimes+1)
							elseif _nextState == "done" then
								self._fsmOP = true
								self._fsm:doEvent("done")
								self._MOVE_LOCK = false
								self:stopAction(_otAction)
							end
						end

					end),
				})))

end

------------------------
-- 状态
------------------------
function GameController:gotoDown()
	self._cleanTimes = 0
	local _moveDelayerVo = {_times = 0}
	self:checkDown({0}, _moveDelayerVo)
	local delayTime = _moveDelayerVo._times*GameMapConfig.MOVE_SPEED
	if delayTime > 0 then
		delayTime = delayTime+0.1
	end
	self:runAction(cca.seq({
		cca.delay(delayTime),
		cca.cb(function(delayTime)
				self._fsmOP = true
				self._fsm:doEvent("down")
			end),
	}))
end

function GameController:gotoClean()
	self:checkClean()
	local delayTime = self._cleanTimes*GameMapConfig.CLEAN_DELAY
	if delayTime > 0 then
		delayTime = delayTime+0.1
	end
	self:runAction(cca.seq({
		cca.delay(delayTime),
		cca.cb(function()
				self._fsmOP = true
				self._fsm:doEvent("clean")
			end),
	}))
end

function GameController:gotoUp(times)
	for i=1,times do
		self:runAction(cca.seq({
			cca.delay(0.2*(i-1)),
			cca.cb(function()
					local _isOver = false
					for _,v in ipairs(self._rocks) do
						local _newYid = v._yid+1
						if _newYid > GameMapConfig.ROCK_Y then
							_isOver = true
							break
						else
							v:updatePosA(v._xid, v._yid+1)
							v:updatePosB(1)
						end
					end
					if _isOver then
						-------------
						-- over 游戏结束
						-------------
					else
						local _sid = 1
						for _,v in ipairs(self._nextRocks) do
							if v.color > 0 then
								APP:createView("Game.GameRockNode", v.len, v.color, _sid, 1)
									:addTo(self, GameMapConfig._GameRockNode_Zorder)
							end
							_sid = _sid+v.len
						end

						self:autoCreateRocks(-1)

						if i == times then
							self:runAction(cca.seq({
								cca.delay(0.5),
								cca.cb(function()
										self._fsmOP = true
										self._fsm:doEvent("up")
									end),
							}))
						end
					end
				end),
			}))
	end

end



function GameController:checkDown(_moveList, _res)
	table.sort(self._rocks, function(a, b)
		return b._yid > a._yid
	end)
	local _moved = false
	for _,v in ipairs(self._rocks) do
		local _vo = {_times=0} 
		v:checkDown(_vo)
		if _vo._times > 0 then
			table.insert(_moveList, _vo._times)
			_moved = true
		end
	end

	if not _moved then
		_res._times = GameUtils.getMaxValue(_moveList)
		return 0
	else
		self:checkDown(_moveList, _res)
	end
end

function GameController:checkClean()
	for ylineN=1, GameMapConfig.ROCK_Y do
		local _compList = {}
		for _,v in ipairs(self._rocks) do
			if v._yid == ylineN then
				table.insert(_compList, v)
			end
		end

		table.sort(_compList, function(a, b)
			return b._xid > a._xid
		end)

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

		local _canClean = true
		for _,v in ipairs(_voo) do
			if v == 0 then
				_canClean = false
			end
		end

		-- clean
		if _canClean then
			local _getScore = 0
			for _,v in ipairs(_compList) do
				----------------
				--calc score
				----------------
				_getScore = _getScore + v._score
				v:showGetScore()
				v:clean(self._cleanTimes*GameMapConfig.CLEAN_DELAY)
			end
			self._cleanTimes = self._cleanTimes+1

			-- view score
			self._SCORE = self._SCORE+_getScore
			self._bgView:setScore(self._SCORE)
		end
	end
	return 
end














return GameController