--麻将配置
Mahjong = {}

--玩法大类
Mahjong.PlayWayCategory = {
    --成都麻将
    ChengDu = 1,
    --幺鸡麻将
    YaoJi = 2,
    --宜宾麻将
    YiBin = 3,
    --内江麻将
    NeiJiang = 4,
    --四川麻将
    Sichuan = 5,
}

--主页玩法分类
Mahjong.NoteType = {
    YaoJi = 1,    --幺鸡
    ChengDu = 2,  --成麻
    YiBin = 3,    --宜宾
    DaXiaGu = 4,  --大峡谷
    NeiJiang = 5, --内江
}

--玩法类型
Mahjong.PlayWayType = {
    --血战到底
    XueZhanDaoDi = 1,
    --三人两房
    SanRenErFang = 2,
    --血战换三张
    XueZhanHuanSanZhang = 3,
    --三人三房
    SanRenSanFang = 4,
    --二人麻将
    ErRen = 5,
    --四人两房
    SiRenErFang = 6,
    --幺鸡麻将四人
    YaoJiSiRen = 7,
    --幺鸡麻将三人
    YaoJiSanRen = 8,
    --幺鸡麻将二人
    YaoJiErRen = 9,
    --成麻，两人一房
    ErRenYiFang = 10,
    --宜宾四人
    YiBinSiRen = 20,
    --宜宾三人
    YiBinSanRen = 21,
    --大峡谷
    DaXiaGu = 22,
    --宜宾二人
    YiBinErRen = 23,
    --内江四人
    NeiJiangSiRen = 31,
    --内江三人
    NeiJiangSanRen = 32,
    --内江二人
    NeiJiangErRen = 33,
    ---飞小鸡
    FlyChicken = 41,
}

Mahjong.PlayWayBelong = {
    [Mahjong.PlayWayType.XueZhanDaoDi] = Mahjong.PlayWayCategory.Sichuan,
    [Mahjong.PlayWayType.SanRenErFang] = Mahjong.PlayWayCategory.Sichuan,
    --[Mahjong.PlayWayType.XueZhanHuanSanZhang] = Mahjong.PlayWayCategory.Sichuan,
    [Mahjong.PlayWayType.SanRenSanFang] = Mahjong.PlayWayCategory.Sichuan,
    [Mahjong.PlayWayType.ErRen] = Mahjong.PlayWayCategory.Sichuan,
    [Mahjong.PlayWayType.SiRenErFang] = Mahjong.PlayWayCategory.Sichuan,
    [Mahjong.PlayWayType.YaoJiSiRen] = Mahjong.PlayWayCategory.YaoJi,
    [Mahjong.PlayWayType.YaoJiSanRen] = Mahjong.PlayWayCategory.YaoJi,
    [Mahjong.PlayWayType.YaoJiErRen] = Mahjong.PlayWayCategory.YaoJi,
    [Mahjong.PlayWayType.FlyChicken] = Mahjong.PlayWayCategory.YaoJi,
    [Mahjong.PlayWayType.ErRenYiFang] = Mahjong.PlayWayCategory.Sichuan,
    [Mahjong.PlayWayType.YiBinSiRen] = Mahjong.PlayWayCategory.Sichuan,
    [Mahjong.PlayWayType.YiBinSanRen] = Mahjong.PlayWayCategory.Sichuan,
    [Mahjong.PlayWayType.DaXiaGu] = Mahjong.PlayWayCategory.Sichuan,
    [Mahjong.PlayWayType.YiBinErRen] = Mahjong.PlayWayCategory.Sichuan,
    [Mahjong.PlayWayType.NeiJiangSiRen] = Mahjong.PlayWayCategory.Sichuan,
    [Mahjong.PlayWayType.NeiJiangSanRen] = Mahjong.PlayWayCategory.Sichuan,
    [Mahjong.PlayWayType.NeiJiangErRen] = Mahjong.PlayWayCategory.Sichuan,
}

--规则类型
Mahjong.RuleType = {
    --玩法类型
    PlayWayType = "NPWT",
    --游戏局数，4四局、8八局、12十二局
    GameTotal = "NGT",
    --牌张，7七张、10十张、13十三张
    CardTotal = "NCT",
    --房牌数量，2两房、3三房
    FangTotal = "NFT",
    --人数，2两人、3三人、4四人
    PlayerTotal = "NPT",
    --定缺，0不定缺、1定缺
    DingQue = "NDQ",
    --番数，倍数，2两番、3三番、4四番、5五番
    Multiple = "NM",
    --换牌总数，0不换、3换三张、4换四张
    ChangeCardTotal = "NCCT",
    --换牌类型，0单色换、1任意换、2任意混换
    ChangeCardType = "NCC",
    --支付方式，0无、1房主支付、2AA制支付、3俱乐部支付、4大赢家付
    Pay = "NP",
    --规则key
    Key = "KEY",
    --房间类型
    RoomType = "CRT",
    --飘 ，不飘0，随飘1，定飘2, 3必飘
    Piao = "PA",
    --点炮胡0，自摸胡1
    HuType = "HT",
    --听牌数量
    TingTotal = "TT",
    --
    --听牌提示，0无、1选中
    TingPaiTiShi = "TPTS",
    --点杠花，0点杠花(点炮)、1点杠花(自摸)
    DianGangHua = "DGH",
    --天地胡，0无、1选中
    TianDiHu = "TDH",
    --清一色0番，清一色1番，清一色2番
    QingYiSe = "ERQYS",
    --门清，0无、1选中
    MenQing = "MQ",
    --中张，0无、1选中
    ZhongZhang = "ZZ",
    --门清中张，0无、1选中
    MenQingZhongZhang = "MQZZ",
    --幺九，0无、1选中
    YaoJiu = "YJ",
    --将对，0无、1选中
    JiangDui = "JD",
    --幺九将对，0无、1选中
    YaoJiuJiangDui = "YJJD",
    --海底，0无、1选中
    HaiDi = "HD",
    --金钩钓，0无、1选中
    JinGouDiao = "JGD",
    --两分起胡，0无、1选中
    LiangFenQiHu = "LFQH",
    --自摸加分类型，0无、1自摸加底、2自摸加番
    ZiMoJiaFen = "ZMJF",
    --点炮可平胡，0无、1选中
    DianPaoPingHu = "DPPH",
    --对对胡两番，0无、1选中
    DuiDuiHuLiangFan = "DDLF",
    --夹心五，0无、1选中
    JiaXinWu = "JXW",
    --卡二条，0无、1选中
    KaErTiao = "KET",
    --分数娱乐场底分
    Score = "TS",
    --托管，客户端显示使用
    Trust = "TRS",
    --Gps选项
    Gps = "GP",
    --四鸡报喜  --5 5番 6 6番
    SiJiBaoXi = "SJBX",
    --三鸡报喜  --4 4番
    SanJiBaoXi = "SANJBX",
    --单家扣喜
    DJKX = "DJKX", --0/1 未选/选中
    --两分起胡(一番)，0无、1选中
    LiangFenQiHu = "LFQH",
    --两番起胡
    LiangFanQiHu = "LMQH",
    --三番起胡 (只用于二人麻将分数场)
    SanFanQiHu = "SFQH",
    --四番起胡
    SiFanQiHu = "F4QH",
    --番数起胡（暂创建页面使用）
    FanShuQiHu = "FSQH",
    --准入
    ZhunRu = "ZR",
    --桌费
    ZhuoFei = "ZF",
    --桌费最小值
    ZhuoFeiMin = "MZF",
    --解散分数
    JieSanFenShu = "JSFS",
    --四对可胡（4对算7对）
    FourDuiHu7Dui = "SD7D",
    --呼叫转移
    CallConvert = "HJZY",
    ---吃牌
    EatCard = "EC",
    ---点鸡
    ClickChicken = "CC",
    ---养猪
    RaisePig = "RP",
    ---飞小鸡人数
    FlyChickenPeopleCount = "FCPC",
    ---保底
    KeepBaseNum = "keepBaseNum",
    -- 对对胡2番
    DDH2Fan = "DDHJF",
    -- 可抢挑胡
    QTH = "QTH",
    -- 可抢碰胡
    QPH = "QPH", --0/1 未选/选中
    -- 可抢挑胡，抢听用
    QTHQJ = "QTHQJ",
    --最低起胡番数（新定义）
    HuMinFan = "MINFAN",
}

--玩法规则配置，如果是复选框，选中则使用Value值，否则使用0，单选框则使用相应的Value值
Mahjong.RuleConfig = {
    --局数
    GameTotalOne = { name = "1局", tips = "1局", type = Mahjong.RuleType.GameTotal, value = 1, cards = 1, cards2 = 1, group = 1 },
    GameTotalFour = { name = "4局", tips = "4局", desc = "4局", type = Mahjong.RuleType.GameTotal, value = 4, cards = 2, cards2 = 3, group = 1 },
    GameTotalEight = { name = "8局", tips = "8局", desc = "8局", type = Mahjong.RuleType.GameTotal, value = 8, cards = 3, cards2 = 4, group = 1 },
    GameTotalTwelve = { name = "12局", tips = "12局", desc = "12局", type = Mahjong.RuleType.GameTotal, value = 12, cards = 4, cards2 = 5, group = 1 },
    GameTotalInfinite = { name = "无限局", tips = "无限局", desc = "无限局", type = Mahjong.RuleType.GameTotal, value = -1, cards = 0, cards2 = 0, group = 1 },
    --两人麻将局数
    GameTotal2Four = { name = "4局", tips = "4局", type = Mahjong.RuleType.GameTotal, value = 4, cards = 2, cards2 = 2, group = 1 },
    GameTotal2Eight = { name = "8局", tips = "8局", type = Mahjong.RuleType.GameTotal, value = 8, cards = 3, cards2 = 3, group = 1 },
    --牌张
    CardTotalSeven = { name = "7张", type = Mahjong.RuleType.CardTotal, value = 7, group = 2 },
    CardTotalTen = { name = "10张", type = Mahjong.RuleType.CardTotal, value = 10, group = 2 },
    CardTotalThirteen = { name = "13张", type = Mahjong.RuleType.CardTotal, value = 13, group = 2 },
    --房牌数量
    FangTotalOne = { name = "一房", type = Mahjong.RuleType.FangTotal, value = 1, group = 3 },
    FangTotalTwo = { name = "两房", type = Mahjong.RuleType.FangTotal, value = 2, group = 3 },
    FangTotalThree = { name = "三房", type = Mahjong.RuleType.FangTotal, value = 3, group = 3 },
    --定缺
    DingQue = { name = "定缺", type = Mahjong.RuleType.DingQue, default = 0, value = 1, group = 0 },
    --番数
    Multiple0 = { name = "番数", desc = "自定义", type = Mahjong.RuleType.Multiple, value = 5, group = 4, dataType = 1, min = 5, max = 10, step = 1, itemType = 1, suffix = "番" },
    MultipleTwo = { name = "2番", type = Mahjong.RuleType.Multiple, value = 2, group = 4 },
    MultipleThree = { name = "3番", type = Mahjong.RuleType.Multiple, value = 3, group = 4 },
    MultipleFour = { name = "4番", type = Mahjong.RuleType.Multiple, value = 4, group = 4 },
    MultipleFive = { name = "5番", type = Mahjong.RuleType.Multiple, value = 5, group = 4 },
    MultipleSix = { name = "6番", type = Mahjong.RuleType.Multiple, value = 6, group = 4 },
    --换牌
    ChangeCardTotalThree = { name = "换三张", type = Mahjong.RuleType.ChangeCardTotal, value = 3, group = 0 },
    ChangeCardTotalFour = { name = "换四张", type = Mahjong.RuleType.ChangeCardTotal, value = 4, group = 0 },
    --换牌类型
    ChangeCardTypeSingle = { name = "单色换", type = Mahjong.RuleType.ChangeCardType, value = 0, group = 5 },
    ChangeCardTypeArbitrarily = { name = "任意换", type = Mahjong.RuleType.ChangeCardType, value = 1, group = 5 },
    ChangeCardTypeArbitrarilyMix = { name = "任意混换", type = Mahjong.RuleType.ChangeCardType, value = 2, group = 5 },
    --支付方式
    PayOwner = { name = "房主付", type = Mahjong.RuleType.Pay, value = 1, group = 6 },
    PayAA = { name = "AA制付", type = Mahjong.RuleType.Pay, value = 2, group = 6 },
    PayClub = { name = "俱乐部付", type = Mahjong.RuleType.Pay, value = 3, group = 6 },
    PayWinner = { name = "大赢家付", type = Mahjong.RuleType.Pay, value = 4, group = 6 },

    --飘
    PiaoNone = { name = "不飘", type = Mahjong.RuleType.Piao, value = 0, group = 10 },
    PiaoSui = { name = "随飘", type = Mahjong.RuleType.Piao, value = 1, group = 10 },
    PiaoDing = { name = "定飘", type = Mahjong.RuleType.Piao, value = 2, group = 10 },

    --点炮胡0，自摸胡1
    HuTypeDianPao = { name = "点炮胡", type = Mahjong.RuleType.HuType, value = 0, group = 11 },
    HuTypeZiMo = { name = "自摸胡", type = Mahjong.RuleType.HuType, value = 1, group = 11 },

    --听牌数量
    TingTotal4 = { name = "4听用", type = Mahjong.RuleType.TingTotal, value = 4, group = 12 },
    TingTotal8 = { name = "8听用", type = Mahjong.RuleType.TingTotal, value = 8, group = 12 },
    TingTotal11 = { name = "11听用", type = Mahjong.RuleType.TingTotal, value = 11, group = 12 },
    TingTotal12 = { name = "12听用", type = Mahjong.RuleType.TingTotal, value = 12, group = 12 },
    --宜宾3人8听用复选框
    --默认值用于未勾选时使用
    TingTotal8Yb3 = { name = "8听用", type = Mahjong.RuleType.TingTotal, default = 4, value = 8, group = 0 },

    --听牌提示
    TingPaiTiShi = { name = "听牌提示", type = Mahjong.RuleType.TingPaiTiShi, value = 1, group = 0 },
    --点杠花
    DianGangHuaDianPao = { name = "点杠花(点炮)", type = Mahjong.RuleType.DianGangHua, value = 0, group = 7 },
    DianGangHuaZiMo = { name = "点杠花(自摸)", type = Mahjong.RuleType.DianGangHua, value = 1, group = 7 },
    --点杠花(自摸)的单独选项
    DianGangHuaZiMoSingle = { name = "点杠花(自摸)", type = Mahjong.RuleType.DianGangHua, value = 1, group = 0 },
    --天地胡，0无、1选中
    NoTianDiHu = { name = "无天地胡", type = Mahjong.RuleType.TianDiHu, value = 0, group = 9 },
    NormalTianDiHu = { name = "普通天地胡", type = Mahjong.RuleType.TianDiHu, value = 1, group = 9 },
    CHongqingTianDiHu = { name = "重庆天地胡", type = Mahjong.RuleType.TianDiHu, value = 2, group = 9 },
    --清一色0番，清一色1番，清一色2番
    QingYiSe0 = { name = "清一色0番", type = Mahjong.RuleType.QingYiSe, value = 0, group = 13 },
    QingYiSe1 = { name = "清一色1番", type = Mahjong.RuleType.QingYiSe, value = 1, group = 13 },
    QingYiSe2 = { name = "清一色2番", type = Mahjong.RuleType.QingYiSe, value = 2, group = 13 },
    --门清，0无、1选中
    MenQing = { name = "门清", type = Mahjong.RuleType.MenQing, value = 1, group = 0 },
    --中张，0无、1选中
    ZhongZhang = { name = "中张", type = Mahjong.RuleType.ZhongZhang, value = 1, group = 0 },
    --门清中张，0无、1选中
    MenQingZhongZhang = { name = "门清中张", type = Mahjong.RuleType.MenQingZhongZhang, value = 1, group = 0 },
    --幺九，0无、1选中
    YaoJiu = { name = "幺九", type = Mahjong.RuleType.YaoJiu, value = 1, group = 0 },
    --将对，0无、1选中
    JiangDui = { name = "将对", type = Mahjong.RuleType.JiangDui, value = 1, group = 0 },
    --幺九将对，0无、1选中
    YaoJiuJiangDui = { name = "幺九将对", type = Mahjong.RuleType.YaoJiuJiangDui, value = 1, group = 0 },
    --海底，0无、1选中
    HaiDi = { name = "海底", type = Mahjong.RuleType.HaiDi, value = 1, group = 0, tips = "开启后，海底自摸、海底炮番数+1（2倍）。" },
    --金钩钓，0无、1选中
    JinGouDiao = { name = "金钩钓", type = Mahjong.RuleType.JinGouDiao, value = 1, group = 0 },

    --自摸加分类型，0无、1自摸加底、2自摸加番
    ZiMoJiaFenJiaDi = { name = "自摸加底", type = Mahjong.RuleType.ZiMoJiaFen, value = 1, group = 8 },
    ZiMoJiaFenJiaFan = { name = "自摸加番", type = Mahjong.RuleType.ZiMoJiaFen, value = 2, group = 8 },
    --自摸加番的单独选项
    ZiMoJiaFenJiaFanSingle = { name = "自摸加番", type = Mahjong.RuleType.ZiMoJiaFen, value = 2, group = 0 },
    --点炮可平胡，0无、1选中
    DianPaoPingHu = { name = "点炮可平胡", type = Mahjong.RuleType.DianPaoPingHu, value = 1, group = 0 },
    --对对胡两番，0无、1选中
    DuiDuiHuLiangFan = { name = "对对胡两番", type = Mahjong.RuleType.DuiDuiHuLiangFan, value = 1, group = 0, tips = "开启后，对对胡胡牌番数为2番（4倍）。" },
    --四对可胡，0无、1选中
    FourDuiHu7Dui = { name = "四对可胡", type = Mahjong.RuleType.FourDuiHu7Dui, value = 1, group = 0 },
    --两分起胡(一番)，0无、1选中
    LiangFenQiHu = { name = "两分起胡", type = Mahjong.RuleType.LiangFenQiHu, value = 1, group = 0 },
    --两番起胡
    LiangFanQiHu = { name = "两番起胡", type = Mahjong.RuleType.LiangFanQiHu, value = 1, group = 0 },
    --三番起胡
    SanFanQiHu = { name = "三番起胡", type = Mahjong.RuleType.SanFanQiHu, value = 1, group = 0 },
    --四番起胡
    SiFanQiHu = { name = "四番起胡", type = Mahjong.RuleType.SiFanQiHu, value = 1, group = 0 },
    --呼叫转移
    CallConvert = { name = "呼叫转移", type = Mahjong.RuleType.CallConvert, value = 1, group = 0 },
    --番数起胡--dataType为数据类型，1表示自定义类型，其他为默认类型；itemType为显示项类型，1为InputBtn类型，其他按原来的方式，20240612
    FanQiHuCustom = { name = "起胡番", desc = "自定义", type = Mahjong.RuleType.HuMinFan, value = 2, group = 9, dataType = 1, min = 2, max = 3, step = 1, itemType = 1, suffix = "番" },
    FanQiHu0 = { name = "0番", type = Mahjong.RuleType.HuMinFan, value = 0, group = 9 },
    FanQiHu1 = { name = "1番", type = Mahjong.RuleType.HuMinFan, value = 1, group = 9 },
    Fan1QiHu = { name = "两分起胡", type = Mahjong.RuleType.FanShuQiHu, value = 1, group = 9 },
    Fan2QiHu = { name = "两番起胡", type = Mahjong.RuleType.FanShuQiHu, value = 2, group = 9 },
    Fan3QiHu = { name = "三番起胡", type = Mahjong.RuleType.FanShuQiHu, value = 3, group = 9 },
    Fan4QiHu = { name = "四番起胡", type = Mahjong.RuleType.FanShuQiHu, value = 4, group = 9 },
    --
    --夹心五，0无、1选中
    JiaXinWu = { name = "夹心五", type = Mahjong.RuleType.JiaXinWu, value = 1, group = 0 },
    --卡二条，0无、1选中
    KaErTiao = { name = "卡二条", type = Mahjong.RuleType.KaErTiao, value = 1, group = 0 },
    --
    Qth = { name = "可抢挑胡", type = Mahjong.RuleType.QTH, value = 1, group = 0, tips = "可以进行抢玩家挑的牌进行胡牌，胡牌类型为抢杠胡，抢走的牌为玩家本身胡的那张牌。" },
    Qph = { name = "可抢碰胡", type = Mahjong.RuleType.QPH, value = 1, group = 0 },
    QthQj = { name = "抢鸡", type = Mahjong.RuleType.QTHQJ, value = 1, group = 0, tips = "玩家在抢杠胡（带幺鸡）时，抢走的牌为幺鸡牌。" },
    --四鸡报喜
    SiJiBaoXi = { name = "四鸡吃喜", type = Mahjong.RuleType.SiJiBaoXi, value = 1, group = 0, tips = "勾选后，拿到四鸡吃喜为封顶番的分数。" },
    SanJiBaoXi = { name = "三鸡吃喜", type = Mahjong.RuleType.SanJiBaoXi, value = 1, group = 0, tips = "勾选后，拿到三鸡吃喜为封顶减一番的分数。" },
    Djkx = { name = "单家扣喜", type = Mahjong.RuleType.DJKX, value = 1, group = 0 },
    --
    SiJiBaoXi5 = { name = "四鸡报喜(5番)", desc = "四鸡报喜<size=28>(5番)</size>", type = Mahjong.RuleType.SiJiBaoXi, value = 5, group = 10 },
    SiJiBaoXi6 = { name = "四鸡报喜(6番)", desc = "四鸡报喜<size=28>(6番)</size>", type = Mahjong.RuleType.SiJiBaoXi, value = 6, group = 10 },
    --
    SanJiBaoXi4 = { name = "三鸡报喜(4番)", desc = "三鸡报喜<size=28>(4番)</size>", type = Mahjong.RuleType.SanJiBaoXi, value = 4, group = 0 },
    --
    ---吃牌
    EatCard = { name = "吃牌", type = Mahjong.RuleType.EatCard, value = 1, group = 0 },
    ---点鸡
    ClickChicken = { name = "点鸡", type = Mahjong.RuleType.ClickChicken, value = 1, group = 0 },
    ---养猪
    RaisePig = { name = "养猪", type = Mahjong.RuleType.RaisePig, value = 1, group = 0 },
    --客户端特殊处理，分数娱乐场分数
    Score0 = { name = "底分", desc = "自定义", type = Mahjong.RuleType.Score, value = 0, group = 11 },
    Score10 = { name = "底分", desc = "10", type = Mahjong.RuleType.Score, value = 10, group = 11 },
    Score20 = { name = "底分", desc = "20", type = Mahjong.RuleType.Score, value = 20, group = 11 },
    Score30 = { name = "底分", desc = "30", type = Mahjong.RuleType.Score, value = 30, group = 11 },
    Score50 = { name = "底分", desc = "50", type = Mahjong.RuleType.Score, value = 50, group = 11 },
    Score100 = { name = "底分", desc = "100", type = Mahjong.RuleType.Score, value = 100, group = 11 },
    Score200 = { name = "底分", desc = "200", type = Mahjong.RuleType.Score, value = 200, group = 11 },
    Score300 = { name = "底分", desc = "300", type = Mahjong.RuleType.Score, value = 300, group = 11 },
    Score500 = { name = "底分", desc = "500", type = Mahjong.RuleType.Score, value = 500, group = 11 },
    Score1000 = { name = "底分", desc = "1000", type = Mahjong.RuleType.Score, value = 1000, group = 11 },
    Score2000 = { name = "底分", desc = "2000", type = Mahjong.RuleType.Score, value = 2000, group = 11 },
    --
    Trust = { name = "超时托管", type = Mahjong.RuleType.Trust, value = 1, group = 0 },
    Gps = { name = "强制定位", type = Mahjong.RuleType.Gps, value = 1, group = 0 },

    --准入
    ZhunRu0 = { name = "准入", desc = "自定义", type = Mahjong.RuleType.ZhunRu, value = 0, group = 12 },
    --桌费
    ZhuoFei0 = { name = "表情赠送", desc = "自定义", type = Mahjong.RuleType.ZhuoFei, value = 0, group = 13 },
    --桌费最小
    ZhuoFeiMin0 = { name = "最低赠送", desc = "自定义", type = Mahjong.RuleType.ZhuoFeiMin, value = 0, group = 14 },
    --解散分数
    JieSanFenShu0 = { name = "解散分数", desc = "自定义", type = Mahjong.RuleType.JieSanFenShu, value = 0, group = 15 },
    ---人数
    PeopleCount2 = { name = "2人", type = Mahjong.RuleType.FlyChickenPeopleCount, value = 2, group = 16 },
    PeopleCount4 = { name = "4人", type = Mahjong.RuleType.FlyChickenPeopleCount, value = 4, group = 16 },
}

--规则配置映射
Mahjong.RuleConfigMap = {}

--初始规则配置映射
function Mahjong.InitRuleConfigMap()
    local temp = nil
    for k, v in pairs(Mahjong.RuleConfig) do
        temp = Mahjong.RuleConfigMap[v.type]
        if temp == nil then
            temp = {}
            Mahjong.RuleConfigMap[v.type] = temp
        end
        temp[v.value] = v
    end
end

--执行
Mahjong.InitRuleConfigMap()

--规则组配置类型，客户端使用
Mahjong.RuleGroupConfigType = {
    --规则
    Rule = 1,
    --局数
    GameTotal = 2,
    --封顶
    Limit = 3,
    --换张
    Change = 4,
    --玩法
    PlayWay = 5,
    --支付
    Pay = 6,
    --房数
    FangTotal = 7,
    --牌张
    CardTotal = 8,
    --底分
    Score = 9,
    --准入
    ZhunRu = 10,
    --桌费
    ZhuoFei = 11,
    --桌费最小值
    ZhuoFeiMin = 12,
    --解散分数
    JieSanFenShu = 13,
    --人数
    PeopleCount = 14,
    --听用
    TingYong = 15,
    --起胡
    QiHu = 16,
}

--规则组配置
Mahjong.RuleGroupConfig = {
    --规则
    Rule = {
        name = "规则：",
        sprite = "",
        type = Mahjong.RuleGroupConfigType.Rule,
    },
    --局数
    GameTotal = {
        name = "局数：",
        sprite = "GameTotal",
        type = Mahjong.RuleGroupConfigType.GameTotal,
    },
    Limit = {
        name = "封顶：",
        sprite = "Limit",
        type = Mahjong.RuleGroupConfigType.Limit,
    },
    Change = {
        name = "换张：",
        sprite = "Change",
        type = Mahjong.RuleGroupConfigType.Change,
    },
    PlayWay = {
        name = "玩法：",
        sprite = "PlayWay",
        type = Mahjong.RuleGroupConfigType.PlayWay,
    },
    Pay = {
        name = "支付：",
        sprite = "Pay",
        type = Mahjong.RuleGroupConfigType.Pay,
    },
    CardTotal = {
        name = "牌张：",
        sprite = "CardTotal",
        type = Mahjong.RuleGroupConfigType.CardTotal,
    },
    FangTotal = {
        name = "房数：",
        sprite = "FangTotal",
        type = Mahjong.RuleGroupConfigType.FangTotal,
    },
    TingYong = {
        name = "听用：",
        sprite = "TingYong",
        type = Mahjong.RuleGroupConfigType.TingYong,
    },
    QiHu = {
        name = "起胡番：",
        sprite = "QiHu",
        type = Mahjong.RuleGroupConfigType.QiHu,
    },
    Score = {
        name = "底分：",
        sprite = "Score",
        type = Mahjong.RuleGroupConfigType.Score,
    },
    ZhunRu = {
        name = "准入：",
        sprite = "ZhuRu",
        type = Mahjong.RuleGroupConfigType.ZhunRu,
    },
    ZhuoFei = {
        name = "表情赠送：",
        sprite = "ZhuoFei",
        type = Mahjong.RuleGroupConfigType.ZhuoFei,
    },
    ZhuoFeiMin = {
        name = "最低赠送：",
        sprite = "ZhuoFeiMin",
        type = Mahjong.RuleGroupConfigType.ZhuoFeiMin,
    },
    JieSanFenShu = {
        name = "解散分数：",
        sprite = "JieSanFenShu",
        type = Mahjong.RuleGroupConfigType.JieSanFenShu,
    },
    PeopleCount = {
        name = "人数：",
        sprite = "",
        type = Mahjong.RuleGroupConfigType.PeopleCount,
    }
}

--支付的规则组配置
Mahjong.RuleGroupConfigPay = {
    data = Mahjong.RuleGroupConfig.Pay,
    rules = {
        { data = Mahjong.RuleConfig.PayWinner, selected = false, interactable = true },
        { data = Mahjong.RuleConfig.PayOwner,  selected = true,  interactable = true },
    }
}

--分数娱乐场创建房间和配置房间的追加配置
Mahjong.RuleGroupConfigScore = {
    data = Mahjong.RuleGroupConfig.Score,
    rules = {
        -- { data = Mahjong.RuleConfig.Score10, selected = true, interactable = true },
        -- { data = Mahjong.RuleConfig.Score20, selected = false, interactable = true },
        -- { data = Mahjong.RuleConfig.Score30, selected = false, interactable = true },
        { data = Mahjong.RuleConfig.Score0, selected = true, interactable = true },
    }
}

--准入配置
Mahjong.RuleGroupConfigZhunRu = {
    data = Mahjong.RuleGroupConfig.ZhunRu,
    rules = {
        { data = Mahjong.RuleConfig.ZhunRu0, selected = true, interactable = true },
    }
}

--桌费配置
Mahjong.RuleGroupConfigZhuoFei = {
    data = Mahjong.RuleGroupConfig.ZhuoFei,
    rules = {
        { data = Mahjong.RuleConfig.ZhuoFei0, selected = true, interactable = true },
    }
}

--桌费最低配置
Mahjong.RuleGroupConfigZhuoFeiMin = {
    data = Mahjong.RuleGroupConfig.ZhuoFeiMin,
    rules = {
        { data = Mahjong.RuleConfig.ZhuoFeiMin0, selected = true, interactable = true },
    }
}

--解散分数配置
Mahjong.RuleGroupConfigJieSanFenShu = {
    data = Mahjong.RuleGroupConfig.JieSanFenShu,
    rules = {
        { data = Mahjong.RuleConfig.JieSanFenShu0, selected = true, interactable = true },
    }
}

--幺鸡麻将的听用配置
Mahjong.RuleGroupConfigTingYong = {
    data = Mahjong.RuleGroupConfig.TingYong,
    rules = {
        { data = Mahjong.RuleConfig.TingTotal4,  selected = true,  interactable = true },
        { data = Mahjong.RuleConfig.TingTotal8,  selected = false, interactable = true },
        { data = Mahjong.RuleConfig.TingTotal12, selected = false, interactable = true },
    }
}

--幺鸡麻将的起胡番配置
Mahjong.RuleGroupConfigQiHu = {
    data = Mahjong.RuleGroupConfig.QiHu,
    rules = {
        { data = Mahjong.RuleConfig.FanQiHu0,      selected = true,  interactable = true },
        { data = Mahjong.RuleConfig.FanQiHu1,      selected = false, interactable = true },
        { data = Mahjong.RuleConfig.FanQiHuCustom, selected = false, interactable = true },
    }
}

--幺鸡麻将的番数配置
Mahjong.RuleGroupConfigLimit = {
    data = Mahjong.RuleGroupConfig.Limit,
    rules = {
        { data = Mahjong.RuleConfig.MultipleThree, selected = true,  interactable = true },
        { data = Mahjong.RuleConfig.MultipleFour,  selected = false, interactable = true },
        { data = Mahjong.RuleConfig.Multiple0,     selected = false, interactable = true }
    }
}

--玩法名称
Mahjong.PlayWayNames = {
    [Mahjong.PlayWayType.YaoJiSiRen] = "幺鸡四人",
    [Mahjong.PlayWayType.YaoJiSanRen] = "幺鸡三人",
    [Mahjong.PlayWayType.YaoJiErRen] = "幺鸡二人",
    [Mahjong.PlayWayType.XueZhanDaoDi] = "血战到底",
    --[Mahjong.PlayWayType.XueZhanHuanSanZhang] = "血战换三张",
    [Mahjong.PlayWayType.SanRenErFang] = "三人两房",
    [Mahjong.PlayWayType.SiRenErFang] = "四人两房",
    [Mahjong.PlayWayType.SanRenSanFang] = "三人三房",
    [Mahjong.PlayWayType.ErRen] = "两人麻将",
    [Mahjong.PlayWayType.ErRenYiFang] = "两人一房",
    [Mahjong.PlayWayType.FlyChicken] = "飞小鸡",
}

--玩法配置
Mahjong.PlayWayConfig = {
    YaoJiSiRen = {
        name = "幺鸡四人",
        playWayType = Mahjong.PlayWayType.YaoJiSiRen,
        playerTotal = 4,
        isGuild = true,
        --默认的规则配置，直接使用，且不显示UI
        defaultRuleGroups = {
            Mahjong.RuleConfig.FangTotalThree,
            Mahjong.RuleConfig.CardTotalThirteen
        },
        ruleGroups = {
            {
                data = Mahjong.RuleGroupConfig.GameTotal,
                rules = {
                    { data = Mahjong.RuleConfig.GameTotalFour,   selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.GameTotalEight,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.GameTotalTwelve, selected = false, interactable = true },
                    --{ data = Mahjong.RuleConfig.GameTotalInfinite, selected = false, interactable = true }
                }
            },
            Mahjong.RuleGroupConfigLimit,
            {
                data = Mahjong.RuleGroupConfig.Change,
                rules = {
                    { data = Mahjong.RuleConfig.ChangeCardTotalThree,         selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeSingle,         selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeArbitrarily,    selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeArbitrarilyMix, selected = false, interactable = true }
                }
            },
            Mahjong.RuleGroupConfigQiHu,
            Mahjong.RuleGroupConfigTingYong,
            {
                data = Mahjong.RuleGroupConfig.PlayWay,
                rules = {
                    { data = Mahjong.RuleConfig.DianGangHuaDianPao, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.DianGangHuaZiMo,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.NormalTianDiHu,     selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.CHongqingTianDiHu,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.NoTianDiHu,         selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.DuiDuiHuLiangFan,   selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.Qth,                selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.QthQj,              selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.Qph,                selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.SanJiBaoXi,         selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.Djkx,               selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.SiJiBaoXi,          selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.MenQing,            selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ZhongZhang,         selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.HaiDi,              selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.JinGouDiao,         selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.YaoJiuJiangDui,     selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.TingPaiTiShi,       selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.Trust,              selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.Gps,                selected = false, interactable = true }
                }
            },
            Mahjong.RuleGroupConfigPay
            --, Mahjong.RuleGroupConfigScore
            -- , Mahjong.RuleGroupConfigZhunRu, Mahjong.RuleGroupConfigJieSanFenShu,
            -- Mahjong.RuleGroupConfigZhuoFei, Mahjong.RuleGroupConfigZhuoFeiMin
        }
    },
    YaoJiSanRen = {
        name = "幺鸡三人",
        playWayType = Mahjong.PlayWayType.YaoJiSanRen,
        playerTotal = 3,
        isGuild = true,
        defaultRuleGroups = {
            Mahjong.RuleConfig.FangTotalThree,
            Mahjong.RuleConfig.CardTotalThirteen
        },
        ruleGroups = {
            {
                data = Mahjong.RuleGroupConfig.GameTotal,
                rules = {
                    { data = Mahjong.RuleConfig.GameTotalFour,   selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.GameTotalEight,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.GameTotalTwelve, selected = false, interactable = true },
                    --{ data = Mahjong.RuleConfig.GameTotalInfinite, selected = false, interactable = true }
                }
            },
            Mahjong.RuleGroupConfigLimit,
            {
                data = Mahjong.RuleGroupConfig.Change,
                rules = {
                    { data = Mahjong.RuleConfig.ChangeCardTotalThree,         selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeSingle,         selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeArbitrarily,    selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeArbitrarilyMix, selected = false, interactable = true }
                }
            },
            Mahjong.RuleGroupConfigQiHu,
            Mahjong.RuleGroupConfigTingYong,
            {
                data = Mahjong.RuleGroupConfig.PlayWay,
                rules = {
                    { data = Mahjong.RuleConfig.DianGangHuaDianPao, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.DianGangHuaZiMo,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.NormalTianDiHu,     selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.CHongqingTianDiHu,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.NoTianDiHu,         selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.DuiDuiHuLiangFan,   selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.Qth,                selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.QthQj,              selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.Qph,                selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.SanJiBaoXi,         selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.Djkx,               selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.SiJiBaoXi,          selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.MenQing,            selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ZhongZhang,         selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.HaiDi,              selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.JinGouDiao,         selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.YaoJiuJiangDui,     selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.TingPaiTiShi,       selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.Trust,              selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.Gps,                selected = false, interactable = true }
                }
            },
            Mahjong.RuleGroupConfigPay
            --, Mahjong.RuleGroupConfigScore
            --, Mahjong.RuleGroupConfigZhunRu, Mahjong.RuleGroupConfigJieSanFenShu,
            -- Mahjong.RuleGroupConfigZhuoFei, Mahjong.RuleGroupConfigZhuoFeiMin
        }
    },
    YaoJiErRen = {
        name = "幺鸡二人",
        playWayType = Mahjong.PlayWayType.YaoJiErRen,
        playerTotal = 2,
        isGuild = true,
        defaultRuleGroups = {
            Mahjong.RuleConfig.CardTotalThirteen
        },
        ruleGroups = {
            {
                data = Mahjong.RuleGroupConfig.GameTotal,
                rules = {
                    { data = Mahjong.RuleConfig.GameTotalFour,   selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.GameTotalEight,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.GameTotalTwelve, selected = false, interactable = true },
                    --{ data = Mahjong.RuleConfig.GameTotalInfinite, selected = false, interactable = true },
                }
            },
            {
                data = Mahjong.RuleGroupConfig.FangTotal,
                rules = {
                    { data = Mahjong.RuleConfig.FangTotalTwo,   selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.FangTotalThree, selected = true,  interactable = true },
                }
            },
            Mahjong.RuleGroupConfigLimit,
            {
                data = Mahjong.RuleGroupConfig.Change,
                rules = {
                    { data = Mahjong.RuleConfig.ChangeCardTotalThree,         selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeSingle,         selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeArbitrarily,    selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeArbitrarilyMix, selected = false, interactable = true }
                }
            },
            Mahjong.RuleGroupConfigQiHu,
            Mahjong.RuleGroupConfigTingYong,
            {
                data = Mahjong.RuleGroupConfig.PlayWay,
                rules = {
                    { data = Mahjong.RuleConfig.DianGangHuaDianPao, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.DianGangHuaZiMo,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.NormalTianDiHu,     selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.CHongqingTianDiHu,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.NoTianDiHu,         selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.DuiDuiHuLiangFan,   selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.Qth,                selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.QthQj,              selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.Qph,                selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.SanJiBaoXi,         selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.Djkx,               selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.SiJiBaoXi,          selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.MenQing,            selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ZhongZhang,         selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.HaiDi,              selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.JinGouDiao,         selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.YaoJiuJiangDui,     selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.TingPaiTiShi,       selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.Trust,              selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.Gps,                selected = false, interactable = true }
                }
            },
            Mahjong.RuleGroupConfigPay
            --, Mahjong.RuleGroupConfigScore
            -- , Mahjong.RuleGroupConfigZhunRu, Mahjong.RuleGroupConfigJieSanFenShu,
            -- Mahjong.RuleGroupConfigZhuoFei, Mahjong.RuleGroupConfigZhuoFeiMin
        }
    },
    XueZhanDaoDi = {
        name = "血战到底",
        playWayType = Mahjong.PlayWayType.XueZhanDaoDi,
        playerTotal = 4,
        defaultRuleGroups = {
            Mahjong.RuleConfig.FangTotalThree,
            Mahjong.RuleConfig.CardTotalThirteen
        },
        ruleGroups = {
            {
                data = Mahjong.RuleGroupConfig.GameTotal,
                rules = {
                    --{ data = Mahjong.RuleConfig.GameTotalOne, selected = true, interactable = false },
                    { data = Mahjong.RuleConfig.GameTotalFour,  selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.GameTotalEight, selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.Limit,
                rules = {
                    { data = Mahjong.RuleConfig.MultipleThree, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFour,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFive,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleSix,   selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.Change,
                rules = {
                    { data = Mahjong.RuleConfig.ChangeCardTotalThree,         selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTotalFour,          selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeSingle,         selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeArbitrarily,    selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeArbitrarilyMix, selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.PlayWay,
                rules = {
                    { data = Mahjong.RuleConfig.ZiMoJiaFenJiaFan,   selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.ZiMoJiaFenJiaDi,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.DianGangHuaDianPao, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.DianGangHuaZiMo,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.NormalTianDiHu,     selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.CHongqingTianDiHu,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.NoTianDiHu,         selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.YaoJiuJiangDui,     selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MenQingZhongZhang,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.TingPaiTiShi,       selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.Trust,              selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.Gps,                selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.DuiDuiHuLiangFan,   selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.CallConvert,        selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.JiaXinWu,           selected = false, interactable = true },
                }
            },
            Mahjong.RuleGroupConfigPay
            --, Mahjong.RuleGroupConfigScore
            -- , Mahjong.RuleGroupConfigZhunRu, Mahjong.RuleGroupConfigJieSanFenShu,
            -- Mahjong.RuleGroupConfigZhuoFei, Mahjong.RuleGroupConfigZhuoFeiMin
        }
    },
    --XueZhanHuanSanZhang = {
    --    name = "血战换三张",
    --    playWayType = Mahjong.PlayWayType.XueZhanHuanSanZhang,
    --    playerTotal = 4,
    --    defaultRuleGroups = {
    --        Mahjong.RuleConfig.FangTotalThree,
    --        Mahjong.RuleConfig.CardTotalThirteen
    --    },
    --    ruleGroups = {
    --        {
    --            data = Mahjong.RuleGroupConfig.GameTotal,
    --            rules = {
    --                { data = Mahjong.RuleConfig.GameTotalOne, selected = true, interactable = false },
    --                { data = Mahjong.RuleConfig.GameTotalEight, selected = true, interactable = false }
    --            }
    --        },
    --        {
    --            data = Mahjong.RuleGroupConfig.Limit,
    --            rules = {
    --                { data = Mahjong.RuleConfig.MultipleFive, selected = true, interactable = true },
    --                { data = Mahjong.RuleConfig.MultipleSix, selected = false, interactable = true }
    --            }
    --        },
    --        {
    --            data = Mahjong.RuleGroupConfig.Change,
    --            rules = {
    --                { data = Mahjong.RuleConfig.ChangeCardTotalThree, selected = true, interactable = false },
    --                { data = Mahjong.RuleConfig.ChangeCardTypeSingle, selected = true, interactable = false },
    --                { data = Mahjong.RuleConfig.ChangeCardTypeArbitrarily, selected = false, interactable = false },
    --                { data = Mahjong.RuleConfig.ChangeCardTypeArbitrarilyMix, selected = false, interactable = false }
    --            }
    --        },
    --        {
    --            data = Mahjong.RuleGroupConfig.PlayWay,
    --            rules = {
    --                { data = Mahjong.RuleConfig.ZiMoJiaFenJiaFanSingle, selected = true, interactable = false },
    --                { data = Mahjong.RuleConfig.DianGangHuaZiMoSingle, selected = true, interactable = false },
    --                { data = Mahjong.RuleConfig.MenQingZhongZhang, selected = true, interactable = false },
    --                { data = Mahjong.RuleConfig.TianDiHu, selected = true, interactable = false },
    --                { data = Mahjong.RuleConfig.TingPaiTiShi, selected = true, interactable = false },
    --                { data = Mahjong.RuleConfig.Trust, selected = true, interactable = false },
    --                { data = Mahjong.RuleConfig.Gps, selected = false, interactable = true },
    --                { data = Mahjong.RuleConfig.DuiDuiHuLiangFan, selected = false, interactable = true },
    --                { data = Mahjong.RuleConfig.CallConvert, selected = true, interactable = true },
    --                { data = Mahjong.RuleConfig.JiaXinWu, selected = false, interactable = true },
    --            }
    --        },
    --        Mahjong.RuleGroupConfigPay
    --        --, Mahjong.RuleGroupConfigScore
    --        --, Mahjong.RuleGroupConfigZhunRu
    --    }
    --},
    SanRenErFang = {
        name = "三人两房",
        playWayType = Mahjong.PlayWayType.SanRenErFang,
        playerTotal = 3,
        --默认的规则配置，直接使用，且不显示UI
        defaultRuleGroups = {
            Mahjong.RuleConfig.FangTotalTwo,
            Mahjong.RuleConfig.CardTotalThirteen
        },
        ruleGroups = {
            {
                data = Mahjong.RuleGroupConfig.GameTotal,
                rules = {
                    { data = Mahjong.RuleConfig.GameTotalOne,   selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.GameTotalFour,  selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.GameTotalEight, selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.Limit,
                rules = {
                    { data = Mahjong.RuleConfig.MultipleThree, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFour,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFive,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleSix,   selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.PlayWay,
                rules = {
                    { data = Mahjong.RuleConfig.ZiMoJiaFenJiaFan,   selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.ZiMoJiaFenJiaDi,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.DianGangHuaDianPao, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.DianGangHuaZiMo,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.NormalTianDiHu,     selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.CHongqingTianDiHu,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.NoTianDiHu,         selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.YaoJiuJiangDui,     selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MenQingZhongZhang,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.DianPaoPingHu,      selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.DuiDuiHuLiangFan,   selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.JiaXinWu,           selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.TingPaiTiShi,       selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.Trust,              selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.Gps,                selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.CallConvert,        selected = true,  interactable = true },
                }
            },
            Mahjong.RuleGroupConfigPay
            --, Mahjong.RuleGroupConfigScore
            --, Mahjong.RuleGroupConfigZhunRu
        }
    },
    SiRenErFang = {
        name = "四人两房",
        playWayType = Mahjong.PlayWayType.SiRenErFang,
        playerTotal = 4,
        defaultRuleGroups = {
            Mahjong.RuleConfig.FangTotalTwo
        },
        ruleGroups = {
            {
                data = Mahjong.RuleGroupConfig.GameTotal,
                rules = {
                    { data = Mahjong.RuleConfig.GameTotalOne,   selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.GameTotalFour,  selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.GameTotalEight, selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.CardTotal,
                rules = {
                    { data = Mahjong.RuleConfig.CardTotalSeven,    selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.CardTotalTen,      selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.CardTotalThirteen, selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.Limit,
                rules = {

                    { data = Mahjong.RuleConfig.MultipleThree, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFour,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFive,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleSix,   selected = false, interactable = true },
                }
            },
            {
                data = Mahjong.RuleGroupConfig.PlayWay,
                rules = {
                    { data = Mahjong.RuleConfig.ZiMoJiaFenJiaFan,   selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.ZiMoJiaFenJiaDi,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.DianGangHuaDianPao, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.DianGangHuaZiMo,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.NormalTianDiHu,     selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.CHongqingTianDiHu,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.NoTianDiHu,         selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.KaErTiao,           selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.TingPaiTiShi,       selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.Trust,              selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.Gps,                selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.DuiDuiHuLiangFan,   selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.CallConvert,        selected = true,  interactable = true },
                }
            },
            Mahjong.RuleGroupConfigPay
            --, Mahjong.RuleGroupConfigScore
            --, Mahjong.RuleGroupConfigZhunRu
        }
    },
    SanRenSanFang = {
        name = "三人三房",
        playWayType = Mahjong.PlayWayType.SanRenSanFang,
        playerTotal = 3,
        defaultRuleGroups = {
            Mahjong.RuleConfig.FangTotalThree
        },
        ruleGroups = {
            {
                data = Mahjong.RuleGroupConfig.GameTotal,
                rules = {
                    { data = Mahjong.RuleConfig.GameTotalOne,   selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.GameTotalFour,  selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.GameTotalEight, selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.CardTotal,
                rules = {
                    { data = Mahjong.RuleConfig.CardTotalSeven,    selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.CardTotalTen,      selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.CardTotalThirteen, selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.Limit,
                rules = {
                    { data = Mahjong.RuleConfig.MultipleThree, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFour,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFive,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleSix,   selected = false, interactable = true },
                }
            },
            {
                data = Mahjong.RuleGroupConfig.PlayWay,
                rules = {
                    { data = Mahjong.RuleConfig.ZiMoJiaFenJiaFan,   selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.ZiMoJiaFenJiaDi,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.DianGangHuaDianPao, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.DianGangHuaZiMo,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.NormalTianDiHu,     selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.CHongqingTianDiHu,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.NoTianDiHu,         selected = false, interactable = true },

                    --
                    { data = Mahjong.RuleConfig.YaoJiuJiangDui,     selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MenQingZhongZhang,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.DianPaoPingHu,      selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.DuiDuiHuLiangFan,   selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.CallConvert,        selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.TingPaiTiShi,       selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.Trust,              selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.Gps,                selected = false, interactable = true },
                }
            },
            Mahjong.RuleGroupConfigPay
            --, Mahjong.RuleGroupConfigScore
            --, Mahjong.RuleGroupConfigZhunRu
        }
    },
    ErRen = {
        name = "两人麻将",
        playWayType = Mahjong.PlayWayType.ErRen,
        playerTotal = 2,
        defaultRuleGroups = {
            Mahjong.RuleConfig.CardTotalThirteen
        },
        ruleGroups = {
            {
                data = Mahjong.RuleGroupConfig.GameTotal,
                rules = {
                    { data = Mahjong.RuleConfig.GameTotalOne,    selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.GameTotal2Four,  selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.GameTotal2Eight, selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.FangTotal,
                rules = {
                    { data = Mahjong.RuleConfig.FangTotalTwo,   selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.FangTotalThree, selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.Limit,
                rules = {
                    { data = Mahjong.RuleConfig.MultipleThree, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFour,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFive,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleSix,   selected = false, interactable = true },
                }
            },
            {
                data = Mahjong.RuleGroupConfig.Change,
                rules = {
                    { data = Mahjong.RuleConfig.ChangeCardTotalThree,         selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTotalFour,          selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeSingle,         selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeArbitrarily,    selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ChangeCardTypeArbitrarilyMix, selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.PlayWay,
                rules = {
                    { data = Mahjong.RuleConfig.ZiMoJiaFenJiaFan,   selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.ZiMoJiaFenJiaDi,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.DianGangHuaDianPao, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.DianGangHuaZiMo,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.NormalTianDiHu,     selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.CHongqingTianDiHu,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.NoTianDiHu,         selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.YaoJiu,             selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.JiangDui,           selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MenQing,            selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ZhongZhang,         selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.LiangFenQiHu,       selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.DuiDuiHuLiangFan,   selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.CallConvert,        selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.TingPaiTiShi,       selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.Trust,              selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.Gps,                selected = false, interactable = true },

                }
            },
            Mahjong.RuleGroupConfigPay
            --, Mahjong.RuleGroupConfigScore
            --, Mahjong.RuleGroupConfigZhunRu
        }
    },
    ErRenYiFang = {
        name = "两人一房",
        playWayType = Mahjong.PlayWayType.ErRenYiFang,
        playerTotal = 2,
        defaultRuleGroups = {
            Mahjong.RuleConfig.CardTotalSeven,
            Mahjong.RuleConfig.FangTotalOne
        },
        ruleGroups = {
            {
                data = Mahjong.RuleGroupConfig.GameTotal,
                rules = {
                    { data = Mahjong.RuleConfig.GameTotalOne,    selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.GameTotal2Four,  selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.GameTotal2Eight, selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.Limit,
                rules = {
                    { data = Mahjong.RuleConfig.MultipleThree, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFour,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFive,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleSix,   selected = false, interactable = true },
                }
            },
            {
                data = Mahjong.RuleGroupConfig.PlayWay,
                rules = {
                    { data = Mahjong.RuleConfig.ZiMoJiaFenJiaFan,   selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.ZiMoJiaFenJiaDi,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.DianGangHuaDianPao, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.DianGangHuaZiMo,    selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.NormalTianDiHu,     selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.CHongqingTianDiHu,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.NoTianDiHu,         selected = false, interactable = true },
                    --
                    { data = Mahjong.RuleConfig.YaoJiu,             selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.JiangDui,           selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.QingYiSe0,          selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.QingYiSe1,          selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.QingYiSe2,          selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MenQing,            selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ZhongZhang,         selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.LiangFenQiHu,       selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.DuiDuiHuLiangFan,   selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.FourDuiHu7Dui,      selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.CallConvert,        selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.TingPaiTiShi,       selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.Trust,              selected = true,  interactable = false },
                    { data = Mahjong.RuleConfig.Gps,                selected = false, interactable = true },
                }
            },
            Mahjong.RuleGroupConfigPay
            --, Mahjong.RuleGroupConfigScore
            --, Mahjong.RuleGroupConfigZhunRu
        }
    },
    FlyChicken = {
        name = "飞小鸡",
        playWayType = Mahjong.PlayWayType.FlyChicken,
        playerTotal = 2,
        defaultRuleGroups = {
            Mahjong.RuleConfig.FangTotalThree,
            Mahjong.RuleConfig.CardTotalThirteen
        },
        ruleGroups = {
            {
                data = Mahjong.RuleGroupConfig.PeopleCount,
                rules = {
                    { data = Mahjong.RuleConfig.PeopleCount2, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.PeopleCount4, selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.GameTotal,
                rules = {
                    { data = Mahjong.RuleConfig.GameTotal2Four,  selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.GameTotal2Eight, selected = false, interactable = true }
                }
            },
            {
                data = Mahjong.RuleGroupConfig.Limit,
                rules = {
                    { data = Mahjong.RuleConfig.MultipleThree, selected = true,  interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFour,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleFive,  selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.MultipleSix,   selected = false, interactable = true },
                }
            },
            {
                data = Mahjong.RuleGroupConfig.PlayWay,
                rules = {
                    { data = Mahjong.RuleConfig.EatCard,      selected = false, interactable = true },
                    { data = Mahjong.RuleConfig.ClickChicken, selected = false, interactable = false },
                    { data = Mahjong.RuleConfig.RaisePig,     selected = false, interactable = false },
                }
            },
            --Mahjong.RuleGroupConfigPay
            --, Mahjong.RuleGroupConfigScore
            --, Mahjong.RuleGroupConfigZhunRu
        }
    },
}

--创建房间配置
Mahjong.CreateRoomConfig = {
    Mahjong.PlayWayConfig.YaoJiSiRen,
    Mahjong.PlayWayConfig.YaoJiSanRen,
    Mahjong.PlayWayConfig.YaoJiErRen,
    Mahjong.PlayWayConfig.XueZhanDaoDi,
    --Mahjong.PlayWayConfig.XueZhanHuanSanZhang,
    Mahjong.PlayWayConfig.SanRenErFang,
    Mahjong.PlayWayConfig.SiRenErFang,
    Mahjong.PlayWayConfig.SanRenSanFang,
    Mahjong.PlayWayConfig.ErRen,
    Mahjong.PlayWayConfig.ErRenYiFang,
    Mahjong.PlayWayConfig.FlyChicken,
}

--================================================================
--
--消费配置
Mahjong.ConsumeConfig = {
    [Mahjong.PlayWayType.YaoJiSiRen] = { [4] = 10001, [8] = 10002, [12] = 10003 },
    [Mahjong.PlayWayType.YaoJiSanRen] = { [4] = 10001, [8] = 10002, [12] = 10003 },
    [Mahjong.PlayWayType.YaoJiErRen] = { [4] = 10001, [8] = 10002, [12] = 10003 },
    --
    [Mahjong.PlayWayType.XueZhanDaoDi] = { [4] = 10004, [8] = 10005 },
    --[Mahjong.PlayWayType.XueZhanHuanSanZhang] = { [4] = 10004, [8] = 10005 },
    [Mahjong.PlayWayType.SanRenErFang] = { [4] = 10004, [8] = 10005 },
    [Mahjong.PlayWayType.SiRenErFang] = { [4] = 10004, [8] = 10005 },
    [Mahjong.PlayWayType.SanRenSanFang] = { [4] = 10004, [8] = 10005 },
    --
    [Mahjong.PlayWayType.ErRen] = { [4] = 10006, [8] = 10007 },
    [Mahjong.PlayWayType.ErRenYiFang] = { [4] = 10006, [8] = 10007 },

    [Mahjong.PlayWayType.FlyChicken] = { [4] = 10001, [8] = 10002, [12] = 10003 },
}

--获取消费ID
function Mahjong.GetConsumeConfigId(playWayType, gameTotal)
    local id = 0

    local temp = Mahjong.ConsumeConfig[playWayType]
    if temp ~= nil then
        local tempConfig = temp[gameTotal]
        if tempConfig ~= nil then
            id = tempConfig
        end
    end
    return id
end

--底分配置,0.2   0.5  1  2  3  4  5  6  10  20
Mahjong.DiFenConfig = {0.1, 0.2, 0.5, 1, 2, 3, 4, 5, 6, 10, 20 }
--底分配置，用于Dropdown列表
Mahjong.DiFenNameConfig = {"0.1", "0.2分", "0.5分", "1分", "2分", "3分", "4分", "5分", "6分", "10分", "20分" }

--准入配置
Mahjong.MinScoreConfig = {
    [Mahjong.PlayWayType.YaoJiSiRen] = {
        { score = 50,  min = 3500 },
        { score = 100, min = 7000 },
        { score = 200, min = 24000 },
        { score = 300, min = 36000 },
        { score = 500, min = 60000 }
    },
    [Mahjong.PlayWayType.YaoJiSanRen] = {
        { score = 50,  min = 5000 },
        { score = 100, min = 9000 },
        { score = 200, min = 18000 },
        { score = 300, min = 36000 },
        { score = 500, min = 60000 }
    },
    [Mahjong.PlayWayType.YaoJiErRen] = {
        { score = 50,  min = 4100 },
        { score = 100, min = 8100 },
        { score = 200, min = 12000 },
        { score = 300, min = 36000 },
        { score = 500, min = 60000 }
    },
}

--获取准入
function Mahjong.GetMinScore(playWayType, score)
    local result = 0
    local scoreConfig = Mahjong.MinScoreConfig[playWayType]
    if scoreConfig ~= nil then
        local temp = nil
        for i = 1, #scoreConfig do
            temp = scoreConfig[i]
            if temp.score == score then
                result = temp.min
                break
            end
        end
    end
    return result
end

--================================================================
--
--规则排序配置
Mahjong.RuleSortConfig = {
    --Mahjong.RuleType.GameTotal,单独处理
    Mahjong.RuleType.CardTotal,
    Mahjong.RuleType.FangTotal,
    Mahjong.RuleType.Multiple,--包含自定义需要特殊处理
    Mahjong.RuleType.ChangeCardTotal,
    Mahjong.RuleType.ChangeCardType,
    Mahjong.RuleType.TingTotal,
    Mahjong.RuleType.HuMinFan,--包含自定义需要特殊处理
    --
    Mahjong.RuleType.ZiMoJiaFen,
    Mahjong.RuleType.DianGangHua,
    Mahjong.RuleType.MenQing,
    Mahjong.RuleType.ZhongZhang,
    Mahjong.RuleType.MenQingZhongZhang,
    Mahjong.RuleType.YaoJiu,
    Mahjong.RuleType.JiangDui,
    Mahjong.RuleType.YaoJiuJiangDui,
    Mahjong.RuleType.TianDiHu,
    Mahjong.RuleType.QingYiSe,
    Mahjong.RuleType.HaiDi,
    Mahjong.RuleType.JinGouDiao,
    Mahjong.RuleType.DuiDuiHuLiangFan,
    Mahjong.RuleType.JiaXinWu,
    Mahjong.RuleType.KaErTiao,
    Mahjong.RuleType.CallConvert,
    --
    Mahjong.RuleType.LiangFenQiHu,
    Mahjong.RuleType.SanFanQiHu,
    Mahjong.RuleType.LiangFanQiHu,
    Mahjong.RuleType.SiFanQiHu,
    Mahjong.RuleType.FanShuQiHu,
    Mahjong.RuleType.FourDuiHu7Dui,
    Mahjong.RuleType.QTH,
    Mahjong.RuleType.QPH,
    Mahjong.RuleType.QTHQJ,
    --
    Mahjong.RuleType.DianPaoPingHu,
    Mahjong.RuleType.SanJiBaoXi,
    Mahjong.RuleType.DJKX,
    Mahjong.RuleType.SiJiBaoXi,
    Mahjong.RuleType.FlyChickenPeopleCount,
    Mahjong.RuleType.EatCard,
    Mahjong.RuleType.ClickChicken,
    Mahjong.RuleType.RaisePig,
    --
    Mahjong.RuleType.TingPaiTiShi,
    Mahjong.RuleType.Gps,
    -- Mahjong.RuleType.ZhuoFei,
    -- Mahjong.RuleType.ZhuoFeiMin,
    --Mahjong.RuleType.ZhunRu,
    --Mahjong.RuleType.JieSanFenShu,
    --
    Mahjong.RuleType.Pay,
}

--玩法规则映射配置，每一个玩法都有相应的映射配置数据
--处理解析等使用
Mahjong.PlayWayRuleMappingConfig = {}

--获取玩法的规则映射配置
function Mahjong.GetPlayWayRuleMappingConfig(playWayType)
    local result = Mahjong.PlayWayRuleMappingConfig[playWayType]
    if result == nil then
        result = Mahjong.HandlePlayWayRuleMappingConfig(playWayType)
    end
    return result
end

--处理玩法规则映射配置
function Mahjong.HandlePlayWayRuleMappingConfig(playWayType)
    local createRoomConfigData = nil
    local length = #Mahjong.CreateRoomConfig
    for i = 1, length do
        if Mahjong.CreateRoomConfig[i].playWayType == playWayType then
            createRoomConfigData = Mahjong.CreateRoomConfig[i]
            break
        end
    end
    if createRoomConfigData == nil then
        createRoomConfigData = Mahjong.CreateRoomConfig[1]
    end

    local mappingConfig = {}
    Mahjong.PlayWayRuleMappingConfig[playWayType] = mappingConfig

    local temp = nil
    local tempLength = nil

    --处理defaultRuleGroups
    --length = #createRoomConfigData.defaultRuleGroups
    --for i = 1, length do
    --    temp = createRoomConfigData.defaultRuleGroups[i]
    --    Mahjong.AddMappingRuleConfigData(mappingConfig, temp.type, temp)
    --end
    --处理ruleGroups
    length = #createRoomConfigData.ruleGroups
    local rulesData = nil
    for i = 1, length do
        temp = createRoomConfigData.ruleGroups[i]
        tempLength = #temp.rules
        for j = 1, tempLength do
            rulesData = temp.rules[j]
            if rulesData.data ~= nil then
                Mahjong.AddMappingRuleConfigData(mappingConfig, rulesData.data.type, rulesData.data)
            end
        end
    end
    return mappingConfig
end

--添加玩法规则映射配置的规则数据
function Mahjong.AddMappingRuleConfigData(mappingConfig, ruleType, ruleData)
    local mappingRules = mappingConfig[ruleType]
    if mappingRules == nil then
        mappingRules = {}
        mappingConfig[ruleType] = mappingRules
    end
    --处理自定义
    if ruleData.dataType == 1 then
        mappingRules[0] = ruleData
    else
        mappingRules[ruleData.value] = ruleData
    end
end

--获取映射的规则配置数据
function Mahjong.GetMappingRuleConfigData(mappingConfig, type, value)
    local mappingRules = mappingConfig[type]
    if mappingRules ~= nil and value ~= nil then
        local temp = mappingRules[value]
        if temp == nil then
            return mappingRules[0]
        else
            return temp
        end
    else
        return nil
    end
end

--获取玩法名称
function Mahjong.GetPlayWayName(ruleObj)
    local playWayType = ruleObj[Mahjong.RuleType.PlayWayType]
    --两人一房使用的是两人的类型，所有需要特殊处理
    if playWayType == Mahjong.PlayWayType.ErRen then
        local fangShu = ruleObj[Mahjong.RuleType.FangTotal]
        if fangShu == 1 then
            playWayType = Mahjong.PlayWayType.ErRenYiFang
        end
    end

    local tingYongNum = ruleObj[Mahjong.RuleType.TingTotal]
    if tingYongNum ~= nil and tingYongNum >= 8 then
        return Mahjong.CheckYaoJiName(tingYongNum, playWayType)
    end
    return Mahjong.PlayWayNames[playWayType]
end

--
function Mahjong.CheckYaoJiName(tingYongNum, playWayType)
    local name = "麻将"
    if playWayType == Mahjong.PlayWayType.YaoJiSiRen then
        name = "四人"
    elseif playWayType == Mahjong.PlayWayType.YaoJiSanRen then
        name = "三人"
    elseif playWayType == Mahjong.PlayWayType.YaoJiErRen then
        name = "二人"
    end

    return tingYongNum .. "鸡" .. name
end

--
function Mahjong.GetPlaywayTypeByName(name)
    local tempConfig = nil
    for i = 1, #Mahjong.CreateRoomConfig do
        tempConfig = Mahjong.CreateRoomConfig[i]
        if tempConfig.name == name then
            return tempConfig.playWayType
        end
    end
    return 0
end

local tempIsFirst = true
--拼接规则字符串
function Mahjong.JointRuleString(separator, str, name)
    if tempIsFirst then
        tempIsFirst = false
        str = str .. name
    else
        str = str .. separator .. name
    end
    return str
end

--解析麻将规则数据
--例如： {"DGH":0,"NP":1,"NGT":4,"JGD":1,"NCC":0,"MQ":1,"ZZ":1,"NPT":4,"NB":0,"NFT":3,"NCCT":3,"NM":3,"NCT":13,"TDH":1,"NDQ":1,"HD":1,"NPWT":7}
function Mahjong.ParseMahjongRule(ruleObj, gps, separator, bdPer)
    if string.IsNullOrEmpty(separator) then
        separator = " "
    end
    if gps ~= nil then
        ruleObj[Mahjong.RuleType.Gps] = gps
    -- else
    --     ruleObj[Mahjong.RuleType.Gps] = nil
    end

    local playWayName = ""
    local PlayWayType = 0
    local juShu = 0
    local juShuTxt = ""
    local juShuTips = ""
    local ruleStr = ""
    local cards = 0 --房卡
    local score = 0
    local multiple = "2番"
    local totalUserNum = 0
    local fanShuQiHu = nil

    if IsTable(ruleObj) then
        local playWayType = ruleObj[Mahjong.RuleType.PlayWayType]
        PlayWayType = playWayType
        --两人一房使用的是两人的类型，所有需要特殊处理
        if playWayType == Mahjong.PlayWayType.ErRen then
            local fangShu = ruleObj[Mahjong.RuleType.FangTotal]
            if fangShu == 1 then
                playWayType = Mahjong.PlayWayType.ErRenYiFang
            end
        end

        --映射配置
        local mappingConfig = Mahjong.GetPlayWayRuleMappingConfig(playWayType)
        --玩法名称
        playWayName = Mahjong.PlayWayNames[playWayType]
        --临时变量定义
        local ruleType = nil
        local ruleValue = nil
        local ruleConfigData = nil
        --局数相关
        ruleType = Mahjong.RuleType.GameTotal
        ruleValue = ruleObj[ruleType]
        ruleConfigData = Mahjong.GetMappingRuleConfigData(mappingConfig, ruleType, ruleValue)
        if ruleConfigData ~= nil then
            juShu = ruleConfigData.value
            cards = ruleConfigData.cards
            juShuTxt = ruleConfigData.name
            juShuTips = ruleConfigData.tips
        end
        --处理换张，没有换张选项就没有换张类型
        local temp = ruleObj[Mahjong.RuleType.ChangeCardTotal]
        if temp == nil or temp == 0 then
            ruleObj[Mahjong.RuleType.ChangeCardType] = nil
        end
        --
        if ruleObj[Mahjong.RuleType.Score] ~= nil then
            score = ruleObj[Mahjong.RuleType.Score]
        end

        totalUserNum = ruleObj[Mahjong.RuleType.PlayerTotal]

        --其他规则
        tempIsFirst = true
        local length = #Mahjong.RuleSortConfig
        for i = 1, length do
            ruleType = Mahjong.RuleSortConfig[i]
            ruleValue = ruleObj[ruleType]
            if ruleValue ~= nil then
                --处理自定义字段，由于有顺序问题，所以在这里处理
                if ruleType == Mahjong.RuleType.Multiple then
                    multiple = ruleValue .. "番"
                    ruleStr = Mahjong.JointRuleString(separator, ruleStr, multiple)
                elseif ruleType == Mahjong.RuleType.HuMinFan then
                    fanShuQiHu = ruleValue .. "番起胡"
                    ruleStr = Mahjong.JointRuleString(separator, ruleStr, fanShuQiHu)
                else
                    ruleConfigData = Mahjong.GetMappingRuleConfigData(mappingConfig, ruleType, ruleValue)
                    if ruleConfigData ~= nil then
                        ruleStr = Mahjong.JointRuleString(separator, ruleStr, ruleConfigData.name)
                    end
                end
            end
        end

        --处理自定义的字段
        temp = ruleObj[Mahjong.RuleType.ZhunRu]
        if temp ~= nil then
            ruleStr = Mahjong.JointRuleString(separator, ruleStr, GetS("%s(%s)", Mahjong.RuleConfig.ZhunRu0.name, temp))
        end
        temp = ruleObj[Mahjong.RuleType.JieSanFenShu]
        if temp ~= nil then
            ruleStr = Mahjong.JointRuleString(separator, ruleStr, GetS("%s(%s)", Mahjong.RuleConfig.JieSanFenShu0.name, temp))
        end
        -- temp = ruleObj[Mahjong.RuleType.ZhuoFei]
        -- if temp ~= nil then
        --     rule = rule .. separator .. Mahjong.RuleConfig.ZhuoFei0.name .. "(" .. temp .. ")"
        -- end
        -- temp = ruleObj[Mahjong.RuleType.ZhuoFeiMin]
        -- if temp ~= nil then
        --     rule = rule .. separator .. Mahjong.RuleConfig.ZhuoFeiMin0.name .. "(" .. temp .. ")"
        -- end
        --番数处理
        temp = ruleObj[Mahjong.RuleType.LiangFenQiHu]
        if temp ~= nil and temp == 1 then
            fanShuQiHu = Mahjong.RuleConfig.LiangFenQiHu.name
        end
        if fanShuQiHu == nil then
            temp = ruleObj[Mahjong.RuleType.LiangFanQiHu]
            if temp ~= nil and temp == 1 then
                fanShuQiHu = Mahjong.RuleConfig.LiangFanQiHu.name
            end
        end
        if fanShuQiHu == nil then
            temp = ruleObj[Mahjong.RuleType.SanFanQiHu]
            if temp ~= nil and temp == 1 then
                fanShuQiHu = Mahjong.RuleConfig.SanFanQiHu.name
            end
        end
        if fanShuQiHu == nil then
            temp = ruleObj[Mahjong.RuleType.SiFanQiHu]
            if temp ~= nil and temp == 1 then
                fanShuQiHu = Mahjong.RuleConfig.SiFanQiHu.name
            end
        end

        if UnionData.IsUnionLeader() then
            temp = ruleObj[Mahjong.RuleType.KeepBaseNum]
            local symbol = bdPer == 0 and "分" or "%"
            if temp ~= nil then
                ruleStr = Mahjong.JointRuleString(separator, ruleStr, "保底" .. temp .. symbol)
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
        rule = ruleStr,
        cards = cards,
        baseScore = score,
        multiple = multiple,
        userNum = totalUserNum,
        fanShuQiHu = fanShuQiHu,
    }
end

--================================================================
