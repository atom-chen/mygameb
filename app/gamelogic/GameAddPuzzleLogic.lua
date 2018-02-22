--
-- Author: gerry
-- Date: 2016-09-05 17:14:27
--
local utils = require("app.common.utils")
local GameUtils = require("app.core.GameUtils")
local GameMapConfig = require("app.core.Game.AddPuzzleGameConfig")

local GameAddPuzzleLogic = {}
GameAddPuzzleLogic.DIR = {GameMapConfig.DIR_TORIGHT,
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

function GameAddPuzzleLogic.getIdsList(xFW, yFW)
	local _out = {}
	for _xid = xFW[1], xFW[2] do
		for _yid = yFW[1], yFW[2] do
			local _id = (_yid-1)*GameMapConfig.ROCK_X+_xid
			table.insert(_out, _id)
		end
	end
	return _out
end


function GameAddPuzzleLogic.getRandNum()
	rand_seed()
	return math.random(1, 9)
end


------------------------------------------
-- 方式一
------------------------------------------
function GameAddPuzzleLogic.autoCreateTypeA(callback)
	rand_seed()
	-- x, y 左右流出距离
	local _cx, _cy = 1,1
	local _allICNum = 12 --math.random(3, 5)
	local _delIds = {{},{},{},{}}
	local _calcIds = {}
	local _colorId = 1
	
	for i=1,_allICNum do
		--先随方向
		local _randMDirKey = math.random(1, 4)
		local _mDir = GameAddPuzzleLogic.DIR[_randMDirKey]
		local _sPoints = {}
		if _mDir == GameMapConfig.DIR_TORIGHT then
			_sPoints = GameAddPuzzleLogic.getIdsList({1,1+_cx}, {1,GameMapConfig.ROCK_Y})
		elseif _mDir == GameMapConfig.DIR_TOLEFT then
			_sPoints = GameAddPuzzleLogic.getIdsList({GameMapConfig.ROCK_X-_cx,GameMapConfig.ROCK_X}, {1,GameMapConfig.ROCK_Y})
		elseif _mDir == GameMapConfig.DIR_TOUP then
			_sPoints = GameAddPuzzleLogic.getIdsList({1,GameMapConfig.ROCK_X}, {1,1+_cy})
		elseif _mDir == GameMapConfig.DIR_TODOWN then
			_sPoints = GameAddPuzzleLogic.getIdsList({1,GameMapConfig.ROCK_X}, {GameMapConfig.ROCK_Y-_cy,GameMapConfig.ROCK_Y})
		end
		
		for _,delId in ipairs(_delIds[_randMDirKey]) do
			utils.removeItem(_sPoints, delId, true)
		end
		if #_sPoints > 0 then
			local _randA = math.random(1, #_sPoints)
			local _startId = _sPoints[_randA]
			local _xid = _startId%GameMapConfig.ROCK_X
			if _xid == 0 then _xid = GameMapConfig.ROCK_X end
			local _yid = math.ceil(_startId/GameMapConfig.ROCK_X)
			local _lenMax = 0
			if _mDir == GameMapConfig.DIR_TORIGHT then
				_lenMax = GameMapConfig.ROCK_X - _xid
			elseif _mDir == GameMapConfig.DIR_TOLEFT then
				_lenMax = _xid-1
			elseif _mDir == GameMapConfig.DIR_TOUP then
				_lenMax = GameMapConfig.ROCK_Y - _yid
			elseif _mDir == GameMapConfig.DIR_TODOWN then
				_lenMax = _yid-1
			end
			

			-- 看主路径上是否有算点
			local _lenMaxB = _lenMax
			for _, ___id in ipairs(_calcIds) do
				local ___xid = ___id%GameMapConfig.ROCK_X
				if ___xid == 0 then ___id = GameMapConfig.ROCK_X end
				local ___yid = math.ceil(___id/GameMapConfig.ROCK_X)

				if _mDir == GameMapConfig.DIR_TORIGHT then
					if ___yid == _yid then
				 		if ___xid > _xid then
				 			_lenMaxB = GameMapConfig.ROCK_X - _xid - ((GameMapConfig.ROCK_X - ___xid)+1)
				 		end
				 	end
				elseif _mDir == GameMapConfig.DIR_TOLEFT then
					if ___yid == _yid then
						if ___xid < _xid then
							_lenMaxB = _xid -1 -___xid
						end
					end
				elseif _mDir == GameMapConfig.DIR_TOUP then
					if ___xid == _xid then
						if ___yid > _yid then
							_lenMaxB = GameMapConfig.ROCK_Y - _yid - ((GameMapConfig.ROCK_Y - ___yid)+1)
						end
					end
				elseif _mDir == GameMapConfig.DIR_TODOWN then
					if ___xid == _xid then
						if ___yid < _yid then
							_lenMaxB = _yid-1-___yid
						end
					end
				end
			 	
			end 
			
			local _lenMaxC = math.min(_lenMaxB, GameMapConfig.ROCK_LEN_MAX)
			
			assert(_lenMaxC >= GameMapConfig.ROCK_LEN_MIN)
			assert(_lenMaxC <= GameMapConfig.ROCK_LEN_MAX)

			local _randLen = math.random(GameMapConfig.ROCK_LEN_MIN, _lenMaxC)

			local _color = _colorId

			local _res = 
			{
				len = _randLen+1,
				color = _color,
				xid = _xid,
				yid = _yid,
				dir = _mDir,
			}
			-- print("======================_startId ", _startId)
			-- print("======================len ", _res.len)
			-- print("======================xid ", _res.xid)
			-- print("======================yid ", _res.yid)
			-- print("======================dir ", _res.dir)

			local _rock = callback("create", _res)
			_colorId = _colorId+1
			if _colorId >= 5 then
				_colorId = 1
			end
			--------------------
			-- _delIds 处理
			table.insert(_calcIds, _startId)
			for i=1,4 do
				table.insert(_delIds[i], _startId)
				for _, obj in ipairs(_rock._IDLIST) do
					table.insert(_delIds[i], obj.id)
				end
			end
			-----------------------


			local __xid = 0
			local __yid = 0
			for i=1, (GameMapConfig.ROCK_LEN_MIN+1) do
				__xid = _xid
				__yid = _yid+i
				if (__xid >= 1 and __xid <= GameMapConfig.ROCK_X)
				and (__yid >= 1 and __yid <= GameMapConfig.ROCK_Y) then
					local __id =(__yid-1)*GameMapConfig.ROCK_X+__xid
					table.insert(_delIds[4], __id)
				end
				__xid = _xid
				__yid = _yid-i
				if (__xid >= 1 and __xid <= GameMapConfig.ROCK_X)
				and (__yid >= 1 and __yid <= GameMapConfig.ROCK_Y) then
					local __id =(__yid-1)*GameMapConfig.ROCK_X+__xid
					table.insert(_delIds[3], __id)
				end
				__xid = _xid+i
				__yid = _yid
				if (__xid >= 1 and __xid <= GameMapConfig.ROCK_X)
				and (__yid >= 1 and __yid <= GameMapConfig.ROCK_Y) then
					local __id =(__yid-1)*GameMapConfig.ROCK_X+__xid
					table.insert(_delIds[2], __id)
				end
				__xid = _xid-i
				__yid = _yid
				if (__xid >= 1 and __xid <= GameMapConfig.ROCK_X)
				and (__yid >= 1 and __yid <= GameMapConfig.ROCK_Y) then
					local __id =(__yid-1)*GameMapConfig.ROCK_X+__xid
					table.insert(_delIds[1], __id)
				end
			end
		end

	end

	callback("over")

end






--
return GameAddPuzzleLogic


