local controller = "AB/LYC/Lua/Controller/"
local LYCViewPath = "AB/LYC/Lua/View/"

LYCCtrlNames = {
    Room = controller .. "LYCRoomCtrl",
}

--捞腌菜 ab包名
LYCBundleName = {
    lycPanels = "lyc/panels",
    lycsound = "lyc/sound",
    lycMusic = "lyc/bgm",
    chat = "lyc/chat",
}

LYCPanelConfig = {
    LoadRes = { path = LYCViewPath, bundleName = LYCBundleName.lycPanels, assetName = "LYCLoadResPanel", layer = 4, isSpecial = true },
    Dismiss = { path = LYCViewPath, bundleName = LYCBundleName.lycPanels, assetName = "LYCDismissPanel", layer = 4 },
    Room = { path = LYCViewPath, bundleName = LYCBundleName.lycPanels, assetName = "LYCRoomPanel", layer = 2, isSpecial = true },
    Operation = { path = LYCViewPath, bundleName = LYCBundleName.lycPanels, assetName = "LYCOperationPanel", layer = 3, isSpecial = true },
    LYCDesk = { path = LYCViewPath, bundleName = LYCBundleName.lycPanels, assetName = "LYCDeskPanel", layer = 1, isSpecial = true },
    RoomInfo = { path = LYCViewPath, bundleName = LYCBundleName.lycPanels, assetName = "LYCRoomInfoPanel", layer = 4 },
    LYCWatcherList = { path = LYCViewPath, bundleName = LYCBundleName.lycPanels, assetName = "LYCWatcherListPanel", layer = 4 },
    RoomSetup = { path = LYCViewPath, bundleName = LYCBundleName.lycPanels, assetName = "LYCRoomSetupPanel", layer = 3 },
    GameOver = { path = LYCViewPath, bundleName = LYCBundleName.lycPanels, assetName = "LYCGameOverPanel", layer = 4 },
    JieSuan = { path = LYCViewPath, bundleName = LYCBundleName.lycPanels, assetName = "LYCJieSuanPanel", layer = 5 },
    Playback = { path = LYCViewPath, bundleName = LYCBundleName.lycPanels, assetName = "LYCPlaybackPanel", layer = 4 },
    AwardPool = { path = LYCViewPath, bundleName = LYCBundleName.lycPanels, assetName = "LYCAwardPoolDetailPanel", layer = 4 }
}

LYCMusics = {
    "table_bgm1",
    "table_bgm2",
    "table_bgm3",
    "table_bgm4"
}

LYCVolumeScale = {
    Music = 1, --音乐音量缩放 
    Sound = 1 --音效音量缩放
}

--玩家牌局状态
LYCPlayerState = {
    NONE = 0,
    --等待玩家加入
    WAITING = 1,
    --待准备状态
    NO_READY = 2,
    --准备完成  
    READY = 3,
    --等待游戏开始
    WAITING_START = 4,
    --等待别人操作
    WAIT = 5,
    --操作中
    OPTION = 6,
    --结算中
    CALCULATE = 7,
}

--房间状态
LYCGameState = {
    WAITTING = 1, --等待玩家加入
    FaPai = 2, --等待玩家加入
    ROB_ZHUANG = 3, --抢庄阶段
    BETTING = 4, --下注阶段
    WATCH_CARD_1 = 5, --看牌阶段1 等待庄家操作
    WATCH_CARD_2 = 6, --看牌阶段2 等待闲家操作
    COMPARE_CARD = 7, ---玩家操作阶段，庄家捞完牌后还有一个比牌阶段
    CALCULATE = 8, --结算中
    OVER = 9, --房间结束
}

--操作牌的类型
LYCOperationCardType = {
    NoGet = 0, --不要
    RubCard = 1, --搓牌
    GetCard = 2, --要牌
    ShowCard = 3, --亮牌
    TipCard = 4, --提示牌
    FilpCard = 5, --翻牌
}

--倒计时显示类型
CountOperationType = {
    Ready = 1, --准备倒计时
    RobBanker = 2, --抢庄倒计时
    BetScore = 3, --下注倒计时
    GetCard = 4, --要牌倒计时
    Dismiss = 5, --解散倒计时
    ReadyQuit = 6, --开局倒计时
    Start = 7, --准备倒计时
}

--桌面颜色
LYCDeskImageColor = {
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
    None = -1,
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
    RobFour = 4
}

----------------------------------------------------------------------------------------------------
--聊天文字
LYCChatLabelArr = {
    [LanguageType.putonghua] = {
        [Global.GenderType.Male] = {
            { text = "别跟我抢庄，小心玩死你们！", audio = "chat_m_0" },
            { text = "喂，赶紧亮牌，别墨迹！", audio = "chat_m_1" },
            { text = "搏一搏，单车变摩托。", audio = "chat_m_2" },
            { text = "快点儿啊！我等到花儿都谢了。", audio = "chat_m_3" },
            { text = "时间就是金钱，我的朋友。", audio = "chat_m_4" },
            { text = "不要因为我是娇花怜惜我，使劲推注吧", audio = "chat_m_5" },
            -- { text = "我是十大炮，我怕谁！", audio = "chat_m_6" },
            -- { text = "大牛吃小牛，哈哈哈。", audio = "chat_m_7" },
            { text = "下的多输的多，小心推注当内裤。", audio = "chat_m_8" },
            { text = "有没有天理，有没有王法，这牌也输？", audio = "chat_m_9" },
            { text = "一点小钱，拿去喝茶吧。", audio = "chat_m_10" },
            { text = "不好意思，全赢！", audio = "chat_m_11" },
            { text = "真倒霉，全输。", audio = "chat_m_12" },
        },
        [Global.GenderType.Female] = {
            { text = "别跟我抢庄，小心玩死你们！", audio = "chat_w_0" },
            { text = "喂，赶紧亮牌，别墨迹！", audio = "chat_w_1" },
            { text = "搏一搏，单车变摩托。", audio = "chat_w_2" },
            { text = "快点儿啊！我等到花儿都谢了。", audio = "chat_w_3" },
            { text = "时间就是金钱，我的朋友。", audio = "chat_w_4" },
            { text = "不要因为我是娇花怜惜我，使劲推注吧", audio = "chat_w_5" },
            -- { text = "我是十大炮，我怕谁！", audio = "chat_w_6" },
            -- { text = "大牛吃小牛，哈哈哈。", audio = "chat_w_7" },
            { text = "下的多输的多，小心推注当内裤。", audio = "chat_w_8" },
            { text = "有没有天理，有没有王法，这牌也输？", audio = "chat_w_9" },
            { text = "一点小钱，拿去喝茶吧。", audio = "chat_w_10" },
            { text = "不好意思，全赢！", audio = "chat_w_11" },
            { text = "真倒霉，全输。", audio = "chat_w_12" },
        }
    }
}

----------------------------------------------------------------------------------
--血战到底
--主玩家手牌间距
LYCMainPlayerCardInv = {
    Normal = 143, --174.2, --正常间距 134*1.3
    Shrink = 96.2, --收缩间距 74*1.3
    ThreeBinary = 33.8, --三二分间距
}

--通用特效
LYCAniCardComType = "CommonEffect"

---牌結果倍数
LYCCardTypeMultiply = {
    "bei11",
    "bei12",
    "bei13",
    "bei14",
    "bei15",
    "bei16",
    "bei17",
    "bei18",
    "bei19",
    "bei110",
}

--牌结果类型
LYCCardType = {
    [1] = {
        ["0"] = "0",
        ["1"] = "1",
        ["2"] = "2",
        ["3"] = "3",
        ["4"] = "4",
        ["5"] = "5",
        ["6"] = "6",
        ["7"] = "7",
        ["8"] = "8",
        ["9"] = "9",
        ["10"] = "10",
    },
    [2] = {
        ["0"] = "lyc_result_0",
        ["1"] = "lyc_result_1",
        ["2"] = "lyc_result_2",
        ["3"] = "lyc_result_3",
        ["4"] = "lyc_result_4",
        ["5"] = "lyc_result_5",
        ["6"] = "lyc_result_6",
        ["7"] = "lyc_result_7_2",
        ["8"] = "lyc_result_8_2",
        ["9"] = "lyc_result_9_3",
        ["10"] = "lyc_result_10_4",
        ["12"] = "lyc_result_12_6",
        ["13"] = "lyc_result_13_6",
        ["14"] = "lyc_result_14_7",
        ["15"] = "lyc_result_15_8",
        ["16"] = "lyc_result_16_9",
        ["17"] = "lyc_result_17_10",
        ["18"] = "lyc_result_18_10",
    },
    [3] = {
        ["0"] = "lyc_result_0",
        ["1"] = "lyc_result_1",
        ["2"] = "lyc_result_2",
        ["3"] = "lyc_result_3",
        ["4"] = "lyc_result_4",
        ["5"] = "lyc_result_5",
        ["6"] = "lyc_result_6",
        ["7"] = "lyc_result_7_2",
        ["8"] = "lyc_result_8_3",
        ["9"] = "lyc_result_9_4",
        ["10"] = "lyc_result_10_5",
        ["12"] = "lyc_result_12_10",
        ["13"] = "lyc_result_13_10",
        ["14"] = "lyc_result_14_10",
        ["15"] = "lyc_result_15_10",
        ["16"] = "lyc_result_16_10",
        ["17"] = "lyc_result_17_10",
        ["18"] = "lyc_result_18_10",
    },
    [4] = {
        ["0"] = "lyc_result_0",
        ["1"] = "lyc_result_1",
        ["2"] = "lyc_result_2_2",
        ["3"] = "lyc_result_3_3",
        ["4"] = "lyc_result_4_4",
        ["5"] = "lyc_result_5_5",
        ["6"] = "lyc_result_6_6",
        ["7"] = "lyc_result_7_7",
        ["8"] = "lyc_result_8_8",
        ["9"] = "lyc_result_9_9",
        ["10"] = "lyc_result_10_10",
        ["12"] = "lyc_result_12_11",
        ["13"] = "lyc_result_13_11",
        ["14"] = "lyc_result_14_12",
        ["15"] = "lyc_result_15_13",
        ["16"] = "lyc_result_16_14",
        ["17"] = "lyc_result_17_15",
        ["18"] = "lyc_result_18_15",
    },
}
--todo 缺少特殊炮x10的结果图片
--缩牌模式
LYCShrinkType = {
    None = 1,
    Shrink = 2,
    ThreeBinary = 3,
}

--血战到底错误码
LYCStatusCode = {
    --成功
    [0] = "成功",
    --失败
    [-1] = "失败",
    --玩家退出房间失败
    [9] = "退出房间失败",
    --退出房间失败 已经开局
    [10] = "游戏已开始，无法离开游戏",
    --房主退出房间解散房间
    [11] = "房主解散房间",
    --玩家操作失败  玩家不是操作状态
    [108] = "操作失败",
    --玩家需要等待别的玩家操作
    [109] = "请先等待其他玩家操作",
    --不能操作
    [201] = "无法操作",
    --抢庄倍数错误
    [101] = "抢庄倍数错误",
    --投注分数不合理
    [102] = "投注分数不合理",
    --不能下最低注 因为参与了抢庄
    [103] = "不能下最低注",
    --准备失败金豆不足
    [104] = "准备失败，金豆不足",
    --观战超过三局
    [105] = "观战超过三局，自动退出房间",
}

LYCOperateDefine = {
    None = 0,
    LaoPai = 1, --捞
    BiPai = 2, --比牌
    ZhaKai = 3, --爆牌（炸开）
}