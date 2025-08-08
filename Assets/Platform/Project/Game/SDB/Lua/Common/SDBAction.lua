-- Buildin Table     
-- 			STC -->> 服务器主推客户端    
-- 			CTS -->> 客户端请求服务器
SDBAction = {
	SDB_CTS_JOIN_ROOM                      = "10002",                           ---! 加入房间
	SDB_CTS_LEAVE_ROOM                     = "10003",                           ---! 离开房间(请求的是框架的离开房间)
	SDB_STC_LEAVE_ROOM                     = "50150",                           ---! 离开房间(请求的是框架的离开房间)
	SDB_STC_JOIN_ROOM                      = "50194",							---! 加入房间回复		
	Push_SystemTips  					   = "901",		                        ---! 系统提示推送						
	---------------------------------------系统------------------------------------------------------------
	-- SDB_ACT_PING						   = 1001,							    ---! 网络延迟（心跳）
	--------------------------------------十点半游戏-------------------------------------------------------
	SDB_STC_ROOM_INFO                      = "50101",                           ---! 房间信息(主推)
	SDB_STC_UPDATE_PLAYER_INFO		       = "50102",                           ---! 更新玩家信息(主推)
	SDB_STC_PLAYER_INFOS			       = "50103",                           ---! 玩家信息(只会推一次)(主推)
	SDB_CTS_READY						   = "50104",						    ---! 准备(坐下)
	SDB_STC_READY                          = "50105",                           ---! 广播坐下状态
	SDB_STC_START_STATE                    = "50106",						    ---! 通知房主是否能够开始游戏
	SDB_CTS_OPERATE_START_GAME             = "50107",                           ---! 房主操作开始游戏
	SDB_STC_GAME_START                     = "50108",                           ---! 通知游戏开始
    SDB_STC_SEND_CARDS    				   = "50109",                           ---! 发牌
	SDB_STC_INFROM_ROB_BANKER              = "50110",							---! 通知抢庄    
	SDB_CTS_OPERATE_ROB_BANKER			   = "50111",                           ---! 抢庄操作(回复广播)
    SDB_STC_ROB_BANKER                     = "50112",                           ---! 抢庄结果通知（庄id，抢庄玩家）
    SDB_STC_INFROM_BET_SCORE               = "50113",							---! 通知下注
	SDB_CTS_OPERATE_BET_SCORE              = "50114",							---! 操作下注
    SDB_STC_BET_SCORE                      = "50115",							---! 广播下注
    SDB_STC_NOTICE_INFROM_GET_CARDS        = "50116",                           ---! 广播某个玩家要牌
	SDB_STC_INFROM_GET_CARDS               = "50117",                           ---! 通知某个玩家要牌
    SDB_CTS_OPERATE_GET_CARDS              = "50118",                           ---! 操作要牌
    SDB_STC_UPDATE_CARDS_NUMBER            = "50119",                           ---! 更新剩余牌数
    SDB_STC_BALANCE                        = "50120",                           ---! 小结
    SDB_STC_SUMMARIZE         		       = "50121",						   	---! 大结
	SDB_CTS_PORTION_PLYAER_INFO            = "50122",                           ---! 请求玩家信息(id,状态，座位)
    SDB_CTS_LAUNCH_DISSOLVE                = "50123",                           ---! 提起解散房间
    SDB_CTS_OPERATE_DISSOLVE               = "50124",                           ---! 操作是否同意解散房间
	SDB_STC_NOTICE_DISMISS_ROOM            = "50125",                           ---! 解散房间信息(主推)
	SDB_CTS_REVIEW 					       = "50126",                           ---! 上局回顾
    SDB_STC_NOTICE_PLAYER_READY            = "50127",                           ---! 通知所有玩家能不能准备
    SDB_STC_IS_DISMISS_ROOM                = "50128",                           ---! 断线重连后，主推是否正在解散房间（所有玩家的是否同意状态）
	SDB_STC_INFROM_NODEED_CARDS			   = "50129",                           ---! 收到广播某个玩家不要牌

	SDB_STC_OFFLINE                        = "50195",							---! 离线状态
	SDB_CTS_REQUEST_ROOM_INFO  			   = "50196",							---! 请求房间信息
	SDB_GAME_PROCESS                       = "50199",						    ---! 游戏进程（倒计时）
	-------------------------------------------------------------------------------------------------------
	SDBLoadEnd	                           = "C_SDBSDBLoadEnd",                 ---! 加载面板结束
	PokerStyleType  					   = "C_SDBPokerStyleType",             ---! 扑克牌样式
    DeskStypleType                         = "C_SDBDeskStypleType",             ---! 桌面样式
	SDBBackMusic                           = "C_SDBBackMusic",                  ---! 十点半背景音曲目
}

NoIgnoreAction = {
	SDBLoadEnd	                           = "SDBLoadEnd",                      ---! 加载面板结束
	SDB_STC_JOIN_ROOM                      = "50194",							---! 加入房间回复	
}