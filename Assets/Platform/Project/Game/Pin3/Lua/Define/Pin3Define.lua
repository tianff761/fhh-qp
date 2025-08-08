local pin3ViewPath = "AB/Pin3/Lua/View/"
Pin3Panels = {}
Pin3BundleNames = {
    panelBundle = "pin3/panels",
    otherBundle = "pin3/otherprefabs",
    audioBundle = "pin3/audio",
    musicBundle = "pin3/music",
    chatBundle = "pin3/chat",
}

Pin3Panels.pin3BattlePanel = "Pin3BattlePanel"
Pin3Panels.pin3SettingPanel = "Pin3SettingPanel"
Pin3Panels.pin3RulePanel = "Pin3RulePanel"
Pin3Panels.pin3DanJuJieSuanPanel = "Pin3DanJuJieSuanPanel"
Pin3Panels.pin3ZongJieSuanPanel = "Pin3JieSuanPanel"
Pin3Panels.jieShanRoomPanel = "Pin3DismissPanel"
Pin3Panels.Playback = "Pin3PlaybackPanel"

Pin3Panels.Pin3Battle = { path = pin3ViewPath, bundleName = Pin3BundleNames.panelBundle, assetName = Pin3Panels.pin3BattlePanel, layer = 1, isSpecial = true }
Pin3Panels.Pin3Setting = { path = pin3ViewPath, bundleName = Pin3BundleNames.panelBundle, assetName = Pin3Panels.pin3SettingPanel, layer = 4 }      --吃界面
Pin3Panels.Pin3Rule = { path = pin3ViewPath, bundleName = Pin3BundleNames.panelBundle, assetName = Pin3Panels.pin3RulePanel, layer = 4 }      --吃界面
Pin3Panels.Pin3DanJuJieSuan = { path = pin3ViewPath, bundleName = Pin3BundleNames.panelBundle, assetName = Pin3Panels.pin3DanJuJieSuanPanel, layer = 4 }      --吃界面
Pin3Panels.Pin3ZongJieSuan = { path = pin3ViewPath, bundleName = Pin3BundleNames.panelBundle, assetName = Pin3Panels.pin3ZongJieSuanPanel, layer = 4 }      --吃界面
Pin3Panels.Pin3DismissRoom = { path = pin3ViewPath, bundleName = Pin3BundleNames.panelBundle, assetName = Pin3Panels.jieShanRoomPanel, layer = 4 }      --吃界面
Pin3Panels.Pin3Playback = { path = pin3ViewPath, bundleName = Pin3BundleNames.panelBundle, assetName = Pin3Panels.Playback, layer = 3 } 

--广播定义
Pin3Broadcast = {}
Pin3Broadcast.BroadcastType = {
    --文本聊天
    TextChat = "txt",
    --输入文本聊 
    InuptChat = "ipt",
    --表情聊天(头像旁表情)
    EmotionChat = "emtn",
    --动画(发送给其他玩家的表情如鲜花、拖鞋、搬砖等)  
    ChatAnim = "anim",
    --说话聊天
    Speak = "sk",
    --gps位置
    Gps = "gps",
    --所有牌位置
    CardPositions = "cdpos",
}

Pin3GameStatus = {
    --等待玩家准备
    WaitingPrepare = 1,
    --发牌巴底
    FaPaiBaDi = 2,
    --等待玩家操作
    WaitingUserPerform = 3,
    --结算
    JieSuan = 4,
    --房间结束
    RoomEnd = 5,
}

--玩家操作类型
Pin3UserOperType = {
    NONE = 0,
    KanPai = 1,
    QiPai = 2,
    BiPai = 3,
    GenZhu = 4,
    JiaZhu = 5,
    LiangPai = 6,
    --轮数结束后强制比牌
    ForceBiPai = 7,
}

--房间快捷语
Pin3QuickLanguage = {
    [LanguageType.sichuan] = {
        [Global.GenderType.Male] = {
            { text = "您的牌打得也忒好啦！", audio = "msg_1" },
            { text = "抱歉，有要紧事儿要离开一下。", audio = "msg_2" },
            { text = "加个好友吧，能告诉我联系方式吗？", audio = "msg_3" },
            { text = "不好意思，网络太差啦！", audio = "msg_4" },
            { text = "青山不改，绿水长流，咱们明日再战！", audio = "msg_5" },
            { text = "大家好，很高兴和你们打牌~", audio = "msg_6" },
            { text = "不要走，决战到天亮！", audio = "msg_7" },
            { text = "你再不快点，花儿都谢啦！", audio = "msg_8" },
        },
        [Global.GenderType.Female] = {
        }
    }
}

Pin3Error = {
    [100001] = "已经准备，不能退出游戏",
    [100002] = "当前非准备状态，不能准备",
    [100003] = "已经准备",
    [100004] = "没有参与游戏",
    [100005] = "当前不能进行此操作",
    [100006] = "当前不能进行此操作",
    [100007] = "当前不能进行此操作",
    [100008] = "押注金额不正确",
    [100009] = "金豆不足",
    [100010] = "押注金额不正确",
    [100011] = "金豆不足",
    [100012] = "当前不能进行此操作",
    [100013] = "当前必须闷牌",
    [100014] = "金豆不足",
    [100015] = "投入金额不对",
    [100016] = "比牌时金币不足",
    [100022] = "人数不足，不能开始游戏",
    [100031] = "玩家不存在",
    [100032] = "已经坐下了",
    [100033] = "没有空位",
    [100034] = "积分不足",
    [100035] = "最后三局不能坐下",
}

Pin3JiaZhuConfig = {
    --一级Key：表示封顶倍数
    --二级key:rank,表示等级，共1~10，每个等级对应不同颜色按钮
    --beiShu:倍数，表示底分的多少倍，此倍数为没看牌闷的倍数，看牌倍数x2
    [5] = {
        [1] = { beiShu = 1 },
        [2] = { beiShu = 2 },
        [3] = { beiShu = 3 },
        [4] = { beiShu = 4 },
        [5] = { beiShu = 5 },
    },
    [15] = {
        [1] = { beiShu = 1 },
        [2] = { beiShu = 2 },
        [3] = { beiShu = 3 },
        [4] = { beiShu = 4 },
        [5] = { beiShu = 5 },
        [6] = { beiShu = 8 },
        [7] = { beiShu = 10 },
        [8] = { beiShu = 11 },
        [9] = { beiShu = 12 },
        [10] = { beiShu = 15 }
    },
    [8] = {
        [1] = { beiShu = 1 },
        [2] = { beiShu = 2 },
        [3] = { beiShu = 4 },
        [4] = { beiShu = 6 },
        [5] = { beiShu = 8 },
    },
    [16] = {
        [1] = { beiShu = 1 },
        [2] = { beiShu = 2 },
        [3] = { beiShu = 4 },
        [4] = { beiShu = 8 },
        [5] = { beiShu = 16 },
    },
    [20] = {
        [1] = { beiShu = 1 },
        [2] = { beiShu = 2 },
        [3] = { beiShu = 3 },
        [4] = { beiShu = 5 },
        [5] = { beiShu = 6 },
        [6] = { beiShu = 8 },
        [7] = { beiShu = 10 },
        [8] = { beiShu = 12 },
        [9] = { beiShu = 15 },
        [10] = { beiShu = 20 }
    },
    [30] = {
        [1] = { beiShu = 1 },
        [2] = { beiShu = 2 },
        [3] = { beiShu = 4 },
        [4] = { beiShu = 6 },
        [5] = { beiShu = 8 },
        [6] = { beiShu = 12 },
        [7] = { beiShu = 15 },
        [8] = { beiShu = 16 },
        [9] = { beiShu = 24 },
        [10] = { beiShu = 30 }
    },
    [40] = {
        [1] = { beiShu = 1 },
        [2] = { beiShu = 2 },
        [3] = { beiShu = 5 },
        [4] = { beiShu = 10 },
        [5] = { beiShu = 15 },
        [6] = { beiShu = 20 },
        [7] = { beiShu = 25 },
        [8] = { beiShu = 30 },
        [9] = { beiShu = 35 },
        [10] = { beiShu = 40 }
    },
    [50] = {
        [1] = { beiShu = 1 },
        [2] = { beiShu = 2 },
        [3] = { beiShu = 4 },
        [4] = { beiShu = 6 },
        [5] = { beiShu = 8 },
        [6] = { beiShu = 10 },
        [7] = { beiShu = 20 },
        [8] = { beiShu = 30 },
        [9] = { beiShu = 40 },
        [10] = { beiShu = 50 }
    },
    [100] = {
        [1] = { beiShu = 1 },
        [2] = { beiShu = 2 },
        [3] = { beiShu = 4 },
        [4] = { beiShu = 8 },
        [5] = { beiShu = 10 },
        [6] = { beiShu = 20 },
        [7] = { beiShu = 40 },
        [8] = { beiShu = 60 },
        [9] = { beiShu = 80 },
        [10] = { beiShu = 100 }
    }
}

Pin3PaiXingConfig = {
    [0] = "无",
    [1] = "单张",
    [2] = "对子",
    [3] = "顺子",
    [4] = "同花",
    [5] = "同花顺",
    [6] = "飞机"
}
--------------------------------------------------------------------------------------------------
