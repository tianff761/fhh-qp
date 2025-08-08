--十点半配置
SDB = {}
--玩法类型
SDB.PlayWayType = {
    --轮流庄家
    TakeRunBanker = 1,
    --房主当庄
    OwerBanker = 2,
    --自由抢庄
    FreeBanker = 3,
    --明牌抢庄
    MingPaiBanker = 4,
}

--规则类型
SDB.RuleType = {
    --玩法类型
    PlayWayType = "wanfa",
    --游戏局数，15局 20局 30局
    GameTotal = "jushu",
    --人数，4 6
    PlayerTotal = "renshu",
    --支付方式，0无、1房主支付、2AA制支付、3亲友圈支付、4大赢家付
    Pay = "zhifu",
    --规则key
    Key = "key",
    --房间类型
    RoomType = "roomtype",
    --房间押注
    Bet = "Bet",
    --茶馆底分
    TeaScore = "ts",
    --模式  1 传统 2癞子
    Model = "moshi",
    --自动开始 
    AutoStart = "kaishi",
    --推注
    TuiZhu = "tuizhu",
    --抢庄倍率
    QiangZhuang = "qiangzhuang",
    --游戏开始禁止加入
    CanJoin = "canJoin",
    --禁止搓牌
    CanCuoPai = "canCuoPai",
    --庄番倍
    ZhuangFanBei = "ZhuangFanBei",
    --平点庄胜
    PingDianZhuangWin = "ZhuangWin",
    --下注限制
    XiaZhuLimit = "XiaZhu",
    --高级选项
    HighOption = "gaoji",
    --Gps选项
    Gps = "gp",
    --入场分
    EnterLimit = "EnterLimit",
    --出场分
    KickLimit = "KickLimit",
    ---表情比例
    ExpressionPercent = "expressionNum",
    ---保底
    KeepBaseNum = "keepBaseNum",
}

--玩法规则配置，如果是复选框，选中则使用Value值，否则使用0，单选框则使用相应的Value值
SDB.RuleConfig = {
    --局数
    GameTotalOne = { name = "1局", tips = "1局", type = SDB.RuleType.GameTotal, value = 1, cards = 1, group = 3 },
    GameTotalFourteen = { name = "15局", tips = "15局", desc = "15局", type = SDB.RuleType.GameTotal, value = 15, cards = 3, group = 3 },
    GameTotalTwenty = { name = "20局", tips = "20局", desc = "20局", type = SDB.RuleType.GameTotal, value = 20, cards = 4, group = 3 },
    GameTotalThirty = { name = "30局", tips = "30局", desc = "30局", type = SDB.RuleType.GameTotal, value = 30, cards = 5, group = 3 },
    --支付方式
    PayOwner = { name = "房主支付", type = SDB.RuleType.Pay, value = 1, group = 4 },
    PayAA = { name = "AA支付", type = SDB.RuleType.Pay, value = 2, group = 4 },
    PayClub = { name = "亲友圈付", type = SDB.RuleType.Pay, value = 3, group = 4 },
    PayWinner = { name = "大赢家付", type = SDB.RuleType.Pay, value = 4, group = 4 },
    --底分
    BaseCore1 = { name = "1/2/4/6", type = SDB.RuleType.Bet, value = 3, group = 1 },
    BaseCore2 = { name = "2/4/6/8", type = SDB.RuleType.Bet, value = 1, group = 1 },
    BaseCore3 = { name = "5/10/15/20", type = SDB.RuleType.Bet, value = 2, group = 1 },
    --人数
    --GameNum4 = { name = "4人", type = SDB.RuleType.PlayerTotal, value = 1, group = 2 },
    GameNum6 = { name = "6人", type = SDB.RuleType.PlayerTotal, value = 6, group = 2 },
    GameNum8 = { name = "8人", type = SDB.RuleType.PlayerTotal, value = 8, group = 2 },
    --模式
    ChuanTongModel = { name = "传统", type = SDB.RuleType.Model, value = 1, group = 5 },
    LaiZiModel = { name = "癞子", type = SDB.RuleType.Model, value = 2, group = 5 },
    WuLaiZiModel = { name = "底牌无癞子", type = SDB.RuleType.Model, value = 3, group = 5 },
    --自动开始
    ShouDongStart = { name = "手动开始", type = SDB.RuleType.AutoStart, value = 1, group = 6 },
    Full4RenStart = { name = "满4人开", type = SDB.RuleType.AutoStart, value = 2, group = 6 },
    Full6RenStart = { name = "满6人开", type = SDB.RuleType.AutoStart, value = 3, group = 6 },
    --推注
    TuiZhu0 = { name = "无", type = SDB.RuleType.TuiZhu, value = 1, group = 7 },
    TuiZhu5 = { name = "5倍", type = SDB.RuleType.TuiZhu, value = 2, group = 7 },
    TuiZhu10 = { name = "10倍", type = SDB.RuleType.TuiZhu, value = 3, group = 7 },
    TuiZhu15 = { name = "15倍", type = SDB.RuleType.TuiZhu, value = 4, group = 7 },
    --抢庄倍率
    QiangZhuang1 = { name = "1倍", type = SDB.RuleType.QiangZhuang, value = 1, group = 8 },
    QiangZhuang2 = { name = "2倍", type = SDB.RuleType.QiangZhuang, value = 2, group = 8 },
    QiangZhuang3 = { name = "3倍", type = SDB.RuleType.QiangZhuang, value = 3, group = 8 },
    QiangZhuang4 = { name = "4倍", type = SDB.RuleType.QiangZhuang, value = 4, group = 8 },

    --游戏开始禁止加入
    CanJoin = { name = "中途禁止加入", type = SDB.RuleType.CanJoin, value = 1, group = 0 },
    --禁止搓牌
    -- CanCuoPai = { name = "禁止搓牌", type = SDB.RuleType.CanJoin, value = 1, group = 0 },
    --庄家翻倍
    ZhuangFanBei = { name = "庄家翻倍", type = SDB.RuleType.ZhuangFanBei, value = 1, group = 0 },
    --平点庄胜
    PingDianZhuangWin = { name = "平点庄胜", type = SDB.RuleType.PingDianZhuangWin, value = 1, group = 0 },
    --下注限制
    XiaZhuLimit = { name = "下注限制", type = SDB.RuleType.XiaZhuLimit, value = 1, group = 0 },
    Gps = { name = "强制定位", type = SDB.RuleType.Gps, value = 1, group = 0 },
}

--规则配置映射
SDB.RuleConfigMap = {}

--初始规则配置映射
function SDB.InitRuleConfigMap()
    local temp = nil
    for k, v in pairs(SDB.RuleConfig) do
        temp = SDB.RuleConfigMap[v.type]
        if temp == nil then
            temp = {}
            SDB.RuleConfigMap[v.type] = temp
        end
        temp[v.value] = v
    end
end

--执行
SDB.InitRuleConfigMap()

--规则组配置类型，客户端使用
SDB.RuleGroupConfigType = {
    --底分
    DiFen = 1000,
    --人数
    PlayerTotal = 2000,
    --局数
    GameTotal = 3000,
    --支付
    Pay = 4000,
    --模式
    Model = 5000,
    --自动开始
    AutoStart = 6000,
    --推注
    TuiZhu = 7000,
    --抢庄倍率
    QiangZhuang = 8000,
    --高级选项
    HighOption = 9000,
    --游戏说明
    GameTips = 10000,
}

--规则组配置
SDB.RuleGroupConfig = {
    --底分
    BaseCore = {
        name = "押        注：",
        sprite = "",
        type = SDB.RuleGroupConfigType.DiFen,
    },
    --人数
    PlayerTotal = {
        name = "人        数：",
        sprite = "",
        type = SDB.RuleGroupConfigType.PlayerTotal,
    },
    --局数
    GameTotal = {
        name = "局        数：",
        sprite = "",
        type = SDB.RuleGroupConfigType.GameTotal,
    },
    --房费
    Pay = {
        name = "房        费：",
        sprite = "",
        type = SDB.RuleGroupConfigType.Pay,
    },
    --模式
    Model = {
        name = "模        式：",
        sprite = "",
        type = SDB.RuleGroupConfigType.Model,
    },
    --自动开始
    AutoStart = {
        name = "自动开始：",
        sprite = "",
        type = SDB.RuleGroupConfigType.AutoStart,
    },
    --推注
    TuiZhu = {
        name = "推注选项：",
        sprite = "",
        type = SDB.RuleGroupConfigType.TuiZhu,
    },
    --抢庄倍率
    QiangZhuang = {
        name = "抢庄倍率：",
        sprite = "",
        type = SDB.RuleGroupConfigType.QiangZhuang,
    },
    --高级选项
    HighOption = {
        name = "高级选项：",
        sprite = "",
        type = SDB.RuleGroupConfigType.HighOption,
    },
    --游戏提示说明
    GameTips = {
        name = "注        释：",
        sprite = "",
        type = SDB.RuleGroupConfigType.GameTips,
    }
}

--支付的规则组配置
SDB.RuleGroupConfigPay = {
    data = SDB.RuleGroupConfig.Pay,
    rules = {
        { data = SDB.RuleConfig.PayOwner, selected = true, interactable = true },
       -- { data = SDB.RuleConfig.PayAA, selected = false, interactable = true },
    }
}

--玩法名称
SDB.PlayWayNames = {
    [SDB.PlayWayType.MingPaiBanker] = "明牌抢庄",
    [SDB.PlayWayType.TakeRunBanker] = "轮流庄家",
    [SDB.PlayWayType.OwerBanker] = "房主当庄",
    [SDB.PlayWayType.FreeBanker] = "自由抢庄",
}

--玩法配置
SDB.PlayWayConfig = {
    TakeRunBanker = {
        name = "轮流庄家",
        playWayType = SDB.PlayWayType.TakeRunBanker,
        -- playerTotal = 4,
        --默认的规则配置，直接使用，且不显示UI
        ruleGroups = {
            {
                data = SDB.RuleGroupConfig.BaseCore,
                rules = {
                    { data = SDB.RuleConfig.BaseCore1, selected = true, interactable = false },
                    { data = SDB.RuleConfig.BaseCore2, selected = true, interactable = true },
                    { data = SDB.RuleConfig.BaseCore3, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.PlayerTotal,
                rules = {
                    
                    { data = SDB.RuleConfig.GameNum6, selected = true, interactable = true },
                    { data = SDB.RuleConfig.GameNum8, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.GameTotal,
                rules = {
                    --{ data = SDB.RuleConfig.GameTotalOne, selected = true, interactable = false },
                    { data = SDB.RuleConfig.GameTotalFourteen, selected = true, interactable = true },
                    { data = SDB.RuleConfig.GameTotalTwenty, selected = false, interactable = true },
                    { data = SDB.RuleConfig.GameTotalThirty, selected = false, interactable = true },
                }
            },
            SDB.RuleGroupConfigPay,
            {
                data = SDB.RuleGroupConfig.Model,
                rules = {
                    { data = SDB.RuleConfig.ChuanTongModel, selected = true, interactable = true },
                    { data = SDB.RuleConfig.LaiZiModel, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.AutoStart,
                rules = {
                    { data = SDB.RuleConfig.ShouDongStart, selected = true, interactable = true },
                    { data = SDB.RuleConfig.Full4RenStart, selected = false, interactable = true },
                    { data = SDB.RuleConfig.Full6RenStart, selected = false, interactable = true },

                }
            },
            {
                data = SDB.RuleGroupConfig.TuiZhu,
                rules = {
                    { data = SDB.RuleConfig.TuiZhu0, selected = true, interactable = true },
                    { data = SDB.RuleConfig.TuiZhu5, selected = false, interactable = true },
                    { data = SDB.RuleConfig.TuiZhu10, selected = false, interactable = true },
                    { data = SDB.RuleConfig.TuiZhu15, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.HighOption,
                rules = {
                    { data = SDB.RuleConfig.CanJoin, selected = false, interactable = true },
                    { data = SDB.RuleConfig.ZhuangFanBei, selected = false, interactable = true },
                    { data = SDB.RuleConfig.PingDianZhuangWin, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.GameTips,
                rules = {}
            },
        }
    },

    OwerBanker = {
        name = "房主当庄",
        playWayType = SDB.PlayWayType.OwerBanker,
        -- playerTotal = 4,
        --默认的规则配置，直接使用，且不显示UI
        ruleGroups = {
            {
                data = SDB.RuleGroupConfig.BaseCore,
                rules = {
                    { data = SDB.RuleConfig.BaseCore1, selected = true, interactable = false },
                    { data = SDB.RuleConfig.BaseCore2, selected = true, interactable = true },
                    { data = SDB.RuleConfig.BaseCore3, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.PlayerTotal,
                rules = {
                    { data = SDB.RuleConfig.GameNum6, selected = true, interactable = true },
                    { data = SDB.RuleConfig.GameNum8, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.GameTotal,
                rules = {
                    --{ data = SDB.RuleConfig.GameTotalOne, selected = true, interactable = false },
                    { data = SDB.RuleConfig.GameTotalFourteen, selected = true, interactable = true },
                    { data = SDB.RuleConfig.GameTotalTwenty, selected = false, interactable = true },
                    { data = SDB.RuleConfig.GameTotalThirty, selected = false, interactable = true },
                }
            },
            SDB.RuleGroupConfigPay,
            {
                data = SDB.RuleGroupConfig.Model,
                rules = {
                    { data = SDB.RuleConfig.ChuanTongModel, selected = true, interactable = true },
                    { data = SDB.RuleConfig.LaiZiModel, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.AutoStart,
                rules = {
                    { data = SDB.RuleConfig.ShouDongStart, selected = true, interactable = true },
                    { data = SDB.RuleConfig.Full4RenStart, selected = false, interactable = true },
                    { data = SDB.RuleConfig.Full6RenStart, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.TuiZhu,
                rules = {
                    { data = SDB.RuleConfig.TuiZhu0, selected = true, interactable = true },
                    { data = SDB.RuleConfig.TuiZhu5, selected = false, interactable = true },
                    { data = SDB.RuleConfig.TuiZhu10, selected = false, interactable = true },
                    { data = SDB.RuleConfig.TuiZhu15, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.HighOption,
                rules = {
                    { data = SDB.RuleConfig.CanJoin, selected = false, interactable = true },
                    { data = SDB.RuleConfig.ZhuangFanBei, selected = false, interactable = true },
                    { data = SDB.RuleConfig.PingDianZhuangWin, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.GameTips,
                rules = {}
            },
        }
    },

    FreeBanker = {
        name = "自由抢庄",
        playWayType = SDB.PlayWayType.FreeBanker,
        -- playerTotal = 4,
        --默认的规则配置，直接使用，且不显示UI
        ruleGroups = {
            {
                data = SDB.RuleGroupConfig.BaseCore,
                rules = {
                    { data = SDB.RuleConfig.BaseCore1, selected = true, interactable = false },
                    { data = SDB.RuleConfig.BaseCore2, selected = true, interactable = true },
                    { data = SDB.RuleConfig.BaseCore3, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.PlayerTotal,
                rules = {
                    { data = SDB.RuleConfig.GameNum6, selected = true, interactable = true },
                    { data = SDB.RuleConfig.GameNum8, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.GameTotal,
                rules = {
                    --{ data = SDB.RuleConfig.GameTotalOne, selected = true, interactable = false },
                    { data = SDB.RuleConfig.GameTotalFourteen, selected = true, interactable = true },
                    { data = SDB.RuleConfig.GameTotalTwenty, selected = false, interactable = true },
                    { data = SDB.RuleConfig.GameTotalThirty, selected = false, interactable = true },
                }
            },
            SDB.RuleGroupConfigPay,
            {
                data = SDB.RuleGroupConfig.Model,
                rules = {
                    { data = SDB.RuleConfig.ChuanTongModel, selected = true, interactable = true },
                    { data = SDB.RuleConfig.LaiZiModel, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.AutoStart,
                rules = {
                    { data = SDB.RuleConfig.ShouDongStart, selected = true, interactable = true },
                    { data = SDB.RuleConfig.Full4RenStart, selected = false, interactable = true },
                    { data = SDB.RuleConfig.Full6RenStart, selected = false, interactable = true },
                }
            },

            {
                data = SDB.RuleGroupConfig.TuiZhu,
                rules = {
                    { data = SDB.RuleConfig.TuiZhu0, selected = true, interactable = true },
                    { data = SDB.RuleConfig.TuiZhu5, selected = false, interactable = true },
                    { data = SDB.RuleConfig.TuiZhu10, selected = false, interactable = true },
                    { data = SDB.RuleConfig.TuiZhu15, selected = false, interactable = true },
                }
            },

            {
                data = SDB.RuleGroupConfig.QiangZhuang,
                rules = {
                    { data = SDB.RuleConfig.QiangZhuang1, selected = true, interactable = true },
                    { data = SDB.RuleConfig.QiangZhuang2, selected = false, interactable = true },
                    { data = SDB.RuleConfig.QiangZhuang3, selected = false, interactable = true },
                    { data = SDB.RuleConfig.QiangZhuang4, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.HighOption,
                rules = {
                    { data = SDB.RuleConfig.CanJoin, selected = false, interactable = true },
                    { data = SDB.RuleConfig.ZhuangFanBei, selected = false, interactable = true },
                    { data = SDB.RuleConfig.PingDianZhuangWin, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.GameTips,
                rules = {}
            },
        }
    },

    MingPaiBanker = {
        name = "明牌抢庄",
        playWayType = SDB.PlayWayType.MingPaiBanker,
        -- playerTotal = 4,
        --默认的规则配置，直接使用，且不显示UI
        ruleGroups = {
            {
                data = SDB.RuleGroupConfig.BaseCore,
                rules = {
                    { data = SDB.RuleConfig.BaseCore1, selected = true, interactable = false },
                    { data = SDB.RuleConfig.BaseCore2, selected = true, interactable = true },
                    { data = SDB.RuleConfig.BaseCore3, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.PlayerTotal,
                rules = {
                    { data = SDB.RuleConfig.GameNum6, selected = true, interactable = true },
                    { data = SDB.RuleConfig.GameNum8, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.GameTotal,
                rules = {
                    --{ data = SDB.RuleConfig.GameTotalOne, selected = true, interactable = false },
                    { data = SDB.RuleConfig.GameTotalFourteen, selected = true, interactable = true },
                    { data = SDB.RuleConfig.GameTotalTwenty, selected = false, interactable = true },
                    { data = SDB.RuleConfig.GameTotalThirty, selected = false, interactable = true },
                }
            },
            SDB.RuleGroupConfigPay,
            {
                data = SDB.RuleGroupConfig.Model,
                rules = {
                    { data = SDB.RuleConfig.ChuanTongModel, selected = true, interactable = true },
                    { data = SDB.RuleConfig.LaiZiModel, selected = false, interactable = true },
                    { data = SDB.RuleConfig.WuLaiZiModel, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.AutoStart,
                rules = {
                    { data = SDB.RuleConfig.ShouDongStart, selected = true, interactable = true },
                    { data = SDB.RuleConfig.Full4RenStart, selected = false, interactable = true },
                    { data = SDB.RuleConfig.Full6RenStart, selected = false, interactable = true },
                }
            },

            {
                data = SDB.RuleGroupConfig.TuiZhu,
                rules = {
                    { data = SDB.RuleConfig.TuiZhu0, selected = true, interactable = true },
                    { data = SDB.RuleConfig.TuiZhu5, selected = false, interactable = true },
                    { data = SDB.RuleConfig.TuiZhu10, selected = false, interactable = true },
                    { data = SDB.RuleConfig.TuiZhu15, selected = false, interactable = true },
                }
            },

            {
                data = SDB.RuleGroupConfig.QiangZhuang,
                rules = {
                    { data = SDB.RuleConfig.QiangZhuang1, selected = true, interactable = true },
                    { data = SDB.RuleConfig.QiangZhuang2, selected = false, interactable = true },
                    { data = SDB.RuleConfig.QiangZhuang3, selected = false, interactable = true },
                    { data = SDB.RuleConfig.QiangZhuang4, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.HighOption,
                rules = {
                    { data = SDB.RuleConfig.CanJoin, selected = false, interactable = true },
                    { data = SDB.RuleConfig.ZhuangFanBei, selected = false, interactable = true },
                    { data = SDB.RuleConfig.PingDianZhuangWin, selected = false, interactable = true },
                    { data = SDB.RuleConfig.XiaZhuLimit, selected = false, interactable = true },
                }
            },
            {
                data = SDB.RuleGroupConfig.GameTips,
                rules = {}
            },
        }
    },
}
SDB.TipsConfig = {
    TuiZhuDes = { "推注：闲家获胜后，下局可以将所赢得的积分与地主一起下注，最大推注为底分设置的倍数，不可连续推注。" },
    ModelDes = { "模式：选择癞子模式后大小王可以变换为任意其他牌，手牌只有大小王时认作十点半。" },
    ZhuangFanBeiDes = { "庄家翻倍：选择庄家翻倍后，庄家特殊牌型将享受翻倍。" },
    PingDianZhuangWinDes = { "平点庄胜：选择平点庄胜后，平点牌型同点数庄家赢，特殊牌型相同时闲家赢，平点指半点到十点的普通牌型。" },
    XiaZhuLimitDes = { "下注限制:手动参与抢庄且倍数最高但没抢到庄家的玩家下注时，不能以最小分下注，较低倍数抢庄和不抢庄的玩家，不能使用推注功能。" },
}

--创建房间配置
SDB.CreateRoomConfig = {
    SDB.PlayWayConfig.TakeRunBanker,
    SDB.PlayWayConfig.OwerBanker,
    SDB.PlayWayConfig.FreeBanker,
    SDB.PlayWayConfig.MingPaiBanker,
}

--================================================================
--

--底分配置
SDB.DiFenConfig = { 0.1, 0.2, 0.3, 0.5, 1, 2, 3, 4, 5, 6, 10, 20 }
--底分配置，用于Dropdown列表
SDB.DiFenNameConfig = { "0.1分", "0.2分", "0.3分", "0.5分", "1分", "2分", "3分", "4分", "5分", "6分", "10分", "20分" }

--消费配置
SDB.ConsumeConfig = {
    [1] = {[1] = 100501, [2] = 100502 },
    [2] = {[1] = 100503, [2] = 100504 },
    [3] = {[1] = 100505, [2] = 100506 },

}
SDB.CardsConfig = {
    [1] = {[1] = 3, [2] = 4, [3] = 5 },
    [2] = {[1] = 5, [2] = 6, [3] = 8 },
    [3] = {[1] = 7, [2] = 9, [3] = 12 },
}

--人数
SDB.PopulationConfig = {
    [1] = 6,
    [2] = 8,
}
SDB.GameTotalConfig = {
    [1] = 15,
    [2] = 20,
    [3] = 30,
}


function SDB.GetCardsConfig(playerTotal, gameTotal)
    local cards = 0
    local temp = SDB.CardsConfig[playerTotal]
    if temp ~= nil then
        local tempConfig = temp[gameTotal]
        if tempConfig ~= nil then
            cards = tempConfig
        end
    end
    return cards
end

--获取消费ID
function SDB.GetConsumeConfigId(playerTotal, gameTotal)
    local id = 0

    local temp = SDB.ConsumeConfig[gameTotal]
    if temp ~= nil then
        local tempConfig = temp[playerTotal]
        if tempConfig ~= nil then
            id = tempConfig
        end
    end
    return id
end

------------------------------------------------------------------
--================================================================
--
--规则排序配置
SDB.RuleSortConfig = {
    --SDB.RuleType.GameTotal,单独处理
    SDB.RuleType.Bet,
    SDB.RuleType.PlayerTotal,
    SDB.RuleType.Model,
    SDB.RuleType.AutoStart,
    SDB.RuleType.TuiZhu,
    SDB.RuleType.QiangZhuang,
    SDB.RuleType.CanJoin,
    SDB.RuleType.ZhuangFanBei,
    SDB.RuleType.PingDianZhuangWin,
    SDB.RuleType.XiaZhuLimit,
    SDB.RuleType.Gps,
    SDB.RuleType.Pay,
}

--玩法规则映射配置，每一个玩法都有相应的映射配置数据
--处理解析等使用
SDB.PlayWayRuleMappingConfig = {}

--获取玩法的规则映射配置
function SDB.GetPlayWayRuleMappingConfig(playWayType)
    local result = SDB.PlayWayRuleMappingConfig[playWayType]
    if result == nil then
        result = SDB.HandlePlayWayRuleMappingConfig(playWayType)
    end
    return result
end

--处理玩法规则映射配置
function SDB.HandlePlayWayRuleMappingConfig(playWayType)
    local createRoomConfigData = nil
    local length = #SDB.CreateRoomConfig
    for i = 1, length do
        if SDB.CreateRoomConfig[i].playWayType == playWayType then
            createRoomConfigData = SDB.CreateRoomConfig[i]
            break
        end
    end
    if createRoomConfigData == nil then
        createRoomConfigData = SDB.CreateRoomConfig[1]
    end

    local mappingConfig = {}
    SDB.PlayWayRuleMappingConfig[playWayType] = mappingConfig

    local temp = nil
    local tempLength = nil
    --处理ruleGroups
    length = #createRoomConfigData.ruleGroups
    local rulesData = nil
    for i = 1, length do
        temp = createRoomConfigData.ruleGroups[i]
        tempLength = #temp.rules
        for j = 1, tempLength do
            rulesData = temp.rules[j]
            SDB.AddMappingRuleConfigData(mappingConfig, rulesData.data.type, rulesData.data)
        end
    end
    return mappingConfig
end

--添加玩法规则映射配置的规则数据
function SDB.AddMappingRuleConfigData(mappingConfig, ruleType, ruleData)
    local mappingRules = mappingConfig[ruleType]
    if mappingRules == nil then
        mappingRules = {}
        mappingConfig[ruleType] = mappingRules
    end
    mappingRules[ruleData.value] = ruleData
end

--获取映射的规则配置数据
function SDB.GetMappingRuleConfigData(mappingConfig, type, value)
    local mappingRules = mappingConfig[type]
    if mappingRules ~= nil and value ~= nil then
        return mappingRules[value]
    else
        return nil
    end
end


--解析十点半规则数据
function SDB.ParseSDBRule(ruleObj, separator, bdPer)
    if string.IsNullOrEmpty(separator) then
        separator = " "
    end
   

    local playWayName = ""
    local PlayWayType = 0
    local juShu = 0
    local juShuTxt = ""
    local juShuTips = ""
    local rule = ""
    local cards = 0--房卡
    local  diFen = 1
    if IsTable(ruleObj) then
        local playWayType = ruleObj[SDB.RuleType.PlayWayType]
        PlayWayType = playWayType
        --映射配置
        local mappingConfig = SDB.GetPlayWayRuleMappingConfig(playWayType)
        --玩法名称
        playWayName = SDB.PlayWayNames[playWayType]
        ruleObj[SDB.RuleType.Gps] = nil
        --临时变量定义
        local ruleType = nil
        local ruleValue = nil
        local ruleConfigData = nil
        --局数相关
        ruleType = SDB.RuleType.GameTotal
        ruleValue = ruleObj[ruleType]
        ruleConfigData = SDB.GetMappingRuleConfigData(mappingConfig, ruleType, ruleValue)
        if ruleConfigData ~= nil then
            juShu = ruleConfigData.value
            cards = ruleConfigData.cards
            juShuTxt = ruleConfigData.name
            juShuTips = ruleConfigData.tips
        end
        if juShu < 0 then
            juShuTxt = "--"
        end
        if ruleObj[SDB.RuleType.RoomType] == RoomType.Tea then
            if ruleObj[SDB.RuleType.TeaScore] ~= nil  then
               diFen  = ruleObj[SDB.RuleType.TeaScore]
            end
        end
        --
        --其他规则
        local length = #SDB.RuleSortConfig
        for i = 1, length do
            ruleType = SDB.RuleSortConfig[i]
            ruleValue = ruleObj[ruleType]
            ruleConfigData = SDB.GetMappingRuleConfigData(mappingConfig, ruleType, ruleValue)
            if ruleConfigData ~= nil then
                if ruleConfigData.type == SDB.RuleType.TuiZhu then
                    rule = rule .. "推注(" .. ruleConfigData.name .. ")"
                elseif ruleConfigData.type == SDB.RuleType.QiangZhuang then
                    rule = rule .. "抢庄倍率(" .. ruleConfigData.name .. ")"
                elseif ruleConfigData.type == SDB.RuleType.Bet then
                    rule = rule .. "押注(" .. ruleConfigData.name .. ")"
                elseif ruleConfigData.type == SDB.RuleType.Model then
                    rule = rule .. "模式(" .. ruleConfigData.name .. ")"
                elseif ruleConfigData.type == SDB.RuleType.AutoStart then
                    rule = rule .. ""
                elseif ruleConfigData.type == SDB.RuleType.PlayerTotal then
                    rule = rule .. "人数(" .. ruleConfigData.name .. ")"
                else
                    rule = rule .. ruleConfigData.name
                end

                rule = (UnionData.selfRole == UnionRole.Leader and ruleObj[SDB.RuleType.ExpressionPercent] and ruleObj[SDB.RuleType.KeepBaseNum]) and rule .. "表情比例 " .. ruleObj[Pin5RuleType.ExpressionPercent] .. "%" .. separator .. "保底 " .. ruleObj[Pin5RuleType.KeepBaseNum] or rule

                if i < length then
                    --最后不加分隔符
                    rule = rule .. separator
                end
            end
        end
        --
    end

    if playWayName == nil then
        playWayName = ""
    end
    return {
        playWayName = playWayName,
        playWayType = PlayWayType,
        juShu = juShu,
        juShuTxt = juShuTxt,
        juShuTips = juShuTips,
        rule = rule,
        cards = cards,
        baseScore = diFen,
        playerTotal = 4,
        tips = ""
    }
end
--================================================================