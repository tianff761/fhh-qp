--注：operation   oper 定义结构：{targetId = 0, from = 0, oper = EqsOperation.Guo, id1 = 0, id2 = 0, id3 = 0}
local eqsViewPath   = "AB/ErQiShi/Lua/View/"
EqsPanels = {}
EqsPanels.bundleName            = "erqishi/panels"
EqsPanels.createRoomPanel       = "CreateEqsRoomPanel"
EqsPanels.eqsBattlePanel        = "EqsBattlePanel"
EqsPanels.baiPanel              = "BaiPanel"
EqsPanels.chiPanel              = "ChiPanel"
EqsPanels.eqsSettingPanel       = "EqsSettingPanel"
EqsPanels.eqsUserInfoPanel      = "EqsUserInfoPanel"
EqsPanels.rulePanel             = "RulePanel"
EqsPanels.danJuJieSuanPanel     = "DanJuJieSuanPanel"
EqsPanels.zongJieSuanPanel      = "ZongJieSuanPanel"
EqsPanels.jieShanRoomPanel      = "JieShanRoomPanel"
EqsPanels.eqsSuiJiQuanPanel     = "EqsSuiJiQuanPanel"


EqsPanels.EqsBattle          = {path = eqsViewPath,  bundleName = EqsPanels.bundleName, assetName = EqsPanels.eqsBattlePanel,        layer = 1, isSpecial = true}
EqsPanels.EqsMap             = {path = eqsViewPath,  bundleName = EqsPanels.bundleName, assetName = EqsPanels.eqsMapPanel,           layer = 1, isSpecial = true}      --距离准备界面
EqsPanels.BaiPanel           = {path = eqsViewPath,  bundleName = EqsPanels.bundleName, assetName = EqsPanels.baiPanel,              layer = 1, isSpecial = true}      --摆界面
EqsPanels.ChiPanel           = {path = eqsViewPath,  bundleName = EqsPanels.bundleName, assetName = EqsPanels.chiPanel,              layer = 1, isSpecial = true}      --吃界面
EqsPanels.EqsSetting         = {path = eqsViewPath,  bundleName = EqsPanels.bundleName, assetName = EqsPanels.eqsSettingPanel,       layer = 1, isSpecial = true}      --吃界面
EqsPanels.Rule               = {path = eqsViewPath,  bundleName = EqsPanels.bundleName, assetName = EqsPanels.rulePanel,             layer = 1, isSpecial = true}      --吃界面
EqsPanels.DanJuJieSuan       = {path = eqsViewPath,  bundleName = EqsPanels.bundleName, assetName = EqsPanels.danJuJieSuanPanel,     layer = 1, isSpecial = true}      --吃界面
EqsPanels.ZongJieSuan        = {path = eqsViewPath,  bundleName = EqsPanels.bundleName, assetName = EqsPanels.zongJieSuanPanel,      layer = 1, isSpecial = true}      --吃界面
EqsPanels.JieShanRoom        = {path = eqsViewPath,  bundleName = EqsPanels.bundleName, assetName = EqsPanels.jieShanRoomPanel,      layer = 1, isSpecial = true}      --吃界面
EqsPanels.EqsSuiJiQuan       = {path = eqsViewPath,  bundleName = EqsPanels.bundleName, assetName = EqsPanels.eqsSuiJiQuanPanel,     layer = 1, isSpecial = true}      --吃界面

--广播定义
EqsBroadcast = {}
EqsBroadcast.BroadcastType = {
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

EqsBroadcast.TextChat = {
    [LanguageType.sichuan] = {
        --代表性别
        [Global.GenderType.Male] = {
            {text = "打快点嘛，公园头都比你打的快", audio = "chat_2_nan_1"} ,
            {text = "哦豁，八块", audio = "chat_2_nan_2"} ,
            {text = "你要啥子说嘛，我打给你！", audio = "chat_2_nan_3"} ,
            {text = "你打的牌硬是老辣哦！", audio = "chat_2_nan_4"} ,
            {text = "哎，真是情场得意，牌场失意~", audio = "chat_2_nan_5"} ,
            {text = "今天硬是霉得起冬瓜灰哦~", audio = "chat_2_nan_6"} ,
            {text = "哎呀，今天的麻辣烫有着落了！", audio = "chat_2_nan_7"} ,
            {text = "漂亮，这一盘吃了", audio = "chat_2_nan_8"} ,
            {text = "估计这一盘要吃咸~", audio = "chat_2_nan_9"} ,
            {text = "一首凉凉送给大家~", audio = "chat_2_nan_10"} ,
        },
        [Global.GenderType.Female] = {
            {text = "打快点嘛，公园头都比你打的快", audio = "chat_2_nv_1"} ,
            {text = "哦豁，八块", audio = "chat_2_nv_2"} ,
            {text = "你要啥子说嘛，我打给你！", audio = "chat_2_nv_3"} ,
            {text = "你打的牌硬是老辣哦！", audio = "chat_2_nv_4"} ,
            {text = "哎，真是情场得意，牌场失意~", audio = "chat_2_nv_5"} ,
            {text = "今天硬是霉得起冬瓜灰哦~", audio = "chat_2_nv_6"} ,
            {text = "哎呀，今天的麻辣烫有着落了！", audio = "chat_2_nv_7"} ,
            {text = "漂亮，这一盘吃了", audio = "chat_2_nv_8"} ,
            {text = "估计这一盘要吃咸~", audio = "chat_2_nv_9"} ,
            {text = "一首凉凉送给大家~", audio = "chat_2_nv_10"} ,
        }
    }
}

--表情聊天的bundle和Asset，初始化根下面所有Emotion
EqsBroadcast.emotionBundleName = "base/chat"
EqsBroadcast.emotionAssetName  = "EmotionAnim"

--动画聊天
EqsBroadcast.chatAnimBundleName = "base/chat"
EqsBroadcast.chatAnimAssetName  = "ChatAnim"
EqsBroadcast.ChatAnim = {}
EqsBroadcast.ChatAnim[1] = { animItem = "AnimItem1", moveItem = "MoveItem1", audioBundle = "base/chat", audioName = "MoveItem1"}
EqsBroadcast.ChatAnim[2] = { animItem = "AnimItem2", moveItem = "MoveItem2", audioBundle = "base/chat", audioName = "MoveItem2"}
EqsBroadcast.ChatAnim[3] = { animItem = "AnimItem3", moveItem = "MoveItem3", audioBundle = "base/chat", audioName = "MoveItem3"}
EqsBroadcast.ChatAnim[4] = { animItem = "AnimItem4", moveItem = "MoveItem4", audioBundle = "base/chat", audioName = "MoveItem4"}
EqsBroadcast.ChatAnim[5] = { animItem = "AnimItem5", moveItem = "MoveItem5", audioBundle = "base/chat", audioName = "MoveItem5"}
EqsBroadcast.ChatAnim[6] = { animItem = "AnimItem6", moveItem = "MoveItem6", audioBundle = "base/chat", audioName = "MoveItem6"}
EqsBroadcast.ChatAnim[7] = { animItem = "AnimItem7", moveItem = "MoveItem7", audioBundle = "base/chat", audioName = "MoveItem7"}
EqsBroadcast.ChatAnim[8] = { animItem = "AnimItem8", moveItem = "MoveItem8", audioBundle = "base/chat", audioName = "MoveItem8"}


-- 贰柒拾牌相关定义:尾数表示第几张相应ID的牌(每个ID对应4张牌) 十位：1 小牌     2 大牌
EqsCardDefine = {
    CardID = {
        Da_1 = 120, --大一    红
        Da_2 = 220, --大二
        Da_3 = 320,
        Da_4 = 420,
        Da_5 = 520,
        Da_6 = 620,
        Da_7 = 720,
        Da_8 = 820,
        Da_9 = 920,
        Da_10 = 1020,

        Xiao_1 = 110, -- 小一  黑
        Xiao_2 = 210, -- 小二
        Xiao_3 = 310,
        Xiao_4 = 410,
        Xiao_5 = 510,
        Xiao_6 = 610,
        Xiao_7 = 710,
        Xiao_8 = 810,
        Xiao_9 = 910,
        Xiao_10 = 1010,
    },

    -- 牌类型： CardID % 100 / 10
    CardType = {
        Da = 2, -- 大牌
        Xiao = 1    -- 小牌
    },

    -- 牌面点数值： CardID / 100
    CardPoint = {
        Point_1 = 1,
        Point_2 = 2,
        Point_3 = 3,
        Point_4 = 4,
        Point_5 = 5,
        Point_6 = 6,
        Point_7 = 7,
        Point_8 = 8,
        Point_9 = 9,
        Point_10 = 10,

    },

    --小牌特殊标记显示定义
    SmallCardEffectType = {
        Null = 0, --没有特效
        YuTag = 1, --雨
        GunTag = 2, --磙
        Up = 3, --向上
        Down = 4, --向下
        Left = 5,
        Right = 6,
        BoundEffect = 7, -- 四周特效
        Hei = 8, --变黑特效
        Hong = 9, --变红  用于出牌时，桌面上已有牌特效
        Normal = 10,  --颜色恢复正常
        SelectedHsz = 11, --换三张选中
        ChangedHsz = 12,   --换三张已交换
    }
}

--Base中定义，因为大厅中要用
--EqsPlayType = {}

--规则类型定义 Base中定义，因为大厅中要用
--EqsRuleType = {}

--玩家状态
EqsUserStatus = {
    WaitJoin        = 1,    --等待玩家加入房间
    Preparing       = 2,    --准备中
    Prepared        = 3,    --已准备
    Changing        = 4,    --换牌中
    Changed         = 5,    --已换牌
    Waiting         = 6,    --等待别人操作
    Operating       = 7,    --操作中   有操作项如：吃、对、开、胡
    ChuPai          = 8,    --该出牌
    Hu              = 9,    --已经胡牌
}

--操作类型
EqsOperation = {
    Hu          = 42,
    Kai         = 43,
    BaYu        = 44,
    Dui         = 45,
    Chi         = 46,
    BaiPai      = 47,
    ChuPai      = 48,
    Guo         = 49,
    FanPai      = 50, -- 翻牌
    HanSanZhang = 51,
}

--全面屏左右两边像素调整
FullScreenAdapt = Vector2(50, 0)

EqsLocalKey = {
    EqsTableColor   = "TableColor_45334342",    --贰柒拾桌面颜色 
    MusicType       = "MusicType_dfgf342",      --贰柒拾声音 
}

EqsAudioType = {
    FangYan1 = "",
    FangYan2 = "1_"
}

EqsStatusCode = {
    --成功
    SUCCESS = 0,
    --失败
    ERROR = -1,
    --玩家出牌失败 上吐下泻
    SHANG_TU_XIA_XIE = 300,
    --等待其他玩家操作
    WAITING_OTHERS_OPER = 109,
}

