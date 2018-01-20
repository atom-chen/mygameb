local GameConfig = require("app.core.GameConfig")
local GameMapConfig = require("app.core.Game.GameMapConfig")

local GameNextNode = class("GameNextNode", function()
    return display.newNode()
end)

function GameNextNode:ctor(mapCfg)
	self._GameController = APP:getObject("GameController")

	self.__allW = (GameMapConfig.ROCK_WIDTH+GameMapConfig.ROCK_D)*(GameMapConfig.ROCK_X-1)
	self.__allH = (GameMapConfig.ROCK_HEIGHT+GameMapConfig.ROCK_D)*(GameMapConfig.ROCK_Y-1)

	self._rocks = {}
end


function GameNextNode:rest()
	for _,v in ipairs(self._rocks) do
		v:removeSelf()
	end
	self._rocks = {}
end

function GameNextNode:addRocks(len, xid)
	local _width = GameMapConfig.ROCK_WIDTH*len+GameMapConfig.ROCK_D*(len-1)
	local _height = 23

	local _x = display.cx-self.__allW/2+(GameMapConfig.ROCK_WIDTH+GameMapConfig.ROCK_D)*(xid-1.5)+GameMapConfig.ROCK_D/2
	local _y = display.cy-self.__allH/2+(GameMapConfig.ROCK_HEIGHT+GameMapConfig.ROCK_D)*(0-1.5)+10

	local _rock = display.newScale9Sprite(GameMapConfig.ROCK_SHADOW_UNIT_PATH, 0, 0, 
        cc.size(_width, _height), 
        cc.rect(1, 1, 1, 1))
        :opacity(0)
        :align(display.BOTTOM_LEFT, _x, _y)
        :addTo(self, 1)

    table.insert(self._rocks, _rock)

    display.newScale9Sprite("image/game/rock_next_1.png", 0, 0, 
		cc.size(_width, _height), 
		cc.rect(50, 11, 2, 2))
		:pos(_width/2, _height/2)
		:addTo(_rock, 1)
end


return GameNextNode