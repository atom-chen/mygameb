--
-- Author: gerry
-- Date: 2016-09-05 17:14:27
--
local utils = require("app.common.utils")
local GameUtils = require("app.core.GameUtils")
local Poker = require("app.gamelogic.Poker")



local PokerLogic = {}

PokerLogic._TYPE_ONE_PAIR = 1
PokerLogic._TYPE_THREE_CARD_STRAIGHT = 2
PokerLogic._TYPE_THREE_OF_A_KING = 3
PokerLogic._TYPE_FIVE_CARD_STRAIGHT = 4
PokerLogic._TYPE_FULL_HOUSE = 5
PokerLogic._TYPE_FLUSH = 6
PokerLogic._TYPE_FOUR_OF_A_KING = 7
PokerLogic._TYPE_STRAIGHT_FLUSH = 8


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


function PokerLogic.getPokerLen(pokerType)
	if pokerType == PokerLogic._TYPE_ONE_PAIR then return 2
	elseif pokerType == PokerLogic._TYPE_THREE_CARD_STRAIGHT then return 3
	elseif pokerType == PokerLogic._TYPE_THREE_OF_A_KING then return 3
	elseif pokerType == PokerLogic._TYPE_FIVE_CARD_STRAIGHT then return 5
	elseif pokerType == PokerLogic._TYPE_FULL_HOUSE then return 5
	elseif pokerType == PokerLogic._TYPE_FLUSH then return 5
	elseif pokerType == PokerLogic._TYPE_FOUR_OF_A_KING then return 4
	elseif pokerType == PokerLogic._TYPE_STRAIGHT_FLUSH then return 5
	end
end


function PokerLogic.sortByPoint(pokerList)
	table.sort(pokerList, function(a, b)
			if b.value == a.value then
				return b.suit < a.suit
			else
				return b.value > a.value
			end
		end)
	return pokerList
end

-- 一对
function PokerLogic.isOnePair(pokerList)
	if #pokerList == 2 then
		local tilesInner = {}
	    for i = 1, 14 do
	        tilesInner[i] = 0
	    end
	    for i,poker in ipairs(pokerList) do
	        tilesInner[poker.value] = tilesInner[poker.value]+1
	    end

	    for pokerValue, num in ipairs(tilesInner) do
	        if num == 2 then
	            return true
	        end
	    end
	end
    return false
end

-- 3顺
function PokerLogic.isThreeCardStraight(pokerList)
	if #pokerList == 3 then
		local tilesInner = {}
	    for i = 1, 14 do
	        tilesInner[i] = 0
	    end
	    for i,poker in ipairs(pokerList) do
	        tilesInner[poker.value] = tilesInner[poker.value]+1
	    end
	    tilesInner[1] = tilesInner[14]
	    for index,v in ipairs(tilesInner) do
	        if index <= 12 then
	            local _vA = tilesInner[index]
	            local _vB = tilesInner[index+1]
	            local _vC = tilesInner[index+2]

	            if _vA == 1 and _vB == 1 and _vC == 1 then
	            	return true
	            end
	        end
	    end
	end
	return false
end

-- 3条
function PokerLogic.isThreeOfAKing(pokerList)
	if #pokerList == 3 then
		local tilesInner = {}
	    for i = 1, 14 do
	        tilesInner[i] = 0
	    end
	    for i,poker in ipairs(pokerList) do
	        tilesInner[poker.value] = tilesInner[poker.value]+1
	    end

	    for pokerValue, num in ipairs(tilesInner) do
	        if num == 3 then
	            return true
	        end
	    end
	end
    return false
end

-- 5顺
function PokerLogic.isFiveCardStraight(pokerList)
	if #pokerList == 5 then
		local tilesInner = {}
	    for i = 1, 14 do
	        tilesInner[i] = 0
	    end
	    for i,poker in ipairs(pokerList) do
	        tilesInner[poker.value] = tilesInner[poker.value]+1
	    end
	    tilesInner[1] = tilesInner[14]
	    for index,v in ipairs(tilesInner) do
	        if index <= 10 then
	            local _vA = tilesInner[index]
	            local _vB = tilesInner[index+1]
	            local _vC = tilesInner[index+2]
	            local _vD = tilesInner[index+3]
	            local _vE = tilesInner[index+4]

	            if _vA == 1 and 
	               _vB == 1 and 
	               _vC == 1 and
	               _vD == 1 and
	               _vE == 1 then
	            	return true
	            end
	        end
	    end
	end
	return false
end

-- fullhouse
function PokerLogic.isFullHouse(pokerList)
	if #pokerList == 5 then
		local tilesInner = {}
	    for i = 1, 14 do
	        tilesInner[i] = 0
	    end
	    for i,poker in ipairs(pokerList) do
	        tilesInner[poker.value] = tilesInner[poker.value]+1
	    end
	    local _3t, _2t = false, false
	    for pokerValue, num in ipairs(tilesInner) do
	        if num == 3 then
	            _3t = true
	        elseif num == 2 then
	        	_2t = true
	        end
	    end
	    if _3t and _2t then
	    	return true
	    end
	end
	return false
end

-- 同花
function PokerLogic.isFlush(pokerList)
	if #pokerList == 5 then
		local _sSuit = 0
		local _isFlush = true
		for i,poker in ipairs(pokerList) do
			local _pokerSuit = poker.suit
			if i == 1 then
				_sSuit = _pokerSuit
			else
				if _pokerSuit ~= _sSuit then
					_isFlush = false
				end
			end
		end
		if _isFlush then
			return true
		end
	end
	return false
end

-- 4条
function PokerLogic.isFourOFAKing(pokerList)
	if #pokerList == 4 then
		local tilesInner = {}
	    for i = 1, 14 do
	        tilesInner[i] = 0
	    end
	    for i,poker in ipairs(pokerList) do
	        tilesInner[poker.value] = tilesInner[poker.value]+1
	    end

	    for pokerValue, num in ipairs(tilesInner) do
	        if num == 4 then
	            return true
	        end
	    end
	end
    return false
end

-- 同花顺
function PokerLogic.isStraightFlush(pokerList)
	local _isFlush = PokerLogic.isFlush(pokerList)
	local _isFiveCardStraight = PokerLogic.isFiveCardStraight(pokerList)
	if _isFlush and _isFiveCardStraight then
		return true
	end
	return false
end

function PokerLogic.crateOnePoker()
	local _out = {}
	for _suit=1,4 do
		for _value=2,14 do
			local _poker = Poker.new(_suit, _value)
			table.insert(_out, _poker)
		end
	end
	return _out
end

------------------
function PokerLogic.getRandomPokersByOneValue(num, ysPokers, onePoker)
	rand_seed()
	local value = 0
	if #ysPokers > 0 then
		value = ysPokers[1].poker.value
		for _,v in ipairs(ysPokers) do
			assert(value == v.poker.value)
		end
	end

	local _out = {}
	local _tempA, _tempB = {}, {}
	if value == 0 then
		local tilesInner = {}
	    for i = 1, 14 do
	        tilesInner[i] = 0
	    end
		for _,poker in ipairs(onePoker) do
			tilesInner[poker.value] = tilesInner[poker.value]+1
		end
		for value, v in ipairs(tilesInner) do
			if v >= num then
				table.insert(_tempB, value)
			end
		end
		local _voa = math.random(1, #_tempB)
		value = _tempB[_voa]
	end

	for _,poker in ipairs(onePoker) do
		if poker.value == value then
			table.insert(_tempA, poker)
		end
	end

	for i=1,num-#ysPokers do
		local _r = math.random(1, #_tempA)
		local _poker = _tempA[_r]
		table.insert(_out, _poker)
		utils.removeItem(_tempA, _poker, false)
		utils.removeItem(onePoker, _poker, false)
	end
	return _out
end

function PokerLogic.getRandomPokersByStraight(num, ysPokers, onePoker, isFlush)
	rand_seed()
	local _out = {}
	local _tempA, _tempB = {}, {}
	local tilesInner = {}
    for i = 1, 14 do
        tilesInner[i] = 0
    end
	for _,poker in ipairs(onePoker) do
		tilesInner[poker.value] = tilesInner[poker.value]+1
	end
	tilesInner[1] = tilesInner[14]

	if #ysPokers == 0 then	
		print("------------------------- 1")
	    for index,v in ipairs(tilesInner) do
	        if index <= 14-num+1 then
				local _can = true
				for i=1,num do
					local _vo = tilesInner[index+i-1]
					if _vo == 0 then
						_can = false
					end
				end
				if _can then
					table.insert(_tempA, index)
				end
			end
		end

		
	else
		print("------------------------- 2")
		for index,v in ipairs(tilesInner) do
			if index <= 14-num+1 then
				local _can, _cannum = true, 0
				for i=1,num do
					local _voIndex = index+i-1
					for _, _voObj in ipairs(ysPokers) do
						if _voIndex == _voObj.poker.value 
						and i == _voObj.pos then
							_cannum = _cannum+1
							break
						end
					end
					local _vo = tilesInner[_voIndex]
					if _vo == 0 then
						_can = false
					end
				end
				
				if _can and _cannum == #ysPokers then
					print("_cannum, #ysPokers", _cannum, #ysPokers)
					for i,v in ipairs(ysPokers) do
						print(v.poker.value)
					end
					print(">>> ", index)
					table.insert(_tempA, index)
				end
			end
		end
	end
	print("#_tempA:", #_tempA)
	local _r = math.random(1, #_tempA)
	local _pokerIndex = _tempA[_r]
	for i=1,num do
		local _tempD = {}
		for _,poker in ipairs(onePoker) do
			if poker.value == _pokerIndex+i-1 then
				-- print("--∂∂> ", poker.value)
				table.insert(_tempD, poker)
			end
		end
		local _r = math.random(1, #_tempD)
		local _poker = _tempD[_r]
		table.insert(_out, _poker)
		utils.removeItem(onePoker, _poker, false)
	end



	return _out
end


function PokerLogic.getRandomPokersByFullHouse(ysPokers, onePoker)
	rand_seed()
	local _out = {}
	local _tempA, _tempB = {}, {}
	local tilesInner = {}
    for i = 1, 14 do
        tilesInner[i] = 0
    end
	for _,poker in ipairs(onePoker) do
		tilesInner[poker.value] = tilesInner[poker.value]+1
	end

	if #ysPokers == 0 then


	else

	end
end


--1
function PokerLogic.getOnePair(ysPokers, onePoker)
	local _randomPokers = PokerLogic.getRandomPokersByOneValue(2, ysPokers, onePoker)
	local _out = {}
	for _,_poker in ipairs(_randomPokers) do
		table.insert(_out, _poker)
	end
	return _out
end


--2
function PokerLogic.getThreeCardStraight(ysPokers, onePoker)
	local _out = {}
	local _randomPokers = PokerLogic.getRandomPokersByStraight(3, ysPokers, onePoker, false)
	for _,_poker in ipairs(_randomPokers) do
		table.insert(_out, _poker)
	end
	return _out
end


--3
function PokerLogic.getThreeOfAKing(ysPokers, onePoker)
	local _randomPokers = PokerLogic.getRandomPokersByOneValue(3, ysPokers, onePoker)
	local _out = {}
	for _,_poker in ipairs(_randomPokers) do
		table.insert(_out, _poker)
	end
	return _out
end


--4 
function PokerLogic.getFiveCardStraight(ysPokers, onePoker)
	local _out = {}
	local _randomPokers = PokerLogic.getRandomPokersByStraight(5, ysPokers, onePoker, false)
	for _,_poker in ipairs(_randomPokers) do
		table.insert(_out, _poker)
	end
	return _out
end


--5
function PokerLogic.getFullHouse(ysPokers, onePoker)
	local _out = {}
	local _randomPokers = PokerLogic.getRandomPokersByFullHouse(ysPokers, onePoker)
	for _,_poker in ipairs(_randomPokers) do
		table.insert(_out, _poker)
	end
	return _out
end


--6
function PokerLogic.getFlush(ysPokers, onePoker)

end


--7
function PokerLogic.getFourOfAKing(ysPokers, onePoker)
	local _randomPokers = PokerLogic.getRandomPokersByOneValue(4, ysPokers, onePoker)
	local _out = {}
	for _,_poker in ipairs(_randomPokers) do
		table.insert(_out, _poker)
	end
	return _out
end


--8 
function PokerLogic.getStraightFlush(ysPokers, onePoker)

end


-- 判断是否只能试一种牌型
function PokerLogic.adjustPokerType(ysPokers)

end

--
return PokerLogic


