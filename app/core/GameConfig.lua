
local GameConfig = {}

GameConfig.Version = "1.0.0.0"

GameConfig.Pay_Token = "@*S&@S(@^"
GameConfig.INVALID_ID = -1

-- PLATFORM
GameConfig.GamePlatform_iOS = 0
GameConfig.GamePlatform_Android = 1

-- HTTP 方法
GameConfig.METHOD_GET = 0
GameConfig.METHOD_POST = 1
GameConfig.METHOD_PUT = 2
GameConfig.METHOD_DELETE = 3


-- 自定义lua回调类型
GameConfig.Handler = GameConfig.Handler or {}
-- 10001 ~ 10100 预留给Common回调
GameConfig.Handler.EVENT_COMMON_HTTP_ERROR = 10001
GameConfig.Handler.EVENT_COMMON_HTTP_CALLBACK = 10002
GameConfig.Handler.EVENT_COMMON_HTTP_PROGRESS_CALLBACK = 10003
GameConfig.Handler.EVENT_COMMON_IMAGE_PICK_FINISHED = 10004
GameConfig.Handler.EVENT_CHANNEL_IAP_NO_PRODUCT = 10005
GameConfig.Handler.EVENT_CHANNEL_IAP_PAY_FAILED = 10006
GameConfig.Handler.EVENT_CHANNEL_IAP_PAY_CANCELED = 10007
GameConfig.Handler.EVENT_CHANNEL_IAP_PAY_SUCCESS = 10008
GameConfig.Handler.EVENT_CHANNEL_IAP_PAY_SUCCESS_STEP = 10009
GameConfig.Handler.EVENT_PLAY_EFFECT = 10010
GameConfig.Handler.EVENT_PLAY_EFFECT_AND_RECORD = 10011
GameConfig.Handler.EVENT_STOP_RECORDED_EFFECT = 10012
GameConfig.Handler.EVENT_PLAY_AUDIO = 10013
GameConfig.Handler.EVENT_PLAY_AUDIO_FAILED = 10014
GameConfig.Handler.EVENT_PLAY_AUDIO_BEGIN = 10015
GameConfig.Handler.EVENT_PLAY_AUDIO_END = 10016
GameConfig.Handler.EVENT_PLAY_AUDIO_STOPED = 10017
GameConfig.Handler.EVENT_DOWNLOAD_AUDIO = 10018
GameConfig.Handler.EVENT_SHOW_ALERT_OK = 10019
GameConfig.Handler.EVENT_SHOW_ALERT_OK_CANCEL = 10020
GameConfig.Handler.EVENT_PLATFORM_LOGIN_SUCCESS = 10021
GameConfig.Handler.EVENT_PLATFORM_LOGOUT_SUCCESS = 10022

-- 10101 ~ 10200 预留给Casino回调
GameConfig.Handler.EVENT_CASINO_ROULETTE_END = 10101

-- 开关定义
GameConfig.SW_DEFAULT = 0
GameConfig.SW_ON = 1
GameConfig.SW_OFF = 2


-- 本地数据XML KEY定义
GameConfig.LocalData_AppEverOpened = "AppEverOpened"
GameConfig.LocalData_FirstLoginTimestamp = "FirstLoginTimestamp"
GameConfig.LocalData_GuestAccount = "GuestAccount"
GameConfig.LocalData_GuestPassword = "GuestPassword"
GameConfig.LocalData_UserType = "UserType"
GameConfig.LocalData_Account = "Account"
GameConfig.LocalData_SaveAccount = "SaveAccount"
GameConfig.LocalData_Password = "Password"
GameConfig.LocalData_IP = "Ip"
GameConfig.LocalData_SW_Music = "SW_Music"
GameConfig.LocalData_SW_Sound = "SW_Sound"
GameConfig.LocalData_SW_Vibrate = "SW_Vibrate"
GameConfig.LocalData_SW_AutoPlayAudio = "SW_AutoPlayAudio"
GameConfig.LocalData_LastLimitedBuyTimestamp = "LastLimitedBuyTimestamp"
GameConfig.LocalData_FirstPayPop = "FirstPayPop"
GameConfig.LocalData_NoticeKey = "NoticeKey"
GameConfig.LocalData_NoticeOpenCounts = "NoticeOpenCounts"
GameConfig.LocalData_NoticeOpenTime = "NoticeOpenTime"
GameConfig.LocalData_DEVICE_ID = "IDE_DEVICE_ID"





-- 通用ZOrder定义
GameConfig.Top_Z = 10000
GameConfig.Waiting_Z = 9999
GameConfig.Alert_Z = 9998
GameConfig.GameTop_Z = 1000
GameConfig.UI_Z = 100

-- Loading比重
GameConfig.LoadingFact_Net = 20
GameConfig.LoadingFact_Resource = 80

-- 数值
GameConfig.PokerLie = 7
GameConfig.TopPokerNum = 15










return GameConfig