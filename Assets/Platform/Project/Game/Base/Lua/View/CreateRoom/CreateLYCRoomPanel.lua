CreateLYCRoomPanel = ClassLuaComponent("CreateLYCRoomPanel")
CreateLYCRoomPanel.Instance = nil

local this = CreateLYCRoomPanel

function CreateLYCRoomPanel:Init()
    this.lastPlayWayType = LYCPlayType.RandomQiangZhuang  --最后一次玩法类型
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
end

function CreateLYCRoomPanel:Awake()
    this = self
    self:Init()
    local content = this:Find("Content")
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

    -- this.baseCoreDrop = this.mingPaiPlayWayNode:Find("Line1/BaseCore/Dropdown"):GetComponent("Dropdown")   --押注分

    this.HomeDrop = this.mingPaiPlayWayNode:Find("Line1/Home/Dropdown"):GetComponent("Dropdown")    --庄家

    this.gameTotalDrop = this.mingPaiPlayWayNode:Find("Line2/GameTotal/Dropdown"):GetComponent("Dropdown")   --局数

    this.startModelDrop = this.mingPaiPlayWayNode:Find("Line2/StartModel/Dropdown"):GetComponent("Dropdown")  --开始模式

    this.laiZiDrop = this.mingPaiPlayWayNode:Find("Line3/LaiZi/Dropdown"):GetComponent("Dropdown")   --癞子玩法

    -- this.maBaoDrop = this.mingPaiPlayWayNode:Find("Line4/MaBao/Dropdown"):GetComponent("Dropdown")   --码宝
    this.maBaoInput = this.mingPaiPlayWayNode:Find("Line4/MaBao/MaBaoInput"):GetComponent(TypeInputField)   --码宝输入框
    this.maBaoInput.text = 1

    --this.zouShuiDrop = this.mingPaiPlayWayNode:Find("Line4/ZouShui/Dropdown"):GetComponent("Dropdown")  -- 走水
    --this.zhifuGo = this.mingPaiPlayWayNode:Find("Line4/PayType").gameObject
    this.PinJuDrop = this.mingPaiPlayWayNode:Find("Line4/PinJu/Dropdown"):GetComponent("Dropdown")  --平局

    this.PaiShuDrop = this.mingPaiPlayWayNode:Find("Line5/PaiShu/Dropdown"):GetComponent("Dropdown")    --牌数

    -- this.QZFenShuDrop = this.mingPaiPlayWayNode:Find("Line5/QZFenShu/Dropdown"):GetComponent("Dropdown")   --抢庄分数
    this.QZFSInput = this.mingPaiPlayWayNode:Find("Line5/QZFenShu/QZFSInput"):GetComponent(TypeInputField)   --抢庄分数输入框
    this.QZFSInput.text = 1

    this.QZFanBeiDrop = this.mingPaiPlayWayNode:Find("Line51/QZFanBei/Dropdown"):GetComponent("Dropdown")   --抢庄倍数

    this.SanPiDrop = this.mingPaiPlayWayNode:Find("Line6/SanPi/Dropdown"):GetComponent("Dropdown")  --三批大小

    --具体牛型Toggle
    this.niuCardType = {}
    this.niuCardNode = this.mingPaiPlayWayNode:Find("Line61/NiuTypeGroup")
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
    this.highOption = this.mingPaiPlayWayNode:Find("Line71/HighOption/OpenOptionBtn")
    this.highOptionBtn = this.highOption:GetComponent(TypeButton)
    this.highOptionTxt = this.mingPaiPlayWayNode:Find("Line71/HighOption/Text"):GetComponent(TypeText)

    --具体高级选项
    this.optionType = {}
    this.optionGroupNode = this.mingPaiPlayWayNode:Find("Line71/OptionGroup")
    local optionContent = this.optionGroupNode:Find("Content")
    local len = optionContent.childCount
    for i = 1, len do
        local item = optionContent:GetChild(i - 1)
        local optionTypeItem = {}
        optionTypeItem.gameObject = item.gameObject
        optionTypeItem.toggle = item:GetComponent("Toggle")
        this.optionType[i] = optionTypeItem
    end

    this.closeOptionBtn = this.mingPaiPlayWayNode:Find("Line71/CloseOptionBtn")
    this.closeSpecialBtn = this.mingPaiPlayWayNode:Find("Line61/CloseSpecialBtn")

    --准入
    local zhunRu = this.mingPaiPlayWayNode:Find("Line81")
    this.zhunRuGo = zhunRu.gameObject
    this.zhunRuInput = zhunRu:Find("InputField"):GetComponent(TypeInputField)
    --表情赠送
    local zhuoFei = this.mingPaiPlayWayNode:Find("Line91")
    this.zhuoFeiGo = zhuoFei.gameObject
    this.zhuoFeiInput = zhuoFei:Find("InputField"):GetComponent(TypeInputField)
    --最低赠送
    local zhuoFeiMin = this.mingPaiPlayWayNode:Find("Line101")
    this.zhuoFeiMinGo = zhuoFeiMin.gameObject
    this.zhuoFeiMinInput = zhuoFeiMin:Find("InputField"):GetComponent(TypeInputField)
    --解散分数
    local jieSanFenShu = this.mingPaiPlayWayNode:Find("Line111")
    this.jieSanFenShuGo = jieSanFenShu.gameObject
    this.jieSanFenShuInput = jieSanFenShu:Find("InputField"):GetComponent(TypeInputField)

    -----------------------------------
    local bottom = ruleNode:Find("Bottom")
    this.createRoomBtn = bottom:Find("Button/CreateButton")
    this.addRuleBtn = bottom:Find("Button/SaveButton")
    this.removeRuleBtn = bottom:Find("Button/DeleteButton")
    this.advancedBtn = bottom:Find("Button/AdvancedButton").gameObject
    this.tips = bottom:Find("Tips").gameObject

    this.AddUIListenerEvent()

    this.playerTotalDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.playerTotalDrop, LYCRulePlayerNumberList)
    -- this.baseCoreDrop:ClearOptions()
    -- UIUtil.AddDropdownOptionsByString(this.baseCoreDrop, LYCRuleDiFen)

    this.startModelDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.startModelDrop, LYCRuleStartModelList)
    this.gameTotalDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.gameTotalDrop, LYCRuleJuShuList)

    this.QZFanBeiDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.QZFanBeiDrop, LYCQiangZhuang)
    this.laiZiDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.laiZiDrop, LYCRuleLaiZiType)

    -- this.maBaoDrop:ClearOptions()
    -- UIUtil.AddDropdownOptionsByString(this.maBaoDrop, LYCMaBaoSelect)
    --this.zouShuiDrop:ClearOptions()
    --UIUtil.AddDropdownOptionsByString(this.zouShuiDrop, LYCRuleZouShuiList)
    this.PinJuDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.PinJuDrop, PinJuSelect)
    this.PaiShuDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.PaiShuDrop, PaiShuSelect)
    this.HomeDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.HomeDrop, ZhuangModeSelect)
    this.SanPiDrop:ClearOptions()
    UIUtil.AddDropdownOptionsByString(this.SanPiDrop, SanPiSelect)

    --this.fanBeiDrop:ClearOptions()
    --UIUtil.AddDropdownOptionsByString(this.fanBeiDrop, LYCRuleFanBeiRule)

    -- this.QZFenShuDrop:ClearOptions()
    -- UIUtil.AddDropdownOptionsByString(this.QZFenShuDrop, LYCQZFenShu)
    
end

--functionType：0普通创建房间   1一键开房配置    2一键开房       3创建其他房间
--openFrom：0从大厅打开     1从亲友圈打开    2茶馆打开
function CreateLYCRoomPanel:OnOpened(fromType, funcType, args)
    this.scrollRect.content.localPosition.y = 0
    this.AddListnerEvent()
    this.CheckArgsData(fromType, funcType, args)

    --处理高级设置按钮显示
    if this.moneyType == MoneyType.Gold then
        UIUtil.SetActive(this.advancedBtn, true)
    else
        UIUtil.SetActive(this.advancedBtn, false)
    end

    this.InitExternalMenu(args.playTypeToggles)
    this.CheckButtonDisplay()
    this.CheckAndUpdateConfigData()
    this.isOpend = true
end

--
function CreateLYCRoomPanel:OnClosed()
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
function CreateLYCRoomPanel:AddUIListenerEvent()
    this:AddOnClick(this.createRoomBtn, this.OnCreateBtnClick)
    this:AddOnClick(this.addRuleBtn, this.OnSaveBtnClick)
    this:AddOnClick(this.removeRuleBtn, this.OnDeleteBtnClick)
    this:AddOnClick(this.advancedBtn, this.OnAdvancedBtnClick)
    local length = #this.playWayMenuItems
    for i = 1, length do
        local playWayMenuItem = this.playWayMenuItems[i]
        UIToggleListener.AddListener(playWayMenuItem.gameObject, this.OnPlayWayMenuValueChanged)
    end
    this.playerTotalDrop.onValueChanged:AddListener(this.OnPlayerTotalDropDown)  --桌数
    -- this.baseCoreDrop.onValueChanged:AddListener(this.OnBaseCoreDropDown)
    this.gameTotalDrop.onValueChanged:AddListener(this.OnGameTotalDropDown)
    --this.maBaoDrop.onValueChanged:AddListener(this.OnTuiZhuDropDown)
    this.maBaoInput.onValueChanged:AddListener(this.OnMaBaoInputValueChanged)
    this.QZFanBeiDrop.onValueChanged:AddListener(this.OnQZFanBeiDropDown)
    this.laiZiDrop.onValueChanged:AddListener(this.OnLaiZiDropDown)
    -- this.QZFenShuDrop.onValueChanged:AddListener(this.OnQZFenShuDropDown)
    this.QZFSInput.onValueChanged:AddListener(this.OnQZFSInputValueChanged)
    this.startModelDrop.onValueChanged:AddListener(this.OnStartModelDropDown)
    --this.zouShuiDrop.onValueChanged:AddListener(this.OnPayDropDown)  --支付

    for i = 1, 3 do
        UIToggleListener.AddListener(this.niuCardType[i].gameObject, this.OnNiuTypeValueChanged)
    end
    UIToggleListener.AddListener(this.niuCardType[4].gameObject, this.AllNiuTypeValueChanged)  --特殊牌型的全选
    for i = 1, 4 do
        UIToggleListener.AddListener(this.optionType[i].gameObject, this.OnOptionValueChanged)
    end
    UIToggleListener.AddListener(this.optionType[5].gameObject, this.AllOptionValueChanged)  --高级选项的全选
    this:AddOnClick(this.highOption, this.OnHighOptionBtnClick)
    this:AddOnClick(this.closeOptionBtn, this.OnCloseOptionBtnClick)
    this:AddOnClick(this.closeSpecialBtn, this.OnCloseSpecialBtnClick)
end

function CreateLYCRoomPanel.AddListnerEvent()
    AddEventListener(CMD.Game.UpdateNewCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

function CreateLYCRoomPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.UpdateNewCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

------------------------------------------------------------------
--
function CreateLYCRoomPanel.CheckArgsData(fromType, moneyType, args)
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
    if this.roomType == RoomType.Lobby then
        this.CheckLobbyPlayWayData()
        this.lastPlayWayType = LYCPlayType.RandomQiangZhuang
        this.playWayRuleDatas = this.lobbyPlayWayData.ruleDatas
    else
        this.playWayRuleDatas = {}
        this.otherArgs = {}
        if args ~= nil then
            --处理参数
            if args.groupId ~= nil then
                this.groupId = args.groupId
            end
            --
            --获取麻将的规则
            local temp = args[GameType.LYC]
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

function CreateLYCRoomPanel.InitExternalMenu(listToggles)
    if listToggles ~= nil and this.externalMenuItems == nil then
        local trans = listToggles[GameType.LYC]
        if trans ~= nil then
            this.externalMenuItems = {}
            for i = 1, 1 do
                local playWayMenuItemTrans = trans:Find(tostring(i))
                local item = {}
                item.gameObject = playWayMenuItemTrans.gameObject
                item.toggle = playWayMenuItemTrans:GetComponent("Toggle")
                item.configTag = playWayMenuItemTrans:Find("ConfigTag").gameObject
                this.externalMenuItems[i] = item
                UIToggleListener.AddListener(item.gameObject, this.OnPlayWayMenuValueChanged)
            end
        end
    end
end

--检测按钮显示
function CreateLYCRoomPanel.CheckButtonDisplay()
    UIUtil.SetActive(this.tips, this.roomType == RoomType.Lobby)
    --UIUtil.SetActive(this.zhifuGo, this.roomType == RoomType.Lobby)

    LogError(this.roomType, this.moneyType)

    local isGold = this.moneyType == MoneyType.Gold

    -- UIUtil.SetActive(this.zhunRuGo, isGold)
    -- UIUtil.SetActive(this.zhuoFeiGo, isGold)
    -- UIUtil.SetActive(this.zhuoFeiMinGo, isGold)
    -- UIUtil.SetActive(this.jieSanFenShuGo, isGold)
end

function CreateLYCRoomPanel.CheckAndUpdateConfigData()
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
    local ruleData = this.playWayRuleDatas[this.lastPlayWayType]
    if ruleData == nil then
        ruleData = {}
    end

    this.SetRuleUI(ruleData)
    this.UpdateNiuCardTxt()
    this.UpdateOptionTxt()
    this.UpdateConsumeDisplay()
end

function CreateLYCRoomPanel.CheckLobbyPlayWayData()
    if this.lobbyPlayWayData == nil then
        this.lobbyPlayWayData = {}
        this.lobbyPlayWayData.ruleDatas = {}
        local temp = nil
        local str = GetLocal(LocalDatas.LYCPlayWayData, nil)
        if str ~= nil then
            temp = JsonToObj(str)
        end
        Log('=====CheckLobbyPlayWayData====', str)
        if temp ~= nil then
            this.lobbyPlayWayData.lastPlayWayType = temp.lastPlayWayType
            if this.lobbyPlayWayData.lastPlayWayType == nil then
                this.lobbyPlayWayData.lastPlayWayType = LYCPlayType.RandomQiangZhuang
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

                        playWayType = ruleData[LYCRuleType.PlayType]
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
function CreateLYCRoomPanel.OnPlayerTotalDropDown(value)
    this.UpdateConsumeDisplay()
end
--底分
function CreateLYCRoomPanel.OnBaseCoreDropDown(value)
    --Log('OnBaseCoreDropDown', value)
    --this.CheckRuleValue(LYCRuleType.BaseScore, value)
end

--局数
function CreateLYCRoomPanel.OnGameTotalDropDown(value)
    this.UpdateConsumeDisplay()
end

--开始模式
function CreateLYCRoomPanel.OnStartModelDropDown(value)
    --this.CheckRuleValue(LYCRuleType.StartModel, value)
end

function CreateLYCRoomPanel.OnPayDropDown(value)
    --this.CheckRuleValue(LYCRuleType.PayType, value)
end

--码宝推注
function CreateLYCRoomPanel.OnTuiZhuDropDown(value)
    --this.CheckRuleValue(LYCRuleType.TuiZhu, value)
end

--码宝推注输入框
function CreateLYCRoomPanel.OnMaBaoInputValueChanged(text)
    this.maBaoInput.text = (tonumber(text) ~= nil and tonumber(text) < 0) and 1 or text
end


--抢庄倍数
function CreateLYCRoomPanel.OnQZFanBeiDropDown(value)
    --this.CheckRuleValue(LYCRuleType.MaxQiangZhuang, value)
end

--癞子
function CreateLYCRoomPanel.OnLaiZiDropDown(value)
    --this.CheckRuleValue(LYCRuleType.LaiZi, value)
end

--庄家选项，选择抢庄则显示抢庄倍数选项
function CreateLYCRoomPanel.OnHomeDropDown(value)
   
end

--抢庄分数
function CreateLYCRoomPanel.OnQZFenShuDropDown(value)
    Log("抢庄分数", value)
    --this.CheckRuleValue(LYCRuleType.FanBeiRule, value)
    -- this.UpdateNiuCardTxt()
end

--抢庄分数输入框
function CreateLYCRoomPanel.OnQZFSInputValueChanged(text)
    this.QZFSInput.text = (tonumber(text) ~= nil and tonumber(text) <= 0) and 1 or text
end



--通过Dropdown索引获取值
function CreateLYCRoomPanel.CheckRuleValue(ruleType, index)
    local tempValue = 0
    if ruleType == LYCRuleType.TuiZhu then
        tempValue = LYCConfig.GetConfigValue(LYCRuleBolusConfig, index)
    elseif ruleType == LYCRuleType.JuShu then
        tempValue = LYCConfig.GetConfigValue(LYCRuleJuShuConfig, index)
    elseif ruleType == LYCRuleType.GameTotal then
        tempValue = LYCConfig.GetConfigValue(LYCRulePlayerNumberConfig, index)
    elseif ruleType == LYCRuleType.PayType then
        tempValue = LYCConfig.GetConfigValue(LYCRulePayConfig, index)
    elseif ruleType == LYCRuleType.StartModel then
        tempValue = LYCConfig.GetConfigValue(LYCRuleStartModelConfig, index)
    elseif ruleType == LYCRuleType.MaBao then
        tempValue = LYCConfig.GetConfigValue(LYCMaoBaoSelectConfig, index)
    elseif ruleType == LYCRuleType.RobZhuang then
        tempValue = LYCConfig.GetConfigValue(ZhuangModeSelectConfig, index)
    elseif ruleType == LYCRuleType.ThreeBatch then
        tempValue = LYCConfig.GetConfigValue(SanPiSelectConfig, index)
    elseif ruleType == LYCRuleType.QZFanBei then
        tempValue = LYCConfig.GetConfigValue(LYCQiangZhuangfig, index)
    elseif ruleType == LYCRuleType.QZFenShu then
        tempValue = LYCConfig.GetConfigValue(LYCQZFenShu, index)
    else
        tempValue = index + 1
    end
    return tempValue
end

--检测输入值
function CreateLYCRoomPanel.CheckInputValue(value)
    local temp = tonumber(value)
    if temp == nil then
        return 0
    end
    return temp
end

--纠正Dropdown中的索引
function CreateLYCRoomPanel.ExchangeDropValueByRule(ruleType, ruleValue)
    if ruleType == LYCRuleType.TuiZhu then
        -- this.maBaoDrop.value = LYCConfig.GetConfigIndex(LYCRuleBolusConfig, ruleValue)
    elseif ruleType == LYCRuleType.GameTotal then
        this.playerTotalDrop.value = LYCConfig.GetConfigIndex(LYCRulePlayerNumberConfig, ruleValue)
    elseif ruleType == LYCRuleType.BaseScore then
        this.baseCoreDrop.value = ruleValue - 1
    elseif ruleType == LYCRuleType.StartModel then
        this.startModelDrop.value = LYCConfig.GetConfigIndex(LYCRuleStartModelConfig, ruleValue)
    elseif ruleType == LYCRuleType.JuShu then
        this.gameTotalDrop.value = LYCConfig.GetConfigIndex(LYCRuleJuShuConfig, ruleValue)
    elseif ruleType == LYCRuleType.LaiZi then
        this.laiZiDrop.value = ruleValue - 1
    elseif ruleType == LYCRuleType.FanBeiRule then
        this.fanBeiDrop.value = ruleValue - 1
    elseif ruleType == LYCRuleType.PayType then
        this.zouShuiDrop.value = LYCConfig.GetConfigIndex(LYCRulePayConfig, ruleValue)
    end
end

--特殊牌型按钮
function CreateLYCRoomPanel.OnSpecialCardBtnClick()
    UIUtil.SetActive(this.niuCardNode, true)
    UIUtil.SetActive(this.optionGroupNode, false)
    UIUtil.SetActive(this.closeSpecialBtn, true)
    this.CheckSpecialIsAllSlected()
    this.UpdateNiuCardTxt()
end

--高级选项按钮
function CreateLYCRoomPanel.OnHighOptionBtnClick()
    UIUtil.SetActive(this.niuCardNode, false)
    UIUtil.SetActive(this.optionGroupNode, true)
    UIUtil.SetActive(this.closeOptionBtn, true)
    this.CheckOptionAllSlected()
    this.UpdateOptionTxt()
end

function CreateLYCRoomPanel.OnCloseOptionBtnClick()
    UIUtil.SetActive(this.niuCardNode, false)
    UIUtil.SetActive(this.optionGroupNode, false)
    UIUtil.SetActive(this.closeOptionBtn, false)
    this.UpdateOptionTxt()
end

function CreateLYCRoomPanel.OnCloseSpecialBtnClick()
    UIUtil.SetActive(this.niuCardNode, false)
    UIUtil.SetActive(this.optionGroupNode, false)
    UIUtil.SetActive(this.closeSpecialBtn, false)
    UIUtil.SetActive(this.closeOptionBtn, false)
    this.UpdateNiuCardTxt()
end
--判断牛型是否全选
function CreateLYCRoomPanel.CheckSpecialIsAllSlected()
    local isAllSlected = true
    for i = 1, 3 do
        if this.niuCardType[i].toggle.isOn == false then
            isAllSlected = false
            break
        end
    end
    this.isNotTogglePress = true
    this.niuCardType[4].toggle.isOn = isAllSlected
    this.isNotTogglePress = false
end

--判断高级选项是否全选
function CreateLYCRoomPanel.CheckOptionAllSlected()
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
function CreateLYCRoomPanel.OnNiuTypeValueChanged(isOn, listener)
    if this.isOpend then
        this.CheckSpecialIsAllSlected()
        this.UpdateNiuCardTxt()
    end
end

--特殊牌型的全选
function CreateLYCRoomPanel.AllNiuTypeValueChanged(isOn, listener)
    if this.isNotTogglePress then
        return
    end
    for i = 1, 3 do
        this.niuCardType[i].toggle.isOn = isOn
    end
    this.UpdateNiuCardTxt()
end


--高级选项的选择
function CreateLYCRoomPanel.OnOptionValueChanged(isOn, listener)
    if this.isOpend then
        this.CheckOptionAllSlected()
        this.UpdateOptionTxt()
    end
end

--高级选项的全选
function CreateLYCRoomPanel.AllOptionValueChanged(isOn, listener)
    if this.isNotTogglePress then
        return
    end
    for i = 1, 4 do
        this.optionType[i].toggle.isOn = isOn
    end
    this.UpdateOptionTxt()
end

--更新高级选项文本
function CreateLYCRoomPanel.UpdateOptionTxt()
    local tempStr = ""
    for i = 1, 4 do
        if this.optionType[i].toggle.isOn then
            tempStr = tempStr .. LYCOptionConfigTxt[i] .. "  "
        end
    end
    if tempStr == "" then
        tempStr = "无"
    end
    this.highOptionTxt.text = tempStr
end

--更新牛型显示文本
function CreateLYCRoomPanel.UpdateNiuCardTxt()
    local tempStr = ""
    --local niuMuilt = this.CheckRuleValue(LYCRuleType.FanBeiRule, this.fanBeiDrop.value)
    --for i = 1, 3 do
    --    if this.niuCardType[i].toggle.isOn then
    --        tempStr = tempStr .. LYCConfig.GetNiuTypeMuiltTxt(niuMuilt, i) .. "  "
    --    end
    --    this.niuCardType[i].labelTxt.text = LYCConfig.GetNiuTypeMuiltTxt(niuMuilt, i)
    --end
    if tempStr == "" then
        tempStr = "无"
    end
    --this.specialCardTxt.text = tempStr
end

--保存到本地存储中
function CreateLYCRoomPanel.SaveLobbyPlayWayConfigData()
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
        SetLocal(LocalDatas.LYCPlayWayData, str)
    end
end

--保存配置数据
function CreateLYCRoomPanel.SavePlayWayConfigData()
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
function CreateLYCRoomPanel.SetDefaultRuleUI()
    this.playerTotalDrop.value = 0
    -- this.baseCoreDrop.value = 0
    this.startModelDrop.value = 0
    this.gameTotalDrop.value = 0
    this.QZFanBeiDrop.value = 0
    this.laiZiDrop.value = 0
    this.fanBeiDrop.value = 0
    -- this.QZFenShuDrop.value = 0
    this.niuCardType[4].toggle.isOn = true
    --this.optionType[1].toggle.isOn = false
    --this.optionType[4].toggle.isOn = false
    --this.optionType[5].toggle.isOn = false

    this.zhunRuInput.text = 0
    this.zhuoFeiInput.text = 0
    this.zhuoFeiMinInput.text = 0
    this.jieSanFenShuInput.text = 0
end

--获取当前选择的UI上的默认字段
function CreateLYCRoomPanel.GetPlayWayRuleDataAtUI()
    --玩法规则对象
    local playWayRuleData = {}
    playWayRuleData[LYCRuleType.PlayType] = this.lastPlayWayType
    playWayRuleData[LYCRuleType.RoomType] = this.roomType
    playWayRuleData[LYCRuleType.GameTotal] = this.CheckRuleValue(LYCRuleType.GameTotal, this.playerTotalDrop.value)
    -- playWayRuleData[LYCRuleType.BaseScore] = this.CheckRuleValue(LYCRuleType.BaseScore, this.baseCoreDrop.value)
    playWayRuleData[LYCRuleType.StartModel] = this.CheckRuleValue(LYCRuleType.StartModel, this.startModelDrop.value)
    playWayRuleData[LYCRuleType.JuShu] = this.CheckRuleValue(LYCRuleType.JuShu, this.gameTotalDrop.value)
    playWayRuleData[LYCRuleType.QZFanBei] = this.CheckRuleValue(LYCRuleType.QZFanBei, this.QZFanBeiDrop.value)
    --playWayRuleData[LYCRuleType.LaiZi] = this.CheckRuleValue(LYCRuleType.LaiZi, this.laiZiDrop.value)
    --playWayRuleData[LYCRuleType.FanBeiRule] = this.CheckRuleValue(LYCRuleType.FanBeiRule, this.fanBeiDrop.value)
    -- playWayRuleData[LYCRuleType.QZFenShu] = this.CheckRuleValue(LYCRuleType.QZFenShu, this.QZFenShuDrop.value)
    -- playWayRuleData[LYCRuleType.MaBao] = this.CheckRuleValue(LYCRuleType.MaBao, this.maBaoDrop.value)
    --playWayRuleData[LYCRuleType.ZouShui] = this.CheckRuleValue(LYCRuleType.ZouShui, this.zouShuiDrop.value)
    playWayRuleData[LYCRuleType.Tie] = this.CheckRuleValue(LYCRuleType.Tie, this.PinJuDrop.value)
    playWayRuleData[LYCRuleType.CardCount] = this.CheckRuleValue(LYCRuleType.CardCount, this.PaiShuDrop.value)
    playWayRuleData[LYCRuleType.RobZhuang] = this.CheckRuleValue(LYCRuleType.RobZhuang, this.HomeDrop.value)
    playWayRuleData[LYCRuleType.ThreeBatch] = this.CheckRuleValue(LYCRuleType.ThreeBatch, this.SanPiDrop.value)

    playWayRuleData[LYCRuleType.DiFen] = 1
    playWayRuleData[LYCRuleType.MaBao] = this.maBaoInput.text
    playWayRuleData[LYCRuleType.QZFenShu] = this.QZFSInput.text

    -- if this.roomType == RoomType.Tea then
    --     playWayRuleData[LYCRuleType.ZhunRu] = this.CheckInputValue(this.zhunRuInput.text)
    --     playWayRuleData[LYCRuleType.ZhuoFei] = this.CheckInputValue(this.zhuoFeiInput.text)
    --     playWayRuleData[LYCRuleType.ZhuoFeiMin] = this.CheckInputValue(this.zhuoFeiMinInput.text)
    --     playWayRuleData[LYCRuleType.JieSanFenShu] = this.CheckInputValue(this.jieSanFenShuInput.text)
    -- end

    if this.roomType == RoomType.Club then
        playWayRuleData[LYCRuleType.PayType] = 3
    end

    local tempCardType = ""
    tempCardType = this.GetTeShuCardType(LYCRuleType.BaoZi, this.niuCardType[1], tempCardType)
    tempCardType = this.GetTeShuCardType(LYCRuleType.TripleYan, this.niuCardType[2], tempCardType)
    tempCardType = this.GetTeShuCardType(LYCRuleType.DoubleYan, this.niuCardType[3], tempCardType)
    playWayRuleData[LYCRuleType.SpecialCard] = tempCardType

    local tempOptionType = ""
    tempOptionType = this.GetHighOptionCardType(LYCRuleType.GameStartForbiden, this.optionType[1], tempOptionType)
    tempOptionType = this.GetHighOptionCardType(LYCRuleType.XiaZhuLimit, this.optionType[2], tempOptionType)
    tempOptionType = this.GetHighOptionCardType(LYCRuleType.VoiceForbiden, this.optionType[3], tempOptionType)
    tempOptionType = this.GetHighOptionCardType(LYCRuleType.CuoPaiForbiden, this.optionType[4], tempOptionType)
    playWayRuleData[LYCRuleType.HighOption] = tempOptionType

    LogError(">> CreateLYCRoomPanel.GetPlayWayRuleDataAtUI > ", playWayRuleData)
    return playWayRuleData
end

function CreateLYCRoomPanel.GetTeShuCardType(type, toggle, str)
    local isOne = this.GetToggleRuleValue(toggle.toggle.isOn) == 1
    if isOne then
        if string.IsNullOrEmpty(str) then
            str = "" .. LYCRuleTeShu[type]
        else
            str = str .. "," .. LYCRuleTeShu[type]
        end
    end
    return str
end

function CreateLYCRoomPanel.GetHighOptionCardType(type, toggle, str)
    local isOne = this.GetToggleRuleValue(toggle.toggle.isOn) == 1
    if isOne then
        if string.IsNullOrEmpty(str) then
            str = "" .. LYCRuleHighOptionMap[type]
        else
            str = str .. "," .. LYCRuleHighOptionMap[type]
        end
    end
    return str
end

function CreateLYCRoomPanel.GetToggleRuleValue(isOn)
    if isOn then
        return 1
    else
        return 0
    end
end

function CreateLYCRoomPanel.SetRuleUI(rules)
    if rules == nil then
        this.SetDefaultRuleUI()
    else
        --Log('=======SetRuleUI========', rules)
        for ruleType, value in pairs(rules) do
            if ruleType == LYCRuleType.HighOption then
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
            elseif ruleType == LYCRuleType.SpecialCard then
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

    this.zhunRuInput.text = this.GetRuleValue(rules, LYCRuleType.ZhunRu)
    this.zhuoFeiInput.text = this.GetRuleValue(rules, LYCRuleType.ZhuoFei)
    this.zhuoFeiMinInput.text = this.GetRuleValue(rules, LYCRuleType.ZhuoFeiMin)
    this.jieSanFenShuInput.text = this.GetRuleValue(rules, LYCRuleType.JieSanFenShu)
end

--获取规则值
function CreateLYCRoomPanel.GetRuleValue(rules, type)
    local temp = rules[type]
    if temp == nil then
        return 0
    else
        return temp
    end
end

--
local optionData = nil
function CreateLYCRoomPanel.UpdateDropDown(ruleValue)
    local optionDatas = {}
    for i = 1, 3 do
        -- local optionData = OptionData.New()
        if optionData == nil then
            optionData = OptionData.New()
        end
        optionData.text = LYCRuleStartModel[i]
        table.insert(optionDatas, optionData)
    end
    UIUtil.SetDropdownOptions(this.startModelDrop, optionDatas)
end

function CreateLYCRoomPanel.OnCreateBtnClick()
    if os.time() - this.createClickTime < 3 then
        Toast.Show("请不要频繁操作")
        return
    end
    this.createClickTime = os.time()
    if GameManager.IsCheckGame(GameType.LYC) then
        if this.roomType == RoomType.Club then
            Alert.Prompt("确定创建亲友圈房间？", this.OnCreateAlert)
        else
            this.HandleCreateRoom()
        end
    end
end

function CreateLYCRoomPanel.OnCreateAlert()
    this.HandleCreateRoom()
end

--高级设置按钮
function CreateLYCRoomPanel.OnAdvancedBtnClick()
    PanelManager.Open(PanelConfig.CreateRoomAdvanced, this.advancedData, LYCConfig.DiFenConfig, LYCConfig.DiFenNameConfig, GameType.LYC)
end

local tempPlayWayType = LYCPlayType.RandomQiangZhuang
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
function CreateLYCRoomPanel.HandleCreateRoom()
    tempRuleDatas = nil
    --只有大厅创建房间才进行规则存储
    tempRuleDatas = this.SavePlayWayConfigData()
    if tempRuleDatas == nil then
        tempRuleDatas = this.GetPlayWayRuleDataAtUI()
    end
    local faceType = 0
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
            -- tempRobLimit = this.advancedData.robNum or 0
            note = this.advancedData.remarkStr
            faceType = this.advancedData.faceAllToggle and 0 or 1 --0/所有人分配  1/赢家分配
            --wins = this.advancedData.wins
            --consts = this.advancedData.costs
        end

        --把数据存入到规则中
        tempRuleDatas[LYCRuleType.DiFen] = tempBaseScore
        tempRuleDatas[LYCRuleType.ZhunRu] = tempInGold
        tempRuleDatas[LYCRuleType.JieSanFenShu] = tempJieSanFenShu
        -- tempRuleDatas[LYCRuleType.RobLimit] = tempRobLimit

        if not IsNumber(tempBaseScore) or tempBaseScore < 0 then
            Toast.Show("请输入正确的底分")
            return
        end
        if not IsNumber(tempInGold) then
            Toast.Show("请输入正确的准入分数")
            return
        end

        if string.IsNullOrEmpty(tempRuleDatas[LYCRuleType.MaBao]) then
            Toast.Show("请输入码宝次数")
            return
        end

        if string.IsNullOrEmpty(tempRuleDatas[LYCRuleType.QZFenShu]) then
            Toast.Show("请输入抢庄分数")
            return
        end

        if tempInGold < tempBaseScore then
            Toast.Show("准入必须大于底分")
            return
        end

        -- if tempInGold < tonumber(tempRuleDatas[LYCRuleType.QZFenShu]) then
        --     Toast.Show("准入必须大于抢庄分数")
        --     return
        -- end

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

    tempPlayWayType = tempRuleDatas[LYCRuleType.PlayType]
    tempPlayerTotal = tempRuleDatas[LYCRuleType.GameTotal]
    tempGameTotal = tempRuleDatas[LYCRuleType.JuShu]
    tempConsumeId = LYCConfig.GetConsumeConfigId(tempPlayerTotal, tempGameTotal)
    tempPayType = tempRuleDatas[LYCRuleType.PayType]

    if this.roomType == RoomType.Lobby then
        BaseTcpApi.SendCreateRoom(GameType.LYC, tempRuleDatas, tempPlayerTotal, tempGameTotal, this.roomType, MoneyType.Fangka, tempConsumeId, 0, tempPayType, tempGps)
    elseif this.roomType == RoomType.Club then

    elseif this.roomType == RoomType.Tea then
        if not IsNil(this.args) then
            if not IsNil(this.args.unionCallback) then
                local data = Functions.PackGameRule(GameType.LYC, tempRuleDatas, tempPlayWayType, tempGameTotal,
                        tempPlayerTotal, tempConsumeId, tempPayType, tempBaseScore, tempInGold, tempJieSanFenShu, note, wins, consts, this.advancedData.keepBaseNum or 0, 2, this.advancedData.allToggle and 0 or 1, this.advancedData.expressionNum or 0, this.advancedData.bdPer, faceType)
                this.args.unionCallback(this.args.type, data)
            end
        end
    end
end


--保存一键配置
function CreateLYCRoomPanel.OnSaveBtnClick()
    if this.roomType == RoomType.Club then
        Alert.Prompt("确定保存一键开房配置信息？", this.OnSaveAlert)
    end
end

function CreateLYCRoomPanel.OnSaveAlert()
    local ruleDatas = this.GetPlayWayRuleDataAtUI()
    local playWayType = ruleDatas[LYCRuleType.PlayType]
    local playerTotal = ruleDatas[LYCRuleType.GameTotal]
    local gameTotal = ruleDatas[LYCRuleType.JuShu]
    local consumeId = LYCConfig.GetConsumeConfigId(playerTotal, gameTotal)
    ClubData.SendSetYjpzRule(GameType.LYC, playWayType, ruleDatas, playerTotal, gameTotal, consumeId, 0)
end


--删除一键配置
function CreateLYCRoomPanel.OnDeleteBtnClick()
    if this.roomType == RoomType.Club then
        Alert.Prompt("确定删除一键开房配置？", this.OnDeleteAlert)
    end
end

function CreateLYCRoomPanel.OnDeleteAlert()
    ClubData.SendRemoveYjpzRule(GameType.LYC, this.lastPlayWayType)
end


--菜单按钮点击
function CreateLYCRoomPanel.OnPlayWayMenuValueChanged(isOn, listener)
    if isOn then
        local dataIndex = tonumber(listener.name)
        if this.lastPlayWayType ~= dataIndex then
            this.SavePlayWayConfigData()
        end
        this.lastPlayWayType = dataIndex
        this.advancedData = CreateRoomConfig.GetAdvancedData(GameType.LYC, this.lastPlayWayType)
    end
end

--
function CreateLYCRoomPanel.UpdateConsumeDisplay()
    local playerTotal = this.CheckRuleValue(LYCRuleType.GameTotal, this.playerTotalDrop.value)
    local gameTotal = this.CheckRuleValue(LYCRuleType.JuShu, this.gameTotalDrop.value)
    local cards = LYCConfig.GetCardsConfig(playerTotal, gameTotal)
    SendEvent(CMD.Game.UpdateCreateRoomConsume, cards)
end

--获取label字体的颜色
function CreateLYCRoomPanel.SetLabelColorTxt(toggle)
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
function CreateLYCRoomPanel.OnUpdateCreateRoomAdvanced(data)
    this.advancedData = data
    CreateRoomConfig.SaveAdvancedData(GameType.LYC, this.lastPlayWayType, data)
end