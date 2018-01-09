
local Poker = class("Poker")

Poker.NONE      = 0

-- card value
Poker.TWO       = 2
Poker.THREE     = 3
Poker.FOUR      = 4
Poker.FIVE      = 5
Poker.SIX       = 6
Poker.SEVEN     = 7
Poker.EIGHT     = 8
Poker.NINE      = 9
Poker.TEN       = 10
Poker.JACK      = 11
Poker.QUEEN     = 12
Poker.KING      = 13
Poker.ACE       = 14
Poker.S_JOKER   = 15
Poker.B_JOKER   = 16

-- card suit
Poker.SPADE     = 1
Poker.HEART     = 2
Poker.DIAMOND   = 3
Poker.CLUB      = 4

Poker.VALUE_PRINTS = {
    "None", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A", "S-Joker", "B-Joker"
}

Poker.SUIT_PRINTS = {
    "♤", "♡", "♧", "♢"
}

function Poker.encode(suit, value)
    return bit32.bor(bit32.lshift(value, 8), suit)
end

function Poker.decode(bitmap)
    return bit32.rshift(bitmap, 8), bit32.band(bitmap, 0xFF)
end

function Poker.isSameValue(pokers)
    if #pokers <= 1 then 
        return true 
    end

    local i = 1
    local value = pokers[i].value
    repeat
        if pokers[i].value ~= value then
            return false
        end
        i = i + 1
    until i > #pokers
    return true
end

function Poker.isSameSuit(pokers)
    if #pokers <= 1 then 
        return true 
    end

    local i = 1
    local suit = pokers[i].suit
    repeat
        if pokers[i].suit ~= suit then
            return false
        end
        i = i + 1
    until i > #pokers
    return true
end

function Poker.isValueConsective(pokers)
    if #pokers <= 1 then
        return true
    end

    table.sort(pokers, function(a, b) return a.value < b.value end)

    for i = 2, #pokers do
        if pokers[i].value ~= pokers[i-1].value + 1 then
            return false
        end
    end
    return true
end

function Poker:ctor(suit, value)
    self.suit = suit or Poker.NONE
    self.value = value or Poker.NONE
end

function Poker:initWithBitmap(bitmap)
    -- print("···", bitmap)
    self.value, self.suit = Poker.decode(bitmap)
end

function Poker:init(suit, value)
    self.suit, self.value = suit, value
end

function Poker:tostring()
    if self.suit ~= Poker.NONE then
        return Poker.SUIT_PRINTS[self.suit] .. Poker.VALUE_PRINTS[self.value]
    else
        return Poker.VALUE_PRINTS[self.value]
    end
end

function Poker:getBaccaratPoint()
    local out = self.value
    if out == 10 then out = 0
    elseif out == 11 then out = 0
    elseif out == 12 then out = 0
    elseif out == 13 then out = 0
    elseif out == 14 then out = 1
    end
    return out
end

function Poker:getNiuNiuPoint()
    local out = self.value
    if out == 10 then out = 10
    elseif out == 11 then out = 10
    elseif out == 12 then out = 10
    elseif out == 13 then out = 10
    elseif out == 14 then out = 1
    end
    return out
end

function Poker:getHualunPoint()
    local out = self.value
    if self.value == 5 and self.suit == Poker.HEART then out = 18
    elseif out == 2 then out = 15
    elseif out == Poker.S_JOKER then out = 16
    elseif out == Poker.B_JOKER then out = 17
    end
    return out
end

function Poker:getHualunPointB()
    local out = self.value
    if out == 2 then out = 15
    elseif out == Poker.S_JOKER then out = 16
    elseif out == Poker.B_JOKER then out = 17
    end
    return out
end

function Poker:getSifutouPoint(mainSuit, mainValue)
    local out
    if self.value >= 15 then 
        out = self.value+1000

    elseif self.value == mainValue then
        if self.suit == mainSuit then
            out = 999
        else
            out = 900-self.suit
        end
    else
        if self.suit == mainSuit then
            out = 600+self.value

        else
            out = (500-self.suit*100)+self.value
        end
    end
    return out
end

function Poker:isSifutouMain(mainSuit, mainValue)
    if self.value == mainValue then
        return true
    elseif self.suit == mainSuit then
        return true
    elseif self.value >= 15 then
        return true
    end
    return false
end

function Poker:getJielongValue()
    if self.value == 14 then
        return 1
    else
        return self.value
    end
end



return Poker