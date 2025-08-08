CreatePin5RoomPanel = ClassLuaComponent("CreatePin5RoomPanel")
CreatePin5RoomPanel.Instance = nil

local this = CreatePin5RoomPanel

function CreatePin5RoomPanel:Init()
    this.lastPlayWayType = Pin5PlayType.MingPaiQiangZhuang  --最后一次玩法类型
    this.roomType = RoomType.Lobby --打开面板的来源
    --创建房间的功能类型
    this.moneyType = MoneyType.Gold  --11
    this.groupId = 0 --组织ID，即亲友圈或者茶馆
    this.playWayRuleDatas = nil  --玩法规则的数据
    this.createClickTime = 0 --创建点击时间
    this.lobbyPlayWayData = nil--大厅玩法数据
    this.createClickTime = 0--创建点击时间
    this.isNotTogglePress = false
    this.isOpend = false
    --当前高级设置数据
    this.advancedData = nil
    --是否修改
    this.isModify = false
end

function CreatePin5RoomPanel:Awake()
    this = self
    self:Init()
    local content = this:Find("Content")

    this.nameLabel = self:Find("Content/RuleContent/NameText"):GetComponent(TypeText)

    this.menuTrans = content:Find("Menu")
    local playWayContent = this.menuTrans:Find("ScrollView/Viewport/Content")
    local len = playWayContent.childCount
    this.playWayMenuItems = {}
    for i = 1, len do
        local item = playWayContent:GetChild(i - 1)
        local playWayMenuItem = {}
        this.playWayMenuItems[i] = playWayMenuItem
        playWayMenuItem.gameObject = item.gameObject
        playWayMenuItem.toggle = item:GetComponent("Toggle")
    end

    --规则面板
    local ruleNode = content:Find("RuleContent")
    this.scrollRect = ruleNode:Find("1"):GetComponent(TypeScrollRect)
    this.mingPaiPlayWayNode = ruleNode:Find("1/ViewPort/Content")
    this.playerTotalDrop = this.mingPaiPlayWayNode:Find("Line1/PlayerTotal/Dropdown"):GetComponent("Dropdown")  --桌子人数

    this.baseCoreDrop = this.mingPaiPlayWayNode:Find("Line1/BaseCore/Dropdown"):GetComponent("Dropdown")   --底分

    this.gameTotalDrop = this.mingPaiPlayWayNode:Find("Line2/GameTotal/Dropdown"):GetComponent("Dropdown")   --局数

    this.startModelDrop = this.mingPaiPlayWayNode:Find("Line2/StartModel/Dropdown"):GetComponent("Dropdown")  --开始模式

    this.maxQiangDrop = this.mingPaiPlayWayNode:Find("Line3/MaxQiangZhuang/Dropdown"):GetComponent("Dropdown")  --最大抢庄

    this.laiZiDrop = this.mingPaiPlayWayNode:Find("Line3/LaiZi/Dropdown"):GetComponent("Dropdown")   --癞子玩法

    this.tuiZhuDrop = this.mingPaiPlayWayNode:Find("Line4/TuiZhu/Dropdown"):GetComponent("Dropdown")   --推注

    this.zhifuDrop = this.mingPaiPlayWayNode:Find("Line4/PayType/Dropdown"):GetComponent("Dropdown")  -- 支付方式
    this.zhifuGo = this.mingPaiPlayWayNode:Find("Line4/PayType").gameObject

    this.fanBeiDrop = this.mingPaiPlayWayNode:Find("Line5/FanBeiRule/Dropdown"):GetComponent("Dropdown")   --翻倍规则

    --特殊牌型
    this.specialCards = this.mingPaiPlayWayNode:Find("Line6/SpecialType/OpenSpeicalBtn")
    this.specialCardBtn = this.specialCards:GetComponent(TypeButton)
    this.specialCardTxt = this.mingPaiPlayWayNode:Find("Line6/SpecialType/Text"):GetComponent(TypeText)
    --具体牛型Toggle
    this.niuCardType = {}
    this.niuCardNode = this.mingPaiPlayWayNode:Find("Line6/NiuTypeGroup")
    local niuContent = this.niuCardNode:Find("Content")
    local len = niuContent.childCount
    for i = 1, len do
        local item = niuContent:GetChild(i - 1)
        local niuTypeMenuItem = {}
        this.niuCardType[i] = niuTypeMenuItem
        niuTypeMenuItem.gameObject = item.gameObject
        niuTypeMenuItem.toggle = item:GetComponent("Toggle")
        niuTypeMenuItem.labelTxt = item:Find("Label"):GetComponent(TypeText)
    end
    --高级选项
    this.highOption = this.mingPaiPlayWayNode:Find("Line7/HighOption/OpenOptionBtn")
    this.highOptionBtn = this.highOption:GetComponent(TypeButton)
    this.highOptionTxt = this.mingPaiPlayWayNode:Find("Line7/HighOption/Text"):GetComponent(TypeText)

    --具体高级选项
    this.optionType = {}
    this.optionGroupNode = this.mingPaiPlayWayNode:Find("Line7/OptionGroup")
    local optionContent = this.optionGroupNode:Find("Content")
    local len = optionContent.childCount
    for i = 1, len do
        local item = optionContent:GetChild(i - 1)
        local optionTypeItem = {}
        optionTypeItem.gameObject = item.gameObject
        optionTypeItem.toggle = item:GetComponent("Toggle")
        this.optionType[i] = optionTypeItem
    end

    this.closeOptionBtn = this.mingPaiPlayWayNode:Find("Line7/CloseOptionBtn")
    this.closeSpecialBtn = this.mingPaiPlayWayNode:Find("Line6/CloseSpecialBtn")

    --准入
    local zhunRu = this.mingPaiPlayWayNode:Find("Line8")
    this.zhunRuGo = zhunRu.gameObject
    this.zhunRuInput = zhunRu:Find("InputField"):GetComponent(TypeInputField)
    --表情赠送
    local zhuoFei = this.mingPaiPlayWayNode:Find("Line9")
    this.zhuoFeiGo = zhuoFei.gameObject
    this.zhuoFeiInput = zhuoFei:Find("InputField"):GetComponent(TypeInputField)
    --最低赠送
    local zhuoFeiMin = this.mingPaiPlayWayNode:Find("Line10")
    this.zhuoFeiMinGo = zhuoFeiMin.gameObject
    this.zhuoFeiMinInput = zhuoFeiMin:Find("InputField"):GetComponent(TypeInputField)
    --解散分数
    local jieSanFenShu = this.mingPaiPlayWayNode:Find("Line11")
    this.jieSanFenShuGo = jieSanFenShu.gameObject
    this.jieSanFenShuInput = jieSanFenShu:Find("InputField"):GetComponent(TypeInputField)

    -----------------------------------
    local bottom = ruleNode:Find("Bottom")
    this.createBtn = bottom:Find("Button/CreateButton").gameObject
    this.addRuleBtn = bottom:Find("Button/SaveButton")
    this.removeRuleBtn = bottom:Find("Button/DeleteButton")
    this.advancedBtn = bottom:Find("Button/AdvancedButton").gameObject
    this.modifyBtn = bottom:Find("Button/ModifyButton").gameObject

    this.tips = bottom:Find("Tips").gameObject

    this.AddUIListenerEvent()

    this.playerTotalDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.playerTotalDrop, Pin5RulePlayerNumberList)
    this.baseCoreDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.baseCoreDrop, Pin5RuleDiFen)

    this.startModelDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.startModelDrop, Pin5RuleStartModelList)
    this.gameTotalDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.gameTotalDrop, Pin5RuleJuShuList)

    this.maxQiangDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.maxQiangDrop, Pin5RuleQiangZhuangList)
    this.laiZiDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.laiZiDrop, Pin5RuleLaiZiType)

    this.tuiZhuDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.tuiZhuDrop, Pin5RuleBolusList)
    this.zhifuDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.zhifuDrop, Pin5RulePayList)

    this.fanBeiDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.fanBeiDrop, Pin5RuleFanBeiRule)
end

--functionType：0普通创建房间   1一键开房配置    2一键开房       3创建其他房间
--openFrom：0从大厅打开     1从亲友圈打开    2茶馆打开
function CreatePin5RoomPanel:OnOpened(fromType, funcType, args)
    this.scrollRect.content.localPosition.y = 0
    this.AddListnerEvent()

    this.rules = args.rules
    this.advancedData = args.advancedData

    this.CheckArgsData(fromType, funcType, args)

    --处理高级设置按钮显示
    if this.moneyType == MoneyType.Gold then
        UIUtil.SetActive(this.advancedBtn, true)
    else
        UIUtil.SetActive(this.advancedBtn, false)
    end

    if this.isModify then
        UIUtil.SetActive(this.createBtn, false)
        UIUtil.SetActive(this.modifyBtn, true)
    else
        UIUtil.SetActive(this.createBtn, true)
        UIUtil.SetActive(this.modifyBtn, false)
    end

    this.InitExternalMenu(args.menuToggleDict)
    this.CheckButtonDisplay()
    this.CheckAndUpdateConfigData()
    if this.isModify then
        this.RevertLastModifyDisplay()
    end
    this.isOpend = true
end

--
function CreatePin5RoomPanel:OnClosed()
    this.SavePlayWayConfigData()
    this.isAddYjkfConfig = false
    this.RemoveListenerEvent()
    this.isOpend = false
    UIUtil.SetActive(this.niuCardNode, false)
    UIUtil.SetActive(this.optionGroupNode, false)
    --
    this.advancedData = nil
end

---UI监听事件
function CreatePin5RoomPanel:AddUIListenerEvent()
    this:AddOnClick(this.createBtn, this.OnCreateBtnClick)
    this:AddOnClick(this.addRuleBtn, this.OnSaveBtnClick)
    this:AddOnClick(this.removeRuleBtn, this.OnDeleteBtnClick)
    this:AddOnClick(this.advancedBtn, this.OnAdvancedBtnClick)
    this:AddOnClick(this.modifyBtn, this.OnCreateBtnClick)

    local length = #this.playWayMenuItems
    for i = 1, length do
        local playWayMenuItem = this.playWayMenuItems[i]
        UIToggleListener.AddListener(playWayMenuItem.gameObject, this.OnPlayWayMenuValueChanged)
    end
    this.playerTotalDrop.onValueChanged:AddListener(this.OnPlayerTotalDropDown)  --桌数
    this.baseCoreDrop.onValueChanged:AddListener(this.OnBaseCoreDropDown)
    this.gameTotalDrop.onValueChanged:AddListener(this.OnGameTotalDropDown)
    this.tuiZhuDrop.onValueChanged:AddListener(this.OnTuiZhuDropDown)
    this.maxQiangDrop.onValueChanged:AddListener(this.OnMaxQiangDropDown)
    this.laiZiDrop.onValueChanged:AddListener(this.OnLaiZiDropDown)
    this.fanBeiDrop.onValueChanged:AddListener(this.OnFanBeiDropDown)
    this.startModelDrop.onValueChanged:AddListener(this.OnStartModelDropDown)
    this.zhifuDrop.onValueChanged:AddListener(this.OnPayDropDown)  --支付

    for i = 1, 7 do
        UIToggleListener.AddListener(this.niuCardType[i].gameObject, this.OnNiuTypeValueChanged)
    end
    UIToggleListener.AddListener(this.niuCardType[8].gameObject, this.AllNiuTypeValueChanged)  --特殊牌型的全选
    for i = 1, 4 do
        UIToggleListener.AddListener(this.optionType[i].gameObject, this.OnOptionValueChanged)
    end
    UIToggleListener.AddListener(this.optionType[5].gameObject, this.AllOptionValueChanged)  --高级选项的全选
    this:AddOnClick(this.specialCards, this.OnSpecialCardBtnClick)
    this:AddOnClick(this.highOption, this.OnHighOptionBtnClick)
    this:AddOnClick(this.closeOptionBtn, this.OnCloseOptionBtnClick)
    this:AddOnClick(this.closeSpecialBtn, this.OnCloseSpecialBtnClick)
end

function CreatePin5RoomPanel.AddListnerEvent()
    AddEventListener(CMD.Game.UpdateNewCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

function CreatePin5RoomPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.UpdateNewCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

------------------------------------------------------------------
--
function CreatePin5RoomPanel.CheckArgsData(fromType, moneyType, args)
    --处理打开面板的来源
    this.roomType = fromType
    if IsNil(this.roomType) then
        this.roomType = RoomType.Lobby
    end

    this.moneyType = moneyType
    if IsNil(this.moneyType) then
        this.moneyType = MoneyType.Fangka
    end

    this.groupId = 0
    this.args = args
    if IsNil(this.args) then
        this.args = {}
    end
    this.isModify = this.args.rules ~= nil
    this.advancedData = this.args.advanceData

    if this.roomType == RoomType.Lobby then
        this.CheckLobbyPlayWayData()
        this.lastPlayWayType = Pin5PlayType.MingPaiQiangZhuang
        this.playWayRuleDatas = this.lobbyPlayWayData.ruleDatas
    elseif this.roomType == RoomType.Tea then
        this.lobbyPlayWayData = nil
        this.playWayRuleDatas = {}
        if this.isModify then
            --表示修改
            this.lastPlayWayType = Pin5Config.GetPlaywayTypeByName(this.args.playWayName)
            this.lastPlayWayName = this.args.playWayName
            this.playWayRuleDatas[this.lastPlayWayType] = this.args.rules
        end
    else
        this.playWayRuleDatas = {}
        this.otherArgs = {}
        if args ~= nil then
            --处理参数
            if args.groupId ~= nil then
                this.groupId = args.groupId
            end
            --
            --获取规则
            local temp = args[GameType.Pin5]
            if temp ~= nil then
                for k, v in pairs(temp) do
                    if not IsNull(v.option) then
                        local tempObj = JsonToObj(v.option)
                        tempObj.isConfig = true
                        this.playWayRuleDatas[k] = tempObj
                    end
                    this.otherArgs[k] = { key = v.key }
                end
            end
        end
    end
end

function CreatePin5RoomPanel.InitExternalMenu(listToggles)
    if listToggles ~= nil and this.externalMenuItems == nil then
        this.externalMenuItems = {}
        local item = listToggles[GameType.Pin5]
        if item ~= nil then
            local listItem = nil
            for i = 1, #item.list do
                listItem = item.list[i]
                this.externalMenuItems[i] = listItem
                UIToggleListener.AddListener(listItem.gameObject, this.OnPlayWayMenuValueChanged)
            end
        end
    end
end

--检测按钮显示
function CreatePin5RoomPanel.CheckButtonDisplay()
    --UIUtil.SetActive(this.tips, this.roomType == RoomType.Lobby)
    --UIUtil.SetActive(this.zhifuGo, this.roomType == RoomType.Lobby)

    --LogError(this.roomType, this.moneyType)

    local isGold = this.moneyType == MoneyType.Gold

    -- UIUtil.SetActive(this.zhunRuGo, isGold)
    -- UIUtil.SetActive(this.zhuoFeiGo, isGold)
    -- UIUtil.SetActive(this.zhuoFeiMinGo, isGold)
    -- UIUtil.SetActive(this.jieSanFenShuGo, isGold)
end

function CreatePin5RoomPanel.RevertLastModifyDisplay()
    LogError("<color=aqua>rules</color>", this.rules)
    this.playerTotalDrop.value = this.GetDropdownIndexOfConfig(Pin5RulePlayerNumberConfig, Pin5RuleType.GameTotal)
    this.baseCoreDrop.value = this.GetDropdownIndexOfConfig(Pin5RuleDiFenConfig, Pin5RuleType.BaseScore)
    this.startModelDrop.value = this.GetDropdownIndexOfConfig(Pin5RuleStartModelConfig, Pin5RuleType.StartModel)
    this.gameTotalDrop.value = this.GetDropdownIndexOfConfig(Pin5RuleJuShuConfig, Pin5RuleType.JuShu)
    this.maxQiangDrop.value = this.GetDropdownIndexOfConfig(Pin5RuleQiangZhuangConfig, Pin5RuleType.MaxQiangZhuang)

    LogError("<color=aqua>this.GetDropdownIndexOfConfig(Pin5RuleLaiZiType, Pin5RuleType.LaiZi)</color>", this.GetDropdownIndexOfConfig(Pin5RuleLaiZiType, Pin5RuleType.LaiZi))
    this.laiZiDrop.value = this.GetDropdownIndexOfConfig(Pin5RuleLaiZiTypeConfig, Pin5RuleType.LaiZi)
    this.tuiZhuDrop.value = this.GetDropdownIndexOfConfig(Pin5RuleBolusConfig, Pin5RuleType.TuiZhu)
    this.fanBeiDrop.value = this.GetDropdownIndexOfConfig(Pin5RuleFanBeiRuleConfig, Pin5RuleType.FanBeiRule)

    local specialCardTypes = string.split(this.rules[Pin5RuleType.SpecialCard], ",")
    this.niuCardType[1].toggle.isOn = table.ContainValue(specialCardTypes, tostring(Pin5RuleTeShu[Pin5RuleType.WuHuaNiu]))
    this.niuCardType[2].toggle.isOn = table.ContainValue(specialCardTypes, tostring(Pin5RuleTeShu[Pin5RuleType.ShunZiNiu]))
    this.niuCardType[3].toggle.isOn = table.ContainValue(specialCardTypes, tostring(Pin5RuleTeShu[Pin5RuleType.TongHuaNiu]))
    this.niuCardType[4].toggle.isOn = table.ContainValue(specialCardTypes, tostring(Pin5RuleTeShu[Pin5RuleType.HuLuNiu]))
    this.niuCardType[5].toggle.isOn = table.ContainValue(specialCardTypes, tostring(Pin5RuleTeShu[Pin5RuleType.ZhaDanNiu]))
    this.niuCardType[6].toggle.isOn = table.ContainValue(specialCardTypes, tostring(Pin5RuleTeShu[Pin5RuleType.WuXiaoNiu]))
    this.niuCardType[7].toggle.isOn = table.ContainValue(specialCardTypes, tostring(Pin5RuleTeShu[Pin5RuleType.TongHuaShunNiu]))
end

function CreatePin5RoomPanel.GetDropdownIndexOfConfig(config, Pin5RuleType)
    local index = 0
    for i = 1, #config do
        if config[i] == this.rules[Pin5RuleType] then
            index = i
        end
    end
    return index - 1
end

function CreatePin5RoomPanel.CheckAndUpdateConfigData()
    local playWayMenuItems = this.playWayMenuItems
    local playWayMenuItem = nil
    if this.externalMenuItems ~= nil then
        playWayMenuItems = this.externalMenuItems
    end

    playWayMenuItem = playWayMenuItems[1]
    if playWayMenuItem ~= nil then
        playWayMenuItem.toggle.isOn = false
        playWayMenuItem.toggle.isOn = true
    end

    local length = #playWayMenuItems
    if this.isModify then
        for i = 1, length do
            playWayMenuItems[i].toggle.interactable = false
        end
    else
        for i = 1, length do
            playWayMenuItems[i].toggle.interactable = true
        end
    end

    local ruleData = this.playWayRuleDatas[this.lastPlayWayType]
    if ruleData == nil then
        ruleData = {}
    end

    this.nameLabel.text = Pin5RulePlayTypeName[this.lastPlayWayType]

    this.SetRuleUI(ruleData)
    this.UpdateNiuCardTxt()
    this.UpdateOptionTxt()
    this.UpdateConsumeDisplay()
end

function CreatePin5RoomPanel.CheckLobbyPlayWayData()
    if this.lobbyPlayWayData == nil then
        this.lobbyPlayWayData = {}
        this.lobbyPlayWayData.ruleDatas = {}
        local temp = nil
        local str = GetLocal(LocalDatas.Pin5PlayWayData, nil)
        if str ~= nil then
            temp = JsonToObj(str)
        end
        Log('=====CheckLobbyPlayWayData====', str)
        if temp ~= nil then
            this.lobbyPlayWayData.lastPlayWayType = temp.lastPlayWayType
            if this.lobbyPlayWayData.lastPlayWayType == nil then
                this.lobbyPlayWayData.lastPlayWayType = Pin5PlayType.MingPaiQiangZhuang
            end
            Log('====temp ~= nil====', temp.ruleDatas)
            if temp.ruleDatas ~= nil then
                local length = #temp.ruleDatas
                local playWayType = nil
                local ruleData = nil
                for i = 1, length do
                    ruleData = temp.ruleDatas[i]

                    if IsTable(ruleData) then
                        ruleData.isConfig = false

                        playWayType = ruleData[Pin5RuleType.PlayType]
                        if playWayType ~= nil then
                            this.lobbyPlayWayData.ruleDatas[playWayType] = ruleData
                        end
                    end
                end
            end
        end
    end
end

--玩家总数
function CreatePin5RoomPanel.OnPlayerTotalDropDown(value)
    this.UpdateConsumeDisplay()
end
--底分
function CreatePin5RoomPanel.OnBaseCoreDropDown(value)
    --Log('OnBaseCoreDropDown', value)
    --this.CheckRuleValue(Pin5RuleType.BaseScore, value)
end

--局数
function CreatePin5RoomPanel.OnGameTotalDropDown(value)
    this.UpdateConsumeDisplay()
end

--开始模式
function CreatePin5RoomPanel.OnStartModelDropDown(value)
    --this.CheckRuleValue(Pin5RuleType.StartModel, value)
end

function CreatePin5RoomPanel.OnPayDropDown(value)
    --this.CheckRuleValue(Pin5RuleType.PayType, value)
end

--推注
function CreatePin5RoomPanel.OnTuiZhuDropDown(value)
    --this.CheckRuleValue(Pin5RuleType.TuiZhu, value)
end
--最大抢庄
function CreatePin5RoomPanel.OnMaxQiangDropDown(value)
    --this.CheckRuleValue(Pin5RuleType.MaxQiangZhuang, value)
end

--癞子
function CreatePin5RoomPanel.OnLaiZiDropDown(value)
    --this.CheckRuleValue(Pin5RuleType.LaiZi, value)
end
--翻倍规则
function CreatePin5RoomPanel.OnFanBeiDropDown(value)
    --this.CheckRuleValue(Pin5RuleType.FanBeiRule, value)
    this.UpdateNiuCardTxt()
end

--通过Dropdown索引获取值
function CreatePin5RoomPanel.CheckRuleValue(ruleType, index)
    local tempValue = 0
    if ruleType == Pin5RuleType.TuiZhu then
        tempValue = Pin5Config.GetConfigValue(Pin5RuleBolusConfig, index)
    elseif ruleType == Pin5RuleType.JuShu then
        tempValue = Pin5Config.GetConfigValue(Pin5RuleJuShuConfig, index)
    elseif ruleType == Pin5RuleType.GameTotal then
        tempValue = Pin5Config.GetConfigValue(Pin5RulePlayerNumberConfig, index)
    elseif ruleType == Pin5RuleType.PayType then
        tempValue = Pin5Config.GetConfigValue(Pin5RulePayConfig, index)
    elseif ruleType == Pin5RuleType.StartModel then
        tempValue = Pin5Config.GetConfigValue(Pin5RuleStartModelConfig, index)
    else
        tempValue = index + 1
    end
    return tempValue
end

--检测输入值
function CreatePin5RoomPanel.CheckInputValue(value)
    local temp = tonumber(value)
    if temp == nil then
        return 0
    end
    return temp
end

--纠正Dropdown中的索引
function CreatePin5RoomPanel.ExchangeDropValueByRule(ruleType, ruleValue)
    if ruleType == Pin5RuleType.TuiZhu then
        this.tuiZhuDrop.value = Pin5Config.GetConfigIndex(Pin5RuleBolusConfig, ruleValue)
    elseif ruleType == Pin5RuleType.GameTotal then
        this.playerTotalDrop.value = Pin5Config.GetConfigIndex(Pin5RulePlayerNumberConfig, ruleValue)
    elseif ruleType == Pin5RuleType.BaseScore then
        this.baseCoreDrop.value = ruleValue - 1
    elseif ruleType == Pin5RuleType.StartModel then
        this.startModelDrop.value = Pin5Config.GetConfigIndex(Pin5RuleStartModelConfig, ruleValue)
    elseif ruleType == Pin5RuleType.JuShu then
        this.gameTotalDrop.value = Pin5Config.GetConfigIndex(Pin5RuleJuShuConfig, ruleValue)
    elseif ruleType == Pin5RuleType.MaxQiangZhuang then
        this.maxQiangDrop.value = Pin5Config.GetConfigIndex(Pin5RuleQiangZhuangConfig, ruleValue)
    elseif ruleType == Pin5RuleType.LaiZi then
        this.laiZiDrop.value = ruleValue - 1
    elseif ruleType == Pin5RuleType.FanBeiRule then
        this.fanBeiDrop.value = ruleValue - 1
    elseif ruleType == Pin5RuleType.PayType then
        this.zhifuDrop.value = Pin5Config.GetConfigIndex(Pin5RulePayConfig, ruleValue)
    end
end

--特殊牌型按钮
function CreatePin5RoomPanel.OnSpecialCardBtnClick()
    UIUtil.SetActive(this.niuCardNode, true)
    UIUtil.SetActive(this.optionGroupNode, false)
    UIUtil.SetActive(this.closeSpecialBtn, true)
    this.CheckSpecialIsAllSlected()
    this.UpdateNiuCardTxt()
end

--高级选项按钮
function CreatePin5RoomPanel.OnHighOptionBtnClick()
    UIUtil.SetActive(this.niuCardNode, false)
    UIUtil.SetActive(this.optionGroupNode, true)
    UIUtil.SetActive(this.closeOptionBtn, true)
    this.CheckOptionAllSlected()
    this.UpdateOptionTxt()
end

function CreatePin5RoomPanel.OnCloseOptionBtnClick()
    UIUtil.SetActive(this.niuCardNode, false)
    UIUtil.SetActive(this.optionGroupNode, false)
    UIUtil.SetActive(this.closeOptionBtn, false)
    this.UpdateOptionTxt()
end

function CreatePin5RoomPanel.OnCloseSpecialBtnClick()
    UIUtil.SetActive(this.niuCardNode, false)
    UIUtil.SetActive(this.optionGroupNode, false)
    UIUtil.SetActive(this.closeSpecialBtn, false)
    UIUtil.SetActive(this.closeOptionBtn, false)
    this.UpdateNiuCardTxt()
end
--判断牛型是否全选
function CreatePin5RoomPanel.CheckSpecialIsAllSlected()
    local isAllSlected = true
    for i = 1, 7 do
        if this.niuCardType[i].toggle.isOn == false then
            isAllSlected = false
            break
        end
    end
    this.isNotTogglePress = true
    this.niuCardType[8].toggle.isOn = isAllSlected
    this.isNotTogglePress = false
end

--判断高级选项是否全选
function CreatePin5RoomPanel.CheckOptionAllSlected()
    local isAllSlected = true
    for i = 1, 4 do
        if this.optionType[i].toggle.isOn == false then
            isAllSlected = false
            break
        end
    end
    this.isNotTogglePress = true
    this.optionType[5].toggle.isOn = isAllSlected
    this.isNotTogglePress = false
end

--特殊类型选择
function CreatePin5RoomPanel.OnNiuTypeValueChanged(isOn, listener)
    if this.isOpend then
        this.CheckSpecialIsAllSlected()
        this.UpdateNiuCardTxt()
    end
end

--特殊牌型的全选
function CreatePin5RoomPanel.AllNiuTypeValueChanged(isOn, listener)
    if this.isNotTogglePress then
        return
    end
    for i = 1, 7 do
        this.niuCardType[i].toggle.isOn = isOn
    end
    this.UpdateNiuCardTxt()
end


--高级选项的选择
function CreatePin5RoomPanel.OnOptionValueChanged(isOn, listener)
    if this.isOpend then
        this.CheckOptionAllSlected()
        this.UpdateOptionTxt()
    end
end

--高级选项的全选
function CreatePin5RoomPanel.AllOptionValueChanged(isOn, listener)
    if this.isNotTogglePress then
        return
    end
    for i = 1, 4 do
        this.optionType[i].toggle.isOn = isOn
    end
    this.UpdateOptionTxt()
end

--更新高级选项文本
function CreatePin5RoomPanel.UpdateOptionTxt()
    local tempStr = ""
    for i = 1, 4 do
        if this.optionType[i].toggle.isOn then
            tempStr = tempStr .. Pin5OptionConfigTxt[i] .. "  "
        end
    end
    if tempStr == "" then
        tempStr = "无"
    end
    this.highOptionTxt.text = tempStr
end

--更新牛型显示文本
function CreatePin5RoomPanel.UpdateNiuCardTxt()
    local tempStr = ""
    local niuMuilt = this.CheckRuleValue(Pin5RuleType.FanBeiRule, this.fanBeiDrop.value)
    for i = 1, 7 do
        if this.niuCardType[i].toggle.isOn then
            tempStr = tempStr .. Pin5Config.GetNiuTypeMuiltTxt(niuMuilt, i) .. "  "
        end
        this.niuCardType[i].labelTxt.text = Pin5Config.GetNiuTypeMuiltTxt(niuMuilt, i)
    end
    if tempStr == "" then
        tempStr = "无"
    end
    this.specialCardTxt.text = tempStr
end

--保存到本地存储中
function CreatePin5RoomPanel.SaveLobbyPlayWayConfigData()
    if this.lobbyPlayWayData ~= nil then
        local temp = {}
        temp.lastPlayWayType = this.lobbyPlayWayData.lastPlayWayType
        if this.lobbyPlayWayData.ruleDatas ~= nil then
            temp.ruleDatas = {}
            for k, v in pairs(this.lobbyPlayWayData.ruleDatas) do
                if IsTable(v) then
                    table.insert(temp.ruleDatas, v)
                end
            end
        end
        local str = ObjToJson(temp)
        SetLocal(LocalDatas.Pin5PlayWayData, str)
    end
end

--保存配置数据
function CreatePin5RoomPanel.SavePlayWayConfigData()
    if this.roomType == RoomType.Lobby or this.roomType == RoomType.Club then
        local playWayRuleData = this.GetPlayWayRuleDataAtUI()
        local temp = this.playWayRuleDatas[this.lastPlayWayType]
        if temp ~= nil and temp.isConfig == true then
            --有配置属性的认为是亲友圈已经配置的，不进行保存
        else
            this.playWayRuleDatas[this.lastPlayWayType] = playWayRuleData
        end
        if this.roomType == RoomType.Lobby then
            --保存选中的玩法类型
            this.lobbyPlayWayData.lastPlayWayType = this.lastPlayWayType
            this.SaveLobbyPlayWayConfigData()
        end
        return playWayRuleData
    else
        return nil
    end
end

--无规则时设置默认规则界面
function CreatePin5RoomPanel.SetDefaultRuleUI()
    this.playerTotalDrop.value = 0
    this.baseCoreDrop.value = 0
    this.startModelDrop.value = 0
    this.gameTotalDrop.value = 0
    this.maxQiangDrop.value = 0
    this.laiZiDrop.value = 0
    this.fanBeiDrop.value = 0
    this.niuCardType[8].toggle.isOn = true
    this.optionType[1].toggle.isOn = false
    this.optionType[4].toggle.isOn = false
    this.optionType[5].toggle.isOn = false

    this.zhunRuInput.text = 0
    this.zhuoFeiInput.text = 0
    this.zhuoFeiMinInput.text = 0
    this.jieSanFenShuInput.text = 0
end

--获取当前选择的UI上的默认字段
function CreatePin5RoomPanel.GetPlayWayRuleDataAtUI()
    --玩法规则对象
    local playWayRuleData = {}
    playWayRuleData[Pin5RuleType.PlayType] = this.lastPlayWayType
    playWayRuleData[Pin5RuleType.RoomType] = this.roomType
    playWayRuleData[Pin5RuleType.GameTotal] = this.CheckRuleValue(Pin5RuleType.GameTotal, this.playerTotalDrop.value)
    playWayRuleData[Pin5RuleType.BaseScore] = this.CheckRuleValue(Pin5RuleType.BaseScore, this.baseCoreDrop.value)
    playWayRuleData[Pin5RuleType.StartModel] = this.CheckRuleValue(Pin5RuleType.StartModel, this.startModelDrop.value)
    playWayRuleData[Pin5RuleType.JuShu] = this.CheckRuleValue(Pin5RuleType.JuShu, this.gameTotalDrop.value)
    playWayRuleData[Pin5RuleType.MaxQiangZhuang] = this.CheckRuleValue(Pin5RuleType.MaxQiangZhuang, this.maxQiangDrop.value)
    playWayRuleData[Pin5RuleType.LaiZi] = this.CheckRuleValue(Pin5RuleType.LaiZi, this.laiZiDrop.value)
    playWayRuleData[Pin5RuleType.FanBeiRule] = this.CheckRuleValue(Pin5RuleType.FanBeiRule, this.fanBeiDrop.value)
    playWayRuleData[Pin5RuleType.TuiZhu] = this.CheckRuleValue(Pin5RuleType.TuiZhu, this.tuiZhuDrop.value)
    playWayRuleData[Pin5RuleType.PayType] = this.CheckRuleValue(Pin5RuleType.PayType, this.zhifuDrop.value)

    playWayRuleData[Pin5RuleType.DiFen] = 1
    playWayRuleData[Pin5RuleType.RobLimit] = 0

    -- if this.roomType == RoomType.Tea then
    --     playWayRuleData[Pin5RuleType.ZhunRu] = this.CheckInputValue(this.zhunRuInput.text)
    --     playWayRuleData[Pin5RuleType.ZhuoFei] = this.CheckInputValue(this.zhuoFeiInput.text)
    --     playWayRuleData[Pin5RuleType.ZhuoFeiMin] = this.CheckInputValue(this.zhuoFeiMinInput.text)
    --     playWayRuleData[Pin5RuleType.JieSanFenShu] = this.CheckInputValue(this.jieSanFenShuInput.text)
    -- end

    if this.roomType == RoomType.Club then
        playWayRuleData[Pin5RuleType.PayType] = 3
    end

    local tempCardType = ""
    tempCardType = this.GetTeShuCardType(Pin5RuleType.WuHuaNiu, this.niuCardType[1], tempCardType)
    tempCardType = this.GetTeShuCardType(Pin5RuleType.ShunZiNiu, this.niuCardType[2], tempCardType)
    tempCardType = this.GetTeShuCardType(Pin5RuleType.TongHuaNiu, this.niuCardType[3], tempCardType)
    tempCardType = this.GetTeShuCardType(Pin5RuleType.HuLuNiu, this.niuCardType[4], tempCardType)
    tempCardType = this.GetTeShuCardType(Pin5RuleType.ZhaDanNiu, this.niuCardType[5], tempCardType)
    tempCardType = this.GetTeShuCardType(Pin5RuleType.WuXiaoNiu, this.niuCardType[6], tempCardType)
    tempCardType = this.GetTeShuCardType(Pin5RuleType.TongHuaShunNiu, this.niuCardType[7], tempCardType)
    playWayRuleData[Pin5RuleType.SpecialCard] = tempCardType

    local tempOptionType = ""
    tempOptionType = this.GetHighOptionCardType(Pin5RuleType.GameStartForbiden, this.optionType[1], tempOptionType)
    tempOptionType = this.GetHighOptionCardType(Pin5RuleType.XiaZhuLimit, this.optionType[2], tempOptionType)
    tempOptionType = this.GetHighOptionCardType(Pin5RuleType.VoiceForbiden, this.optionType[3], tempOptionType)
    tempOptionType = this.GetHighOptionCardType(Pin5RuleType.CuoPaiForbiden, this.optionType[4], tempOptionType)
    playWayRuleData[Pin5RuleType.HighOption] = tempOptionType

    LogError(">> CreatePin5RoomPanel.GetPlayWayRuleDataAtUI > ", playWayRuleData)
    return playWayRuleData
end

function CreatePin5RoomPanel.GetTeShuCardType(type, toggle, str)
    local isOne = this.GetToggleRuleValue(toggle.toggle.isOn) == 1
    if isOne then
        if string.IsNullOrEmpty(str) then
            str = "" .. Pin5RuleTeShu[type]
        else
            str = str .. "," .. Pin5RuleTeShu[type]
        end
    end
    return str
end

function CreatePin5RoomPanel.GetHighOptionCardType(type, toggle, str)
    local isOne = this.GetToggleRuleValue(toggle.toggle.isOn) == 1
    if isOne then
        if string.IsNullOrEmpty(str) then
            str = "" .. Pin5RuleHighOptionMap[type]
        else
            str = str .. "," .. Pin5RuleHighOptionMap[type]
        end
    end
    return str
end

function CreatePin5RoomPanel.GetToggleRuleValue(isOn)
    if isOn then
        return 1
    else
        return 0
    end
end

function CreatePin5RoomPanel.SetRuleUI(rules)
    if rules == nil then
        this.SetDefaultRuleUI()
    else
        --Log('=======SetRuleUI========', rules)
        for ruleType, value in pairs(rules) do
            if ruleType == Pin5RuleType.HighOption then
                --{"rz":1,"ct":1,"pt":1,"pn":6,"pb":1,"tz":0,"kl":1,"js":10,"st":1,"sn":"12,13,14,15,16,17,18","ho":"1,2,3,4","ba":1}
                local ho = string.split(value, ",")

                for i = 1, #this.optionType do
                    this.optionType[i].toggle.isOn = false
                end

                for i = 1, #ho do
                    this.optionType[tonumber(ho[i])].toggle.isOn = true
                end
                if #ho == #this.optionType - 1 then
                    this.optionType[#this.optionType].toggle.isOn = true
                end
            elseif ruleType == Pin5RuleType.SpecialCard then
                local sc = string.split(value, ",")
                for i = 1, #this.niuCardType do
                    this.niuCardType[i].toggle.isOn = false
                end
                for i = 1, #sc do
                    this.niuCardType[tonumber(sc[i]) - 11].toggle.isOn = true
                end
                if #sc == #this.niuCardType - 1 then
                    this.niuCardType[#this.niuCardType].toggle.isOn = true
                end
            else
                this.ExchangeDropValueByRule(ruleType, value)
            end
        end
    end

    this.zhunRuInput.text = this.GetRuleValue(rules, Pin5RuleType.ZhunRu)
    this.zhuoFeiInput.text = this.GetRuleValue(rules, Pin5RuleType.ZhuoFei)
    this.zhuoFeiMinInput.text = this.GetRuleValue(rules, Pin5RuleType.ZhuoFeiMin)
    this.jieSanFenShuInput.text = this.GetRuleValue(rules, Pin5RuleType.JieSanFenShu)
end

--获取规则值
function CreatePin5RoomPanel.GetRuleValue(rules, type)
    local temp = rules[type]
    if temp == nil then
        return 0
    else
        return temp
    end
end

--
local optionData = nil
function CreatePin5RoomPanel.UpdateDropDown(ruleValue)
    local optionDatas = {}
    for i = 1, 3 do
        -- local optionData = OptionData.New()
        if optionData == nil then
            optionData = OptionData.New()
        end
        optionData.text = Pin5RuleStartModel[i]
        table.insert(optionDatas, optionData)
    end
    UIUtil.SetDropdownOptions(this.startModelDrop, optionDatas)
end

function CreatePin5RoomPanel.OnCreateBtnClick()
    if os.time() - this.createClickTime < 3 then
        Toast.Show("请不要频繁操作")
        return
    end
    this.createClickTime = os.time()
    if GameManager.IsCheckGame(GameType.Pin5) then
        if this.roomType == RoomType.Club then
            Alert.Prompt("确定创建亲友圈房间？", this.OnCreateAlert)
        else
            this.HandleCreateRoom()
        end
    end
end

function CreatePin5RoomPanel.OnCreateAlert()
    this.HandleCreateRoom()
end

--高级设置按钮
function CreatePin5RoomPanel.OnAdvancedBtnClick()
    PanelManager.Open(PanelConfig.CreateRoomAdvanced, this.advancedData, Pin5Config.DiFenConfig, Pin5Config.DiFenNameConfig, GameType.Pin5)
end

local tempPlayWayType = Pin5PlayType.MingPaiQiangZhuang
local tempPlayerTotal = 6
local tempGameTotal = 10
local tempGps = 0
local tempConsumeId = 0
local tempPayType = PayType.Owner
local tempRuleDatas = nil
local tempBaseScore = 1
local tempInGold = 0
local tempRobLimit = 0
local tempZhuoFei = 0
local tempZhuoFeiMin = 0
local tempJieSanFenShu = 0
local note = nil
local wins = ""
local consts = ""
function CreatePin5RoomPanel.HandleCreateRoom()
    tempRuleDatas = nil
    --只有大厅创建房间才进行规则存储
    tempRuleDatas = this.SavePlayWayConfigData()
    if tempRuleDatas == nil then
        tempRuleDatas = this.GetPlayWayRuleDataAtUI()
    end
    if this.moneyType == MoneyType.Gold then
        tempBaseScore = 0
        tempInGold = 0
        tempJieSanFenShu = 0
        note = nil
        --wins = nil
        --consts = nil
        if this.advancedData ~= nil then
            tempBaseScore = this.advancedData.diFen or 0
            tempJieSanFenShu = this.advancedData.kickNum or 0
            tempInGold = this.advancedData.enterNum or 0
            tempRobLimit = this.advancedData.robNum or 0
            note = this.advancedData.remarkStr
            --wins = this.advancedData.wins
            --consts = this.advancedData.costs
        end

        --把数据存入到规则中
        tempRuleDatas[Pin5RuleType.DiFen] = tempBaseScore
        tempRuleDatas[Pin5RuleType.ZhunRu] = tempInGold
        tempRuleDatas[Pin5RuleType.JieSanFenShu] = tempJieSanFenShu
        tempRuleDatas[Pin5RuleType.RobLimit] = tempRobLimit

        if not IsNumber(tempBaseScore) or tempBaseScore < 0 then
            Toast.Show("请输入正确的底分")
            return
        end
        if not IsNumber(tempInGold) then
            Toast.Show("请输入正确的准入分数")
            return
        end
        if tempInGold < tempBaseScore then
            Toast.Show("准入必须大于底分")
            return
        end
        if tempJieSanFenShu < 0 then
            Toast.Show("请输入正确的解散分数")
            return
        end
        if string.IsNullOrEmpty(note) then
            Toast.Show("请输入分组备注名")
            return
        end
        --if string.IsNullOrEmpty(wins) then
        --    Toast.Show("请输入大赢家得分区间")
        --    return
        --end
        --if string.IsNullOrEmpty(consts) then
        --    Toast.Show("请输入表情赠送")
        --    return
        --end
    end
    tempPlayWayType = tempRuleDatas[Pin5RuleType.PlayType]
    tempPlayerTotal = tempRuleDatas[Pin5RuleType.GameTotal]
    tempGameTotal = tempRuleDatas[Pin5RuleType.JuShu]
    tempConsumeId = Pin5Config.GetConsumeConfigId(tempPlayerTotal, tempGameTotal)
    tempPayType = tempRuleDatas[Pin5RuleType.PayType]

    if this.roomType == RoomType.Lobby then
        BaseTcpApi.SendCreateRoom(GameType.Pin5, tempRuleDatas, tempPlayerTotal, tempGameTotal, this.roomType, MoneyType.Fangka, tempConsumeId, 0, tempPayType, tempGps)
    elseif this.roomType == RoomType.Club then

    elseif this.roomType == RoomType.Tea then
        if not IsNil(this.args) then
            if not IsNil(this.args.unionCallback) then
                local data = Functions.PackGameRule(GameType.Pin5, tempRuleDatas, tempPlayWayType, tempGameTotal,
                        tempPlayerTotal, tempConsumeId, tempPayType, tempBaseScore, tempInGold, tempJieSanFenShu, note, wins, consts, this.advancedData.keepBaseNum or 0, 2, this.advancedData.allToggle and 0 or 1, this.advancedData.expressionNum or 0, this.advancedData.bdPer)
                this.args.unionCallback(this.args.type, data)
            end
        end
    end
end


--保存一键配置
function CreatePin5RoomPanel.OnSaveBtnClick()
    if this.roomType == RoomType.Club then
        Alert.Prompt("确定保存一键开房配置信息？", this.OnSaveAlert)
    end
end

function CreatePin5RoomPanel.OnSaveAlert()
    local ruleDatas = this.GetPlayWayRuleDataAtUI()
    local playWayType = ruleDatas[Pin5RuleType.PlayType]
    local playerTotal = ruleDatas[Pin5RuleType.GameTotal]
    local gameTotal = ruleDatas[Pin5RuleType.JuShu]
    local consumeId = Pin5Config.GetConsumeConfigId(playerTotal, gameTotal)
    ClubData.SendSetYjpzRule(GameType.Pin5, playWayType, ruleDatas, playerTotal, gameTotal, consumeId, 0)
end


--删除一键配置
function CreatePin5RoomPanel.OnDeleteBtnClick()
    if this.roomType == RoomType.Club then
        Alert.Prompt("确定删除一键开房配置？", this.OnDeleteAlert)
    end
end

function CreatePin5RoomPanel.OnDeleteAlert()
    ClubData.SendRemoveYjpzRule(GameType.Pin5, this.lastPlayWayType)
end


--菜单按钮点击
function CreatePin5RoomPanel.OnPlayWayMenuValueChanged(isOn, listener)
    if isOn then
        local dataIndex = tonumber(listener.name)
        if this.lastPlayWayType ~= dataIndex then
            this.SavePlayWayConfigData()
        end
        this.lastPlayWayType = dataIndex
        if not this.isModify then
            this.advancedData = CreateRoomConfig.GetAdvancedData(GameType.Pin5, this.lastPlayWayType)
        end
    end
end

--
function CreatePin5RoomPanel.UpdateConsumeDisplay()
    local playerTotal = this.CheckRuleValue(Pin5RuleType.GameTotal, this.playerTotalDrop.value)
    local gameTotal = this.CheckRuleValue(Pin5RuleType.JuShu, this.gameTotalDrop.value)
    local cards = Pin5Config.GetCardsConfig(playerTotal, gameTotal)
    SendEvent(CMD.Game.UpdateCreateRoomConsume, cards)
end

--获取label字体的颜色
function CreatePin5RoomPanel.SetLabelColorTxt(toggle)
    local grayBg = toggle.transform:Find("Background/GrayBg")
    local checkGray = toggle.transform:Find("Background/CheckGray")
    local labelTxt = toggle.transform:Find("Label"):GetComponent(TypeText)
    UIUtil.SetActive(grayBg, not toggle.interactable)
    UIUtil.SetActive(checkGray, not toggle.interactable and toggle.isOn)
    if toggle.interactable then
        if toggle.isOn then
            labelTxt.color = CreateRoomConfig.COLOR_SELECTED
        else
            labelTxt.color = CreateRoomConfig.COLOR_NORMAL
        end
    else
        labelTxt.color = CreateRoomConfig.COLOR_FORBIDDEN
    end
end

--更新创建房间高级设置
function CreatePin5RoomPanel.OnUpdateCreateRoomAdvanced(data)
    this.advancedData = data
    CreateRoomConfig.SaveAdvancedData(GameType.Pin5, this.lastPlayWayType, data)
end