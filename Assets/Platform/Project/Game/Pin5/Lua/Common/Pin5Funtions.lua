Pin5Funtions = {}
-- 获取玩法字符串
function Pin5Funtions.PlayWay(arg)
    local config = arg
    local rule = config.rule
    local tab = {}
    -- local isGoldGame = Pin5RoomData.IsGoldGame()

    --游戏类型
    if rule[Pin5RuleType.PlayType] ~= nil then
        Pin5RoomData.gameType = rule[Pin5RuleType.PlayType]
        -- --设置游戏类型名
        Pin5RoomData.gameName = Pin5RulePlayTypeName[Pin5RoomData.gameType]
    end

    --局数
    if config.maxJuShu ~= nil then
        Pin5RoomData.gameTotal = config.maxJuShu
    end

    --推注
    if rule[Pin5RuleType.TuiZhu] ~= nil then
        Pin5RoomData.tuiZhu = Pin5RuleBolus[rule[Pin5RuleType.TuiZhu]]
    end

    --抢庄(倍率)
    if rule[Pin5RuleType.MaxQiangZhuang] ~= nil then
        Pin5RoomData.multipleValue = Pin5RuleQiangZhuang[rule[Pin5RuleType.MaxQiangZhuang]]
        Pin5RoomData.multiple = Pin5RoomData.multipleValue .. "倍"
    end

    --开始类型
    if rule[Pin5RuleType.StartModel] ~= nil then
        Pin5RoomData.showStartType = Pin5RuleStartModel[rule[Pin5RuleType.StartModel]]
        Pin5RoomData.startType = rule[Pin5RuleType.StartModel]
    end

    --人数
    if rule[Pin5RuleType.GameTotal] ~= nil then
        Pin5RoomData.manCount = rule[Pin5RuleType.GameTotal]
    end

    --模式
    if rule[Pin5RuleType.LaiZi] ~= nil then
        Pin5RoomData.model = Pin5RuleLaiZiType[rule[Pin5RuleType.LaiZi]]
    end

    --支付
    if rule[Pin5RuleType.PayType] ~= nil then
        Pin5RoomData.payType = PayTypeName[rule[Pin5RuleType.PayType]]
    end

    --底分
    if rule[Pin5RuleType.BaseScore] ~= nil then
        LogError("Pin5RuleDiFen[rule[Pin5RuleType.DiFen]]", Pin5RuleDiFen[rule[Pin5RuleType.DiFen]])
        Pin5RoomData.diFen = rule[Pin5RuleType.DiFen]
        local tab = Pin5RuleDiFenValue[rule[Pin5RuleType.BaseScore]]
        Pin5RoomData.maxDiFen = tab[#tab]
    end

    --翻倍规则
    if rule[Pin5RuleType.FanBeiRule] ~= nil then
        Pin5RoomData.fanBeiRuleValue = rule[Pin5RuleType.FanBeiRule]
        Pin5RoomData.fanBeiRule = Pin5RuleFanBeiRule[Pin5RoomData.fanBeiRuleValue]
    end

    --高级
    Pin5RoomData.isRubCard = true
    Pin5RoomData.isSpeech = true
    if rule[Pin5RuleType.HighOption] ~= nil then
        local gaoji = string.split(rule[Pin5RuleType.HighOption], ",")
        local str = " "
        for i = 1, #gaoji do
            str = str .. Pin5OptionConfigTxt[tonumber(gaoji[i])] .. "  "
            if gaoji[i] == "4" then
                Pin5RoomData.isRubCard = false
            elseif gaoji[i] == "3" then
                Pin5RoomData.isSpeech = false
            end
        end
        Pin5RoomData.gaoJiConfig = str
    end

    --牌型
    if rule[Pin5RuleType.SpecialCard] ~= nil then
        local special = string.split(rule[Pin5RuleType.SpecialCard], ",")
        local str = " "
        for i = 1, #special do
            str = str .. Pin5Config.GetNiuTypeMuiltTxt(Pin5RoomData.fanBeiRuleValue, tonumber(special[i]) - 11) .. "  "
        end
        Pin5RoomData.SpecialConfig = str
    end

    if rule[Pin5RuleType.RobLimit] then
        Pin5RoomData.RobLimit = rule[Pin5RuleType.RobLimit]
    end
end

--通过服务器座位号计算本地座位号
function Pin5Funtions.CalcLocalSeatByServerSeat(relative, seatNumber)
    -- (最大人数 - 自己服务器座位号 + 玩家服务器座位号) % 最大人数 + 1
    return (Pin5RoomData.manCount - relative + seatNumber) % Pin5RoomData.manCount + 1
end

--是否为空或者零
function Pin5Funtions.IsNilOrZero(num)
    return IsNil(num) or num == 0
end

function Pin5Funtions.GetActive(item)
    return item.gameObject.activeSelf
end

--是否需要抢庄
function Pin5Funtions.isRobBanker()
    return true
end

--提示状态码
function Pin5Funtions.ToastStatusCode(code)
    local str = Pin5StatusCode[code]
    if not IsNil(str) then
        Toast.Show(str)
    end
end

--提示状态码
function Pin5Funtions.AlertStatusCode(code)
    local str = Pin5StatusCode[code]
    if not IsNil(str) then
        Alert.Show(str)
    end
end

return Pin5Funtions