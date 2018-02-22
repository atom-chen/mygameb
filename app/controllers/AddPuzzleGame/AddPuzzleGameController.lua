--
-- Author: gerry
-- Date: 2015-11-26 15:08:53
--
local GameUtils = require("app.core.GameUtils")
local GameConfig = require("app.core.GameConfig")
local ControllerBase = require("app.controllers.ControllerBase")
local scheduler = require("framework.scheduler")
local AddPuzzleGameController = class("AddPuzzleGameController", ControllerBase)
local GlobalStatus = APP:getObject("GlobalStatus")
local utils = require("app.common.utils")
local GameMapConfig = require("app.core.Game.AddPuzzleGameConfig")
local GameAddPuzzleLogic = require("app.gamelogic.GameAddPuzzleLogic")

function AddPuzzleGameController:ctor()
	-- print("os time 1: ", os.time())
	-- print("os time 2: ", tostring(os.time()):reverse():sub(1, 6))
	-- print("socket time 1: ", socket.gettime())
	-- print("socket time 2: ", tostring(socket.gettime()):reverse():sub(1, 6))
    AddPuzzleGameController.super.ctor(self)
    self._SCORE = 0
    self._MAP_XY = {}
    self._MAP_MIN_X = 0
    self._MAP_MIN_Y = 0
    self._MAP_MAX_X = 0
    self._MAP_MAX_Y = 0
    self._MAP_CELL_X = {}

    self._NUM_VO_LIST = {}
    self._ROCK_LIST = {}
    self._NUM_OBJ_LIST = {}

    self._touchStep = 1
    self._changeA = nil
    self._changeB = nil
    
    self._mapView = APP:createView("AddPuzzleGame.GameMapNode")
        :addTo(self, GameMapConfig._GameMapNode_Zorder)

    self._uiView = APP:createView("AddPuzzleGame.GameUINode")
    	:addTo(self, GameMapConfig._GameUINode_Zorder)

    self._rockLayer = display.newNode()
    	:addTo(self, GameMapConfig._GameRockNode_Zorder)
    self._numLayer = display.newNode()
    	:addTo(self, GameMapConfig._GameNumNode_Zorder)
    
    self:startGame()
    -- test

	
end

function AddPuzzleGameController:onEnter()
	AddPuzzleGameController.super.onEnter(self)
    self._handelA = scheduler.scheduleGlobal(handler(self, self.onCollisionA), 0)
    -- self._handelB = scheduler.scheduleGlobal(handler(self, self.onCollisionB), 0)
end

function AddPuzzleGameController:onExit()
    AddPuzzleGameController.super.onExit(self)
    scheduler.unscheduleGlobal(self._handelA)
end




-------------------------------
-------- onCollision ----------
-------------------------------
function AddPuzzleGameController:onCollisionA(dt)
	
end

function AddPuzzleGameController:onCollisionB(dt)
	-- self._bgView:onCollision(dt)
end
-------------------------------
-------- onCollision end ------
-------------------------------

function AddPuzzleGameController:startGame()
	self:gameCreateMap()
end

function AddPuzzleGameController:restartGame()
	for _, _Rock in ipairs(self._ROCK_LIST) do
		_Rock:removeSelf()
	end
	for _, _NumObj in ipairs(self._NUM_OBJ_LIST) do
		_NumObj:removeSelf()
	end
	self._NUM_VO_LIST = {}
    self._ROCK_LIST = {}
    self._NUM_OBJ_LIST = {}


	self:gameCreateMap()
end


function AddPuzzleGameController:gameCreateMap()
	-- APP:createView("AddPuzzleGame.GameRockNode", 4, 1, 1, 6, GameMapConfig.DIR_TORIGHT)
	-- 	:addTo(self, GameMapConfig._GameRockNode_Zorder)
	-- APP:createView("AddPuzzleGame.GameRockNode", 4, 2, 5, 1, GameMapConfig.DIR_TOLEFT)
	-- 	:addTo(self, GameMapConfig._GameRockNode_Zorder)
	-- APP:createView("AddPuzzleGame.GameRockNode", 4, 3, 1, 1, GameMapConfig.DIR_TOUP)
	-- 	:addTo(self, GameMapConfig._GameRockNode_Zorder)
	-- APP:createView("AddPuzzleGame.GameRockNode", 4, 4, 5, 6, GameMapConfig.DIR_TODOWN)
	-- 	:addTo(self, GameMapConfig._GameRockNode_Zorder)
	local _index = 1
	GameAddPuzzleLogic.autoCreateTypeA(function(type, res)
			if type == "create" then
				local _Rock = APP:createView("AddPuzzleGame.GameRockNode", res.len, res.color, res.xid, res.yid, res.dir)
					:addTo(self._rockLayer, _index)
				for _, _obj in ipairs(_Rock._IDLIST) do
					table.insert(self._NUM_VO_LIST, _obj)
				end
				table.insert(self._ROCK_LIST, _Rock)
				_index = _index+1
				return _Rock
			elseif type == "over" then
				self:autoMakeNum()
			end
		end)
end


function AddPuzzleGameController:autoMakeNum()
	local _voList = {}

	for _, _obj in ipairs(self._NUM_VO_LIST) do
		local _canGoOn = true
		for _, vo in ipairs(_voList) do
			if vo == _obj.id then
				print("repeat id: ", _obj.id)
				_canGoOn = false
			end
		end
		if _canGoOn then
			local _r = GameAddPuzzleLogic.getRandNum()
			local params = {id=_obj.id, num=_r}
			local _NumObj = APP:createView("AddPuzzleGame.GameNumNode", params)
				:addTo(self._numLayer, 1)
			table.insert(_voList, _obj.id)
			table.insert(self._NUM_OBJ_LIST, _NumObj)
			-- 第一次set
			self:setRockNum(params)
		end
	end
	-- 计算结果值
	for _, _Rock in ipairs(self._ROCK_LIST) do
		_Rock:makeNumEnd()
	end
	-- 打乱
	-- 
	local _tempIdList = {}
	for _, _NumObj in ipairs(self._NUM_OBJ_LIST) do
		table.insert(_tempIdList, _NumObj._id)
	end
	local _tempIdListB = utils.shuffle(_tempIdList)
	
	for i, _NumObj in ipairs(self._NUM_OBJ_LIST) do
		_NumObj:changeId(_tempIdListB[i],false)
		-- 第二次set
		local params = {id=_NumObj._id, num=_NumObj._num}
		self:setRockNum(params)
	end
	self:checkEnd()
end


function AddPuzzleGameController:setRockNum(params)
	for _, _Rock in ipairs(self._ROCK_LIST) do
		for _, _obj in ipairs(_Rock._IDLIST) do
			if params.id == _obj.id then 
				_Rock:setNum(params.id, params.num)
			end
		end
	end
end


function AddPuzzleGameController:touchNum(mapid)
	if self._touchStep == 1 then
		self._touchStep = 2

		for _, _NumObj in ipairs(self._NUM_OBJ_LIST) do
			if mapid == _NumObj._id then
				self._changeA = _NumObj
				self._changeA:beChooseed()
			end
		end

	elseif self._touchStep == 2 then
		self._touchStep = 1

		for _, _NumObj in ipairs(self._NUM_OBJ_LIST) do
			if mapid == _NumObj._id then
				self._changeB = _NumObj
			end
		end
		local _aid = self._changeA._id
		local _bid = self._changeB._id
		self._changeA:changeId(_bid, true)
		self._changeB:changeId(_aid, true)

		self._changeA:unChooseed()

		local paramsA = {id=self._changeA._id, num=self._changeA._num}
		local paramsB = {id=self._changeB._id, num=self._changeB._num}
		self:setRockNum(paramsA)
		self:setRockNum(paramsB)

		self:checkEnd()
	end
end

function AddPuzzleGameController:checkEnd()
	for _, _Rock in ipairs(self._ROCK_LIST) do
		_Rock:checkEnd()
	end
end





return AddPuzzleGameController