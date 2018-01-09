
local GameUtils = require("app.core.GameUtils")
local GameConfig = require("app.core.GameConfig")
local HttpManager = require("app.core.HttpManager")
local json = require("framework.json")
local protocols = require("app.protocol.init")

local PayManager = {}

function PayManager.init()
    -- 取一个全局共享node当绑定载体
    local node = cc.Director:getInstance():getNotificationNode()
    
    GameUtils.registerScriptHandler(node, PayManager.onNoProduct,
        GameConfig.Handler.EVENT_CHANNEL_IAP_NO_PRODUCT)
    GameUtils.registerScriptHandler(node, PayManager.onPayFailed,
        GameConfig.Handler.EVENT_CHANNEL_IAP_PAY_FAILED)
    GameUtils.registerScriptHandler(node, PayManager.onPayCanceled,
        GameConfig.Handler.EVENT_CHANNEL_IAP_PAY_CANCELED)
    GameUtils.registerScriptHandler(node, PayManager.onPaySucc,
        GameConfig.Handler.EVENT_CHANNEL_IAP_PAY_SUCCESS)
    GameUtils.registerScriptHandler(node, PayManager.onPaySuccStep,
        GameConfig.Handler.EVENT_CHANNEL_IAP_PAY_SUCCESS_STEP)
end

function PayManager.onNoProduct(productId)
    printInfo("[PayManager] ---------> onNoProduct: %s", productId)
    APP:getCurrentController():hideWaiting()
    APP:getCurrentController():showAlertOK({
        desc = "找不到指定的商品"
    })
end

function PayManager.onPayFailed(productId)
    printInfo("[PayManager] ---------> onPayFailed: %s", productId)
    APP:getCurrentController():hideWaiting()
    APP:getCurrentController():showAlertOK({
        desc = "支付失败"
    })
end

function PayManager.onPayCanceled(productId)
    printInfo("[PayManager] ---------> onPayCanceled: %s", productId)
    APP:getCurrentController():hideWaiting()
    APP:getCurrentController():showAlertOK({
        desc = "支付已取消"
    })
end

function PayManager.onPaySucc(data)
    printInfo("[PayManager] ---------> onPaySucc: %s", data)
    APP:getCurrentController():hideWaiting()
    -- TODO
end

function PayManager.onPaySuccStep(data)
    printInfo("[PayManager] ---------> onPaySuccStep: %s", data)

    if device.platform == "ios" then
        PayManager.onPaySuccStepIOS(data)
    end
end

function PayManager.onPaySuccStepIOS(data)
    local dataObject = json.decode(data)
    local globalStatus = APP:getObject("GlobalStatus")
    local body = json.encode({
        user_id = globalStatus:getUserId(), 
        sign = crypto.md5(globalStatus:getUserId() .. "_" .. globalStatus:getPassword() .. "_" .. GameConfig.Pay_Token),
        transaction_id = dataObject.transaction_id,
        receipt = dataObject.receipt_data,
    })
    local request = z.CurlManager:getInstance():sendCommandForLua(
        HttpManager:urlIOSPay(), GameConfig.METHOD_POST, body)
    GameUtils.registerHttpHandler(request, PayManager.paySuccStepCallback)
end

function PayManager.paySuccStepCallback(request)
    
    APP:getCurrentController():hideWaiting()

    if request:getCode() ~= 0 then 
        PayManager.paySuccStepFailed(request:getCode())
        return
    end
    
    local response = json.decode(request:getResult())
    if response.code ~= protocols.Protocol.CODE_SUCCESS then
        PayManager.paySuccStepFailed(response.code)

        -- 支付失败且非服务器内部错误：关闭订单
        if device.platform == "ios" and response.code ~= protocols.Protocol.CODE_ERROR_INTERNAL_ERROR then
            z.IOSManager:getInstance():finishTransaction(z.IOSManager:getInstance():getTransactionId())
        end
        return
    end

    printInfo("[PayManager] pay succ step succ, [product_id|%s] [plus_coin|%d] [coin|%d]", 
        response.data.product_id, response.data.plus_coin, response.data.coin)

    local globalStatus = APP:getObject("GlobalStatus")
    local product = globalStatus:getProductById(response.data.product_id)
    local price = 6
    if product ~= nil then
        price = product.price
    end
    -- 支付成功：关闭订单
    if device.platform == "ios" then
        z.IOSManager:getInstance():finishTransaction(response.data.transaction_id)
    end

    local desc = string.format("您购买的%d金币已经成功", response.data.plus_coin)
    APP:getCurrentController():showAlertOK({desc = desc})

    -- save
    local user = APP:getObject("User")
    user.coin = response.data.coin
    user.vip_level = response.data.vip_level
    user.vip_exp = response.data.vip_exp    

    -- 统计
    if device.platform == "ios" or device.platform == "android" then
        z.MobClickCpp:pay(price, GAME_PLATFORM, response.data.plus_coin)
    end

    -- 刷新界面
    PayManager.updateViews()
end

function PayManager.paySuccStepFailed(code)
    local code = code or -1
    printInfo("[PayManager] ---------> paySuccStepFailed: %d", code)
end

function PayManager.updateViews()
    if APP:isObjectExists("HomeController") then
        APP:getObject("HomeController"):refreshUserInfo()
    end 
end

return PayManager