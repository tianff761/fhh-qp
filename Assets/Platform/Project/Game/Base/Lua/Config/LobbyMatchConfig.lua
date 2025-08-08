--游戏列表顺序配置
MatchConfigTable = {
    YiBinSiRen = 5,
    YiBinErRen = 6,
    GongXianSanRen = 7,
    NeiJiangSanRen = 8,
    NeiJiangErRen = 9,
}


local MatchRulese = {
   
}

MatchEtc = {
    NeiJiang3Ren = 3,
    NeiJiang2Ren = 4,
}

ChangCi = {
    TiYan = 1, --体验场
    RuMen = 2, --入门
    XinShou = 3, --新手
    PingMin = 4, --平民
    GuanJia = 5, --官甲
    TuHao = 6, --土豪
    GuanShang = 7, --官商
    ZunJue = 8, --尊爵
}

--匹配场配置
MatchConfigData = {
}

--游戏屏蔽映射 对应 MatchConfigData 的index
SheildGameMap = {
    [MatchConfigTable.YiBinSiRen] = 102,
    [MatchConfigTable.NeiJiangSanRen] = 103,
    [MatchConfigTable.NeiJiangErRen] = 104,
    [MatchConfigTable.YiBinErRen] = 105,
    [MatchConfigTable.GongXianSanRen] = 106,
}

ChangCiTxt = {
    [ChangCi.TiYan] = "体验场",
    [ChangCi.RuMen] = "入门场",
    [ChangCi.XinShou] = "新手场",
    [ChangCi.PingMin] = "平民场",
    [ChangCi.GuanJia] = "官甲场",
    [ChangCi.TuHao] = "土豪场",
    [ChangCi.GuanShang] = "管商场",
    [ChangCi.ZunJue] = "尊爵场",
}