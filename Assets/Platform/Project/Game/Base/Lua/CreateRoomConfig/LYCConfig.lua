LYCConfig = {}
local this = LYCConfig
--血战到底玩法类型
LYCPlayType = {
    --随机抢庄
    RandomQiangZhuang = 1,
    --自由抢庄
    --ZiYouQiangZhuang = 2,
    --王癞拼十
    --WangLai = 2,
}

LYCRuleType = {
    --玩法
    PlayType = "pt", -- value = 1 明牌抢庄
    --押注分
    BaseScore = "ba", -- 1/2/3  1/2/4
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
    --最大抢庄 抢庄倍数
    QZFanBei = "qzbs", --1/2/3/4 2/4/6/8
    ---抢庄最低分数
    QZFenShu = "qzfs",
    --推注
    TuiZhu = "pb", -- 0无   5 5倍  10 10倍   15 15倍  20 20 倍
    --特殊牌型
    SpecialCard = "sn", --"SC":{{"SZN":1},{"WHN":1},{},{},{},}  --
    ---码宝
    MaBao = "MB",
    ---走水
    ZouShui = "ZS",
    ---豹子
    BaoZi = "BZ",
    ---三腌
    TripleYan = "TY",
    ---双腌
    DoubleYan = "BY",
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
    ---抢庄
    RobZhuang = "rb",
    ---平局
    Tie = "TIE",
    ---牌数
    CardCount = "PFN",
    ---三批大小
    ThreeBatch = "ZD3"
}

LYCOptionConfigTxt = {
    [1] = "中途禁入",
    [2] = "下注限制",
    [3] = "禁止语音",
    [4] = "禁止搓牌",
}

LYCNiuCardTypeConfigTxt = {
    [1] = "豹子",
    [2] = "三腌",
    [3] = "双腌",
}

--拼五规则
LYCRuleTeShu = {
    [LYCRuleType.BaoZi] = 1,
    [1] = LYCRuleType.BaoZi,
    [LYCRuleType.TripleYan] = 2,
    [2] = LYCRuleType.TripleYan,
    [LYCRuleType.DoubleYan] = 3,
    [3] = LYCRuleType.DoubleYan,
}

--高级规则  `
LYCRuleHighOptionMap = {
    [LYCRuleType.GameStartForbiden] = 1,
    [1] = LYCRuleType.GameStartForbiden,
    [LYCRuleType.XiaZhuLimit] = 2,
    [2] = LYCRuleType.XiaZhuLimit,
    [LYCRuleType.VoiceForbiden] = 3,
    [3] = LYCRuleType.VoiceForbiden,
    [LYCRuleType.CuoPaiForbiden] = 4,
    [4] = LYCRuleType.CuoPaiForbiden,
}

LYCNiuTypeMap = {
    LYCRuleType.BaoZi,
    LYCRuleType.TripleYan,
    LYCRuleType.DoubleYan,
}

LYCNiuTypeMuiltMap = {
    [1] = {
        [LYCRuleType.BaoZi] = "(5倍)",
        [LYCRuleType.TripleYan] = "(3倍)",
        [LYCRuleType.DoubleYan] = "(2倍)",
    },
    --[2] = {
    --    [LYCRuleType.WuHuaNiu] = "(6倍)",
    --    [LYCRuleType.ShunZiNiu] = "(6倍)",
    --    [LYCRuleType.TongHuaNiu] = "(7倍)",
    --    [LYCRuleType.HuLuNiu] = "(8倍)",
    --    [LYCRuleType.ZhaDanNiu] = "(9倍)",
    --    [LYCRuleType.WuXiaoNiu] = "(10倍)",
    --    [LYCRuleType.TongHuaShunNiu] = "(10倍)",
    --},
    --[3] = {
    --    [LYCRuleType.WuHuaNiu] = "(10倍)",
    --    [LYCRuleType.ShunZiNiu] = "(10倍)",
    --    [LYCRuleType.TongHuaNiu] = "(10倍)",
    --    [LYCRuleType.HuLuNiu] = "(10倍)",
    --    [LYCRuleType.ZhaDanNiu] = "(10倍)",
    --    [LYCRuleType.WuXiaoNiu] = "(10倍)",
    --    [LYCRuleType.TongHuaShunNiu] = "(10倍)",
    --},
    --[4] = {
    --    [LYCRuleType.WuHuaNiu] = "(11倍)",
    --    [LYCRuleType.ShunZiNiu] = "(11倍)",
    --    [LYCRuleType.TongHuaNiu] = "(12倍)",
    --    [LYCRuleType.HuLuNiu] = "(13倍)",
    --    [LYCRuleType.ZhaDanNiu] = "(14倍)",
    --    [LYCRuleType.WuXiaoNiu] = "(15倍)",
    --    [LYCRuleType.TongHuaShunNiu] = "(15倍)",
    --},
}


-----------------------------------------------------
--血战到底玩法类型名称
LYCRulePlayTypeName = {
    --明牌抢庄
    [LYCPlayType.RandomQiangZhuang] = "捞腌菜",
    --自由抢庄
    --[LYCPlayType.ZiYouQiangZhuang] = "自由抢庄",
    --王癞拼十
    --[LYCPlayType.WangLai] = "王癞拼十",
}

--局数
LYCRuleJuShu = {
    [1] = 10,
    [2] = 12,
}

LYCRuleJuShuConfig = { 10, 12, }-- 30 }
LYCRuleJuShuList = { "10局", "12局", }-- "30局" }

--人数
LYCRulePlayerNumber = {
    [6] = "6人桌",
    [8] = "8人桌",
    [10] = "10人桌",
}

LYCRulePlayerNumberConfig = { 6, 8, 10 }
LYCRulePlayerNumberList = {"6人桌", "8人桌", "10人桌"}

--押注分
LYCRuleDiFenConfig = { 1, 2 }
LYCRuleDiFen = {
    "1/2/3",
    "1/2/4",
    --"20/40/80",
    --"50/100/200",
    --"100/200/400",
    --"4/8/16",
}

--押注分值 （和下面底分相对应）
LYCRuleDiFenValue = {
    [1] = { 1, 2, 3, 4},
    [2] = { 2, 4, 6, 8},
    [3] = { 3, 6, 9, 12},
    [4] = { 4, 8, 12, 16},
}

--底分配置
LYCConfig.DiFenConfig = { 1, 2, 3, 4}
--底分配置，用于Dropdown列表
LYCConfig.DiFenNameConfig = { "1分", "2分", "3分", "4分"}

--癞子
LYCRuleLaiZiTypeConfig = { 1, 2, 3 }
LYCRuleLaiZiType = {
    "无",
    "经典王癞",
    "疯狂王癞"
}

--开始类型
LYCRuleStartModel = {
    "房主开始",
    "满2人开",
    "满4人开",
    "满6人开",
    --"满8人开",
    --"满10人开",
}
LYCRuleStartModelConfig = { 2, 3, 4 }
LYCRuleStartModelList = { "满2人开", "满4人开", "满6人开" }

---码宝选择
LYCMaBaoSelect = {
    [1] = "3次",
    [2] = "5次",
    [3] = "10次",
    [4] = "不限",
}
LYCMaoBaoSelectConfig = { 3, 5, 10, 0 }
LYCMaoBaoSelectConfigIndex = {
    [3] = LYCMaBaoSelect[1],
    [5] = LYCMaBaoSelect[2],
    [10] = LYCMaBaoSelect[3],
    [0] = LYCMaBaoSelect[4],
}

LYCZouShuiSelect = {
    "无"
}

PinJuSelect = {
    "走水",
    "走水或码宝"
}

PaiShuSelect = {
    "一副牌",
    -- "二副牌"
}

ZhuangModeSelect = {
    -- "随机庄",
    "自由抢庄",
    -- "霸王庄"
}

ZhuangModeSelectConfig = { 3 }
ZhuangModeSelectConfigIndex = { [3] = ZhuangModeSelect[1] }
-- ZhuangModeSelectConfig = { 2, 3, 1 }
-- ZhuangModeSelectConfigIndex = { [2] = ZhuangModeSelect[1], [3] = ZhuangModeSelect[2], [1] = ZhuangModeSelect[3] }

SanPiSelect = {
    "333(10倍)>其余炸弹（5倍）",
    "所有炸弹一样大（5倍）",
}

SanPiSelectConfig = { 1, 0 }
SanPiSelectConfigIndex = { [1] = SanPiSelect[1], [0] = SanPiSelect[2] }

--抢庄倍数
LYCQiangZhuang = {
    "1/2/3/4",
    "2/4/6/8",
}

LYCQiangZhuangfig = {1, 2}
--抢庄倍数规则
LYCQiangZhuangRule = {
    [1] = "1/2/3/4",
    [2] = "2/4/6/8",
}

--抢庄分数
LYCQZFenShu = {
    "300",
}

--推注0无   5 5倍  10 10倍   15 15倍  20 20 倍
LYCRuleBolus = {
    [0] = "无",
    [5] = "5倍",
    [8] = "8倍",
    [10] = "10倍",
    [15] = "15倍",
    [20] = "20倍",
}

--推注选项
LYCRuleBolusConfig = { 0, 10, 15, 20 }
LYCRuleBolusList = { "无", "10倍", "15倍", "20倍" }

---走水
LYCRuleZouShui = { 1 }
LYCRuleZouShuiList = { "无" }

--0无、1房主支付、2AA制支付、3亲友圈支付、4大赢家付
LYCRulePayConfig = { 1 }
LYCRulePayList = { "房主支付" }

--特殊牌型
LYCRuleSpecialCardType = {
    [LYCRuleType.BaoZi] = "豹子",
    [LYCRuleType.TripleYan] = "三腌",
    [LYCRuleType.DoubleYan] = "双腌",
}

--高级选项
LYCRuleHighOption = {
    [LYCRuleType.GameStartForbiden] = "中途禁入",
    [LYCRuleType.XiaZhuLimit] = "下注限制",
    [LYCRuleType.VoiceForbiden] = "禁止语音",
}

--翻倍规则
LYCRuleFanBeiRuleConfig = { 1, 2, 3, 4 }
LYCRuleFanBeiRule = {
    "牛牛×3牛九×2牛八×2牛七×1",
    "牛牛x4牛九x3牛八×2牛七×2",
    "牛牛×5牛九×4牛八×3牛七×2",
    "牛一~牛牛分别对应1~10倍"
}

----------------------------------------------------
--
--获取配置索引
function LYCConfig.GetConfigIndex(config, value)
    for i = 1, #config do
        if config[i] == value then
            return i - 1
        end
    end
    return 0
end

--通过索引获取值
function LYCConfig.GetConfigValue(config, index)
    local result = config[index + 1]
    if result ~= nil then
        return result
    end
    return 0
end

---
function LYCConfig.GetNiuTypeMuiltTxt(muilt, niuValue)
    local muiltMap = LYCNiuTypeMuiltMap[muilt]
    local niuType = LYCNiuTypeMap[niuValue]
    local niuTypeTxt = ""
    if muiltMap ~= nil and niuType ~= nil then
        if muiltMap[niuType] ~= nil then
            niuTypeTxt = LYCNiuCardTypeConfigTxt[niuValue] .. muiltMap[niuType]
        end
    end
    return niuTypeTxt
end

LYCConsumeConfig = {
    [10] = { [6] = 101405, [8] = 101406 },
    [20] = { [6] = 101401, [8] = 101402 },
    [30] = { [6] = 101403, [8] = 101404 },
}

LYCCardsConfig = {
    [6] = { [10] = 16, [12] = 18, [30] = 64 },
    [8] = { [10] = 16, [12] = 18, [30] = 64 },
    [10] = { [10] = 16, [12] = 18, [30] = 64 },
}

LYCZhunRuConfig = {
    [10] = 6100,
    [20] = 12000
}


function LYCConfig.GetCardsConfig(playerTotal, maxJushu)
    local cards = 0
    local temp = LYCCardsConfig[playerTotal]
    if temp ~= nil then
        local tempConfig = temp[maxJushu]
        if tempConfig ~= nil then
            cards = tempConfig
        end
    end
    return cards
end

--获取消费ID
function LYCConfig.GetConsumeConfigId(playerTotal, maxJushu)
    local id = 0

    local temp = LYCConsumeConfig[maxJushu]
    if temp ~= nil then
        local tempConfig = temp[playerTotal]
        if tempConfig ~= nil then
            id = tempConfig
        end
    end
    return id
end

--房卡配置
LYCRoomCardConfig = {
    -- FourBj = 30001,
    -- FourSLj = 30002,
    -- ThreeBj = 30003,
    -- ThreeSLj = 30004,
}

--解析规则
function LYCConfig.ParseLYCRule(ruleObj, separator, isSpeical, bdPer, faceType)
    if string.IsNullOrEmpty(separator) then
        separator = " "
    end

    local rules = ruleObj
    local parsedRule = { playWayName = "", juShu = 0, juShuTxt = "", rule = "", cards = 0, baseScore = 1, baseScoreTips = "", userNum = 4, tips = "", baseRuleText = "", specialRuleText = ""}

    if IsTable(ruleObj) then
        local playType = ruleObj[LYCRuleType.PlayType]
        --Log('=====ruleObj====', ruleObj)
        --解析玩法名称
        parsedRule.playWayName = this.GetLYCRuleText(LYCRuleType.PlayType, playType, separator)

        parsedRule.juShu = ruleObj[LYCRuleType.JuShu]
        if parsedRule.juShu == -1 then
            parsedRule.juShuTxt = "--"
        else
            parsedRule.juShuTxt = parsedRule.juShu .. "局"
        end
        parsedRule.userNum = rules[LYCRuleType.GameTotal]
        if rules[LYCRuleType.RoomType] == RoomType.Tea then
            parsedRule.baseScore = rules[LYCRuleType.DiFen]
            parsedRule.baseScoreTips = this.GetDiFenStr(rules)
        end
        --解析规则
        local ruleText = ""
        ruleText = ruleText .. this.GetLYCRuleText(LYCRuleType.GameTotal, rules[LYCRuleType.GameTotal], separator)
        ruleText = ruleText .. this.GetLYCRuleText(LYCRuleType.BaseScore, rules[LYCRuleType.BaseScore], separator)
        ruleText = ruleText .. this.GetLYCRuleText(LYCRuleType.StartModel, rules[LYCRuleType.StartModel], separator)
        ruleText = ruleText .. this.GetLYCRuleText(LYCRuleType.QZFanBei, rules[LYCRuleType.QZFanBei], separator)
        ruleText = ruleText .. this.GetLYCRuleText(LYCRuleType.QZFenShu, rules[LYCRuleType.QZFenShu], separator)
        ruleText = ruleText .. this.GetLYCRuleText(LYCRuleType.MaBao, rules[LYCRuleType.MaBao], separator)
        ruleText = ruleText .. this.GetLYCRuleText(LYCRuleType.ZouShui, rules[LYCRuleType.ZouShui], separator)

        if faceType ~= nil then
            local faceTypeText = faceType == 0 and "所有人分配 " or "赢家分配 "
            ruleText = ruleText .. faceTypeText
        end
        --ruleText = ruleText .. this.GetLYCRuleText(LYCRuleType.Tie, rules[LYCRuleType.Tie], separator)
        --ruleText = ruleText .. this.GetLYCRuleText(LYCRuleType.CardCount, rules[LYCRuleType.CardCount], separator)
        --ruleText = ruleText .. this.GetLYCRuleText(LYCRuleType.RobZhuang, rules[LYCRuleType.RobZhuang], separator)
        --ruleText = ruleText .. this.GetLYCRuleText(LYCRuleType.ThreeBatch, rules[LYCRuleType.ThreeBatch], separator)

        parsedRule.baseRuleText = this.GetLYCRuleText(LYCRuleType.MaBao, rules[LYCRuleType.MaBao], separator) .. this.GetLYCRuleText(LYCRuleType.Tie, rules[LYCRuleType.Tie], separator) .. this.GetLYCRuleText(LYCRuleType.CardCount, rules[LYCRuleType.CardCount], separator) .. this.GetLYCRuleText(LYCRuleType.RobZhuang, rules[LYCRuleType.RobZhuang], separator)
        parsedRule.specialRuleText = this.GetLYCRuleText(LYCRuleType.ThreeBatch, rules[LYCRuleType.ThreeBatch], separator)
        --if isSpeical then
        --    ruleText = ruleText .. "特殊牌型都是10倍" .. separator
        --else
        -- local temp = string.split(rules[LYCRuleType.SpecialCard], ",")
        -- if temp ~= nil and GetTableSize(temp) > 0 then
        --     for i = 1, #temp do
        --         ruleText = ruleText .. LYCConfig.GetNiuTypeMuiltTxt(rules[LYCRuleType.FanBeiRule], i) .. separator
        --     end
        -- end
        --end
        -- ruleText = ruleText .. this.GetLYCRuleText(LYCRuleType.SpecialCard, rules[LYCRuleType.SpecialCard], separator,isSpeical)
        -- ruleText = ruleText .. this.GetLYCRuleText(LYCRuleType.HighOption, rules[LYCRuleType.HighOption], separator)
        ruleText = (UnionData.selfRole == UnionRole.Leader and rules[LYCRuleType.ExpressionPercent] and rules[LYCRuleType.KeepBaseNum]) and ruleText .. "表情比例 " .. rules[LYCRuleType.ExpressionPercent] .. "%" .. separator .. "保底 " .. rules[Pin5RuleType.KeepBaseNum] .. (bdPer == 0 and "分" or "%") or ruleText

        parsedRule.rule = ruleText
        parsedRule.tips = this.GetLYCRuleText(LYCRuleType.LaiZi, rules[LYCRuleType.LaiZi], separator)
    end
    return parsedRule
end


--获取规则字符串
function LYCConfig.GetLYCRuleText(rule, value, separator, isSpeical)
    if string.IsNullOrEmpty(rule) or string.IsNullOrEmpty(value) then
        return ""
    end
    if string.IsNullOrEmpty(separator) then
        separator = " "
    end

    if rule == LYCRuleType.PlayType then
        return LYCRulePlayTypeName[value] .. separator
    end

    if rule == LYCRuleType.BaseScore then
        return "押注分" .. LYCRuleDiFen[value] .. separator
    end

    if rule == LYCRuleType.JuShu then
        return LYCRuleJuShu[value] .. separator
    end

    if rule == LYCRuleType.GameTotal then
        --LogError("LYCRulePlayerNumber[value]", LYCRulePlayerNumber[value], "separator", separator)
        return LYCRulePlayerNumber[value] .. separator
    end

    if rule == LYCRuleType.PayType then
        return PayTypeName[value] .. separator
    end

    if rule == LYCRuleType.LaiZi then
        return LYCRuleLaiZiType[value] .. separator
    end

    if rule == LYCRuleType.StartModel then
        return LYCRuleStartModel[value] .. separator
    end

    if rule == LYCRuleType.QZFanBei then
        return "抢庄倍数" .. LYCQiangZhuangRule[value] .. separator
    end

    if rule == LYCRuleType.QZFenShu then
        return "抢庄分数" .. value .. separator
    end

    if rule == LYCRuleType.FanBeiRule then
        return LYCRuleFanBeiRule[value] .. separator
    end

    if rule == LYCRuleType.TuiZhu then
        return "推注" .. LYCRuleBolus[value] .. separator
    end

    if rule == LYCRuleType.MaBao then
        LogError("value", value)
        local maBaoStr = tonumber(value) == 0 and "不限" or value
        return "码宝次数 " .. maBaoStr .. separator
        -- return "码宝选择 " .. LYCMaoBaoSelectConfigIndex[value] .. separator
    end

    if rule == LYCRuleType.ZouShui then
        return "走水" .. LYCZouShuiSelect[value] .. separator
    end

    if rule == LYCRuleType.Tie then
        return "平局 " .. PinJuSelect[value] .. separator
    end

    if rule == LYCRuleType.CardCount then
        return "牌数 " .. PaiShuSelect[value] .. separator
    end

    if rule == LYCRuleType.RobZhuang then
        LogError("庄家value", value)
        return ZhuangModeSelectConfigIndex[value] .. separator
    end

    if rule == LYCRuleType.ThreeBatch then
        LogError("三批大小value", value)
        return "三批大小 " .. SanPiSelectConfigIndex[value] .. separator
    end

    if rule == LYCRuleType.SpecialCard then

    end
    if rule == LYCRuleType.HighOption then
        local temp = string.split(value, ",")
        local tempStr = ""
        for i = 1, #temp do
            tempStr = tempStr .. LYCOptionConfigTxt[tonumber(temp[i])] .. separator
        end
        return tempStr .. separator
    end
    return ""
end

--获取押注底分字符串
function LYCConfig.GetDiFenStr(rules)
    local tempIndex = rules[LYCRuleType.BaseScore]
    if tempIndex == nil then
        tempIndex = 1
    end
    local temp = LYCRuleDiFen[tempIndex]
    if temp == nil then
        return LYCRuleDiFen[1]
    else
        return temp
    end
end

-- --牌型-- function LYCConfig.GetCardTypeText(specialCards)--     local str = ""--     for specialCard, value in pairs(specialCards) do--             str = str .. "," .. LYCRuleSpecialCardType[specialCard]--     end--     return str-- end-- --高级选项-- function LYCConfig.GetCardHighOptionText(highOptions)--     local str = ""--     for highOption, value in pairs(highOptions) do--         if value == 1 then--             str = str .. "," .. LYCRuleHighOption[highOption]--         end--     end--     return str-- end