local protocols = require("app.protocol.init")
local GameConfig = require("app.core.GameConfig")
local GameUtils = require("app.core.GameUtils")
local GameEnv = require("app.core.GameEnv")
local HttpManager = require("app.core.HttpManager")
local RegisterView = class("RegisterView", function()
    return display.newNode()
end)

function RegisterView:ctor()
    -- 背景
    self._loginRememberYesSp = nil

    
    if device.platform == "mac" then
        self:initUI()
    else
        if GameEnv.Current == GameEnv.DEV then
            self:initUI()
        elseif device.platform == "ios" then
           self:sendRequest()
        elseif device.platform == "android" then
            -- self:initUI2()
        end
    end
end

function RegisterView:sendRequest()
    local body = json.encode({})
    local request = z.CurlManager:getInstance():sendCommandForLua(
        HttpManager:urlGetFreeClientVersion(), GameConfig.METHOD_POST, body)
    GameUtils.registerHttpHandler(request, handler(self, RegisterView.getVersionCallback)) 
end

function RegisterView:getVersionCallback(request)
    if request:getCode() ~= 0 then 
    	self:runAction(cca.seq({cca.delay(1.0),
    		cca.cb(function() self:sendRequest() end)}))    	
        return 
    end	

    local response = json.decode(request:getResult())

    local globalStatus = APP:getObject("GlobalStatus")
    globalStatus:setProperties({
        free_client_version = response.data.version,
    }) 
    dump( "client version:" .. GameConfig.Version)
    dump( "server client version:" .. response.data.version)
    if response.data.version >= GameConfig.Version then
		  self:initUI2()
    elseif device.platform == "ios" then
    	self:initUI()
    end    
end


function RegisterView:initUI()
	local localDataManager = z.LocalDataManager:getInstance()

	local user_type = localDataManager:getIntegerForKey(GameConfig.LocalData_UserType)
    local account = localDataManager:getStringForKey(GameConfig.LocalData_Account)
    local password = localDataManager:getStringForKey(GameConfig.LocalData_Password)
    local saveAccont = localDataManager:getIntegerForKey(GameConfig.LocalData_SaveAccount)

    local content = display.newNode()
      :addTo(self)
    content:scale(math.min(1, display.width / 1334))

    

	-- 账号输入框背景

    self._account = APP:createView("UIInputFixed", {
        image = display.newScale9Sprite("image/white_unit.png"),
        -- image = display.newScale9Sprite("image/transparent_unit.png"),
        size = cc.size(350, 55),--55
    })
    self._account:align(display.LEFT_CENTER, display.cx+60, display.cy+173)
    self._account:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._account:setPlaceHolder("请输入账号")
    self._account:setPlaceholderFontColor(cc.c3b(210, 210, 210))
    self._account:setFontColor(cc.c3b(50, 50, 50))
    self._account:setText("")
    self._account:setCascadeOpacityEnabled(true)
    self._account:addTo(content)



    -- 密码输入框背景

	self._password = APP:createView("UIInputFixed", {
        image = display.newScale9Sprite("image/white_unit.png"),
        -- image = display.newScale9Sprite("image/transparent_unit.png"),
        size = cc.size(350, 55),
    })
    self._password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self._password:align(display.LEFT_CENTER, display.cx+60, display.cy+63)
    self._password:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._password:setPlaceHolder("请输入密码")
    self._password:setPlaceholderFontColor(cc.c3b(210, 210, 210))
    self._password:setFontColor(cc.c3b(50, 50, 50))
    self._password:setText("")
    self._password:setCascadeOpacityEnabled(true)
    self._password:addTo(content)

   

	--  login
    local btnImage = 
		{
		    normal = "image/login_button_login.png",
		    pressed = "image/login_button_login.png",
		}
	cc.ui.UIPushButton.new(btnImage)
        :onButtonPressed(function(event) event.target:scale(1.1) end)
        :onButtonRelease(function(event) event.target:scale(1) end)
		:onButtonClicked(function()
			print("login_button_login")
			
			local account = self._account:getText()
            local password = self._password:getText()

            -- account = "TestA"
            -- password = "user@123"
            print("===========account > ", account)
            print("===========password > ", password)
            if account == "" then
                APP:getCurrentController():showAlertOK({desc = "账号不能为空"})
                return
            end
            if password == "" then
                APP:getCurrentController():showAlertOK({desc = "密码不能为空"})
                return
            end

            APP:getCurrentController():showWaiting()

            self:runAction(cca.seq({
            	cca.delay(0.1),
            	cca.cb(function() 
		            local GlobalStatus = APP:getObject("GlobalStatus")
		            GlobalStatus:setProperties({
			            account = account,
			            user_type = 0,
			            password = password,
			            is_auto_login = 0,
			        })
			        local SocketManager = require("app.core.SocketManager")
		            SocketManager.connect()
            	end),
            }))
		end)
		:align(display.CENTER, display.cx+60, display.cy-140)
		:addTo(content)


	--  reg
    local btnImage = 
		{
		    normal = "image/login_button_register.png",
		    pressed = "image/login_button_register.png",
		}
	self._registerButton = cc.ui.UIPushButton.new(btnImage)
        :onButtonPressed(function(event) event.target:scale(1.1) end)
        :onButtonRelease(function(event) event.target:scale(1) end)
		:onButtonClicked(function()
			print("login_button_register")
			if APP:isObjectExists("RegiseterController") then
		        local RegiseterController = APP:getObject("RegiseterController")
		        


		    end
		end)
		:align(display.CENTER, display.cx+380, display.cy-140)
		:addTo(content)
	
	

end















return RegisterView