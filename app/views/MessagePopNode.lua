--
-- Author: gerry
-- Date: 2016-10-08 17:20:09
--
local MJTable = require("app.models.MJTable")
local GameUtils = require("app.core.GameUtils")
local utils = require("app.common.utils")
local GlobalStatus = APP:getObject("GlobalStatus")
local protocols = require("app.protocol.init")


local MessagePopNode = class("MessagePopNode", function()
    return display.newNode()
end)

function MessagePopNode:ctor(params)

	local text = params.text
    local _isMe = params.isMe or false
    local _isMusic = params.isMusic or false
    local content
    local _bgWidth, _bgHeight = 0, 0

    self._bubble_notplayed = nil
    self._playing = nil
    self._loading = nil
    self._play = nil

    if _isMusic then
        content = display.newNode()

        _bgWidth = 150
        _bgHeight = 60

        local _vvo = cc.ui.UIPushButton.new("image/white_unit.png", {scale9 = true})
                :opacity(0)
                :setButtonSize(_bgWidth, _bgHeight)
                :onButtonClicked(function(event) 
                    params.callback()
                end)
                :align(display.CENTER, _bgWidth/2-12, 12)
                :addTo(content, 1)

        self._loading = z.FrameAnimUtil:createAnim("yy-loading", 12, -1)
            :align(display.CENTER, 160, 15)
            :hide()
            :addTo(content)

        self._play = display.newSprite("image/playing_audio.png")
            :align(display.CENTER, 30, 14)
            :addTo(content)

        self._playing = z.FrameAnimUtil:createAnim("chatin_voice_play", 3, -1)
            :align(display.CENTER, 30, 14)
            :hide()
            :addTo(content)

        local time = cc.ui.UILabel.new({
            text = string.format("%d\"", params.sec or 0),
            size = 22,
            color = cc.c3b(238,44,44),
            align = cc.ui.TEXT_ALIGN_LEFT,
            valign = cc.ui.TEXT_VALIGN_CENTER,
            })
            :align(display.LEFT_CENTER, 68, 14)
            :addTo(content)

        if _isMe then
            self._bubble_notplayed = display.newNode()
                :align(display.CENTER_LEFT, 68+time:getContentSize().width+10, 30)
                :addTo(content)
        else
            self._bubble_notplayed = display.newSprite("image/chatin_new_voice.png")
                :align(display.CENTER_LEFT, 68+time:getContentSize().width+10, 30)
                :addTo(content)
        end

    else
    	content = cc.ui.UILabel.new({
                text = text,
                size = 28,
                color = cc.c3b(65, 55, 50),
                align = cc.ui.TEXT_ALIGN_LEFT,
                valign = cc.ui.TEXT_VALIGN_TOP,
                -- dimensions = cc.size(298, 0)
            })

        if content:getContentSize().width > 298 then
            content = cc.ui.UILabel.new({
                    text = text,
                    size = 28,
                    color = cc.c3b(65, 55, 50),
                    align = cc.ui.TEXT_ALIGN_LEFT,
                    valign = cc.ui.TEXT_VALIGN_TOP,
                    dimensions = cc.size(298, 0)
            })
        end
        _bgWidth = content:getContentSize().width + 45
        _bgHeight = content:getContentSize().height + 30
    end

    local _bgPath, _pointPath = "", ""
    if _isMe then
        _bgPath = "#mj_lt_bk_2.png"
        _pointPath = "#mj_lt_bk_2_1.png"
    else
        _bgPath = "#mj_lt_bk_1.png"
        _pointPath = "#mj_lt_bk_1_1.png"
    end


    local textContent = display.newScale9Sprite(_bgPath, 0, 0, 
            cc.size(_bgWidth, _bgHeight), 
            cc.rect(40, 20, 2, 2))
        :align(params.align, 0, 0)
        :addTo(self, 30)

    content:align(display.LEFT_TOP, 15, content:getContentSize().height + 15)
        :addTo(textContent) 

    local _voPoint = nil
    if _isMe then
        if params.align == display.TOP_LEFT then
        	_voPoint = display.newSprite(_pointPath)
                :align(params.align, -10, -11)
                :addTo(self, 31)
       	elseif params.align == display.TOP_RIGHT then
       		_voPoint = display.newSprite(_pointPath)
                :align(params.align, -5, -11)
                :addTo(self, 31)
            _voPoint:setScaleX(-1)
       	elseif params.align == display.BOTTOM_RIGHT then
       		_voPoint = display.newSprite(_pointPath)
                :align(params.align, -5, 11)
                :addTo(self, 31)
            _voPoint:setScaleX(-1)
       	elseif params.align == display.BOTTOM_LEFT then
       		_voPoint = display.newSprite(_pointPath)
                :align(params.align, -11, 10)
                :addTo(self, 31)
       	end
    else
        if params.align == display.TOP_LEFT then
            _voPoint = display.newSprite(_pointPath)
                :align(params.align, -11+14, -11)
                :addTo(self, 31)
            _voPoint:setScaleX(-1)
        elseif params.align == display.TOP_RIGHT then
            _voPoint = display.newSprite(_pointPath)
                :align(params.align, -5+14, -11)
                :addTo(self, 31)
            _voPoint:setScaleX(1)
        elseif params.align == display.BOTTOM_RIGHT then
            _voPoint = display.newSprite(_pointPath)
                :align(params.align, -5+14, 11)
                :addTo(self, 31)
            _voPoint:setScaleX(1)
        elseif params.align == display.BOTTOM_LEFT then
            _voPoint = display.newSprite(_pointPath)
                :align(params.align, -11+14, 10)
                :addTo(self, 31)
            _voPoint:setScaleX(-1)
        end

    end

    self._content = textContent

end


function MessagePopNode:getHeight()
    return self._content:getContentSize().height
end

function MessagePopNode:getBubbleNotplayed()
    return self._bubble_notplayed
end

function MessagePopNode:getLoading()
    return self._loading
end

function MessagePopNode:getPlaying()
    return self._playing
end

function MessagePopNode:getPlay()
    return self._play
end


return MessagePopNode