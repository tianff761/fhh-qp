TpConfig = {}

--牌数据的字典
TpConfig.CardDataDict = {}

-- 皇家同花顺＞同花顺＞四条＞葫芦（3带2）＞同花＞顺子＞三条＞两队＞一对＞单张
--牌型类型
TpConfig.PX = {
    None            = 0,
    Single          = 1,
    Pair            = 2,
    Two_Pair        = 3,
    Three           = 4,
    Shun            = 5,
    Same_Color      = 6,
    Hulu            = 7,
    Bomb            = 8,
    Same_Color_Shun = 9,
    King_Color_Shun = 10,
}

--牌型文本
TpConfig.PX_TXT = {
    [TpConfig.PX.None] = "",
    [TpConfig.PX.Single] = "单张",
    [TpConfig.PX.Pair] = "对子",
    [TpConfig.PX.Two_Pair] = "两对",
    [TpConfig.PX.Three] = "三条",
    [TpConfig.PX.Shun] = "顺子",
    [TpConfig.PX.Same_Color] = "同花",
    [TpConfig.PX.Hulu] = "葫芦",
    [TpConfig.PX.Bomb] = "四条",
    [TpConfig.PX.Same_Color_Shun] = "同花顺",
    [TpConfig.PX.King_Color_Shun] = "皇家同花顺",
}

--玩法类型
TpPlayWayType = {
    --玩法1
    PlayWay1 = 1,
}

--规则组配置类型，客户端使用
TpRuleGroupType = {
    --规则
    Rule = 1,
    --局数
    GameTotal = 2,
    --人数
    PlayerTotal = 3,
    --满几人开
    StartTotal = 4,
    --小盲
    XiaoMang = 5,
    --大芒
    DaMang = 6,
    --前注
    QianZhu = 7,
    --封顶
    Limit = 8,
    --玩法
    PlayWay = 9,
    --支付
    Pay = 20,
    --底分
    Score = 21,
    --准入
    ZhunRu = 22,
    --桌费
    ZhuoFei = 23,
    --桌费最小值
    ZhuoFeiMin = 24,
    --解散分数
    JieSanFenShu = 25,
}


--规则类型
TpRuleType = {
    --玩法类型
    PlayWayType = "WF",
    --游戏局数，4四局、8八局、12十二局
    GameTotal = "NGT",
    --人数，6人，7人，8人，9人
    PlayerTotal = "MAX_NUM",
    --满开
    StartTotal = "START_NUM",
    --小盲
    XiaoMang = "xm",
    --大盲
    DaMang = "dm",
    --前注
    QianZhu = "qz",

    --封顶
    Limit = "fd",
    --支付方式，0无、1房主支付、2AA制支付、3俱乐部支付、4大赢家付
    Pay = "NP",
    --房间类型
    RoomType = "CRT",
    --规则key
    Key = "KEY",

    --Gps选项
    Gps = "GP",
    --金豆准入
    ZhunRu = "ZR",
    --底分
    DiFen = "BS",
    --桌费
    ZhuoFei = "ZF",
    --桌费最小值
    ZhuoFeiMin = "MZF",
    --解散分数
    JieSanFenShu = "JSFS",
    ---表情比例
    ExpressionPercent = "expressionNum",
    ---保底
    KeepBaseNum = "keepBaseNum",
}


--玩法规则配置，如果是复选框，选中则使用Value值，否则使用0，单选框则使用相应的Value值
TpConfig.RuleConfig = {
    --局数
    GameTotal8 = { name = "8局", type = TpRuleType.GameTotal, value = 8, group = 1 },
    GameTotal16 = { name = "16局", type = TpRuleType.GameTotal, value = 16, group = 1 },
    GameTotal24 = { name = "24局", type = TpRuleType.GameTotal, value = 24, group = 1 },

    --人数
    PlayerTotal6 = { name = "6人", type = TpRuleType.PlayerTotal, value = 6, group = 2 },
    PlayerTotal7 = { name = "7人", type = TpRuleType.PlayerTotal, value = 7, group = 2 },
    PlayerTotal8 = { name = "8人", type = TpRuleType.PlayerTotal, value = 8, group = 2 },
    PlayerTotal9 = { name = "9人", type = TpRuleType.PlayerTotal, value = 9, group = 2 },

    --满几人开
    StartTotal3 = { name = "满3人开", type = TpRuleType.StartTotal, value = 3, group = 3 },
    StartTotal4 = { name = "满4人开", type = TpRuleType.StartTotal, value = 4, group = 3 },
    StartTotal5 = { name = "满5人开", type = TpRuleType.StartTotal, value = 5, group = 3 },

    --dataType表示数据类型，0表示自定义，需要的时候需要特殊处理，比如解析规则时过滤处理
    --前注itemType = 2表示自定义输入
    QianZhu0 = { dataType = 0, name = "自定义", type = TpRuleType.QianZhu, value = 1, itemType = 2, group = 0 },

    --不封顶
    Limit50 = { name = "50倍", ruleTxt = "50倍封顶", type = TpRuleType.Limit, value = 50, group = 5 },
    Limit100 = { name = "100倍", ruleTxt = "100倍封顶", type = TpRuleType.Limit, value = 100, group = 5 },
    Limit200 = { name = "200倍", ruleTxt = "200倍封顶", type = TpRuleType.Limit, value = 200, group = 5 },
    Limit500 = { name = "500倍", ruleTxt = "500倍封顶", type = TpRuleType.Limit, value = 500, group = 5 },
    Limit0 = { name = "不封顶", type = TpRuleType.Limit, value = 0, group = 5 },

    --支付方式
    PayOwner = { name = "房主付", type = TpRuleType.Pay, value = 1, group = 8 },
    PayAA = { name = "AA制付", type = TpRuleType.Pay, value = 2, group = 8 },
    PayClub = { name = "俱乐部付", type = TpRuleType.Pay, value = 3, group = 8 },
    PayWinner = { name = "大赢家付", type = TpRuleType.Pay, value = 4, group = 8 },

    --客户端特殊处理，分数娱乐场分数
    Score0 = { name = "底分", desc = "自定义", type = TpRuleType.DiFen, value = 0, group = 11 },
}



--规则组配置
TpConfig.RuleGroupConfig = {
    --规则
    Rule = {
        name = "规则：",
        sprite = "",
        type = TpRuleGroupType.Rule,
    },
    GameTotal = {
        name = "局数：",
        sprite = "",
        type = TpRuleGroupType.GameTotal,
    },
    PlayerTotal = {
        name = "人数：",
        sprite = "",
        type = TpRuleGroupType.PlayerTotal,
    },
    StartTotal = {
        name = "满开：",
        sprite = "",
        type = TpRuleGroupType.StartTotal,
    },
    XiaoMang = {
        name = "小盲：",
        sprite = "",
        type = TpRuleGroupType.MangGuo,
    },
    QianZhu = {
        name = "前注：",
        sprite = "",
        type = TpRuleGroupType.QianZhu,
    },
    Limit = {
        name = "封顶：",
        sprite = "",
        type = TpRuleGroupType.Limit,
    },
    PlayWay = {
        name = "玩法",
        sprite = "",
        type = TpRuleGroupType.PlayWay,
    },
    Pay = {
        name = "支付：",
        sprite = "Pay",
        type = TpRuleGroupType.Pay,
    },
    Score = {
        name = "底分：",
        sprite = "Score",
        type = TpRuleGroupType.Score,
    },
    ZhunRu = {
        name = "准入：",
        sprite = "ZhuRu",
        type = TpRuleGroupType.ZhunRu,
    },
    ZhuoFei = {
        name = "表情赠送：",
        sprite = "ZhuoFei",
        type = TpRuleGroupType.ZhuoFei,
    },
    ZhuoFeiMin = {
        name = "最低赠送：",
        sprite = "ZhuoFeiMin",
        type = TpRuleGroupType.ZhuoFeiMin,
    },
    JieSanFenShu = {
        name = "解散分数：",
        sprite = "JieSanFenShu",
        type = TpRuleGroupType.JieSanFenShu,
    }
}

--玩法名称
TpConfig.PlayWayNameDict = {
    [TpPlayWayType.PlayWay1] = "德州",
}

--玩法配置
TpConfig.PlayWayConfig = {
    {
        name = "精简模式",
        type = TpPlayWayType.PlayWay1,
        ruleGroups = {
            {
                data = TpConfig.RuleGroupConfig.GameTotal,
                rules = {
                    { data = TpConfig.RuleConfig.GameTotal8, selected = true, interactable = true },
                    { data = TpConfig.RuleConfig.GameTotal16, selected = false, interactable = true },
                    { data = TpConfig.RuleConfig.GameTotal24, selected = false, interactable = true },
                }
            },
            {
                data = TpConfig.RuleGroupConfig.PlayerTotal,
                rules = {
                    { data = TpConfig.RuleConfig.PlayerTotal6, selected = false, interactable = true },
                    { data = TpConfig.RuleConfig.PlayerTotal7, selected = false, interactable = true },
                    { data = TpConfig.RuleConfig.PlayerTotal8, selected = false, interactable = true },
                    { data = TpConfig.RuleConfig.PlayerTotal9, selected = true, interactable = true },
                }
            },
            {
                data = TpConfig.RuleGroupConfig.StartTotal,
                rules = {
                    { data = TpConfig.RuleConfig.StartTotal3, selected = true, interactable = true },
                    { data = TpConfig.RuleConfig.StartTotal4, selected = false, interactable = true },
                    { data = TpConfig.RuleConfig.StartTotal5, selected = false, interactable = true },
                }
            },
            {
                data = TpConfig.RuleGroupConfig.QianZhu,
                rules = {
                    { data = TpConfig.RuleConfig.QianZhu0, selected = true, interactable = true },
                }
            },
            {
                data = TpConfig.RuleGroupConfig.Limit,
                rules = {
                    { data = TpConfig.RuleConfig.Limit50, selected = true, interactable = true },
                    { data = TpConfig.RuleConfig.Limit100, selected = false, interactable = true },
                    { data = TpConfig.RuleConfig.Limit200, selected = false, interactable = true },
                    { data = TpConfig.RuleConfig.Limit500, selected = false, interactable = true },
                    { data = TpConfig.RuleConfig.Limit0, selected = false, interactable = true },
                }
            },
        }
    }
}

function TpConfig.GetPlaywayTypeByName(name)
    for key, value in pairs(TpConfig.PlayWayNameDict) do
        if value == name then
            return key
        end
    end
    return 0
end

--获取玩法名称
function TpConfig.GetPlayWayName(playWayType)
    return TpConfig.PlayWayNameDict[playWayType] or ""
end

--获取玩法名称
function TpConfig.GetPlayWayNameByRule(ruleObj)
    local playWayType = ruleObj[TpRuleType.PlayWayType] or TpPlayWayType.PlayWay1
    return TpConfig.GetPlayWayName(playWayType)
end

--获取前注
function TpConfig.GetQianZhuByRule(ruleObj)
    return ruleObj[TpRuleType.QianZhu] or 1
end

--获取牌型名称
function TpConfig.GetPokerTypeName(type)
    if type ~= nil then
        return TpConfig.PX_TXT[type] or ""
    else
        return ""
    end
end

--获取牌的资源名称，由于TP使用的ID不一样，需要转换，转换方式跟TpCardData一致
function TpConfig.GetPokerResName(id)
    local data = TpConfig.CardDataDict[id]
    if data == nil then
        data = {}
        TpConfig.CardDataDict[id] = data
        data.id = id
        data.key = math.floor(id / 10)
        data.type = id % 10
        --处理资源名称Key
        local temp = data.key
        if data.key == 14 then
            temp = 1
        end
        data.resKey = temp * 100 + (data.type + 1)--服务器是0-3，客户端是1-4
    end
    return data.resKey
end


--================================================================
--
--规则排序配置
TpConfig.RuleSortConfig = {
    --
    --TpRuleType.GameTotal,
    TpRuleType.PlayerTotal,
    TpRuleType.StartTotal,
    TpRuleType.QianZhu,
    TpRuleType.Limit,
    --
    TpRuleType.Gps,
    --
    --TpRuleType.Pay,
}

--规则配置的映射处理
TpConfig.RuleConfigDict = nil

--检测处理规则映射
function TpConfig.CheckHandleRuleConfig()
    if TpConfig.RuleConfigDict == nil then
        TpConfig.RuleConfigDict = {}
        local ruleDict = nil
        for k, v in pairs(TpConfig.RuleConfig) do
            if v.dataType ~= 0 then
                ruleDict = TpConfig.RuleConfigDict[v.type]
                if ruleDict == nil then
                    ruleDict = {}
                    TpConfig.RuleConfigDict[v.type] = ruleDict
                end
                ruleDict[v.value] = v
            end
        end
    end
end

--检测处理规则映射
function TpConfig.GetRuleConfigData(type, value)
    if TpConfig.RuleConfigDict ~= nil then
        local ruleDict = TpConfig.RuleConfigDict[type]
        if ruleDict ~= nil then
            return ruleDict[value]
        end
    end
    return nil
end

--返回前注字符串
function TpConfig.GetQianZhuStr(ruleObj)
    local result = ruleObj[TpRuleType.QianZhu] or 0
    result = "前注:" .. result
    return result
end


--拼接规则字符串
function TpConfig.JointRuleString(separator, str, name)
    if str == nil then
        str = name
    else
        str = str .. separator .. name
    end
    return str
end

--解析规则文本
function TpConfig.ParseTpRule(ruleObj, gps, separator, bdPer)
    if string.IsNullOrEmpty(separator) then
        separator = " "
    end
    if gps ~= nil then
        ruleObj[TpRuleType.Gps] = gps
    end

    local playWayName = ""
    local playWayType = 0
    local juShu = 0
    local juShuTxt = ""
    local juShuTips = ""
    local ruleStr = nil
    local cardNum = 0 --房卡
    local score = 0
    local totalUserNum = 0

    if IsTable(ruleObj) then
        TpConfig.CheckHandleRuleConfig()
        --
        playWayType = ruleObj[TpRuleType.PlayWayType] or TpPlayWayType.PlayWay1
        playWayName = TpConfig.GetPlayWayName(playWayType)
        totalUserNum = ruleObj[TpRuleType.PlayerTotal]
        juShu = ruleObj[TpRuleType.GameTotal]
        juShuTxt = juShu .. "局"
        juShuTips = juShuTxt
        if ruleObj[TpRuleType.Score] ~= nil then
            score = ruleObj[TpRuleType.Score]
        end

        --临时变量定义
        local ruleType = nil
        local ruleValue = nil
        local ruleConfigData = nil
        local length = #TpConfig.RuleSortConfig
        for i = 1, length do
            ruleType = TpConfig.RuleSortConfig[i]
            ruleValue = ruleObj[ruleType]
            if ruleValue ~= nil then
                --处理自定义字段，由于有顺序问题，所以在这里处理
                --前注
                if ruleType == TpRuleType.QianZhu then
                    ruleStr = TpConfig.JointRuleString(separator, ruleStr, "前注" .. ruleValue)
                else
                    ruleConfigData = TpConfig.GetRuleConfigData(ruleType, ruleValue)
                    if ruleConfigData ~= nil then
                        if ruleConfigData.ruleTxt ~= nil then
                            ruleStr = TpConfig.JointRuleString(separator, ruleStr, ruleConfigData.ruleTxt)
                        else
                            ruleStr = TpConfig.JointRuleString(separator, ruleStr, ruleConfigData.name)
                        end
                    end
                end
            end
        end

        --处理自定义的字段
        local temp = ruleObj[TpRuleType.ZhunRu]
        if temp ~= nil then
            ruleStr = TpConfig.JointRuleString(separator, ruleStr, GetS("%s(%s)", "准入", temp))
        end
        temp = ruleObj[TpRuleType.JieSanFenShu]
        if temp ~= nil then
            ruleStr = TpConfig.JointRuleString(separator, ruleStr, GetS("%s(%s)", "解散分数", temp))
        end
        if UnionData.IsUnionLeader() then
            temp = ruleObj[TpRuleType.KeepBaseNum]
            local symbol = bdPer == 0 and "分" or "%"
            if temp ~= nil then
                ruleStr = TpConfig.JointRuleString(separator, ruleStr, "保底" .. temp .. symbol)
            end
        end
        temp = ruleObj[TpRuleType.ExpressionPercent]
        if temp ~= nil then
            ruleStr = TpConfig.JointRuleString(separator, ruleStr, GetS("%s(%s)", "表情比例", temp .. "%"))
        end
    end

    if playWayName == nil then
        playWayName = ""
    end
    return {
        playWayName = playWayName,
        playWayType = playWayType,
        juShu = juShu,
        juShuTxt = juShuTxt,
        juShuTips = juShuTips,
        rule = ruleStr,
        cards = cardNum,
        baseScore = score,
        userNum = totalUserNum,
    }
end