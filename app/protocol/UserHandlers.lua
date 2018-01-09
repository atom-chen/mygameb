local GameConfig = require("app.core.GameConfig")
local GameUtils = require("app.core.GameUtils")
local protocols = require("app.protocol.init")
local Protocol = protocols.Protocol
local models = require("app.models.init")
local UserHandlers = {}

UserHandlers.poorNotify = {}

function UserHandlers.isUserMessage(type)
    
    return false    
end

function UserHandlers.handlePing(payload)
    -- local response = protocols.base_pb.ReadyResponse()
    -- response:ParseFromString(payload)

    -- printInfo("code %d", response.code)
end

function UserHandlers.handleEchoRsonse(payload)

end

function UserHandlers.handleAuthResponse(payload)
    local GlobalStatus = APP:getObject("GlobalStatus")
    local User = APP:getObject("User")
    local response = protocols.base_pb.AuthResponse()
    response:ParseFromString(payload)
    printInfo("code %d", response.code)

    
    if response.code == Protocol.CODE_SUCCESS then
        User:loadByPBBaseUser(response.base_user)
        
        printInfo("user_id %d", response.base_user.user_id)
        printInfo("name %s", response.base_user.name)
        printInfo("avatar %s", response.base_user.avatar)
        printInfo("signature %s", response.base_user.signature)
        printInfo("gender %d", response.base_user.gender)
        printInfo("coin %d", response.base_user.coin)
        printInfo("vip_level %d", response.base_user.vip_level)
        printInfo("score %d", response.base_user.score)
        printInfo("voice %s", response.base_user.voice)


        FSM:doEvent(FSM.E_AUTH)
        
        -- if GlobalStatus:getUserType() ~= protocols.defines_pb.UT_WX then
            local localDataManager = z.LocalDataManager:getInstance()
            localDataManager:setIntegerForKey(GameConfig.LocalData_UserType, GlobalStatus:getUserType())
            localDataManager:setStringForKey(GameConfig.LocalData_Account, GlobalStatus:getAccount())
            localDataManager:setStringForKey(GameConfig.LocalData_Password, GlobalStatus:getPassword())
            localDataManager:flush() 
        -- end

        -- 监听IOS支付需要在登录成功以后
        if device.platform == "ios" then
            z.IOSManager:getInstance():startListen()
        end

        -- 处理友盟统计
        if device.platform == "ios" or device.platform == "android" then
            -- z.MobClickCpp:setUserInfo(tostring(User.user_id), User.gender, 0, GameUtils.getChannel())
        end
    
    else
        APP:getCurrentController():hideWaiting()

        -- APP:getCurrentController():showAlertOK({desc = "登陆失败，账号密码不正确"})       
    end

    return response
end

function UserHandlers.handleNotifyKickedOff(payload)
    local GlobalStatus = APP:getObject("GlobalStatus")
    GlobalStatus:setProperties({
        is_auto_login = 1,
    })    
end

function UserHandlers.handleSetUserProfileResponse(payload)
    local response = protocols.base_pb.SetUserProfileResponse()
    response:ParseFromString(payload)

    local User = APP:getObject("User")

    if response.code == Protocol.CODE_SUCCESS then
        User:loadByPBBaseUser(response.base_user)

        if response:HasField("invite_user_id") then
            local GlobalStatus = APP:getObject("GlobalStatus")
            GlobalStatus.invite_user_id_ = response.invite_user_id
        end 

        if APP:isObjectExists("InviteNode") then
            APP:getObject("InviteNode"):setInviteUser()
        end 
    elseif response.code == 6 then
        if APP:isObjectExists("InviteNode") then
            APP:getCurrentController():showAlertOK({desc = "邀请人ID不存在！"}) 
        end    
    else
        if APP:isObjectExists("SelfPlayerProfile") then
            APP:getCurrentController():showAlertOK({desc = "该昵称已经被占用，请重新修改昵称"}) 
            APP:getObject("SelfPlayerProfile"):resetNickname()
        elseif APP:isObjectExists("InviteNode") then
            APP:getCurrentController():showAlertOK({desc = "邀请人填写失败"}) 
        end        
    end

    return response
end

function UserHandlers.handleReconnectGameResponse(payload)
    local response = protocols.base_pb.ReconnectGameResponse()
    response:ParseFromString(payload)   

    local MJTable = models.MJTable.new()
    local GlobalStatus = APP:getObject("GlobalStatus")
    if response:HasField("mtt_waiting_arrange") then
        GlobalStatus.mtt_id_ = response.mtt_waiting_arrange.mtt_id
        APP:enterScene("MttWaitingScene")
        return
    end
    if response.table.game_type == protocols.defines_pb.MJ_LI_YANG_HUA_2P
    or response.table.game_type == protocols.defines_pb.MJ_LI_YANG_HUA_4P then
        MJTable = models.MJLYTable.new()

        if response.code == Protocol.CODE_SUCCESS then
            SOCKET_MANAGER.blockMessage()
            
            GlobalStatus:setProperties({
                game_table = MJTable,
                game_type = response.table.game_type
            })
            MJTable:loadByPBBaseTable(response.table)

            MJTable._isReconnect = true
            APP:enterScene("MJLYGameScene")
        else

        end 
    elseif response.table.game_type == protocols.defines_pb.NIUNIU then
         MJTable = models.NNTable.new()

         if response.code == Protocol.CODE_SUCCESS then
            SOCKET_MANAGER.blockMessage()
            GlobalStatus:setProperties({
                game_table = MJTable,
                game_type = response.table.game_type
            })

            MJTable:loadByPBBaseTable(response.table)

            APP:enterScene("NNGameScene")
        else

        end 
    elseif response.table.game_type == protocols.defines_pb.GAN_DENG_YAN then
         MJTable = models.GDYTable.new()
         if response.code == Protocol.CODE_SUCCESS then
            SOCKET_MANAGER.blockMessage()
            GlobalStatus:setProperties({
                game_table = MJTable,
                game_type = response.table.game_type
            })

            MJTable:loadByPBBaseTable(response.table)
            MJTable._isReconnect = true

            APP:enterScene("GDYGameScene")
        else

        end  
    elseif response.table.game_type == protocols.defines_pb.DOU_DI_ZHU then
        MJTable = models.LandlordTable.new()
         if response.code == Protocol.CODE_SUCCESS then
            SOCKET_MANAGER.blockMessage()
            GlobalStatus:setProperties({
                game_table = MJTable,
                game_type = response.table.game_type
            })

            MJTable:loadByPBBaseTable(response.table)
            MJTable._isReconnect = true

            APP:enterScene("LandlordGameScene")
        else

        end       
    elseif response.table.game_type == protocols.defines_pb.BAI_REN_NIU_NIU then
        print("======------   protocols.defines_pb.BAI_REN_NIU_NIU")
         MJTable = models.BRNNTable.new()
         if response.code == Protocol.CODE_SUCCESS then
            SOCKET_MANAGER.blockMessage()
            GlobalStatus:setProperties({
                game_table = MJTable,
                game_type = response.table.game_type
            })

            MJTable:loadByPBBaseTable(response.table)
            MJTable._isReconnect = true

            APP:enterScene("BRNNGameScene")
        else

        end 
    elseif response.table.game_type == protocols.defines_pb.SUOHA then
        SHTable = models.SHTable.new()

        if response.code == Protocol.CODE_SUCCESS then
            SHTable:loadByPBBaseTable(response.table)
            SHTable._isReconnect = true
            GlobalStatus:setProperties({
                game_table = SHTable,
                game_type = response.table.game_type
            })

            APP:enterScene("SHGameScene")
        else

        end 
    elseif response.table.game_type == protocols.defines_pb.HUA_LUN then
        MJTable = models.HualunTable.new()

        if response.code == Protocol.CODE_SUCCESS then
            SOCKET_MANAGER.blockMessage()
            GlobalStatus:setProperties({
                game_table = MJTable,
                game_type = response.table.game_type
            })
            MJTable:loadByPBBaseTable(response.table)
            MJTable._isReconnect = true

            APP:enterScene("HualunGameScene")

        else

        end 

    elseif response.table.game_type == protocols.defines_pb.SI_FU_TOU then
        MJTable = models.SifutouTable.new()

        if response.code == Protocol.CODE_SUCCESS then
            SOCKET_MANAGER.blockMessage()
            GlobalStatus:setProperties({
                game_table = MJTable,
                game_type = response.table.game_type
            })
            MJTable:loadByPBBaseTable(response.table)
            MJTable._isReconnect = true
            APP:enterScene("SifutouGameScene")
        else

        end 

    end  

    return response
end

function UserHandlers.handleGetUsersResponse(payload)
    -- body
    local response = protocols.user_pb.GetUsersResponse()
    response:ParseFromString(payload) 

    APP:getCurrentController():hideWaiting()

    if response.option == 1 then 
        if 0 == #response.users then
            APP:getCurrentController():showAlertOK({desc = "找不到该用户，请重新查找"})
            return
        end
        APP:getCurrentController():showAlert(APP:createView("OtherPlayerProfileView", response.users[1]))
    elseif response.option == 2 then
        local globalStatus = APP:getObject("GlobalStatus")
        globalStatus.friend_users_ = response.users
        APP:getCurrentController():showAlert(APP:createView("FriendsView", response.users))
        return
    elseif response.option == 3 then
        if 0 == #response.users then
            APP:getCurrentController():showAlertOK({desc = "找不到该用户，请重新查找"})
            return
        end
        if APP:isObjectExists("BankView") then
            APP:getObject("BankView"):showNickSprite(response.users[1].name)
        end
    end
end

function UserHandlers.handleAddFriendResponse(payload)
    -- body
    local response = protocols.user_pb.AddFriendResponse()
    response:ParseFromString(payload) 

    if response.code ~= Protocol.CODE_SUCCESS then
        APP:getCurrentController():hideWaiting()
        APP:getCurrentController():showAlertOK({desc = "加好友失败，请稍后重新尝试"})
        return
    end

    local GlobalStatus = APP:getObject("GlobalStatus")
    local friends = GlobalStatus:getFriends()
    local friendUsers = GlobalStatus:getFriendUsers()
    table.insert(friends, response.user_id)
    table.insert(friendUsers, response.user)

    APP:getCurrentController():hideWaiting()

    if APP:isObjectExists("OtherPlayerProfileView") then
        APP:getObject("OtherPlayerProfileView"):reloadFriendButton()
    end

    if APP:isObjectExists("FriendsView") then
        APP:getObject("FriendsView"):reloadData()
    end
end

function UserHandlers.handleNotifyAddFriend(payload)
    -- body
end

function UserHandlers.handleDeleteFriendResponse(payload)
    -- body
    local response = protocols.user_pb.DeleteFriendResponse()
    response:ParseFromString(payload) 

    if response.code ~= Protocol.CODE_SUCCESS then
        APP:getCurrentController():hideWaiting()
        APP:getCurrentController():showAlertOK({desc = "加好友失败，请稍后重新尝试"})
        return
    end

    local GlobalStatus = APP:getObject("GlobalStatus")
    local friends = GlobalStatus:getFriends()
    local friendUsers = GlobalStatus:getFriendUsers()

    for i=1,#friends do
        if tonumber(friends[i]) == response.user_id then
            table.remove(friends,i)
            break
        end
    end
    for i=1,#friendUsers do
        -- printInfo("%d", friendUsers[i].user_id)
        if friendUsers[i].user_id == response.user_id then
            table.remove(friendUsers,i)
            break
        end
    end

    APP:getCurrentController():hideWaiting()

    if APP:isObjectExists("OtherPlayerProfileView") then
        APP:getObject("OtherPlayerProfileView"):reloadFriendButton()
    end
        if APP:isObjectExists("FriendsView") then
        APP:getObject("FriendsView"):reloadData()
    end
end

function UserHandlers.handleNotifyDeleteFriend(payload)
    -- body
end

function UserHandlers.handleMessageResponse(payload)
    local response = protocols.message_pb.MessageResponse()
    response:ParseFromString(payload)

    local user = APP:getObject("User")

    if response.code == Protocol.CODE_SUCCESS then
        if response.type == protocols.message_pb.MESSAGE_TYPE_PLAYER_TEXT or
            response.type == protocols.message_pb.MESSAGE_TYPE_PLAYER_VOICE then
            z.LocalMessagesManager:getInstance():addMessage(
                response.to_id, response.to_name, response.to_avatar,
                response.send_time, true, response.type, response.content)

            if APP:isObjectExists("MessagesView") then
                -- 刷新新消息
                APP:getObject("MessagesView"):newMessage(user.user_id, response.to_id)
            end
        elseif response.type == protocols.message_pb.MESSAGE_TYPE_TABLE_TEXT then
            if APP:isObjectExists("TableMessagesNode") then
                -- 刷新新消息
                APP:getObject("TableMessagesNode"):pushMessage("0", user.user_id, 
                    user.name, user.gender, response.send_time, response.content)
            end  
        elseif response.type == protocols.message_pb.MESSAGE_TYPE_TABLE_VOICE then
            APP:getObject("TableMessagesNode"):pushAudio("0", user.user_id, 
                user.name, user.gender, response.send_time, response.content, response.record_time)        
        end

        if response:HasField("coin") then
            user.coin = response.coin

            if APP:getCurrentController().refreshUserInfo then
                APP:getCurrentController():refreshUserInfo()
            end
        end
    elseif response.code == 48 then
        APP:getCurrentController():showAlertOK({desc = "您发送的频率太高了，请休息一会再试试吧～"})
    elseif response.code == 49 then
        APP:getCurrentController():showAlertOK({desc = "您今天发送的消息太多了，请休息一下，明天再来吧～"})
    elseif response.code == 20 then
        APP:getCurrentController():showAlertOK({desc = "您的金币数不足，无法发送"})
    end
end

function UserHandlers.handleNotifyMessage(payload)
    local response = protocols.message_pb.NotifyMessage()
    response:ParseFromString(payload)

    local user = APP:getObject("User")

    if response.type == protocols.message_pb.MESSAGE_TYPE_PLAYER_TEXT or
        response.type == protocols.message_pb.MESSAGE_TYPE_PLAYER_VOICE then
        z.LocalMessagesManager:getInstance():addMessage(
            response.from_id, response.from_name, response.from_avatar,
            response.send_time, false, response.type, response.content)
        z.LocalMessagesManager:getInstance():addNewMessagePlayerId(response.from_id)

        if APP:isObjectExists("MessagesView") then
            -- 刷新新消息
            APP:getObject("MessagesView"):newMessage(response.from_id, user.user_id)
        else
            -- 刷新新消息
            local currentController = APP:getCurrentController()
            if currentController.updateNewMessage then
                currentController:updateNewMessage()
            end
        end
    elseif response.type == protocols.message_pb.MESSAGE_TYPE_WORLD_TEXT or
        response.type == protocols.message_pb.MESSAGE_TYPE_WORLD_VOICE then
        -- 刷新新消息
        local currentController = APP:getCurrentController()
        if currentController.messageWorld then
            currentController:messageWorld(response)
        end

        if APP:isObjectExists("BroadcastNode") then
            APP:getObject("BroadcastNode"):pushBroadcast({
                from = {user_id = response.from_id, nickname = response.from_name}, 
                text = response.content
            })
        end

        local GlobalStatus = APP:getObject("GlobalStatus")
        table.insert(GlobalStatus.world_messages_, 1, payload)
    elseif response.type == protocols.message_pb.MESSAGE_TYPE_TABLE_TEXT then
        if APP:isObjectExists("TableMessagesNode") then
            -- 刷新新消息
            APP:getObject("TableMessagesNode"):pushMessage("0", response.from_id, 
                response.from_name, 1, response.send_time, response.content)
        end  
    elseif response.type == protocols.message_pb.MESSAGE_TYPE_TABLE_VOICE then
        if APP:isObjectExists("TableMessagesNode") then
            APP:getObject("TableMessagesNode"):pushAudio("0", response.from_id, 
                response.from_name, 1, response.send_time, response.content, response.record_time)    
        end    
    end
end

function UserHandlers.GetCoinRankingResponse(payload)
    local response = protocols.user_pb.GetCoinRankingResponse()
    response:ParseFromString(payload)   

    if response.code == Protocol.CODE_SUCCESS then
        local GlobalStatus = APP:getObject("GlobalStatus")
        local items = {}
        for i,v in ipairs(response.users) do
            table.insert(items, {user = v,rank = i})
        end
        
        GlobalStatus:setProperties({
            rank_players = items,
        })

        APP:getCurrentController():hideWaiting()
        APP:getCurrentController():showAlert(APP:createView("LeaderBoardView"))
    end    
end

function UserHandlers.GiftCoinResponse(payload)
    local response = protocols.base_pb2.GiftCoinResponse()
    response:ParseFromString(payload)   

    APP:getCurrentController():hideWaiting()

    if response.code == Protocol.CODE_SUCCESS then
        local globalStatus = APP:getObject("GlobalStatus")
        globalStatus:setProperties({
            bank_coin = response.bank,
        }) 
      
        APP:getCurrentController():showAlertOK({desc = string.format("成功打赏%d金币", response.gift_coin)})
        if APP:isObjectExists("BankView") then
            APP:getObject("BankView"):changeTab(2)
        end 

        if APP:isObjectExists("HomeController") then
            APP:getObject("HomeController"):refreshUserInfo()
        end 
    elseif response.code == 44 then
        APP:getCurrentController():showAlertOK({desc = "打赏失败，起赠金额20万，赠送过程中系统收取1%手续费，请确保有足够的金额"})
    else
        APP:getCurrentController():showAlertOK({desc = "打赏失败，请稍后重新尝试"})
    end    
end

function UserHandlers.NotifyGiftCoin(payload)
    local response = protocols.base_pb2.NotifyGiftCoin()
    response:ParseFromString(payload)   
    
    APP:getCurrentController():showAlertOK({
        desc = string.format("ID为%d的用户打赏了你%d金币,请到保险箱领取", response.from_user_id, response.gift_coin)
    })

    -- local user = APP:getObject("User")
    -- user.coin = user.coin+response.gift_coin
    local globalStatus = APP:getObject("GlobalStatus") 
    local _bankCoin = globalStatus:getBankCoin()
    globalStatus:setProperties({
        bank_coin = _bankCoin + response.gift_coin,
    })   
end


function UserHandlers.BankPasswordResponse(payload)
    local response = protocols.base_pb2.BankPasswordResponse()
    response:ParseFromString(payload)   

    APP:getCurrentController():hideWaiting()

    if response.code == Protocol.CODE_SUCCESS then
        local globalStatus = APP:getObject("GlobalStatus")    
        globalStatus:setProperties({
            bank_password = globalStatus:getTempBankPassword(),
            bank_coin = response.bank,
        })          

        if response.is_set == true then
            APP:getCurrentController():showAlertOK({desc = "修改保险箱密码成功"})
            if APP:isObjectExists("BankView") then
                APP:getObject("BankView"):changeTab(3)
            end   
        else
            --进入保险箱逻辑
            if APP:isObjectExists("BankView") then
                APP:getObject("BankView"):changeTab(1)
            end
        end
    else
        if response.is_set == true then
            APP:getCurrentController():showAlertOK({desc = "原密码错误，重置密码失败，请稍后再试"})
        else
            APP:getCurrentController():showAlertOK({desc = "保险箱密码错误，无法进入保险箱，请稍后再试"})
        end
    end    
end

function UserHandlers.BankIOResponse(payload)
    local response = protocols.base_pb2.BankIOResponse()
    response:ParseFromString(payload)   

    local globalStatus = APP:getObject("GlobalStatus")

    globalStatus:setProperties({
        bank_coin = response.bank,
    })      

    local user = APP:getObject("User")
    user.coin = response.coin

    if response.code == Protocol.CODE_SUCCESS then
        if response.in_or_out == 0 then
            APP:getCurrentController():showAlertOK({desc = 
                string.format("成功存入%d金币", response.change_coin)
            })
        else
            APP:getCurrentController():showAlertOK({desc = 
                string.format("成功取出%d金币", response.change_coin)
            })
        end
        if APP:isObjectExists("BankView") then
            APP:getObject("BankView"):changeTab(1)
        end

        if APP:isObjectExists("HomeController") then
            APP:getObject("HomeController"):refreshUserInfo()
        end

        if APP:isObjectExists("MJLYGameController") then
            local gameTable = globalStatus:getGameTable()
            for _,v in pairs(gameTable._players) do
                if v ~= nil then
                    if v._user.user_id == user.user_id then
                        v._user.coin = user.coin
                    end
                end
            end
            if globalStatus:getWatchingSeatId() == -1 then
                APP:getObject("MJLYGameController"):refreshPlayerNode()
            end
        end

        if APP:isObjectExists("NNGameController") then
            if globalStatus:getWatchingSeatId() == -1 then
                APP:getObject("NNGameController")._myNode:updateCoin(user.coin)
            end
        end

        if APP:isObjectExists("LandlordGameController") then
            if globalStatus:getWatchingSeatId() == -1 then
                APP:getObject("LandlordGameController"):refreshPlayerNode()
            end
        end

        if APP:isObjectExists("GDYGameController") then
            if globalStatus:getWatchingSeatId() == -1 then
                APP:getObject("GDYGameController")._myNode:updateCoin(user.coin)
            end
        end       

        if APP:isObjectExists("ShGameController") then
            if globalStatus:getWatchingSeatId() == -1 then
                APP:getObject("ShGameController")._myNode:updateCoin(user.coin)
            end
        end 

        if APP:isObjectExists("SifutouGameController") then
            if globalStatus:getWatchingSeatId() == -1 then
                APP:getObject("SifutouGameController")._myNode:updateCoin(user.coin)
            end
        end

    else
        if response.in_or_out == 0 then
            APP:getCurrentController():showAlertOK({desc = "存入保险箱失败，请稍后再试"})
        else
            APP:getCurrentController():showAlertOK({desc = "从保险箱取金币失败，请稍后再试"})
        end
    end    
end

function UserHandlers.NotifyPayScucess(payload)
    local response = protocols.pay_pb.NotifyPaySucc()
    response:ParseFromString(payload)   

    local globalStatus = APP:getObject("GlobalStatus")

    APP:getCurrentController():hideWaiting()

    local user = APP:getObject("User")
    user.coin = response.coin
    user.vip_level = response.vip_level
    user.vip_exp = response.vip_exp
    
    local desc = string.format("您购买的%d金币已经成功", response.plus_coin)
    APP:getCurrentController():showAlertOK({desc = desc})

    if APP:isObjectExists("HomeController") then
        APP:getObject("HomeController"):refreshUserInfo()
    end 

    if APP:isObjectExists("MJLYGameController") then
        local gameTable = globalStatus:getGameTable()
        for _,v in pairs(gameTable._players) do
            if v ~= nil then
                if v._user.user_id == user.user_id then
                    v._user.coin = user.coin
                end
            end
        end
        if globalStatus:getWatchingSeatId() == -1 then
            APP:getObject("MJLYGameController"):refreshPlayerNode()
        end
    end

    if APP:isObjectExists("NNGameController") then
        if globalStatus:getWatchingSeatId() == -1 then
            APP:getObject("NNGameController")._myNode:updateCoin(user.coin)
        end
    end
end



function UserHandlers.HeePayResponse(payload)
    local response = protocols.pay_pb.HeePayResponse()
    response:ParseFromString(payload)   

    if response.code == Protocol.CODE_SUCCESS then
        if APP:isObjectExists("MallView") then
            APP:getObject("MallView"):requestHeePay(response)
            return 
        end        
    end

    APP:getCurrentController():hideWaiting()

    APP:getCurrentController():showAlertOK({desc = "支付请求失败，请稍后再试"})
end


function UserHandlers.handleSetGamesettingsResponse(payload)
    local response = protocols.base_pb2.SetGameSettingsResponse()
    response:ParseFromString(payload)   

    local globalStatus = APP:getObject("GlobalStatus")

    globalStatus:setProperties({
        game_settings = response.game_settings
    })      


    return response
end

function UserHandlers.handleQuickStartResponse(payload)
    local response = protocols.base_pb.QuickStartResponse()
    response:ParseFromString(payload)  
    local MJTable = models.MJTable.new()

    local GlobalStatus = APP:getObject("GlobalStatus")

    APP:getCurrentController():hideWaiting()

    if response.table.game_type == protocols.defines_pb.MJ_LI_YANG_HUA_2P
    or response.table.game_type == protocols.defines_pb.MJ_LI_YANG_HUA_4P then
        MJTable = models.MJLYTable.new()
    elseif response.table.game_type == protocols.defines_pb.NIUNIU then
        MJTable = models.NNTable.new()
    elseif response.table.game_type == protocols.defines_pb.GAN_DENG_YAN then
        MJTable = models.GDYTable.new()
    elseif response.table.game_type == protocols.defines_pb.DOU_DI_ZHU then
        MJTable = models.LandlordTable.new()
    elseif response.table.game_type == protocols.defines_pb.SUOHA then
        MJTable = models.SHTable.new()
    elseif response.table.game_type == protocols.defines_pb.HUA_LUN then
        MJTable = models.HualunTable.new()
    elseif response.table.game_type == protocols.defines_pb.SI_FU_TOU then
        MJTable = models.SifutouTable.new()
    end 

    if response.code == Protocol.CODE_SUCCESS then
        GameUtils.stopMusic()

        SOCKET_MANAGER.blockMessage()

        GlobalStatus:setProperties({
            game_table = MJTable,
            seat_id = response.seat_id,
            watching_seat_id = response.watching_seat_id,
        })
        
        MJTable:loadByPBBaseTable(response.table)

        if MJTable._gameType == protocols.defines_pb.MJ_LI_YANG_HUA_2P or
            MJTable._gameType == protocols.defines_pb.MJ_LI_YANG_HUA_4P then
            APP:enterScene("MJLYGameScene")
        elseif response.table.game_type == protocols.defines_pb.NIUNIU then
            APP:enterScene("NNGameScene")
        elseif response.table.game_type == protocols.defines_pb.GAN_DENG_YAN then
            APP:enterScene("GDYGameScene")
        elseif response.table.game_type == protocols.defines_pb.DOU_DI_ZHU then
            APP:enterScene("LandlordGameScene")
        elseif response.table.game_type == protocols.defines_pb.SUOHA then
            APP:enterScene("SHGameScene")
        elseif response.table.game_type == protocols.defines_pb.HUA_LUN then
            APP:enterScene("HualunGameScene")
        elseif response.table.game_type == protocols.defines_pb.SI_FU_TOU then
            APP:enterScene("SifutouGameScene")
        end
    elseif response.code == 20 then
        APP:getCurrentController():showAlertOK({
            desc = "您身上的金币不足，无法进行游戏",
        })
    elseif response.code == 39 then
        APP:getCurrentController():showAlertOK({
            desc = "进桌密码错误",
        })
    elseif response.code == 40 then
        APP:getCurrentController():showAlertOK({
            desc = "您身上的金币 未达到最低进桌限制",
        })
    elseif response.code == 41 then
        APP:getCurrentController():showAlertOK({
            desc = "您身上的金币 超过最高进桌限制",
        })
    elseif response.code == 42 then
        APP:getCurrentController():showAlertOK({
            desc = "其它玩家不满足自己的进桌限制",
        })
    else
        APP:getCurrentController():showAlertOK({
            desc = "进入游戏失败，请稍后再试！！！",
        })
    end

    return response    
end

function UserHandlers.handleNotifyPoorProtect(payload)
    local response = protocols.base_pb2.NotifyPoorProtect()
    response:ParseFromString(payload)

    local user = APP:getObject("User")
    user.coin = response.coin
    local desc = string.format("您的金币数少于1000，赠送您%d金币，每天有%d次机会，今天剩余次数为：%d次", 
        response.gift_coin,response.max_times,response.remain_times)
    if APP:isObjectExists("HomeController") or APP:isObjectExists("RoomController") then
        APP:getCurrentController():showAlertOK({desc = desc})
        APP:getCurrentController():refreshUserInfo()
    else
        table.insert(UserHandlers.poorNotify, response)
    end  
end

function UserHandlers.handleGetGiftLogResponse(payload)
    local response = protocols.base_pb2.GetGiftLogResponse()
    response:ParseFromString(payload)

    APP:getCurrentController():hideWaiting()

    if response.code == Protocol.CODE_SUCCESS then
        APP:createView("GiftLogNode", response.logs)
            :align(display.CENTER, display.cx, display.cy)
            :addTo(APP:getCurrentController(),9999999)
    else
        APP:getCurrentController():showAlertOK({desc = "获取送金记录失败，请稍后再试"})
    end
end

function UserHandlers.handleRecordUserInfoResponse(payload)
    local response = protocols.base_pb2.RecordUserInfoResponse()
    response:ParseFromString(payload)

    APP:getCurrentController():hideWaiting()

    if response.code == Protocol.CODE_SUCCESS then
        if APP:isObjectExists("RecordUserInfoNode") then
            APP:getObject("RecordUserInfoNode"):removeFromParent()
        end
        
        local desc = "您的信息已经录入成功，稍后客服会联系您"
        APP:getCurrentController():showAlertOK({desc = desc})   
    end
end

function UserHandlers.handleGetInviteUsersResponse(payload)
    local response = protocols.base_pb2.GetInvitedUsersResponse()
    response:ParseFromString(payload)

    APP:getCurrentController():hideWaiting()

    if response.code == Protocol.CODE_SUCCESS then
        APP:createView("InviteNode", response)
            :pos(display.cx, display.cy)
            :addTo(APP:getCurrentController(),9998) 
    else
        APP:getCurrentController():showAlertOK({desc = "获取邀请列表失败，请稍后再试"})
    end
end

function UserHandlers.handleNotifyAlert(payload)
    local response = protocols.base_pb2.NotifyAlert()
    response:ParseFromString(payload)

    APP:getCurrentController():showAlertOK({
        title = response.title,
        desc = response.content,
        okText = response.ok,
    })  
end

function UserHandlers.handleGameScreenShotResponse(payload)
    local response = protocols.table_pb.GameScreenShotResponse()
    response:ParseFromString(payload)


end


function UserHandlers.handleNotifyGameScreenShot(payload)
    local response = protocols.table_pb.NotifyGameScreenShot()
    response:ParseFromString(payload)

    if APP:isObjectExists("SifutouGameController") then
        APP:getObject("SifutouGameController"):showScreenTips(response.seat_id)
    end    
end







return UserHandlers