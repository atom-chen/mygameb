--
-- Author: Your Name
-- Date: 2018-01-10 16:19:59
--
local GameConfig = require("app.core.GameConfig")
local GameUtils = require("app.core.GameUtils")
local ToolsLabelNode = require("app.other.ToolsLabelNode")

local ToolsWordLabelNode = class("ToolsWordLabelNode", ToolsLabelNode)

function ToolsWordLabelNode:ctor(params)
	ToolsWordLabelNode.super.ctor(self, params)
	
	self:createLabel()
end


function ToolsWordLabelNode:updateWord(text)
	self._text = text
	self:refreshString()
end
















return ToolsWordLabelNode