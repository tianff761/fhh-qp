--贰柒拾玩法类型
EqsPlayType = {
    LeShan = 1,
    JianWei = 2,
    MeiShan = 3,
    SiRen14Zhang = 4,
    SiRenXiaoJia = 5,
    SanRen14Zhang = 6,
    ErRen = 7,
    ErRen14Zhang = 8,
}

--贰柒拾规则类型定义
EqsRuleType = {
    -- 房间类型  即贰柒拾玩法类型
    RType = "rt",
    -- 圈数
    QuanShu = "qs",
    --封顶
    FengDing = "fd",
    --房卡方式：1房主付
    PayType = "pt",
    --房间人数 
    RoomNum = "rn",
    --天地胡
    TianDiHu = "tdh",
    --坤
    Kun = "kh",
    --漂
    Piao = "ph",
    --圈胡
    QuanHu = "qh",
    --下雨
    XiaYu = "xy",
    --巴雨加胡
    BaYuJiaHu = "byjh",
    --清一色
    QingYiSe = "qys",
    --磙翻
    GunFan = "gf",
    --打半圈自付
    DaBanQuanZiFu = "dqbzf",
    --大胡
    DaHu = "dh",
    --上台
    ShangTai = "st",
    --双圈
    ShuangQuan = "sq",
    --小家自摸加翻
    XiaoJiaZiMoJiaFan = "xjzmjf",
    --胡牌算法  1乐山    2眉山   3犍为
    HuPaiSuanFa = "hpsf",
    --小家胡数算法      XiaoJia1Toggle
    XiaoJiaHuShuSuanFa = "hssf",
    --无大小幺
    WuDaXiaoYao = "wdxy",
    --换三张
    HuanSanZhang = "hsz",
    --起胡胡数(十四张三人规则)
    QiHuHuShu = "qhhs",
    --
    --底分              
    TeaBaseScore = "tbs",
    --准入              
    ZhunRu = "zr",
    --入场条件
    TeaInGold = "tig",
    --是否打开分数娱乐场
    TeaIsOpen = "ioc",
    --消耗类型 1房卡   2分数
    RoomType = "trt",
    --是否是强制GPS
    Gps = "GPS",
    --听牌提示
    TingPaiTiShi = "tpts",
    --
    --客户端自定义
    TianDiKunPiao = "c1",
    TianDiKunPiaoQuan = "c2",
    DaHuShangTai = "c3",
    Desc = "c4",
    ZhuoFei = "ZF",
    ZhuoFeiMin = "MZF",
    --解散分数
    JieSanFenShu = "JSFS",
    ---14张2人点炮包几家
    DianPaoNum = "dpn",

    ---保底
    KeepBaseNum = "keepBaseNum",
}

EqsRule = {}

--规则描述
EqsRule.DescConfig = {
    [EqsPlayType.LeShan] = {
        height = 150,
        text = "10-14胡  1个           15-20胡  2个           21-24胡  4个\n25-30胡  6个           30胡以上  10个\n胡牌: 个数加番，10个封顶    抬炮: 包三家，30个封顶",
    },
    [EqsPlayType.JianWei] = {
        height = 150,
        text = "10胡  1个    11-20胡  2个    21-30胡  4个    30胡以上  8个\n抬炮: 8个封顶时，包三家24个封顶\n        16个封顶时，包三家48个封顶",
    },
    [EqsPlayType.MeiShan] = {
        height = 150,
        text = "按胡数加番，四舍五入成算个数\n30封顶时，抬炮包三家，胡牌或抬炮30个封顶\n40封顶时，抬炮包三家，胡牌40个封顶，抬炮120个封顶",
    },
    [EqsPlayType.SiRen14Zhang] = {
        height = 150,
        text = "1胡起胡，按胡数加番\n100胡封顶时，番胡每家100胡封顶，抬炮包三家，300胡封顶\n300胡封顶时，番胡每家300胡封顶，抬炮包三家，900胡封顶",
    },
    [EqsPlayType.SanRen14Zhang] = {
        height = 150,
        text = "50胡封顶时，番胡每家50胡封顶，抬炮包三家，150胡封顶\n100胡封顶时，番胡每家100胡封顶，抬炮包三家，300胡封顶\n300胡封顶时，番胡每家300胡封顶，抬炮包三家，900胡封顶",
    },
    --二人的规则描述
    [EqsPlayType.ErRen] = {
        height = 150,
        text = nil,
        list = {
            [1] = "10-14胡 1个            15-20胡 2个               21-24胡 4个  \n25-30胡 6个            31胡以上 10个\n3胡牌：个数加番，10个封顶    抬炮：包两家，20个封顶",
            [2] = "按胡数加番，四舍五入算成个数\n抬炮包两家，胡牌或者抬炮20个封顶",
            [3] = "10胡  1个    11-20胡  2个     21-30胡  4个    31胡以上  8个\n胡牌(8个)：个数加番，8个封顶   抬炮：包两家，16个封顶\n胡牌(16个)：个数加番，16个封顶   抬炮：包两家，32个封顶",
        },
    },
    [EqsPlayType.ErRen14Zhang] = {
        height = 150,
        text = "50胡封顶时，番胡每家50胡封顶\n100胡封顶时，番胡每家100胡封顶\n300胡封顶时，番胡每家300胡封顶",
    },
}

--规则配置
EqsRule.RuleConfig = {
    --局数
    GameTotal2 = { name = "圈2", tips = "圈2", desc = "圈2", type = EqsRuleType.QuanShu, value = 2, cards = 3, cards2 = 5, group = 1 },
    GameTotal3 = { name = "圈3", tips = "圈3", desc = "圈3", type = EqsRuleType.QuanShu, value = 3, cards = 4, cards2 = 7, group = 1 },
    GameTotal5 = { name = "圈5", tips = "圈5", desc = "圈5", type = EqsRuleType.QuanShu, value = 5, cards = 6, cards2 = 10, group = 1 },
    GameTotal10 = { name = "圈10", tips = "圈10", desc = "圈10", type = EqsRuleType.QuanShu, value = 10, cards = 12, cards2 = 20, group = 1 },
    GameTotalInfinite = { name = "无限局", tips = "无限局", desc = "无限局", type = EqsRuleType.QuanShu, value = -1, cards = 0, cards2 = 0, group = 1 },
    --
    QiHuHuShu1 = { name = "一胡起胡", tips = "一胡起胡", type = EqsRuleType.QiHuHuShu, value = 1, group = 2 },
    QiHuHuShu3 = { name = "三胡起胡", tips = "三胡起胡", type = EqsRuleType.QiHuHuShu, value = 3, group = 2 },
    --
    FengDing8 = { name = "8个", tips = "8个", type = EqsRuleType.FengDing, value = 8, group = 3 },
    FengDing16 = { name = "16个", tips = "16个", type = EqsRuleType.FengDing, value = 16, group = 3 },
    FengDing30 = { name = "30个", tips = "30个", type = EqsRuleType.FengDing, value = 30, group = 3 },
    FengDing40 = { name = "40个", tips = "40个", type = EqsRuleType.FengDing, value = 40, group = 3 },
    FengDing50 = { name = "50胡", tips = "50胡", type = EqsRuleType.FengDing, value = 50, group = 3 },
    FengDing100 = { name = "100胡", tips = "100胡", type = EqsRuleType.FengDing, value = 100, group = 3 },
    FengDing300 = { name = "300胡", tips = "300胡", type = EqsRuleType.FengDing, value = 300, group = 3 },
    --
    SuanFaLeShan = { name = "乐山胡数算法", tips = "乐山胡数算法", type = EqsRuleType.HuPaiSuanFa, value = 1, group = 4 },
    SuanFaMeiShan = { name = "眉山胡数算法", tips = "眉山胡数算法", type = EqsRuleType.HuPaiSuanFa, value = 2, group = 4 },
    SuanFaQianWei = { name = "犍为胡数算法", tips = "犍为胡数算法", type = EqsRuleType.HuPaiSuanFa, value = 3, group = 4 },
    --
    --
    TianDi = { name = "天地胡", type = EqsRuleType.TianDiHu, value = 1, group = 0 },
    Kun = { name = "坤", type = EqsRuleType.Kun, value = 1, group = 0 },
    Piao = { name = "漂", type = EqsRuleType.Piao, value = 1, group = 0 },
    QuanHu = { name = "圈胡", type = EqsRuleType.QuanHu, value = 1, group = 0 },
    TianDiKunPiao = { name = "天地坤漂", type = EqsRuleType.TianDiKunPiao, value = 1, group = 0,
                      list = {
                          EqsRuleType.TianDiHu,
                          EqsRuleType.Kun,
                          EqsRuleType.Piao,
                      }
    },
    TianDiKunPiaoQuan = { name = "天地坤漂圈", type = EqsRuleType.TianDiKunPiaoQuan, value = 1, group = 0,
                          list = {
                              EqsRuleType.TianDiHu,
                              EqsRuleType.Kun,
                              EqsRuleType.Piao,
                              EqsRuleType.QuanHu,
                          }
    },
    --
    HuanSanZhang = { name = "换三张", type = EqsRuleType.HuanSanZhang, value = 1, group = 0 },
    DaHu = { name = "大胡", type = EqsRuleType.DaHu, value = 1, group = 0 },
    ShangTai = { name = "上台", type = EqsRuleType.ShangTai, value = 1, group = 0 },
    DaHuShangTai = { name = "大胡上台", type = EqsRuleType.DaHuShangTai, value = 1, group = 0,
                     list = {
                         EqsRuleType.DaHu,
                         EqsRuleType.ShangTai,
                     }
    },
    --
    QingYiSe = { name = "清一色", type = EqsRuleType.QingYiSe, value = 1, group = 0 },
    ShuangQuan = { name = "双圈", type = EqsRuleType.ShuangQuan, value = 1, group = 0 },
    XiaYu = { name = "下雨", type = EqsRuleType.XiaYu, value = 1, group = 0 },
    BaYuJiaHu = { name = "巴雨加胡", type = EqsRuleType.BaYuJiaHu, value = 1, group = 0 },
    GunFan = { name = "磙翻", type = EqsRuleType.GunFan, value = 1, group = 0 },
    DaQuanBaZhiHu = { name = "打圈半自付", type = EqsRuleType.DaBanQuanZiFu, value = 1, group = 0 },
    WuDaXiaoYao = { name = "无大小幺", type = EqsRuleType.WuDaXiaoYao, value = 1, group = 0 },
    --isOnValue为选中才会有值的处理，特殊处理
    TaiPaoBaoYiJia = { name = "抬炮包一家", type = EqsRuleType.DianPaoNum, value = 1, group = 0, isOnValue = true },
    TaiPaoBaoLiangJia = { name = "抬炮包两家", type = EqsRuleType.DianPaoNum, value = 2, group = 0, isOnValue = true },
    --听牌提示
    TingPaiTiShi = { name = "听牌提示", type = EqsRuleType.TingPaiTiShi, value = 1, group = 0 },
    Gps = { name = "强制定位", type = EqsRuleType.Gps, value = 1, group = 0 },

    --客户端特殊处理，分数娱乐场分数
    Score0 = { name = "底分", desc = "自定义", type = EqsRuleType.TeaBaseScore, value = 0, group = 5 },
    Score10 = { name = "底分", desc = "10", type = EqsRuleType.TeaBaseScore, value = 10, group = 5 },
    Score20 = { name = "底分", desc = "20", type = EqsRuleType.TeaBaseScore, value = 20, group = 5 },
    Score30 = { name = "底分", desc = "30", type = EqsRuleType.TeaBaseScore, value = 30, group = 5 },
    Score50 = { name = "底分", desc = "50", type = EqsRuleType.TeaBaseScore, value = 50, group = 5 },
    --准入
    ZhunRu0 = { name = "准入", desc = "自定义", type = EqsRuleType.ZhunRu, value = 0, group = 6 },
    --描述
    Desc = { name = "", type = EqsRuleType.Desc, value = 0, group = 7 },
    --桌费
    ZhuoFei0 = { name = "表情赠送", desc = "自定义", type = EqsRuleType.ZhuoFei, value = 0, group = 8 },
    --桌费
    ZhuoFeiMin0 = { name = "最低赠送", desc = "自定义", type = EqsRuleType.ZhuoFeiMin, value = 0, group = 9 },
    --解散分数
    JieSanFenShu0 = { name = "解散分数", desc = "自定义", type = EqsRuleType.JieSanFenShu, value = 0, group = 10 },
}

--规则特殊配置字典
EqsRule.RuleSpecialConfigDict = {
    [EqsRuleType.TianDiKunPiao] = EqsRule.RuleConfig.TianDiKunPiao,
    [EqsRuleType.TianDiKunPiaoQuan] = EqsRule.RuleConfig.TianDiKunPiaoQuan,
    [EqsRuleType.DaHuShangTai] = EqsRule.RuleConfig.DaHuShangTai,
}

--规则组配置类型，客户端使用
EqsRule.RuleGroupConfigType = {
    --胡数
    HuShu = 1,
    --局数
    GameTotal = 2,
    --封顶
    Limit = 3,
    --加番
    PlayWay = 4,
    --支付
    Pay = 5,
    --底分
    Score = 6,
    --准入
    ZhunRu = 7,
    --支付
    Pay = 8,
    --算法
    SuanFa = 9,
    --起息
    QiXi = 10,
    --桌费
    ZhuoFei = 11,
    --桌费
    ZhuoFeiMin = 12,
    --解散分数
    JieSanFenShu = 13,
}


--规则组配置
EqsRule.RuleGroupConfig = {
    --局数
    GameTotal = {
        name = "局数：",
        sprite = "GameTotal",
        type = EqsRule.RuleGroupConfigType.GameTotal,
    },
    Limit = {
        name = "封顶：",
        sprite = "Limit",
        type = EqsRule.RuleGroupConfigType.Limit,
    },
    PlayWay = {
        name = "加番：",
        sprite = "PlayWay",
        type = EqsRule.RuleGroupConfigType.PlayWay,
    },
    Pay = {
        name = "支付：",
        sprite = "Pay",
        type = EqsRule.RuleGroupConfigType.Pay,
    },
    Score = {
        name = "底分：",
        sprite = "Score",
        type = EqsRule.RuleGroupConfigType.Score,
    },
    ZhunRu = {
        name = "准入：",
        sprite = "ZhuRu",
        type = EqsRule.RuleGroupConfigType.ZhunRu,
    },
    --胡数
    HuShu = {
        name = "胡数：",
        sprite = "",
        type = EqsRule.RuleGroupConfigType.HuShu,
    },
    --算法
    SuanFa = {
        name = "算法：",
        sprite = "",
        type = EqsRule.RuleGroupConfigType.SuanFa,
    },
    QiXi = {
        name = "起息：",
        sprite = "",
        type = EqsRule.RuleGroupConfigType.QiXi,
    },
    ZhuoFei = {
        name = "表情赠送：",
        sprite = "",
        type = EqsRule.RuleGroupConfigType.ZhuoFei,
    },
    ZhuoFeiMin = {
        name = "最低赠送：",
        sprite = "",
        type = EqsRule.RuleGroupConfigType.ZhuoFeiMin,
    },
    JieSanFenShu = {
        name = "解散分数：",
        sprite = "",
        type = EqsRule.RuleGroupConfigType.JieSanFenShu,
    }
}


--胡数配置
EqsRule.RuleGroupConfigHuShu = {
    data = EqsRule.RuleGroupConfig.HuShu,
    rules = {
        { data = EqsRule.RuleConfig.Desc, selected = true, interactable = true },
    }
}

--分数娱乐场创建房间和配置房间的追加配置
EqsRule.RuleGroupConfigScore = {
    data = EqsRule.RuleGroupConfig.Score,
    rules = {
        -- { data = EqsRule.RuleConfig.Score10, selected = true, interactable = true },
        -- { data = EqsRule.RuleConfig.Score20, selected = false, interactable = true },
        -- { data = EqsRule.RuleConfig.Score30, selected = false, interactable = true },
        { data = EqsRule.RuleConfig.Score0, selected = true, interactable = true },
    }
}

--准入配置
EqsRule.RuleGroupConfigZhunRu = {
    data = EqsRule.RuleGroupConfig.ZhunRu,
    rules = {
        { data = EqsRule.RuleConfig.ZhunRu0, selected = true, interactable = true },
    }
}


--桌费
EqsRule.RuleGroupConfigZhuoFei = {
    data = EqsRule.RuleGroupConfig.ZhuoFei,
    rules = {
        { data = EqsRule.RuleConfig.ZhuoFei0, selected = true, interactable = true },
    }
}

--桌费
EqsRule.RuleGroupConfigZhuoFeiMin = {
    data = EqsRule.RuleGroupConfig.ZhuoFeiMin,
    rules = {
        { data = EqsRule.RuleConfig.ZhuoFeiMin0, selected = true, interactable = true },
    }
}

--解散分数配置
EqsRule.RuleGroupConfigJieSanFenShu = {
    data = EqsRule.RuleGroupConfig.JieSanFenShu,
    rules = {
        { data = EqsRule.RuleConfig.JieSanFenShu0, selected = true, interactable = true },
    }
}

--玩法配置
EqsRule.PlayWayConfig = {
    {
        name = "乐山贰柒拾",
        playWayType = EqsPlayType.LeShan,
        playerTotal = 3,
        isGuild = true,
        ruleGroups = {
            {
                data = EqsRule.RuleGroupConfig.GameTotal,
                rules = {
                    { data = EqsRule.RuleConfig.GameTotal2, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal3, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal5, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal10, selected = false, interactable = true },
                    --{ data = EqsRule.RuleConfig.GameTotalInfinite, selected = false, interactable = true }
                }
            },
            {
                data = EqsRule.RuleGroupConfig.PlayWay,
                rules = {
                    { data = EqsRule.RuleConfig.TianDiKunPiao, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.QuanHu, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.HuanSanZhang, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.ShuangQuan, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.XiaYu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.BaYuJiaHu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.QingYiSe, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.Gps, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.TingPaiTiShi, selected = false, interactable = true },
                }
            },
            EqsRule.RuleGroupConfigHuShu
            --, EqsRule.RuleGroupConfigScore
            -- , EqsRule.RuleGroupConfigZhunRu, EqsRule.RuleGroupConfigJieSanFenShu,
            -- EqsRule.RuleGroupConfigZhuoFei, EqsRule.RuleGroupConfigZhuoFeiMin
        }
    },
    {
        name = "犍为贰柒拾",
        playWayType = EqsPlayType.JianWei,
        playerTotal = 3,
        isGuild = true,
        ruleGroups = {
            {
                data = EqsRule.RuleGroupConfig.GameTotal,
                rules = {
                    { data = EqsRule.RuleConfig.GameTotal2, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal3, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal5, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal10, selected = false, interactable = true },
                    --{ data = EqsRule.RuleConfig.GameTotalInfinite, selected = false, interactable = true }
                }
            },
            {
                data = EqsRule.RuleGroupConfig.Limit,
                rules = {
                    { data = EqsRule.RuleConfig.FengDing8, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.FengDing16, selected = false, interactable = true },
                }
            },
            {
                data = EqsRule.RuleGroupConfig.PlayWay,
                rules = {
                    { data = EqsRule.RuleConfig.TianDiKunPiao, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.QuanHu, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.HuanSanZhang, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.ShuangQuan, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GunFan, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.DaQuanBaZhiHu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.QingYiSe, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.Gps, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.TingPaiTiShi, selected = false, interactable = true },
                }
            },
            EqsRule.RuleGroupConfigHuShu
            --, EqsRule.RuleGroupConfigScore
            -- , EqsRule.RuleGroupConfigZhunRu, EqsRule.RuleGroupConfigJieSanFenShu,
            -- EqsRule.RuleGroupConfigZhuoFei, EqsRule.RuleGroupConfigZhuoFeiMin
        }
    },
    {
        name = "眉山贰柒拾",
        playWayType = EqsPlayType.MeiShan,
        playerTotal = 3,
        isGuild = true,
        ruleGroups = {
            {
                data = EqsRule.RuleGroupConfig.GameTotal,
                rules = {
                    { data = EqsRule.RuleConfig.GameTotal2, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal3, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal5, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal10, selected = false, interactable = true },
                    --{ data = EqsRule.RuleConfig.GameTotalInfinite, selected = false, interactable = true }
                }
            },
            {
                data = EqsRule.RuleGroupConfig.Limit,
                rules = {
                    { data = EqsRule.RuleConfig.FengDing30, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.FengDing40, selected = false, interactable = true },
                }
            },
            {
                data = EqsRule.RuleGroupConfig.PlayWay,
                rules = {
                    { data = EqsRule.RuleConfig.TianDiKunPiao, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.DaHu, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.ShangTai, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.QuanHu, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.QingYiSe, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.ShuangQuan, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.XiaYu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.BaYuJiaHu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.HuanSanZhang, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.Gps, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.TingPaiTiShi, selected = false, interactable = true },
                }
            },
            EqsRule.RuleGroupConfigHuShu
            --, EqsRule.RuleGroupConfigScore
            -- , EqsRule.RuleGroupConfigZhunRu, EqsRule.RuleGroupConfigJieSanFenShu,
            -- EqsRule.RuleGroupConfigZhuoFei, EqsRule.RuleGroupConfigZhuoFeiMin
        }
    },
    {
        name = "十四张两人",
        playWayType = EqsPlayType.ErRen14Zhang,
        playerTotal = 2,
        isGuild = true,
        ruleGroups = {
            {
                data = EqsRule.RuleGroupConfig.GameTotal,
                rules = {
                    { data = EqsRule.RuleConfig.GameTotal2, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal3, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal5, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal10, selected = false, interactable = true },
                    --{ data = EqsRule.RuleConfig.GameTotalInfinite, selected = false, interactable = true }
                }
            },
            {
                data = EqsRule.RuleGroupConfig.QiXi,
                rules = {
                    { data = EqsRule.RuleConfig.QiHuHuShu1, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.QiHuHuShu3, selected = false, interactable = true },
                }
            },
            {
                data = EqsRule.RuleGroupConfig.Limit,
                rules = {
                    { data = EqsRule.RuleConfig.FengDing50, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.FengDing100, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.FengDing300, selected = false, interactable = true },
                }
            },
            {
                data = EqsRule.RuleGroupConfig.PlayWay,
                rules = {
                    { data = EqsRule.RuleConfig.TianDiKunPiaoQuan, selected = true, interactable = false },
                    { data = EqsRule.RuleConfig.DaHuShangTai, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.QingYiSe, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.ShuangQuan, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.XiaYu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.BaYuJiaHu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GunFan, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.DaQuanBaZhiHu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.Gps, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.TingPaiTiShi, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.TaiPaoBaoYiJia, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.TaiPaoBaoLiangJia, selected = false, interactable = true },
                }
            },
            EqsRule.RuleGroupConfigHuShu
            --, EqsRule.RuleGroupConfigScore
            -- , EqsRule.RuleGroupConfigZhunRu, EqsRule.RuleGroupConfigJieSanFenShu,
            -- EqsRule.RuleGroupConfigZhuoFei, EqsRule.RuleGroupConfigZhuoFeiMin
        }
    },
    {
        name = "十四张三人",
        playWayType = EqsPlayType.SanRen14Zhang,
        playerTotal = 3,
        isGuild = true,
        ruleGroups = {
            {
                data = EqsRule.RuleGroupConfig.GameTotal,
                rules = {
                    { data = EqsRule.RuleConfig.GameTotal2, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal3, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal5, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal10, selected = false, interactable = true },
                    --{ data = EqsRule.RuleConfig.GameTotalInfinite, selected = false, interactable = true }
                }
            },
            {
                data = EqsRule.RuleGroupConfig.QiXi,
                rules = {
                    { data = EqsRule.RuleConfig.QiHuHuShu1, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.QiHuHuShu3, selected = false, interactable = true },
                }
            },
            {
                data = EqsRule.RuleGroupConfig.Limit,
                rules = {
                    { data = EqsRule.RuleConfig.FengDing50, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.FengDing100, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.FengDing300, selected = false, interactable = true },
                }
            },
            {
                data = EqsRule.RuleGroupConfig.PlayWay,
                rules = {
                    { data = EqsRule.RuleConfig.TianDiKunPiaoQuan, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.DaHuShangTai, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.QingYiSe, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.ShuangQuan, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.XiaYu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.BaYuJiaHu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GunFan, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.DaQuanBaZhiHu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.Gps, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.TingPaiTiShi, selected = false, interactable = true },
                }
            },
            EqsRule.RuleGroupConfigHuShu
            --, EqsRule.RuleGroupConfigScore
            -- , EqsRule.RuleGroupConfigZhunRu, EqsRule.RuleGroupConfigJieSanFenShu,
            -- EqsRule.RuleGroupConfigZhuoFei, EqsRule.RuleGroupConfigZhuoFeiMin
        }
    },
    {
        name = "十四张四人",
        playWayType = EqsPlayType.SiRen14Zhang,
        playerTotal = 4,
        isGuild = true,
        ruleGroups = {
            {
                data = EqsRule.RuleGroupConfig.GameTotal,
                rules = {
                    { data = EqsRule.RuleConfig.GameTotal2, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal3, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal5, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal10, selected = false, interactable = true },
                    --{ data = EqsRule.RuleConfig.GameTotalInfinite, selected = false, interactable = true }
                }
            },
            {
                data = EqsRule.RuleGroupConfig.Limit,
                rules = {
                    { data = EqsRule.RuleConfig.FengDing100, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.FengDing300, selected = false, interactable = true },
                }
            },
            {
                data = EqsRule.RuleGroupConfig.PlayWay,
                rules = {
                    { data = EqsRule.RuleConfig.QuanHu, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.TianDi, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.Kun, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.Piao, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.DaHu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.ShangTai, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.QingYiSe, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.ShuangQuan, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.TingPaiTiShi, selected = false, interactable = true },
                }
            },
            EqsRule.RuleGroupConfigHuShu
            --, EqsRule.RuleGroupConfigScore
            -- , EqsRule.RuleGroupConfigZhunRu, EqsRule.RuleGroupConfigJieSanFenShu,
            -- EqsRule.RuleGroupConfigZhuoFei, EqsRule.RuleGroupConfigZhuoFeiMin
        }
    },
    {
        name = "两人贰柒拾",
        playWayType = EqsPlayType.ErRen,
        playerTotal = 2,
        isGuild = true,
        ruleGroups = {
            {
                data = EqsRule.RuleGroupConfig.GameTotal,
                rules = {
                    { data = EqsRule.RuleConfig.GameTotal2, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal3, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal5, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GameTotal10, selected = false, interactable = true },
                    --{ data = EqsRule.RuleConfig.GameTotalInfinite, selected = false, interactable = true }
                }
            },
            {
                data = EqsRule.RuleGroupConfig.SuanFa,
                rules = {
                    { data = EqsRule.RuleConfig.SuanFaLeShan, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.SuanFaMeiShan, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.SuanFaQianWei, selected = false, interactable = true },
                }
            },
            {
                data = EqsRule.RuleGroupConfig.Limit,
                rules = {
                    { data = EqsRule.RuleConfig.FengDing8, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.FengDing16, selected = false, interactable = true },
                }
            },
            {
                data = EqsRule.RuleGroupConfig.PlayWay,
                rules = {
                    { data = EqsRule.RuleConfig.TianDiKunPiaoQuan, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.DaHuShangTai, selected = true, interactable = true },
                    { data = EqsRule.RuleConfig.ShuangQuan, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.QingYiSe, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.XiaYu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.BaYuJiaHu, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.GunFan, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.WuDaXiaoYao, selected = false, interactable = true },
                    { data = EqsRule.RuleConfig.TingPaiTiShi, selected = false, interactable = true },
                }
            },
            EqsRule.RuleGroupConfigHuShu
            --, EqsRule.RuleGroupConfigScore
            -- , EqsRule.RuleGroupConfigZhunRu, EqsRule.RuleGroupConfigJieSanFenShu,
            -- EqsRule.RuleGroupConfigZhuoFei, EqsRule.RuleGroupConfigZhuoFeiMin
        }
    },
}

--创建房间配置
EqsRule.CreateRoomConfig = {
    EqsRule.PlayWayConfig[1],
    EqsRule.PlayWayConfig[2],
    EqsRule.PlayWayConfig[3],
    EqsRule.PlayWayConfig[4],
    EqsRule.PlayWayConfig[5],
    EqsRule.PlayWayConfig[6],
    EqsRule.PlayWayConfig[7],
}

--规则排序配置，规则解析根据该排序显示
EqsRule.RuleSortConfig = {
    --EqsRuleType.QuanShu,
    --
    EqsRuleType.TianDiKunPiao,
    EqsRuleType.TianDiKunPiaoQuan,
    EqsRuleType.DaHuShangTai,
    --
    EqsRuleType.TianDiHu,
    EqsRuleType.Kun,
    EqsRuleType.Piao,
    EqsRuleType.QuanHu,
    EqsRuleType.XiaYu,
    EqsRuleType.BaYuJiaHu,
    EqsRuleType.QingYiSe,
    EqsRuleType.GunFan,
    EqsRuleType.DaBanQuanZiFu,
    EqsRuleType.DaHu,
    EqsRuleType.ShangTai,
    EqsRuleType.ShuangQuan,
    EqsRuleType.XiaoJiaZiMoJiaFan,
    EqsRuleType.HuPaiSuanFa,
    EqsRuleType.WuDaXiaoYao,
    EqsRuleType.HuanSanZhang,
    EqsRuleType.QiHuHuShu,
    EqsRuleType.DianPaoNum,
    --
    EqsRuleType.Gps,
    -- EqsRuleType.ZhuoFei,
    -- EqsRuleType.ZhuoFeiMin,
    -- EqsRuleType.ZhunRu,
    -- EqsRuleType.JieSanFenShu,
    EqsRuleType.PayType,
}


--房卡消耗ID
EqsRoomCardConsumeConfig = {}       --key:人数 * 100+圈数
EqsRoomCardConsumeConfig["302"] = 70001
EqsRoomCardConsumeConfig["303"] = 70002
EqsRoomCardConsumeConfig["305"] = 70003
EqsRoomCardConsumeConfig["310"] = 70004

EqsRoomCardConsumeConfig["202"] = 70005
EqsRoomCardConsumeConfig["203"] = 70006
EqsRoomCardConsumeConfig["205"] = 70007
EqsRoomCardConsumeConfig["210"] = 70008

EqsRoomCardConsumeConfig["402"] = 70009
EqsRoomCardConsumeConfig["403"] = 70010
EqsRoomCardConsumeConfig["405"] = 70011
EqsRoomCardConsumeConfig["410"] = 70012

--配置数据
EqsConfig = {}
--当前的玩法配置
EqsConfig.playWayConfig = nil
--规则配置字典
EqsConfig.ruleConfigDict = {}

--底分配置
EqsConfig.DiFenConfig = {0.1, 0.2, 0.5, 1, 2, 3, 4, 5, 6, 10, 20 }
--底分配置，用于Dropdown列表
EqsConfig.DiFenNameConfig = {"0.1", "0.2分", "0.5分", "1分", "2分", "3分", "4分", "5分", "6分", "10分", "20分" }

local this = EqsConfig
function EqsConfig.GetConsumeConfigId(userNum, quanShu)
    local id = EqsRoomCardConsumeConfig[tostring(userNum * 100 + quanShu)]
    if id ~= nil then
        return id
    end
    return 0
end

--检测规则
function EqsConfig.CheckRules(rules)
    local playWayType = rules[EqsRuleType.RType]
    local userNum = rules[EqsRuleType.RoomNum]
    --14张2人特殊处理
    if playWayType == EqsPlayType.SanRen14Zhang and userNum == 2 then
        playWayType = EqsPlayType.ErRen14Zhang
        rules[EqsRuleType.RType] = playWayType
    end
end

--获取玩法的规则映射配置
function EqsConfig.GetPlayWayConfig(playWayType)
    local result = nil
    local temp = nil
    for i = 1, #EqsRule.PlayWayConfig do
        temp = EqsRule.PlayWayConfig[i]
        if temp.playWayType == playWayType then
            result = temp
            break
        end
    end
    return result
end

--设置玩法配置，用于规则解析
function EqsConfig.SetPlayWayConfig(playWayConfig)
    if this.playWayConfig ~= playWayConfig then
        this.playWayConfig = playWayConfig
        EqsConfig.ruleConfigDict = {}

        if this.playWayConfig ~= nil then
            local ruleGroups = this.playWayConfig.ruleGroups
            local rules = nil
            local tempDict = nil
            local data = nil
            for i = 1, #ruleGroups do
                rules = ruleGroups[i].rules
                for j = 1, #rules do
                    data = rules[j].data
                    tempDict = EqsConfig.ruleConfigDict[data.type]
                    if tempDict == nil then
                        tempDict = {}
                        EqsConfig.ruleConfigDict[data.type] = tempDict
                    end
                    --存储的是规则配置，不是下面的属性data
                    tempDict[data.value] = rules[j]
                end
            end
        end
    end
end

--获取当前的规则配置数据
function EqsConfig.GetCurrRuleConfigData(ruleType, ruleValue)
    if ruleType == nil or ruleValue == nil then
        return nil
    end

    local dict = this.ruleConfigDict[ruleType]
    if dict ~= nil then
        return dict[ruleValue]
    end

    return nil
end


--解析规则
function EqsConfig.ParseEqsRule(ruleObj, gps, separator, bdPer)
    if string.IsNullOrEmpty(separator) then
        separator = ' '
    end
    ruleObj[EqsRuleType.Gps] = gps
    --Log("解析贰柒拾规则：", ruleObj, gps, separator)
    local rules = ruleObj
    --返回数据
    local parsedRule = { playWayType = 0, playWayName = "", juShu = 0, juShuTxt = "圈0", rule = "", cards = 0, baseScore = 0, userNum = 0 }
    --
    if IsTable(ruleObj) then
        local playWayType = ruleObj[EqsRuleType.RType]
        local userNum = ruleObj[EqsRuleType.RoomNum]
        --14张2人特殊处理
        if playWayType == EqsPlayType.SanRen14Zhang and userNum == 2 then
            playWayType = EqsPlayType.ErRen14Zhang
            ruleObj[EqsRuleType.RType] = playWayType
        end

        local playWayConfig = EqsConfig.GetPlayWayConfig(playWayType)
        if playWayConfig ~= nil then
            EqsConfig.SetPlayWayConfig(playWayConfig)

            --玩法名称
            parsedRule.playWayName = playWayConfig.name
            --临时变量定义
            local ruleType = nil
            local ruleValue = nil
            local ruleConfigData = nil
            --解析局数
            ruleType = EqsRuleType.QuanShu
            ruleValue = ruleObj[ruleType]
            ruleConfigData = EqsConfig.GetCurrRuleConfigData(ruleType, ruleValue)
            if ruleConfigData ~= nil then
                parsedRule.juShu = ruleConfigData.data.value
                parsedRule.juShuTxt = ruleConfigData.data.name
                parsedRule.cards = ruleConfigData.data.cards
            end
            --处理底分
            ruleValue = ruleObj[EqsRuleType.TeaBaseScore]
            if ruleValue ~= nil then
                parsedRule.baseScore = ruleValue
            end
            --处理玩家数量
            ruleValue = ruleObj[EqsRuleType.RoomNum]
            if ruleValue ~= nil then
                parsedRule.userNum = ruleValue
            end
            --其他规则
            local length = #EqsRule.RuleSortConfig
            local rule = ""
            local isFirst = true
            --显示处理不显示的规则，即自定义的规则下的list
            local filterDict = {}
            EqsConfig.HandleHiddenRule(filterDict, EqsRuleType.TianDiKunPiao, ruleObj[EqsRuleType.TianDiKunPiao])
            EqsConfig.HandleHiddenRule(filterDict, EqsRuleType.TianDiKunPiaoQuan, ruleObj[EqsRuleType.TianDiKunPiaoQuan])
            EqsConfig.HandleHiddenRule(filterDict, EqsRuleType.DaHuShangTai, ruleObj[EqsRuleType.DaHuShangTai])
            for i = 1, length do
                ruleType = EqsRule.RuleSortConfig[i]
                --过滤掉不显示的规则
                if filterDict[ruleType] == nil then
                    ruleValue = ruleObj[ruleType]
                    ruleConfigData = EqsConfig.GetCurrRuleConfigData(ruleType, ruleValue)
                    if ruleConfigData ~= nil then
                        if not isFirst then
                            rule = rule .. separator
                        end
                        isFirst = false
                        rule = rule .. ruleConfigData.data.name
                    end
                end
            end

            local temp = 0
            --处理自定义的字段
            temp = ruleObj[EqsRuleType.ZhunRu]
            if temp ~= nil then
                rule = rule .. separator .. EqsRule.RuleConfig.ZhunRu0.name .. "(" .. temp .. ")"
            end
            temp = ruleObj[EqsRuleType.JieSanFenShu]
            if temp ~= nil then
                rule = rule .. separator .. EqsRule.RuleConfig.JieSanFenShu0.name .. "(" .. temp .. ")"
            end
            -- temp = ruleObj[EqsRuleType.ZhuoFei]
            -- if temp ~= nil then
            --     rule = rule .. separator .. EqsRule.RuleConfig.ZhuoFei0.name .. "(" .. temp .. ")"
            -- end
            -- temp = ruleObj[EqsRuleType.ZhuoFeiMin]
            -- if temp ~= nil then
            --     rule = rule .. separator .. EqsRule.RuleConfig.ZhuoFeiMin0.name .. "(" .. temp .. ")"
            -- end
            if UnionData.IsUnionLeader() then
                temp = ruleObj[EqsRuleType.KeepBaseNum]
                local symbol = bdPer == 0 and "分" or "%"
                if temp ~= nil then
                    rule = rule .. separator .. "保底" .. temp .. symbol
                end
            end

            parsedRule.rule = rule
            parsedRule.playWayType = playWayType
        end
    end
    return parsedRule
end

--处理隐藏规则，即自定下的规则不显示子规则
function EqsConfig.HandleHiddenRule(dict, ruleType, ruleValue)
    local ruleConfigData = EqsConfig.GetCurrRuleConfigData(ruleType, ruleValue)
    if ruleConfigData ~= nil and ruleConfigData.data ~= nil then
        local list = ruleConfigData.data.list
        if list ~= nil then
            for i = 1, #list do
                dict[list[i]] = 1
            end
        end
    end
end


--加番规则
EqsConfig.JiaFanToggleNames = {
    --乐山
    TianDiKunPiaoToggle = { EqsRuleType.TianDiHu, EqsRuleType.Kun, EqsRuleType.Piao },
    QuanHuToggle = { EqsRuleType.QuanHu },
    HuanSanZhangToggle = { EqsRuleType.HuanSanZhang },
    ShuangQuanToggle = { EqsRuleType.ShuangQuan },
    XiaYuToggle = { EqsRuleType.XiaYu },
    BaYuJiaHuToggle = { EqsRuleType.BaYuJiaHu },
    QingYiSeToggle = { EqsRuleType.QingYiSe },
    QiangZhiDingWeiToggle = { EqsRuleType.Gps },
    --犍为
    GunFanToggle = { EqsRuleType.GunFan },
    DaBanQuanZiFuToggle = { EqsRuleType.DaBanQuanZiFu },
    --眉山
    DaHuToggle = { EqsRuleType.DaHu },
    ShangTaiToggle = { EqsRuleType.ShangTai },
    --三人十四张
    TianDiKunPiaoQuanToggle = { EqsRuleType.TianDiHu, EqsRuleType.Kun, EqsRuleType.Piao, EqsRuleType.QuanHu },
    DaHuShangTaiToggle = { EqsRuleType.DaHu, EqsRuleType.ShangTai },
    --四人十四张
    TianDiHuToggle = { EqsRuleType.TianDiHu },
    KunToggle = { EqsRuleType.Kun },
    PiaoToggle = { EqsRuleType.Piao },
    --二人
    WuDaXiaoYaoToggle = { EqsRuleType.WuDaXiaoYao },
    --听牌提示
    TingPaiToggle = { EqsRuleType.TingPaiTiShi },
}

function EqsConfig.IsToggleMatchRule(toggleName, rules)
    local matchRules = this.JiaFanToggleNames[toggleName]
    if IsTable(matchRules) then
        local isMatch = true
        for _, rule in pairs(matchRules) do
            if rules[rule] ~= 1 then
                return false
            end
        end
    end
    return true
end