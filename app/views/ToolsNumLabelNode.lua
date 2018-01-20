--
-- Author: Your Name
-- Date: 2018-01-10 16:19:59
--
local GameConfig = require("app.core.GameConfig")
local GameUtils = require("app.core.GameUtils")
local ToolsLabelNode = require("app.other.ToolsLabelNode")

local ToolsNumLabelNode = class("ToolsNumLabelNode", ToolsLabelNode)

function ToolsNumLabelNode:ctor(params)
	ToolsNumLabelNode.super.ctor(self, params)

	self._num = params.num or 0
	self._isEnglishType = params.isEnglishType or false
	self._text = self:getNumString(self._num)
	
	self:createLabel()
end


function ToolsNumLabelNode:getNumString(num)
	local _numString = ""
	if self._isEnglishType then
		_numString = GameUtils.formatNumForEnglish(num)
	else
		_numString = num
	end
	return _numString
end


function ToolsNumLabelNode:updateNum(num)
	local _oldNum = self._num
	local _newNum = num

	local _disNum = _newNum - _oldNum
	local _dx = _disNum/80
	local _otAction = nil
	local _index = 1
	_otAction = self:runAction(cca.repeatForever(cca.seq({
				cca.delay(0.01),
				cca.cb(function()
						local _tempNum = math.floor(_oldNum + _dx*_index)
						self._text = self:getNumString(_tempNum)
						self:refreshString()
						_index = _index+1
					end),
				})))

	self:runAction(cca.seq({
			cca.delay(0.8),
			cca.cb(function() 
						self._num = num
						self._text = self:getNumString(self._num)
						self:refreshString()
						self:stopAction(_otAction)
					end),
		}))
end
















return ToolsNumLabelNode