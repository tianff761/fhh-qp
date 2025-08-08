PdkConfig = {}

local this = PdkConfig

--跑得快玩法类型
PdkGameType = {
    --四川跑得快
    SC = 1,
    --乐山跑得快
    LS = 2,
}

--跑得快玩法类型
PdkPlayType = {
    --四川二人
    SCErRen = 12,
    --四川三人
    SCSanRen = 13,
    --四川四人
    SCSiRen = 14,
    --乐山三人
    LSSanRen = 23,
    --乐山四人
    LSSiRen = 24,
    ---15张跑得快
    FifteenPDK = 35,
    ---16张跑得快
    SixteenPDK = 36,
}

PdkRuleType = {
    --玩法
    PlayType = "WF",
    --局数
    JuShu = "JS",
    --玩家数量
    PlayerTotal = "NPT",
    --支付方式
    PayType = "PT",
    --出牌规则
    OutRule = "CPGZ",
    --首出必带黑桃3
    FirstOut = "BCHS",
    --能出必出
    YCBC = "YCBC",
    --可四带二
    SDE = "SDE",
    --剩一张不输分
    BSF = "BSF",
    --可四带三
    SDS = "SDS",
    --报单必须出最大
    BDZD = "BDZD",
    --最后一首可三带一
    ZHSD = "ZHSD",
    --分数准入
    ZhunRu = "ZR",
    --底分
    DiFen = "DF",
    --炸弹规则
    ZDGZ = "ZDGZ",
    --炸弹分数
    ZDFS = "ZDFS",
    --是否有飞机
    FJ = "FJ",
    --姐妹对
    PX = "PX",
    --名堂
    MT = "MT",
    --名堂分数
    MTFS = "MTFS",
    --红桃10扎鸟
    HSZN = "HSZN",
    --首轮盖牌
    SLGP = "SLGP",
    --乐山先出规则
    LS_XC = "LS_XC",
    --乐山余牌显示
    LS_YP = "LS_YP",
    --乐山炸弹可拆
    LS_WF = "LS_WF",
    --桌费
    ZhuoFei = "ZF",
    --桌费最小值
    ZhuoFeiMin = "MZF",
    --房间类型
    RoomType = "CRT",
    --解散分数
    JieSanFenShu = "JSFS",

    ------以下为新添加

    ST_RS = "ST_RS", --16张排的快人数
    ST_LD = "ST_LD", --0表示连队的数量
    ST_XC = "ST_XC", --出牌 1.黑3 2.赢家 3.轮庄
    ST_42 = "ST_42", --可四代2
    ST_43 = "ST_43", --可四代3
    ST_YBS = "ST_YBS", --一张不输
    ST_3A = "ST_3A", --3个A炸弹
    ST_LFJ = "ST_LFJ", --最后飞机可少带
    ST_LS = "ST_LS", -- 最后可三不带
    ST_FC = "ST_FC", -- 反春
    ST_SC3 = "ST_SC3", -- 首出必出黑桃三
    ST_WF = "ST_WF", -- 0表示16张1表示15张

    --ST_BD = 0,  -- 报单出最大
    --ST_YD = 0,  -- 有大必大

    ---保底
    KeepBaseNum = "keepBaseNum",
}

--房卡配置
PdkRoomCardConfig = {
    FourBj = 30001,
    FourSLj = 30002,
    ThreeBj = 30003,
    ThreeSLj = 30004,
}


--玩法规则配置，如果是复选框，选中则使用Value值，否则使用0，单选框则使用相应的Value值
PdkConfig.RuleConfig = {
    --局数
    GameTotalEight = { name = "8局", tips = "8局", type = PdkRuleType.JuShu, value = 8, cards = 4, cards2 = 3, group = 1 },
    GameTotalTen = { name = "10局", tips = "10局", type = PdkRuleType.JuShu, value = 10, cards = 4, cards2 = 3, group = 1 },
    GameTotalTwenty = { name = "20局", tips = "20局", type = PdkRuleType.JuShu, value = 20, cards = 8, cards2 = 6, group = 1 },

    --支付方式
    PayOwner = { name = "房主付", type = PdkRuleType.PayType, value = 1, group = 2 },
    PayWinner = { name = "大赢家付", type = PdkRuleType.PayType, value = 4, group = 2 },

    --出牌规则
    OutRule1 = { name = "每局黑桃5先出", type = PdkRuleType.OutRule, value = 1, group = 3 },
    OutRule2 = { name = "第二局赢家先出", type = PdkRuleType.OutRule, value = 2, group = 3 },

    --16张出牌规则
    OutRule3 = { name = "黑桃3先出", type = PdkRuleType.OutRule, value = 1, group = 3 },
    OutRule4 = { name = "赢家先出", type = PdkRuleType.OutRule, value = 2, group = 3 },
    OutRule5 = { name = "轮庄", type = PdkRuleType.OutRule, value = 3, group = 3 },

    --余牌数显示
    YuPai1 = { name = "不显示", type = PdkRuleType.LS_YP, value = 0, group = 4 },
    YuPai2 = { name = "显示", type = PdkRuleType.LS_YP, value = 1, group = 4 },

    --玩法
    WanFa1 = { name = "炸弹不可拆", type = PdkRuleType.LS_WF, value = 0, group = 5 },
    WanFa2 = { name = "炸弹可拆", type = PdkRuleType.LS_WF, value = 1, group = 5 },

    ---人数
    PeopleCount1 = { name = "2人", type = PdkRuleType.ST_RS, value = 2, group = 5 },
    PeopleCount2 = { name = "3人", type = PdkRuleType.ST_RS, value = 3, group = 5 },

    --炸弹
    ZhaDan11 = { name = "3张算炸弹", type = PdkRuleType.ZDGZ, value = 1, group = 6 },
    ZhaDan12 = { name = "不带炸弹", type = PdkRuleType.ZDGZ, value = 2, group = 6 },
    ZhaDan13 = { name = "炸弹可拆", type = PdkRuleType.ZDGZ, value = 3, group = 6 },
    --炸弹2
    ZhaDan21 = { name = "3张4张算炸弹", type = PdkRuleType.ZDGZ, value = 1, group = 6 },
    ZhaDan22 = { name = "只有4张算炸弹", type = PdkRuleType.ZDGZ, value = 2, group = 6 },
    ZhaDan23 = { name = "不带炸弹", type = PdkRuleType.ZDGZ, value = 3, group = 6 },

    --炸弹分数
    ZhaDanFenShu11 = { name = "3炸5分", type = PdkRuleType.ZDFS, value = 1, group = 8 },
    ZhaDanFenShu12 = { name = "3炸10分", type = PdkRuleType.ZDFS, value = 2, group = 8 },
    ZhaDanFenShu13 = { name = "3张算炸弹", type = PdkRuleType.ZDFS, value = 3, group = 28 },
    ZhaDanFenShu14 = { name = "不带炸弹", type = PdkRuleType.ZDFS, value = 4, group = 28 },

    --炸弹分数2
    ZhaDanFenShu21 = { name = "3炸5分4炸10分", type = PdkRuleType.ZDFS, value = 1, group = 8 },
    ZhaDanFenShu22 = { name = "3炸10分4炸20分", type = PdkRuleType.ZDFS, value = 2, group = 8 },
    ZhaDanFenShu23 = { name = "4炸10分", type = PdkRuleType.ZDFS, value = 3, group = 28 },
    ZhaDanFenShu24 = { name = "4炸20分", type = PdkRuleType.ZDFS, value = 4, group = 28 },

    --炸弹分数3
    ZhaDanFenShu31 = { name = "炸弹5倍底分", type = PdkRuleType.ZDFS, value = 1, group = 28 },
    ZhaDanFenShu32 = { name = "炸弹10倍底分", type = PdkRuleType.ZDFS, value = 2, group = 28 },
    ZhaDanFenShu33 = { name = "炸弹20倍底分", type = PdkRuleType.ZDFS, value = 3, group = 28 },
    ZhaDanFenShu34 = { name = "炸弹不算分", type = PdkRuleType.ZDFS, value = 4, group = 28 },

    --飞机
    FeiJi1 = { name = "飞机不可出", type = PdkRuleType.FJ, value = 1, group = 9 },
    FeiJi2 = { name = "飞机可出", type = PdkRuleType.FJ, value = 2, group = 9 },

    ShouLunGaiPai = { name = "首轮盖牌", type = PdkRuleType.SLGP, value = 1, group = 0 },
    JieMeiDui = { name = "姐妹对", type = PdkRuleType.PX, value = 1, group = 0 },
    --名堂，在规则中使用数组形式存放
    QuanHei = { name = "全黑", type = PdkRuleType.MT, value = 1, group = 0 },
    QuanHong = { name = "全红", type = PdkRuleType.MT, value = 2, group = 0 },
    QuanDa = { name = "全大", type = PdkRuleType.MT, value = 3, group = 0 },
    QuanXiao = { name = "全小", type = PdkRuleType.MT, value = 4, group = 0 },
    QuanDan = { name = "全单", type = PdkRuleType.MT, value = 5, group = 0 },
    QuanShuang = { name = "全双", type = PdkRuleType.MT, value = 6, group = 0 },
    SiGe5 = { name = "5555(10分)", type = PdkRuleType.MT, value = 7, group = 0 },
    SiGeA = { name = "AAAA(10分)", type = PdkRuleType.MT, value = 8, group = 0 },
    SiGe6k = { name = "4个6-4个K(5分)", type = PdkRuleType.MT, value = 9, group = 0 },
    --名堂分数
    MingTangFen10 = { name = "【全黑、全红、全大、全小、全单、全双】10分", type = PdkRuleType.MTFS, value = 1, group = 15 },
    MingTangFen20 = { name = "【全黑、全红、全大、全小、全单、全双】20分", type = PdkRuleType.MTFS, value = 2, group = 15 },
    --
    HongTao10ZaNiao = { name = "红桃10扎鸟", type = PdkRuleType.HSZN, value = 1, group = 0 },
    --底分
    Score0 = { name = "底分", desc = "自定义", type = PdkRuleType.DiFen, value = 0, group = 11 },
    --
    --准入
    ZhunRu0 = { name = "准入", desc = "自定义", type = PdkRuleType.ZhunRu, value = 0, group = 12 },
    --桌费
    ZhuoFei0 = { name = "表情赠送", desc = "自定义", type = PdkRuleType.ZhuoFei, value = 0, group = 13 },
    --桌费最小
    ZhuoFeiMin0 = { name = "最低赠送", desc = "自定义", type = PdkRuleType.ZhuoFeiMin, value = 0, group = 14 },
    --解散分数
    JieSanFenShu0 = { name = "解散分数", desc = "自定义", type = PdkRuleType.JieSanFenShu, value = 0, group = 15 },
}


--规则组配置类型，客户端使用
PdkConfig.RuleGroupConfigType = {
    --局数
    GameTotal = 10,
    --支付
    Pay = 20,
    --底分
    Score = 30,
    --准入
    ZhunRu = 40,
    --桌费
    ZhuoFei = 50,
    --桌费最小值
    ZhuoFeiMin = 60,
    ---人数
    PeopleCount = 65,
    --先出
    XianChu = 70,
    --炸弹
    ZhaDan = 80,
    --炸弹
    ZhaDanFen1 = 90,
    --炸弹
    ZhaDanFen2 = 100,
    --飞机
    FeiJi = 110,
    --牌型
    PaiXing = 120,
    --名堂
    MingTang = 130,
    --名堂分数
    MingTangFen = 140,
    --玩法
    PlayWay = 150,
    --防作弊
    FangZuoBi = 160,
    --牌数
    PaiShu = 170,
    --解散
    JieSanFenShu = 180,
}

---特殊玩法
PdkConfig.SpecialPlayWay = {
    { name = "最后飞机可少带", key = "ST_LFJ", isOn = true },
    { name = "可四带二", key = "ST_42", isOn = false },
    { name = "可四带三", key = "ST_43", isOn = true },
    { name = "一张不输分", key = "ST_YBS", isOn = true },
    { name = "三个A炸弹", key = "ST_3A", isOn = true },
    { name = "最后三张可少带", key = "ST_LS", isOn = true },
    { name = "反春", key = "ST_FC", isOn = true },
    { name = "首出必带黑桃3", key = "ST_SC3", isOn = false },
}

---高级选项
PdkConfig.SeniorOption = {
    "首轮盖牌"
}

--规则组配置
PdkConfig.RuleGroupConfig = {
    --局数
    GameTotal = {
        name = "局数：",
        type = PdkConfig.RuleGroupConfigType.GameTotal,
    },
    Pay = {
        name = "支付：",
        type = PdkConfig.RuleGroupConfigType.Pay,
    },
    Score = {
        name = "底分：",
        type = PdkConfig.RuleGroupConfigType.Score,
    },
    ZhunRu = {
        name = "准入：",
        type = PdkConfig.RuleGroupConfigType.ZhunRu,
    },
    ZhuoFei = {
        name = "表情赠送：",
        type = PdkConfig.RuleGroupConfigType.ZhuoFei,
    },
    ZhuoFeiMin = {
        name = "最低赠送：",
        type = PdkConfig.RuleGroupConfigType.ZhuoFeiMin,
    },
    XianChu = {
        name = "先出：",
        type = PdkConfig.RuleGroupConfigType.XianChu,
    },
    ZhaDan = {
        name = "炸弹：",
        type = PdkConfig.RuleGroupConfigType.ZhaDan,
    },
    ZhaDanFen1 = {
        name = "炸弹分数：",
        type = PdkConfig.RuleGroupConfigType.ZhaDanFen1,
    },
    ZhaDanFen2 = {
        name = "炸弹分数：",
        type = PdkConfig.RuleGroupConfigType.ZhaDanFen2,
    },
    FeiJi = {
        name = "飞机：",
        type = PdkConfig.RuleGroupConfigType.FeiJi,
    },
    PaiXing = {
        name = "牌型：",
        type = PdkConfig.RuleGroupConfigType.PaiXing,
    },
    MingTang = {
        name = "名堂：",
        type = PdkConfig.RuleGroupConfigType.MingTang,
    },
    MingTangFen = {
        name = "名堂分数：",
        type = PdkConfig.RuleGroupConfigType.MingTangFen,
    },
    PlayWay = {
        name = "玩法：",
        type = PdkConfig.RuleGroupConfigType.PlayWay,
    },
    FangZuoBi = {
        name = "防作弊：",
        type = PdkConfig.RuleGroupConfigType.FangZuoBi,
    },
    PaiShu = {
        name = "牌数：",
        type = PdkConfig.RuleGroupConfigType.PaiShu,
    },
    JieSanFenShu = {
        name = "解散分数：",
        type = PdkConfig.RuleGroupConfigType.JieSanFenShu,
    },
    RenShu = {
        name = "人数：",
        type = PdkConfig.RuleGroupConfigType.PeopleCount,
    }
}

--局数的规则组配置
PdkConfig.RuleGroupConfigGameTotal = {
    data = PdkConfig.RuleGroupConfig.GameTotal,
    rules = {
        { data = PdkConfig.RuleConfig.GameTotalEight, selected = true, interactable = true },
        { data = PdkConfig.RuleConfig.GameTotalTen, selected = false, interactable = true },
        { data = PdkConfig.RuleConfig.GameTotalTwenty, selected = false, interactable = true },
    }
}

--支付的规则组配置
PdkConfig.RuleGroupConfigPay = {
    data = PdkConfig.RuleGroupConfig.Pay,
    rules = {
        { data = PdkConfig.RuleConfig.PayWinner, selected = false, interactable = true },
        { data = PdkConfig.RuleConfig.PayOwner, selected = true, interactable = true },
    }
}

--分数娱乐场创建房间和配置房间的追加配置
PdkConfig.RuleGroupConfigScore = {
    data = PdkConfig.RuleGroupConfig.Score,
    rules = {
        { data = PdkConfig.RuleConfig.Score0, selected = true, interactable = true },
    }
}

--准入配置
PdkConfig.RuleGroupConfigZhunRu = {
    data = PdkConfig.RuleGroupConfig.ZhunRu,
    rules = {
        { data = PdkConfig.RuleConfig.ZhunRu0, selected = true, interactable = true },
    }
}

--桌费配置
PdkConfig.RuleGroupConfigZhuoFei = {
    data = PdkConfig.RuleGroupConfig.ZhuoFei,
    rules = {
        { data = PdkConfig.RuleConfig.ZhuoFei0, selected = true, interactable = true },
    }
}

--桌费最低配置
PdkConfig.RuleGroupConfigZhuoFeiMin = {
    data = PdkConfig.RuleGroupConfig.ZhuoFeiMin,
    rules = {
        { data = PdkConfig.RuleConfig.ZhuoFeiMin0, selected = true, interactable = true },
    }
}

--先出的规则组配置
PdkConfig.RuleGroupConfigXianChu = {
    data = PdkConfig.RuleGroupConfig.XianChu,
    rules = {
        { data = PdkConfig.RuleConfig.OutRule1, selected = true, interactable = true },
        { data = PdkConfig.RuleConfig.OutRule2, selected = false, interactable = true },
    }
}

--16张先出
PdkConfig.RuleGroupConfigSixteenXianChu = {
    data = PdkConfig.RuleGroupConfig.XianChu,
    rules = {
        { data = PdkConfig.RuleConfig.OutRule3, selected = true, interactable = true },
        { data = PdkConfig.RuleConfig.OutRule4, selected = false, interactable = true },
        { data = PdkConfig.RuleConfig.OutRule5, selected = false, interactable = true },
    }
}

--解散分数配置
PdkConfig.RuleGroupConfigJieSanFenShu = {
    data = PdkConfig.RuleGroupConfig.JieSanFenShu,
    rules = {
        { data = PdkConfig.RuleConfig.JieSanFenShu0, selected = true, interactable = true },
    }
}

--玩法名称
PdkConfig.PlayWayNames = {
    [PdkPlayType.SCErRen] = "两人无四炸",
    [PdkPlayType.SCSanRen] = "三人无四炸",
    [PdkPlayType.SCSiRen] = "四人跑得快",
    [PdkPlayType.LSSanRen] = "乐山三人",
    [PdkPlayType.LSSiRen] = "乐山四人",
    [PdkPlayType.FifteenPDK] = "15张跑得快",
    [PdkPlayType.SixteenPDK] = "16张跑得快",
}

--玩法配置
PdkConfig.PlayWayConfig = {
    {
        name = "乐山三人",
        playWayType = PdkPlayType.LSSanRen,
        playerTotal = 3,
        isGuild = true,
        ruleGroups = {
            PdkConfig.RuleGroupConfigGameTotal,
            PdkConfig.RuleGroupConfigPay,
            PdkConfig.RuleGroupConfigXianChu,
            {
                data = PdkConfig.RuleGroupConfig.PaiShu,
                rules = {
                    { data = PdkConfig.RuleConfig.YuPai1, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.YuPai2, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.PlayWay,
                rules = {
                    { data = PdkConfig.RuleConfig.WanFa1, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.WanFa2, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.FangZuoBi,
                rules = {
                    { data = PdkConfig.RuleConfig.ShouLunGaiPai, selected = true, interactable = true },
                }
            },
            --PdkConfig.RuleGroupConfigScore
            -- , PdkConfig.RuleGroupConfigZhunRu, PdkConfig.RuleGroupConfigJieSanFenShu,
            -- PdkConfig.RuleGroupConfigZhuoFei, PdkConfig.RuleGroupConfigZhuoFeiMin
        }
    },
    {
        name = "乐山四人",
        playWayType = PdkPlayType.LSSiRen,
        playerTotal = 4,
        isGuild = true,
        ruleGroups = {
            PdkConfig.RuleGroupConfigGameTotal,
            PdkConfig.RuleGroupConfigPay,
            PdkConfig.RuleGroupConfigXianChu,
            {
                data = PdkConfig.RuleGroupConfig.PaiShu,
                rules = {
                    { data = PdkConfig.RuleConfig.YuPai1, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.YuPai2, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.PlayWay,
                rules = {
                    { data = PdkConfig.RuleConfig.WanFa1, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.WanFa2, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.FangZuoBi,
                rules = {
                    { data = PdkConfig.RuleConfig.ShouLunGaiPai, selected = true, interactable = true },
                }
            },
            --PdkConfig.RuleGroupConfigScore
            -- , PdkConfig.RuleGroupConfigZhunRu, PdkConfig.RuleGroupConfigJieSanFenShu,
            -- PdkConfig.RuleGroupConfigZhuoFei, PdkConfig.RuleGroupConfigZhuoFeiMin
        }
    },
    {
        name = "两人无四炸",
        playWayType = PdkPlayType.SCErRen,
        playerTotal = 2,
        isGuild = true,
        ruleGroups = {
            PdkConfig.RuleGroupConfigGameTotal,
            PdkConfig.RuleGroupConfigPay,
            {
                data = PdkConfig.RuleGroupConfig.ZhaDan,
                rules = {
                    { data = PdkConfig.RuleConfig.ZhaDan11, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDan12, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.ZhaDanFen1,
                rules = {
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu11, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu12, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.FeiJi,
                rules = {
                    { data = PdkConfig.RuleConfig.FeiJi1, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.FeiJi2, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.PaiXing,
                rules = {
                    { data = PdkConfig.RuleConfig.JieMeiDui, selected = true, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.MingTang,
                rules = {
                    { data = PdkConfig.RuleConfig.QuanHei, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanHong, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanDa, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanXiao, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanDan, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanShuang, selected = true, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.MingTangFen,
                rules = {
                    { data = PdkConfig.RuleConfig.MingTangFen10, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.MingTangFen20, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.PlayWay,
                rules = {
                    { data = PdkConfig.RuleConfig.HongTao10ZaNiao, selected = true, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.FangZuoBi,
                rules = {
                    { data = PdkConfig.RuleConfig.ShouLunGaiPai, selected = false, interactable = true },
                }
            },
            --PdkConfig.RuleGroupConfigScore
            -- , PdkConfig.RuleGroupConfigZhunRu, PdkConfig.RuleGroupConfigJieSanFenShu,
            -- PdkConfig.RuleGroupConfigZhuoFei, PdkConfig.RuleGroupConfigZhuoFeiMin
        }
    },
    {
        name = "三人无四炸",
        playWayType = PdkPlayType.SCSanRen,
        playerTotal = 3,
        isGuild = true,
        ruleGroups = {
            PdkConfig.RuleGroupConfigGameTotal,
            PdkConfig.RuleGroupConfigPay,
            PdkConfig.RuleGroupConfigXianChu,
            {
                data = PdkConfig.RuleGroupConfig.ZhaDan,
                rules = {
                    { data = PdkConfig.RuleConfig.ZhaDan11, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDan12, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.ZhaDanFen1,
                rules = {
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu11, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu12, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.FeiJi,
                rules = {
                    { data = PdkConfig.RuleConfig.FeiJi1, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.FeiJi2, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.PaiXing,
                rules = {
                    { data = PdkConfig.RuleConfig.JieMeiDui, selected = true, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.MingTang,
                rules = {
                    { data = PdkConfig.RuleConfig.QuanHei, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanHong, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanDa, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanXiao, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanDan, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanShuang, selected = true, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.MingTangFen,
                rules = {
                    { data = PdkConfig.RuleConfig.MingTangFen10, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.MingTangFen20, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.PlayWay,
                rules = {
                    { data = PdkConfig.RuleConfig.HongTao10ZaNiao, selected = true, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.FangZuoBi,
                rules = {
                    { data = PdkConfig.RuleConfig.ShouLunGaiPai, selected = true, interactable = true },
                }
            },
            --PdkConfig.RuleGroupConfigScore
            -- , PdkConfig.RuleGroupConfigZhunRu, PdkConfig.RuleGroupConfigJieSanFenShu,
            -- PdkConfig.RuleGroupConfigZhuoFei, PdkConfig.RuleGroupConfigZhuoFeiMin
        }
    },
    {
        name = "四人跑得快",
        playWayType = PdkPlayType.SCSiRen,
        playerTotal = 4,
        isGuild = true,
        ruleGroups = {
            PdkConfig.RuleGroupConfigGameTotal,
            PdkConfig.RuleGroupConfigPay,
            PdkConfig.RuleGroupConfigXianChu,
            {
                data = PdkConfig.RuleGroupConfig.ZhaDan,
                rules = {
                    { data = PdkConfig.RuleConfig.ZhaDan21, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDan22, selected = false, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDan23, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.ZhaDanFen1,
                rules = {
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu21, selected = false, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu22, selected = true, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.ZhaDanFen2,
                rules = {
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu23, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu24, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.FeiJi,
                rules = {
                    { data = PdkConfig.RuleConfig.FeiJi1, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.FeiJi2, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.PaiXing,
                rules = {
                    { data = PdkConfig.RuleConfig.JieMeiDui, selected = true, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.MingTang,
                rules = {
                    { data = PdkConfig.RuleConfig.QuanHei, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanHong, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanDa, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanXiao, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanDan, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.QuanShuang, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.SiGe6k, selected = false, interactable = true },
                    { data = PdkConfig.RuleConfig.SiGe5, selected = false, interactable = true },
                    { data = PdkConfig.RuleConfig.SiGeA, selected = false, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.MingTangFen,
                rules = {
                    { data = PdkConfig.RuleConfig.MingTangFen10, selected = false, interactable = true },
                    { data = PdkConfig.RuleConfig.MingTangFen20, selected = true, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.PlayWay,
                rules = {
                    { data = PdkConfig.RuleConfig.HongTao10ZaNiao, selected = true, interactable = true },
                }
            },
            {
                data = PdkConfig.RuleGroupConfig.FangZuoBi,
                rules = {
                    { data = PdkConfig.RuleConfig.ShouLunGaiPai, selected = false, interactable = true },
                }
            },
            --PdkConfig.RuleGroupConfigScore
            -- , PdkConfig.RuleGroupConfigZhunRu, PdkConfig.RuleGroupConfigJieSanFenShu,
            -- PdkConfig.RuleGroupConfigZhuoFei, PdkConfig.RuleGroupConfigZhuoFeiMin
        }
    },
    {
        name = "15张跑得快",
        playWayType = PdkPlayType.FifteenPDK,
        playerTotal = 3,
        isGuild = true,
        ruleGroups = {
            PdkConfig.RuleGroupConfigGameTotal,
            {
                data = PdkConfig.RuleGroupConfig.RenShu,
                rules = {
                    { data = PdkConfig.RuleConfig.PeopleCount1, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.PeopleCount2, selected = false, interactable = true },
                }
            },
            PdkConfig.RuleGroupConfigPay,
            PdkConfig.RuleGroupConfigSixteenXianChu,
            {
                data = PdkConfig.RuleGroupConfig.ZhaDanFen1,
                rules = {
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu31, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu32, selected = false, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu33, selected = false, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu34, selected = false, interactable = true },
                }
            },
        }
    },
    {
        name = "16张跑得快",
        playWayType = PdkPlayType.SixteenPDK,
        playerTotal = 3,
        isGuild = true,
        ruleGroups = {
            PdkConfig.RuleGroupConfigGameTotal,
            {
                data = PdkConfig.RuleGroupConfig.RenShu,
                rules = {
                    { data = PdkConfig.RuleConfig.PeopleCount1, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.PeopleCount2, selected = false, interactable = true },
                }
            },

            PdkConfig.RuleGroupConfigPay,
            PdkConfig.RuleGroupConfigSixteenXianChu,
            {
                data = PdkConfig.RuleGroupConfig.ZhaDanFen1,
                rules = {
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu31, selected = true, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu32, selected = false, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu33, selected = false, interactable = true },
                    { data = PdkConfig.RuleConfig.ZhaDanFenShu34, selected = false, interactable = true },
                }
            },
        }
    }
}


--规则排序配置，规则解析根据该排序显示
PdkConfig.

RuleSortConfig = {
    --
    PdkRuleType.ST_RS,
    PdkRuleType.OutRule,
    PdkRuleType.LS_XC,
    PdkRuleType.LS_YP,
    PdkRuleType.LS_WF,
    PdkRuleType.ZDGZ,
    PdkRuleType.ZDFS,
    PdkRuleType.FJ,
    PdkRuleType.SLGP,
    PdkRuleType.PX,
    PdkRuleType.MT,
    PdkRuleType.MTFS,
    PdkRuleType.HSZN,
    --
    PdkRuleType.FirstOut,
    PdkRuleType.YCBC,
    PdkRuleType.SDE,
    PdkRuleType.BSF,
    PdkRuleType.SDS,
    PdkRuleType.BDZD,
    PdkRuleType.ZHSD,
    --
    -- PdkRuleType.ZhuoFei,
    -- PdkRuleType.ZhuoFeiMin,
    --PdkRuleType.ZhunRu,
    --PdkRuleType.JieSanFenShu,
    PdkRuleType.PayType,

    PdkRuleType.ST_LFJ,
    PdkRuleType.ST_42,
    PdkRuleType.ST_43,
    PdkRuleType.ST_YBS,
    PdkRuleType.ST_3A,
    PdkRuleType.ST_FC,
    PdkRuleType.ST_SC3,
}

--底分配置,0.1  0.2  0.3  0.5  1  2  3  4  5  6  10  20
PdkConfig.DiFenConfig = { 0.1, 0.2, 0.3, 0.5, 1, 2, 3, 4, 5, 6, 10, 20 }
--底分配置，用于Dropdown列表
PdkConfig.DiFenNameConfig = { "0.1分", "0.2分", "0.3分", "0.5分", "1分", "2分", "3分", "4分", "5分", "6分", "10分", "20分" }

--获取玩法的规则映射配置
function PdkConfig.GetPlayWayConfig(playWayType)
    local result = nil
    local temp = nil
    for i = 1, #PdkConfig.PlayWayConfig do
        temp = PdkConfig.PlayWayConfig[i]
        if temp.playWayType == playWayType then
            result = temp
            break
        end
    end
    return result
end

function PdkConfig.GetPlaywayTypeByName(name)
    local temp = nil
    for i = 1, #PdkConfig.PlayWayConfig do
        temp = PdkConfig.PlayWayConfig[i]
        if temp.name == name then
            return temp.playWayType
        end
    end
    return 0
end


--设置玩法配置，用于规则解析
function PdkConfig.SetPlayWayConfig(playWayConfig)
    if this.playWayConfig ~= playWayConfig then
        this.playWayConfig = playWayConfig
        this.ruleConfigDict = {}

        if this.playWayConfig ~= nil then
            local ruleGroups = this.playWayConfig.ruleGroups
            local rules = nil
            local tempDict = nil
            local data = nil
            for i = 1, #ruleGroups do
                rules = ruleGroups[i].rules
                for j = 1, #rules do
                    data = rules[j].data
                    tempDict = this.ruleConfigDict[data.type]
                    if tempDict == nil then
                        tempDict = {}
                        this.ruleConfigDict[data.type] = tempDict
                    end
                    --存储的是规则配置，不是下面的属性data
                    tempDict[data.value] = rules[j]
                end
            end
        end
    end
end


--获取当前的规则配置数据
function PdkConfig.GetCurrRuleConfigData(ruleType, ruleValue)
    if ruleType == nil or ruleValue == nil then
        return nil
    end

    local dict = this.ruleConfigDict[ruleType]
    if dict ~= nil then
        return dict[ruleValue]
    end

    return nil
end

--解析跑得快规则
function PdkConfig.ParsePdkRule(ruleObj, separator, bdPer)
    if string.IsNullOrEmpty(separator) then
        separator = " "
    end
    local rules = ruleObj
    local parsedRule = { playWayType = 0, playWayName = "", juShu = 0, juShuTxt = "", rule = "", cards = 0, baseScore = 0, userNum = 0 }
    if IsTable(ruleObj) then
        local playWayType = ruleObj[PdkRuleType.PlayType]

        local playWayConfig = PdkConfig.GetPlayWayConfig(playWayType)
        if playWayConfig ~= nil then
            this.SetPlayWayConfig(playWayConfig)
            --玩法名称
            parsedRule.playWayName = playWayConfig.name

            --临时变量定义
            local ruleType = nil
            local ruleValue = nil
            local ruleConfigData = nil

            --解析局数
            ruleType = PdkRuleType.JuShu
            ruleValue = ruleObj[ruleType]
            ruleConfigData = this.GetCurrRuleConfigData(ruleType, ruleValue)
            if ruleConfigData ~= nil then
                parsedRule.juShu = ruleConfigData.data.value
                parsedRule.juShuTxt = ruleConfigData.data.name
                parsedRule.cards = ruleConfigData.data.cards
            end

            --处理底分
            ruleValue = ruleObj[PdkRuleType.DiFen]
            if ruleValue ~= nil then
                parsedRule.baseScore = ruleValue
            end

            --处理玩家数量
            ruleValue = ruleObj[PdkRuleType.PlayerTotal]
            if ruleValue ~= nil then
                parsedRule.userNum = ruleValue
            end

            --其他规则
            local length = #PdkConfig.RuleSortConfig
            local rule = ""
            local isFirst = true
            for i = 1, length do
                ruleType = PdkConfig.RuleSortConfig[i]
                if ruleType == PdkRuleType.MT then
                    --名堂需要特殊处理，因为存的是数组，不是单个值
                    ruleValue = ruleObj[ruleType]
                    if ruleValue ~= nil then
                        if not isFirst then
                            rule = rule .. separator
                        end
                        isFirst = false
                        rule = rule .. this.GetMingTangRuleTxt(ruleValue, separator)
                    end
                else
                    ruleValue = ruleObj[ruleType]
                    --LogError("ruleValue", ruleValue)
                    ruleConfigData = PdkConfig.GetCurrRuleConfigData(ruleType, ruleValue)
                    if ruleConfigData ~= nil then
                        if not isFirst then
                            rule = rule .. separator
                        end
                        isFirst = false
                        rule = rule .. ruleConfigData.data.name
                        --LogError("ruleConfigData.data.name", ruleConfigData.data.name)
                    end
                end
            end

            local temp = 0
            --处理自定义的字段
            rule = ruleObj[PdkRuleType.ST_42] == 1 and rule .. separator .. "可四带二" or rule
            rule = ruleObj[PdkRuleType.ST_43] == 1 and rule .. separator .. "可四带三" or rule
            rule = ruleObj[PdkRuleType.ST_YBS] == 1 and rule .. separator .. "一张不输分" or rule
            rule = ruleObj[PdkRuleType.ST_3A] == 1 and rule .. separator .. "三个A炸弹" or rule
            rule = ruleObj[PdkRuleType.ST_LS] == 1 and rule .. separator .. "最后三张可少带" or rule
            rule = ruleObj[PdkRuleType.ST_LFJ] == 1 and rule .. separator .. "最后飞机可少带" or rule
            rule = ruleObj[PdkRuleType.ST_FC] == 1 and rule .. separator .. "反春" or rule
            rule = ruleObj[PdkRuleType.ST_SC3] == 1 and rule .. separator .. "首出必带黑桃3" or rule

            temp = ruleObj[PdkRuleType.ZhunRu]
            if temp ~= nil then
                rule = rule .. separator .. PdkConfig.RuleConfig.ZhunRu0.name .. "(" .. temp .. ")"
            end
            temp = ruleObj[PdkRuleType.JieSanFenShu]
            if temp ~= nil then
                rule = rule .. separator .. PdkConfig.RuleConfig.JieSanFenShu0.name .. "(" .. temp .. ")"
            end
            -- temp = ruleObj[PdkRuleType.ZhuoFei]
            -- if temp ~= nil then
            --     rule = rule .. separator .. PdkConfig.RuleConfig.ZhuoFei0.name .. "(" .. temp .. ")"
            -- end
            -- temp = ruleObj[PdkRuleType.ZhuoFeiMin]
            -- if temp ~= nil then
            --     rule = rule .. separator .. PdkConfig.RuleConfig.ZhuoFeiMin0.name .. "(" .. temp .. ")"
            -- end

            if UnionData.IsUnionLeader() then
                temp = ruleObj[PdkRuleType.KeepBaseNum]
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

--获取名堂规则文本
function PdkConfig.GetMingTangRuleTxt(list, separator)
    local rule = ""
    local ruleConfigData = nil
    local isFirst = true
    for i = 1, #list do
        ruleConfigData = PdkConfig.GetCurrRuleConfigData(PdkRuleType.MT, list[i])
        if ruleConfigData ~= nil then
            if not isFirst then
                rule = rule .. separator
            end
            isFirst = false
            rule = rule .. ruleConfigData.data.name
        end
    end
    return rule
end

--牌型
function PdkConfig.GetCardTypeText(value, separator)
    if string.IsNullOrEmpty(value) then
        return ""
    end
    if string.IsNullOrEmpty(separator) then
        separator = " "
    end
    if value == 1 then
        return "全黑" .. separator
    end
    if value == 2 then
        return "全红" .. separator
    end
    if value == 3 then
        return "全大" .. separator
    end
    if value == 4 then
        return "全小" .. separator
    end
    if value == 5 then
        return "全单" .. separator
    end
    if value == 6 then
        return "全双" .. separator
    end
    if value == 7 then
        return "4个5" .. separator
    end
    if value == 8 then
        return "4个A" .. separator
    end
    if value == 90 then
        return "4个6" .. separator
    end
    if value == 91 then
        return "4个7" .. separator
    end
    if value == 92 then
        return "4个8" .. separator
    end
    if value == 93 then
        return "4个9" .. separator
    end
    if value == 94 then
        return "4个10" .. separator
    end
    if value == 95 then
        return "4个J" .. separator
    end
    if value == 96 then
        return "4个Q" .. separator
    end
    if value == 97 then
        return "4个K" .. separator
    end
end

--获取消费ID
function PdkConfig.GetConsumeConfigId(playWayType, gameTotal)
    local id = 0

    if playWayType == PdkPlayType.SCSiRen then
        if gameTotal == 10 then
            id = 30005
        elseif gameTotal == 20 then
            id = 30006
        end
    elseif playWayType == PdkPlayType.SCSanRen then
        if gameTotal == 10 then
            id = 30003
        elseif gameTotal == 20 then
            id = 30004
        end
    elseif playWayType == PdkPlayType.SCErRen then
        if gameTotal == 10 then
            id = 30001
        elseif gameTotal == 20 then
            id = 30002
        end
    elseif playWayType == PdkPlayType.LSSanRen then
        if gameTotal == 10 then
            id = 30007
        elseif gameTotal == 20 then
            id = 30008
        end
    elseif playWayType == PdkPlayType.LSSiRen then
        if gameTotal == 10 then
            id = 30009
        elseif gameTotal == 20 then
            id = 30010
        end
    end
    return id
end