--贰柒拾规则类型定义
Pin3RuleType = {
    --玩法
    playType = "WF",
    --局数
    juShu = "JS",
    --支付类型
    payType = "PT",
    --最大人数
    maxUserNum = "MAX_NUM",
    --最大轮数
    maxLunShu = "MAX_COUNT",
    --闷轮数
    menLunShu = "MUST_MEN",
    --准入
    zhuiRu = "ZR",
    --底分
    baseScore = "BS",
    --是否可以语音
    canVoice = "CAN_CHAT",
    --是否开启GPS
    GPS = "gps",
    --封住大小，以暗注为准。
    fengZhu = "MAX_IG",
    --飞机喜钱
    feiJiXiQian = "XI_FJ",
    --同花顺喜钱
    tongHuaShunXiQian = "XI_THS",
    --创建房间 时选择几人开局
    START_NUM = "START_NUM",
    ---房费类型
    feetType = "feetype",
    ---赠送类型
    bigWin = "bigwin",
    ---表情比例
    percent = "per",
    --解散分数
    JieSanFenShu = "JSFS",
    ---表情比例
    ExpressionPercent = "expressionNum",
    ---保底
    KeepBaseNum = "keepBaseNum",
}
Pin3Config = {}
function Pin3Config.ParsePin3Rule(ruleObj, gps, separator, bdPer)
    if string.IsNullOrEmpty(separator) then
        separator = ' '
    end
    local parsedRule = { playWayName = "拼三张", juShu = 0, juShuTxt = "", rule = "", baseScore = 0, playerTotal = 4, tips = "" }
    if IsTable(ruleObj) then
        LogError("ruleObj", ruleObj)
        ruleObj[Pin3RuleType.GPS] = gps
        parsedRule.baseScore = ruleObj[Pin3RuleType.baseScore]
        parsedRule.playerTotal = ruleObj[Pin3RuleType.maxUserNum]
        parsedRule.tips = "封顶:" .. tostring(ruleObj[Pin3RuleType.fengZhu] * 2)
        --解析局数
        parsedRule.juShu = tonumber(ruleObj[Pin3RuleType.juShu])
        if parsedRule.juShu == nil then
            parsedRule.juShu = 1
            parsedRule.juShuTxt = "1局"
        elseif parsedRule.juShu > 0 then
            parsedRule.juShuTxt = tostring(parsedRule.juShu) .. "局"
        else
            parsedRule.juShuTxt = "--"
        end

        --解析规则
        local ruleText = ""
        ruleText = ruleText .. "最大人数:" .. tostring(ruleObj[Pin3RuleType.maxUserNum])
        ruleText = ruleText .. "  最大轮数:" .. tostring(ruleObj[Pin3RuleType.maxLunShu])
        if ruleObj[Pin3RuleType.zhuiRu] ~= nil then
            ruleText = ruleText .. "  准入:" .. tostring(ruleObj[Pin3RuleType.zhuiRu])
        end
        ruleText = ruleText .. "  底分:" .. tostring(ruleObj[Pin3RuleType.baseScore])
        ruleText = ruleText .. "  单注封顶:" .. tostring(ruleObj[Pin3RuleType.fengZhu] * 2)
        if ruleObj[Pin3RuleType.feiJiXiQian] ~= nil then
            ruleText = ruleText .. "  飞机收喜:" .. tostring(ruleObj[Pin3RuleType.feiJiXiQian])
        end
        if ruleObj[Pin3RuleType.tongHuaShunXiQian] ~= nil then
            ruleText = ruleText .. "  同花顺收喜:" .. tostring(ruleObj[Pin3RuleType.tongHuaShunXiQian])
        end
        if ruleObj[Pin3RuleType.menLunShu] >= 1 then
            ruleText = ruleText .. "  必闷" .. tostring(ruleObj[Pin3RuleType.menLunShu]) .. "轮"
        end
        if ruleObj[Pin3RuleType.START_NUM] then
            if ruleObj[Pin3RuleType.START_NUM] ~= 31 then
                ruleText = ruleText .. "  满" .. tostring(ruleObj[Pin3RuleType.START_NUM]) .. "人开"
            else
                ruleText = ruleText .. "  满三人房主开"
            end
        end
        ruleText = ruleText .. "  牌型相同时，主动比牌玩家输"
        if (UnionData.selfRole == UnionRole.Leader and ruleObj[Pin3RuleType.ExpressionPercent] and ruleObj[Pin3RuleType.KeepBaseNum]) then
            ruleText = ruleText .. separator .. "表情比例 " .. ruleObj[Pin5RuleType.ExpressionPercent] .. "%" .. separator .. "保底 " .. ruleObj[Pin5RuleType.KeepBaseNum] .. (bdPer == 0 and "分" or "%")
        end
        
        parsedRule.rule = ruleText
    end
    return parsedRule
end

local zhunRuConfig = {
    --50底分，准入3000，封顶1000
    [50] = { zhunRu = 3000, fengDing = 1000 },
    [100] = { zhunRu = 5000, fengDing = 1500 },
}

--底分配置
Pin3Config.DiFenConfig = { 0.1, 0.2, 0.3, 0.5, 1, 2, 3, 4, 5, 6, 10, 20 }
--底分配置，用于Dropdown列表
Pin3Config.DiFenNameConfig = { "0.1分", "0.2分", "0.3分", "0.5分", "1分", "2分", "3分", "4分", "5分", "6分", "10分", "20分" }

Pin3ConsumeConfig = {
    [4] = { [4] = 101701, [6] = 101702, [8] = 101703 }, --4句
    [6] = { [4] = 101704, [6] = 101705, [8] = 101706 }, --6句
    [8] = { [4] = 101707, [6] = 101708, [8] = 101709 }, -- 8句
}

Pin3CardsConfig = {
    [4] = { [4] = 6, [6] = 8, [8] = 10 }, -- 4人
    [6] = { [4] = 8, [6] = 10, [8] = 12 }, -- 6人
    [8] = { [4] = 10, [6] = 12, [8] = 15 }, -- 8人
}

Pin3Config.PlayWayNames = {
    [1] = "经典模式"
}

Pin3Config.AirPlane = { 0, 5, 10, 15, 30 }
Pin3Config.SameFlower = { 0, 5, 10, 15, 30 }

--根据底分获取准入
function Pin3Config.GetZhunRu(baseScore)
    local config = zhunRuConfig[baseScore]
    if config ~= nil then
        return config.zhunRu
    end
    return baseScore * 60
end
--根据底分获取封顶
function Pin3Config.GetFengDing(baseScore)
    local config = zhunRuConfig[baseScore]
    if config ~= nil then
        return config.fengDing
    end
    return baseScore * 40
end

--获取消费ID
function Pin3Config.GetConsumeConfigId(playerTotal, maxJushu)
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