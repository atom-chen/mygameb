--
-- Author: gerry
-- Date: 2016-09-05 17:14:27
--
local utils = require("app.common.utils")
local GameUtils = require("app.core.GameUtils")
local GameMapConfig = require("app.core.GameMapConfig")

local GameRocksLogic = {}


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

function GameRocksLogic.test()
	rand_seed()
end


------------------------------------------
-- 方式一
------------------------------------------
function GameRocksLogic.autoCreateRocksTypeA(res, callback)
	rand_seed()
	local _usedLen = 0
	for _,v in ipairs(res) do
		_usedLen = _usedLen+v.len
	end

	local _emptyLen = GameMapConfig.ROCK_X - _usedLen

	local _rockLen = 0
	local _rockColor = 0

	if _emptyLen == 0 then
		if callback then
			callback(res)
		end
		return 0
	elseif _emptyLen <= GameMapConfig.ROCK_LEN_MAX  then
		_rockLen = _emptyLen
		_rockColor = math.random(GameMapConfig.ROCK_COLOR_MIN,GameMapConfig.ROCK_COLOR_MAX)
	else
		_rockLen = math.random(GameMapConfig.ROCK_LEN_MIN, GameMapConfig.ROCK_LEN_MAX)
		_rockColor = math.random(GameMapConfig.ROCK_COLOR_MIN,GameMapConfig.ROCK_COLOR_MAX)
		
	end

	if _rockLen > 0 and _rockColor > 0 then
		-- 空 满 平衡
		local _noN, _yesN = 0, 0

		for _,v in ipairs(res) do
			if v.color > 0 then
				_yesN = _yesN+1
			elseif v.color == 0 then
				_noN = _noN+1
			end
		end

		local _normalXS = 8000
		if (_noN == 0 and _usedLen >= 5) then
			_normalXS = 0
		end
		
		if (_noN == 0 and _emptyLen <= GameMapConfig.ROCK_LEN_MAX) then
			_normalXS = 0
		end

		if (_yesN == 0 and _usedLen <= 3) then
			_normalXS = 10000
		end

		if (_yesN == 0 and _emptyLen <= GameMapConfig.ROCK_LEN_MAX) then
			_normalXS = 10000
		end

		local _needRock = false
		local _needRockRadom = math.random(1, 10000)
		if _needRockRadom <= _normalXS then
			_needRock = true
		else
			_needRock = false
		end

		if _needRock then
			table.insert(res, {len=_rockLen, color=_rockColor})
		else
			table.insert(res, {len=_rockLen, color=0})
		end


		GameRocksLogic.autoCreateRocksTypeA(res, callback)
	end
end



------------------------------------------
-- 方式二
------------------------------------------
function GameRocksLogic.autoCreateRocksTypeB(res, callback)
	rand_seed()
	-- rand empty
	
	local __TypeList = 
	{
		"0000000_",
		"000000_0",
		"00000_00",
		"0000_000",
		"000_0000",
		"00_00000",
		"0_000000",
		"_0000000",

		"000000__",
		"00000__0",
		"0000__00",
		"000__000",
		"00__0000",
		"0__00000",
		"__000000",

		"0_00000_",
		"0_0000_0",
		"0_000_00",
		"0_00_000",
		"0_0_0000",
		"0_0_00_0",
		"00_000_0",
		"0_0000_0",
		"_00000_0",

		"00_0000_",
		"00_000_0",
		"00_00_00",
		"00_0_000",
		"000_0_00",
		"00_00_00",
		"0_000_00",
		"_0000_00",

		"000_000_",
		"000_00_0",
		"000_0_00",
		"00_0_000",
		"0_00_000",
		"_000_000",
	}

	local _randA = math.random(1, #__TypeList)
	local _styleType = __TypeList[_randA]


	local _v1, _v2 = {}, {}
	local _voTime, _startXId = 0, 0
	for xId=1, #_styleType do
		local _v0 = string.sub(_styleType, xId, xId)
		table.insert(_v2, _v0)
		local _ag = false
		if _v0 == "_" then
			_ag = true
		else
			_voTime = _voTime + 1
			if xId == #_styleType then
				_ag = true
			end
		end
		
		if _ag then
			if _voTime > 0 then
				_startXId = xId-_voTime
				table.insert(_v1, {startXId=_startXId, allLen=_voTime})
			end
			_voTime = 0
		end

	end

	local _rockListTamp = {}
	for xId, obj in ipairs(_v1) do
		local __res = {}
		GameRocksLogic.autoCreateRocksTypeB_makeLittleRocks(__res, obj.allLen)
		-- print(">>777>> : ", obj.allLen)
		-- dump(__res)
		table.insert(_rockListTamp, __res)
	end


	local _reckList, _tempNum, _tempCanPullList = {}, 1, true
	for xId,v in ipairs(_v2) do
		if v == "_" then
			table.insert(_reckList, {len=1, color=0})
			_tempCanPullList = true
		else
			if _tempCanPullList then
				local _voList = _rockListTamp[_tempNum]
				for _,v in ipairs(_voList) do
					table.insert(_reckList, v)
				end
				_tempCanPullList = false
				_tempNum = _tempNum + 1
			end
		end
	end
	-- 照方式一的样子背书res
	for _,v in ipairs(_reckList) do
		table.insert(res, v)
	end
	if callback then
		callback(res)
	end
	return 0
end


function GameRocksLogic.autoCreateRocksTypeB_makeLittleRocks(res, allLen)
	rand_seed()
	local _usedLen = 0
	for _,v in ipairs(res) do
		_usedLen = _usedLen+v.len
	end

	local _emptyLen = allLen - _usedLen

	local _rockLen = 0
	local _rockColor = 0

	if _emptyLen == 0 then
		
		return 0
	else
		_rockLen = math.random(GameMapConfig.ROCK_LEN_MIN, GameMapConfig.ROCK_LEN_MAX)
		if _rockLen > _emptyLen then
			_rockLen = _emptyLen
		end
		_rockColor = math.random(GameMapConfig.ROCK_COLOR_MIN,GameMapConfig.ROCK_COLOR_MAX)
	end

	if _rockLen > 0 and _rockColor > 0 then
		table.insert(res, {len=_rockLen, color=_rockColor})
		GameRocksLogic.autoCreateRocksTypeB_makeLittleRocks(res, allLen)
	end
end



--
return GameRocksLogic


