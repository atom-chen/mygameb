local GameConfig = require("app.core.GameConfig")
local GameMapConfig = require("app.core.GameMapConfig")

local GameMapNode = class("GameMapNode", function()
    return display.newNode()
end)

function GameMapNode:ctor(mapCfg)
	self._GameController = APP:getObject("GameController")

	

	local __allW = (GameMapConfig.ROCK_WIDTH+GameMapConfig.ROCK_D)*(GameMapConfig.ROCK_X-1)
	local __allH = (GameMapConfig.ROCK_HEIGHT+GameMapConfig.ROCK_D)*(GameMapConfig.ROCK_Y-1)

	self._GameController._MAP_MIN_X
	= display.cx-__allW/2+(GameMapConfig.ROCK_WIDTH+GameMapConfig.ROCK_D)*(1-1.5)+GameMapConfig.ROCK_D/2
	self._GameController._MAP_MAX_X
	= display.cx-__allW/2+(GameMapConfig.ROCK_WIDTH+GameMapConfig.ROCK_D)*(GameMapConfig.ROCK_X-1.5)+GameMapConfig.ROCK_WIDTH+GameMapConfig.ROCK_D/2

	self._GameController._MAP_MIN_Y
	= display.cy-__allH/2+(GameMapConfig.ROCK_HEIGHT+GameMapConfig.ROCK_D)*(1-1.5)-54
	self._GameController._MAP_MAX_Y
	= display.cy-__allH/2+(GameMapConfig.ROCK_HEIGHT+GameMapConfig.ROCK_D)*(GameMapConfig.ROCK_Y-1.5)+GameMapConfig.ROCK_HEIGHT-54

	for _yRock=1,GameMapConfig.ROCK_Y do
		for _xRock=1,GameMapConfig.ROCK_X do

			local _x = display.cx-__allW/2+(GameMapConfig.ROCK_WIDTH+GameMapConfig.ROCK_D)*(_xRock-1.5)+GameMapConfig.ROCK_D/2
			local _y = display.cy-__allH/2+(GameMapConfig.ROCK_HEIGHT+GameMapConfig.ROCK_D)*(_yRock-1.5)-54
			local temp = display.newScale9Sprite(GameMapConfig.ROCK_SHADOW_UNIT_PATH, 0, 0, 
						cc.size(GameMapConfig.ROCK_WIDTH, GameMapConfig.ROCK_HEIGHT), 
						cc.rect(0, 0, 1, 1))
						:align(display.BOTTOM_LEFT, _x, _y)
						:opacity(0)
						:addTo(self,1)
			-- temp:setColor(cc.c4f(1,0,0,1))

			-- set xy
			local _id = (_yRock-1)*GameMapConfig.ROCK_X+_xRock

			if M_DEBUG then
				cc.ui.UILabel.new({
		            text = tostring(_id),
		            size = 24,
		            color = cc.c3b(244, 244, 244),
		            align = cc.ui.TEXT_ALIGN_CENTER,
		            valign = cc.ui.TEXT_VALIGN_CENTER,
		        })
		        :align(display.CENTER, _x, _y)
		        :addTo(self,2)
	        end

			table.insert(self._GameController._MAP_XY, {x=_x, y=_y})

			if _yRock == 1 then
				table.insert(self._GameController._MAP_CELL_X, _x)
			end
		end
	end
	
	table.insert(self._GameController._MAP_CELL_X, self._GameController._MAP_MAX_X+GameMapConfig.ROCK_D)
end















return GameMapNode