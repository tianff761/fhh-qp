-- Buildin Table     
-- 			STC -->> 服务器主推客户端    
-- 			CTS -->> 客户端请求服务器
LYCAction = {
    Push_SystemTips                        = "901", ---! 系统提示推送	

    LYC_CTS_JOIN_ROOM                    = "10002", ---! 加入房间
    LYC_CTS_LEAVE_ROOM                   = "10003", ---! 离开房间(请求的是框架的离开房间)
    LYC_STC_LEAVE_ROOM                   = "1040036", ---! 离开房间回复  --!!
    LYC_CTS_SEAT_DOWN                    = "1040001",--- 玩家坐下
    LYC_STC_JOIN_ROOM                    = "1040002", ---! 加入房间回复
    -- --------------------------------------十点半游戏-------------------------------------------------------
    LYC_STC_JoinRoom_Info                = "1040004", --加入房间信息
    LYC_STC_Start_State                  = "1040006", --通知房主是否能够开始游戏
    LYC_CTS_DISSOLVE                     = "1040007", --提起解散房间
    LYC_STC_RoomState                    = "1040008", --通知房间状态改变（开始游戏，抢庄阶段...）（倒计时）
    LYC_CTC_GameStart                    = "1040009", --玩家操作开始游戏
    LYC_STC_B_GameStart                  = "1040032", --广播游戏开始
    LYC_STC_Update_Player_Info           = "1040010", --广播玩家信息改变  --!!
    LYC_STC_Send_Cards                   = "1040012", --广播发牌
    LYC_CTS_Owner_DISSOLVE               = "1040013", --房主提起解散房间
    LYC_CTS_Operate                      = "1040003", --玩家操作
    LYC_STC_Operate                      = "1040003", --玩家操作回复
    LYC_STC_B_Operate                    = "1040014", --广播玩家操作
    LYC_STC_B_FlipCard                   = "1040016", --广播玩家亮牌
    LYC_STC_GetTipCard                   = "1040005", --获取牌型提示回复
    LYC_STC_B_XiaoJie                    = "1040018", --广播小结算
    LYC_STC_B_ZongJie                    = "1040020", --广播总结算
    LYC_STC_BetPoints                    = "1040022", --通知下注分
    LYC_STC_Bolus                        = "1040024", --通知推注
    LYC_CTS_READY                        = "1040025", --玩家准备(或坐下)
    LYC_STC_READY                        = "1040025", --广播玩家准备
    LYC_STC_DissolveTip                  = "1040026", --解散房间提示
    LYC_CTS_GetWatchPlayerList           = "1040027", --获取观战玩家列表
    LYC_CTS_PlayerBomb                   = "1040029", -- 玩家选择炸开
    LYC_CTS_PlayerLaoPai                 = "1040031", -- 玩家选择捞牌
    LYC_CTS_PlayerBiPai                  = "1040033", -- 庄家选择比牌
    LYC_STC_GetWatchPlayerList           = "1040042", --获取观战玩家列表
    LYC_STC_OFFLINE                      = "1040028", --离线状态推送
    LYC_STC_ROB_BANKER                   = "1040034", --抢庄结果通知
    LYC_STC_ROOMAUTODISS                 = "1040038", --房间自动解散
    LYC_STC_OwnerChange                  = "1040044", --房主变更协议
    LYC_STC_ErrorCode                    = "1040046", --房主变更协议
    LYC_STC_NoticePlayerBomb             = "1040048", --玩家选择炸开
    LYC_STC_NoticePlayerLao              = "1040050", --通知玩家捞牌
    LYC_STC_NoticeBiPai                  = "1040052", --通知玩家比牌
    LYC_STC_NoticeCanOp                  = "1040054", --通知玩家可选操作
    LYC_STC_AWARD_OPEN                   = "110000", ---! 玩家开奖

-- -------------------------------------------------------------------------------------------------------
    LYCLoadEnd                           = "C_LYCLYCLoadEnd", ---! 加载面板结束
    PokerStyleType                        = "C_LYCPokerStyleType", ---! 扑克牌样式
    DeskStypleType                        = "C_LYCDeskStypleType", ---! 桌面样式
    LYCBackMusic                         = "C_LYCBackMusic", ---! 血战到底背景音曲目

    LYCObserverSitDown                   = "C_LYCObserverSitDown", ---观战玩家坐下
    LYCHideOperate                       = "C_LYCHideOperate", ---观战玩家坐下
}

NoIgnoreAction = {
    LYCLoadEnd                           = "LYCLoadEnd", ---! 加载面板结束
    LYC_STC_JOIN_ROOM                    = "50194", ---! 加入房间回复
}