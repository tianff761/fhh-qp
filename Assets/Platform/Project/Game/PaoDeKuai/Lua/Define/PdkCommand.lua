--跑得快协议
--
CMD.Tcp.Pdk = {}
CMD.Game.Pdk = {}

--房间信息
CMD.Tcp.Pdk.C2S_JoinRoom = 10002

--玩家退出
CMD.Tcp.Pdk.C2S_ExitRoom = 10003

--房间信息
CMD.Tcp.Pdk.S2C_RoomInfo = 30000

--玩家信息更新
CMD.Tcp.Pdk.S2C_UpdatePlayerInfo = 30001

--游戏状态更新
CMD.Tcp.Pdk.S2C_RoonStatus = 30002

--玩家准备
CMD.Tcp.Pdk.C2S_PlayerReady = 30003
CMD.Tcp.Pdk.S2C_PlayerReady = 30004

--发牌
CMD.Tcp.Pdk.S2C_DealCard = 30005

--出牌通知
CMD.Tcp.Pdk.S2C_NoticeOutCard = 30006

--出牌
CMD.Tcp.Pdk.C2S_PlayerOutCard = 30007
CMD.Tcp.Pdk.S2C_PlayerOutCard = 30008

--结算
CMD.Tcp.Pdk.S2C_SingleRecord = 30009

--通知
CMD.Tcp.Pdk.S2C_GameWaitStart = 2016

--玩家发起解散投票
CMD.Tcp.Pdk.C2S_DissolveRoom = 30010
CMD.Tcp.Pdk.S2C_DissolveRoom = 30011

--玩家投票
CMD.Tcp.Pdk.C2S_VoteAction = 30012

--房间解散
CMD.Tcp.Pdk.S2C_RoomDissolve = 30013

--总结算
CMD.Tcp.Pdk.S2C_TotalRecord = 30014

--过牌
CMD.Tcp.Pdk.C2S_PlayerPassCard = 30020
CMD.Tcp.Pdk.S2C_PlayerPassCard = 30021

--提示
CMD.Tcp.Pdk.C2S_TipOutCard = 30022
CMD.Tcp.Pdk.S2C_TipOutCard = 30023

--及时结算分数
CMD.Tcp.Pdk.S2C_DeductScore = 30024

--玩家取消托管
CMD.Tcp.Pdk.C2S_PlayerCancelOnHook = 30025

--玩家剩余手牌
CMD.Tcp.Pdk.S2C_SurplusHandCard = 30026

--GPS
CMD.Tcp.Pdk.C2S_PlayerGpsData = 30027
CMD.Tcp.Pdk.S2C_PlayerGpsData = 30028

--看牌
CMD.Tcp.Pdk.S2C_PlayerSeePoker = 30030

--玩家出牌是否成功
CMD.Tcp.Pdk.S2C_PlayerOutCardResult = 30031

--推送房间结束状态
CMD.Tcp.Pdk.PushRoomEndStatus = 30032

--错误信息
CMD.Tcp.Pdk.S2C_ErrorMessage = 30050

--能不能出牌
CMD.Game.Pdk.CanPopCard = 30101
--发牌结束
CMD.Game.Pdk.DealCardEnd = 30102

PdkErrorCode = {
    --规则错误
    RULES_EOOR = 10000,
    --不该你出牌
    YOU_CAN_SHOW = 10001,
    --你沒有这些牌 牌数据出错
    YOU_NOT_HAVE_SOME_POKER = 10002,
    --该牌型不能出
    YOU_NOT_SHOW_THIS = 10003,
    --房间正在解散
    ROOM_DIS_NOW = 10004,
    --记牌器未开启
    JIPAIQI_CLOSE = 10005,
    --游戏状态不允许
    GAMESTATUS_NOTAGREE = 10006,
    --房间未发起解散
    ROOM_NOT_DIS_NOW = 10007,
    --游戏已经开始，请勿换座
    CAN_HUAN_ZUOWEI = 10008,
    --该位置已经有玩家
    HAVE_PLAYER = 10009,
    --不该你操作
    CAN_NOT_DO = 10010,
    --不能过牌
    CAN_NOT_PAST = 10011,
    --下家报单
    NEXT_ONE_POKER = 10012,
    --首出必带黑桃五
    MUST_SHOW_POKER = 10013,
    --首出必出黑三
    MUST_SHOW_POKER_THREE = 10025,
    --炸弹不可拆
    CAN_NOT_CHAI_BOOM = 10014,
    ---不是最后一手不能出
    CAN_NOT_OUT_EXCEPT_LAST_ROUND = 10024,
}

PdkErrorMessage = {
    [PdkErrorCode.RULES_EOOR] = "规则错误",
    [PdkErrorCode.YOU_CAN_SHOW] = "不该你出牌",
    -- [PdkErrorCode.YOU_NOT_HAVE_SOME_POKER] = "牌数据出错",
    [PdkErrorCode.YOU_NOT_SHOW_THIS] = "不符合出牌规则",
    [PdkErrorCode.ROOM_DIS_NOW] = "房间正在解散",
    [PdkErrorCode.JIPAIQI_CLOSE] = "记牌器未开启",
    [PdkErrorCode.GAMESTATUS_NOTAGREE] = "游戏状态不允许",
    [PdkErrorCode.ROOM_NOT_DIS_NOW] = "房间未发起解散",
    [PdkErrorCode.CAN_HUAN_ZUOWEI] = "游戏已经开始，请勿换座",
    [PdkErrorCode.HAVE_PLAYER] = "该位置已经有玩家",
    -- [PdkErrorCode.CAN_NOT_DO] = "不该你操作",
    [PdkErrorCode.CAN_NOT_PAST] = "不能过牌",
    [PdkErrorCode.NEXT_ONE_POKER] = "下家报单，请出最大的单牌",
    [PdkErrorCode.MUST_SHOW_POKER] = "首出必带黑桃五",
    [PdkErrorCode.MUST_SHOW_POKER_THREE] = "首出必出黑桃三",
    [PdkErrorCode.CAN_NOT_CHAI_BOOM] = "炸弹不可拆",
    [PdkErrorCode.CAN_NOT_OUT_EXCEPT_LAST_ROUND] = "不是最后一手不能出",
}

