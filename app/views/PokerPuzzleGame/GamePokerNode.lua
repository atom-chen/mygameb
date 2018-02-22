local GameConfig = require("app.core.GameConfig")
local GameMapConfig = require("app.core.Game.PokerPuzzleGameConfig")
local GameUtils = require("app.core.GameUtils")
local utils = require("app.common.utils")

local GamePokerNode = class("GamePokerNode", function()
    return display.newNode()
end)

local _Zorder_Rock_Touch = 10
local _Zorder_Rock_Light = 15
local _Zorder_Rock_Sprite = 20
local _Zorder_Score = 22

function GamePokerNode:ctor(id, poker)
	self._GameController = APP:getObject("PokerPuzzleGameController")
    self._id = id
    self._poker = poker

	local _touchSizeWidth, _touchSizeHeight = 110, 110
    assert(self._id>=1 and self._id<=(GameMapConfig.ROCK_X*GameMapConfig.ROCK_Y))

	self._x = self._GameController._MAP_XY[self._id].x+GameMapConfig.ROCK_WIDTH/2
	self._y = self._GameController._MAP_XY[self._id].y+GameMapConfig.ROCK_HEIGHT/2

	self._rockSpTouch = display.newScale9Sprite(GameMapConfig.ROCK_SHADOW_UNIT_PATH, 0, 0, 
        cc.size(_touchSizeWidth, _touchSizeHeight), 
        cc.rect(1, 1, 1, 1))
        :opacity(0)
        :align(display.CENTER, self._x, self._y)
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


	self._bg = display.newSolidCircle(50, {x = 0, y = 0, color = utils.c3bToc4f(GameConfig._COLOR["Snow"], 1)})
	self._bg:align(display.CENTER, _touchSizeWidth/2, _touchSizeHeight/2)
	self._bg:addTo(self._rockSpTouch, _Zorder_Rock_Sprite)



    if self._poker.suit == 1 or self._poker.suit == 3 then
        self._valuePath = "#card_black_"..self._poker.value..".png"
    else
        self._valuePath = "#card_red_"..self._poker.value..".png"
    end


    if self._poker.suit == 1 then
        self._suitPath = "#card_ht.png"
    elseif self._poker.suit == 2 then
        self._suitPath = "#card_hx.png"
    elseif self._poker.suit == 3 then
        self._suitPath = "#card_mh.png"
    elseif self._poker.suit == 4 then
        self._suitPath = "#card_fk.png"
    end

    self._pokerValue = display.newSprite(self._valuePath)
                        :scale(0.5)
                        :align(display.CENTER, _touchSizeWidth/2+20, _touchSizeHeight/2)
                        :addTo(self._rockSpTouch, _Zorder_Rock_Sprite)

    self._pokerSuit = display.newSprite(self._suitPath)
                        :scale(0.35)
                        :align(display.CENTER, _touchSizeWidth/2-20, _touchSizeHeight/2)
                        :addTo(self._rockSpTouch, _Zorder_Rock_Sprite)

end

function GamePokerNode:changeId(newid, withAnim)
	self._id = newid
	self._x = self._GameController._MAP_XY[self._id].x+GameMapConfig.ROCK_WIDTH/2
	self._y = self._GameController._MAP_XY[self._id].y+GameMapConfig.ROCK_HEIGHT/2

	if not withAnim then
		self._rockSpTouch:setPosition(self._x, self._y)
	else
		self._rockSpTouch:runAction(cca.sineIn(cca.moveTo(0.2, self._x, self._y)))
	end
end

function GamePokerNode:touchStart(x,y)
	-- print(self._id)
	return true	
end

function GamePokerNode:touchMove(x,y)
	
end

function GamePokerNode:touchEnded(x,y)
	self._GameController:touchNum(self._id)
end

function GamePokerNode:beChooseed()
	self._bg:runAction(cca.repeatForever(cca.seq({
										cca.scaleTo(0.2, 1.1),
										cca.scaleTo(0.2, 1),
									})))
end

function GamePokerNode:unChooseed()
	self._bg:stopAllActions()
	self._bg:setScale(1)
end

return GamePokerNode