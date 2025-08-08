local controller = "AB/Pin5/Lua/Controller/"
local Pin5ViewPath = "AB/Pin5/Lua/View/"

Pin5CtrlNames = {
    Room = controller .. "Pin5RoomCtrl",
}

--拼五 ab包名
Pin5BundleName = {
    pin5Panels = "pin5/panels",
    pin5sound = "pin5/sound",
    pin5Music = "pin5/bgm",
    chat = "pin5/chat",
}

Pin5PanelConfig = {
    LoadRes = { path = Pin5ViewPath, bundleName = Pin5BundleName.pin5Panels, assetName = "Pin5LoadResPanel", layer = 4, isSpecial = true },
    Dismiss = { path = Pin5ViewPath, bundleName = Pin5BundleName.pin5Panels, assetName = "Pin5DismissPanel", layer = 4 },
    Room = { path = Pin5ViewPath, bundleName = Pin5BundleName.pin5Panels, assetName = "Pin5RoomPanel", layer = 2, isSpecial = true },
    Operation = { path = Pin5ViewPath, bundleName = Pin5BundleName.pin5Panels, assetName = "Pin5OperationPanel", layer = 3, isSpecial = true },
    Pin5Desk = { path = Pin5ViewPath, bundleName = Pin5BundleName.pin5Panels, assetName = "Pin5DeskPanel", layer = 1, isSpecial = true },
    RoomInfo = { path = Pin5ViewPath, bundleName = Pin5BundleName.pin5Panels, assetName = "Pin5RoomInfoPanel", layer = 4 },
    Pin5WatcherList = { path = Pin5ViewPath, bundleName = Pin5BundleName.pin5Panels, assetName = "Pin5WatcherListPanel", layer = 4 },
    RoomSetup = { path = Pin5ViewPath, bundleName = Pin5BundleName.pin5Panels, assetName = "Pin5RoomSetupPanel", layer = 3 },
    GameOver = { path = Pin5ViewPath, bundleName = Pin5BundleName.pin5Panels, assetName = "Pin5GameOverPanel", layer = 4 },
    JieSuan = { path = Pin5ViewPath, bundleName = Pin5BundleName.pin5Panels, assetName = "Pin5JieSuanPanel", layer = 5 },
    Playback = { path = Pin5ViewPath, bundleName = Pin5BundleName.pin5Panels, assetName = "Pin5PlaybackPanel", layer = 4 },
    AwardPool = { path = Pin5ViewPath, bundleName = Pin5BundleName.pin5Panels, assetName = "Pin5AwardPoolDetailPanel", layer = 4 }
}

Pin5Musics = {
    "table_bgm1",
    "table_bgm2",
    "table_bgm3",
    "table_bgm4"
}

Pin5VolumeScale = {
    Music = 1, --音乐音量缩放 
    Sound = 1 --音效音量缩放
}

--玩家牌局状态
Pin5PlayerState = {
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
Pin5GameState = {
    WAITTING = 1, --等待玩家加入
    ROB_ZHUANG = 2, --抢庄阶段
    BETTING = 3, --下注阶段
    WATCH_CARD = 4, --看牌阶段
    CALCULATE = 5, --结算中
    OVER = 6, --房间结束
}

--操作牌的类型
Pin5OperationCardType = {
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
Pin5DeskImageColor = {
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
Pin5ChatLabelArr = {
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
---
--主玩家手牌间距
Pin5MainPlayerCardInv = {
    Normal = 121, --
    Shrink = 50, --收缩间距
    ThreeBinary = 22, --三二分间距，多增加的间隔
}

--通用特效
Pin5AniCardComType = "CommonEffect"

--牌结果类型
Pin5CardType = {
    [1] = {
        ["0"] = "pin5_result_0",
        ["1"] = "pin5_result_1",
        ["2"] = "pin5_result_2",
        ["3"] = "pin5_result_3",
        ["4"] = "pin5_result_4",
        ["5"] = "pin5_result_5",
        ["6"] = "pin5_result_6",
        ["7"] = "pin5_result_7",
        ["8"] = "pin5_result_8_2",
        ["9"] = "pin5_result_9_2",
        ["10"] = "pin5_result_10_3",
        ["12"] = "pin5_result_12_5",
        ["13"] = "pin5_result_13_5",
        ["14"] = "pin5_result_14_6",
        ["15"] = "pin5_result_15_7",
        ["16"] = "pin5_result_16_8",
        ["17"] = "pin5_result_17_9",
        ["18"] = "pin5_result_18_10",
    },
    [2] = {
        ["0"] = "pin5_result_0",
        ["1"] = "pin5_result_1",
        ["2"] = "pin5_result_2",
        ["3"] = "pin5_result_3",
        ["4"] = "pin5_result_4",
        ["5"] = "pin5_result_5",
        ["6"] = "pin5_result_6",
        ["7"] = "pin5_result_7_2",
        ["8"] = "pin5_result_8_2",
        ["9"] = "pin5_result_9_3",
        ["10"] = "pin5_result_10_4",
        ["12"] = "pin5_result_12_6",
        ["13"] = "pin5_result_13_6",
        ["14"] = "pin5_result_14_7",
        ["15"] = "pin5_result_15_8",
        ["16"] = "pin5_result_16_9",
        ["17"] = "pin5_result_17_10",
        ["18"] = "pin5_result_18_10",
    },
    [3] = {
        ["0"] = "pin5_result_0",
        ["1"] = "pin5_result_1",
        ["2"] = "pin5_result_2",
        ["3"] = "pin5_result_3",
        ["4"] = "pin5_result_4",
        ["5"] = "pin5_result_5",
        ["6"] = "pin5_result_6",
        ["7"] = "pin5_result_7_2",
        ["8"] = "pin5_result_8_3",
        ["9"] = "pin5_result_9_4",
        ["10"] = "pin5_result_10_5",
        ["12"] = "pin5_result_12_10",
        ["13"] = "pin5_result_13_10",
        ["14"] = "pin5_result_14_10",
        ["15"] = "pin5_result_15_10",
        ["16"] = "pin5_result_16_10",
        ["17"] = "pin5_result_17_10",
        ["18"] = "pin5_result_18_10",
    },
    [4] = {
        ["0"] = "pin5_result_0",
        ["1"] = "pin5_result_1",
        ["2"] = "pin5_result_2_2",
        ["3"] = "pin5_result_3_3",
        ["4"] = "pin5_result_4_4",
        ["5"] = "pin5_result_5_5",
        ["6"] = "pin5_result_6_6",
        ["7"] = "pin5_result_7_7",
        ["8"] = "pin5_result_8_8",
        ["9"] = "pin5_result_9_9",
        ["10"] = "pin5_result_10_10",
        ["12"] = "pin5_result_12_11",
        ["13"] = "pin5_result_13_11",
        ["14"] = "pin5_result_14_12",
        ["15"] = "pin5_result_15_13",
        ["16"] = "pin5_result_16_14",
        ["17"] = "pin5_result_17_15",
        ["18"] = "pin5_result_18_15",
    },
}


Pin5CardTypeValue = {
    [1] = {
        ["0"] = "0",
        ["1"] = "1",
        ["2"] = "1",
        ["3"] = "1",
        ["4"] = "1",
        ["5"] = "1",
        ["6"] = "1",
        ["7"] = "1",
        ["8"] = "2",
        ["9"] = "2",
        ["10"] = "3",
        ["12"] = "5",
        ["13"] = "5",
        ["14"] = "6",
        ["15"] = "7",
        ["16"] = "8",
        ["17"] = "9",
        ["18"] = "10",
    },
    [2] = {
        ["0"] = "0",
        ["1"] = "1",
        ["2"] = "1",
        ["3"] = "1",
        ["4"] = "1",
        ["5"] = "1",
        ["6"] = "1",
        ["7"] = "2",
        ["8"] = "2",
        ["9"] = "3",
        ["10"] = "4",
        ["12"] = "6",
        ["13"] = "6",
        ["14"] = "7",
        ["15"] = "8",
        ["16"] = "9",
        ["17"] = "10",
        ["18"] = "10",
    },
    [3] = {
        ["0"] = "0",
        ["1"] = "1",
        ["2"] = "1",
        ["3"] = "1",
        ["4"] = "1",
        ["5"] = "1",
        ["6"] = "1",
        ["7"] = "2",
        ["8"] = "3",
        ["9"] = "4",
        ["10"] = "5",
        ["12"] = "10",
        ["13"] = "10",
        ["14"] = "10",
        ["15"] = "10",
        ["16"] = "10",
        ["17"] = "10",
        ["18"] = "10",
    },
    [4] = {
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
        ["12"] = "11",
        ["13"] = "11",
        ["14"] = "12",
        ["15"] = "13",
        ["16"] = "14",
        ["17"] = "15",
        ["18"] = "15",
    },
}

--牌结果类型动画名称
Pin5CardTypeAnimName = {
    [1] = {
        ["0"] = "WN",
        ["1"] = "N1",
        ["2"] = "N2",
        ["3"] = "N3",
        ["4"] = "N4",
        ["5"] = "N5",
        ["6"] = "N6",
        ["7"] = "N7",
        ["8"] = "N8X2",
        ["9"] = "N9X2",
        ["10"] = "NNX3",
        ["12"] = "SZNX5",
        ["13"] = "WHNX5",
        ["14"] = "THNX6",
        ["15"] = "HLNX7",
        ["16"] = "ZDNX8",
        ["17"] = "WXNX9",
        ["18"] = "THSX10",
    },
    [2] = {
        ["0"] = "WN",
        ["1"] = "N1",
        ["2"] = "N2",
        ["3"] = "N3",
        ["4"] = "N4",
        ["5"] = "N5",
        ["6"] = "N6",
        ["7"] = "N7X2",
        ["8"] = "N8X2",
        ["9"] = "N9X3",
        ["10"] = "NNX4",
        ["12"] = "SZNX6",
        ["13"] = "WHNX6",
        ["14"] = "THNX7",
        ["15"] = "HLNX8",
        ["16"] = "ZDNX9",
        ["17"] = "WXNX10",
        ["18"] = "THSX10",
    },
    [3] = {
        ["0"] = "WN",
        ["1"] = "N1",
        ["2"] = "N2",
        ["3"] = "N3",
        ["4"] = "N4",
        ["5"] = "N5",
        ["6"] = "N6",
        ["7"] = "N7X2",
        ["8"] = "N8X3",
        ["9"] = "N9X4",
        ["10"] = "NNX5",
        ["12"] = "SZNX10",
        ["13"] = "WHNX10",
        ["14"] = "THNX10",
        ["15"] = "HLNX10",
        ["16"] = "ZDNX10",
        ["17"] = "WXNX10",
        ["18"] = "THSX10",
    },
    [4] = {
        ["0"] = "WN",
        ["1"] = "N1",
        ["2"] = "N2X2",
        ["3"] = "N3X3",
        ["4"] = "N4X4",
        ["5"] = "N5X5",
        ["6"] = "N6X6",
        ["7"] = "N7X7",
        ["8"] = "N8X8",
        ["9"] = "N9X9",
        ["10"] = "NNX10",
        ["12"] = "SZNX11",
        ["13"] = "WHNX11",
        ["14"] = "THNX12",
        ["15"] = "HLNX13",
        ["16"] = "ZDNX14",
        ["17"] = "WXNX15",
        ["18"] = "THSX15",
    },
}

--todo 缺少特殊炮x10的结果图片
--缩牌模式
Pin5ShrinkType = {
    None = 1,
    Shrink = 2,
    ThreeBinary = 3,
}

--血战到底错误码
Pin5StatusCode = {
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