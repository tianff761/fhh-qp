CreateRoomCommonPanel = ClassLuaComponent("CreateRoomCommonPanel")
--
local CELL_SIZE_3 = Vector2(250, 64)
--
local CELL_SIZE_4 = Vector2(190, 90)
--
local CELL_SIZE_5 = Vector2(150, 64)

local this = CreateRoomCommonPanel

function CreateRoomCommonPanel:Init()
    --
    this.gameType = GameType.None
    --大厅玩法数据
    this.localPlayWayData = nil
    --是否初始化了，用途是防止在创建规则项时处理事件，复选框等都需要手动初始化
    this.inited = false
    --打开面板的来源
    this.roomType = RoomType.Lobby  
    --创建房间的功能类型
    this.moneyType = MoneyType.Gold 
    --其他参数
    this.args = nil
    --组织ID，即俱乐部或者茶馆
    this.groupId = 0             
    --上次保存的玩法类型，用于查找定位当前的玩法配置数据
    this.lastPlayWayType = nil   
    --当前的玩法配置数据，配置表中的
    this.playWayConfigData = nil 
    --
    --玩法规则项，用玩法key保存的对象，对象内部参数请参考生成方法
    this.playWayRuleItems = {} 
    --
    --玩法规则数据字典
    this.playWayRuleDataDict = nil 
    --
    --ToggleGroup组件集合
    this.toggleGroupItems = {}
    --算消耗
    this.gameTotalItems = {}
    --
    --其他参数存储
    this.otherArgs = {}      
    --创建点击时间
    this.createClickTime = 0 
    --当前高级设置数据
    this.advancedData = nil
    --是否修改
    this.isModify = false
end

--UI初始化
function CreateRoomCommonPanel:Awake()
    this = self
    self:Init()
    -----------------------------------------------------------------------
    this.playWayMenuItems = {}

    this.nameLabel = self:Find("Content/Config/NameText"):GetComponent(TypeText)
    --玩法配置
    --按钮
    local config = self:Find("Content/Config")

    local bottom = config:Find("Bottom")

    local buttonTrans = bottom:Find("Button")
    this.createBtn = buttonTrans:Find("CreateButton").gameObject
    this.saveBtn = buttonTrans:Find("SaveButton").gameObject
    this.deleteBtn = buttonTrans:Find("DeleteButton").gameObject
    this.advancedBtn = buttonTrans:Find("AdvancedButton").gameObject
    this.modifyBtn = buttonTrans:Find("ModifyButton").gameObject

    --玩法选项
    local configScrollViewTrans = config:Find("ScrollView")
    this.configScrollViewGo = configScrollViewTrans.gameObject
    this.configScrollView = configScrollViewTrans:GetComponent("ScrollRect")
    this.configViewport = configScrollViewTrans:Find("Viewport"):GetComponent(TypeRectTransform)
    this.configItemContent = configScrollViewTrans:Find("Viewport/Content")
    this.configItemContentGo = this.configItemContent.gameObject
    --每一个配置项
    this.configItemPrefab = this.configItemContent:Find("Item").gameObject

    --3个选项Item
    this.ruleGroupItemPrefab = config:Find("RuleGroupItem").gameObject
    --单选项
    this.singleItemPrefab = config:Find("SingleItem").gameObject
    --可输入单选项
    this.inputSingleItemPrefab = config:Find("InputSingleItem").gameObject
    --多选项
    this.multiItemPrefab = config:Find("MultiItem").gameObject
    --Toggle组对象
    this.toggleGroupItemContent = config:Find("ToggleGroups")
    this.toggleGroupItemPrefab = this.toggleGroupItemContent:Find("ToggleGroupItem").gameObject
    --带输入选项的
    this.inputBtnItemPrefab = config:Find("InputBtnItem").gameObject
    --只有输入框的
    this.inputItemPrefab = config:Find("InputItem").gameObject
    --点问号提示
    local tips = config:Find("ScrollView/Viewport/Tips")
    this.tipsTransform = tips
    this.tipsGo = tips.gameObject
    this.tipsLabel = tips:Find("Label"):GetComponent(TypeText)

    this.AddUIListenerEvent()
end

--当面板开启开启时
function CreateRoomCommonPanel:OnOpened(fromType, funcType, args)
    this = self
    --LogError(">> CreateRoomCommonPanel > OnOpened > ", fromType, funcType)
    this.AddListenerEvent()

    local gameType = GameType.TP
    this.CheckArgsData(gameType, fromType, funcType, args)

    this.CheckUpdateConfig()

    this.InitExternalMenu(args.menuToggleDict)

    this.CheckButtonDisplay()

    this.CheckAndUpdateDisplay()
end

--当面板关闭时调用
function CreateRoomCommonPanel:OnClosed()
    this.StopTipsTimer()
    this.RemoveListenerEvent()
    --关闭的时候保存下配置
    this.SavePlayWayConfigData()
    --清除玩法类型
    this.lastPlayWayType = nil
    --
    this.advancedData = nil
    --
    this = nil
end

------------------------------------------------------------------
--
function CreateRoomCommonPanel.AddListenerEvent()
    AddEventListener(CMD.Game.UpdateNewCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
    AddEventListener(CMD.Game.UpdateCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

--
function CreateRoomCommonPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.UpdateNewCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
    RemoveEventListener(CMD.Game.UpdateCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

--UI相关事件
function CreateRoomCommonPanel.AddUIListenerEvent()
    this:AddOnClick(this.createBtn, this.OnCreateBtnClick)
    this:AddOnClick(this.saveBtn, this.OnSaveBtnClick)
    this:AddOnClick(this.deleteBtn, this.OnDeleteBtnClick)
    this:AddOnClick(this.advancedBtn, this.OnAdvancedBtnClick)
    this:AddOnClick(this.modifyBtn, this.OnModifyBtnClick)
end

--================================================================
--
--检测按钮显示
function CreateRoomCommonPanel.CheckButtonDisplay()
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
end

--初始外部菜单
function CreateRoomCommonPanel.InitExternalMenu(menuToggleDict)
    if menuToggleDict ~= nil and this.externalMenuItems == nil then
        this.externalMenuItems = {}
        local item = menuToggleDict[this.gameType]
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

--更新配置相关
function CreateRoomCommonPanel.CheckUpdateConfig()
    this.PlayWayConfigList = CreateRoomConfig.PlayWayConfig[this.gameType]
    this.RuleType = CreateRoomConfig.RuleTypeConfig[this.gameType]
end


--================================================================
--创建
function CreateRoomCommonPanel.OnCreateBtnClick()
    if os.time() - this.createClickTime < 1 then
        Toast.Show("请不要频繁操作")
        return
    end
    this.createClickTime = os.time()
    if GameManager.IsCheckGame(this.gameType) then
        this.HandleCreateRoom()
    end
end

--修改
function CreateRoomCommonPanel.OnModifyBtnClick()
    if os.time() - this.createClickTime < 1 then
        Toast.Show("请不要频繁操作")
        return
    end
    this.createClickTime = os.time()
    if GameManager.IsCheckGame(this.gameType) then
        this.HandleCreateRoom()
    end
end

--创建房间提示处理
function CreateRoomCommonPanel.OnCreateAlert()
    this.HandleCreateRoom()
end

--俱乐部和茶馆的保存
function CreateRoomCommonPanel.OnSaveBtnClick()
    if this.roomType == RoomType.Club then
        Alert.Prompt("确定保存一键开房配置信息？", this.OnSaveAlert)
    end
end

--保存一键配置提示处理
function CreateRoomCommonPanel.OnSaveAlert()
    --todo
end

--俱乐部的删除
function CreateRoomCommonPanel.OnDeleteBtnClick()
    if this.roomType == RoomType.Club then
        Alert.Prompt("确定删除一键开房配置？", this.OnDeleteAlert)
    end
end

--删除配置提示处理
function CreateRoomCommonPanel.OnDeleteAlert()
    if this.roomType == RoomType.Club then
        if this.playWayConfigData ~= nil then
            --ClubData.SendRemoveYjpzRule(this.gameType, this.playWayConfigData.playWayType)
        end
    end
end

--高级设置按钮
function CreateRoomCommonPanel.OnAdvancedBtnClick()
    local diFenConfig = CreateRoomConfig.DiFenConfig[this.gameType][this.lastPlayWayType]
    local diFenNameConfig = CreateRoomConfig.DiFenNameConfig[this.gameType][this.lastPlayWayType]
    PanelManager.Open(PanelConfig.CreateRoomAdvanced, this.advancedData, diFenConfig, diFenNameConfig, this.gameType)
end

--菜单按钮点击
function CreateRoomCommonPanel.OnPlayWayMenuValueChanged(isOn, listener)
    if isOn then
        this.SavePlayWayConfigData()
        local dataIndex = tonumber(listener.name)
        local playWayConfigData = this.PlayWayConfigList[dataIndex]
        if playWayConfigData ~= nil then
            this.playWayConfigData = playWayConfigData
        end
        this.lastPlayWayType = this.playWayConfigData.type
        if not this.isModify then
            this.advancedData = CreateRoomConfig.GetAdvancedData(this.gameType, this.lastPlayWayType)
        end
        this.UpdatePlayWayConfigDataDisplay()
    end
end

--================================================================
--
local tempPlayWayType = 1
local tempPlayerTotal = 4
local tempGameTotal = 4
local tempGps = 0
local tempConsumeId = 0
local tempPayType = PayType.Owner
local tempRuleDatas = nil
local tempBaseScore = 0
local tempInGold = 0
local tempJieSanFenShu = 0
local note = nil
local wins = ""
local consts = ""
local baoDi = 0
local bdPer = 0
local bdNum = 0
--处理创建房间
--{"keepBaseNum":1,"enterNum":500,"bdPer":0,"note":"dz10","diFen":1,"kickNum":50,"allToggle":true,"expressionNum":1}
function CreateRoomCommonPanel.HandleCreateRoom()
    tempRuleDatas = nil

    --先处理存储
    tempRuleDatas = this.SavePlayWayConfigData()

    if tempRuleDatas == nil then
        tempRuleDatas = this.GetPlayWayRuleDataAtUI()
    end
    if this.moneyType == MoneyType.Gold then
        tempBaseScore = 0
        tempInGold = 0
        tempJieSanFenShu = 0
        note = nil
        -- wins = nil
        -- consts = nil
        baoDi = 0
        bdPer = 0
        bdNum = 0
        if this.advancedData ~= nil then
            tempBaseScore = this.advancedData.diFen or 1
            tempJieSanFenShu = this.advancedData.kickNum or 0
            tempInGold = this.advancedData.enterNum or 0
            note = this.advancedData.note or this.advancedData.remarkStr
            -- wins = this.advancedData.wins
            -- consts = this.advancedData.costs
            baoDi = this.advancedData.keepBaseNum or 0
            bdPer = this.advancedData.bdPer or 0
            bdNum = this.advancedData.expressionNum or 0
        end
        --把数据存入到规则中
        tempRuleDatas[this.RuleType.DiFen] = tempBaseScore
        tempRuleDatas[this.RuleType.ZhunRu] = tempInGold
        tempRuleDatas[this.RuleType.JieSanFenShu] = tempJieSanFenShu

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
    end
    tempPlayWayType = tempRuleDatas[this.RuleType.PlayWayType]
    tempPlayerTotal = tempRuleDatas[this.RuleType.PlayerTotal]
    tempGameTotal = tempRuleDatas[this.RuleType.GameTotal]
    tempGps = tempRuleDatas[this.RuleType.Gps]
    tempConsumeId = 0
    tempPayType = tempRuleDatas[this.RuleType.Pay]

    if this.gameType == GameType.Tp then
        local qianZhu = tempRuleDatas[TpRuleType.QianZhu]
        if qianZhu == nil or qianZhu < 1 then
            Toast.Show("请输入正确的前注")
            return
        end
    end

    if this.roomType == RoomType.Lobby then
        --LogError(tempRuleDatas)
        --BaseTcpApi.SendCreateRoom(this.gameType, tempRuleDatas, tempPlayerTotal, tempGameTotal, this.roomType,
        --    this.moneyType, tempConsumeId, 0, tempPayType, tempGps)
    elseif this.roomType == RoomType.Tea then
        if not IsNil(this.args) then
            if not IsNil(this.args.unionCallback) then
                local data = Functions.PackGameRule(this.gameType, tempRuleDatas, tempPlayWayType, tempGameTotal,
                    tempPlayerTotal, tempConsumeId, tempPayType, tempBaseScore, tempInGold, tempJieSanFenShu, note, wins,
                    consts, baoDi, 2, this.advancedData.allToggle and 0 or 1, bdNum, bdPer)
                LogError(data)
                this.args.unionCallback(this.args.type, data)
            end
        end
    end
end


--================================================================
--
--处理传递参数数据
function CreateRoomCommonPanel.CheckArgsData(gameType, fromType, moneyType, args)
    --处理打开面板的来源
    this.gameType = gameType

    this.roomType = fromType
    if IsNil(this.roomType) then
        this.roomType = RoomType.Lobby
    end

    this.moneyType = moneyType
    if IsNil(this.moneyType) then
        this.moneyType = MoneyType.Fangka
    end
    this.args = args
    if IsNil(this.args) then
        this.args = {}
    end

    this.isModify = this.args.type == 2
    this.advancedData = this.args.advanceData

    this.groupId = 0

    if this.roomType == RoomType.Lobby then
        this.localPlayWayData = nil
        this.CheckLocalPlayWayData()
        this.playWayRuleDataDict = this.localPlayWayData.ruleDatas
        this.lastPlayWayType = this.localPlayWayData.lastPlayWayType
    elseif this.roomType == RoomType.Tea then
        this.localPlayWayData = nil
        this.playWayRuleDataDict = {}
        if this.isModify then
            --表示修改
            this.lastPlayWayType = TpConfig.GetPlaywayTypeByName(this.args.playWayName) --this.args.playWayType
            this.lastPlayWayName = this.args.playWayName
            this.playWayRuleDataDict[this.lastPlayWayType] = this.args.rules
        end
    else
        this.playWayRuleDataDict = {}
        this.otherArgs = {}
        if args ~= nil then
            --处理参数
            if args.groupId ~= nil then
                this.groupId = args.groupId
            end
            --
            --获取麻将的规则
            local temp = args[this.gameType]
            if temp ~= nil then
                for k, v in pairs(temp) do
                    if not IsNull(v.option) then
                        local tempObj = JsonToObj(v.option)
                        tempObj.isConfig = true
                        this.playWayRuleDataDict[k] = tempObj
                    end
                    this.otherArgs[k] = { key = v.key }
                end
            end
        end
    end
end

--更新配置数据，俱乐部的配置数据更新
function CreateRoomCommonPanel.CheckAndUpdateDisplay()
    --先清除当前存储的配置数据
    this.playWayConfigData = nil

    local length = 0
    --临时选中的玩法配置数据
    local tempSelectedPlayWayConfigData = nil
    local playWayConfigData = nil
    local playWayRuleData = nil
    local playWayMenuItem = nil

    --第一个显示的玩法数据，用于没有玩法的时候使用
    local firstPlayWayConfigData = nil
    --是否是配置数据，俱乐部的一键开房
    local isConfigData = false
    --临时变量
    local isShowPlayWayMenu = false

    local playWayMenuItems = this.playWayMenuItems
    if this.externalMenuItems ~= nil then
        playWayMenuItems = this.externalMenuItems
    end

    --修改模式下需要处理玩法菜单的屏蔽
    if this.externalMenuItems ~= nil and this.isModify then
        for i = 1, #this.externalMenuItems do
            local item = this.externalMenuItems[i]
            if item ~= nil then
                item.isShow = item.name == this.lastPlayWayName
                UIUtil.SetActive(item.gameObject, item.isShow)
                item.toggle.interactable = false
            end
        end
    end

    --激活菜单的计数
    local PlayWayConfigList = this.PlayWayConfigList

    LogError(">> PlayWayConfigList", PlayWayConfigList)

    length = #PlayWayConfigList
    for i = 1, length do
        playWayConfigData = PlayWayConfigList[i]
        --
        playWayRuleData = this.playWayRuleDataDict[playWayConfigData.type]
        --

        --玩法菜单按钮是否显示配置图标
        playWayConfigData.isConfig = playWayRuleData ~= nil and playWayRuleData.isConfig == true and isConfigData
        playWayConfigData.interactable = true

        isShowPlayWayMenu = true

        --设置为激活
        playWayConfigData.active = isShowPlayWayMenu

        --显示配置图标，处理选中项
        if this.isModify or isShowPlayWayMenu then
            if this.lastPlayWayType == playWayConfigData.type then
                tempSelectedPlayWayConfigData = playWayConfigData
            end

            if firstPlayWayConfigData == nil then
                firstPlayWayConfigData = playWayConfigData
            end
        end
    end

    --处理选中的菜单
    if tempSelectedPlayWayConfigData == nil then
        tempSelectedPlayWayConfigData = firstPlayWayConfigData
    end

    playWayMenuItem = nil
    --查找玩法配置数据对应的菜单显示项
    for i = 1, length do
        playWayConfigData = PlayWayConfigList[i]
        if playWayConfigData.active == true then

            if tempSelectedPlayWayConfigData == nil then
                tempSelectedPlayWayConfigData = playWayConfigData
            end
        end

        if tempSelectedPlayWayConfigData ~= nil and tempSelectedPlayWayConfigData.type == playWayConfigData.type then
            playWayMenuItem = playWayMenuItems[i]
            break
        end
    end

    --设置菜单按钮选中
    if playWayMenuItem ~= nil then
        playWayMenuItem.toggle.isOn = false
        playWayMenuItem.toggle.isOn = true
    else
        if tempSelectedPlayWayConfigData ~= nil then
            if this.lastPlayWayType ~= tempSelectedPlayWayConfigData.type then
                Alert.Show("界面数据错误")
                return
            end
        end
        this.playWayConfigData = tempSelectedPlayWayConfigData
        this.UpdatePlayWayConfigDataDisplay()
    end
end

--清理显示项相关
function CreateRoomCommonPanel.ClearDisplay()
    this.gameTotalItems = {}
    this.toggleGroupItems = ClearObjList(this.toggleGroupItems)
end

--更新配置数据的显示
function CreateRoomCommonPanel.UpdatePlayWayConfigDataDisplay()
    this.inited = false
    this.ClearDisplay()

    if this.playWayConfigData == nil then
        LogError(">> CreateRoomCommonPanel.UpdatePlayWayConfigDataDisplay > No data.")
        return
    end

    this.nameLabel.text = this.playWayConfigData.name

    --配置了的规则，用于更新显示
    local playWayRuleData = this.playWayRuleDataDict[this.playWayConfigData.type]
    if playWayRuleData == nil then
        playWayRuleData = {}
        playWayRuleData.isEmpty = true
    else
        playWayRuleData.isEmpty = false
    end

    --是否显示支付方式类型
    local isDisplayPayment = this.roomType == RoomType.Lobby
    --是否显示底分
    local isDisplayScore = this.moneyType == MoneyType.Gold

    --是否显示规则
    local isDisplayRule = false
    --规则组配置数据
    local playWayRuleGroupConfigData = nil
    --
    --标记未激活
    local playWayRuleItem = nil
    for k, v in pairs(this.playWayRuleItems) do
        v.isActive = false
    end

    --处理规则项创建或者显示
    for i = 1, #this.playWayConfigData.ruleGroups do
        playWayRuleGroupConfigData = this.playWayConfigData.ruleGroups[i]

        isDisplayRule = false

        if playWayRuleGroupConfigData.data.type == TpRuleGroupType.Pay then
            isDisplayRule = isDisplayPayment
        else
            isDisplayRule = true
        end

        if isDisplayRule then
            playWayRuleItem = this.playWayRuleItems[playWayRuleGroupConfigData.data.type]
            if playWayRuleItem == nil then
                playWayRuleItem = this.CreatePlayWayRuleItem(i, playWayRuleGroupConfigData)
                this.playWayRuleItems[playWayRuleGroupConfigData.data.type] = playWayRuleItem
            else
                playWayRuleItem.gameObject.name = tostring(i)
            end
            playWayRuleItem.isActive = true
            this.SetPlayWayRuleItem(playWayRuleItem, playWayRuleGroupConfigData, playWayRuleData)
        end
    end
    UIUtil.SetAnchoredPositionY(this.configItemContentGo, 0)
    --隐藏未激活的玩法规则项
    for k, v in pairs(this.playWayRuleItems) do
        if not v.isActive then
            UIUtil.SetActive(v.gameObject, false)
        end
    end
    this.inited = true
    --更新钻石消耗
    this.UpdateConsumeDisplay()
end

--创建一个规则组显示项
function CreateRoomCommonPanel.CreatePlayWayRuleItem(ruleGroupIndex, playWayRuleGroupConfigData)
    local item = {}
    item.ruleGroupIndex = ruleGroupIndex
    item.isActive = false
    item.gameObject = CreateGO(this.configItemPrefab, this.configItemContent, tostring(ruleGroupIndex))
    item.transform = item.gameObject.transform
    item.ruleGroupTrans = item.transform:Find("RuleGroup")
    item.ruleTxt = item.transform:Find("Text"):GetComponent(TypeText)
    item.ruleTxt.text = playWayRuleGroupConfigData.data.name
    item.items = {}
    --里面存放的对象参考创建方法
    return item
end

--设置一个规则组显示项数据
function CreateRoomCommonPanel.SetPlayWayRuleItem(playWayRuleItem, playWayRuleGroupConfigData, playWayRuleData)
    UIUtil.SetActive(playWayRuleItem.gameObject, true)
    --Item排序，防止不同玩法的牌型不同，导致UI排序错误
    playWayRuleItem.transform:SetAsLastSibling()

    --规则配置数据
    local ruleConfigData = nil

    local ruleGroups = {}
    local ruleGroupDict = {}
    local ruleGroup = nil

    --规则组配置类型
    local ruleGroupConfigType = playWayRuleGroupConfigData.data.type
    --
    --首先分组
    for i = 1, #playWayRuleGroupConfigData.rules do
        ruleConfigData = playWayRuleGroupConfigData.rules[i]
        --动态给数据设置序号，该值很重要，在查找显示对象时需要
        ruleConfigData.order = i
        ruleConfigData.name = tostring(ruleGroupConfigType + i)
        this.HandleRuleGroup(ruleGroups, ruleGroupDict, ruleConfigData, ruleConfigData.data.group)
    end

    local item = nil
    --先重置标记
    for i = 1, #playWayRuleItem.items do
        item = playWayRuleItem.items[i]
        item.isActive = false
    end

    --排序
    --table.sort(ruleGroups, this.SortRuleGroup)

    local itemMaxCol = 3
    local cellSize = nil
    local ruleGroupConfigType = nil
    local length = 0
    for i = 1, #ruleGroups do
        ruleGroup = ruleGroups[i]
        --计算需要显示的项
        length = #ruleGroup
        --
        ruleConfigData = ruleGroup[1]

        ruleGroupConfigType = playWayRuleGroupConfigData.data.type
        --itemMaxCol = 4
        cellSize = CELL_SIZE_4

        item = playWayRuleItem.items[i]
        if item == nil then
            item = this.CreatePlayWayRuleGroupItem(i, playWayRuleItem.ruleGroupTrans)
            playWayRuleItem.items[i] = item
        else
            item.gameObject.name = tostring(i)
        end
        item.gridLayoutGroup.constraintCount = itemMaxCol
        item.gridLayoutGroup.cellSize = cellSize
        item.isActive = true
        --
        this.SetPlayWayRuleGroupItem(item, ruleGroup, playWayRuleData)
    end
    for i = 1, #playWayRuleItem.items do
        item = playWayRuleItem.items[i]
        if not item.isActive then
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

--组排序
function CreateRoomCommonPanel.SortRuleGroup(data1, data2)
    return data1.order < data2.order
end

--处理规则分组
function CreateRoomCommonPanel.HandleRuleGroup(ruleGroups, ruleGroupDict, ruleConfigData, group)
    local groupName = tostring(group)
    local ruleGroup = ruleGroupDict[groupName]
    if ruleGroup == nil then
        ruleGroup = {}
        ruleGroup.name = groupName
        if group ~= 0 then
            ruleGroup.order = group
        else
            ruleGroup.order = 1000
        end
        ruleGroupDict[groupName] = ruleGroup
        table.insert(ruleGroups, ruleGroup)
    end
    table.insert(ruleGroup, ruleConfigData)
end

--创建规则组显示项
function CreateRoomCommonPanel.CreatePlayWayRuleGroupItem(index, parent)
    local item = {}
    item.gameObject = CreateGO(this.ruleGroupItemPrefab, parent, tostring(index))
    item.transform = item.gameObject.transform
    item.isActive = false
    item.gridLayoutGroup = item.gameObject:GetComponent("GridLayoutGroup")
    item.singleItems = {}
    item.multiItems = {}
    item.btnItems = {}
    item.inputItems = {}
    return item
end

--设置规则组数据
function CreateRoomCommonPanel.SetPlayWayRuleGroupItem(ruleGroupItem, ruleGroup, playWayRuleData)
    UIUtil.SetActive(ruleGroupItem.gameObject, true)

    local ruleConfigData = nil
    local ruleData = nil
    local singleIndex = 0
    local multiIndex = 0
    local btnIndex = 0
    local inputIndex = 0
    local item = nil
    --重置标记
    for i = 1, #ruleGroupItem.singleItems do
        ruleGroupItem.singleItems[i].isActive = false
    end

    for i = 1, #ruleGroupItem.multiItems do
        ruleGroupItem.multiItems[i].isActive = false
    end

    for i = 1, #ruleGroupItem.btnItems do
        ruleGroupItem.btnItems[i].isActive = false
    end

    for i = 1, #ruleGroupItem.inputItems do
        ruleGroupItem.inputItems[i].isActive = false
    end

    for i = 1, #ruleGroup do
        ruleConfigData = ruleGroup[i]
        ruleData = ruleConfigData.data
        item = nil
        if ruleData.itemType ~= nil then
            if ruleData.itemType == 1 then
                btnIndex = btnIndex + 1
                item = ruleGroupItem.btnItems[btnIndex]
                if item == nil then
                    item = InputBtnIem.New()
                    item.itemType = ruleData.itemType
                    item:Init(CreateGO(this.inputBtnItemPrefab, ruleGroupItem.transform, ruleConfigData.name))
                    ruleGroupItem.btnItems[btnIndex] = item
                else
                    item.gameObject.name = ruleConfigData.name
                end
                item:Set(ruleData.min, ruleData.max, ruleData.step, ruleData.value, ruleData.suffix)
            elseif ruleData.itemType == 2 then
                inputIndex = inputIndex + 1
                item = ruleGroupItem.inputItems[inputIndex]
                if item == nil then
                    item = this.CreateInputItem(this.inputItemPrefab, ruleGroupItem.transform, ruleConfigData.name)
                    item.itemType = ruleData.itemType
                    ruleGroupItem.inputItems[inputIndex] = item
                else
                    item.gameObject.name = ruleConfigData.name
                end
            end
        elseif ruleData.group ~= 0 then
            singleIndex = singleIndex + 1
            item = ruleGroupItem.singleItems[singleIndex]
            if item == nil then
                item = this.CreatePlayWayRuleConfigItem(this.singleItemPrefab, ruleGroupItem.transform,
                    ruleConfigData.name)
                ruleGroupItem.singleItems[singleIndex] = item
            else
                item.gameObject.name = ruleConfigData.name
            end
        else
            multiIndex = multiIndex + 1
            item = ruleGroupItem.multiItems[multiIndex]
            if item == nil then
                item = this.CreatePlayWayRuleConfigItem(this.multiItemPrefab, ruleGroupItem.transform,
                    ruleConfigData.name)
                ruleGroupItem.multiItems[multiIndex] = item
            else
                item.gameObject.name = ruleConfigData.name
            end
        end

        if item ~= nil then
            if ruleData.type == this.RuleType.GameTotal and this.moneyType == MoneyType.Fangka and ruleData.value == -1 then
                item.isActive = false
            else
                item.isActive = true
            end
            this.SetPlayWayRuleConfigItem(item, ruleConfigData, playWayRuleData)
            UIUtil.SetAsLastSibling(item.transform)
        end
    end

    --隐藏多余的显示项
    for i = 1, #ruleGroupItem.singleItems do
        item = ruleGroupItem.singleItems[i]
        if not item.isActive then
            item.toggle.isOn = false
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
    for i = 1, #ruleGroupItem.multiItems do
        item = ruleGroupItem.multiItems[i]
        if not item.isActive then
            item.toggle.isOn = false
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
    for i = 1, #ruleGroupItem.btnItems do
        item = ruleGroupItem.btnItems[i]
        if not item.isActive then
            item.toggle.isOn = false
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
    for i = 1, #ruleGroupItem.inputItems do
        item = ruleGroupItem.inputItems[i]
        if not item.isActive then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

--获取ToggleGroup组件
function CreateRoomCommonPanel.GetToggleGroupItem(type, group)
    local toggleGroupItemName = type .. "_" .. group
    local toggleGroupItem = this.toggleGroupItems[toggleGroupItemName]
    if toggleGroupItem == nil then
        toggleGroupItem = CreateGO(this.toggleGroupItemPrefab, this.toggleGroupItemContent, toggleGroupItemName)
        this.toggleGroupItems[toggleGroupItemName] = toggleGroupItem
    end
    return toggleGroupItem
end

--创建具体的一个规则
function CreateRoomCommonPanel.CreatePlayWayRuleConfigItem(prefab, parent, order)
    local item = {}
    item.itemType = nil
    --用于标识是否激活
    item.isActive = false
    --用于事件
    item.inited = false
    --时候可以交互
    item.interactable = false
    item.gameObject = CreateGO(prefab, parent, tostring(order))
    item.transform = item.gameObject.transform
    item.label = item.transform:Find("Label"):GetComponent(TypeText)
    local background = item.transform:Find("Background")
    item.grayBg = background:Find("GrayBg").gameObject
    item.grayMask = background:Find("GrayMask").gameObject
    item.toggle = item.gameObject:GetComponent(TypeToggle)
    local temp = item.transform:Find("TipsBtn")
    if temp ~= nil then
        item.tips = temp
        item.tipsBtnGo = temp.gameObject
        EventUtil.AddOnClick(item.tipsBtnGo, function() this.OnTipsBtnClick(item) end)
    end
    item.data = nil
    return item
end

--创建具体的一个规则
function CreateRoomCommonPanel.CreateInputItem(prefab, parent, name)
    local item = {}
    item.itemType = nil
    --用于标识是否激活
    item.isActive = false
    --用于事件
    item.inited = false
    --时候可以交互
    item.interactable = false
    item.gameObject = CreateGO(prefab, parent, tostring(name))
    item.transform = item.gameObject.transform
    item.input = item.transform:Find("InputField"):GetComponent(TypeInputField)
    item.inputLabel = item.transform:Find("InputField/Text"):GetComponent(TypeText)
    item.inputLabel.color = CreateRoomConfig.COLOR_SELECTED
    local temp = item.transform:Find("TipsBtn")
    if temp ~= nil then
        item.tips = temp
        item.tipsBtnGo = temp.gameObject
        EventUtil.AddOnClick(item.tipsBtnGo, function() this.OnTipsBtnClick(item) end)
    end
    item.data = nil
    return item
end

function CreateRoomCommonPanel.OnTipsBtnClick(item)
    if item.data ~= nil then
        this.tipsLabel.text = item.data.data.tips

        local temp = RectTransformUtility.WorldToScreenPoint(UIConst.uiCamera, item.tips.position)
        local position = UIUtil.ScreenToLocalPosition(this.configViewport, temp, UIConst.uiCamera)

        this.tipsTransform.localPosition = Vector3(position.x - 73, position.y + 70, 0)
        UIUtil.SetActive(this.tipsGo, true)

        this.StartTipsTimer()
    end
end

--开启提示计时器
function CreateRoomCommonPanel.StartTipsTimer()
    if this.tipsTimer == nil then
        this.tipsTimer = UpdateTimer.New(this.OnTipsTimer)
    end
    this.tipsTimer:Start()
end

--停止提示计时器
function CreateRoomCommonPanel.StopTipsTimer()
    if this.tipsTimer ~= nil then
        this.tipsTimer:Stop()
    end
end

--处理提示计时器
function CreateRoomCommonPanel.OnTipsTimer()
    if Input.anyKeyDown then
        this.StopTipsTimer()
        UIUtil.SetActive(this.tipsGo, false)
    end
end

--
local tempGroup = nil
local tempType = 0
local tempToggle = nil
local tempSelected = nil
local tempInteractable = true
local itemType = nil

--设置具体规则数据
function CreateRoomCommonPanel.SetPlayWayRuleConfigItem(ruleConfigItem, ruleConfigData, playWayRuleData)
    --存储数据，用于获取
    ruleConfigItem.data = ruleConfigData

    --设置显示
    UIUtil.SetActive(ruleConfigItem.gameObject, true)

    tempGroup = ruleConfigData.data.group
    tempType = ruleConfigData.data.type
    itemType = ruleConfigData.data.itemType
    tempToggle = ruleConfigItem.toggle
    tempSelected = nil
    tempInteractable = true
    if tempType == this.RuleType.GameTotal then
        --选中局数，处理钻石消耗显示
        if not ruleConfigItem.inited then
            EventUtil.AddToggleListener(ruleConfigItem.toggle,
                function(isOn) this.OnConsumeCardsChanged(ruleConfigItem, isOn) end)
        end
        table.insert(this.gameTotalItems, ruleConfigItem)
    elseif tempType == TpRuleType.QianZhu then
        if not ruleConfigItem.inited then
            --ruleConfigItem.input.onValueChanged:AddListener(this.OnQianZhuValueChanged)
        end
    else
        if not ruleConfigItem.inited then
            EventUtil.AddToggleListener(ruleConfigItem.toggle,
                function(isOn) this.OnToggleValueChanged(ruleConfigItem, isOn) end)
        end
    end
    --
    --
    ruleConfigItem.inited = true
    --给Toggle设置ToggleGroup
    if tempGroup ~= 0 then
        local toggleGroupItem = this.GetToggleGroupItem(tempType, tempGroup)
        if toggleGroupItem ~= nil then
            local toggleGroup = toggleGroupItem:GetComponent("ToggleGroup")
            tempToggle.group = toggleGroup
        end
    else
        if tempToggle ~= nil then
            tempToggle.group = nil
        end
    end

    --主要是针对俱乐部一键开房时可以由玩家选择
    if tempType == this.RuleType.Gps then
        tempInteractable = true
    else
        tempInteractable = tempInteractable and this.playWayConfigData.interactable and ruleConfigData.interactable
    end
    ruleConfigItem.interactable = tempInteractable
    if tempToggle ~= nil then
        tempToggle.interactable = tempInteractable
    end

    --处理缓存配置选中
    if tempSelected == nil then
        if playWayRuleData == nil or playWayRuleData.isEmpty then
            tempSelected = ruleConfigData.selected
            --
            if itemType == 1 then
                ruleConfigItem:SetValue(ruleConfigItem.default)
            elseif itemType == 2 then
                ruleConfigItem.input.text = ruleConfigData.data.value
            end
        else
            local cacheRuleValue = playWayRuleData[ruleConfigData.data.type]
            if cacheRuleValue ~= nil then
                --
                if itemType == 1 then
                    if cacheRuleValue >= ruleConfigData.data.min and cacheRuleValue <= ruleConfigData.data.max then
                        tempSelected = true
                        ruleConfigItem:SetValue(cacheRuleValue)
                    else
                        ruleConfigItem:SetValue(ruleConfigItem.default)
                        tempSelected = false
                    end
                elseif itemType == 2 then
                    ruleConfigItem.input.text = cacheRuleValue
                else
                    tempSelected = cacheRuleValue == ruleConfigData.data.value
                end
            else
                tempSelected = ruleConfigData.selected
                --
                if itemType == 1 then
                    ruleConfigItem:SetValue(ruleConfigItem.default)
                elseif itemType == 2 then
                    ruleConfigItem.input.text = ruleConfigData.data.value
                end
            end
        end
    end

    if tempToggle ~= nil then
        tempToggle.isOn = tempSelected
    end

    if ruleConfigItem.label ~= nil then
        --文本显示
        local nameStr = ruleConfigData.data.name
        --特殊显示处理
        if ruleConfigData.data.desc ~= nil then
            nameStr = ruleConfigData.data.desc
        end
        ruleConfigItem.label.text = nameStr
    end

    --处理提示按钮
    if ruleConfigItem.tipsBtnGo ~= nil then
        if ruleConfigData.data.tips ~= nil then
            UIUtil.SetActive(ruleConfigItem.tipsBtnGo, true)
        else
            UIUtil.SetActive(ruleConfigItem.tipsBtnGo, false)
        end
    end
    --
    this.UpdateToggleStatus(ruleConfigItem, tempSelected)
end

--处理Toggle选项的状态，比如选中、禁用等颜色
function CreateRoomCommonPanel.UpdateToggleStatus(ruleConfigItem, isOn)
    if ruleConfigItem.itemType == 2 then
        --TODO
    else
        local toggle = ruleConfigItem.toggle
        if isOn == nil then
            isOn = toggle.isOn
        end
        if ruleConfigItem.interactable then
            if isOn then
                ruleConfigItem.label.color = CreateRoomConfig.COLOR_SELECTED
            else
                ruleConfigItem.label.color = CreateRoomConfig.COLOR_NORMAL
            end
            --
            if ruleConfigItem.valueLabel ~= nil then
                if isOn then
                    ruleConfigItem.valueLabel.color = CreateRoomConfig.COLOR_SELECTED
                else
                    ruleConfigItem.valueLabel.color = CreateRoomConfig.COLOR_NORMAL
                end
            end
            --
            if ruleConfigItem.grayBg ~= nil then
                UIUtil.SetActive(ruleConfigItem.grayBg, false)
            end
            if ruleConfigItem.grayMask ~= nil then
                UIUtil.SetActive(ruleConfigItem.grayMask, false)
            end
        else
            ruleConfigItem.label.color = CreateRoomConfig.COLOR_FORBIDDEN
            --
            if ruleConfigItem.valueLabel ~= nil then
                ruleConfigItem.valueLabel.color = CreateRoomConfig.COLOR_FORBIDDEN
            end
            --
            if ruleConfigItem.grayBg ~= nil then
                UIUtil.SetActive(ruleConfigItem.grayBg, true)
            end
            if ruleConfigItem.grayMask ~= nil then
                UIUtil.SetActive(ruleConfigItem.grayMask, isOn)
            end
        end
    end
end

--处理Toggle选项的选择状态
function CreateRoomCommonPanel.UpdateToggleSelectedStatus(item)
    if item.toggle ~= nil then
        if item.toggle.isOn then
            item.label.color = CreateRoomConfig.COLOR_SELECTED
        else
            item.label.color = CreateRoomConfig.COLOR_NORMAL
        end
    end
    --
    if item.valueLabel ~= nil then
        if item.toggle.isOn then
            item.valueLabel.color = CreateRoomConfig.COLOR_SELECTED
        else
            item.valueLabel.color = CreateRoomConfig.COLOR_NORMAL
        end
    end
end

--选项值改变
function CreateRoomCommonPanel.OnToggleValueChanged(item, isOn)
    if not this.inited then
        return
    end
    this.UpdateToggleSelectedStatus(item)
end

--局数选择
function CreateRoomCommonPanel.OnConsumeCardsChanged(item, isOn)
    if not this.inited then
        return
    end
    this.UpdateToggleSelectedStatus(item)
    if isOn then
        this.UpdateConsumeDisplay()
    end
end

--更新钻石消耗显示
function CreateRoomCommonPanel.UpdateConsumeDisplay()
    local item = nil
    local cards = 0
    for i = 1, #this.gameTotalItems do
        item = this.gameTotalItems[i]
        if item.toggle.isOn then
            if item.data ~= nil then
                if this.roomType == RoomType.Tea then
                    cards = item.data.data.cards2
                else
                    cards = item.data.data.cards
                end
                SendEvent(CMD.Game.UpdateCreateRoomConsume, cards or 0)
            end
            break
        end
    end
end

--================================================================
--获取本地玩法数据的Key
function CreateRoomCommonPanel.GetPlayWayDataKey()
    return string.format("PlayWayData-%s", this.gameType)
end

--
--检测存储的玩法缓存数据
function CreateRoomCommonPanel.CheckLocalPlayWayData()
    if this.localPlayWayData == nil then
        this.localPlayWayData = {}
        this.localPlayWayData.ruleDatas = {}

        local temp = nil
        local str = GetLocal(this.GetPlayWayDataKey(), nil)
        if str ~= nil then
            temp = JsonToObj(str)
        end

        if temp ~= nil then
            this.localPlayWayData.lastPlayWayType = temp.lastPlayWayType
            if this.localPlayWayData.lastPlayWayType == nil then
                if this.PlayWayConfigList ~= nil then
                    this.localPlayWayData.lastPlayWayType = this.PlayWayConfigList[1].type
                end
            end

            if temp.ruleDatas ~= nil then
                local length = #temp.ruleDatas
                local playWayType = nil
                local ruleData = nil
                for i = 1, length do
                    ruleData = temp.ruleDatas[i]
                    if IsTable(ruleData) then
                        ruleData.isConfig = false
                        playWayType = ruleData[this.RuleType.PlayWayType]
                        if playWayType ~= nil then
                            this.localPlayWayData.ruleDatas[playWayType] = ruleData
                        end
                    end
                end
            end
        end
    end
end

--保存到本地存储中
function CreateRoomCommonPanel.SaveLocalPlayWayConfigData()
    if this.localPlayWayData ~= nil then
        local temp = {}
        temp.lastPlayWayType = this.localPlayWayData.lastPlayWayType
        if this.localPlayWayData.ruleDatas ~= nil then
            temp.ruleDatas = {}
            for k, v in pairs(this.localPlayWayData.ruleDatas) do
                if IsTable(v) then
                    table.insert(temp.ruleDatas, v)
                end
            end
        end
        local str = ObjToJson(temp)
        SetLocal(this.GetPlayWayDataKey(), str)
    end
end

--保存配置数据
function CreateRoomCommonPanel.SavePlayWayConfigData()
    if this.playWayConfigData == nil then
        return nil
    end
    if this.roomType == RoomType.Lobby or this.roomType == RoomType.Club then
        local playWayRuleData = this.GetPlayWayRuleDataAtUI()

        local temp = this.playWayRuleDataDict[this.playWayConfigData.type]
        if temp ~= nil and temp.isConfig == true then
            --有配置属性的认为是俱乐部已经配置的，不进行保存
        else
            this.playWayRuleDataDict[this.playWayConfigData.type] = playWayRuleData
        end
        if this.roomType == RoomType.Lobby then
            --保存选中的玩法类型
            this.localPlayWayData.lastPlayWayType = this.lastPlayWayType
            this.SaveLocalPlayWayConfigData()
        end
        return playWayRuleData
    else
        return nil
    end
end

--获取当前选择的UI上显示的玩法规则字符串
function CreateRoomCommonPanel.GetPlayWayRuleDataAtUI()
    if this.playWayConfigData == nil then
        return {}
    end

    --玩法规则对象
    local playWayRuleData = {}
    --包含规则
    local includeRules = {}

    --遍历所有的显示项
    for k, v in pairs(this.playWayRuleItems) do
        if v.isActive then
            for i = 1, #v.items do
                this.CheckRuleGroupItem(v.items[i], playWayRuleData, includeRules)
            end
        end
    end

    LogError(">> CreateRoomCommonPanel.GetPlayWayRuleDataAtUI > this.playWayConfigData", this.playWayConfigData)

    --玩法类型
    playWayRuleData[this.RuleType.PlayWayType] = this.playWayConfigData.type
    --房间类型
    playWayRuleData[this.RuleType.RoomType] = this.roomType

    --默认规则配置
    local ruleConfigData = nil
    if this.playWayConfigData.defaultRuleGroups ~= nil then
        for i = 1, #this.playWayConfigData.defaultRuleGroups do
            ruleConfigData = this.playWayConfigData.defaultRuleGroups[i]
            playWayRuleData[ruleConfigData.type] = ruleConfigData.value
        end
    end

    --支付方式，俱乐部固定传3
    if playWayRuleData[this.RuleType.Pay] == nil then
        if this.roomType == RoomType.Club or this.roomType == RoomType.Tea then
            playWayRuleData[this.RuleType.Pay] = 3
        end
    end

    LogError(">> CreateRoomCommonPanel.GetPlayWayRuleDataAtUI > ", playWayRuleData)
    return playWayRuleData
end

--检测规则组显示对象
function CreateRoomCommonPanel.CheckRuleGroupItem(ruleGroupItem, playWayRuleData, includeRules)
    if ruleGroupItem.isActive then
        local ruleConfigItem = nil
        local ruleConfigData = nil

        for i = 1, #ruleGroupItem.singleItems do
            ruleConfigItem = ruleGroupItem.singleItems[i]
            if ruleConfigItem.isActive then
                ruleConfigData = ruleConfigItem.data
                if ruleConfigData ~= nil then
                    --处理玩法包含的规则
                    includeRules[ruleConfigData.data.type] = ruleConfigData.data.type
                    local inputValue = nil
                    if ruleConfigItem.inputField ~= nil then
                        inputValue = tonumber(ruleConfigItem.inputField.text)
                    end
                    this.CheckAndSetRuleData(playWayRuleData, ruleConfigData, ruleConfigItem.toggle.isOn, inputValue)
                end
            end
        end

        for i = 1, #ruleGroupItem.multiItems do
            ruleConfigItem = ruleGroupItem.multiItems[i]
            if ruleConfigItem.isActive then
                ruleConfigData = ruleConfigItem.data
                if ruleConfigData ~= nil then
                    --处理玩法包含的规则
                    includeRules[ruleConfigData.data.type] = ruleConfigData.data.type
                    this.CheckAndSetRuleData(playWayRuleData, ruleConfigData, ruleConfigItem.toggle.isOn)
                end
            end
        end

        for i = 1, #ruleGroupItem.btnItems do
            ruleConfigItem = ruleGroupItem.btnItems[i]
            if ruleConfigItem.isActive then
                ruleConfigData = ruleConfigItem.data
                if ruleConfigData ~= nil then
                    --处理玩法包含的规则
                    includeRules[ruleConfigData.data.type] = ruleConfigData.data.type
                    this.CheckAndSetRuleData(playWayRuleData, ruleConfigData, ruleConfigItem.toggle.isOn,
                        ruleConfigItem.value)
                end
            end
        end

        for i = 1, #ruleGroupItem.inputItems do
            ruleConfigItem = ruleGroupItem.inputItems[i]
            if ruleConfigItem.isActive then
                ruleConfigData = ruleConfigItem.data
                if ruleConfigData ~= nil then
                    --处理玩法包含的规则
                    includeRules[ruleConfigData.data.type] = ruleConfigData.data.type
                    --
                    playWayRuleData[ruleConfigData.data.type] = tonumber(ruleConfigItem.input.text)
                end
            end
        end
    end
end

--获取规则的数据对象，用于服务器交互
function CreateRoomCommonPanel.CheckAndSetRuleData(playWayRuleData, ruleConfigData, selected, inputValue)
    if ruleConfigData == nil then
        return
    end

    if ruleConfigData.data.group ~= 0 then
        --单选
        if selected then
            if IsNil(inputValue) then
                playWayRuleData[ruleConfigData.data.type] = ruleConfigData.data.value
            else
                playWayRuleData[ruleConfigData.data.type] = inputValue
            end
        end
    else
        --多选
        if selected then
            playWayRuleData[ruleConfigData.data.type] = ruleConfigData.data.value
        else
            if ruleConfigData.data.default ~= nil then
                playWayRuleData[ruleConfigData.data.type] = ruleConfigData.data.default
            else
                playWayRuleData[ruleConfigData.data.type] = 0
            end
        end
    end
end

--更新创建房间高级设置
function CreateRoomCommonPanel.OnUpdateCreateRoomAdvanced(data)
    LogError(">> CreateRoomCommonPanel.OnUpdateCreateRoomAdvanced", data)
    this.advancedData = data
    CreateRoomConfig.SaveAdvancedData(this.gameType, this.lastPlayWayType, data)
end
