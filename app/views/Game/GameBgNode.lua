local GameConfig = require("app.core.GameConfig")

local GameBgNode = class("GameBgNode", function()
	return display.newNode()
end)

function GameBgNode:ctor(mapCfg)
	self._GameController = APP:getObject("GameController")
	
	self:initBg()
end


function GameBgNode:initBg()
	self._ao = 0

	local _bgNode_1 = display.newSprite("image/game/bg_1.png")
						:align(display.CENTER_TOP, display.cx, display.height)
						:addTo(self, 1)

	local _bgNode_2 = display.newSprite("image/game/bg_2.png")
						:align(display.CENTER_BOTTOM, display.cx, 0)
						:addTo(self, 100)

	local _bgNode_3 = display.newSprite("image/game/bg_3.png")
						:align(display.CENTER_BOTTOM, display.cx, display.height-298)
						:addTo(self, 50)
	-------
	-- 山 云
	self._bgNode = display.newNode()
		:align(display.CENTER, 0, 0)
        :addTo(self, 2)

	local _bgNode_5 = display.newSprite("image/game/bg_5.png")
						:align(display.CENTER_BOTTOM, 0, 0)
						:addTo(self._bgNode, 2)

	local _bgNode_8 = display.newSprite("image/game/bg_8.png")
						:align(display.CENTER_BOTTOM, -100, 30)
						:addTo(self._bgNode, 2)

	local _bgNode_9 = display.newSprite("image/game/bg_9.png")
						:align(display.CENTER_BOTTOM, 200, 78)
						:addTo(self._bgNode, 2)

	local _bgNode_10 = display.newSprite("image/game/bg_10.png")
						:align(display.CENTER_BOTTOM, 500, 60)
						:addTo(self._bgNode, 2)


	local _bgNode_11 = display.newSprite("image/game/bg_11.png")
						:align(display.CENTER, display.cx, display.cy+614)
						:addTo(self, 110)

	--
	local _bgNode_12 = display.newSprite("image/game/bg_12.png")
						:align(display.CENTER, display.cx, display.cy-86)
						:addTo(self, 110) 


	local params = 
    {
        type = GameConfig._TOOLS_LABEL_TYPE[2],
        num = 0,
        size = 54,
        isEnglishType = true,
        color = GameConfig._COLOR["Snow"], 
        borderColor = GameConfig._COLOR["Purple1"], 
        bordWidth = 2,
        shadowWidth = 4,
        fontPath = "effect/BRITANIC.TTF"
    }
    self._scoreLabel = APP:createView("ToolsNumLabelNode",params)
						:align(display.CENTER,_bgNode_11:getContentSize().width/2, _bgNode_11:getContentSize().height/2)
						:addTo(_bgNode_11, 2)
end




function GameBgNode:onCollision(dt)
	local _r = 1600
	local _pai = 3.1415926
	self._ao = self._ao + 0.1
	-- 45 ~ 135 之间
	if self._ao >= 150 then
		self._ao = 30
	end

	local _x1 = display.cx+_r*math.cos(self._ao*_pai/180)
	local _y1 = 0+_r*math.sin(self._ao*_pai/180)

	self._bgNode:pos(_x1, _y1)
	self._bgNode:setRotation(180-self._ao-90)

end


function GameBgNode:setScore(score)
	self._scoreLabel:updateNum(score, true)
end

















return GameBgNode