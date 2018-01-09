
local GameConfig = require("app.core.GameConfig")
local ViewBase = require("app.views.ViewBase")
local utils = require("app.common.utils")
local GameUtils = require("app.core.GameUtils")
local protocols = require("app.protocol.init")
local scheduler = require("framework.scheduler")

local TableMessagesNode = class("TableMessagesNode", ViewBase)

function TableMessagesNode:ctor(params)
    TableMessagesNode.super.ctor(self)
    display.addSpriteFrames("effect/mj_chat_res.plist", "effect/mj_chat_res.png")


    self._dx = 70
    self:setCascadeOpacityEnabled(true)

    self._info = {}
    self._info = {
        _userIds = {},
        _audios = {}
    }

    self._voiceRecordX = params.x
    self._voiceRecordY = params.y

    self._locationX = params.location_x or (params.x + 90)
    self._locationY = params.location_y or params.y

    self._recordSec = 0
    self._recordSprite = nil
    self._lastVolumeIndex = 0

    self._isShowAlert = false
    self._isShow = false
    self._widthA = 492
    self._heightA = 574
    self._width = self._widthA-45
    self._height = self._heightA-135
    self._closeCB = nil
    self._chatCB = function(mtype, content, record_time) 
        local request = protocols.message_pb.MessageRequest()
        request.type = mtype
        request.content = content
        request.to = 0
        request.record_time = record_time or 0
        SOCKET_MANAGER.send(protocols.command_pb.CMD_MESSAGE_REQ, request) 
    end

    local globalStatus = APP:getObject("GlobalStatus")
    if not globalStatus._scheduleHandlers then
        globalStatus._scheduleHandlers = {}
    end

    self._recordPressedFunc = function()
        if z.AudioRecorder == nil then
            if self._isShowAlert == false then
                self._isShowAlert = true
                APP:getCurrentController():showAlertOK({desc = "游戏版本过低，请重新下载新版本后使用语音功能"})
            end
            return
        end

        GameUtils.startRecordAudio()
        self._recordSprite = display.newSprite("image/chatin_record_bg.png")
                        :align(display.CENTER, display.cx, display.cy)
                        :addTo(self)

        self._recordTimeLabel = cc.ui.UILabel.new({
                    text = "",
                    size = 25,
                    color = cc.c3b(255, 0, 0),
                    }):pos(72, 50)
                      :addTo(self._recordSprite)

        self._recordTooShortLabel = cc.ui.UILabel.new({
                    text = "(录音过短)",
                    size = 22,
                    color = cc.c3b(255, 0, 0),
                    }):pos(52, 20)
                      :addTo(self._recordSprite)

        self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.displayRecording))
        self:scheduleUpdate()
    end

    self._recordReleaseFunc = function()
        if z.AudioRecorder == nil then
            return
        end
        local result = GameUtils.endRecordAudio()
        self:removeRecording()
        if result == 0 then
            local path = z.AudioRecorder:getInstance():getRecordFilename()
            -- print("----- paht : ", path)
            local size = utils.convertNumberShortKM(z.FileOperation:fileSize(path))
            -- print("----- size : ", size)
            -- print("----- pooo : ", utils.getLocalString("send_audio_ask"))
            -- 录音成功，上传upyun
            if z.AudioRecorder:getInstance():getRecordTime() > 60 or z.AudioRecorder:getInstance():getRecordTime() < 1 then
                return false
            end
            
            self:runAction(cca.seq({
                cca.delay(0.5),
                cca.callFunc(function() 
                    printInfo("上传 %s", path)
                    -- local result = z.UpYunManager:getInstance():uploadFile("casino-audio", "mobile", path)
                    -- if result == 0 then
                    --     if self._chatCB then
                    --         self._chatCB(protocols.message_pb.MESSAGE_TYPE_TABLE_VOICE, 
                    --             z.UpYunManager:getInstance():getLastUrl(),
                    --             z.AudioRecorder:getInstance():getRecordTime())
                    --         self._editBox:setText("")
                    --     end
                    -- else
                    --     printInfo("上传失败")
                    -- end
                    local recordTime = z.AudioRecorder:getInstance():getRecordTime()
                    local url = z.UpYunManager:getInstance():uploadFile("shigao-audio", "audio", path)
                    local s = scheduler.scheduleGlobal(function()
                        local result = z.UpYunManager:getInstance():getUploadResult(url)
                        printInfo(result)
                        local globalStatus = APP:getObject("GlobalStatus")
                        local handler = globalStatus._scheduleHandlers[url]
                        if result > 0 then
                            printInfo("上传失败")
                            z.UpYunManager:getInstance():clearUploadResult(url)
                            scheduler.unscheduleGlobal(handler)
                            globalStatus._scheduleHandlers[url] = nil
                        elseif result == 0 then
                            printInfo("上传成功")
                            local request = protocols.message_pb.MessageRequest()
                            request.type = protocols.message_pb.MESSAGE_TYPE_TABLE_VOICE
                            request.content = url
                            request.to = 0
                            request.record_time = recordTime
                            SOCKET_MANAGER.send(protocols.command_pb.CMD_MESSAGE_REQ, request) 
    
                            z.UpYunManager:getInstance():clearUploadResult(url)
                            scheduler.unscheduleGlobal(handler)
                            globalStatus._scheduleHandlers[url] = nil
                        end
                    end, 1)
                    local globalStatus = APP:getObject("GlobalStatus")
                    globalStatus._scheduleHandlers[url] = s

                    self._editBox:setText("")
                end),
            }))
        else
            printInfo("录音失败")
        end
    end

    -- 底部背景
    self._backSprite = display.newScale9Sprite("#mj_lt_bg.png", 0, 0, 
        cc.size(self._widthA, self._heightA), 
        cc.rect(35, 150, 4, 4))
        :align(display.LEFT_BOTTOM, params.x+40 - self._widthA, 100)
        :hide()
        :addTo(self)

    self._backSprite:setCascadeColorEnabled(true)

    self._contA = display.newNode()
        :align(display.TOP_LEFT, 0, 0)
        :addTo(self._backSprite,1) 
    self._contB = display.newNode()
        :align(display.TOP_LEFT, 0, 0)
        :addTo(self._backSprite,1) 
    self._contC = display.newNode()
        :align(display.TOP_LEFT, 0, 0)
        :addTo(self._backSprite,1) 

    -- 按钮：关闭
    self._touchBottom = cc.ui.UIPushButton.new("image/white_unit.png", {scale9 = true})
        :opacity(0)
        :setButtonSize(display.width, display.height)
        :onButtonClicked(function(event) 
            self._backSprite:hide()
            -- self._backSprite:runAction(cca.seq({
            --     cca.moveTo(0.2, display.width + 100, 100), 
            --     cca.cb(function() 
            --         self._backSprite:hide()
            --         self:zorder(15)
            --     end)
            -- }))
        end)
        :align(display.LEFT_BOTTOM, -self._backSprite:getPositionX(), -self._backSprite:getPositionY())
        :addTo(self._backSprite, -10)

    cc.ui.UIPushButton.new("image/white_unit.png", {scale9 = true})
        :opacity(0)
        :setButtonSize(self._widthA, self._heightA)
        :onButtonClicked(function(event) 
            -- printInfo("xxx")
        end)
        :align(display.LEFT_BOTTOM, 0, 0)
        :addTo(self._backSprite, -10)

    display.newSprite("imagetemp/chatin_btn_msg.png")
            :align(display.CENTER, params.x+84, params.y-80+40)
            :addTo(self,-1)
    -- local button = cc.ui.UIPushButton.new("image/white_unit.png")
    local button = cc.ui.UIPushButton.new("image/transparent_unit.png")
        :onButtonClicked(function()
            if self._backSprite:isVisible() then
                self._backSprite:hide()
            else
                self:zorder(30)
                self._backSprite:show()
            end
        end)
        :align(display.CENTER, params.x+84, params.y-80+40)
        :addTo(self,-1)
    button:setButtonSize(80, 80)

    --- 侧边按钮
    cc.ui.UIPushButton.new("image/white_unit.png", {scale9 = true})
        :opacity(0)
        :setButtonSize(80, 150)
        :onButtonClicked(function(event) 
            self:chooseTab(1)
        end)
        :align(display.CENTER, 444, 490)
        :addTo(self._backSprite, 1)

    cc.ui.UIPushButton.new("image/white_unit.png", {scale9 = true})
        :opacity(0)
        :setButtonSize(80, 150)
        :onButtonClicked(function(event) 
            self:chooseTab(2)
        end)
        :align(display.CENTER, 444, 326)
        :addTo(self._backSprite, 1)

    cc.ui.UIPushButton.new("image/white_unit.png", {scale9 = true})
        :opacity(0)
        :setButtonSize(80, 150)
        :onButtonClicked(function(event) 
            self:chooseTab(3)
        end)
        :align(display.CENTER, 444, 162)
        :addTo(self._backSprite, 1)

    self._tabSpA = display.newSprite("#mj_lt_btn1_1.png")
        :align(display.CENTER, 444, 486)
        :addTo(self._backSprite, 2)

    self._tabSpB = display.newSprite("#mj_lt_btn2_1.png")
        :align(display.CENTER, 444, 326)
        :addTo(self._backSprite, 2)

    self._tabSpC = display.newSprite("#mj_lt_btn3_1.png")
        :align(display.CENTER, 444, 162)
        :addTo(self._backSprite, 2)


    -- 世界聊天频道
    self._chatListViewWorld = cc.ui.UIListView.new({
        viewRect = cc.rect(0, 0, 400, 460),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        touchOnContent = false
        })
        :pos(10, 90)
        :addTo(self._contC)
    self._chatListViewWorld:setCascadeOpacityEnabled(true)
    self._chatListViewWorld.container:setCascadeOpacityEnabled(true)
    self._chatListViewWorld:onTouch(handler(self, self.handleTouch))
    -- self._chatListViewWorld:hide()

    local localDataManager = z.LocalDataManager:getInstance()
    local swAutoPlayAudio = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_AutoPlayAudio)

    
    --输入框 背景
    display.newScale9Sprite("#mj_lt_edit_bg.png", 0, 0, 
        cc.size(330, 56), 
        cc.rect(20, 27, 2, 2))
        :align(display.LEFT_BOTTOM, 10, 14)
        :addTo(self._backSprite,3)

    self._editBox = nil
    self._editBox = APP:createView("UIInputFixed", {
        image = "image/transparent_unit.png",
        -- image = "image/white_unit.png",
        size = cc.size(330, 50),
        listener = function(event, editbox)
            -- print("···event :", event)
            -- print("···xx ", self._editBox:getText())
            dump(self._editBox)
            if event == "return" then
                if #self._editBox:getText() > 0 then
                    if self._chatCB then
                        self._chatCB(protocols.message_pb.MESSAGE_TYPE_TABLE_TEXT, self._editBox:getText())
                        self._editBox:setText("")
                    end
                end
            end
        end
    })
    self._editBox:setMaxLength(80)
    self._editBox:setCascadeOpacityEnabled(true)
    self._editBox:setPosition(cc.p(10, 10))
    self._editBox:setAnchorPoint(cc.p(0, 0))
    self._editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self._editBox:setPlaceholderFontColor(cc.c3b(180, 220, 230))
    self._editBox:setFontColor(cc.c3b(180, 220, 230))
    self._editBox:addTo(self._backSprite,3)
    -- dump(self._editBox)

    -- 发送
    cc.ui.UIPushButton.new({normal ="#mj_lt_send.png", 
        pressed = "#mj_lt_send.png"})
        :onButtonClicked(function() 
            if #self._editBox:getText() > 0 then
                if self._chatCB then
                    self._chatCB(protocols.message_pb.MESSAGE_TYPE_TABLE_TEXT, self._editBox:getText())
                    self._editBox:setText("")
                end
            end
        end)
        :onButtonPressed(function(event) event.target:scale(1.1) end)
        :onButtonRelease(function(event) event.target:scale(1) end)
        :align(display.CENTER, self._widthA - 78, 41)
        :addTo(self._backSprite)

    ----[[-- 

    -- 语音聊天按钮
    display.newSprite("imagetemp/chatin_btn_voice.png")
        :align(display.CENTER, params.x+84, params.y+40)
        :addTo(self,-1)
    -- local button = cc.ui.UIPushButton.new("image/white_unit.png")
    local button = cc.ui.UIPushButton.new("image/transparent_unit.png")
        :onButtonPressed(self._recordPressedFunc)
        :onButtonRelease(self._recordReleaseFunc)
        :align(display.CENTER, params.x+84, params.y+40)
        :addTo(self,-1)
    button:setButtonSize(80, 80)

    


    -- 初始状态
    -- self:hide()
    -- self:opacity(0)
    -- self:setScaleY(0)
    -- self:runAction(cca.seq({
    --     cca.delay(0.2),
    --     cca.cb(function()
    --             self:pushAudio("0", 10015, "xxxxx", 1, 1231231111, "", 31)
    --             self:pushAudio("0", 10008, "xxxxx", 1, 1231231111, "", 3)
    --             self:pushMessage("0", 104, "xxxxx", 2, 1231231111, "text---2222")
    --             self:pushMessage("0", 10008, "xxxxx", 2, 1231231111, "text---2222")
    --             self:pushMessage("0", 103, "xxxxx", 2, 1231231111, "text---i say XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    --             self:pushMessage("0", 10014, "xxxxx", 2, 1231231111, "text---2222text---2222text---2222text---2222")

    --             APP:getCurrentController():showMessageAnim(10015, 2)
    --             APP:getCurrentController():showMessageAnim(10008, 2)
    --             APP:getCurrentController():showMessageAnim(10014, 2)
    --             APP:getCurrentController():showMessageAnim(102, 2)

    --         end),
    -- }))
    
    
    -- self:pushMessage("0", 10015, "xxxxx", 2, 1231231111, "text---i say")
   
    -- self:pushMessage("0", 10016, "xxxxx", 2, 1231231111, "text---2222")

    self:chooseTab(1)
end

function TableMessagesNode:setCloseCallback(callback)
    self._closeCB = callback
end

function TableMessagesNode:setChatCallback(callback)
    self._chatCB = callback
end

function TableMessagesNode:actionEnter()
    self._isShow = true
    self:stopAllActions()
    self:runAction(cca.spawn({
        cca.show(),
        cca.sineInOut(cca.fadeTo(0.1, 1)),
        cca.sineInOut(cca.scaleTo(0.2, 1, 1)),
        }))
end

function TableMessagesNode:actionExit()
    self._isShow = false
    self:runAction(cca.seq({
        cca.spawn({
            cca.sineInOut(cca.fadeTo(0.1, 0)),
            cca.sineInOut(cca.scaleTo(0.2, 1, 0)),
            }),
        cca.hide()
        }))
end

function TableMessagesNode:isShow()
    return self._isShow
end

function TableMessagesNode:pushAudio(channelId, user_id, nickname, gender, timestamp, url, ext_data)
    local info = self._info
    local user = APP:getObject("User")
    table.insert(info._userIds, user_id)
    
    -- self:showTableMessageTip(user_id, "【语音】   ")
    APP:getCurrentController():showMessage(user_id, "[语音]   ")

    local listView = self:getListView(channelId)

    local x, y = listView.container:getPosition()
    local height = listView.container:getCascadeBoundingBox().height
    -- printInfo("lastPos %f %f %f", x, y, height)

    if nickname == "" then
        nickname = "系统"
    end
    local _width = self._width / 2 - 100 + self._dx

    -- 第一排 名字
    local item = listView:newItem()
    item:setCascadeOpacityEnabled(true)
    local dcontent = display.newNode()
    if user.user_id ~= user_id then
        local content = cc.ui.UILabel.new({
            text = "    " .. z.StringUtility:truncate(nickname, 15, ""),
            size = 22,
            color = cc.c3b(180, 220, 230),
            align = cc.ui.TEXT_ALIGN_LEFT,
            valign = cc.ui.TEXT_VALIGN_TOP,
            -- dimensions = cc.size(self._width - 120, 0)
            })
            :align(display.LEFT_TOP, -_width - 20, 10)
            :addTo(dcontent)
    end
    item:setItemSize(self._width, 26 + 35)
    item:addContent(dcontent)

    --chatin_line.png

    -- if user_id <= 0 then
    --     display.newSprite("image/chips_s_5.png")
    --         :align(display.LEFT_CENTER, 8, item.height - content:getContentSize().height/2 - 2)
    --         :scale(0.8)
    --         :addTo(item)
    -- elseif gender ~= GameConfig.Gender_Female then
    --     display.newSprite("image/chips_s_2.png")
    --         :align(display.LEFT_CENTER, 8, item.height - content:getContentSize().height/2 - 2)
    --         :scale(0.8)
    --         :addTo(item)
    -- else
    --     display.newSprite("image/chips_s_3.png")
    --         :align(display.LEFT_CENTER, 8, item.height - content:getContentSize().height/2 - 2)
    --         :scale(0.8)
    --         :addTo(item)
    -- end
    cc.ui.UILabel.new({
        text = os.date("%m.%d %H:%M:%S", timestamp),
        size = 22,
        color = cc.c3b(180, 220, 230),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        valign = cc.ui.TEXT_VALIGN_TOP,
        })
        :align(display.RIGHT_TOP, _width - 25, 10)
        :addTo(dcontent)
    if #listView.items_ ~= 0 then
        display.newScale9Sprite("#mj_lt_line.png", 0, 0, 
                cc.size(self._width-38, 2), 
                cc.rect(5, 2, 1, 1))
                :align(display.CENTER, _width -10, 45)
                :addTo(item)
    end
    listView:addItem(item)

    -- 第二排 内容
    local item = listView:newItem()
    item:setCascadeOpacityEnabled(true)

    local content = display.newNode()

    local bubble_notplayed
    local loading 
    local playing
    local play
    local time
    local sec = tonumber(ext_data) or 0
    -- sec = math.ceil(sec / 1000)
    local button

    local _align
    local ___pos
    local _isMe
    if user.user_id ~= user_id then
        _align = display.TOP_LEFT
        _isMe = false
    else
        _align = display.TOP_RIGHT
        _isMe = true
    end

    local params = 
    {
        text = text,
        align = _align,
        isMe = _isMe,
        isMusic = true,
        sec = sec,
        callback = (function()
                    printInfo("手动播放语音")
                    z.AudioPlayManager:getInstance():stopCurrentAudio()
                    z.AudioPlayManager:getInstance():requestPlay(url)
                end),

    }

    local _cont = APP:createView("MessagePopNode",params)
       :addTo(content,30)

    if user.user_id ~= user_id then
        ___pos = cc.p(-180, _cont:getHeight()/2)
    else
        ___pos = cc.p(180, _cont:getHeight()/2)
    end
    _cont:align(display.CENTER, ___pos.x, ___pos.y)

    item:setItemSize(self._width, _cont:getHeight()+30)


    bubble_notplayed = _cont:getBubbleNotplayed()
    loading = _cont:getLoading()
    playing = _cont:getPlaying()
    play = _cont:getPlay()

    -- if user.user_id ~= user_id then
    --     textContent = display.newScale9Sprite("image/chatin_msg_bg_1.png", 0, 0, 
    --         cc.size(135, 58), 
    --         cc.rect(40, 20, 5, 5))
    --         :align(display.LEFT_TOP, -_width, 40)
    --         :addTo(content) 

    --     bubble_notplayed = display.newSprite("image/chatin_new_voice.png")
    --         :align(display.CENTER, -_width + 120, 20)
    --         :addTo(content)

    --     loading = z.FrameAnimUtil:createAnim("yy-loading", 12, -1)
    --         :align(display.CENTER, -_width + 160, 4)
    --         :hide()
    --         :addTo(content)

    --     play = display.newSprite("image/playing_audio.png")
    --         :align(display.CENTER, -_width + 30, 5)
    --         :addTo(content)

    --     playing = z.FrameAnimUtil:createAnim("chatin_voice_play", 3, -1)
    --         :align(display.CENTER, -_width + 30, 5)
    --         :hide()
    --         :addTo(content)

    --     time = cc.ui.UILabel.new({
    --         text = string.format("%d\"", sec or 0),
    --         size = 22,
    --         color = cc.c3b(238,44,44),
    --         align = cc.ui.TEXT_ALIGN_LEFT,
    --         valign = cc.ui.TEXT_VALIGN_CENTER,
    --         })
    --         :align(display.LEFT_CENTER, -_width + 68, 5)
    --         :addTo(content)

    --     button = cc.ui.UIPushButton.new("image/transparent_unit.png", {scale9 = true})
    --         :setButtonSize(150, 60)
    --         :onButtonClicked(function(event)
    --             printInfo("手动播放语音")
    --             z.AudioPlayManager:getInstance():stopCurrentAudio()
    --             z.AudioPlayManager:getInstance():requestPlay(url)
    --         end)
    --         :align(display.LEFT_TOP,-_width, 22)
    --         :addTo(content)
            
    --     local localDataManager = z.LocalDataManager:getInstance()
    --     local swAutoPlayAudio = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_AutoPlayAudio)
    --     if swAutoPlayAudio == GameConfig.SW_DEFAULT or swAutoPlayAudio == GameConfig.SW_ON then
    --         local swSound = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_Sound)
    --         if swSound == GameConfig.SW_DEFAULT or swSound == GameConfig.SW_ON then
    --             z.AudioPlayManager:getInstance():requestPlay(url)
    --         end
    --     end
    -- else
    --     textContent = display.newScale9Sprite("image/chatin_msg_bg_2.png", 0, 0, 
    --         cc.size(135, 50), 
    --         cc.rect(40, 20, 5, 5))
    --         :align(display.RIGHT_TOP, _width -15, 30)
    --         :addTo(content) 

    --     bubble_notplayed = display.newNode()
    --         :align(display.CENTER, -_width + 120, 20)
    --         :hide()
    --         :addTo(content)   

    --     loading = z.FrameAnimUtil:createAnim("yy-loading", 12, -1)
    --         :align(display.CENTER, _width - 170, 4)
    --         :hide()
    --         :addTo(content)

    --     play = display.newSprite("image/playing_audio.png")
    --         :align(display.CENTER, _width - 120, 5)
    --         :addTo(content)

    --     playing = z.FrameAnimUtil:createAnim("chatin_voice_play", 3, -1)
    --         :align(display.CENTER, _width - 120, 5)
    --         :hide()
    --         :addTo(content)  
    --     time = cc.ui.UILabel.new({
    --         text = string.format("%d\"", sec or 0),
    --         size = 22,
    --         color = cc.c3b(238,44,44),
    --         align = cc.ui.TEXT_ALIGN_LEFT,
    --         valign = cc.ui.TEXT_VALIGN_CENTER,
    --         })
    --         :align(display.LEFT_CENTER, _width - 80, 3)
    --         :addTo(content) 

    --     button = cc.ui.UIPushButton.new("image/transparent_unit.png", {scale9 = true})
    --         :setButtonSize(150, 60)
    --         :onButtonClicked(function(event)
    --             printInfo("手动播放语音")
    --             z.AudioPlayManager:getInstance():stopCurrentAudio()
    --             z.AudioPlayManager:getInstance():requestPlay(url)
    --         end)
    --         :align(display.RIGHT_TOP, _width -15, 30)
    --         :addTo(content)  

        
    -- end


    local localDataManager = z.LocalDataManager:getInstance()
    local swAutoPlayAudio = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_AutoPlayAudio)
    if swAutoPlayAudio == GameConfig.SW_DEFAULT or swAutoPlayAudio == GameConfig.SW_ON then
        local swSound = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_Sound)
        if swSound == GameConfig.SW_DEFAULT or swSound == GameConfig.SW_ON then
            z.AudioPlayManager:getInstance():requestPlay(url)
        end
    end

    local bubble_played = display.newNode()
        :hide()
        :align(display.CENTER, -112, 0)
        :addTo(content)

    -- local button = cc.ui.UIPushButton.new("image/transparent_unit.png", {scale9 = true})
    --     :setButtonSize(150, 60)
    --     :onButtonClicked(function(event)
    --         printInfo("手动播放语音")
    --         z.AudioPlayManager:getInstance():stopCurrentAudio()
    --         z.AudioPlayManager:getInstance():requestPlay(url)
    --     end)
    --     :align(display.LEFT_TOP,-_width, 2)
    --     :addTo(content)

    -- 保存音频信息
    local audio = {
        bubble_notplayed = bubble_notplayed,
        bubble_played = bubble_played,
        loading = loading,
        play = play,
        playing = playing,
        -- button = button,
    }
    info._audios[url] = audio

    -- item:setItemSize(self._width, 52)
    item:addContent(content)
    listView:addItem(item)

    listView:reload()

    local newheight = listView.size.height
    -- printInfo("-------------- %f %f %f", height, newheight, self._height)
    if newheight >= self._height then
        listView.container:setPosition(cc.p(x, 0))
    else
        listView.container:setPosition(cc.p(x, self._height - newheight))
    end
end

function TableMessagesNode:pushMessage(channelId, user_id, nickname, gender, timestamp, text)
    local info = self._info
    local user = APP:getObject("User")

    local __a = string.sub(text,1,5)
    local __b = string.sub(text,6,string.len(text))


    printInfo("==> channelId %d", channelId)
    printInfo("==> user_id %d", user_id)
    printInfo("==> nickname %s", nickname)
    printInfo("==> gender %d", gender)
    printInfo("==> timestamp %d", timestamp)
    printInfo("==> text %s", text)


    --[[
    if __a == "#001-" then
        APP:getCurrentController():showMessageAnim(user_id, __b)

        table.insert(info._userIds, user_id)
    elseif __a == "#002-" then
        APP:getCurrentController():showAvatarAnim(__b)

    elseif __a == "#003-" then

        local __b = string.sub(text,8,string.len(text))
        local __c = string.sub(text,6,6)
        APP:getCurrentController():showMessage(user_id, __b)

        GameUtils.playSound("audio/msg/fix_msg_"..__c..".mp3") 
    else

        APP:getCurrentController():showMessage(user_id, text)

        local _width = self._width / 2 - 100 + self._dx

        table.insert(info._userIds, user_id)

        local listView = self:getListView(channelId)

        local x, y = listView.container:getPosition()
        local height = listView.container:getCascadeBoundingBox().height
        -- printInfo("lastPos %f %f %f", x, y, height)

        if nickname == "" then
            nickname = "系统"
        end
        -- 第一排 名字
        local item = listView:newItem()
        item:setCascadeOpacityEnabled(true)
        local dcontent = display.newNode()
        if user.user_id ~= user_id then
            local content = cc.ui.UILabel.new({
                text = "    " .. z.StringUtility:truncate(nickname, 15, ""),
                size = 22,
                color = cc.c3b(180, 220, 230),
                align = cc.ui.TEXT_ALIGN_LEFT,
                valign = cc.ui.TEXT_VALIGN_TOP,
                -- dimensions = cc.size(self._width - 120, 0)
                })
                :align(display.LEFT_TOP, -_width - 20, 10)
                :addTo(dcontent)
        end
        item:setItemSize(self._width, 26 + 35)
        item:addContent(dcontent)

        --chatin_line.png

        -- if user_id <= 0 then
        --     display.newSprite("image/chips_s_5.png")
        --         :align(display.LEFT_CENTER, 8, item.height - content:getContentSize().height/2 - 2)
        --         :scale(0.8)
        --         :addTo(item)
        -- elseif gender ~= GameConfig.Gender_Female then
        --     display.newSprite("image/chips_s_2.png")
        --         :align(display.LEFT_CENTER, 8, item.height - content:getContentSize().height/2 - 2)
        --         :scale(0.8)
        --         :addTo(item)
        -- else
        --     display.newSprite("image/chips_s_3.png")
        --         :align(display.LEFT_CENTER, 8, item.height - content:getContentSize().height/2 - 2)
        --         :scale(0.8)
        --         :addTo(item)
        -- end
        cc.ui.UILabel.new({
            text = os.date("%m.%d %H:%M:%S", timestamp),
            size = 22,
            color = cc.c3b(180, 220, 230),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            valign = cc.ui.TEXT_VALIGN_TOP,
            })
            :align(display.RIGHT_TOP, _width - 25, 10)
            :addTo(dcontent)
        if #listView.items_ ~= 0 then
            display.newScale9Sprite("#mj_lt_line.png", 0, 0, 
                cc.size(self._width-38, 2), 
                cc.rect(5, 2, 1, 1))
                :align(display.CENTER, _width -10, 45)
                :addTo(item)
        end
        listView:addItem(item)
        
        -- 第二排 内容
        local item = listView:newItem()
        item:setCascadeOpacityEnabled(true)

        dcontent = display.newNode()

        -- local content = cc.ui.UILabel.new({
        --     text = text,
        --     size = 28,
        --     color = cc.c3b(65, 55, 50),
        --     align = cc.ui.TEXT_ALIGN_LEFT,
        --     valign = cc.ui.TEXT_VALIGN_TOP,
        --     -- dimensions = cc.size(345, 0)
        -- })

        -- if content:getContentSize().width > 345 then
        --     content = cc.ui.UILabel.new({
        --             text = text,
        --             size = 28,
        --             color = cc.c3b(65, 55, 50),
        --             align = cc.ui.TEXT_ALIGN_LEFT,
        --             valign = cc.ui.TEXT_VALIGN_TOP,
        --             dimensions = cc.size(345, 0)
        --     })
        -- end
            
        -- item:setItemSize(self._width, content:getContentSize().height + 25)
        -- local textContent
        -- if user.user_id ~= user_id then
        --     textContent = display.newScale9Sprite("image/chatin_msg_bg_1.png", 0, 0, 
        --         cc.size(content:getContentSize().width + 45, content:getContentSize().height + 30), 
        --         cc.rect(40, 20, 5, 5))
        --         :align(display.LEFT_TOP, -_width, 
        --             content:getContentSize().height / 2 + 22)
        --         :addTo(dcontent)
        --     content:align(display.LEFT_TOP, 15, content:getContentSize().height + 10)
        --         :addTo(textContent)  
        -- else
        --     textContent = display.newScale9Sprite("image/chatin_msg_bg_2.png", 0, 0, 
        --         cc.size(content:getContentSize().width + 45, content:getContentSize().height + 30), 
        --         cc.rect(10, 10, 5, 5))
        --         :align(display.RIGHT_TOP, _width-15, 
        --             content:getContentSize().height / 2 + 22)
        --         :addTo(dcontent)
        --     content:align(display.LEFT_TOP, 15, content:getContentSize().height + 15)
        --         :addTo(textContent)        
        -- end

        local _align
        local ___pos
        local _isMe
        if user.user_id ~= user_id then
            _align = display.TOP_LEFT
            _isMe = false
        else
            _align = display.TOP_RIGHT
            _isMe = true
        end

        local params = 
        {
            text = text,
            align = _align,
            isMe = _isMe,
            isMusic = false,
        }

        local _cont = APP:createView("MessagePopNode",params)
           :addTo(dcontent,30)

        if user.user_id ~= user_id then
            ___pos = cc.p(-180, _cont:getHeight()/2)
        else
            ___pos = cc.p(180, _cont:getHeight()/2)
        end
        _cont:align(display.CENTER, ___pos.x, ___pos.y)

        item:setItemSize(self._width, _cont:getHeight()+30)
        item:addContent(dcontent)
        listView:addItem(item)

        listView:reload()

        local newheight = listView.size.height
        -- printInfo("-------------- %f %f %f", height, newheight, self._height)
        if newheight >= self._height then
            listView.container:setPosition(cc.p(x, 0))
        else
            listView.container:setPosition(cc.p(x, self._height - newheight))
        end
    end
    --]]--
end

function TableMessagesNode:switchAutoPlayAudio()
    -- 切换开关
    local localDataManager = z.LocalDataManager:getInstance()
    local swAutoPlayAudio = localDataManager:getIntegerForKey(GameConfig.LocalData_SW_AutoPlayAudio)
    if swAutoPlayAudio == GameConfig.SW_DEFAULT or swAutoPlayAudio == GameConfig.SW_ON then
        localDataManager:setIntegerForKey(GameConfig.LocalData_SW_AutoPlayAudio, GameConfig.SW_OFF)
        self._switchButton:setButtonSelected(false)
    else
        localDataManager:setIntegerForKey(GameConfig.LocalData_SW_AutoPlayAudio, GameConfig.SW_ON)
        self._switchButton:setButtonSelected(true)
    end
    localDataManager:flush()

    -- 切换开关时，把队列中的语音全部清除
    z.AudioPlayManager:getInstance():clear()
end

function TableMessagesNode:loadingAudio(url)
    local info = self._info
    if info._audios[url] then
        info._audios[url].loading:show()
    end
end

function TableMessagesNode:finishLoadingAudio(url)
    local info = self._info
    if info._audios[url] then
        info._audios[url].loading:hide()
    end
end

function TableMessagesNode:playingAudio(url)
    local info = self._info
    if info._audios[url] then
        info._audios[url].play:hide()
        info._audios[url].playing:show()
    end
end

function TableMessagesNode:finishPlayingAudio(url)
    local info = self._info
    if info._audios[url] then
        info._audios[url].play:show()
        info._audios[url].playing:hide()
        info._audios[url].bubble_notplayed:hide()
        info._audios[url].bubble_played:show()
    end
end

function TableMessagesNode:playAudioFailed(url)
    self:finishLoadingAudio(url)
end

function TableMessagesNode:handleTouch(event)
    if event.name == "began" then
    elseif event.name == "ended" then
    elseif event.name == "clicked" then
        if event.itemPos then
            -- dump(event.itemPos)
            -- local user = APP:getObject("User")
            -- local index = math.ceil(event.itemPos / 2)
            -- local info = self._info
            -- if info._userIds[index] and info._userIds[index] > 0 and info._userIds[index] ~= user._user.user_id then
            --     APP:command("GetProfileCommand", {user_id = info._userIds[index]})
            --     APP:getCurrentController():showWaiting()
            -- end
        end
    end
end

function TableMessagesNode:getListView(channelId)
    return self._chatListViewWorld
end

function TableMessagesNode:displayRecording(dt)
    self._recordSec = self._recordSec + dt
    if self._recordSec < 1.5 then
        self._recordTimeLabel:setString(string.format("%.1f秒", self._recordSec))
        self._recordTimeLabel:setColor(cc.c3b(255, 0, 0))
        self._recordTooShortLabel:setVisible(true)
    else
        self._recordTimeLabel:setString(string.format("%.1f秒", self._recordSec))
        self._recordTimeLabel:setColor(cc.c3b(255, 255, 0))
        self._recordTooShortLabel:setVisible(false)
    end

    local volume = GameUtils.getRecordVolume()
    local index = 1
    if volume >= 0.8 then
        index = 4
    elseif volume >= 0.7 then
        index = 4
    elseif volume >= 0.6 then
        index = 3
    elseif volume >= 0.5 then
        index = 3
    elseif volume >= 0.4 then
        index = 2
    elseif volume >= 0.3 then
        index = 2
    elseif volume >= 0.2 then
        index = 2
    elseif volume >= 0.1 then
        index = 1
    else
        index = 1
    end
    
    if index ~= self._lastVolumeIndex then
        self._lastVolumeIndex = index
        if self._recordLowPassSprite then
            self._recordLowPassSprite:removeFromParent()
        end
        self._recordLowPassSprite = display.newSprite(string.format("image/chatin_record_%d.png", index))
                                        :pos(96, 118)
                                        :addTo(self._recordSprite)
    end
end

function TableMessagesNode:removeRecording()
    self:unscheduleUpdate()

    if self._recordTimeLabel then
        self._recordTimeLabel:removeFromParent()
        self._recordTimeLabel = nil
    end

    if self._recordLowPassSprite then
        self._recordLowPassSprite:removeFromParent()
        self._recordLowPassSprite = nil
    end

    if self._recordSprite then
        self._recordSprite:removeFromParent();
        self._recordSprite = nil
    end

    self._recordSec = 0
end



function TableMessagesNode:showTableMessageTip(user_id, text)
    local GlobalStatus = APP:getObject("GlobalStatus")
    local gameTable = GlobalStatus:getGameTable()
    local players = gameTable._players
    local selfPlayer = gameTable:getSelfPlayer()
    local sendSeatId = nil
    local _br_isMe = false
    
    
    for _,v in pairs(players) do
        if v._user.user_id == user_id then
            sendSeatId = v._seatId
        end
    end

    -- if sendSeatId == nil then
    --     return 
    -- end

    

end


function TableMessagesNode:chooseTab(idx)
    self._tabSpA:removeSelf()
    self._tabSpB:removeSelf()
    self._tabSpC:removeSelf()

    self._contA:removeAllChildren()
    self._contB:removeAllChildren()
    self._contC:hide()

    if idx == 1 then

        self._tabSpA = display.newSprite("#mj_lt_btn1_2.png")
            :align(display.CENTER, 444, 486)
            :addTo(self._backSprite, 2)

        self._tabSpB = display.newSprite("#mj_lt_btn2_1.png")
            :align(display.CENTER, 444, 326)
            :addTo(self._backSprite, 2)

        self._tabSpC = display.newSprite("#mj_lt_btn3_1.png")
            :align(display.CENTER, 444, 162)
            :addTo(self._backSprite, 2)

        display.newSprite("#mj_lt_btn_bg.png")
            :align(display.CENTER, 34, 34)
            :addTo(self._tabSpA, 2)

        -------------------------------------------------------

        if sp.SkeletonAnimation then

            for i=1,8 do
                local _voa, _vob = i%3, 0
                if _voa == 0 then
                    _voa = 3 
                    _vob = math.floor((i-1)/3)
                else
                    _vob = math.floor(i/3)
                end
                
                cc.ui.UIPushButton.new("image/white_unit.png", {scale9 = true})
                    :opacity(0)
                    :setButtonSize(120, 120)
                    :onButtonClicked(function(event) 
                        -- print("..", i)
                        GameUtils.playSound("audio/button.mp3") 
                        self._chatCB(protocols.message_pb.MESSAGE_TYPE_TABLE_TEXT, "#001-"..i)
                        self._backSprite:hide()
                        -- self._backSprite:runAction(cca.seq({
                        --     cca.moveTo(0.2, display.width + 100, 100), 
                        --     cca.cb(function() 
                        --         self._backSprite:hide()
                        --         self:zorder(10)
                        --     end)
                        -- }))

                    end)
                    :align(display.CENTER, -41+122*_voa, 488-122*_vob)
                    :addTo(self._contA, 1)

                
                sp.SkeletonAnimation:create("effect/majiangbiaoqing.json", "effect/majiangbiaoqing.atlas")
                    :align(display.CENTER, -41+122*_voa-44, 488-122*_vob-44)
                    :scale(0.5)
                    :addTo(self._contA, 1)
                    :setAnimation(0, i.."-ssd", true);

            end

        else
            cc.ui.UILabel.new({
                text = "如需使用表情",
                size = 30,
                color = cc.c3b(187,253,253),
                align = cc.ui.TEXT_ALIGN_LEFT,
                valign = cc.ui.TEXT_VALIGN_CENTER,
                })
                :align(display.CENTER, 208,450)
                :addTo(self._contA, 1)

            cc.ui.UILabel.new({
                text = "请获取最新版本",
                size = 30,
                color = cc.c3b(187,253,253),
                align = cc.ui.TEXT_ALIGN_LEFT,
                valign = cc.ui.TEXT_VALIGN_CENTER,
                })
                :align(display.CENTER, 208,400)
                :addTo(self._contA, 1)

            
        end

        

        -- 

    elseif idx == 2 then

        self._tabSpA = display.newSprite("#mj_lt_btn1_1.png")
            :align(display.CENTER, 444, 486)
            :addTo(self._backSprite, 2)

        self._tabSpB = display.newSprite("#mj_lt_btn2_2.png")
            :align(display.CENTER, 444, 326)
            :addTo(self._backSprite, 2)

        self._tabSpC = display.newSprite("#mj_lt_btn3_1.png")
            :align(display.CENTER, 444, 162)
            :addTo(self._backSprite, 2)

        display.newSprite("#mj_lt_btn_bg.png")
            :align(display.CENTER, 34, 31)
            :addTo(self._tabSpB, 2)

        ----------------------------------------------------
        self._wordsCfg ={}
        self._wordsCfg = {
                "#003-1-快点啊, 都等得我花儿都谢了",
                "#003-2-怎么又断线了, 网络怎么又这么差呀",
                "#003-3-不要走, 决战到天亮啊",
                "#003-4-你丫的, 打的牌也忒好了",
                "#003-5-你是妹妹, 还是哥哥啊?",
                "#003-6-和你合作真是太愉快了吖",
                "#003-7-大家好, 很高兴见到各位",
                "#003-8-各位, 真是不好意思吖, 我得离开一会儿",
                "#003-9-不要吵了, 不要吵了, 吵撒么吵嘛, 专心玩游戏吧",
            }

        for i=1,8 do
            if i < 8 then
                display.newScale9Sprite("#mj_lt_line.png", 0, 0, 
                    cc.size(380, 4), 
                    cc.rect(5, 2, 1, 1))
                    :align(display.LEFT_BOTTOM, 10, 550-58*i)
                    :addTo(self._contB, 1)
            end
            cc.ui.UIPushButton.new("image/white_unit.png", {scale9 = true})
                :opacity(0)
                :setButtonSize(380, 52)
                :onButtonClicked(function(event) 
                    GameUtils.playSound("audio/button.mp3") 
                    self._chatCB(protocols.message_pb.MESSAGE_TYPE_TABLE_TEXT, self._wordsCfg[i])
                    self._backSprite:hide()
                    -- self._backSprite:runAction(cca.seq({
                    --     cca.moveTo(0.2, display.width + 100, 100), 
                    --     cca.cb(function() 
                    --         self._backSprite:hide()
                    --         self:zorder(10)
                    --     end)
                    -- }))

                end)
                :align(display.LEFT_BOTTOM, 10, 550-58*(i)+4)
                :addTo(self._contB, 1)

            local __b = string.sub(self._wordsCfg[i],8,string.len(self._wordsCfg[i]))
            cc.ui.UILabel.new({
                text = z.StringUtility:truncate(__b, 11, "..."),
                size = 30,
                color = cc.c3b(187,253,253),
                align = cc.ui.TEXT_ALIGN_LEFT,
                valign = cc.ui.TEXT_VALIGN_CENTER,
                })
                :align(display.LEFT_BOTTOM, 20, 550-58*(i)+14)
                :addTo(self._contB, 1)
        end



    elseif idx == 3 then

        self._tabSpA = display.newSprite("#mj_lt_btn1_1.png")
            :align(display.CENTER, 444, 486)
            :addTo(self._backSprite, 2)

        self._tabSpB = display.newSprite("#mj_lt_btn2_1.png")
            :align(display.CENTER, 444, 326)
            :addTo(self._backSprite, 2)

        self._tabSpC = display.newSprite("#mj_lt_btn3_2.png")
            :align(display.CENTER, 444, 162)
            :addTo(self._backSprite, 2)

        display.newSprite("#mj_lt_btn_bg.png")
            :align(display.CENTER, 34, 31)
            :addTo(self._tabSpC, 2)

        self._contC:show()
    end

end






return TableMessagesNode