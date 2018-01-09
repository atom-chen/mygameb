
local Protocol = {}
Protocol.CODE_SUCCESS                        = 0  -- 成功
Protocol.CODE_ERROR_RETRY                    = 1  -- 请重新尝试
Protocol.CODE_ERROR_IGNORE                   = 2  -- 忽略不处理
Protocol.CODE_ERROR_DENIED                   = 3  -- 拒绝请求(不符合逻辑)
Protocol.CODE_ERROR_INTERNAL_ERROR           = 4  -- 服务器内部错误
Protocol.CODE_ERROR_UNKNOWN                  = 5  -- 未知错误
Protocol.CODE_ERROR_NOT_FOUND                = 6  -- 资源没有找到
Protocol.CODE_ERROR_UNSUPPORT_API            = 7  -- 不支持的APIs
Protocol.CODE_ERROR_INVALID_JSON             = 8  -- Json格式非法
Protocol.CODE_ERROR_ALREADY_REGISTERED       = 9  -- 用户已经注册
Protocol.CODE_ERROR_INVALID_USER_TYPE        = 10 -- 用户类型不对
Protocol.CODE_ERROR_INVALID_ACCOUNT_PASSWORD = 11 -- 密码错误
Protocol.CODE_ERROR_SEND_EMAIL_ERROR         = 12 -- 发送邮件失败
Protocol.CODE_ERROR_INVALID_SIGN             = 13 -- 签名错误
Protocol.CODE_ERROR_NO_PRODUCT               = 14 -- 没有货物
Protocol.CODE_ERROR_DUPLICATE_ORDER_ID       = 15 -- 订单重复
Protocol.CODE_ERROR_INVALID_API_KEY          = 16 -- API Key非法
Protocol.CODE_ERROR_IAP_FAILED               = 17 -- 支付失败
Protocol.CODE_ERROR_IAP_CANCEL               = 18 -- 支付取消
Protocol.CODE_ERROR_HAVE_NOT_AUTH            = 19 -- 尚未授权
Protocol.CODE_ERROR_NOT_ENOUGH_COIN          = 20 -- 筹码不足
Protocol.CODE_ERROR_NOT_ENOUGH_DIAMOND       = 21 -- 钻石不足
Protocol.CODE_ERROR_NOT_ENOUGH_VIP           = 22 -- VIP等级不足
Protocol.CODE_ERROR_NOT_IN_GROUP             = 23 -- 不在此Group中
Protocol.CODE_ERROR_NOT_IN_CLUB              = 24 -- 不在此Club中
Protocol.CODE_ERROR_NO_RIGHTS                = 25 -- 权限不足
Protocol.CODE_ERROR_STILL_HAVE_MEMBERS       = 26 -- Group/Club中仍有成员，无法解散
Protocol.CODE_ERROR_SEAT_HAS_USER            = 27 -- 座位已有其他玩家
Protocol.CODE_ERROR_INVALID_SEAT_ID          = 28 -- 非法座位号
Protocol.CODE_ERROR_STILL_IN_GAMING          = 29 -- 仍在游戏中无法离开
Protocol.CODE_ERROR_CANNOT_EMPTY             = 30 -- 不允许为空
Protocol.CODE_ERROR_TABLE_NOT_STARTED        = 31 -- 牌局尚未开始
Protocol.CODE_ERROR_TABLE_HAS_STARTED        = 32 -- 牌局已经开始
Protocol.CODE_ERROR_TABLE_HAS_ENDED          = 33 -- 牌局已结束
Protocol.CODE_ERROR_TOO_MANY_MEMBERS         = 34 -- Group/Club 成员数超过限制

local c = require("command_pb")

Protocol[c.CMD_PING] = "CMD_PING"
Protocol[c.CMD_ECHO_REQ] = "CMD_ECHO_REQ"
Protocol[c.CMD_ECHO_RESP] = "CMD_ECHO_RESP"




return Protocol
