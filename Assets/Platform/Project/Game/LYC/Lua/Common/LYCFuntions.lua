LYCFuntions = {}
-- 获取玩法字符串
function LYCFuntions.PlayWay(arg)
    local config = arg
    local rule = config.rule
    local tab = {}
    -- local isGoldGame = LYCRoomData.IsGoldGame()

    --游戏类型
    if rule[LYCRuleType.PlayType] ~= nil then
        LYCRoomData.gameType = rule[LYCRuleType.PlayType]
        -- --设置游戏类型名
        LYCRoomData.gameName = LYCRulePlayTypeName[LYCRoomData.gameType]
    end

    --局数
    if config.maxJuShu ~= nil then
        LYCRoomData.gameTotal = config.maxJuShu
    end

    --推注
    if rule[LYCRuleType.TuiZhu] ~= nil then
        LYCRoomData.tuiZhu = LYCRuleBolus[rule[LYCRuleType.TuiZhu]]
    end

    --抢庄(倍率)
    if rule[LYCRuleType.QZFanBei] ~= nil then
        -- LYCRoomData.multipleValue = LYCQiangZhuangRule[rule[LYCRuleType.QZFanBei]]
        -- LYCRoomData.multiple = LYCRoomData.multipleValue .. "倍"

        LYCRoomData.multiple = rule[LYCRuleType.QZFanBei] .. "倍"
    end

    --开始类型
    if rule[LYCRuleType.StartModel] ~= nil then
        LYCRoomData.showStartType = LYCRuleStartModel[rule[LYCRuleType.StartModel]]
        LYCRoomData.startType = rule[LYCRuleType.StartModel]
    end

    --人数
    if rule[LYCRuleType.GameTotal] ~= nil then
        LYCRoomData.manCount = rule[LYCRuleType.GameTotal]
    end

    --模式
    if rule[LYCRuleType.LaiZi] ~= nil then
        LYCRoomData.model = LYCRuleLaiZiType[rule[LYCRuleType.LaiZi]]
    end

    --支付
    if rule[LYCRuleType.PayType] ~= nil then
        LYCRoomData.payType = PayTypeName[rule[LYCRuleType.PayType]]
    end

    --底分
    if rule[LYCRuleType.DiFen] ~= nil then
        LogError("LYCRuleDiFen[rule[LYCRuleType.DiFen]]", LYCRuleDiFen[rule[LYCRuleType.DiFen]])
        LYCRoomData.diFen = rule[LYCRuleType.DiFen]
        local tab = LYCRuleDiFenValue[LYCRoomData.diFen]
        LYCRoomData.maxDiFen = tab[#tab] --最大押注分
    end

    --码宝次数
    if rule[LYCRuleType.MaBao] ~= nil then
        LYCRoomData.maBaoCount = rule[LYCRuleType.MaBao]
    end

    --抢庄分数
    if rule[LYCRuleType.QZFenShu] ~= nil then
        LYCRoomData.QZFSCount = rule[LYCRuleType.QZFenShu]
    end

    --翻倍规则
    if rule[LYCRuleType.FanBeiRule] ~= nil then
        LYCRoomData.fanBeiRuleValue = rule[LYCRuleType.FanBeiRule]
        LYCRoomData.fanBeiRule = LYCRuleFanBeiRule[LYCRoomData.fanBeiRuleValue]
    end

    --高级
    LYCRoomData.isRubCard = true
    LYCRoomData.isSpeech = true
    if rule[LYCRuleType.HighOption] ~= nil then
        local gaoji = string.split(rule[LYCRuleType.HighOption], ",")
        local str = " "
        for i = 1, #gaoji do
            str = str .. LYCOptionConfigTxt[tonumber(gaoji[i])] .. "  "
            if gaoji[i] == "4" then
                LYCRoomData.isRubCard = false
            elseif gaoji[i] == "3" then
                LYCRoomData.isSpeech = false
            end
        end
        LYCRoomData.gaoJiConfig = str
    end

    --牌型
    if rule[LYCRuleType.SpecialCard] ~= nil then
        local special = string.split(rule[LYCRuleType.SpecialCard], ",")
        local str = " "
        for i = 1, #special do
            LogError("special[i]", special[i])
            str = str .. LYCConfig.GetNiuTypeMuiltTxt(1, tonumber(special[i])) .. "  "
        end
        LYCRoomData.SpecialConfig = str
    end

    if rule[LYCRuleType.QZFenShu] then
        LYCRoomData.RobLimit = rule[LYCRuleType.QZFenShu]
    end

    LYCFuntions.ParseRoomInfoPanelRoomText(rule)
end

function LYCFuntions.ParseRoomInfoPanelRoomText(rule)
    local parsedData =  LYCConfig.ParseLYCRule(rule)
    LYCRoomData.RuleText = parsedData.rule
    LYCRoomData.baseRuleText =  parsedData.baseRuleText
    LYCRoomData.specialRuleText =  parsedData.specialRuleText
end

--通过服务器座位号计算本地座位号
function LYCFuntions.CalcLocalSeatByServerSeat(relative, seatNumber)
    -- (最大人数 - 自己服务器座位号 + 玩家服务器座位号) % 最大人数 + 1
    return (LYCRoomData.manCount - relative + seatNumber) % LYCRoomData.manCount + 1
end

--是否为空或者零
function LYCFuntions.IsNilOrZero(num)
    return IsNil(num) or num == 0
end

function LYCFuntions.GetActive(item)
    return item.gameObject.activeSelf
end

--是否需要抢庄
function LYCFuntions.isRobBanker()
    return true
end

--提示状态码
function LYCFuntions.ToastStatusCode(code)
    local str = LYCStatusCode[code]
    if not IsNil(str) then
        Toast.Show(str)
    end
end

--提示状态码
function LYCFuntions.AlertStatusCode(code)
    local str = LYCStatusCode[code]
    if not IsNil(str) then
        Alert.Show(str)
    end
end

return LYCFuntions