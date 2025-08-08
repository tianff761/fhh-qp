--麻将全局对象，用于存储全局使用的参数
MahjongGlobal = {
    --增加数字
    FontIncrease = nil,
    --减少数字
    FontDecrease = nil,
}

--脚本路径
MahjongScriptPath = {
    View = "AB/Mahjong/Lua/View/",
}

--Bundle名称
MahjongBundleName = {
    Panel = "mahjong/panels",
    Audio = "mahjong/audio",
    Music = "mahjong/music",
    Effect = "mahjong/effects",
    Quick = "mahjong/quick",
    Share = "mahjong/share",
}

--面板，大厅的普通面板都使用层数4
MahjongPanelConfig = {
    Room = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongRoomPanel", isSpecial = true },
    Operation = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongOperationPanel", isSpecial = true },
    HuTips = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongHuTipsPanel", layer = 3, isSpecial = true },
    Setup = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongSetupPanel", layer = 4, isSpecial = true },
    Rule = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongRulePanel", layer = 4, isSpecial = true },
    Dismiss = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongDismissPanel", layer = 6, isSpecial = true },
    SingleSettlement = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongSingleSettlementPanel", layer = 5, isSpecial = true },
    TotalSettlement = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongTotalSettlementPanel", layer = 5, isSpecial = true },
    GoldSettlement = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongGoldSettlementPanel", layer = 5, isSpecial = true },
    Playback = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongPlaybackPanel", layer = 4, isSpecial = true },
    MahjongScreenshot = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongScreenshotPanel", layer = 4, isSpecial = true },
    JushuTips = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongJushuTipsPanel", layer = 4, isSpecial = true },
    MatchSettlement = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongMatchSettlementPanel", layer = 5, isSpecial = true },
    Ranking = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongRankingPanel", layer = 4 },
    HuEffect = { path = MahjongScriptPath.View, bundleName = MahjongBundleName.Panel, assetName = "MahjongHuEffectPanel", layer = 6, isSpecial = true },
}

--麻将座位索引，自己始终1，下家2，对家3，尾家4
MahjongSeatIndex = {
    Seat1 = 1,
    Seat2 = 2,
    Seat3 = 3,
    Seat4 = 4
}

--麻将牌显示类型
MahjongCardDisplayType = {
    --手牌
    Hand = -1,
    --盖着的牌
    Cover = 0,
    --显示的牌
    Display = 1,
    --杠碰吃的牌
    Operate = 2,
    --胡牌--手牌明牌（只有麻将回放的时候才会出现）
    Hu_Hand = 3,
    --胡牌--操作牌（只有一张）
    Hu_Operation = 4
}

--麻将游戏状态类型
MahjongGameStateType = {
    --等待，进入游戏时都处于等待
    Waiting = 100,
    --结束
    End = 200,
    --开始
    Bengin = 300,
    --换牌
    ChangeCard = 310,
    --定缺
    DingQue = 320,
    --打牌
    Play = 330,
}

--麻将花色类型
--101-104表示1万、201-204表示2万
--1101-1104表示1条、1201-1204表示2条
--2101-2104表示1同、2201-2204表示2筒
--与类型匹配需要除1000，然后加1就是类型
MahjongColorType = {
    --万
    Wan = 1,
    --条
    Tiao = 2,
    --筒
    Tong = 3,
}

--换牌类型，单色换，任意换
MahjongChangeCardType = {
    --单色
    SingleColor = 0,
    --任意
    Arbitrary = 1,
    --任意混换
    ArbitraryMix = 2
}

--0是等待，1是有操作项，2是已经胡了，3是该出牌
MahjongOperateState = {
    None = -1,
    Waiting = 0,
    Operate = 1,
    Hu = 2,
    Play = 3
}

--麻将玩家的桌子状态，主要是标记换牌和定缺
MahjongPlayerTableState = {
    None = 0,
    --换牌中
    ChangingCard = 1,
    --换牌完成
    ChangedCard = 2,
    --定缺中
    DingQue = 3,
    --定缺完成
    DingQueEnd = 4
}

--操作状态，用于操作界面
MahjongOperatePanelState = {
    --没有操作
    None = 0,
    --操作
    Operation = 1,
    --定缺
    DingQue = 2,
    --换牌
    Change = 3,
}

--麻将牌局结束状态
MahjongEndState = {
    --正常打牌结束
    Normal = 0,
    --流局结束
    LiuJu = 1,
    --房间解散
    Dismiss = 2,
}

--操作类型
MahjongOperateCode = {
    MO = 0,                   --摸牌
    HU = 1,                   --胡牌
    GANG = 2,                 --点杠
    GANG_IN = 3,              --摸牌杠(包含手牌区的摸牌杠,该情况时，来源为-1)
    GANG_ALL_IN = 4,          --暗杠
    PENG = 5,                 --碰
    CHI = 6,                  --吃
    DING_ZHANG = 7,           --定张
    CHU_PAI = 8,              --出牌
    HUAN_PAI = 12,            --换牌
    SPC_GANG = 15,            --特殊杠 点杠
    SPC_GANG_IN = 16,         --特殊杠 补杠
    SPC_GANG_ALL_IN = 17,     --特殊杠 暗杠
    SPC_PENG = 18,            --特殊碰
    HUAN_ZHANG = 29,          --换张
    GUO = 30,                 --过
    DING_QUE = 32,            --定缺
    BU_PAI = 33,              -- 杠选牌
    MAI_ZHU = 34,             --买猪
    CAN_NOT_HU = -1,          --过牌胡
    QuanQiuRen = 36,          -- 全求人
    LanPai = 37,              -- 烂牌
    QiXingLanPai = 38,        -- 七星烂牌
    LongZhuaBei = 39,         -- 龙爪背
    ShiFeng = 40,             -- 十风
    ShiSanYao = 41,           -- 十三幺
    SiXiaoJi = 42,            -- 四小鸡
    HunYiSe = 43,             -- 混一色
    ZiYiSe = 44,              -- 字一色
    Gang5MeiHua = 45,         -- 杠上5梅花
    XiaoJiGuiWei = 46,        -- 小鸡归位
    DaSanYuan = 47,           -- 大三元
    DaSiXi = 48,              -- 大四喜
    FlyChickenChi = 60,       --吃(飞小鸡)
    --胡的其他选项，客户端自定义
    HU_ZI_MO = 1002,          --自摸
    HU_GANG_SHANG_HUA = 1003, --杠上花
    HU_GANG_SHANG_PAO = 1004, --杠上炮
    HU_QIANG_GANG = 1005,     --抢杠胡
    HU_TIAN_HU = 1006,     --天胡
    HU_DI_HU = 1007,     --地胡
    HU_HAI_DI_LAO = 1008,     --海底捞
    HU_HAI_DI_PAO = 1009,     --海底炮
    HU_QING_YI_SE = 1010,     --清一色
    HU_LONG_QI_DUI = 1011,     --龙七对
    HU_AN_QI_DUI = 1012,     --暗七对
    HU_JIN_GOU_GOU = 1013,     --金钩钩
}

--操作语音名字
MahjongOperateAudio = {
    [Global.GenderType.Male] = {
        [MahjongOperateCode.HU] = "hu",                          --胡牌
        [MahjongOperateCode.HU_ZI_MO] = "zimo",                  --自摸
        [MahjongOperateCode.HU_GANG_SHANG_HUA] = "hu",           --杠上花
        [MahjongOperateCode.HU_GANG_SHANG_PAO] = "gangshangpao", --杠上炮
        [MahjongOperateCode.HU_QIANG_GANG] = "qianggang",        --抢杠胡
        --
        [MahjongOperateCode.GANG] = "gang",                      --明杠
        [MahjongOperateCode.GANG_IN] = "gang",                   --巴杠
        [MahjongOperateCode.GANG_ALL_IN] = "gang",               --暗杠
        [MahjongOperateCode.PENG] = "peng",                      --碰
        --
        --幺鸡麻将语言
        [MahjongOperateCode.SPC_GANG] = "gang",        --幺鸡明杠
        [MahjongOperateCode.SPC_GANG_IN] = "gang",     --幺鸡开杠
        [MahjongOperateCode.SPC_GANG_ALL_IN] = "gang", --幺鸡暗杠
        [MahjongOperateCode.SPC_PENG] = "peng"         --幺鸡碰
    },
    [Global.GenderType.Female] = {
        [MahjongOperateCode.HU] = "hu",                          --胡牌
        [MahjongOperateCode.HU_ZI_MO] = "zimo",                  --自摸
        [MahjongOperateCode.HU_GANG_SHANG_HUA] = "gangshanghua", --杠上花
        [MahjongOperateCode.HU_GANG_SHANG_PAO] = "hu",           --杠上炮
        [MahjongOperateCode.HU_QIANG_GANG] = "hu",               --抢杠胡
        --
        [MahjongOperateCode.GANG] = "minggang",                  --明杠
        [MahjongOperateCode.GANG_IN] = "kaigang",                --开杠
        [MahjongOperateCode.GANG_ALL_IN] = "angang",             --暗杠
        [MahjongOperateCode.PENG] = "peng",                      --碰
        --
        --幺鸡麻将语言
        [MahjongOperateCode.SPC_GANG] = "minggang",      --幺鸡明杠
        [MahjongOperateCode.SPC_GANG_IN] = "kaigang",    --幺鸡开杠
        [MahjongOperateCode.SPC_GANG_ALL_IN] = "angang", --幺鸡暗杠
        [MahjongOperateCode.SPC_PENG] = "peng"           --幺鸡碰
    }
}

--胡牌特效类型，打牌操作使用类型，跟下面的规则名称对应
MahjongHuEffectsType = {
    --胡牌
    Hu = 1,
    --自摸
    ZiMo = 2,
    --杠上花
    GangShangHua = 3,
    --杠上炮
    GangShangPao = 4,
    --抢杠胡
    QiangGangHu = 5,
    --天胡
    TianHu = 6,
    --地胡
    DiHu = 7,
    --海底捞
    HaiDiLao = 8,
    --海底炮
    HaiDiPao = 9,
    --清一色
    QingYiSe = 10,
    --龙七对
    LongQiDui = 11,
    --暗七对
    AnQiDui = 12,
    --金钩钩
    JinGouGou = 13,
}

--麻将胡牌状态，结算使用类型，0.无、1.自摸、2.胡、3有叫、4查叫
MahjongHuState = {
    --无
    None = 0,
    --自摸
    ZiMo = 1,
    --胡
    Hu = 2,
    --有叫
    YouJiao = 3,
    --查叫
    ChaJiao = 4,
}

--胡牌规则名称
MahjongHuRuleName = {
    [1] = "平胡",
    [2] = "对对胡",
    [3] = "自摸",
    [4] = "清一色",
    [5] = "七对",
    [6] = "龙七对",
    [7] = "将对",
    [8] = "门清",
    [9] = "全幺九",
    [10] = "四归一",
    [11] = "中张",
    [12] = "杠上花",
    [13] = "杠上炮",
    [14] = "抢杠胡",
    [15] = "天胡",
    [16] = "地胡",
    [17] = "海底捞",
    [18] = "海底炮",
    [19] = "金钩胡",
    [20] = "杠子",
    [21] = "夹心五",
    [22] = "四对",
    [23] = "龙四对",
    [24] = "卡二条",
    [25] = "无鸡",
    [26] = "四鸡吃喜",
    [27] = "双龙七对",
    [28] = "三龙七对",
    [35] = "三鸡吃喜",
}

--胡牌规则名称
MahjongHuRuleShareImageName = {
    -- [1] = "pinghu",
    [2] = "duiduihu",
    -- [3] = "zimo",
    [4] = "qingyise",
    [5] = "qidui",
    [6] = "longqidui",
    [7] = "jiangdui",
    -- [8] = "menqing",
    [9] = "quanyaojiu",
    [10] = "siguiyi",
    -- [11] = "zhongzhang",
    [12] = "gangshanghua",
    [13] = "gangshangpao",
    [14] = "qiangganghu",
    [15] = "tianhu",
    [16] = "dihu",
    [17] = "haidilao",
    [18] = "haidipao",
    [19] = "jingouhu",
    -- [20] = "gangzi",
    [21] = "jiaxinwu",
    [22] = "sidui",
    [23] = "longsidui",
    [24] = "kaertiao",
    -- [25] = "wuji",
    [26] = "sijifacai",
    [27] = "shuanglongqidui",
    [28] = "sanlongqidui"
}

--分享牌型优先级
MahjongPriorityImageName = {
    24,
    21,
    9,
    7,
    2,
    19,
    18,
    17,
    14,
    13,
    12,
    5,
    4,
    6,
    16,
    27,
    28,
    15,
    26,
    35,
}

--成麻分享牌型优先级
MahjongChengMaPriorityImageName = {
    2,
    19,
    18,
    17,
    14,
    13,
    12,
    5,
    4,
    6,
    16,
    27,
    28,
    15,
    26,
    35,
    24,
    21,
    7,
    9,
}

--胡牌规则名称
MahjongGangName = {
    [2] = "明杠x",
    [3] = "巴杠x",
    [4] = "暗杠x",
    [5] = "根x",
    [6] = "点杠x",
    [7] = "被巴杠x",
    [8] = "被暗杠x",
}


--麻将静态值
MahjongConst = {
    --无效的key标识
    INVALID_CARD_KEY = -1000,
    --手牌提起的Y值
    HandCardUpY = 20,
    --打牌判断的Y值
    PlayCardUpY = 15,
    --手牌按下的Y值
    HandCardPressDownY = 32,
    --手牌换牌时的Y值
    HandCardChangeY = 66,
    --幺鸡玩法的听用牌，4听用，8听用。12听用
    YaoJiTingYong = { [4] = { 11 }, [8] = { 11, 21 }, [12] = { 1, 11, 21 } },
}

--麻将换牌提示图片名称
MahjongHuanPaiTipsName = {
    --幺鸡任意三张
    YaojiArbitrarySanZhang = "Y-n-3",
    --幺鸡任意四张
    YaojiArbitrarySiZhang = "Y-n-4",
    --幺鸡同色三张
    YaojiSingleColorSanZhang = "Y-s-3",
    --幺鸡同色四张
    YaojiSingleColorSiZhang = "Y-s-4",
    --任意三张
    ArbitrarySanZhang = "N-n-3",
    --任意四张
    ArbitrarySiZhang = "N-n-4",
    --同色三张
    SingleColorSanZhang = "N-s-3",
    --同色四张
    SingleColorSiZhang = "N-s-4",
}

--麻将牌提起类型
MahjongCardUpType = {
    --没有提起
    None = 1,
    --按下
    PressDown = 2,
    --选择
    Selected = 3,
}

--麻将牌遮罩颜色类型
MahjongMaskColorType = {
    --无
    None = 0,
    --灰色，标记换出牌、标记定缺牌
    Gray = 1,
    --标记换回牌
    ChangeCard = 2,
    --标记选中牌
    Selected = 3,
    --听用
    TingYong = 4,
}

--麻将准备状态类型
MahjongReadyType = {
    --没有准备
    No = 0,
    --准备
    Ready = 1
}

--麻将进入房间状态类型
MahjongJoinType = {
    --没有进入
    No = 0,
    --进入
    Join = 1
}

--麻将房间状态，1初始化、2等待中、3游戏中、4结算状态、5房间结束
MahjongRoomStateType = {
    Init = 1,
    Waiting = 2,
    Gaming = 3,
    Settlement = 4,
    End = 5,
}

--麻将聊天类型
--1表情、2快捷文字语音、3表情道具动画、4文本、5录制语音、6其他
MahjongChatType = {
    --表情
    Emotion = 1,
    --快捷文字语音
    Quick = 2,
    --表情道具动画
    ChatAnim = 3,
    --文本
    Text = 4,
    --录制语音
    Speech = 5,
    --其他
    Other = 6
}

--房间最大玩家数量
Mahjong.ROOM_MAX_PLAYER_NUM = 4
--最大的麻将牌数量
Mahjong.ROOM_MAX_CARD_NUM = 13
--打出的牌第一行最大的列数
Mahjong.OUT_CARD_FRIST_ROW_MAX_COL = 9 --原版为8



--麻将牌配置信息
MahjongCardItemInfoConfig = {
    [1] = {
        OperateWidth = 240,
        CardWidth = 89,
        NewCardGap = 32,
        OutWidth = 54,
        OutHeight = 50,
        HuWidth = 74,
    },
    [2] = {
        OperateWidth = 107, --已弃用，因为2号位玩家麻将X、Y轴坐标都得改变
        CardWidth = 22,
        NewCardGap = 17,
        OutWidth = 6,
        OutHeight = 42,
        HuWidth = 0,  --读坐标配置，已弃用
    },
    [3] = {
        OperateWidth = 134,
        CardWidth = 40,
        NewCardGap = 40,
        OutWidth = 48,
        OutHeight = 41,
        HuWidth = 40,
    },
    [4] = {
        OperateWidth = 107, --已弃用，因为4号位玩家麻将X、Y轴坐标都得改变
        CardWidth = 22,
        NewCardGap = 17,
        OutWidth = 6,
        OutHeight = 42,
        HuWidth = 0, --读坐标配置，已弃用
    }
}

--麻将操作的来源方向角度
MahjongOperateDirectionAngle = { 180, 270, 0, 90 }

--麻将打出的牌的箭头坐标偏移量
MahjongOutCardArrowOffset = {
    { x = 0, y = 22 },
    { x = 3, y = 20 },
    { x = 0, y = 7 },
    { x = 7, y = 22 },
}

--换张特效旋转类型
MahjongHuanRotateType = {
    --对家换
    Dui = 0,
    --顺时针
    Shun = 1,
    --逆时针
    Ni = 2,
}

--换张特效配置，0对家换，1顺时针，2逆时针
MahjongHuanEffectConfig = {
    --人数
    [2] = {
        [0] = {
            [1] = { x = 0, y = 350, z = 0 },
            [3] = { x = 0, y = -350, z = 0 },
        }
    },
    [3] = {
        [1] = {
            [1] = { x = -680, y = 0, z = 0 },
            [2] = { x = 0, y = -350, z = 0 },
            [4] = { x = 680, y = 0, z = 0 },
        },
        [2] = {
            [1] = { x = 680, y = 0, z = 0 },
            [2] = { x = -680, y = 0, z = 0 },
            [4] = { x = 0, y = -350, z = 0 },
        },
    },
    [4] = {
        [0] = {
            [1] = { x = 0, y = 350, z = 0 },
            [2] = { x = -680, y = 0, z = 0 },
            [3] = { x = 0, y = -350, z = 0 },
            [4] = { x = 680, y = 0, z = 0 },
        },
        [1] = {
            [1] = { x = -680, y = 0, z = 0 },
            [2] = { x = 0, y = -350, z = 0 },
            [3] = { x = 680, y = 0, z = 0 },
            [4] = { x = 0, y = 350, z = 0 },
        },
        [2] = {
            [1] = { x = 680, y = 0, z = 0 },
            [2] = { x = 0, y = 350, z = 0 },
            [3] = { x = -680, y = 0, z = 0 },
            [4] = { x = 0, y = -350, z = 0 },
        }
    }
}

MahjongChatLabelArr = {
    [LanguageType.putonghua] = {
        [Global.GenderType.Male] = {
            { text = "大家好，很高兴见到各位！", audio = "man_chat0" },
            { text = "快点吧，我等到花儿都谢了。", audio = "man_chat1" },
            { text = "不要走！决战到天亮。", audio = "man_chat2" },
            { text = "你是帅哥，还是妹妹啊。", audio = "man_chat3" },
            { text = "君子报仇十盘不算晚。", audio = "man_chat4" },
            { text = "快放炮啊，我等得不耐烦了。", audio = "man_chat5" },
            { text = "真不好意思，又胡了！", audio = "man_chat6" },
            { text = "打错了！555555555", audio = "man_chat7" },
        },
        [Global.GenderType.Female] = {
            { text = "大家好，很高兴见到各位！", audio = "woman_chat0" },
            { text = "快点吧，我等到花儿都谢了。", audio = "woman_chat1" },
            { text = "不要走！决战到天亮。", audio = "woman_chat2" },
            { text = "你是帅哥，还是妹妹啊。", audio = "woman_chat3" },
            { text = "君子报仇十盘不算晚。", audio = "woman_chat4" },
            { text = "快放炮啊，我等得不耐烦了。", audio = "woman_chat5" },
            { text = "真不好意思，又胡了！", audio = "woman_chat6" },
            { text = "打错了！555555555", audio = "woman_chat7" },
        }
    },
    [LanguageType.sichuan] = {
        [Global.GenderType.Male] = {
            { text = "你是哪个单位的，出牌这么慢。", audio = "chat_2_boy_1" },
            { text = "眼瞅都要下班了，你快点呗。", audio = "chat_2_boy_2" },
            { text = "哈哈，没了吧。", audio = "chat_2_boy_3" },
            { text = "这牌打得真精彩。", audio = "chat_2_boy_4" },
            { text = "看你打牌可真费劲。", audio = "chat_2_boy_5" },
            { text = "时间就是金钱我的朋友。", audio = "chat_2_boy_6" },
            { text = "来呀互相伤害呀。", audio = "chat_2_boy_7" },
            { text = "你这样以后没朋友。", audio = "chat_2_boy_8" },
        },
        [Global.GenderType.Female] = {
            { text = "你是哪个单位的，出牌这么慢。", audio = "chat_2_boy_1" },
            { text = "眼瞅都要下班了，你快点呗。", audio = "chat_2_boy_2" },
            { text = "哈哈，没了吧。", audio = "chat_2_boy_3" },
            { text = "这牌打得真精彩。", audio = "chat_2_boy_4" },
            { text = "看你打牌可真费劲。", audio = "chat_2_boy_5" },
            { text = "时间就是金钱我的朋友。", audio = "chat_2_boy_6" },
            { text = "来呀互相伤害呀。", audio = "chat_2_boy_7" },
            { text = "你这样以后没朋友。", audio = "chat_2_boy_8" },
        }
    }
}

--协议状态码
MahjongErrorCode = {
    ERROR = -1,                --系统错误
    Normal = 0,                --正常
    Not_Oper = 1,              --不能操作(10772)
    Player_Not_Exist = 2,      --玩家不存在(10772)
    Already_Que = 3,           --已经定缺(10772)
    Not_Oper_Allow = 4,        --操作不允许(10772)
    Must_Hu = 5,               --必须胡牌(10772)
    Not_ChuPai = 6,            --不能出牌(10772)
    Already_Select_Card = 7,   --已经选牌(10772)
    Huan_Zhang_Error = 8,      --换张错误(10772)
    Huan_Num_Error = 9,        --换三张选择得牌数不对(10772)
    Huan_Select_Error = 10,    --选牌不对(10772)
    Huan_Select_YaoJi = 11,    --换牌时幺鸡不能换(10772)
    Huan_Select_Hs = 12,       --换牌时必须选择花色相同得牌(10772)
    Not_Oper_Invalid = 13,     --操作无效(10772)
    Not_Hu = 14,               --不能胡牌(10772)
    Not_Oper_Wait = 15,        --玩家处于等待中, 不能操作(10772)
    Not_Gang = 16,             --不能杠(10772)
    Gang_Error = 17,           --杠牌错误(10772)
    Not_Peng = 18,             --不能碰(10772)
    Peng_Error = 19,           --碰牌错误(10772)
    Not_Huan = 20,             --不能换牌(10772)
    Huan_Error = 21,           --换牌错误(10772)
    Already_Ready = 22,        --玩家已经准备(10132)
    Table_Not_Ready = 23,      --该牌局还不能准备(10132)
    Table_Not_Runing = 24,     --牌局不再进行中(10772)
    Table_End = 25,            --该局已经结束(10772)
    Need_Wait = 26,            --改玩家需要等待其他玩家操作(10772)
    Table_Already_Start = 27,  --牌局已经开始，无法退出(11003)
    PlayerNum_Not_Enough = 28, --人数不够无法准备(10132)
    Player_Already_Oper = 29,  --玩家已经操作过同意或者拒绝(10166)
}

--错误提示映射
MahjongErrorCodeMap = {
    [MahjongErrorCode.Not_Oper] = "操作失败",
    [MahjongErrorCode.Player_Not_Exist] = "操作失败。",
    [MahjongErrorCode.Already_Que] = "已经定缺",
    [MahjongErrorCode.Not_Oper_Allow] = "不能操作",
    [MahjongErrorCode.Must_Hu] = "当前只能选择胡牌",
    [MahjongErrorCode.Not_ChuPai] = "不能出牌",
    [MahjongErrorCode.Already_Select_Card] = "已经选牌",
    [MahjongErrorCode.Huan_Zhang_Error] = "换张失败",
    [MahjongErrorCode.Huan_Num_Error] = "换张失败，请选择相应数量的牌张",
    [MahjongErrorCode.Huan_Select_Error] = "换张失败，请选择正确的牌张",
    [MahjongErrorCode.Huan_Select_YaoJi] = "幺鸡玩法不能选择幺鸡牌张",
    [MahjongErrorCode.Huan_Select_Hs] = "请选择同花色牌张",
    [MahjongErrorCode.Not_Oper_Invalid] = "操作无效",
    [MahjongErrorCode.Not_Hu] = "不能胡牌",
    [MahjongErrorCode.Not_Oper_Wait] = "等待操作时不能操作",
    [MahjongErrorCode.Not_Gang] = "杠牌失败",
    [MahjongErrorCode.Gang_Error] = "杠牌错误",
    [MahjongErrorCode.Not_Peng] = "碰牌失败",
    [MahjongErrorCode.Peng_Error] = "碰牌错误",
    [MahjongErrorCode.Not_Huan] = "换牌失败",
    [MahjongErrorCode.Huan_Error] = "换牌错误",
    [MahjongErrorCode.Table_Not_Runing] = "牌局已经结束",
    [MahjongErrorCode.Table_End] = "牌局已经结束。",
    [MahjongErrorCode.Need_Wait] = "等待其他玩家操作",
}

--倍数映射
MahjongMultipleMappingDict = {
    [0] = 1,
    [1] = 2,
    [2] = 4,
    [3] = 8,
    [4] = 16,
    [5] = 32,
    [6] = 64,
    [7] = 128,
    [8] = 256,
    [9] = 512,
    [10] = 1024,
}

--=========================================================手牌 相关配置

--上方（3号位）玩家手牌坐标配置
MahjongTopHandCardPosConfig = {
    [1] = {0, 0},
    [2] = {-41, 0},
    [3] = {-81, 0},
    [4] = {-123, 0},
    [5] = {-165, 0},
    [6] = {-205, 0},
    [7] = {-248, 0},
    [8] = {-287, 0},
    [9] = {-327, 0},
    [10] = {-371, 0},
    [11] = {-411, 0},
    [12] = {-453, 0},
    [13] = {-495, 0},
    [14] = {-560, 0},
}


--左方（4号位）玩家手牌坐标配置
--2号位预制体索引 1-13 对应 坐标索引 2-14
--4号位预制体索引 1-13 对应 坐标索引 13-1
MahjongLeftHandCardPosConfig = {
    [1] = {0, 0},
    [2] = {-7, -23},
    [3] = {-16, -46},
    [4] = {-23, -69},
    [5] = {-31, -92},
    [6] = {-38, -117},
    [7] = {-46, -142},
    [8] = {-55, -169},
    [9] = {-62, -196},
    [10] = {-71, -225},
    [11] = {-80, -254},
    [12] = {-90, -285},
    [13] = {-100, -318},
    [14] = {-110, -351},
}


--右方（2号位）玩家手牌节点坐标配置
MahjongRightHandCardNodePos = {
    [0] = {0, -90},
    [1] = {-5, -70},
    [2] = {-5, -70},
    [3] = {-5, -70},
    [4] = {-8, -62},
}

--上方（3号位）玩家手牌节点坐标配置
MahjongTopHandCardNodePos = {
    [0] = {0, 0},
    [1] = {0, 0},
    [2] = {-15, 0},
    [3] = {-25, 0},
    [4] = {-35, 0},
}


--左方（4号位）玩家手牌节点坐标配置 --暂时未用，因为碰刚吃盖牌时，手牌坐标不需要调整
MahjongLeftHandCardNodePos = {
    [0] = {0, -90},
    [1] = {0, -90},
    [2] = {0, -90},
    [3] = {0, -90},
    [4] = {0, -90},
}

--=========================================================胡牌-盖牌 / 胡牌-手牌 相关配置


MahjongLeftHuCardItemPosConfig = {
    --左方（4号位）玩家胡牌-盖牌 坐标配置   美术给的是4号位盖牌资源，2号位做镜像翻转
    --2号位预制体索引 1-13 对应 坐标索引 2-14
    --4号位预制体索引 1-13 对应 坐标索引 13-1
    [1] = {
        [1] = {-25, -58},
        [2] = {-32, -80},
        [3] = {-40, -104},
        [4] = {-49, -128},
        [5] = {-58, -154},
        [6] = {-66, -178},
        [7] = {-75, -206},
        [8] = {-83, -233},
        [9] = {-93, -262},
        [10] = {-104, -291},
        [11] = {-114, -320},
        [12] = {-125, -353},
        [13] = {-136, -386},
        [14] = {-146, -419},
    },
    
    --左方（4号位）玩家胡牌-手牌明牌 坐标配置   美术给的是2号位胡牌资源，4号位做镜像翻转
    --2号位预制体索引 1-13 对应 坐标索引 1-13
    --4号位预制体索引 1-13 对应 坐标索引 13-1
    [2] = {
        [1] = {-25, -58},
        [2] = {-32, -80},
        [3] = {-37, -102},
        [4] = {-45, -127},
        [5] = {-51, -152},
        [6] = {-59, -177},
        [7] = {-66, -203},
        [8] = {-74, -230},
        [9] = {-82, -258},
        [10] = {-90, -287},
        [11] = {-98, -317},
        [12] = {-107, -348},
        [13] = {-116, -380},
    }
}


--上方（3号位）玩家胡牌 坐标配置
MahjongTopHuCardItemPosConfig = {
    --胡牌-盖牌
    [1] = {
    [1] = {0, 0},
    [2] = {-42, 0},
    [3] = {-82, 0},
    [4] = {-124, 0},
    [5] = {-164, 0},
    [6] = {-205, 0},
    [7] = {-246, 0},
    [8] = {-287, 0},
    [9] = {-328, 0},
    [10] = {-369, 0},
    [11] = {-410, 0},
    [12] = {-451, 0},
    [13] = {-491, 0},
    [14] = {-560, 0},
    },

    --胡牌-手牌明牌，回放时显示
    [2] = {
        [1] = {0, 0},
        [2] = {-41, 0},
        [3] = {-82, 0},
        [4] = {-123, 0},
        [5] = {-164, 0},
        [6] = {-205, 0},
        [7] = {-245, 0},
        [8] = {-287, 0},
        [9] = {-328, 0},
        [10] = {-369, 0},
        [11] = {-410, 0},
        [12] = {-451, 0},
        [13] = {-492, 0},
        [14] = {-560, 0},
    },
}


--右方（2号位）玩家胡牌节点坐标配置 ，根据碰杠吃盖牌的数量来变更坐标
MahjongRightHuCardNodePos = {
    --胡牌-盖牌
    [1] = {
        [0] = {-20, -50},
        [1] = {-15, -40},
        [2] = {-15, -40},
        [3] = {-16, -36},
        [4] = {-20, -22},
    },
    --胡牌-手牌明牌，回放时显示
    [2] = {
        [0] = {-20, -40},
        [1] = {-10, -40},
        [2] = {-15, -40},
        [3] = {-15, -40},
        [4] = {-25, -25},
    }
}


--上方（3号位）玩家胡牌节点坐标配置 ，根据碰杠吃盖牌的数量来变更坐标
MahjongTopHuCardNodePos = {
    --胡牌-盖牌
    [1] = {
        [0] = {0, 0},
        [1] = {-5, 0},
        [2] = {-15, 0},
        [3] = {-30, 0},
        [4] = {-40, 0},
    },
    --胡牌-手牌明牌，回放时显示
    [2] = {
        [0] = {0, 0},
        [1] = {-40, 0},
        [2] = {-55, 0},
        [3] = {-70, 0},
        [4] = {-80, 0},
    },
}

--左方（4号位）玩家胡牌节点坐标配置 ，根据碰杠吃盖牌的数量来变更坐标
MahjongLeftHuCardNodePos = {
    --胡牌-盖牌
    [1] = {
        [0] = {13, -50},
        [1] = {25, -10},
        [2] = {20, -30},
        [3] = {14, -47},
        [4] = {14, -47},
    },
    
    --胡牌-手牌明牌，回放时显示
    [2] = {
        [0] = {20, -40},
        [1] = {20, -40},
        [2] = {10, -65},
        [3] = {0, -80},
        [4] = {-5, -90},
    }
}

--玩家胡牌操作牌Icon坐标配置字典
MahjongHuCardIconPosConfigDicts_Operation = {
    [1] = {posX = 0, posY = 12, scale = {0.75, 0.75}, offset = -2, RotationZ = 0},
    [2] = {posX = -3, posY = 14, scale = {-0.28, 0.48}, offset = 31, RotationZ = 102},
    [3] = {posX = 3, posY = 14, scale = {0.5, 0.35}, offset = 13, RotationZ = 180},
    [4] = {posX = -2, posY = 9, scale = {0.41, 0.61}, offset = -32, RotationZ = -104},
}

--玩家胡牌-手牌明牌 Icon坐标配置字典
--2号位/4号位做镜像翻转
MahjongHuCardIconPosConfigDicts_Hand = {
    [2] = {
        pos = {{-3, 14}, {-3, 14}, {-4, 12}, {-3, 13}, {-4, 13}, {-3, 12}, {-3, 11}, {-3, 11}, {-3, 10}, {-3, 10}, {-3, 9}, {-3, 8}, {-3, 8}}, 
        scaleX = {-0.28, -0.29, -0.30, -0.31, -0.32, -0.33, -0.34, -0.35, -0.36, -0.37, -0.38, -0.39, -0.40}, 
        scaleY = {0.48, 0.49, 0.50, 0.51, 0.52, 0.53, 0.54, 0.55, 0.56, 0.57, 0.58, 0.59, 0.60}, 
        offset = 31,
        RotationZ = 102,
    },
    [3] = {
        pos = {{2, 12}, {1, 12}, {1, 12}, {1, 12}, {1, 12}, {0, 12}, {-1, 12}, {0, 12}, {-1, 12}, {-1, 12}, {-1, 12}, {-1, 12}, {-2, 12}}, 
        scale = 0.38, 
        offset = {14, 12, 10, 8, 6, 2, 0, -4, -6, -8, -10, -12, -14}, 
        RotationZ = 180
    },
}


--玩家胡牌-手牌明牌/操作牌 Mark坐标配置字典
MahjongHuCardMarkConfigDicts = {
    [2] = {
       pos = {{45, 42}, {45, 41}, {43, 39}, {44, 39}, {43, 39}, {44, 38}, {43, 37}, {43, 36}, {43, 35}, {43, 34}, {42, 34}, {43, 33}, {42, 33}}, 
       scale = {0.3, 0.31, 0.32, 0.33, 0.34, 0.35, 0.36, 0.37, 0.38, 0.39, 0.40, 0.41, 0.42}, 
       offset = 15, RotationZ = 107
    },

    [3] = {
        pos = {-23, 45}, 
        scale = 0.35, 
        offset = {7, 6, 5, 4, 3, 2, -1, -2, -3, -4, -5, -6, -7}, 
        RotationZ = 180
    },

    [4] = {
        pos = {{50, 60}, {50, 60}, {50, 60}, {50, 60}, {50, 60}, {50, 60}, {50, 60}, {50, 60}, {50, 61}, {50, 60}, {49, 59}, {50, 60}, {50, 61}}, 
        scale = {0.42, 0.41, 0.40, 0.39, 0.38, 0.37, 0.36, 0.35, 0.34, 0.33, 0.32, 0.31, 0.30}, 
        offset = -16, RotationZ = -107
    },
}


--玩家胡牌操作牌特效配置字典
MahjongHuCardEffectsConfigDicts = {
    [1] = {posX = -440, posY = 190, scale = 1},
    [2] = {posX = -265, posY = 122, scale = 0.6},
    [3] = {posX = -220, posY = 100, scale = 0.5},
    [4] = {posX = -353, posY = 160, scale = 0.8},
}



--=========================================================出牌Icon 相关配置

--玩家出牌Icon坐标配置字典
MahjongOutCardIconPosConfigDicts = {
    [1] = {    
        [1] = {posX = {-4, -3, -3, -2, 0, 2, 3, 3, 4}, posY = 17, scaleX = 0.6, scaleY = 0.5, offset = {9, 7, 5, 3, 0, -3, -5, -7, -9}, RotationZ = 0},
        [2] = {posX = {-4, -3, -3, -2, 0, 2, 3, 3, 4}, posY = 16, scaleX = 0.65, scaleY = 0.5, offset = {9, 7, 5, 3, 0, -3, -5, -7, -9}, RotationZ = 0},
        [3] = {posX = {-4, -3, -3, -2, 0, 2, 3, 3, 4}, posY = 16, scaleX = 0.65, scaleY = 0.5, offset = {9, 7, 5, 3, 0, -3, -5, -7, -9}, RotationZ = 0},
        [4] = {posX = {-4, -3, -3, -2, 0, 2, 3, 3, 4}, posY = 16, scaleX = 0.65, scaleY = 0.5, offset = {9, 7, 5, 3, 0, -3, -5, -7, -9}, RotationZ = 0},
    },
    [2] = {
        [1] = {posX = -2, posY = 9, scaleX = {-0.43, -0.43, -0.42, -0.41, -0.4, -0.38, -0.38, -0.37, -0.36}, 
            scaleY = {0.63, 0.62, 0.61, 0.6, 0.59, 0.57, 0.57, 0.56, 0.55, }, offset = 21, RotationZ = 99},

        [2] = {posX = -2, posY = 9, scaleX = {-0.43, -0.43, -0.42, -0.41, -0.4, -0.38, -0.38, -0.37, -0.36}, 
            scaleY = {0.63, 0.62, 0.61, 0.6, 0.59, 0.57, 0.57, 0.56, 0.55, }, offset = 21, RotationZ = 99},

        [3] = {posX = -2, posY = 9, scaleX = {-0.43, -0.43, -0.42, -0.41, -0.4, -0.38, -0.38, -0.37, -0.36}, 
            scaleY = {0.63, 0.62, 0.61, 0.6, 0.59, 0.57, 0.57, 0.56, 0.55, }, offset = 21, RotationZ = 99},

        [4] = {posX = -2, posY = 9, scaleX = {-0.43, -0.43, -0.42, -0.41, -0.4, -0.38, -0.38, -0.37, -0.36}, 
            scaleY = {0.63, 0.62, 0.61, 0.6, 0.59, 0.57, 0.57, 0.56, 0.55, }, offset = 21, RotationZ = 99},
    },
    [3] = {
        [1] = {posX = {-2, -2, -1, -1, 0, 1, 1, 2, 2}, posY = 14, scaleX = 0.55, scaleY = 0.42, offset = {-9, -7, -5, -3, 0, 3, 5, 7, 9}, RotationZ = 180},
        [2] = {posX = {-2, -2, -1, -1, 0, 1, 1, 2, 2}, posY = 15, scaleX = 0.55, scaleY = 0.42, offset = {-9, -7, -5, -3, 0, 3, 5, 7, 9}, RotationZ = 180},
        [3] = {posX = {-2, -2, -1, -1, 0, 1, 1, 2, 2}, posY = 15, scaleX = 0.55, scaleY = 0.42, offset = {-9, -7, -5, -3, 0, 3, 5, 7, 9}, RotationZ = 180},
        [4] = {posX = {-2, -2, -1, -1, 0, 1, 1, 2, 2}, posY = 15, scaleX = 0.55, scaleY = 0.42, offset = {-9, -7, -5, -3, 0, 3, 5, 7, 9}, RotationZ = 180},
    },
    [4] = {
        [1] = {posX = -2, posY = 9, scaleX = {0.36, 0.37, 0.38, 0.39, 0.4, 0.41, 0.42, 0.43, 0.43}, 
            scaleY = {0.55, 0.56, 0.57, 0.58, 0.59, 0.6, 0.61, 0.62, 0.63, }, offset = -21, RotationZ = -99},

        [2] = {posX = -2, posY = 9, scaleX = {0.36, 0.37, 0.38, 0.39, 0.4, 0.41, 0.42, 0.43, 0.43}, 
            scaleY = {0.55, 0.56, 0.57, 0.58, 0.59, 0.6, 0.61, 0.62, 0.63, }, offset = -21, RotationZ = -99},

        [3] = {posX = -2, posY = 9, scaleX = {0.36, 0.37, 0.38, 0.39, 0.4, 0.41, 0.42, 0.43, 0.43}, 
            scaleY = {0.55, 0.56, 0.57, 0.58, 0.59, 0.6, 0.61, 0.62, 0.63, }, offset = -21, RotationZ = -99},

        [4] = {posX = -2, posY = 9, scaleX = {0.36, 0.37, 0.38, 0.39, 0.4, 0.41, 0.42, 0.43, 0.43}, 
            scaleY = {0.55, 0.56, 0.57, 0.58, 0.59, 0.6, 0.61, 0.62, 0.63, }, offset = -21, RotationZ = -99},
    },
}


--=========================================================碰杠吃盖牌 相关配置

--左方（4号位）玩家碰杠吃盖牌坐标配置, 2号位玩家可以做镜像翻转
MahjongLeftOperateCardPos = {
    [1] = {{0, 0}, {-7, -22}, {-14, -45}, {-10, 0}},
    [2] = {{0, 0}, {-8, -24}, {-16, -49}, {-10, -2}},
    [3] = {{0, 0}, {-7, -27}, {-18, -54}, {-10, -4}},
    [4] = {{0, 0}, {-9, -31}, {-19, -61}, {-12, -7}},
}

--玩家碰杠吃盖牌Icon坐标配置字典
MahjongOperateCardIconPosConfigDicts = {
    [1] = {
        [1] = {posX = {-12, -10, -11, -11}, posY = 15, scale = {0.75, 0.75}, offset = {26, 22, 24, 24}, RotationZ = 0},
        [2] = {posX = {-6, -6, -6, -6}, posY = 15, scale = {0.75, 0.75}, offset = {16, 12, 14, 14}, RotationZ = 0},
        [3] = {posX = {-2, 0, 0, 0}, posY = 15, scale = {0.75, 0.75}, offset = {6, 0, 4, 4}, RotationZ = 0},
        [4] = {posX = {0, 0, -2, 0}, posY = 15, scale = {0.75, 0.75}, offset = {0, -4, -2, -2}, RotationZ = 0},
    },

    [2] = {
        [1] = {posX = -4, posY = 7, scale = {{-0.41, 0.61}, {-0.39, 0.59}, {-0.4, 0.6}, {-0.4, 0.6}}, offset = 36, RotationZ = 105},
        [2] = {posX = -4, posY = 7, scale = {{-0.38, 0.58}, {-0.36, 0.56}, {-0.37, 0.57}, {-0.37, 0.57}}, offset = 36, RotationZ = 105},
        [3] = {posX = -4, posY = 8, scale = {{-0.35, 0.55}, {-0.33, 0.53}, {-0.34, 0.54}, {-0.34, 0.54}}, offset = 36, RotationZ = 105},
        [4] = {posX = -4, posY = 8, scale = {{-0.32, 0.52}, {-0.3, 0.5}, {-0.31, 0.51}, {-0.31, 0.51}}, offset = 36, RotationZ = 104},
    },

    [3] = {
        [1] = {posX = {-2, -1, -1, -2}, posY = 15, scale = {0.5, 0.35}, offset = {-16, -12, -14, -14}, RotationZ = 180},
        [2] = {posX = {0, 0, 0, 0}, posY = 15, scale = {0.5, 0.35}, offset = {-10, -5, -7, -7}, RotationZ = 180},
        [3] = {posX = {1, -1, 1, 1}, posY = 15, scale = {0.5, 0.35}, offset = {-3, 3, 0, 0}, RotationZ = 180},
        [4] = {posX = {0, 0, 0, 0}, posY = 15, scale = {0.5, 0.35}, offset = {5, 9, 7, 7}, RotationZ = 180},
    },

    [4] = {
        [1] = {posX = -4, posY = 8, scale = {{0.3, 0.5}, {0.32, 0.52}, {0.31, 0.51}, {0.31, 0.51}}, offset = -38, RotationZ = -105},
        [2] = {posX = -4, posY = 7, scale = {{0.33, 0.53}, {0.35, 0.55}, {0.34, 0.54}, {0.34, 0.54}}, offset = -38, RotationZ = -106},
        [3] = {posX = -4, posY = 7, scale = {{0.36, 0.56}, {0.38, 0.58}, {0.37, 0.57}, {0.37, 0.57}}, offset = -38, RotationZ = -106},
        [4] = {posX = -4, posY = 7, scale = {{0.39, 0.59}, {0.41, 0.61}, {0.4, 0.6}, {0.4, 0.6}}, offset = -38, RotationZ = -106},
    }
}


--玩家碰杠吃盖牌Mark坐标配置字典
MahjongOperateCardMarkConfigDicts = {
    [1] = {
        [1] = {pos = {{1, -4}, {2, -4}, {1, -4}, {1, -4}}, scale = 0.8, offset = {16, 13, 14, 14}, RotationZ = 0},
        [2] = {pos = {{3, -4}, {3, -4}, {3, -4}, {3, -4}}, scale = 0.8, offset = {10, 7, 9, 9}, RotationZ = 0},
        [3] = {pos = {{4, -4}, {4, -4}, {4, -4}, {4, -4}}, scale = 0.8, offset = {4, 1, 2, 2}, RotationZ = 0},
        [4] = {pos = {{3, -4}, {3, -4}, {3, -4}, {3, -4}}, scale = 0.8, offset = {0, -2, -1, -1}, RotationZ = 0},
    },

    [2] = {
        [1] = {pos = {{28, 24}, {28, 24}, {27, 24}, {27, 24}}, scale = 0.4, offset = 15, RotationZ = 107},
        [2] = {pos = {{29, 25}, {28, 25}, {27, 25}, {27, 25}}, scale = 0.38, offset = 15, RotationZ = 107},
        [3] = {pos = {{29, 26}, {28, 26}, {28, 26}, {28, 26}}, scale = 0.36, offset = 15, RotationZ = 107},
        [4] = {pos = {{27, 26}, {27, 27}, {27, 27}, {27, 27}}, scale = 0.34, offset = 15, RotationZ = 107},
    },

    [3] = {
        [1] = {pos = {{-16, 46}, {-16, 46}, {-16, 46}, {-16, 46}}, scale = 0.35, offset = {-11, -9, -10, -10}, RotationZ = 180},
        [2] = {pos = {{-16, 46}, {-16, 46}, {-16, 46}, {-16, 46}}, scale = 0.35, offset = {-8, -4, -6, -6}, RotationZ = 180},
        [3] = {pos = {{-16, 46}, {-18, 46}, {-16, 46}, {-16, 46}}, scale = 0.35, offset = {-2, 1, 0, 0}, RotationZ = 180},
        [4] = {pos = {{-19, 46}, {-20, 46}, {-20, 46}, {-20, 46}}, scale = 0.35, offset = {3, 7, 5, 5}, RotationZ = 180},
    },

    [4] = {
        [1] = {pos = {{-16, 0}, {-16, 0}, {-16, 0}, {-16, 0}}, scale = 0.34, offset = -16, RotationZ = -107},
        [2] = {pos = {{-15, 1}, {-15, 1}, {-15, 1}, {-15, 1}}, scale = 0.36, offset = -16, RotationZ = -107},
        [3] = {pos = {{-14, 2}, {-14, 2}, {-14, 2}, {-14, 2}}, scale = 0.38, offset = -16, RotationZ = -107},
        [4] = {pos = {{-13, 3}, {-13, 3}, {-13, 3}, {-13, 3}}, scale = 0.4, offset = -16, RotationZ = -107},
    },
}
