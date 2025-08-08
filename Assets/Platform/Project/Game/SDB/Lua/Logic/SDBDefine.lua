
local controller = "AB/SDB/Lua/Controller/"
local SDBViewPath = "AB/SDB/Lua/View/"

SDBCtrlNames = {
    Operation = controller .. "SDBOperationCtrl",
    Room = controller .. "SDBRoomCtrl",
}

--十点半ab包名
SDBBundleName = {
	sdbPanels = "sdb/panels",
    sdbsound = "sdb/sound",
    sdbMusic = "sdb/bgm",
	chat = "sdb/chat",
}

SDBPanelConfig = {
	LoadRes = {path = SDBViewPath, bundleName = SDBBundleName.sdbPanels, assetName = "SDBLoadResPanel", layer = 4, isSpecial = true},
	Dismiss = {path = SDBViewPath, bundleName = SDBBundleName.sdbPanels, assetName = "SDBDismissPanel", layer = 4},
	Room = {path = SDBViewPath, bundleName = SDBBundleName.sdbPanels, assetName = "SDBRoomPanel", layer = 2, isSpecial = true},
	Operation = {path = SDBViewPath, bundleName = SDBBundleName.sdbPanels, assetName = "SDBOperationPanel", layer = 3, isSpecial = true},
	SdbDesk = {path = SDBViewPath, bundleName = SDBBundleName.sdbPanels, assetName = "SDBDeskPanel", layer = 1, isSpecial = true},
	RoomInfo = {path = SDBViewPath, bundleName = SDBBundleName.sdbPanels, assetName = "SDBRoomInfoPanel", layer = 4},
	RoomSetup = {path = SDBViewPath, bundleName = SDBBundleName.sdbPanels, assetName = "SDBRoomSetupPanel", layer = 3},
	GoldReview = {path = SDBViewPath, bundleName = SDBBundleName.sdbPanels, assetName = "SDBGoldReviewPanel", layer = 3},
	Review = {path = SDBViewPath, bundleName = SDBBundleName.sdbPanels, assetName = "SDBReviewPanel", layer = 3},
	gameOver = {path = SDBViewPath, bundleName = SDBBundleName.sdbPanels, assetName = "SDBGameOverPanel", layer = 4},
	JieSuan = {path = SDBViewPath, bundleName = SDBBundleName.sdbPanels, assetName = "SDBJieSuanPanel", layer = 4}, 
	Playback =  {path = SDBViewPath, bundleName = SDBBundleName.sdbPanels, assetName = "SDBPlaybackPanel", layer = 4}
}

SDBMusics = {
	"table_bgm1",
	"table_bgm2",
	"table_bgm3",
	"table_bgm4"
}

SDBVolumeScale = {
    -- Music = 0.1, --音乐音量缩放 
	-- Sound = 0.4--音效音量缩放
	Music = 1, --音乐音量缩放 
    Sound = 1 --音效音量缩放
}

--玩家状态
PlayerState = {
	--坐下
	Ready = 1,
	--观看（未准备，未坐下）
	LookOn = 2,
	--站立（未准备，已坐下）
	Stand = 3,
	--游戏中
	Gaming = 4,
}

--游戏状态
SDBGameState = {
	--准备阶段
	Ready = 1,
	--抢庄阶段
	RobBanker = 2,
	--下注阶段
	BetState = 3,
	--发牌阶段
	SendCard = 4,
}	

--发牌类型
SDBSendCardsType = {
	--正常发牌
	Normal = 0,
	--搓牌
	RubCards = 1,
	--要牌
	GetCards = 2,
	--断线重连，发出全部牌
	Reconnection = 3,
	--特殊牌型，发出全部牌
	SpecialCard = 4,
}

SDBCardType = {
	--爆点
	[1] = "BoomCards",
	[2] = "", --平点
	[3] = "wuxiao",
	[4] = "res_10_5",
	[5] = "tianwang",
	[6] = "renwuxiao",
}

--操作牌的类型
SDBOperationCardType = {
	NoGet = 0, --不要
	RubCard = 1, --搓牌
	GetCard = 2, --要牌
	ShowCard = 3, --搓完牌后调用
}

--倒计时显示类型
CountOperationType = {
	Ready = 1,
	RobBanker = 2,
	BetScore = 3,
	GetCard = 4,
	Dismiss = 5,
	ReadyQuit = 6,
	Start = 7,
}

--桌面颜色
SdbDeskImageColor = {
	green = 1,
	grey = 2,
	purple = 3,
	blue = 4,
}

--扑克牌颜色
PokerCardColor = {
	--橙色
	orange = 1,
	--蓝色
	blue = 2,
	--绿色
	green = 3,
	--红色
	red = 4,
}

--抢庄倍数
RobZhuangNumType = {
	--无
	None = - 1,
	--不抢
	NoRob = 0,
	--抢庄
	Rob = 1,
	--抢1倍
	RobOne = 1,
	--抢2倍
	RobTow = 2,
	--抢3倍
	RobThree = 3,
	--抢4倍
	RobFour = 4,
}

--更新玩家信息类型
UpdatePlayerInfoType = {
	Join = 1,
	Leave = 2,
}

--十点半牌资源类型
SDBCardSpritesType = {
	--手牌
	HandleCards = 1,
	--搓牌
	CubCards = 2,
	--结算资源
	Result = 3,
	--小牌
	SmallCards = 4,
}

----------------------------------------------------------------------------------------------------
--聊天文字
SDBChatLabelArr = {
	[LanguageType.putonghua] = {
		[Global.GenderType.Male] = {
			{text = "请你吃爆米花！", audio = "nm_fsdb_1"},
			{text = "搏一搏，单车变摩托。", audio = "nm_fsdb_2"},
			{text = "重注是朋友，使劲推注吧", audio = "nm_fsdb_3"},
			{text = "快点儿啊！我等到花儿都谢了。", audio = "nm_fsdb_4"},
			{text = "时间就是金钱，我的朋友。", audio = "nm_fsdb_5"},
			{text = "压的多吃火锅，压的少吃青草", audio = "nm_fsdb_6"},
			{text = "富二代上庄，有车有房，还有大鱼坊", audio = "nm_fsdb_7"},
		},
		[Global.GenderType.Female] = {
			{text = "请你吃爆米花！", audio = "nw_fsdb_1"},
			{text = "搏一搏，单车变摩托。", audio = "nw_fsdb_2"},
			{text = "重注是朋友，使劲推注吧", audio = "nw_fsdb_3"},
			{text = "快点儿啊！我等到花儿都谢了。", audio = "nw_fsdb_4"},
			{text = "时间就是金钱，我的朋友。", audio = "nw_fsdb_5"},
			{text = "压的多吃火锅，压的少吃青草", audio = "nw_fsdb_6"},
			{text = "富二代上庄，有车有房，还有大鱼坊", audio = "nw_fsdb_7"},
		}
	}
}

-----------------------------------------------玩法配置---------------------------------------------
SDBGameType_CONFIG = {
	[1] = {
		name = "轮流当庄"
	},
	[2] = {
		name = "房主当庄"
	},
	[3] = {
		name = "自由抢庄"
	},
	[4] = {
		name = "明牌抢庄"
	}
}
-----------------------------------------------底分配置---------------------------------------------
SDBGameDiFen_CONFIG = {
	[1] = {
		name = "2/4/6/8"
	},
	[2] = {
		name = "5/10/15/20"
	},
	[3] = {
		name = "1/2/4/6"
	},
}
-----------------------------------------------人数配置---------------------------------------------
SDBGamePlayerCount_CONFIG = {
	[1] = {
		name = "4人",
		value = 4,
	},
	[2] = {
		name = "6人",
		value = 6,
	},
	[3] = {
		name = "8人",
		value = 8,
	},
}
----------------------------------------------局数配置---------------------------------------------
SDBGameCount_CONFIG = {
	[1] = {
		name = "15", fangzhuPay = "房主支付（3房卡）", AAPay = "AA支付（每人1房卡）"
	},
	[2] = {
		name = "20", fangzhuPay = "房主支付（5房卡）", AAPay = "AA支付（每人2房卡）"
	},
	[3] = {
		name = "30", fangzhuPay = "房主支付（7房卡）", AAPay = "AA支付（每人3房卡）"
	},
	[4] = {
		name = "无限", fangzhuPay = "", AAPay = ""
	}
}
-----------------------------------------------模式配置---------------------------------------------
SDBGameModel_CONFIG = {
	[1] = {
		name = "传统"
	},
	[2] = {
		name = "癞子"
	},
	[3] = {
	    name = "底牌无癞子"
	},
}
-----------------------------------------------开始选项---------------------------------------------
SDBGameStart_CONFIG = {
	[1] = {
		[1] = {name = "手动开始", value = 0}, [2] = {name = "满4人开", value = 4}, [3] = {name = "满6人开", value = 6}, [4] = {name = "满8人开", value = 8}
	},
	[2] = {
		[1] = {name = "手动开始", value = 0}, [2] = {name = "满4人开", value = 4}, [3] = {name = "满6人开", value = 6}, [4] = {name = "满8人开", value = 8}
	},
	[3] = {
		[1] = {name = "手动开始", value = 0}, [2] = {name = "满4人开", value = 4}, [3] = {name = "满6人开", value = 6}, [4] = {name = "满8人开", value = 8}
	},
	[4] = {
		[1] = {name = "手动开始", value = 0}, [2] = {name = "满4人开", value = 4}, [3] = {name = "满6人开", value = 6}, [4] = {name = "满8人开", value = 8}
	}
}
-----------------------------------------------倍率---------------------------------------------
SDBGameMultiple_CONFIG = {
	[1] = {
		name = "1倍",
		value = 1,
	},
	[2] = {
		name = "2倍",
		value = 2,
	},
	[3] = {
		name = "3倍",
		value = 3,
	},
	[4] = {
		name = "4倍",
		value = 4,
	},
}
-----------------------------------------------推注选项---------------------------------------------
SDBGameTuizhu_CONFIG = {
	[1] = {
		name = "无"
	},
	[2] = {
		name = "5倍"
	},
	[3] = {
		name = "10倍"
	},
	[4] = {
		name = "15倍"
	},
}
-----------------------------------------------高级选项---------------------------------------------
SDBGameHighLevel_CONFIG = {
	[1] = {name = '游戏开始后禁止加入', value = 0},
	[2] = {name = '禁止搓牌', value = 1},
	[3] = {name = '庄家翻倍', value = 2},
	[4] = {name = '同点庄胜', value = 4},
	[5] = {name = '下注限制', value = 3},
}
-----------------------------------------------支付类型---------------------------------------------
SDBGamePayType = {
	[1] = {name = "房主付"},
	[2] = {name = "AA付"},
	[3] = {name = "亲友圈房卡"},
}
-----------------------------------------------支付id---------------------------------------------
SDBPlayCardId ={
	[15]= {
		[4] = 10001,
		[6] = 10002,
		[8] = 10003,
	},
	[20] = {
		[4] = 10004,
		[6] = 10005,
		[8] = 10006,
	},
	[30] = {
		[4] = 10007,
		[6] = 10008,
		[8] = 10009,
	}
}

--结算 类型读取表
SDBPointType = {
	[0.5] = "res_0_5",
	[1] = "res_1",
	[1.5] = "res_1_5",
	[2] = "res_2",
	[2.5] = "res_2_5",
	[3] = "res_3",
	[3.5] = "res_3_5",
	[4] = "res_4",
	[4.5] = "res_4_5",
	[5] = "res_5",
	[5.5] = "res_5_5",
	[6] = "res_6",
	[6.5] = "res_6_5",
	[7] = "res_7",
	[7.5] = "res_7_5",
	[8] = "res_8",
	[8.5] = "res_8_5",
	[9] = "res_9",
	[9.5] = "res_9_5",
	[10] = "res_10",
}

--游戏类型
SDBGameType = {
    --轮流庄家
    TAKE_TURNS_BANKER = 1,
    --房主当庄
    OWNERS_BANKER = 2,
    --自由抢庄
    FREE_ROB_BANKER = 3,
    --明牌抢庄
    MINGPAI_ROB_BANKER = 4,
}
