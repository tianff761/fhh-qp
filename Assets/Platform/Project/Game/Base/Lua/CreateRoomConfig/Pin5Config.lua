Pin5Config = {}
local this = Pin5Config
--血战到底玩法类型
Pin5PlayType = {
    --明牌抢庄
    MingPaiQiangZhuang = 1,
    --自由抢庄
    ZiYouQiangZhuang = 2,
    --王癞拼十
    WangLai = 2,
}

Pin5RuleType = {
    --玩法
    PlayType = "pt", -- value = 1 明牌抢庄
    --底分
    BaseScore = "ba", -- 1 1/2/4  2 
    --局数
    JuShu = "js", -- value = 10 10局  value = 20 20局
    --人数
    GameTotal = "pn", --value = 6 6人桌   value = 8 8人桌  value = 10 10人桌
    --支付方式
    PayType = "ct", --0无、1房主支付、2AA制支付、3亲友圈支付、4大赢家付
    --癞子
    LaiZi = "kl", -- 1 无癞子  2 有癞子  3 底牌无癞子
    --开始选项
    StartModel = "st", --1准备开始  2满2人开  3 满4人开
    --最大抢庄
    MaxQiangZhuang = "rz", --1 1倍 2 2倍 3 3倍 4 4倍
    --推注
    TuiZhu = "pb", -- 0无   5 5倍  10 10倍   15 15倍  20 20 倍
    --特殊牌型
    SpecialCard = "sn", --"SC":{{"SZN":1},{"WHN":1},{},{},{},}  --
    --五花炮
    WuHuaNiu = "WHN", -- 0 沒选择 1 选择五花炮4倍 
    --顺子炮
    ShunZiNiu = "SZN", -- 0 沒选择 1 选择顺子炮5倍
    --同花炮
    TongHuaNiu = "THN", -- 0 沒选择 1 选择同花炮6倍
    --葫芦炮
    HuLuNiu = "HLN", -- 0 沒选择 1 选择葫芦炮7倍
    --炸弹炮
    ZhaDanNiu = "ZDN", -- 0 沒选择 1 选择炸弹炮8倍
    --五小炮
    WuXiaoNiu = "WXN", -- 0 沒选择 1 选择五小炮9倍
    --快乐炮
    TongHuaShunNiu = "THSN", -- 0 沒选择 1 选择快乐一大炮0倍
    --高级选项
    HighOption = "ho", --"HO":{{}{}{}}
    --中途禁入
    GameStartForbiden = "GSF", -- 0 沒选择 1 选择中途禁入
    --下注限制
    XiaZhuLimit = "XZL", -- 0 沒选择 1 选择下注限制
    --禁止语音
    VoiceForbiden = "VF", -- 0 沒选择 1 选择禁止语音
    --禁止搓牌
    CuoPaiForbiden = "CPF", -- 0 沒选择 1 选择禁止搓牌
    --翻倍规则
    FanBeiRule = "mr", --一大炮~十大炮分别对应1~10倍  十大炮×5九大炮×4八大炮×3七大炮×2  十大炮×3九大炮×2八大炮×2七大炮×1
    --金豆准入
    ZhunRu = "zr",
    --底分
    DiFen = "bs",
    --房间类型
    RoomType = "rt", --
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
    ---抢庄最低分数
    RobLimit = "qzfs",
}

Pin5OptionConfigTxt = {
    [1] = "中途禁入",
    [2] = "下注限制",
    [3] = "禁止语音",
    [4] = "禁止搓牌",
}

Pin5NiuCardTypeConfigTxt = {
    [1] = "五花牛",
    [2] = "顺子牛",
    [3] = "同花牛",
    [4] = "葫芦牛",
    [5] = "炸弹牛",
    [6] = "五小牛",
    [7] = "快乐牛",
}

--拼五规则
Pin5RuleTeShu = {
    [Pin5RuleType.WuHuaNiu] = 12,
    [12] = Pin5RuleType.WuHuaNiu,
    [Pin5RuleType.ShunZiNiu] = 13,
    [13] = Pin5RuleType.ShunZiNiu,
    [Pin5RuleType.TongHuaNiu] = 14,
    [14] = Pin5RuleType.TongHuaNiu,
    [Pin5RuleType.HuLuNiu] = 15,
    [15] = Pin5RuleType.HuLuNiu,
    [Pin5RuleType.ZhaDanNiu] = 16,
    [16] = Pin5RuleType.ZhaDanNiu,
    [Pin5RuleType.WuXiaoNiu] = 17,
    [17] = Pin5RuleType.WuXiaoNiu,
    [Pin5RuleType.TongHuaShunNiu] = 18,
    [18] = Pin5RuleType.TongHuaShunNiu,
}

--高级规则  `
Pin5RuleHighOptionMap = {
    [Pin5RuleType.GameStartForbiden] = 1,
    [1] = Pin5RuleType.GameStartForbiden,
    [Pin5RuleType.XiaZhuLimit] = 2,
    [2] = Pin5RuleType.XiaZhuLimit,
    [Pin5RuleType.VoiceForbiden] = 3,
    [3] = Pin5RuleType.VoiceForbiden,
    [Pin5RuleType.CuoPaiForbiden] = 4,
    [4] = Pin5RuleType.CuoPaiForbiden,
}

Pin5NiuTypeMap = {
    Pin5RuleType.WuHuaNiu,
    Pin5RuleType.ShunZiNiu,
    Pin5RuleType.TongHuaNiu,
    Pin5RuleType.HuLuNiu,
    Pin5RuleType.ZhaDanNiu,
    Pin5RuleType.WuXiaoNiu,
    Pin5RuleType.TongHuaShunNiu,
}

Pin5NiuTypeMuiltMap = {
    [1] = {
        [Pin5RuleType.WuHuaNiu] = "(5倍)",
        [Pin5RuleType.ShunZiNiu] = "(5倍)",
        [Pin5RuleType.TongHuaNiu] = "(6倍)",
        [Pin5RuleType.HuLuNiu] = "(7倍)",
        [Pin5RuleType.ZhaDanNiu] = "(8倍)",
        [Pin5RuleType.WuXiaoNiu] = "(9倍)",
        [Pin5RuleType.TongHuaShunNiu] = "(10倍)",
    },
    [2] = {
        [Pin5RuleType.WuHuaNiu] = "(6倍)",
        [Pin5RuleType.ShunZiNiu] = "(6倍)",
        [Pin5RuleType.TongHuaNiu] = "(7倍)",
        [Pin5RuleType.HuLuNiu] = "(8倍)",
        [Pin5RuleType.ZhaDanNiu] = "(9倍)",
        [Pin5RuleType.WuXiaoNiu] = "(10倍)",
        [Pin5RuleType.TongHuaShunNiu] = "(10倍)",
    },
    [3] = {
        [Pin5RuleType.WuHuaNiu] = "(10倍)",
        [Pin5RuleType.ShunZiNiu] = "(10倍)",
        [Pin5RuleType.TongHuaNiu] = "(10倍)",
        [Pin5RuleType.HuLuNiu] = "(10倍)",
        [Pin5RuleType.ZhaDanNiu] = "(10倍)",
        [Pin5RuleType.WuXiaoNiu] = "(10倍)",
        [Pin5RuleType.TongHuaShunNiu] = "(10倍)",
    },
    [4] = {
        [Pin5RuleType.WuHuaNiu] = "(11倍)",
        [Pin5RuleType.ShunZiNiu] = "(11倍)",
        [Pin5RuleType.TongHuaNiu] = "(12倍)",
        [Pin5RuleType.HuLuNiu] = "(13倍)",
        [Pin5RuleType.ZhaDanNiu] = "(14倍)",
        [Pin5RuleType.WuXiaoNiu] = "(15倍)",
        [Pin5RuleType.TongHuaShunNiu] = "(15倍)",
    },
}


-----------------------------------------------------
--血战到底玩法类型名称
Pin5RulePlayTypeName = {
    --明牌抢庄
    [Pin5PlayType.MingPaiQiangZhuang] = "明牌抢庄",
    --自由抢庄
    [Pin5PlayType.ZiYouQiangZhuang] = "自由抢庄",
    --王癞拼十
    [Pin5PlayType.WangLai] = "王癞拼十",
}

--局数
Pin5RuleJuShu = {
    [1] = 10,
    [2] = 20,
    [3] = 30,
}

Pin5RuleJuShuConfig = { 10, 20, 30 }
Pin5RuleJuShuList = { "10局", "20局", "30局" }

--人数
Pin5RulePlayerNumber = {
    [6] = "6人桌",
    [8] = "8人桌",
    [10] = "10人桌"
}

Pin5RulePlayerNumberConfig = { 6, 8, 10 }
Pin5RulePlayerNumberList = { "6人桌", "8人桌", "10人桌" }

--底分
Pin5RuleDiFenConfig = { 1, 2, 3, 4, 5, 6, 7 }
Pin5RuleDiFen = {
    "2/4/8",
    "5/10/20",
    "10/20/40",
    "20/40/80",
    "50/100/200",
    "100/200/400",
    "4/8/16",
}

--底分值 （上面改的时候记得改下这里）
Pin5RuleDiFenValue = {
    [1] = { 2, 4, 8 },
    [2] = { 5, 10, 20 },
    [3] = { 10, 20, 40 },
    [4] = { 20, 40, 80 },
    [5] = { 50, 100, 200 },
    [6] = { 100, 200, 400 },
    [7] = { 4, 8, 16 },
}

--癞子
Pin5RuleLaiZiTypeConfig = { 1, 2, 3 }
Pin5RuleLaiZiType = {
    "无",
    "经典王癞",
    "疯狂天王癞"
}

--开始类型
Pin5RuleStartModel = {
    "房主开始",
    "满2人开",
    "满4人开",
    "满6人开",
    "满8人开",
    "满10人开",
}
Pin5RuleStartModelConfig = { 2, 3, 4, 5, 6 }
Pin5RuleStartModelList = { "满2人开", "满4人开", "满6人开", "满8人开", "满10人开" }

--抢庄倍数
Pin5RuleQiangZhuang = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
}

Pin5RuleQiangZhuangConfig = { 1, 2, 3, 4 }
Pin5RuleQiangZhuangList = { "1倍", "2倍", "3倍", "4倍" }

--推注0无   5 5倍  10 10倍   15 15倍  20 20 倍
Pin5RuleBolus = {
    [0] = "无",
    [5] = "5倍",
    [8] = "8倍",
    [10] = "10倍",
    [15] = "15倍",
    [20] = "20倍",
}

--推注选项
Pin5RuleBolusConfig = { 0, 10, 15, 20 }
Pin5RuleBolusList = { "无", "10倍", "15倍", "20倍" }

--0无、1房主支付、2AA制支付、3亲友圈支付、4大赢家付
Pin5RulePayConfig = { 1 }
Pin5RulePayList = { "房主支付" }

--特殊牛
Pin5RuleSpecialCardType = {
    [Pin5RuleType.WuHuaNiu] = "五花牛",
    [Pin5RuleType.ShunZiNiu] = "顺子牛",
    [Pin5RuleType.TongHuaNiu] = "同花牛",
    [Pin5RuleType.HuLuNiu] = "葫芦牛",
    [Pin5RuleType.ZhaDanNiu] = "炸弹牛",
    [Pin5RuleType.WuXiaoNiu] = "五小牛",
    [Pin5RuleType.TongHuaShunNiu] = "快乐牛",
}

--高级选项
Pin5RuleHighOption = {
    [Pin5RuleType.GameStartForbiden] = "中途禁入",
    [Pin5RuleType.XiaZhuLimit] = "下注限制",
    [Pin5RuleType.VoiceForbiden] = "禁止语音",
}

--翻倍规则
Pin5RuleFanBeiRuleConfig = { 1, 2, 3, 4 }
Pin5RuleFanBeiRule = {
    "牛牛×3牛九×2牛八×2牛七×1",
    "牛牛x4牛九x3牛八×2牛七×2",
    "牛牛×5牛九×4牛八×3牛七×2",
    "牛一~牛牛分别对应1~10倍"
}

----------------------------------------------------
--
--获取配置索引
function Pin5Config.GetConfigIndex(config, value)
    for i = 1, #config do
        if config[i] == value then
            return i - 1
        end
    end
    return 0
end

--通过索引获取值
function Pin5Config.GetConfigValue(config, index)
    local result = config[index + 1]
    if result ~= nil then
        return result
    end
    return 0
end

---
function Pin5Config.GetNiuTypeMuiltTxt(muilt, niuValue)
    local muiltMap = Pin5NiuTypeMuiltMap[muilt]
    local niuType = Pin5NiuTypeMap[niuValue]
    local niuTypeTxt = ""
    if muiltMap ~= nil and niuType ~= nil then
        if muiltMap[niuType] ~= nil then
            niuTypeTxt = Pin5NiuCardTypeConfigTxt[niuValue] .. muiltMap[niuType]
        end
    end
    return niuTypeTxt
end

Pin5ConsumeConfig = {
    [10] = { [6] = 101405, [8] = 101406 },
    [20] = { [6] = 101401, [8] = 101402 },
    [30] = { [6] = 101403, [8] = 101404 },
}

Pin5CardsConfig = {
    [6] = { [10] = 16, [20] = 32, [30] = 64 },
    [8] = { [10] = 16, [20] = 32, [30] = 64 },
    [10] = { [10] = 16, [20] = 32, [30] = 64 },
}

Pin5ZhunRuConfig = {
    [10] = 6100,
    [20] = 12000
}

--底分配置
Pin5Config.DiFenConfig = { 0.1, 0.2, 0.3, 0.5, 1, 2, 3, 4, 5, 6, 10, 20 }
--底分配置，用于Dropdown列表
Pin5Config.DiFenNameConfig = { "0.1分", "0.2分", "0.3分", "0.5分", "1分", "2分", "3分", "4分", "5分", "6分", "10分", "20分" }

function Pin5Config.GetCardsConfig(playerTotal, maxJushu)
    local cards = 0
    local temp = Pin5CardsConfig[playerTotal]
    if temp ~= nil then
        local tempConfig = temp[maxJushu]
        if tempConfig ~= nil then
            cards = tempConfig
        end
    end
    return cards
end

--获取消费ID
function Pin5Config.GetConsumeConfigId(playerTotal, maxJushu)
    local id = 0

    local temp = Pin5ConsumeConfig[maxJushu]
    if temp ~= nil then
        local tempConfig = temp[playerTotal]
        if tempConfig ~= nil then
            id = tempConfig
        end
    end
    return id
end

--房卡配置
Pin5RoomCardConfig = {
    -- FourBj = 30001,
    -- FourSLj = 30002,
    -- ThreeBj = 30003,
    -- ThreeSLj = 30004,
}

--解析规则
function Pin5Config.ParsePin5Rule(ruleObj, separator, isSpeical, bdPer)
    if string.IsNullOrEmpty(separator) then
        separator = " "
    end

    local rules = ruleObj
    local parsedRule = { playWayName = "", juShu = 0, juShuTxt = "", rule = "", cards = 0, baseScore = 1, baseScoreTips = "", userNum = 4, tips = "" }

    if IsTable(ruleObj) then
        local playType = ruleObj[Pin5RuleType.PlayType]
        --Log('=====ruleObj====', ruleObj)
        --解析玩法名称
        parsedRule.playWayName = this.GetPin5RuleText(Pin5RuleType.PlayType, playType, separator)

        parsedRule.juShu = ruleObj[Pin5RuleType.JuShu]
        if parsedRule.juShu == -1 then
            parsedRule.juShuTxt = "--"
        else
            parsedRule.juShuTxt = parsedRule.juShu .. "局"
        end
        parsedRule.userNum = rules[Pin5RuleType.GameTotal]
        if rules[Pin5RuleType.RoomType] == RoomType.Tea then
            parsedRule.baseScore = rules[Pin5RuleType.DiFen]
            parsedRule.baseScoreTips = this.GetDiFenStr(rules)
        end
        --解析规则
        local ruleText = ""
        ruleText = ruleText .. this.GetPin5RuleText(Pin5RuleType.GameTotal, rules[Pin5RuleType.GameTotal], separator)
        ruleText = ruleText .. this.GetPin5RuleText(Pin5RuleType.BaseScore, rules[Pin5RuleType.BaseScore], separator)
        ruleText = ruleText .. this.GetPin5RuleText(Pin5RuleType.StartModel, rules[Pin5RuleType.StartModel], separator)
        ruleText = ruleText .. this.GetPin5RuleText(Pin5RuleType.MaxQiangZhuang, rules[Pin5RuleType.MaxQiangZhuang], separator)
        ruleText = ruleText .. this.GetPin5RuleText(Pin5RuleType.LaiZi, rules[Pin5RuleType.LaiZi], separator)
        ruleText = ruleText .. this.GetPin5RuleText(Pin5RuleType.TuiZhu, rules[Pin5RuleType.TuiZhu], separator)
        ruleText = ruleText .. this.GetPin5RuleText(Pin5RuleType.FanBeiRule, rules[Pin5RuleType.FanBeiRule], separator)
        --ruleText = ruleText .. "底分"..
        --if isSpeical then
        --    ruleText = ruleText .. "特殊牌型都是10倍" .. separator
        --else
        local temp = string.split(rules[Pin5RuleType.SpecialCard], ",")
        if temp ~= nil and GetTableSize(temp) > 0 then
            for i = 1, #temp do
                ruleText = ruleText .. Pin5Config.GetNiuTypeMuiltTxt(rules[Pin5RuleType.FanBeiRule], i) .. separator
            end
        end
        --end
        -- ruleText = ruleText .. this.GetPin5RuleText(Pin5RuleType.SpecialCard, rules[Pin5RuleType.SpecialCard], separator,isSpeical)
        ruleText = ruleText .. this.GetPin5RuleText(Pin5RuleType.HighOption, rules[Pin5RuleType.HighOption], separator)
        ruleText = (UnionData.selfRole == UnionRole.Leader and rules[Pin5RuleType.ExpressionPercent] and rules[Pin5RuleType.KeepBaseNum]) and ruleText .. "表情比例 " .. rules[Pin5RuleType.ExpressionPercent] .. "%" .. separator .. "保底 " .. rules[Pin5RuleType.KeepBaseNum] .. (bdPer == 0 and "分" or "%") or ruleText
        ruleText = rules[Pin5RuleType.RobLimit] and ruleText .. "  抢庄最低积分 " .. rules[Pin5RuleType.RobLimit] or ruleText

        parsedRule.rule = ruleText
        parsedRule.tips = this.GetPin5RuleText(Pin5RuleType.LaiZi, rules[Pin5RuleType.LaiZi], separator)
    end
    return parsedRule
end


--获取规则字符串
function Pin5Config.GetPin5RuleText(rule, value, separator, isSpeical)
    if string.IsNullOrEmpty(rule) or string.IsNullOrEmpty(value) then
        return ""
    end
    if string.IsNullOrEmpty(separator) then
        separator = " "
    end

    if rule == Pin5RuleType.PlayType then
        return Pin5RulePlayTypeName[value] .. separator
    end

    if rule == Pin5RuleType.BaseScore then
        return "押注分" .. Pin5RuleDiFen[value] .. separator
    end

    if rule == Pin5RuleType.JuShu then
        return Pin5RuleJuShu[value] .. separator
    end

    if rule == Pin5RuleType.GameTotal then
        --LogError("Pin5RulePlayerNumber[value]", Pin5RulePlayerNumber[value], "separator", separator)
        return Pin5RulePlayerNumber[value] .. separator
    end

    if rule == Pin5RuleType.PayType then
        return PayTypeName[value] .. separator
    end

    if rule == Pin5RuleType.LaiZi then
        return Pin5RuleLaiZiType[value] .. separator
    end

    if rule == Pin5RuleType.StartModel then
        return Pin5RuleStartModel[value] .. separator
    end

    if rule == Pin5RuleType.MaxQiangZhuang then
        return "最大抢庄" .. Pin5RuleQiangZhuang[value] .. "倍" .. separator
    end

    if rule == Pin5RuleType.FanBeiRule then
        return Pin5RuleFanBeiRule[value] .. separator
    end

    if rule == Pin5RuleType.TuiZhu then
        return "推注" .. Pin5RuleBolus[value] .. separator
    end

    if rule == Pin5RuleType.SpecialCard then

    end
    if rule == Pin5RuleType.HighOption then
        local temp = string.split(value, ",")
        local tempStr = ""
        for i = 1, #temp do
            tempStr = tempStr .. Pin5OptionConfigTxt[tonumber(temp[i])] .. separator
        end
        return tempStr .. separator
    end
    return ""
end

--获取押注底分字符串
function Pin5Config.GetDiFenStr(rules)
    local tempIndex = rules[Pin5RuleType.BaseScore]
    if tempIndex == nil then
        tempIndex = 1
    end
    local temp = Pin5RuleDiFen[tempIndex]
    if temp == nil then
        return Pin5RuleDiFen[1]
    else
        return temp
    end
end


function Pin5Config.GetPlaywayTypeByName(name)
    for k,v in pairs(Pin5RulePlayTypeName) do
        if name == v then
            return k
        end
    end
    return 0
end


-- --牌型-- function Pin5Config.GetCardTypeText(specialCards)--     local str = ""--     for specialCard, value in pairs(specialCards) do--             str = str .. "," .. Pin5RuleSpecialCardType[specialCard]--     end--     return str-- end-- --高级选项-- function Pin5Config.GetCardHighOptionText(highOptions)--     local str = ""--     for highOption, value in pairs(highOptions) do--         if value == 1 then--             str = str .. "," .. Pin5RuleHighOption[highOption]--         end--     end--     return str-- end