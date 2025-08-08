-- Buildin Table     
-- 			STC -->> 服务器主推客户端    
-- 			CTS -->> 客户端请求服务器
Pin5Action = {
    Push_SystemTips                        = "901", ---! 系统提示推送	

    Pin5_CTS_JOIN_ROOM                    = "10002", ---! 加入房间
    Pin5_CTS_LEAVE_ROOM                   = "10003", ---! 离开房间(请求的是框架的离开房间)
    Pin5_STC_LEAVE_ROOM                   = "1014036", ---! 离开房间回复  --!!
    Pin5_CTS_SEAT_DOWN                    = "1014001",--- 玩家坐下
    Pin5_STC_JOIN_ROOM                    = "1014002", ---! 加入房间回复
    -- --------------------------------------十点半游戏-------------------------------------------------------
    Pin5_STC_JoinRoom_Info                = "1014004", --加入房间信息
    Pin5_STC_Start_State                  = "1014006", --通知房主是否能够开始游戏
    Pin5_CTS_DISSOLVE                     = "1014007", --提起解散房间
    Pin5_STC_RoomState                    = "1014008", --通知房间状态改变（开始游戏，抢庄阶段...）（倒计时）
    Pin5_CTC_GameStart                    = "1014009", --玩家操作开始游戏
    Pin5_STC_B_GameStart                  = "1014032", --广播游戏开始 
    Pin5_STC_Update_Player_Info           = "1014010", --广播玩家信息改变  --!!
    Pin5_STC_Send_Cards                   = "1014012", --广播发牌
    Pin5_CTS_Owner_DISSOLVE               = "1014013", --房主提起解散房间
    Pin5_CTS_Operate                      = "1014003", --玩家操作
    Pin5_STC_Operate                      = "1014003", --玩家操作回复
    Pin5_STC_B_Operate                    = "1014014", --广播玩家操作
    Pin5_STC_B_FlipCard                   = "1014016", --广播玩家亮牌
    Pin5_STC_GetTipCard                   = "1014005", --获取牌型提示回复
    Pin5_STC_B_XiaoJie                    = "1014018", --广播小结算
    Pin5_STC_B_ZongJie                    = "1014020", --广播总结算
    Pin5_STC_BetPoints                    = "1014022", --通知下注分
    Pin5_STC_Bolus                        = "1014024", --通知推注
    Pin5_CTS_READY                        = "1014025", --玩家准备(或坐下)
    Pin5_STC_READY                        = "1014025", --广播玩家准备
    Pin5_STC_DissolveTip                  = "1014026", --解散房间提示 
    Pin5_CTS_GetWatchPlayerList           = "1014027", --获取观战玩家列表
    Pin5_STC_GetWatchPlayerList           = "1014042", --获取观战玩家列表
    Pin5_STC_OFFLINE                      = "1014028", --离线状态推送
    Pin5_STC_ROB_BANKER                   = "1014034", --抢庄结果通知 
    Pin5_STC_ROOMAUTODISS                 = "1014038", --房间自动解散
    Pin5_STC_OwnerChange                  = "1014044", --房主变更协议
    Pin5_STC_ErrorCode                    = "1014046", --房主变更协议
    Pin5_STC_AWARD_OPEN                   = "110000", ---! 玩家开奖

-- -------------------------------------------------------------------------------------------------------
    Pin5LoadEnd                           = "C_Pin5Pin5LoadEnd", ---! 加载面板结束
    PokerStyleType                        = "C_Pin5PokerStyleType", ---! 扑克牌样式
    DeskStypleType                        = "C_Pin5DeskStypleType", ---! 桌面样式
    Pin5BackMusic                         = "C_Pin5BackMusic", ---! 血战到底背景音曲目

    Pin5ObserverSitDown                   = "C_Pin5ObserverSitDown", ---观战玩家坐下
    Pin5HideOperate                       = "C_Pin5HideOperate", ---观战玩家坐下
}

NoIgnoreAction = {
    Pin5LoadEnd                           = "Pin5LoadEnd", ---! 加载面板结束
    Pin5_STC_JOIN_ROOM                    = "50194", ---! 加入房间回复	
}