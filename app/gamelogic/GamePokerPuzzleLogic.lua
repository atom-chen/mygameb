--
-- Author: gerry
-- Date: 2016-09-05 17:14:27
--
local utils = require("app.common.utils")
local GameUtils = require("app.core.GameUtils")
local GameMapConfig = require("app.core.Game.PokerPuzzleGameConfig")
local PokerLogic = require("app.gamelogic.PokerLogic")
local Poker = require("app.gamelogic.Poker")

local GamePokerPuzzleLogic = {}
GamePokerPuzzleLogic.DIR = {GameMapConfig.DIR_TORIGHT,
								GameMapConfig.DIR_TOLEFT,
								GameMapConfig.DIR_TOUP,
								GameMapConfig.DIR_TODOWN}

local function rand_seed()  
	local t = string.format("%f", socket.gettime())  
	local st = string.sub(t, string.find(t, "%.") + 1, -1)   
	local _seed = tonumber(string.reverse(st))
	math.randomseed(_seed)
	-- print("--t1>: ", t)
	-- print("--t2>: ", _seed)
	
	math.random(1,10000)
	math.random(1,10000)
	math.random(1,10000)
	math.random(1,10000)

	return 0
end  

function GamePokerPuzzleLogic.getIdsList(xFW, yFW)
	local _out = {}
	for _xid = xFW[1], xFW[2] do
		for _yid = yFW[1], yFW[2] do
			local _id = (_yid-1)*GameMapConfig.ROCK_X+_xid
			table.insert(_out, _id)
		end
	end
	return _out
end


function GamePokerPuzzleLogic.getRandNum()
	rand_seed()
	return math.random(1, 9)
end


------------------------------------------
-- 方式一
------------------------------------------
function GamePokerPuzzleLogic.autoCreateTypeA(callback)
	rand_seed()

	local _res = {}
	
	GamePokerPuzzleLogic.autoCreateTypeA_DG(_res, 8, {}, callback)	

end

function GamePokerPuzzleLogic.autoCreateTypeA_DG(res, times, compareRes, callback)
	rand_seed()
	-- temp used random
	local _pokerType = math.random(1, 8)

	local _len = PokerLogic.getPokerLen(_pokerType)
	local _dir = GamePokerPuzzleLogic.DIR[math.random(1,4)]

	-- base filt
	local _randX_min, _randX_max = 1, GameMapConfig.ROCK_X
	local _randY_min, _randY_max = 1, GameMapConfig.ROCK_Y
	if _dir == GameMapConfig.DIR_TORIGHT then
		_randX_max = GameMapConfig.ROCK_X-_len+1
	elseif _dir == GameMapConfig.DIR_TOLEFT then
		_randX_min = _len
	elseif _dir == GameMapConfig.DIR_TOUP then
		_randY_max = GameMapConfig.ROCK_Y-_len+1
	elseif _dir == GameMapConfig.DIR_TODOWN then
		_randY_min = _len
	end
	local _xid = math.random(_randX_min, _randX_max)
	local _yid = math.random(_randY_min, _randY_max)
	local _color = math.random(GameMapConfig.ROCK_COLOR_MIN, GameMapConfig.ROCK_COLOR_MAX)

	local _resObj = {xid=_xid,yid=_yid,len=_len,color=_color,dir=_dir}

	--
	for i,v in ipairs(compareRes) do
		if v.xid == _resObj.xid and v.yid == _resObj.yid and v.dir == _resObj.dir then
			GamePokerPuzzleLogic.autoCreateTypeA_DG(res, times, compareRes, callback)
			return
		end 

		if (v.dir == GameMapConfig.DIR_TORIGHT or v.dir == GameMapConfig.DIR_TOLEFT) 
		and (_resObj.dir == GameMapConfig.DIR_TORIGHT or _resObj.dir == GameMapConfig.DIR_TOLEFT) then
			if (_resObj.xid+_resObj.len-1) == v.xid or (_resObj.xid-_resObj.len+1) == v.xid
			or (v.xid+v.len-1) == _resObj.xid or (v.xid-v.len+1) == _resObj.xid then
				GamePokerPuzzleLogic.autoCreateTypeA_DG(res, times, compareRes, callback)
				return
			end
			-- 在一条直线上
			if v.yid == _resObj.yid then
				GamePokerPuzzleLogic.autoCreateTypeA_DG(res, times, compareRes, callback)
				return
			end
		elseif (v.dir == GameMapConfig.DIR_TOUP or v.dir == GameMapConfig.DIR_TODOWN) 
		and (_resObj.dir == GameMapConfig.DIR_TOUP or _resObj.dir == GameMapConfig.DIR_TODOWN) then
			if (_resObj.yid+_resObj.len-1) == v.yid or (_resObj.yid-_resObj.len+1) == v.yid
			or (v.yid+v.len-1) == _resObj.yid or (v.yid-v.len+1) == _resObj.yid then
				GamePokerPuzzleLogic.autoCreateTypeA_DG(res, times, compareRes, callback)
				return
			end
			-- 在一条直线上
			if v.xid == _resObj.xid then
				GamePokerPuzzleLogic.autoCreateTypeA_DG(res, times, compareRes, callback)
				return
			end 
		end


	end


	table.insert(compareRes, _resObj)
	table.insert(res, _resObj)

	times = times-1
	if times == 0 then
		callback(res)
		return 
	else
		GamePokerPuzzleLogic.autoCreateTypeA_DG(res, times, compareRes, callback)
	end
end



-----------------------
-----------------------

function GamePokerPuzzleLogic.autoCreatePoker(rockList, callback)
	rand_seed()
	local _hadPokerList = {}
	local _onePoker = PokerLogic.crateOnePoker()
	------------------------
	-- step1
	------------------------
	GamePokerPuzzleLogic.autoCreatePokerStepA(rockList, _hadPokerList, _onePoker)


	------------------------
	-- step2
	------------------------
	-- local _poker2, _poker3, _poker4, _poker5 = {}, {}, {}, {}
	

	-- for i,rock in ipairs(rockList) do
	-- 	if rock._len == 2 then
	-- 		table.insert(_poker2, rock)
	-- 	elseif rock._len == 3 then
	-- 		table.insert(_poker3, rock)
	-- 	elseif rock._len == 4 then
	-- 		table.insert(_poker4, rock)
	-- 	elseif rock._len == 5 then
	-- 		table.insert(_poker5, rock)
	-- 	end
	-- end

	-- for i,rock in ipairs(_poker2) do
	-- 	GamePokerPuzzleLogic.autoCreatePokerStepB_DG(rock, _hadPokerList, _onePoker)
	-- end
	-- for i,rock in ipairs(_poker3) do
	-- 	GamePokerPuzzleLogic.autoCreatePokerStepB_DG(rock, _hadPokerList, _onePoker)
	-- end
	-- for i,rock in ipairs(_poker4) do
	-- 	GamePokerPuzzleLogic.autoCreatePokerStepB_DG(rock, _hadPokerList, _onePoker)
	-- end
	-- for i,rock in ipairs(_poker5) do
	-- 	GamePokerPuzzleLogic.autoCreatePokerStepB_DG(rock, _hadPokerList, _onePoker)
	-- end


	callback(_hadPokerList)
end


function GamePokerPuzzleLogic.autoCreatePokerStepA(rockList, hadPokerList, onePoker)
	local _idsList = {}
	for _, rock in ipairs(rockList) do
		local _dir = rock._dir
		local _pList = {}
		if _dir == GameMapConfig.DIR_TORIGHT then
			for i=1,rock._len do
				local _id = rock._id+i-1
				table.insert(_pList, {id=_id,rp=false})
			end
		elseif _dir == GameMapConfig.DIR_TOLEFT then
			for i=1,rock._len do
				local _id = rock._id-i+1
				table.insert(_pList, {id=_id,rp=false})
			end
		elseif _dir == GameMapConfig.DIR_TOUP then
			for i=1,rock._len do
				local _id = rock._id+GameMapConfig.ROCK_X*(i-1)
				table.insert(_pList, {id=_id,rp=false})
			end
		elseif _dir == GameMapConfig.DIR_TODOWN then
			for i=1,rock._len do
				local _id = rock._id-GameMapConfig.ROCK_X*(i-1)
				table.insert(_pList, {id=_id,rp=false})
			end
		end 
		table.insert(_idsList, _pList)
	end

	----计算重复point
	local _tempListA, _tempListB, _tempListC = {}, {}, {}
	for _, _rockIds in ipairs(_idsList) do
		for _, _idObj in ipairs(_rockIds) do
			table.insert(_tempListA, _idObj.id)
		end
	end
	for i = 1, GameMapConfig.ROCK_X*GameMapConfig.ROCK_Y do
		_tempListB[i] = 0
	end
	for _, _id in ipairs(_tempListA) do
		_tempListB[_id] = _tempListB[_id]+1
	end
	for _id, _value in ipairs(_tempListB) do
		if _value > 1 then
			table.insert(_tempListC, _id)
		end
	end

	for _, _rockIds in ipairs(_idsList) do
		local _debuga = ""
		local _rpNum, _allNum = 0, #_rockIds
		local _rpIds, _allIds, _ysPokers, _res = {}, {}, {}, {}
		local _posId = 1
		for _, _idObj in ipairs(_rockIds) do
			for _, _tempid in ipairs(_tempListC) do
				if _idObj.id == _tempid then _idObj.rp = true end
			end
			if _idObj.rp then
				_debuga = _debuga.."*"..tostring(_idObj.id)..","
				_rpNum = _rpNum+1
				table.insert(_rpIds, _idObj.id)
			else
				_debuga = _debuga..tostring(_idObj.id)..","
			end

			for _, _pokerObj in ipairs(hadPokerList) do
				if _idObj.id == _pokerObj.id then
					table.insert(_ysPokers, {pos=_posId, poker=_pokerObj.poker})
				end
			end
			table.insert(_allIds, _idObj.id)
			_posId = _posId+1
		end
		print("-allNUM, rpNUM: >", _allNum, _rpNum)
		print("------ids: >", _debuga)

		local _useAllIds, _useRpIds = false, false
		if _rpNum == 5 then
			local _gl = math.random(1, 200)
			if _gl <= 250 then
				-- 5顺
				-- _res = PokerLogic.getFiveCardStraight(_ysPokers, onePoker)
				_res = PokerLogic.getFullHouse(_ysPokers, onePoker)
			elseif _gl <= 500 then
				-- 同花
				_res = PokerLogic.getFlush(_ysPokers, onePoker)
			elseif _gl <= 750 then
				-- fullhouse
				_res = PokerLogic.getFullHouse(_ysPokers, onePoker)
			else
				-- 同花顺
				_res = PokerLogic.getStraightFlush(_ysPokers, onePoker)
			end
			_useRpIds = true
		elseif _rpNum == 4 then
			if _allNum == 4 then
				_res = PokerLogic.getFourOfAKing(_ysPokers, onePoker)
				_useRpIds = true
			else

			end
		elseif _rpNum == 3 then
			if #_ysPokers <= 1 then
				local _gl = math.random(1, 500)
				if _allNum == 3 then
					if _gl <= 500 then
						-- 三顺
						_res = PokerLogic.getThreeCardStraight(_ysPokers, onePoker)
					else
						-- 三条
						_res = PokerLogic.getThreeOfAKing(_ysPokers, onePoker)
					end
					_useRpIds = true
				elseif _allNum == 4 then
					_res = PokerLogic.getFourOfAKing(_ysPokers, onePoker)
					_useAllIds = true
				elseif _allNum == 5 then
					if _gl <= 500 then
						-- 5顺
						_res = PokerLogic.getFiveCardStraight(_ysPokers, onePoker)
					else
						-- 三条
						_res = PokerLogic.getFullHouse(_ysPokers, onePoker)
					end
					_useAllIds = true
				end
				
			end
		end
		
		if _useRpIds then
			for i, _poker in ipairs(_res) do
				table.insert(hadPokerList, {id=_rpIds[i], poker=_poker})
			end
		elseif _useAllIds then
			for i, _poker in ipairs(_res) do
				table.insert(hadPokerList, {id=_allIds[i], poker=_poker})
			end
		end

	end




end


function GamePokerPuzzleLogic.autoCreatePokerStepA_DG(rock, hadPokerList, onePoker)
	

end



function GamePokerPuzzleLogic.autoCreatePokerStepB_DG(rock, hadPokerList, onePoker)
	local _dir = rock._dir
	local _pList = {}
	if _dir == GameMapConfig.DIR_TORIGHT then
		for i=1,rock._len do
			local _id = rock._id+i-1
			table.insert(_pList, {id=_id,poker=nil,isHad=false})
		end
	elseif _dir == GameMapConfig.DIR_TOLEFT then
		for i=1,rock._len do
			local _id = rock._id-i+1
			table.insert(_pList, {id=_id,poker=nil,isHad=false})
		end
	elseif _dir == GameMapConfig.DIR_TOUP then
		for i=1,rock._len do
			local _id = rock._id+GameMapConfig.ROCK_X*(i-1)
			table.insert(_pList, {id=_id,poker=nil,isHad=false})
		end
	elseif _dir == GameMapConfig.DIR_TODOWN then
		for i=1,rock._len do
			local _id = rock._id-GameMapConfig.ROCK_X*(i-1)
			table.insert(_pList, {id=_id,poker=nil,isHad=false})
		end
	end 

	for _, _pObj in ipairs(_pList) do
		for _, _pokerObj in ipairs(hadPokerList) do
			if _pObj.id == _pokerObj.id then
				_pObj.poker = _pokerObj.poker
				_pObj.isHad = true
			end
		end
	end

	local _ysPokers, _res = {}, {}
	local _posId = 1
	for _, _pObj in ipairs(_pList) do
		if _pObj.isHad then
			table.insert(_ysPokers, {pos=_posId, poker=_pObj.poker})
		end
		_posId = _posId+1
	end

	-- 2张
	if rock._len == 2 then
		-- 一对
		_res = PokerLogic.getOnePair(_ysPokers, onePoker)
	-- 3张	
	elseif rock._len == 3 then
		local _goOn = true
		if #_ysPokers == 2 then
			if _ysPokers[1].value == _ysPokers[2].value then
				-- 三条
				_res = PokerLogic.getThreeOfAKing(_ysPokers, onePoker)
				_goOn = false
			end
		end
		if _goOn then
			local _gl = math.random(1, 1000)
			if _gl <= 500 then
				-- 三顺
				_res = PokerLogic.getThreeCardStraight(_ysPokers, onePoker)
			else
				-- 三条
				_res = PokerLogic.getThreeOfAKing(_ysPokers, onePoker)
			end
		end
	--4张
	elseif rock._len == 4 then
		-- 4张
		_res = PokerLogic.getFourOfAKing(_ysPokers, onePoker)
	--5张
	elseif rock._len == 5 then

	else

	end
	local index = 1
	for _, _pObj in ipairs(_pList) do
		if not _pObj.isHad then
			if #_res > 0 then
				_pObj.poker = _res[index]
				print("---- > ", _pObj.poker:tostring())
				index = index+1
				table.insert(hadPokerList, {id=_pObj.id,poker=_pObj.poker})
			end
		end
	end
end









--
return GamePokerPuzzleLogic


