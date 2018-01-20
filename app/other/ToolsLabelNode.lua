--
-- Author: Your Name
-- Date: 2018-01-10 16:19:59
--
local GameConfig = require("app.core.GameConfig")
local GameUtils = require("app.core.GameUtils")
local GameConfig = require("app.core.GameConfig")

local ToolsLabelNode = class("ToolsLabelNode", function()
	return display.newNode()
end)

function ToolsLabelNode:ctor(params)
	self._type = params.type or GameConfig._TOOLS_LABEL_TYPE[1]
	self._text = params.text or ""
	self._size = params.size or 10
	self._color = params.color or GameConfig._COLOR["Snow"]
	self._borderWidth = params.bordWidth or 1
	self._borderColor = params.borderColor or GameConfig._COLOR["Black"]
	self._shadowWidth = params.shadowWidth or 4
	self._shadowOpacity = params.shadowOpacity or 120
	self._fontPath = params.fontPath or nil

	self._mainLabel = nil
	self._mainLabel_Stroke_up = nil
    self._mainLabel_Stroke_down = nil
    self._mainLabel_Stroke_left = nil
    self._mainLabel_Stroke_right = nil
    self._mainLabel_Shadow = nil
end

function ToolsLabelNode:createLabel()
	self:createNormalLabel()
	if self._type == GameConfig._TOOLS_LABEL_TYPE[1] then
		
	elseif self._type == GameConfig._TOOLS_LABEL_TYPE[2] then
		self:AddStroke()
	elseif self._type == GameConfig._TOOLS_LABEL_TYPE[3] then
		self:AddShadow()
	elseif self._type == GameConfig._TOOLS_LABEL_TYPE[4] then
		self:AddStroke()
		self:AddShadow()
	end
end

function ToolsLabelNode:refreshString()
	self._mainLabel:setString(self._text)
	if self._type == GameConfig._TOOLS_LABEL_TYPE[1] then
		
	elseif self._type == GameConfig._TOOLS_LABEL_TYPE[2] then
		if self._mainLabel_Stroke_up then
			self._mainLabel_Stroke_up:setString(self._text)
		end
		if self._mainLabel_Stroke_down then
			self._mainLabel_Stroke_down:setString(self._text)
		end
		if self._mainLabel_Stroke_left then
			self._mainLabel_Stroke_left:setString(self._text)
		end
		if self._mainLabel_Stroke_right then
			self._mainLabel_Stroke_right:setString(self._text)
		end
	elseif self._type == GameConfig._TOOLS_LABEL_TYPE[3] then
		if self._mainLabel_Shadow then
			self._mainLabel_Shadow:setString(self._text)
		end
	elseif self._type == GameConfig._TOOLS_LABEL_TYPE[4] then
		if self._mainLabel_Stroke_up then
			self._mainLabel_Stroke_up:setString(self._text)
		end
		if self._mainLabel_Stroke_down then
			self._mainLabel_Stroke_down:setString(self._text)
		end
		if self._mainLabel_Stroke_left then
			self._mainLabel_Stroke_left:setString(self._text)
		end
		if self._mainLabel_Stroke_right then
			self._mainLabel_Stroke_right:setString(self._text)
		end
		if self._mainLabel_Shadow then
			self._mainLabel_Shadow:setString(self._text)
		end
	end
end

function ToolsLabelNode:createNormalLabel()
	self._mainLabel = cc.ui.UILabel.new({
			UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
			text = self._text,
			size = self._size,
			font = self._fontPath,
		})
		:align(display.CENTER,0, 0)
		:addTo(self, 10)
	self._mainLabel:setColor(self._color)
end


function ToolsLabelNode:AddStroke()

	--描边CCLabelTTF 上  
	self._mainLabel_Stroke_up = cc.ui.UILabel.new({
			UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
			text = self._text,
			size = self._size,
			font = self._fontPath,
		})
		:align(display.CENTER, 0, self._borderWidth)
		:addTo(self, 9)
  
    -- --描边CCLabelTTF 下  
    self._mainLabel_Stroke_down = cc.ui.UILabel.new({
			UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
			text = self._text,
			size = self._size,
			font = self._fontPath,
		})
		:align(display.CENTER, 0, -self._borderWidth)
		:addTo(self, 9)
      
    -- --描边CCLabelTTF 左  
    self._mainLabel_Stroke_left = cc.ui.UILabel.new({
			UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
			text = self._text,
			size = self._size,
			font = self._fontPath,
		})
		:align(display.CENTER, -self._borderWidth, 0)
		:addTo(self, 9)
      
    -- --描边CCLabelTTF 右  
    self._mainLabel_Stroke_right = cc.ui.UILabel.new({
			UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
			text = self._text,
			size = self._size,
			font = self._fontPath,
		})
		:align(display.CENTER, self._borderWidth, 0)
		:addTo(self, 9)


    self._mainLabel_Stroke_up:setColor(self._borderColor)
    self._mainLabel_Stroke_down:setColor(self._borderColor)
    self._mainLabel_Stroke_left:setColor(self._borderColor)
    self._mainLabel_Stroke_right:setColor(self._borderColor)
    
end


function ToolsLabelNode:AddShadow() 

    self._mainLabel_Shadow = cc.ui.UILabel.new({
			UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
			text = self._text,
			size = self._size,
			font = self._fontPath,
		})
		:align(display.CENTER, self._shadowWidth, -self._shadowWidth)
		:addTo(self, 1)
      
 	self._mainLabel_Shadow:setColor(GameConfig._COLOR["Black"])
 	self._mainLabel_Shadow:setOpacity(self._shadowOpacity)

end








return ToolsLabelNode