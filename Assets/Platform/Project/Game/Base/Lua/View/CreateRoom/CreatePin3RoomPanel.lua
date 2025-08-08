CreatePin3RoomPanel = ClassLuaComponent("CreatePin3RoomPanel")
CreatePin3RoomPanel.Instance = nil

local this = CreatePin3RoomPanel

function CreatePin3RoomPanel:Init()
    this.createBtn = nil
    this.modifyRuleBtn = nil
    this.juShuFkTran = nil
    this.juShuGoldTran = nil
    this.zhiFuTran = nil
    this.diFenTran = nil
    this.fengDingTran = nil

    this.juShuToggles = nil
    this.juShuFkToggles = nil
    this.juShuGoldToggles = nil
    this.diFenToggles = nil

    this.renShuToggles = nil
    this.zhiFuToggles = nil
    this.lunShuToggles = nil
    this.fengDingToggles = nil
    this.menLunShuToggles = nil
    this.feiJiShouXiToggles = nil
    this.tongHuaShunToggles = nil
    this.StartPeopleCountToggles = nil

    this.fromType = RoomType.Lobby
    this.moneyType = MoneyType.Fangka
    this.args = nil
end

function CreatePin3RoomPanel:Awake()
    this = self
    this.createBtn = self:Find("Content/Config/Bottom/Button/CreateButton").gameObject
    this.modifyBtn = self:Find("Content/Config/Bottom/Button/ModifyButton").gameObject
    this.advancedBtn = self:Find("Content/Config/Bottom/Button/AdvancedButton").gameObject

    this.nameLabel = self:Find("Content/Config/NameText"):GetComponent(TypeText)

    local content = this:Find("Content/Config/ScrollView/Viewport/Content")
    this.juShuFkToggles = {}
    this.juShuFkTran = content:Find("JuShu/JuShuFkToggles")
    this.juShuFkToggles[10] = this.juShuFkTran:Find("JuShuToggle10")
    this.juShuFkToggles[15] = this.juShuFkTran:Find("JuShuToggle15")
    this.juShuFkToggles[20] = this.juShuFkTran:Find("JuShuToggle20")

    this.juShuGoldToggles = {}
    this.juShuGoldTran = content:Find("JuShu/JuShuGoldToggles")
    this.juShuGoldToggles[-1] = this.juShuGoldTran:Find("JuShuToggle0")
    this.juShuGoldToggles[8] = this.juShuGoldTran:Find("JuShuToggle10")
    this.juShuGoldToggles[10] = this.juShuGoldTran:Find("JuShuToggle15")
    this.juShuGoldToggles[20] = this.juShuGoldTran:Find("JuShuToggle20")

    this.renShuToggles = {}
    this.renShuToggles[4] = content:Find("RenShu/RenShuToggle4")
    this.renShuToggles[6] = content:Find("RenShu/RenShuToggle6")
    this.renShuToggles[8] = content:Find("RenShu/RenShuToggle8")

    --1房主付   4大赢家支付
    this.zhiFuToggles = {}
    this.zhiFuTran = content:Find("FangKaZhiFu")
    this.zhiFuToggles[1] = this.zhiFuTran:Find("FangZhuFuToggle")
    this.zhiFuToggles[4] = this.zhiFuTran:Find("DaYingJiaFuToggle")

    this.lunShuToggles = {}
    this.lunShuToggles[10] = content:Find("LunShu/LunShuToggle10")
    this.lunShuToggles[15] = content:Find("LunShu/LunShuToggle15")
    this.lunShuToggles[20] = content:Find("LunShu/LunShuToggle20")

    this.fengDingToggles = {}
    this.fengDingTran = content:Find("FengDing")
    this.fengDingToggles[30] = content:Find("FengDing/FengDingToggle30")
    this.fengDingToggles[50] = content:Find("FengDing/FengDingToggle50")
    this.fengDingToggles[100] = content:Find("FengDing/FengDingToggle100")

    this.menLunShuToggles = {}
    this.menLunShuToggles[0] = content:Find("MenLunShu/MenLunShuToggle0")
    this.menLunShuToggles[1] = content:Find("MenLunShu/MenLunShuToggle1")
    this.menLunShuToggles[2] = content:Find("MenLunShu/MenLunShuToggle2")

    this.feiJiShouXiToggles = {}
    this.feiJiShouXiToggles[0] = content:Find("FeiJiXiQian/XiQianToggle0")
    this.feiJiShouXiToggles[5] = content:Find("FeiJiXiQian/XiQianToggle5")
    this.feiJiShouXiToggles[10] = content:Find("FeiJiXiQian/XiQianToggle10")
    this.feiJiShouXiToggles[15] = content:Find("FeiJiXiQian/XiQianToggle15")
    this.feiJiShouXiToggles[30] = content:Find("FeiJiXiQian/XiQianToggle30")

    this.tongHuaShunToggles = {}
    this.tongHuaShunToggles[0] = content:Find("TongHuaShunXiQian/XiQianToggle0")
    this.tongHuaShunToggles[5] = content:Find("TongHuaShunXiQian/XiQianToggle5")
    this.tongHuaShunToggles[10] = content:Find("TongHuaShunXiQian/XiQianToggle10")
    this.tongHuaShunToggles[15] = content:Find("TongHuaShunXiQian/XiQianToggle15")
    this.tongHuaShunToggles[30] = content:Find("TongHuaShunXiQian/XiQianToggle30")

    this.StartPeopleCountToggles = {}
    this.StartPeopleCountToggles[2] = content:Find("StartPeopleCount/StartPeopleToggle2")
    this.StartPeopleCountToggles[4] = content:Find("StartPeopleCount/StartPeopleToggle4")
    this.StartPeopleCountToggles[31] = content:Find("StartPeopleCount/StartPeopleToggle31")

    this.diFenTran = content:Find("DiFen")
    this.diFenToggles = {}
    this.diFenToggles[50] = this.diFenTran:Find("DiFenToggle50")
    this.diFenToggles[100] = this.diFenTran:Find("DiFenToggle100")

end

--moneyType:   1房卡 2积分
--openFrom：0从大厅打开     1从亲友圈打开    2茶馆打开
function CreatePin3RoomPanel:OnOpened(fromType, funcType, args)
    --if not IsNull(args.menuHelper) then
    --    args.menuHelper:RefreshTogglesItem()
    --    args.menuHelper:CheckIsOnToggle()
    --end
    this.AddListenerEvent()
    this.fromType = fromType
    if IsNil(this.fromType) then
        this.fromType = RoomType.Lobby
    end

    this.moneyType = funcType
    if IsNil(this.moneyType) then
        this.moneyType = MoneyType.Fangka
    end
    if this.moneyType == MoneyType.Fangka then
        this.juShuToggles = this.juShuFkToggles
        UIUtil.SetActive(this.juShuFkTran, true)
        UIUtil.SetActive(this.juShuGoldTran, false)
        UIUtil.SetActive(this.advancedBtn, false)
    elseif this.moneyType == MoneyType.Gold then
        this.juShuToggles = this.juShuGoldToggles
        UIUtil.SetActive(this.juShuFkTran, false)
        UIUtil.SetActive(this.juShuGoldTran, true)
        UIUtil.SetActive(this.zhiFuTran, false)
        UIUtil.SetActive(this.advancedBtn, true)
    end
    this.args = args
    if IsNil(this.args) then
        this.args = {}
    end

    this.isModify = this.args.rules ~= nil
    this.playWayName = this.args.playWayName
    this.rules = this.args.rules
    this.advancedData = this.args.advanceData

    if this.isModify then
        UIUtil.SetActive(this.createBtn, false)
        UIUtil.SetActive(this.modifyBtn, true)
    else
        UIUtil.SetActive(this.createBtn, true)
        UIUtil.SetActive(this.modifyBtn, false)
    end

    --UIUtil.SetActive(this.diFenTran, this.moneyType == MoneyType.Gold)
    UIUtil.SetActive(this.zhiFuTran, this.moneyType == MoneyType.Fangka)
    UIUtil.SetActive(this.fengDingTran, this.moneyType == MoneyType.Fangka)

    this.InitFkShow()

    this:AddOnClick(this.createBtn, this.OnClickCreateRoomBtn)
    this:AddOnClick(this.modifyBtn, this.OnClickCreateRoomBtn)
    this:AddOnClick(this.advancedBtn, this.OnAdvancedBtnClick)
    --Log("OnOpened", fromType, funcType, GetTableString(this.args))

    this.nameLabel.text = Pin3Config.PlayWayNames[1]
    if args.menuToggleDict ~= nil then
        local item = args.menuToggleDict[GameType.Pin3]
        if item ~= nil then
            local listItem = item.list[1]
            listItem.toggle.isOn = true

            if this.isModify then
                for i = 1, #item.list do
                    item.list[i].toggle.interactable = false
                end
            else
                for i = 1, #item.list do
                    item.list[i].toggle.interactable = true
                end
            end
        end
    end
    if this.isModify then
        this.RevertLastModifyDisplay()
    end
end

function CreatePin3RoomPanel.AddListenerEvent()
    AddEventListener(CMD.Game.UpdateNewCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

function CreatePin3RoomPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.UpdateNewCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

--更新创建房间高级设置
function CreatePin3RoomPanel.OnUpdateCreateRoomAdvanced(data)
    this.advancedData = data
    --LogError('this.advancedData', this.advancedData)
    CreateRoomConfig.SaveAdvancedData(GameType.Pin3, this.lastPlayWayType, data)
end

--高级设置按钮
function CreatePin3RoomPanel.OnAdvancedBtnClick()
    PanelManager.Open(PanelConfig.CreateRoomAdvanced, this.advancedData, Pin3Config.DiFenConfig, Pin3Config.DiFenNameConfig, GameType.Pin3)
end

--初始化房卡显示相关控制
function CreatePin3RoomPanel.InitFkShow()
    for juShu, toggle in pairs(this.juShuToggles) do
        this:AddOnToggle(toggle, function(isOn)
            if isOn then
                local curRenShu = 0
                for num, toggle1 in pairs(this.renShuToggles) do
                    if UIUtil.GetToggle(toggle1) then
                        curRenShu = num
                        break
                    end
                end
                --local config = this.GetFkConfig(curRenShu, juShu)
                local config = this.GetNewFKConfig(juShu)
                if config ~= nil then
                    SendEvent(CMD.Game.UpdateCreateRoomConsume, config.fkNum)
                end
            end
        end)
    end

    for renShu, toggle in pairs(this.renShuToggles) do
        this:AddOnToggle(toggle, function(isOn)
            if isOn then
                local curJuShu = 0
                for num, toggle1 in pairs(this.juShuToggles) do
                    if UIUtil.GetToggle(toggle1) then
                        curJuShu = num
                        break
                    end
                end
                --local config = this.GetFkConfig(renShu, curJuShu)
                local config = this.GetNewFKConfig(curJuShu)
                if config ~= nil then
                    SendEvent(CMD.Game.UpdateCreateRoomConsume, config.fkNum)
                end
            end
        end)
    end

    local curJuShu = 0
    for num, toggle1 in pairs(this.juShuToggles) do
        if UIUtil.GetToggle(toggle1) then
            curJuShu = num
            break
        end
    end

    local curRenShu = 0
    for num, toggle1 in pairs(this.renShuToggles) do
        if UIUtil.GetToggle(toggle1) then
            curRenShu = num
            break
        end
    end
    --local config = this.GetFkConfig(curRenShu, curJuShu)
    local config = this.GetNewFKConfig(curJuShu)
    if config ~= nil then
        SendEvent(CMD.Game.UpdateCreateRoomConsume, config.fkNum)
    end
end

function CreatePin3RoomPanel.RevertLastModifyDisplay()
    this.SetAllTogglesFalse(this.juShuGoldToggles)
    UIUtil.SetToggle(this.juShuGoldToggles[this.rules.JS], true)
    this.SetAllTogglesFalse(this.renShuToggles)
    UIUtil.SetToggle(this.renShuToggles[this.rules.MAX_NUM], true)
    this.SetAllTogglesFalse(this.lunShuToggles)
    UIUtil.SetToggle(this.lunShuToggles[this.rules.MAX_COUNT], true)
    this.SetAllTogglesFalse(this.menLunShuToggles)
    UIUtil.SetToggle(this.menLunShuToggles[this.rules.MUST_MEN], true)
    this.SetAllTogglesFalse(this.feiJiShouXiToggles)
    local AirPlaneIndex = this.rules.XI_FJ / this.advancedData.diFen
    UIUtil.SetToggle(this.feiJiShouXiToggles[AirPlaneIndex], true)
    this.SetAllTogglesFalse(this.tongHuaShunToggles)
    local THSIndex = this.rules.XI_THS / this.advancedData.diFen
    UIUtil.SetToggle(this.tongHuaShunToggles[THSIndex], true)
end

function CreatePin3RoomPanel.SetAllTogglesFalse(toggles)
    for _, v in pairs(toggles) do
        UIUtil.SetToggle(v, false)
    end
end

function CreatePin3RoomPanel.OnClickCreateRoomBtn()
    --Log("OnClickCreateRoomBtn")
    if GameManager.IsCheckGame(GameType.Pin3) then
        local rules = this.GetCreateRoomRules()
        if not this.advancedData then
            Toast.Show("请输入高级设置")
            return
        end
        local baseScore = this.advancedData.diFen
        local zhunRu = this.advancedData.enterNum
        local kickNum = this.advancedData.kickNum
        if not IsNumber(baseScore) then
            Toast.Show("请输入正确的底分")
            return
        end
        --if baseScore < 1 then
        --    Toast.Show("底分最低为1分")
        --    return
        --end

        if zhunRu == nil or zhunRu < baseScore then
            Toast.Show("准入分数必须大于底分")
            return
        end
        local userNum = rules[Pin3RuleType.maxUserNum]
        local juShu = rules[Pin3RuleType.juShu]
        if this.fromType == RoomType.Lobby then
            BaseTcpApi.SendCreateRoom(GameType.Pin3, rules, userNum, juShu, this.fromType, this.moneyType, this.GetNewFKConfig(juShu).configId, 0, rules[Pin3RuleType.payType])
        elseif this.fromType == RoomType.Club then

        elseif this.fromType == RoomType.Tea then
            if not IsNil(this.args) then
                if not IsNil(this.args.unionCallback) then
                    --LogError("kickNum", kickNum)
                    --LogError("advancedData", this.advancedData)
                    local data = Functions.PackGameRule(GameType.Pin3, rules, rules[Pin3RuleType.playType], juShu, userNum, this.GetNewFKConfig(juShu).configId, rules[Pin3RuleType.payType], baseScore, zhunRu, kickNum, this.advancedData.remarkStr, "", "", this.advancedData.keepBaseNum or 0, 2, this.advancedData.allToggle and 0 or 1, this.advancedData.expressionNum or 0, this.advancedData.bdPer)
                    this.args.unionCallback(this.args.type, data)
                end
            end
        end
    end
end

function CreatePin3RoomPanel.CheckAdvanceInfoInput()
    if not this.advancedData then
        Toast.Show("请输入高级设置")
        return false
    end
    return true
end

function CreatePin3RoomPanel.GetCreateRoomRules()
    if this.CheckAdvanceInfoInput() then
        local rules = {}
        rules[Pin3RuleType.playType] = 1

        local baseScore = 1
        local zhunRu = 100
        if this.moneyType == MoneyType.Gold then
            --for num, toggle in pairs(this.diFenToggles) do
            --    if UIUtil.GetToggle(toggle) then
            --        baseScore = num
            --        break
            --    end
            --end
            baseScore = this.advancedData.diFen
            rules[Pin3RuleType.baseScore] = baseScore
            rules[Pin3RuleType.zhuiRu] = this.advancedData.enterNum--Pin3Config.GetZhunRu(baseScore)
            rules[Pin3RuleType.JieSanFenShu] = this.advancedData.kickNum
        else
            rules[Pin3RuleType.baseScore] = this.advancedData.diFen
            rules[Pin3RuleType.zhuiRu] = this.advancedData.enterNum
            rules[Pin3RuleType.JieSanFenShu] = this.advancedData.kickNum
        end
        for num, toggle in pairs(this.juShuToggles) do
            if UIUtil.GetToggle(toggle) then
                rules[Pin3RuleType.juShu] = num
                break
            end
        end

        for num, toggle in pairs(this.renShuToggles) do
            if UIUtil.GetToggle(toggle) then
                rules[Pin3RuleType.maxUserNum] = num
                break
            end
        end

        for num, toggle in pairs(this.zhiFuToggles) do
            if UIUtil.GetToggle(toggle) then
                rules[Pin3RuleType.payType] = num
                break
            end
        end
        if this.fromType == RoomType.Club or this.fromType == RoomType.Tea then
            rules[Pin3RuleType.payType] = 3
        end

        for num, toggle in pairs(this.lunShuToggles) do
            if UIUtil.GetToggle(toggle) then
                rules[Pin3RuleType.maxLunShu] = num
                break
            end
        end

        if this.moneyType == MoneyType.Gold then
            --    rules[Pin3RuleType.fengZhu] = Pin3Config.GetFengDing(baseScore)
            --else
            --    for num, toggle in pairs(this.fengDingToggles) do
            --        if UIUtil.GetToggle(toggle) then
            --            rules[Pin3RuleType.fengZhu] = num * baseScore
            --            break
            --        end
            --    end
            rules[Pin3RuleType.fengZhu] = 8 * baseScore
        end

        for num, toggle in pairs(this.menLunShuToggles) do
            if UIUtil.GetToggle(toggle) then
                rules[Pin3RuleType.menLunShu] = num
                break
            end
        end

        for num, toggle in pairs(this.feiJiShouXiToggles) do
            if UIUtil.GetToggle(toggle) then
                LogError("<color=aqua>num</color>", num)
                rules[Pin3RuleType.feiJiXiQian] = num * baseScore
                break
            end
        end

        for num, toggle in pairs(this.tongHuaShunToggles) do
            if UIUtil.GetToggle(toggle) then
                rules[Pin3RuleType.tongHuaShunXiQian] = num * baseScore
                break
            end
        end

        for num, toggle in pairs(this.StartPeopleCountToggles) do
            if UIUtil.GetToggle(toggle) then
                rules[Pin3RuleType.START_NUM] = num
                break
            end
        end

        Log("获取规则", rules)
        return rules
    end
end

--获取房卡配置 key值前2位表示局数，第三位表示人数
local fkConfig = {
    [104] = { configId = 101701, fkNum = 6 },
    [106] = { configId = 101702, fkNum = 8 },
    [108] = { configId = 101703, fkNum = 10 },
    [154] = { configId = 101704, fkNum = 8 },
    [156] = { configId = 101705, fkNum = 10 },
    [158] = { configId = 101706, fkNum = 12 },
    [204] = { configId = 101707, fkNum = 10 },
    [206] = { configId = 101708, fkNum = 12 },
    [208] = { configId = 101709, fkNum = 15 },
}
function CreatePin3RoomPanel.GetFkConfig(userNum, juShu)
    if IsNumber(userNum) and IsNumber(juShu) then
        local config = fkConfig[juShu * 10 + userNum]
        if config == nil then
            config = { configId = 0 }
        end
        return config
    else
        return { configId = 0 }
    end
end

local newFKConfig = {
    [8] = { fkNum = 8, },
    [10] = { fkNum = 10 },
    [20] = { fkNum = 15 },
}

function CreatePin3RoomPanel.GetNewFKConfig(juShu)
    return newFKConfig[juShu]
end

function CreatePin3RoomPanel:OnClosed()
    this.RemoveListenerEvent()
end