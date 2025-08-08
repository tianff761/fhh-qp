--全局对象，用于存储全局使用的参数
TpGlobal = {
    --增加数字
    FontIncrease = nil,
    --减少数字
    FontDecrease = nil,
}

--最大的玩家总数
TpMaxPlayerTotal = 9

-- -- 等待玩家准备
-- GAME_WAIT_READY = 1
-- -- 发牌巴底阶段
-- GAME_DEAL_POKER_1 = 2
-- -- 第一轮下注
-- ROUND_1 = 3
-- -- 第2次发牌
-- GAME_DEAL_POKER_2 = 4
-- -- 第二轮下注
-- ROUND_2 = 5
-- -- 发最后一张牌
-- GAME_DEAL_POKER_3 = 6
-- -- 第3轮下注
-- ROUND_3 = 7
-- -- 结算
-- GAME_RESULT = 8
-- -- 游戏结束
-- GAME_END = 9
--游戏状态
TpGameStatus = {
    --无
    None = 0,
    --等待玩家准备
    ReadyWait = 1,
    --发牌巴底阶段
    DealPoker1 = 2,
    --第一轮下注
    Round1 = 3,
    --发牌第3张
    DealPoker2 = 4,
    --第二轮下注
    Round2 = 5,
    --发最后一张牌
    DealPoker3 = 6,
    --第3轮下注
    Round3 = 7,
    --结算
    GameResult = 8,
    --游戏结束
    GameEnd = 9,
}


--操作类型
-- DZ_BET = 1   	--下注
-- DZ_GEN = 2		--跟注
-- DZ_ALL_IN = 3		--all in
-- DZ_GIVE_UP = 4	--弃牌
-- DZ_CHECK = 5		--check 或者 说是看牌
TpOperateType = {
    --无
    None = 0,
    --下注
    Bet = 1,
    --跟注
    Gen = 2,
    --all in
    AllIn = 3,
    --弃牌
    GiveUp = 4,
    --check 或者 说是看牌
    Check = 5,
}

TpOperateTypeTxt = {
    Thinking = "<color=#FFFF00>思考中...</color>",
    Check = "<color=#00ABFF>看牌</color>",
    Bet = "<color=#FFFF00>加注</color>",
    Gen = "<color=#B8FF47>跟注</color>",
    GiveUp = "<color=#FF0000>弃牌</color>",
    AllIn = "<color=#FFFF00>All-In</color>",
}

-- 等待
-- PLAYER_STATUS_WAIT = 0
-- -- 操作
-- PLAYER_STATUS_OPER = 1
--玩家状态
TpPlayerStatus = {
    --等待
    Wait = 0,
    --操作
    Operate = 1,
}


--牌遮罩颜色类型
TpMaskColorType = {
    --无
    None = 0,
    --灰色
    Gray = 1,
}

--位置类型
TpPositionType = {
    --下
    Down = 1,
    --右
    Right = 2,
    --右下
    RightDown = 3,
    --右上
    RightUp = 4,
    --上
    Up = 5,
    --左
    Left = 6,
    --左上
    LeftUp = 7,
    --左下
    LeftDown = 8,
}

--根据人数处理
TpPositionDict = {
    [6] = {
        [1] = TpPositionType.Down,
        [2] = TpPositionType.Down,
        [3] = TpPositionType.Right,
        [4] = TpPositionType.Up,
        [5] = TpPositionType.Up,
        [6] = TpPositionType.Left,
    },
    [7] = {
        [1] = TpPositionType.Down,
        [2] = TpPositionType.Down,
        [3] = TpPositionType.Right,
        [4] = TpPositionType.Up,
        [5] = TpPositionType.Up,
        [6] = TpPositionType.Left,
        [7] = TpPositionType.Down,
    },
    [8] = {
        [1] = TpPositionType.Down,
        [2] = TpPositionType.Down,
        [3] = TpPositionType.RightDown,
        [4] = TpPositionType.RightUp,
        [5] = TpPositionType.Up,
        [6] = TpPositionType.Up,
        [7] = TpPositionType.LeftUp,
        [8] = TpPositionType.LeftDown,
    },
    [9] = {
        [1] = TpPositionType.Down,
        [2] = TpPositionType.Down,
        [3] = TpPositionType.RightDown,
        [4] = TpPositionType.RightUp,
        [5] = TpPositionType.Up,
        [6] = TpPositionType.Up,
        [7] = TpPositionType.LeftUp,
        [8] = TpPositionType.LeftDown,
        [9] = TpPositionType.Down,
    },
}

--下注筹码位置的值
TpBetChipPositionValue = {
    [TpPositionType.Down] = Vector2(4, 80),
    [TpPositionType.Right] = Vector2(-140, -20),
    [TpPositionType.RightDown] = Vector2(-130, 40),
    [TpPositionType.RightUp] = Vector2(-130, -40),
    [TpPositionType.Up] = Vector2(4, -120),
    [TpPositionType.Left] = Vector2(140, -20),
    [TpPositionType.LeftUp] = Vector2(130, -40),
    [TpPositionType.LeftDown] = Vector2(130, 40),
}

--表情位置
TpFaceAnimPositionValue = {
    [TpPositionType.Down] = Vector2(120, 0),
    [TpPositionType.Right] = Vector2(-120, 0),
    [TpPositionType.RightDown] = Vector2(-120, 0),
    [TpPositionType.RightUp] = Vector2(-120, 0),
    [TpPositionType.Up] = Vector2(120, 0),
    [TpPositionType.Left] = Vector2(120, 0),
    [TpPositionType.LeftUp] = Vector2(120, 0),
    [TpPositionType.LeftDown] = Vector2(120, 0),
}

--操作语音名字
TpOperateAudio = {
    [Global.GenderType.Male] = {

    },
    [Global.GenderType.Female] = {

    }
}

TpChatLabelArr = {
    [LanguageType.putonghua] = {
        [Global.GenderType.Male] = {
            { text = "大家好，很高兴见到各位！", audio = "man_chat0" },
            { text = "快点吧，我等到花儿都谢了。", audio = "man_chat1" },
            { text = "不要走！决战到天亮。", audio = "man_chat2" },
            { text = "你是帅哥，还是妹妹啊。", audio = "man_chat3" },
            { text = "君子报仇十盘不算晚。", audio = "man_chat4" },
            { text = "打错了！555555555", audio = "man_chat7" },
        },
        [Global.GenderType.Female] = {
            { text = "大家好，很高兴见到各位！", audio = "woman_chat0" },
            { text = "快点吧，我等到花儿都谢了。", audio = "woman_chat1" },
            { text = "不要走！决战到天亮。", audio = "woman_chat2" },
            { text = "你是帅哥，还是妹妹啊。", audio = "woman_chat3" },
            { text = "君子报仇十盘不算晚。", audio = "woman_chat4" },
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
TpErrorCode = {
    ERROR = -1,                      --系统错误
    NORMOL = 0,                      --正常
    READY_NOT_EXIT = 105101,         --"已经准备不能退出"}
    NOT_READY = 105102,              --"不是准备状态不能准备"}
    IS_READY = 105103,               --"已经准备了"}
    NO_PLAY = 105104,                --"没有参与游戏"}
    NO_IN_ING_STATUS = 105105,       --"没有在游戏进行状态，不能操作"}
    CANT_FIGHT_THIS_PLAYER = 105106, --"该玩家没有参与游戏或已经淘汰"}
    NOT_YOU_OPER = 105107,           --"不该你操作"}
    GEN_ZHU_GOLD_ERROR = 105108,     --"跟注金额错误"}
    GEN_ZHU_GOLD_LESS = 105109,      --"跟注金币不足"}
    ADD_ZHU_GOLD_ERROR = 105110,     --"加注金币不足"}
    ADD_ZHU_GOLD_LESS = 105111,      --"加注金币不足"}
    NO_IN_RESULT_STATUS = 105112,    --"没有在结算状态，不能操作"}
    ADD_ZHU_NO_CHANCE = 105113,      --"一个回合只能加注一次"}
    READY_GOLD_LESS = 105114,        --"准备时准入不足"}
    MORE_MAX_IG = 105115,            --"超过最大投入"}
    CANNOT_XIU = 105116,             --"不能休"}

    NOT_FANGZHU = 105120,            --"不是房主不能操作"}
    GAME_IS_START = 105121,          --"游戏已经开始"}
    PLAYER_LESS_NO_START = 105122,   --"人员不足，不能开始"}

    PLAYER_NO_EXIST = 105131,        --"玩家不存在"}
    PLAYER_HAVE_SEAT = 105132,       --"已经坐下了"}
    PLAYER_NO_SEAT = 105133,         --"没有空位"}
    PLAYER_NO_MONEY = 105134,        --"金币不足"}
    PLAYER_LAST_TREE = 105135,       --"不能坐下"}
    TP_ERROR_CANNOT_OP =  105117, --"不能进行该操作" }
}

--错误提示
TpErrorTips = {
    [TpErrorCode.READY_NOT_EXIT] = "已经准备不能退出",
    [TpErrorCode.NOT_READY] = "不是准备状态不能准备",
    [TpErrorCode.IS_READY] = "已经准备了",
    [TpErrorCode.NO_PLAY] = "没有参与游戏",
    [TpErrorCode.NO_IN_ING_STATUS] = "没有在游戏进行状态，不能操作",
    [TpErrorCode.CANT_FIGHT_THIS_PLAYER] = "该玩家没有参与游戏或已经淘汰",
    [TpErrorCode.NOT_YOU_OPER] = "不该你操作",
    [TpErrorCode.GEN_ZHU_GOLD_ERROR] = "跟注金额错误",
    [TpErrorCode.GEN_ZHU_GOLD_LESS] = "跟注金币不足",
    [TpErrorCode.ADD_ZHU_GOLD_ERROR] = "加注金币错误",
    [TpErrorCode.ADD_ZHU_GOLD_LESS] = "加注金币不足",
    [TpErrorCode.NO_IN_RESULT_STATUS] = "没有在结算状态，不能操作",
    [TpErrorCode.ADD_ZHU_NO_CHANCE] = "一个回合只能加注一次",
    [TpErrorCode.READY_GOLD_LESS] = "准备时准入不足",
    [TpErrorCode.MORE_MAX_IG] = "超过最大投入",
    [TpErrorCode.CANNOT_XIU] = "不能Check",

    [TpErrorCode.NOT_FANGZHU] = "不是房主不能操作",
    [TpErrorCode.GAME_IS_START] = "游戏已经开始",
    [TpErrorCode.PLAYER_LESS_NO_START] = "人员不足，不能开始",

    [TpErrorCode.PLAYER_NO_EXIST] = "玩家不存在",
    [TpErrorCode.PLAYER_HAVE_SEAT] = "已经坐下了",
    [TpErrorCode.PLAYER_NO_SEAT] = "没有空位",
    [TpErrorCode.PLAYER_NO_MONEY] = "金币不足",
    [TpErrorCode.PLAYER_LAST_TREE] = "不能坐下",
    [TpErrorCode.TP_ERROR_CANNOT_OP] = "不能进行该操作",
}

--特效名称
TpEffectName = {
    Gang = "EffectGang",
}
