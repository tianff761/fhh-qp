--脚本路径
PdkScriptPath = {
    View = "AB/PaoDeKuai/Lua/View/"
}

--Bundle名称
PdkBundleName = {
    Room = "paodekuai/pdkroom",
    Panel = "paodekuai/panels",
    Audio = "paodekuai/audio",
    Music = "paodekuai/music",
    Effect = "paodekuai/effects",
    Texture = "paodekuai/textures"
}

--面板，大厅的普通面板都使用层数4
PdkPanelConfig = {
    Room = {path = PdkScriptPath.View, bundleName = PdkBundleName.Room, assetName = "PdkRoomPanel", layer = 1, isSpecial = true},
    Setup = {path = PdkScriptPath.View, bundleName = PdkBundleName.Panel, assetName = "PdkSetupPanel", layer = 4, isSpecial = true},
    Dissovle = {path = PdkScriptPath.View, bundleName = PdkBundleName.Panel, assetName = "PdkDissRoomPanel", layer = 5, isSpecial = true},
    SingleRecord = {path = PdkScriptPath.View, bundleName = PdkBundleName.Panel, assetName = "PdkSingleRecordPanel", layer = 4, isSpecial = true},
    TotalRecord = {path = PdkScriptPath.View, bundleName = PdkBundleName.Panel, assetName = "PdkTotalRecordPanel", layer = 4, isSpecial = true},
    Rule = {path = PdkScriptPath.View, bundleName = PdkBundleName.Panel, assetName = "PdkRulePanel", layer = 4, isSpecial = true},
    Playback = {path = PdkScriptPath.View, bundleName = PdkBundleName.Panel, assetName = "PdkPlaybackPanel", layer = 4, isSpecial = true},
}

PdkRoomType = {
    --房卡
    Room_FangKa = 1,
    --分数
    Room_Coin = 2, 
}

--房间状态
PdkGameStatus = {
    --空闲状态
    Leisure = 1,
    --准备
    WaitReady = 2,
    --抢庄
    ContendBanker = 3,
    --游戏中
    Strat = 4,
    --结算状态
    Result = 5,
    --游戏结束
    Over = 6
}

--玩家状态
PdkPlayerStatus = {
    --进入状态
    Loading = 0,
    --空闲状态
    Leisure = 1,
    --准备状态
    Ready = 2,
    --游戏中
    Start = 3,
    --离线状态
    OffLine = 4,
    --结算状态
    Result = 5,
    --游戏结束
    Over = 6
}

PdkBroadcast = {}
PdkBroadcast.TextChat = {
    -- [LanguageType.sichuan] = {
    --     --代表性别
    --     [Global.GenderType.Male] = {
    --         {text = "打快点嘛，公园头都比你打的快", audio = "feiji"} ,
    --         {text = "哦豁，八块", audio = "feiji"} ,
    --         {text = "你要啥子说嘛，我打给你！", audio = "feiji"} ,
    --         {text = "你打的牌硬是老辣哦！", audio = "feiji"} ,
    --         {text = "哎，真是情场得意，牌场失意~", audio = "feiji"} ,
    --         {text = "今天硬是霉得起冬瓜灰哦~", audio = "feiji"} ,
    --         {text = "哎呀，今天的麻辣烫有着落了！", audio = "feiji"} ,
    --         {text = "漂亮，这一盘吃了", audio = "feiji"} ,
    --         {text = "估计这一盘要吃咸~", audio = "feiji"} ,
    --         {text = "一首凉凉送给大家~", audio = "feiji"} ,
    --     },
    --     [Global.GenderType.Female] = {
    --         {text = "打快点嘛，公园头都比你打的快", audio = "feiji"} ,
    --         {text = "哦豁，八块", audio = "feiji"} ,
    --         {text = "你要啥子说嘛，我打给你！", audio = "feiji"} ,
    --         {text = "你打的牌硬是老辣哦！", audio = "feiji"} ,
    --         {text = "哎，真是情场得意，牌场失意~", audio = "feiji"} ,
    --         {text = "今天硬是霉得起冬瓜灰哦~", audio = "feiji"} ,
    --         {text = "哎呀，今天的麻辣烫有着落了！", audio = "feiji"} ,
    --         {text = "漂亮，这一盘吃了", audio = "feiji"} ,
    --         {text = "估计这一盘要吃咸~", audio = "feiji"} ,
    --         {text = "一首凉凉送给大家~", audio = "feiji"} ,
    --     }
    -- }
    [LanguageType.putonghua] = {
        --代表性别
        [Global.GenderType.Male] = {
            {text = "快点吧，我等得花儿都谢了", audio = "M_speech_1"} ,
            {text = "天灵灵，地灵灵，来手好牌行不行", audio = "M_speech_2"} ,
            {text = "唉，无敌是多么寂寞", audio = "M_speech_3"} ,
            {text = "宝宝心里苦，宝宝不说", audio = "M_speech_4"} ,
            {text = "哎呀，网络不太好，又掉线了", audio = "M_speech_5"} ,
            {text = "老姐，扎心了！", audio = "M_speech_11"} ,
            {text = "这牌我也是醉了", audio = "M_speech_12"} ,
            {text = "来呀，互相伤害", audio = "M_speech_13"} ,
            {text = "你看我想理你吗？", audio = "M_speech_14"} ,
            {text = "人生如戏，全靠演技", audio = "M_speech_15"} ,
            {text = "约吗？我是说约牌吗", audio = "M_speech_16"} ,
            {text = "出牌这么慢！你属乌龟的吧！", audio = "M_speech_17"} ,
            {text = "你的牌技让我很难和你一起建设社会主义", audio = "M_speech_18"} ,
            {text = "厉害了我的哥！", audio = "M_speech_19"} ,
            {text = "打牌不怕炸，说明胆子大！", audio = "M_003"} ,
            {text = "哈哈，我要把你们都关起来！", audio = "M_004"} ,
            {text = "咱有钱，随便啦！", audio = "M_007"} ,
            {text = "不要走，决战到天亮！", audio = "M_008"} ,
            {text = "别吵了，别吵了，专心玩游戏吧！", audio = "M_010"} ,
        },
        [Global.GenderType.Female] = {
            {text = "快点吧，我等得花儿都谢了", audio = "W_speech_1"} ,
            {text = "天灵灵，地灵灵，来手好牌行不行", audio = "W_speech_2"} ,
            {text = "唉，无敌是多么寂寞", audio = "W_speech_3"} ,
            {text = "宝宝心里苦，宝宝不说", audio = "W_speech_4"} ,
            {text = "哎呀，网络不太好，又掉线了", audio = "W_speech_5"} ,
            {text = "老铁，扎心了！", audio = "W_speech_11"} ,
            {text = "这牌我也是醉了", audio = "W_speech_12"} ,
            {text = "来啊，互相伤害", audio = "W_speech_13"} ,
            {text = "你看我想理你吗？", audio = "W_speech_14"} ,
            {text = "人生如戏，全靠演技", audio = "W_speech_15"} ,
            {text = "约吗？我是说约牌吗", audio = "W_speech_16"} ,
            {text = "出牌这么慢！你属乌龟的吧！", audio = "W_speech_17"} ,
            {text = "你的牌技让我很难和你一起建设社会主义", audio = "W_speech_18"} ,
            {text = "厉害了我的哥！", audio = "W_speech_19"} ,
            {text = "打牌不怕炸，说明胆子大！", audio = "W_003"} ,
            {text = "哈哈，我要把你们都关起来！", audio = "W_004"} ,
            {text = "咱有钱，随便啦！", audio = "W_007"} ,
            {text = "不要走，决战到天亮！", audio = "W_008"} ,
            {text = "别吵了，别吵了，专心玩游戏吧！", audio = "W_010"} ,
        }
    }
}

PdkPoker = {
    --扑克花色
    PdkPokerColors = {
        --方片
        Square = 0,
        --梅花
        Club = 1,
        --红桃
        Heart = 2,
        --黑桃
        Spade = 3,
        --小王
        Small = 8,
        --大王
        Big = 9,
    },

    --点数
    PointType = {
        CardA = 1,
        Card2 = 2,
        Card3 = 3,
        Card4 = 4,
        Card5 = 5,
        Card6 = 6,
        Card7 = 7,
        Card8 = 8,
        Card9 = 9,
        Card10 = 10,
        CardJ = 11,
        CardQ = 12,
        CardK = 13,
        CardWang = 20,
    },

    --扑克牌权值
    PdkPokerWeight = {
        Three = 3,
        Four = 4,
        Five = 5,
        Six = 6,
        Seven = 7,
        Eight = 8,
        Nine = 9,
        Ten = 10,
        Jack = 11,
        Queen = 12,
        King = 13,
        One = 14,
        Two = 15,
        SJoker = 16,
        BJoker = 17,
    }
}

--扑克牌型
PdkPokerType = {
    --默认
    None = 0,
    --单张
    Single = 1,
    --对子
    Double = 2,
    --三不带
    Three = 3,
    --三带一
    ThreeAndOne = 4,
    --三带二
    ThreeAndTwo = 5,
    --顺子
    Straight = 6,
    --连对
    DoubleStraight = 7,
    --飞机
    Airplane = 8,
    --飞机带单
    AirplaneAndOne = 9,
    --飞机带对
    AirplaneAndTwo = 10,
    --炸弹
    Bomb = 11,
    --炸弹带二单
    BombAndSingle = 12,
    --炸弹带两张
    BombAndDouble = 13,
    --炸弹带三
    BombAndThree = 14,
    --四张
    Four = 15,
}

PdkLayoutDirection = {
    LeftBegin = 0,
    RightBegin = 1,
}

PdkSeatDirection = {
    Self = 1,
    Left = 2,
    Right = 3,
    Top = 4,
}

PdkPrefabName = {
    SelfHandPoker = "SelfHandPoker",
    PlayerOutPoker = "PlayerOutPoker",
    PlayerHandPoker = "PlayerHandPoker",
    PlayerRemainCard = "PlayerRemainCard"
}


