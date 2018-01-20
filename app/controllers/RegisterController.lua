--
-- Author: gerry
-- Date: 2016-01-11 16:17:51
--
local protocols = require("app.protocol.init")
local ControllerBase = require("app.controllers.ControllerBase")
local GameConfig = require("app.core.GameConfig")
local GameUtils = require("app.core.GameUtils")
local HttpManager = require("app.core.HttpManager")
local scheduler = require("framework.scheduler")
local SocketManager = require("app.core.SocketManager")

local RegiseterController = class("RegiseterController", ControllerBase)

function RegiseterController:ctor()
	RegiseterController.super.ctor(self)
    -- print("--------------w ", display.width)
    -- print("--------------h ", display.height)

    -- local GlobalStatus = APP:getObject("GlobalStatus")
    -- local localDataManager = z.LocalDataManager:getInstance()

    -- local account = localDataManager:getStringForKey(GameConfig.LocalData_Account)
    -- local password = localDataManager:getStringForKey(GameConfig.LocalData_Password)
    -- local user_type = localDataManager:getIntegerForKey(GameConfig.LocalData_UserType)
    -- local refreshToken = localDataManager:getStringForKey(GameConfig.LocalData_WEI_XIN_REFRESH_TOKEN)
    -- local refreshDate = localDataManager:getStringForKey(GameConfig.LocalData_WEI_XIN_REFRESH_TIME)

    if device.platform == "mac" then

    elseif device.platform == "ios" then
        self:showWaiting()
        z.IOSManager:getInstance():GameCenterLogin();
    end

--[[--
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
    if account ~= "" and password ~= "" and GlobalStatus:getAutoLogin() == 0 then
        if refreshToken and refreshToken ~= "" then
            self:showWaiting()
            if refreshDate ~= utils.timeStrDate() then
                self:runAction(cca.seq({cca.delay(0.2), cca.cb(function() 
                    local command = require("app.commands.WeixinInfoCommand")
                    command.execute(refreshToken) 
                end)}))
            else
                GlobalStatus:setProperties({
                    account = account,
                    user_type = user_type,
                    password = password,
                })
                local SocketManager = require("app.core.SocketManager")
                SocketManager.connect() 
            end

        elseif device.platform == "mac" then
            self:showWaiting()
            GlobalStatus:setProperties({
                account = account,
                user_type = user_type,
                password = password,
            })
            local SocketManager = require("app.core.SocketManager")
            SocketManager.connect() 
        end        
    end    
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--]]--


    -- if SocketManager.getStatus() == SocketManager.S_CONNECTED then
    --     -- auth
    -- else
    --     SocketManager.connect()
    -- end

    -- setting
    -- local _isRightHand = localDataManager:getIntegerForKey("isRightHand", 1)
    -- GlobalStatus.is_right_hand_ = _isRightHand == 1 or false
    -- local _isFanSanZhang = localDataManager:getIntegerForKey("isFanSanZhang", 0)
    -- GlobalStatus.is_fan_san_zhang_ = _isFanSanZhang == 1 or false
    -- local _isMusic = localDataManager:getIntegerForKey("isMusic", 1)
    -- GlobalStatus.is_music_ = _isMusic == 1 or false



    -- 
    -- local _loginBg = display.newSprite("image/sel.png")
    --     :align(display.CENTER, display.cx, display.cy+50)
    --     :addTo(self, 1)

    -----test
    -- self:runAction(cca.seq({
    --             cca.delay(0.1),
    --             cca.cb(function()
    --                     APP:enterScene("GameScene")
    --                 end),
    --         }))
    

    -- local _loginBg = display.newSprite("image/b.png")
    --     :align(display.CENTER, display.cx, display.cy-150)
    --     :addTo(self, 1)


    --tts
    -- display.addSpriteFrames("image/mj_mahjong_tile_new.plist", "image/mj_mahjong_tile_new.png")

    -- local _Sc = 0.6
    -- local _dx = 88*_Sc

    -- for i=1,7 do
    --     local _vo = display.newSprite("#mj_cardbg_me_front_"..i..".png")
    --         :align(display.CENTER, display.cx-300+_dx*(i-1), display.cy+150)
    --         :scale(_Sc)
    --         :addTo(self, 1)

    --     local _voo = display.newSprite("#mj_cardnum_mahjong_"..(i+20)..".png")
    --         :align(display.CENTER, display.cx-300+_dx*(i-1), display.cy+162)
    --         :scale(_Sc-0.1)
    --         :addTo(self, 1)

    --     local _rwo = math.pow(0.67, i-1)*17
    --     print("------------", _rwo)
    --     _voo:setSkewX(_rwo)

    -- end
    -- local _idx = 7
    -- local _ii = 0
    -- for i=1,6 do
    --     _idx = _idx+1
    --     _ii = _ii+1
    --     local _vo = display.newSprite("#mj_cardbg_me_front_"..(7-i)..".png")
    --         :align(display.CENTER, display.cx-300+2+_dx*(_idx-1), display.cy+150)
    --         :addTo(self, 1)
    --     _vo:setScaleX(-_Sc)
    --     _vo:setScaleY(_Sc)
    --     _vo:setLocalZOrder(7-i)

    --     local _voo = display.newSprite("#mj_cardnum_mahjong_"..(i+20)..".png")
    --         :align(display.CENTER, display.cx-300+2+_dx*(_idx-1), display.cy+162)
    --         :scale(_Sc-0.1)
    --         :addTo(self, 11)

    --     local _rwo = math.pow(0.67, 6-i)*17*(-1)
    --     _voo:setSkewX(_rwo )
    -- end


    -- for i=1,5 do
    --     display.newSprite("#mj_cardbg_me_chupai_"..i..".png")
    --         :align(display.CENTER, display.cx-300+64*(i-1), display.cy+50)
    --         :addTo(self, 1)

    --     local _voo = display.newSprite("#mj_cardnum_mahjong_"..(i+20)..".png")
    --         :align(display.CENTER, display.cx-300+64*(i-1), display.cy+66)
    --         :scale(0.55)
    --         :addTo(self, 1)

    --     local _rwo = math.pow(0.67, i-1)*4
    --     print("------------", _rwo)
    --     _voo:setSkewX(_rwo)
    --     _voo:setSkewY(0.2)
    -- end

    -- sp.SkeletonAnimation:create("image/majiangbiaoqing.json", "image/majiangbiaoqing.atlas")
    --     :align(display.CENTER, display.cx, display.cy+150)
    --     :addTo(self, 1)
    --     :setAnimation(0, "2-yingqian", true);

    -- sp.SkeletonAnimation:create("image/majiangbiaoqing.json", "image/mj_bq_zong.atlas")
    --     :align(display.CENTER, display.cx-200, display.cy+150)
    --     :addTo(self, 1)
    --     :setAnimation(0, "2-yingqian", true);

end



function RegiseterController:onEnter()
	RegiseterController.super.onEnter(self)
	--SocketManager.unblockMessage()

	local localDataManager = z.LocalDataManager:getInstance()
    if localDataManager:getIntegerForKey(GameConfig.LocalData_AppEverOpened) == 0 then
        -- 全局初始化
        local localDataManager = z.LocalDataManager:getInstance()
        localDataManager:setIntegerForKey(GameConfig.LocalData_AppEverOpened, 1)
        localDataManager:setIntegerForKey(GameConfig.LocalData_SaveAccount, 1)
        localDataManager:flush()

    end

    -- APP:createView("RegisterView")
    --     :addTo(self)
end

function RegiseterController:onExit()
    print("···RegiseterController:onExit")
    RegiseterController.super.onExit(self)
end




return RegiseterController