CreateLSPdkRoomPanel = ClassLuaComponent("CreateLSPdkRoomPanel")
CreateLSPdkRoomPanel.Instance = nil

--
local CELL_SIZE_3 = Vector2(190, 90)
--
local CELL_SIZE_4 = Vector2(190, 90)
--
local CELL_SIZE_2 = Vector2(380, 90)
--
local CELL_SIZE_1 = Vector2(760, 90)

--大厅菜单
local LobbyMenus = { 0, 0, 3, 4, 5, }
--联盟菜单
local UnionMenus = { 0, 0, 3, 4, 5, }
--俱乐部菜单
local ClubMenus1 = { 0, 0, 3, 4, 5, }
local ClubMenus2 = { 0, 0, 3, 4, 5, }

local this = CreateLSPdkRoomPanel

function CreateLSPdkRoomPanel:Init()
    --大厅玩法数据
    this.lobbyPlayWayData = nil
    --是否初始化了，用途是防止在创建规则项时处理事件，复选框等都需要手动初始化
    this.inited = false
    --打开面板的来源
    this.roomType = RoomType.Lobby   --11
    --创建房间的功能类型
    this.moneyType = MoneyType.Gold  --11
    --其他参数 
    this.args = nil
    --组织ID，即俱乐部或者茶馆
    this.groupId = 0   --11
    --上次保存的玩法类型，用于查找定位当前的玩法配置数据
    this.lastPlayWayType = nil  --11
    --当前的玩法配置数据，配置表中的
    this.playWayConfigData = nil --11
    --
    --玩法规则项，用玩法key保存的对象，对象内部参数请参考生成方法
    this.playWayRuleItems = {}  --11
    --
    --玩法规则数据，普通创建即NormalPlayWayRuleData，其他的就是传递过来的参数
    this.playWayRuleDatas = nil  --11

    --ToggleGroup组件集合
    this.toggleGroupItems = {}
    --存储局数规则显示项
    this.gameTotalItems = {}
    --
    --其他参数存储
    this.otherArgs = {}  --11
    --创建点击时间
    this.createClickTime = 0  --11
    --当前高级设置数据
    this.advancedData = nil
    --是否处理特殊玩法的Toggle
    this.isHandleSpecialPlayWayToggle = true
    --是否处理特殊玩法的所有按钮Toggle
    this.isHandleSpecialPlayWayAllToggle = true
    --当前高级设置数据
    this.advancedData = nil
    --是否修改
    this.isModify = false
end

--UI初始化
function CreateLSPdkRoomPanel:Awake()
    this = self
    self:Init()
    -----------------------------------------------------------------------
    --玩法菜单按钮
    local menuTrans = self:Find("Content/Menu")
    this.menu = menuTrans.gameObject
    this.menuContentTrans = menuTrans:Find("ScrollView/Viewport/Content")

    this.playWayMenuItems = {}

    this.nameLabel = self:Find("Content/Config/NameText"):GetComponent(TypeText)

    --玩法配置
    --按钮
    local configTrans = self:Find("Content/Config")
    local bottomTrans = configTrans:Find("Bottom")
    this.tips = bottomTrans:Find("Tips").gameObject
    local buttonTrans = bottomTrans:Find("Button")
    this.createBtn = buttonTrans:Find("CreateButton").gameObject
    this.saveBtn = buttonTrans:Find("SaveButton").gameObject
    this.deleteBtn = buttonTrans:Find("DeleteButton").gameObject
    this.advancedBtn = buttonTrans:Find("AdvancedButton").gameObject
    this.modifyBtn = buttonTrans:Find("ModifyButton").gameObject

    --玩法选项
    local configScorllViewTrans = configTrans:Find("ScrollView")
    this.configScorllViewGO = configScorllViewTrans.gameObject
    this.configScorllView = configScorllViewTrans:GetComponent("ScrollRect")
    this.configContent = configScorllViewTrans:Find("Viewport/Content")
    this.configContentGO = this.configContent.gameObject
    --每一个配置项
    this.configItemPrefab = this.configContent:Find("Item").gameObject

    this.configLine = this.configContent:Find("Line")
    this.configLinePrefab = this.configLine.gameObject
    this.configLinePrefabText = this.configContent:Find("Line/SpecialType/Text"):GetComponent(TypeText)
    this.configLinePrefabBtn = this.configContent:Find("Line/SpecialType/OpenSpeicalBtn"):GetComponent(TypeButton)
    this.CloseSpecialBtn = this.configContent:Find("Line/CloseSpecialBtn"):GetComponent(TypeButton)
    this.SpecialPlayWayToggleParent = this.configContent:Find("Line/SpecialPlayWay").gameObject
    this.SpecialPlayWayToggleGroup = this.SpecialPlayWayToggleParent.transform:Find("Content")
    this.SpecialPlayWayItems = {}
    for i = 0, this.SpecialPlayWayToggleGroup.childCount - 1 do
        local item = {}
        item.gameObject = this.SpecialPlayWayToggleGroup:GetChild(i).gameObject
        item.name = item.gameObject.name
        item.toggle = item.gameObject:GetComponent(TypeToggle)
        table.insert(this.SpecialPlayWayItems, item)
    end

    this.SelectAllToggle = this.SpecialPlayWayToggleParent.transform:Find("SelectAll"):GetComponent(TypeToggle)
    this.SpecialPlayWayTable = CopyTable(PdkConfig.SpecialPlayWay, true)

    --3个选项Item
    this.ruleGroupItemPrefab = configTrans:Find("RuleGroupItem").gameObject
    --单选项
    this.singleItemPrefab = configTrans:Find("SingleItem").gameObject
    --可输入单选项
    this.inputSingleItemPrefab5 = configTrans:Find("InputSingleItem").gameObject
    this.inputSingleItemPrefab6 = configTrans:Find("InputSingleItem6").gameObject
    --多选项
    this.multiItemPrefab = configTrans:Find("MultiItem").gameObject
    this.toggleGroups = configTrans:Find("ToggleGroups")
    this.toggleGroupItemPrefab = this.toggleGroups:Find("ToggleGroupItem").gameObject

    this.AddUIListenerEvent()

    -----------------------------------
    this.scrollRect = menuTrans:Find("ScrollView"):GetComponent(TypeScrollRect)
    this.scrollRectContent = this.scrollRect.content
    local downImage = self:Find("Content/Menu/DownImage")
    ScrollRectHelper.New(this.scrollRect, downImage)
    -----------------------------------
end

--当面板开启开启时
function CreateLSPdkRoomPanel:OnOpened(fromType, funcType, args)
    LogError(">> CreateLSPdkRoomPanel > OnOpened > ", fromType, funcType)
    CreateLSPdkRoomPanel.Instance = self
    local v3 = this.scrollRectContent.localPosition
    this.scrollRectContent.localPosition = Vector2(v3.x, 0)

    this.AddListenerEvent()

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
end

--当面板关闭时调用
function CreateLSPdkRoomPanel:OnClosed()
    CreateLSPdkRoomPanel.Instance = nil
    this.RemoveListenerEvent()
    --关闭的时候保存下配置
    this.SavePlayWayConfigData()
    --清除玩法类型
    this.lastPlayWayType = nil
    --
    this.advancedData = nil
    this.isHandleSpecialPlayWayToggle = true
    this.isHandleSpecialPlayWayAllToggle = true
end

------------------------------------------------------------------
--
function CreateLSPdkRoomPanel.AddListenerEvent()
    AddEventListener(CMD.Game.UpdateCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

--
function CreateLSPdkRoomPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.UpdateCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

--UI相关事件
function CreateLSPdkRoomPanel.AddUIListenerEvent()
    this:AddOnClick(this.createBtn, this.OnCreateBtnClick)
    this:AddOnClick(this.saveBtn, this.OnSaveBtnClick)
    this:AddOnClick(this.deleteBtn, this.OnDeleteBtnClick)
    this:AddOnClick(this.advancedBtn, this.OnAdvancedBtnClick)
    this:AddOnClick(this.modifyBtn, this.OnModifyBtnClick)

    this:AddOnClick(this.configLinePrefabBtn, this.OnSpecialWayBtnClick)
    this:AddOnClick(this.CloseSpecialBtn, this.CloseSpecialBtnCLick)

    local length = #this.playWayMenuItems
    for i = 1, length do
        local playWayMenuItem = this.playWayMenuItems[i]
        UIToggleListener.AddListener(playWayMenuItem.gameObject, this.OnPlayWayMenuValueChanged)
    end
    for i = 1, #this.SpecialPlayWayItems do
        local SpecialPlayWayToggleItem = this.SpecialPlayWayItems[i]
        UIToggleListener.AddListener(SpecialPlayWayToggleItem.gameObject, this.OnSpecialPlayWayToggleChanged)
    end
    UIToggleListener.AddListener(this.SelectAllToggle.gameObject, this.OnSelectAllToggleChanged)
end

------------------------------------------------------------------
--初始外部菜单
function CreateLSPdkRoomPanel.InitExternalMenu(menuToggleDict)
    if menuToggleDict ~= nil and this.externalMenuItems == nil then
        this.externalMenuItems = {}
        local item = menuToggleDict[GameType.PaoDeKuai]
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

------------------------------------------------------------------
--创建
function CreateLSPdkRoomPanel.OnCreateBtnClick()
    if os.time() - this.createClickTime < 3 then
        Toast.Show("请不要频繁操作")
        return
    end
    this.createClickTime = os.time()
    if GameManager.IsCheckGame(GameType.PaoDeKuai) then
        this.HandleCreateRoom()
    end
end

--修改
function CreateLSPdkRoomPanel.OnModifyBtnClick()
    if os.time() - this.createClickTime < 3 then
        Toast.Show("请不要频繁操作")
        return
    end
    this.createClickTime = os.time()
    if GameManager.IsCheckGame(GameType.PaoDeKuai) then
        this.HandleCreateRoom()
    end
end

--创建房间提示处理
function CreateLSPdkRoomPanel.OnCreateAlert()
    this.HandleCreateRoom()
end

--俱乐部和茶馆的保存
function CreateLSPdkRoomPanel.OnSaveBtnClick()
    if this.roomType == RoomType.Club then
        Alert.Prompt("确定保存一键开房配置信息？", this.OnSaveAlert)
    end
end

--保存一键配置提示处理
function CreateLSPdkRoomPanel.OnSaveAlert()
    local ruleDatas = this.GetPlayWayRuleDataAtUI()
    if ruleDatas == nil then
        return
    end
    local playWayType = ruleDatas[PdkRuleType.PlayType]
    local playerTotal = ruleDatas[PdkRuleType.PlayerTotal]
    local gameTotal = ruleDatas[PdkRuleType.JuShu]
    local gps = 0
    --由于俱乐部一键配置需要保存GPS的规则用于默认选择项，故这里不清除
    if this.roomType == RoomType.Club then
        local consumeId = PdkConfig.GetConsumeConfigId(playWayType, gameTotal)
        ClubData.SendSetYjpzRule(GameType.PaoDeKuai, playWayType, ruleDatas, playerTotal, gameTotal, consumeId, gps)
    end
end

--俱乐部的删除
function CreateLSPdkRoomPanel.OnDeleteBtnClick()
    if this.roomType == RoomType.Club then
        Alert.Prompt("确定删除一键开房配置？", this.OnDeleteAlert)
    end
end

--删除配置提示处理
function CreateLSPdkRoomPanel.OnDeleteAlert()
    if this.roomType == RoomType.Club then
        if this.playWayConfigData ~= nil then
            ClubData.SendRemoveYjpzRule(GameType.PaoDeKuai, this.playWayConfigData.playWayType)
        end
    end
end

--高级设置按钮
function CreateLSPdkRoomPanel.OnAdvancedBtnClick()
    --LogError("CreateLSPdkRoomPanel.OnAdvancedBtnClick")
    PanelManager.Open(PanelConfig.CreateRoomAdvanced, this.advancedData, PdkConfig.DiFenConfig, PdkConfig.DiFenNameConfig)
end

--菜单按钮点击
function CreateLSPdkRoomPanel.OnPlayWayMenuValueChanged(isOn, listener)
    --LogError("OnPlayWayMenuValueChanged", isOn)
    if isOn then
        this.SavePlayWayConfigData()
        local dataIndex = tonumber(listener.name)
        local playWayConfigData = PdkConfig.PlayWayConfig[dataIndex]
        if playWayConfigData ~= nil then
            this.playWayConfigData = playWayConfigData
        end
        this.lastPlayWayType = this.playWayConfigData.playWayType
        if not this.isModify then
            this.advancedData = CreateRoomConfig.GetAdvancedData(GameType.PaoDeKuai, this.lastPlayWayType)
        end
        this.UpdatePlayWayConfigDataDisplay()
        --关闭特殊玩法弹出选择界面
        this.CloseSpecialBtnCLick()
    end
end

function CreateLSPdkRoomPanel.OnSpecialWayBtnClick()
    UIUtil.SetActive(this.SpecialPlayWayToggleParent, true)
    UIUtil.SetActive(this.CloseSpecialBtn.gameObject, true)
end

function CreateLSPdkRoomPanel.CloseSpecialBtnCLick()
    UIUtil.SetActive(this.SpecialPlayWayToggleParent, false)
    UIUtil.SetActive(this.CloseSpecialBtn.gameObject, false)
end

function CreateLSPdkRoomPanel.OnSpecialPlayWayToggleChanged(isOn, listener)
    if this.isHandleSpecialPlayWayToggle then
        LogError("CreateLSPdkRoomPanel.OnSpecialPlayWayToggleChanged", isOn)

        this.SpecialPlayWayTable[tonumber(listener.name)].isOn = isOn
        this.configLinePrefabText.text = this.GetSpecialPlayWayLabel()

        --更新全部按钮
        local isAll = true
        for k,v in pairs(this.SpecialPlayWayTable) do
            isAll = isAll and v.isOn
        end
        this.isHandleSpecialPlayWayAllToggle = false
        this.SelectAllToggle.isOn = isAll
        this.isHandleSpecialPlayWayAllToggle = true
    end
end

function CreateLSPdkRoomPanel.OnSelectAllToggleChanged(isOn, listener)
    if this.isHandleSpecialPlayWayAllToggle then
        LogError("CreateLSPdkRoomPanel.OnSelectAllToggleChanged", isOn)
        this.isHandleSpecialPlayWayToggle = false
        local item = nil
        for i = 1, #this.SpecialPlayWayItems do
            item = this.SpecialPlayWayItems[i]
            item.toggle.isOn = isOn
            this.SpecialPlayWayTable[tonumber(item.name)].isOn = isOn
        end
        this.configLinePrefabText.text = this.GetSpecialPlayWayLabel()
        this.isHandleSpecialPlayWayToggle = true
    end
end

--================================================================
--
local tempPlayWayType = PdkPlayType.SCSiRen
local tempPlayerTotal = 4
local tempGameTotal = 10
local tempGps = 0
local tempConsumeId = 0
local tempPayType = PayType.Owner
local tempRuleDatas = nil
local tempBaseScore = 0
local tempInGold = 0
local tempZhuoFei = 0
local tempZhuoFeiMin = 0
local tempJieSanFenShu = 0
local note = nil
local wins = nil
local consts = nil
local baoDi = nil
local bdPer = nil
--处理创建房间
function CreateLSPdkRoomPanel.HandleCreateRoom()
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
        wins = nil
        consts = nil
        baoDi = nil
        bdPer = nil
        if this.advancedData ~= nil then
            tempBaseScore = this.advancedData.diFen or 0
            tempJieSanFenShu = this.advancedData.jieSanFenShu or 0
            tempInGold = this.advancedData.zhunRu or 0
            note = this.advancedData.note
            wins = this.advancedData.wins
            consts = this.advancedData.costs
            baoDi = this.advancedData.baoDi
            bdPer = this.advancedData.bdPer
        end
        --把数据存入到规则中
        tempRuleDatas[PdkRuleType.DiFen] = tempBaseScore
        tempRuleDatas[PdkRuleType.ZhunRu] = tempInGold
        tempRuleDatas[PdkRuleType.JieSanFenShu] = tempJieSanFenShu

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
        if string.IsNullOrEmpty(wins) then
            Toast.Show("请输入大赢家得分区间")
            return
        end
        if string.IsNullOrEmpty(consts) then
            Toast.Show("请输入表情赠送")
            return
        end
    end
    tempPlayWayType = tempRuleDatas[PdkRuleType.PlayType]

    tempPlayerTotal = tempRuleDatas[PdkRuleType.PlayerTotal]
    ---15,16张人数特殊处理
    if tempRuleDatas[PdkRuleType.PlayType] == PdkPlayType.FifteenPDK or tempRuleDatas[PdkRuleType.PlayType] == PdkPlayType.SixteenPDK then
        tempPlayerTotal = tempRuleDatas[PdkRuleType.ST_RS]
    end

    tempGameTotal = tempRuleDatas[PdkRuleType.JuShu]
    tempGps = 0
    tempConsumeId = PdkConfig.GetConsumeConfigId(tempPlayWayType, tempGameTotal)

    LogError("tempRuleDatas", tempRuleDatas)

    tempPayType = tempRuleDatas[PdkRuleType.PayType]

    if this.roomType == RoomType.Lobby then
        BaseTcpApi.SendCreateRoom(GameType.PaoDeKuai, tempRuleDatas, tempPlayerTotal, tempGameTotal, this.roomType, this.moneyType, tempConsumeId, 0, tempPayType, tempGps)
        -- elseif this.roomType == RoomType.Club then
        --     if not IsNil(this.args) then
        --         if not IsNil(this.args.clubCallback) then
        --             local data = Functions.PackGameRule(GameType.PaoDeKuai, tempRuleDatas, tempPlayWayType, tempGameTotal,
        --             tempPlayerTotal, tempConsumeId, tempPayType, tempBaseScore, tempInGold, tempZhuoFei, tempZhuoFeiMin, tempJieSanFenShu)
        --             this.args.clubCallback(this.args.type, data)
        --         end
        --     end
    elseif this.roomType == RoomType.Tea then
        if not IsNil(this.args) then
            if not IsNil(this.args.unionCallback) then
                local data = Functions.PackGameRule(GameType.PaoDeKuai, tempRuleDatas, tempPlayWayType, tempGameTotal,
                        tempPlayerTotal, tempConsumeId, tempPayType, tempBaseScore, tempInGold, tempJieSanFenShu, note, wins, consts, baoDi,nil,nil,nil,bdPer)
                this.args.unionCallback(this.args.type, data)
            end
        end
    end
end

--检测定位
function CreateLSPdkRoomPanel.OnCheckGpsCompleted()
    if GPSModule.gpsEnabled then
        BaseTcpApi.SendCreateRoom(GameType.PaoDeKuai, tempRuleDatas, tempPlayerTotal, tempGameTotal, this.roomType, MoneyType.Fangka, tempConsumeId, 0, tempPayType, tempGps)
    else
        Waiting.Hide()
        if AppGlobal.isOnlyPc then
            PanelManager.Open(PanelConfig.QRCode, "强制定位功能请在手机端上使用")
        else
            Alert.Prompt("请开启GPS定位功能", this.OnGpsAlertCallback)
        end
    end
end

--检测定位提示处理
function CreateLSPdkRoomPanel.OnGpsAlertCallback()
    AppPlatformHelper.OpenDeviceSetting()
end

--检测按钮显示
function CreateLSPdkRoomPanel.CheckButtonDisplay()

end

--================================================================
--
--处理传递参数数据
function CreateLSPdkRoomPanel.CheckArgsData(fromType, moneyType, args)
    --处理打开面板的来源
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

    this.isModify = this.args.rules ~= nil
    this.advancedData = this.args.advanceData

    this.groupId = 0

    if this.roomType == RoomType.Lobby then
        this.lobbyPlayWayData = nil
        this.CheckLobbyPlayWayData()
        this.playWayRuleDatas = this.lobbyPlayWayData.ruleDatas
        this.lastPlayWayType = this.lobbyPlayWayData.lastPlayWayType
    elseif this.roomType == RoomType.Tea then
        this.lobbyPlayWayData = nil
        this.playWayRuleDatas = {}
        if this.isModify then
            --表示修改
            this.lastPlayWayType = PdkConfig.GetPlaywayTypeByName(this.args.playWayName)
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
            --获取麻将的规则
            local temp = args[GameType.PaoDeKuai]
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

--更新配置数据，俱乐部的配置数据更新
function CreateLSPdkRoomPanel.CheckAndUpdateConfigData()
    --先清除当前存储的配置数据
    this.playWayConfigData = nil

    local length = 0
    --临时选中的玩法配置数据
    local tempSelectedPlayWayConfigData = nil
    local playWayConfigData = nil
    local playWayRuleData = nil
    local playWayMenuItem = nil

    --第一个显示的玩法数据，用于没有玩法的时候使用
    local fristPlayWayConfigData = nil
    --第一个配置了的玩法数据
    local fristConfigedPlayWayConfigData = nil
    --是否是配置数据，俱乐部的一键开房
    local isConfigData = false
    --临时变量
    local isShowPlayWayMneu = false

    -- if this.roomType ~= RoomType.Lobby and this.moneyType ~= CreateRoomFuncType.Normal then
    --     isConfigData = true
    -- end
    local playWayMenuItems = this.playWayMenuItems
    if this.externalMenuItems ~= nil then
        playWayMenuItems = this.externalMenuItems
    end

    local menus = LobbyMenus
    if this.roomType == RoomType.Club then
        if this.moneyType == MoneyType.Fangka then
        else
            menus = ClubMenus1
            menus = ClubMenus2
        end
    elseif this.roomType == RoomType.Tea then
        menus = UnionMenus
    else
        menus = LobbyMenus
    end

    --处理修改
    if this.isModify then
        for i = 1, #this.externalMenuItems do
            local item = this.externalMenuItems[i]
            if item ~= nil then
                item.isShow = item.name == this.lastPlayWayName
                UIUtil.SetActive(item.gameObject, item.isShow)
                item.toggle.interactable = false
            end
        end
    else
        --处理菜单的屏蔽
        -- length = #playWayMenuItems
        -- for i = 1, length do
        --     playWayMenuItem = playWayMenuItems[i]
        --     playWayConfigData = PdkConfig.PlayWayConfig[i]
        --     UIUtil.SetActive(playWayMenuItem.gameObject, playWayConfigData ~= nil)
        -- end

        for i = 1, #this.externalMenuItems do
            local item = this.externalMenuItems[i]
            if item ~= nil then
                item.toggle.interactable = true
                if menus[i] == 0 then
                    UIUtil.SetActive(item.gameObject, false)
                    item.isShow = false
                else
                    UIUtil.SetActive(item.gameObject, true)
                    item.isShow = true
                end
            end
        end
    end

    --激活菜单的计数
    local activeMenuCount = 0
    local isItemShow = true
    length = #PdkConfig.PlayWayConfig
    for i = 1, length do
        playWayConfigData = PdkConfig.PlayWayConfig[i]
        --
        playWayRuleData = this.playWayRuleDatas[playWayConfigData.playWayType]
        --
        playWayMenuItem = playWayMenuItems[i]
        if playWayMenuItem ~= nil then
            isItemShow = playWayMenuItem.isShow == true
        else
            isItemShow = false
        end

        --玩法菜单按钮是否显示配置图标
        playWayConfigData.isConfig = playWayRuleData ~= nil and playWayRuleData.isConfig == true and isConfigData
        playWayConfigData.interactable = true

        isShowPlayWayMneu = isItemShow and menus[i] ~= 0
        -- --一键开房，如果没有配置，则需要屏蔽掉菜单按钮，一键开房才有屏蔽所有配置显示项不可点
        -- if this.moneyType == CreateRoomFuncType.OneKey then
        --     isShowPlayWayMneu = playWayConfigData.isConfig
        --     --一键开房是无法修改管理员设置好的数据的
        --     playWayConfigData.interactable = false
        -- end
        UIUtil.SetActive(playWayMenuItem.gameObject, isShowPlayWayMneu)
        --设置为激活
        playWayConfigData.active = isShowPlayWayMneu
        if isShowPlayWayMneu then
            activeMenuCount = activeMenuCount + 1
        end

        --显示配置图标，处理选中项
        if isShowPlayWayMneu then
            if this.lastPlayWayType == playWayConfigData.playWayType then
                tempSelectedPlayWayConfigData = playWayConfigData
            end

            if fristConfigedPlayWayConfigData == nil and playWayConfigData.isConfig then
                fristConfigedPlayWayConfigData = playWayConfigData
            end

            if fristPlayWayConfigData == nil then
                fristPlayWayConfigData = playWayConfigData
            end
        end
    end

    --处理选中的菜单
    if tempSelectedPlayWayConfigData == nil then
        tempSelectedPlayWayConfigData = fristPlayWayConfigData
    end

    playWayMenuItem = nil
    local menuIndex = 0
    --查找玩法配置数据对应的菜单显示项
    for i = 1, length do
        playWayConfigData = PdkConfig.PlayWayConfig[i]
        if playWayConfigData.active == true then
            menuIndex = menuIndex + 1

            if tempSelectedPlayWayConfigData == nil then
                tempSelectedPlayWayConfigData = playWayConfigData
            end
        end

        if tempSelectedPlayWayConfigData ~= nil and tempSelectedPlayWayConfigData.playWayType == playWayConfigData.playWayType then
            playWayMenuItem = playWayMenuItems[i]
            break
        end
    end

    --处理菜单的Scroll，即选中的菜单定位
    if activeMenuCount < 7 then
        UIUtil.SetAnchoredPositionY(this.menuContentTrans, 0)
    else
        if menuIndex < 7 then
            UIUtil.SetAnchoredPositionY(this.menuContentTrans, 0)
        else
            local tempY = 43 + (menuIndex - 7) * 126
            UIUtil.SetAnchoredPositionY(this.menuContentTrans, tempY)
        end
    end

    --设置菜单按钮选中
    if playWayMenuItem ~= nil then
        playWayMenuItem.toggle.isOn = false
        playWayMenuItem.toggle.isOn = true
    else
        this.UpdatePlayWayConfigDataDisplay()
    end
end

--清理显示项相关
function CreateLSPdkRoomPanel.ClearDisplay()
    this.gameTotalItems = {}
    this.toggleGroupItems = ClearObjList(this.toggleGroupItems)
end

--更新配置数据的显示
function CreateLSPdkRoomPanel.UpdatePlayWayConfigDataDisplay()
    this.inited = false
    this.ClearDisplay()

    if this.playWayConfigData == nil then
        return
    end

    this.nameLabel.text = this.playWayConfigData.name

    -- --处理删除按钮状态
    -- if this.moneyType == CreateRoomFuncType.Config then
    --     local temp = this.playWayRuleDatas[this.lastPlayWayType]
    --     local isConfig = temp ~= nil and temp.isConfig == true
    --     if this.roomType == RoomType.Club then
    --         --俱乐部的删除按钮
    --         UIUtil.SetActive(this.deleteBtn, isConfig)
    --     end
    -- end
    --配置了的规则，用于更新显示
    local playWayRuleData = this.playWayRuleDatas[this.playWayConfigData.playWayType]
    if playWayRuleData == nil then
        playWayRuleData = {}
        playWayRuleData.isEmpty = true
    else
        playWayRuleData.isEmpty = false
    end

    --是否显示支付方式类型
    local isDisplayPayment = this.roomType == RoomType.Lobby
    --是否显示底分
    local isDisplayScorement = this.moneyType == MoneyType.Gold

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

        if playWayRuleGroupConfigData.data.type == PdkConfig.RuleGroupConfigType.Pay then
            isDisplayRule = isDisplayPayment
        elseif playWayRuleGroupConfigData.data.type == PdkConfig.RuleGroupConfigType.Score or playWayRuleGroupConfigData.data.type == PdkConfig.RuleGroupConfigType.ZhunRu
                or playWayRuleGroupConfigData.data.type == PdkConfig.RuleGroupConfigType.ZhuoFei or playWayRuleGroupConfigData.data.type == PdkConfig.RuleGroupConfigType.ZhuoFeiMin
                or playWayRuleGroupConfigData.data.type == PdkConfig.RuleGroupConfigType.JieSanFenShu then
            isDisplayRule = isDisplayScorement
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
    UIUtil.SetAnchoredPositionY(this.configContentGO, 0)
    --隐藏未激活的玩法规则项
    for k, v in pairs(this.playWayRuleItems) do
        if not v.isActive then
            UIUtil.SetActive(v.gameObject, false)
        end
    end
    UIUtil.SetAsLastSibling(this.configLine)
    this.inited = true
    --更新钻石消耗
    this.UpdateConsumeDisplay()
    --处理特殊玩法
    this.HandleSpecialPlayWayDisplay()
end

function CreateLSPdkRoomPanel.GetSpecialPlayWayLabel()
    local SpecialPlayWayText = ""
    for i = 1, #this.SpecialPlayWayTable do
        if this.SpecialPlayWayTable[i].isOn then
            SpecialPlayWayText = SpecialPlayWayText .. this.SpecialPlayWayTable[i].name .. "  "
        end
    end
    return SpecialPlayWayText
end

--创建一个规则显示项
function CreateLSPdkRoomPanel.CreatePlayWayRuleItem(ruleGroupIndex, playWayRuleGroupConfigData)
    local item = {}
    item.ruleGroupIndex = ruleGroupIndex
    item.isActive = false
    item.gameObject = CreateGO(this.configItemPrefab, this.configContent, tostring(ruleGroupIndex))
    item.transform = item.gameObject.transform
    item.ruleGroupTrans = item.transform:Find("RuleGroup")
    item.ruleTxt = item.transform:Find("Text"):GetComponent(TypeText)
    item.ruleTxt.text = playWayRuleGroupConfigData.data.name
    item.items = {}
    --里面存放的对象参考创建方法
    return item
end

--设置一个规则显示项数据
function CreateLSPdkRoomPanel.SetPlayWayRuleItem(playWayRuleItem, playWayRuleGroupConfigData, playWayRuleData)
    --规则配置数据
    local ruleConfigData = nil

    local ruleGroups = {}
    local ruleGroup = nil
    --组的名称
    local groupName = nil
    --规则组配置类型
    local ruleGroupConfigType = playWayRuleGroupConfigData.data.type
    --
    --首先对数据进行处理
    if ruleGroupConfigType == PdkConfig.RuleGroupConfigType.GameTotal then
        ruleGroup = {}
        ruleGroup.name = tostring(ruleGroupConfigType)
        table.insert(ruleGroups, ruleGroup)

        for i = 1, #playWayRuleGroupConfigData.rules do
            ruleConfigData = playWayRuleGroupConfigData.rules[i]
            ruleConfigData.order = i
            ruleConfigData.name = tostring(ruleGroupConfigType + i)
            --一局不属于普通场，所以不加入处理
            if ruleConfigData.data.value ~= 1 then
                table.insert(ruleGroup, ruleConfigData)
            end
        end
    else
        --首先分组
        for i = 1, #playWayRuleGroupConfigData.rules do
            ruleConfigData = playWayRuleGroupConfigData.rules[i]
            --动态给数据设置序号，该值很重要，在查找显示对象时需要
            ruleConfigData.order = i
            ruleConfigData.name = tostring(ruleGroupConfigType + i)
            this.HandleRuleGroup(ruleGroups, ruleConfigData, ruleConfigData.data.group)
        end
    end

    local item = nil
    --先重置标记
    for i = 1, #playWayRuleItem.items do
        item = playWayRuleItem.items[i]
        item.isActive = false
    end

    local itemMaxCol = 3
    local cellSize = nil
    local ruleGroupConfigType = nil
    local length = 0
    --计算高度，分组创建
    for i = 1, #ruleGroups do
        ruleGroup = ruleGroups[i]
        --计算需要显示的项
        length = #ruleGroup
        --
        ruleGroupConfigType = playWayRuleGroupConfigData.data.type
        if ruleGroupConfigType == PdkConfig.RuleGroupConfigType.MingTangFen then
            itemMaxCol = 1
            cellSize = CELL_SIZE_1
        else
            itemMaxCol = 3
            cellSize = CELL_SIZE_3
        end

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
        this.SetPlayWayRuleGroupItem(item, ruleGroup, playWayRuleData)
    end

    for i = 1, #playWayRuleItem.items do
        item = playWayRuleItem.items[i]
        if not item.isActive then
            UIUtil.SetActive(item.gameObject, false)
        end
    end
    UIUtil.SetActive(playWayRuleItem.gameObject, true)
end

--处理规则分组
function CreateLSPdkRoomPanel.HandleRuleGroup(ruleGroups, ruleConfigData, groupName)
    groupName = tostring(groupName)
    local ruleGroup = ruleGroups[groupName]
    if ruleGroup == nil then
        ruleGroup = {}
        ruleGroup.name = groupName
        ruleGroups[groupName] = ruleGroup
        table.insert(ruleGroups, ruleGroup)
    end
    table.insert(ruleGroup, ruleConfigData)
end

--创建规则组显示项
function CreateLSPdkRoomPanel.CreatePlayWayRuleGroupItem(index, parent)
    local item = {}
    item.gameObject = CreateGO(this.ruleGroupItemPrefab, parent, tostring(index))
    item.transform = item.gameObject.transform
    item.isActive = false
    item.gridLayoutGroup = item.gameObject:GetComponent("GridLayoutGroup")
    item.singleItems = {}
    --参数参考创建方法
    item.multiItems = {}
    return item
end

--设置规则组数据
function CreateLSPdkRoomPanel.SetPlayWayRuleGroupItem(ruleGroupItem, ruleGroup, playWayRuleData)
    UIUtil.SetActive(ruleGroupItem.gameObject, true)

    local ruleConfigData = nil
    local singleIndex = 0
    local multiIndex = 0
    local item = nil
    --重置标记
    for i = 1, #ruleGroupItem.singleItems do
        ruleGroupItem.singleItems[i].isActive = false
    end

    for i = 1, #ruleGroupItem.multiItems do
        ruleGroupItem.multiItems[i].isActive = false
    end

    for i = 1, #ruleGroup do
        ruleConfigData = ruleGroup[i]

        if ruleConfigData.data.group ~= 0 then
            singleIndex = singleIndex + 1
            item = ruleGroupItem.singleItems[singleIndex]
            if item == nil then
                if ruleConfigData.data.type == PdkRuleType.DiFen and ruleConfigData.data.value == 0 then
                    item = this.CreatePlayWayRuleConfigInputItem(this.inputSingleItemPrefab6, ruleGroupItem.transform, ruleConfigData.name)
                elseif ruleConfigData.data.type == PdkRuleType.ZhunRu and ruleConfigData.data.value == 0 then
                    item = this.CreatePlayWayRuleConfigInputItem(this.inputSingleItemPrefab6, ruleGroupItem.transform, ruleConfigData.name)
                elseif ruleConfigData.data.type == PdkRuleType.ZhuoFei and ruleConfigData.data.value == 0 then
                    item = this.CreatePlayWayRuleConfigInputItem(this.inputSingleItemPrefab6, ruleGroupItem.transform, ruleConfigData.name)
                elseif ruleConfigData.data.type == PdkRuleType.ZhuoFeiMin and ruleConfigData.data.value == 0 then
                    item = this.CreatePlayWayRuleConfigInputItem(this.inputSingleItemPrefab6, ruleGroupItem.transform, ruleConfigData.name)
                elseif ruleConfigData.data.type == PdkRuleType.JieSanFenShu and ruleConfigData.data.value == 0 then
                    item = this.CreatePlayWayRuleConfigInputItem(this.inputSingleItemPrefab6, ruleGroupItem.transform, ruleConfigData.name)
                else
                    item = this.CreatePlayWayRuleConfigItem(this.singleItemPrefab, ruleGroupItem.transform, ruleConfigData.name)
                end
                ruleGroupItem.singleItems[singleIndex] = item
            else
                item.gameObject.name = ruleConfigData.name
            end
        else
            multiIndex = multiIndex + 1
            item = ruleGroupItem.multiItems[multiIndex]
            if item == nil then
                item = this.CreatePlayWayRuleConfigItem(this.multiItemPrefab, ruleGroupItem.transform, ruleConfigData.name)
                ruleGroupItem.multiItems[multiIndex] = item
            else
                item.gameObject.name = ruleConfigData.name
            end
        end
        if ruleConfigData.data.type == PdkRuleType.JuShu and this.moneyType == MoneyType.Fangka and ruleConfigData.data.value == -1 then
            item.isActive = false
        else
            item.isActive = true
        end
        this.SetPlayWayRuleConfigItem(item, ruleConfigData, playWayRuleData)
        UIUtil.SetAsLastSibling(item.transform)
    end

    --隐藏多余的显示项
    for i = 1, #ruleGroupItem.singleItems do
        item = ruleGroupItem.singleItems[i]
        if not item.isActive then
            item.toggle.isOn = false
            UIUtil.SetActive(item.gameObject, false)
        end
    end
    for i = 1, #ruleGroupItem.multiItems do
        item = ruleGroupItem.multiItems[i]
        if not item.isActive then
            item.toggle.isOn = false
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

--获取ToggleGroup组件
function CreateLSPdkRoomPanel.GetToggleGroupItem(type, group)
    local toggleGroupItemName = type .. "_" .. group
    local toggleGroupItem = this.toggleGroupItems[toggleGroupItemName]
    if toggleGroupItem == nil then
        toggleGroupItem = CreateGO(this.toggleGroupItemPrefab, this.toggleGroups, toggleGroupItemName)
        this.toggleGroupItems[toggleGroupItemName] = toggleGroupItem
    end
    return toggleGroupItem
end

--创建具体的一个规则
function CreateLSPdkRoomPanel.CreatePlayWayRuleConfigItem(prefab, parent, order)
    local item = {}
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
    item.data = nil
    return item
end

--创建可输入的规则Item
function CreateLSPdkRoomPanel.CreatePlayWayRuleConfigInputItem(prefab, parent, order)
    local item = {}
    --用于标识是否激活
    item.isActive = false
    --用于事件
    item.inited = false
    --时候可以交互
    item.interactable = false
    item.gameObject = CreateGO(prefab, parent, tostring(order))
    item.transform = item.gameObject.transform
    item.label = item.transform:Find("Label"):GetComponent(TypeText)
    item.inputField = item.transform:Find("Label/InputField"):GetComponent("InputField")
    local background = item.transform:Find("Background")
    item.grayBg = background:Find("GrayBg").gameObject
    item.grayMask = background:Find("GrayMask").gameObject
    item.toggle = item.gameObject:GetComponent(TypeToggle)
    item.data = nil
    return item
end

--
local tempGroup = nil
local tempType = 0
local tempToggle = nil
local tempSelected = nil
local tempInteractable = true

--设置具体规则数据
function CreateLSPdkRoomPanel.SetPlayWayRuleConfigItem(ruleConfigItem, ruleConfigData, playWayRuleData)
    --存储数据，用于获取
    ruleConfigItem.data = ruleConfigData

    --设置显示
    UIUtil.SetActive(ruleConfigItem.gameObject, true)

    tempGroup = ruleConfigData.data.group
    tempType = ruleConfigData.data.type
    tempToggle = ruleConfigItem.toggle
    tempSelected = nil
    tempInteractable = true
    if tempType == PdkRuleType.JuShu then
        --选中局数，处理钻石消耗显示
        if not ruleConfigItem.inited then
            UIToggleListener.AddListener(ruleConfigItem.gameObject, this.OnConsumeCardsChanged)
        end
        table.insert(this.gameTotalItems, ruleConfigItem)
    else
        if not ruleConfigItem.inited then
            UIToggleListener.AddListener(ruleConfigItem.gameObject, this.OnToggleValueChanged)
        end
    end

    ruleConfigItem.inited = true
    if tempGroup ~= 0 then
        local toggleGroupItem = this.GetToggleGroupItem(tempType, tempGroup)
        if toggleGroupItem ~= nil then
            local toggleGroup = toggleGroupItem:GetComponent("ToggleGroup")
            tempToggle.group = toggleGroup
        end
    else
        tempToggle.group = nil
    end

    --主要是针对俱乐部一键开房时可以由玩家选择
    tempInteractable = tempInteractable and this.playWayConfigData.interactable and ruleConfigData.interactable

    ruleConfigItem.interactable = tempInteractable
    tempToggle.interactable = tempInteractable

    --处理缓存配置选中
    if tempSelected == nil then
        if playWayRuleData.isEmpty then
            tempSelected = ruleConfigData.selected
        else
            if ruleConfigData.data.type == PdkRuleType.MT then
                --名堂特殊处理
                tempSelected = this.GetMingTangSelected(playWayRuleData[ruleConfigData.data.type], ruleConfigData.data.value)
            else
                local cacheRuleValue = playWayRuleData[ruleConfigData.data.type]
                if cacheRuleValue ~= nil then
                    tempSelected = cacheRuleValue == ruleConfigData.data.value
                else
                    tempSelected = false
                end
            end
        end
    end

    tempToggle.isOn = tempSelected

    --文本显示
    local nameStr = ruleConfigData.data.name
    --特殊显示处理
    if ruleConfigData.data.desc ~= nil then
        nameStr = ruleConfigData.data.desc
    end
    ruleConfigItem.label.text = nameStr

    this.UpdateToggleStatus(ruleConfigItem, tempSelected)
end

--获取名堂选项
function CreateLSPdkRoomPanel.GetMingTangSelected(list, value)
    if IsTable(list) then
        for i = 1, #list do
            if list[i] == value then
                return true
            end
        end
    end
    return false
end

--处理Toggle选项的状态，比如选中、禁用等颜色
function CreateLSPdkRoomPanel.UpdateToggleStatus(ruleConfigItem, isOn)
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
        UIUtil.SetActive(ruleConfigItem.grayBg, false)
        UIUtil.SetActive(ruleConfigItem.grayMask, false)
    else
        ruleConfigItem.label.color = CreateRoomConfig.COLOR_FORBIDDEN
        UIUtil.SetActive(ruleConfigItem.grayBg, true)
        UIUtil.SetActive(ruleConfigItem.grayMask, isOn)
    end
    -- Log('===ruleConfigItem====',ruleConfigItem)
end

--处理Toggle选项的选择状态
function CreateLSPdkRoomPanel.UpdateToggleSelectedStatus(toggle)
    local label = toggle.transform:Find("Label"):GetComponent(TypeText)
    if toggle.isOn then
        label.color = CreateRoomConfig.COLOR_SELECTED
    else
        label.color = CreateRoomConfig.COLOR_NORMAL
    end
end

--处理选项值改变
function CreateLSPdkRoomPanel.HandleToggleValueChanged(go)
    local toggle = go:GetComponent(TypeToggle)
    if toggle ~= nil then
        this.UpdateToggleSelectedStatus(toggle)
    end
end


--选项值改变
function CreateLSPdkRoomPanel.OnToggleValueChanged(isOn, listener)
    if not this.inited then
        return
    end
    this.HandleToggleValueChanged(listener.gameObject)
end

--局数选择
function CreateLSPdkRoomPanel.OnConsumeCardsChanged(isOn, listener)
    if not this.inited then
        return
    end
    this.HandleToggleValueChanged(listener.gameObject)
    this.UpdateConsumeDisplay()
end



--更新钻石消耗显示
function CreateLSPdkRoomPanel.UpdateConsumeDisplay()
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
                SendEvent(CMD.Game.UpdateCreateRoomConsume, cards)
            end
            break
        end
    end
end

--================================================================
--
--检测大厅的玩法缓存数据
function CreateLSPdkRoomPanel.CheckLobbyPlayWayData()
    if this.lobbyPlayWayData == nil then
        this.lobbyPlayWayData = {}
        this.lobbyPlayWayData.ruleDatas = {}

        local temp = nil
        local str = GetLocal(LocalDatas.PdkPlayWayData, nil)
        if str ~= nil then
            temp = JsonToObj(str)
        end

        if temp ~= nil then
            this.lobbyPlayWayData.lastPlayWayType = temp.lastPlayWayType
            if this.lobbyPlayWayData.lastPlayWayType == nil then
                this.lobbyPlayWayData.lastPlayWayType = PdkPlayType.SCSiRen
            end

            if temp.ruleDatas ~= nil then
                local length = #temp.ruleDatas
                local playWayType = nil
                local ruleData = nil
                for i = 1, length do
                    ruleData = temp.ruleDatas[i]
                    if IsTable(ruleData) then
                        ruleData.isConfig = false
                        playWayType = ruleData[PdkRuleType.PlayType]
                        if playWayType ~= nil then
                            this.lobbyPlayWayData.ruleDatas[playWayType] = ruleData
                        end
                    end
                end
            end
        end
    end
end

--保存到本地存储中
function CreateLSPdkRoomPanel.SaveLobbyPlayWayConfigData()
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
        SetLocal(LocalDatas.PdkPlayWayData, str)
    end
end

--保存配置数据
function CreateLSPdkRoomPanel.SavePlayWayConfigData()
    if this.playWayConfigData == nil then
        return nil
    end
    if this.roomType == RoomType.Lobby or this.roomType == RoomType.Club then
        local playWayRuleData = this.GetPlayWayRuleDataAtUI()

        local temp = this.playWayRuleDatas[this.playWayConfigData.playWayType]
        if temp ~= nil and temp.isConfig == true then
            --有配置属性的认为是俱乐部已经配置的，不进行保存
        else
            this.playWayRuleDatas[this.playWayConfigData.playWayType] = playWayRuleData
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

--获取当前选择的UI上显示的玩法规则字符串
function CreateLSPdkRoomPanel.GetPlayWayRuleDataAtUI()
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

    --玩法类型
    playWayRuleData[PdkRuleType.PlayType] = this.playWayConfigData.playWayType
    --人数字段
    playWayRuleData[PdkRuleType.PlayerTotal] = this.playWayConfigData.playerTotal


    --房间类型
    playWayRuleData[PdkRuleType.RoomType] = this.roomType

    --默认规则配置
    local ruleConfigData = nil
    if this.playWayConfigData.defaultRuleGroups ~= nil then
        for i = 1, #this.playWayConfigData.defaultRuleGroups do
            ruleConfigData = this.playWayConfigData.defaultRuleGroups[i]
            playWayRuleData[ruleConfigData.type] = ruleConfigData.value
        end
    end

    --支付方式，俱乐部固定传3
    if playWayRuleData[PdkRuleType.PlayType] == nil then
        if this.roomType == RoomType.Club or this.roomType == RoomType.Tea then
            playWayRuleData[PdkRuleType.PlayType] = 3
        end
    end

    LogError("playWayRuleData", playWayRuleData)

    playWayRuleData = this.GetSixteenExtraPlayWay(playWayRuleData)

    LogError(">> CreateLSPdkRoomPanel.GetPlayWayRuleDataAtUI > ", playWayRuleData)
    return playWayRuleData
end

function CreateLSPdkRoomPanel.GetSixteenExtraPlayWay(playWayRuleData)
    if this.playWayConfigData.playWayType == PdkPlayType.SixteenPDK or this.playWayConfigData.playWayType == PdkPlayType.FifteenPDK then
        playWayRuleData = this.SetSixteenPeopleCount(playWayRuleData)
        playWayRuleData = this.SetSixteenFirstOut(playWayRuleData)
        playWayRuleData = this.SetSpecialPlayWay(playWayRuleData)
        if this.playWayConfigData.playWayType == PdkPlayType.FifteenPDK then
            playWayRuleData[PdkRuleType.ST_WF] = 1
        elseif this.playWayConfigData.playWayType == PdkPlayType.SixteenPDK then
            playWayRuleData[PdkRuleType.ST_WF] = 0
        end
        return playWayRuleData
    end
    return playWayRuleData
end

function CreateLSPdkRoomPanel.SetSixteenPeopleCount(playWayRuleData)
    local selectedPeopleCountData = {}
    --LogError("this.playWayConfigData", this.playWayConfigData)
    --LogError("this.playWayConfigData.ruleGroups[2].rules", this.playWayConfigData.ruleGroups[2].rules)
    for _, v in pairs(this.playWayConfigData.ruleGroups[2].rules) do
        if v.selected then
            selectedPeopleCountData = v.data
        end
    end
    LogError("selectedPeopleCountData", selectedPeopleCountData)
    playWayRuleData[PdkRuleType.PlayerTotal] = selectedPeopleCountData.value
    return playWayRuleData
end

---15张16张的先出规则
function CreateLSPdkRoomPanel.SetSixteenFirstOut(playWayRuleData)
    local selectedData = {}
    for _, v in pairs(this.playWayConfigData.ruleGroups[3].rules) do
        if v.selected then
            selectedData = v.data
        end
    end
    playWayRuleData[PdkRuleType.ST_XC] = selectedData.value
    return playWayRuleData
end

---15张16张的特殊玩法
function CreateLSPdkRoomPanel.SetSpecialPlayWay(playWayRuleData)
    for _, v in pairs(this.SpecialPlayWayTable) do
        playWayRuleData[v.key] = v.isOn and 1 or 0
    end
    return playWayRuleData
end


--检测规则组显示对象
function CreateLSPdkRoomPanel.CheckRuleGroupItem(ruleGroupItem, playWayRuleData, includeRules)
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
    end
end

--获取规则的数据对象，用于服务器交互
function CreateLSPdkRoomPanel.CheckAndSetRuleData(playWayRuleData, ruleConfigData, selected, inputValue)
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
        if PdkRuleType.MT == ruleConfigData.data.type then
            --名堂特殊处理
            local list = playWayRuleData[ruleConfigData.data.type]
            if list == nil then
                list = {}
                playWayRuleData[ruleConfigData.data.type] = list
            end
            if selected then
                table.insert(list, ruleConfigData.data.value)
            end
        else
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
end

--更新创建房间高级设置
function CreateLSPdkRoomPanel.OnUpdateCreateRoomAdvanced(data)
    this.advancedData = data
    CreateRoomConfig.SaveAdvancedData(GameType.PaoDeKuai, this.lastPlayWayType, data)
end

--处理特殊玩法显示
function CreateLSPdkRoomPanel.HandleSpecialPlayWayDisplay()
    local playWayRuleData = nil
    if this.playWayRuleDatas ~= nil and this.playWayConfigData ~= nil then
        playWayRuleData = this.playWayRuleDatas[this.playWayConfigData.playWayType]
    end
    
    if playWayRuleData ~= nil then
        local specialPlayWayData = nil
        local isOn = false
        for i = 1, #this.SpecialPlayWayTable do
            specialPlayWayData = this.SpecialPlayWayTable[i]
            isOn = playWayRuleData[specialPlayWayData.key] == 1
            specialPlayWayData.isOn = isOn
        end
    end

    this.isHandleSpecialPlayWayToggle = false
    this.isHandleSpecialPlayWayAllToggle = false
    local item = nil
    local isAll = true
    for k,v in pairs(this.SpecialPlayWayTable) do
        item = this.SpecialPlayWayItems[k]
        if item ~= nil then
            isAll = isAll and v.isOn
            item.toggle.isOn = v.isOn
        end
    end
    this.SelectAllToggle.isOn = isAll
    this.configLinePrefabText.text = this.GetSpecialPlayWayLabel()
    this.isHandleSpecialPlayWayToggle = true
    this.isHandleSpecialPlayWayAllToggle = true
end