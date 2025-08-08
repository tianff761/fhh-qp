CreateSDBRoomPanel = ClassLuaComponent("CreateSDBRoomPanel")
CreateSDBRoomPanel.Instance = nil

--显示项的高度
local ITEM_HEIGHT = 76
--
local CELL_SIZE_3 = Vector2(270, 76)
--
local CELL_SIZE_4 = Vector2(180, 76)
local DES_HEIGHT = 492
local CELL_SIZE_1 = Vector2(795, 492)

local this = CreateSDBRoomPanel

function CreateSDBRoomPanel:Init()
    --大厅玩法数据
    this.lobbyPlayWayData = nil
    --是否初始化了，用途是防止在创建规则项时处理事件，复选框等都需要手动初始化
    this.inited = false
    --打开面板的来源
    this.roomType = RoomType.Lobby
    --创建房间的功能类型
    this.funcType = CreateRoomFuncType.Normal
    --组织ID，即亲友圈或者茶馆
    this.groupId = 0
    --上次保存的玩法类型，用于查找定位当前的玩法配置数据
    this.lastPlayWayType = nil
    --当前的玩法配置数据，配置表中的
    this.playWayConfigData = nil
    --
    --玩法规则项，用玩法key保存的对象，对象内部参数请参考生成方法
    this.playWayRuleItems = {}
    --
    --玩法规则数据，普通创建即NormalPlayWayRuleData，其他的就是传递过来的参数
    this.playWayRuleDatas = nil
    --
    --ToggleGroup组件集合
    this.toggleGroupItems = {}
    --手动开始
    this.handStartItem = nil
    --满6人开
    this.fullSixStartItem = nil
    --满4人开
    this.fullFourStartItem = nil
    --是否选中4人
    this.isSlect4Ren = false


    --
    --其他参数存储
    this.otherArgs = {}
    --创建点击时间
    this.createClickTime = 0
    --当前高级设置数据
    this.advancedData = nil
end

--UI初始化
function CreateSDBRoomPanel:Awake()
    this = self
    self:Init()
    -----------------------------------------------------------------------
    --玩法菜单按钮
    local menuTrans = self:Find("Content/Menu")
    this.menu = menuTrans.gameObject
    this.menuContentTrans = menuTrans:Find("ScrollView/Viewport/Content")

    this.playWayMenuItems = {}
    for i = 1, 4 do
        local playWayMenuItemTrans = this.menuContentTrans:Find(tostring(i))
        local playWayMenuItem = {}
        this.playWayMenuItems[i] = playWayMenuItem

        playWayMenuItem.gameObject = playWayMenuItemTrans.gameObject
        playWayMenuItem.toggle = playWayMenuItemTrans:GetComponent("Toggle")
    end

    --玩法配置
    --按钮
    local configTrans = self:Find("Content/Config")
    local bottomTrans = configTrans:Find("Bottom")
    this.tips = bottomTrans:Find("Tips").gameObject
    local buttonTrans = bottomTrans:Find("Button")
    this.createBtn = buttonTrans:Find("CreateBtn").gameObject
    this.advancedBtn = buttonTrans:Find("AdvancedButton").gameObject
    this.saveBtn = buttonTrans:Find("SaveButton").gameObject
    this.deleteBtn = buttonTrans:Find("DeleteButton").gameObject

    --玩法选项
    local configScorllViewTrans = configTrans:Find("ScrollView")
    this.configScorllViewGO = configScorllViewTrans.gameObject
    this.configScorllView = configScorllViewTrans:GetComponent("ScrollRect")
    this.configContent = configScorllViewTrans:Find("Content")
    this.configContentGO = this.configContent.gameObject
    --每一个配置项
    this.configItemPrefab = this.configContent:Find("Item").gameObject

    --3个选项Item
    this.ruleGroupItemPrefab = configTrans:Find("RuleGroupItem").gameObject
    --单选项
    this.singleItemPrefab = configTrans:Find("SingleItem").gameObject
    --多选项
    this.multiItemPrefab = configTrans:Find("MultiItem").gameObject
    this.toggleGroups = configTrans:Find("ToggleGroups")
    this.toggleGroupItemPrefab = this.toggleGroups:Find("ToggleGroupItem").gameObject
    --文本框
    this.desTextItemPrefab = configTrans:Find("DesTextItem").gameObject

    this.AddUIListenerEvent()

    -----------------------------------
    this.scrollRect = menuTrans:Find("ScrollView"):GetComponent(TypeScrollRect)
    this.scrollRectContent = this.scrollRect.content
    -----------------------------------
end

--当面板开启开启时
function CreateSDBRoomPanel:OnOpened(fromType, funcType, args)
    CreateSDBRoomPanel.Instance = self

    local v3 = this.scrollRectContent.localPosition
    this.scrollRectContent.localPosition = Vector2(v3.x, 0)

    this.AddListenerEvent()

    this.CheckArgsData(fromType, funcType, args)
    this.InitExternalMenu(args.menuToggleDict)--menuToggleDict
    this.CheckButtonDisplay()
    this.CheckAndUpdateConfigData()

    --if not IsNull(args.menuHelper) then
    --    args.menuHelper:RefreshTogglesItem()
    --    args.menuHelper:CheckIsOnToggle()
    --end

end

--当面板关闭时调用
function CreateSDBRoomPanel:OnClosed()
    CreateSDBRoomPanel.Instance = nil
    this.RemoveListenerEvent()
    --关闭的时候保存下配置
    this.SavePlayWayConfigData()
    --清除玩法类型
    this.lastPlayWayType = nil
end

------------------------------------------------------------------
--
function CreateSDBRoomPanel.AddListenerEvent()
    AddEventListener(CMD.Game.UpdateNewCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

--
function CreateSDBRoomPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.UpdateNewCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

--UI相关事件
function CreateSDBRoomPanel.AddUIListenerEvent()
    this:AddOnClick(this.createBtn, this.OnCreateBtnClick)
    this:AddOnClick(this.saveBtn, this.OnSaveBtnClick)
    this:AddOnClick(this.deleteBtn, this.OnDeleteBtnClick)
    this:AddOnClick(this.advancedBtn, this.OnAdvancedBtnClick)
    --local length = #this.playWayMenuItems
    for i = 1, #this.playWayMenuItems do
        UIToggleListener.AddListener(this.playWayMenuItems[i].gameObject, this.OnPlayWayMenuValueChanged)
    end
end

--更新创建房间高级设置
function CreateSDBRoomPanel.OnUpdateCreateRoomAdvanced(data)
    this.advancedData = data
    LogError('this.advancedData', this.advancedData)
    CreateRoomConfig.SaveAdvancedData(GameType.SDB, this.lastPlayWayType, data)
end

------------------------------------------------------------------
--初始外部菜单
function CreateSDBRoomPanel.InitExternalMenu(listToggles)
    if listToggles ~= nil and this.externalMenuItems == nil then
        this.externalMenuItems = {}
        local item = listToggles[GameType.SDB]
        --if trans ~= nil then
        --    for i = 1, 4 do
        --        local playWayMenuItemTrans = trans:Find(tostring(i))
        --
        --        local item = {}
        --        item.gameObject = playWayMenuItemTrans.gameObject
        --        item.toggle = playWayMenuItemTrans:GetComponent("Toggle")
        --        item.configTag = playWayMenuItemTrans:Find("ConfigTag").gameObject
        --
        --        this.externalMenuItems[i] = item
        --
        --        UIToggleListener.AddListener(item.gameObject, this.OnPlayWayMenuValueChanged)
        --    end
        --end
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
function CreateSDBRoomPanel.OnCreateBtnClick()
    if os.time() - this.createClickTime < 3 then
        Toast.Show("请不要频繁操作")
        return
    end
    this.createClickTime = os.time()
    if GameManager.IsCheckGame(GameType.SDB) then
        if this.roomType == RoomType.Club then
            Alert.Prompt("确定创建亲友圈房间？", this.OnCreateAlert)
        else
            this.HandleCreateRoom()
        end
    end
end

--创建房间提示处理
function CreateSDBRoomPanel.OnCreateAlert()
    this.HandleCreateRoom()
end

--高级设置按钮
function CreateSDBRoomPanel.OnAdvancedBtnClick()
    PanelManager.Open(PanelConfig.CreateRoomAdvanced, this.advancedData, SDB.DiFenConfig, SDB.DiFenNameConfig, GameType.SDB)
end

--亲友圈和茶馆的保存
function CreateSDBRoomPanel.OnSaveBtnClick()
    if this.roomType == RoomType.Club then
        Alert.Prompt("确定保存一键开房配置信息？", this.OnSaveAlert)
    end
end

--保存一键配置提示处理
function CreateSDBRoomPanel.OnSaveAlert()
    local ruleDatas = this.GetPlayWayRuleDataAtUI()
    if ruleDatas == nil then
        return
    end
    ruleDatas[SDB.RuleType.HighOption] = { [SDB.RuleType.CanJoin] = ruleDatas[SDB.RuleType.CanJoin], [SDB.RuleType.ZhuangFanBei] = ruleDatas[SDB.RuleType.ZhuangFanBei],
                                           [SDB.RuleType.PingDianZhuangWin] = ruleDatas[SDB.RuleType.PingDianZhuangWin], [SDB.RuleType.XiaZhuLimit] = ruleDatas[SDB.RuleType.XiaZhuLimit], [SDB.RuleType.CanCuoPai] = 1 }
    local playWayType = ruleDatas[SDB.RuleType.PlayWayType]
    local playerTotal = ruleDatas[SDB.RuleType.PlayerTotal]
    local gameTotal = ruleDatas[SDB.RuleType.GameTotal]
    local gps = ruleDatas[SDB.RuleType.Gps]
    --由于亲友圈一键配置需要保存GPS的规则用于默认选择项，故这里不清除
    if this.roomType == RoomType.Club then
        local consumeId = SDB.GetConsumeConfigId(playerTotal, gameTotal)
        local tempRenShu = SDB.PopulationConfig[playerTotal]
        ClubData.SendSetYjpzRule(GameType.SDB, playWayType, ruleDatas, tempRenShu, SDB.GameTotalConfig[gameTotal], consumeId, gps)
    end
end

--亲友圈的删除
function CreateSDBRoomPanel.OnDeleteBtnClick()
    if this.roomType == RoomType.Club then
        Alert.Prompt("确定删除一键开房配置？", this.OnDeleteAlert)
    end
end

--删除配置提示处理
function CreateSDBRoomPanel.OnDeleteAlert()
    if this.roomType == RoomType.Club then
        if this.playWayConfigData ~= nil then
            ClubData.SendRemoveYjpzRule(GameType.SDB, this.playWayConfigData.playWayType)
        end
    end
end

--菜单按钮点击
function CreateSDBRoomPanel.OnPlayWayMenuValueChanged(isOn, listener)
    if isOn then
        this.SavePlayWayConfigData()
        local dataIndex = tonumber(listener.name)
        local playWayConfigData = SDB.CreateRoomConfig[dataIndex]
        if playWayConfigData ~= nil then
            this.playWayConfigData = playWayConfigData
        end
        this.lastPlayWayType = this.playWayConfigData.playWayType
        this.UpdatePlayWayConfigDataDisplay()
    end
end

--================================================================
--
local tempPlayWayType = SDB.PlayWayType.TakeRunBanker
local tempPlayerTotal = 4
local tempGameTotal = 15
local tempGps = 0
local tempConsumeId = 0
local tempPayType = PayType.Owner
local tempRuleDatas = nil
local tempCanJoin = 0
local tempZhuangFanBei = 0
local tempZhuangWin = 0
local tempXiaZhuLimit = 0
local tempRenShu = 0
local tempBaseScore = 1
local tempInGold = 0
local tempJieSanFenShu = 0
local note = nil
local wins = nil
local consts = nil

--处理创建房间
function CreateSDBRoomPanel.HandleCreateRoom()
    tempRuleDatas = nil

    --只有大厅创建房间才进行规则存储
    if this.roomType == RoomType.Lobby then
        tempRuleDatas = this.SavePlayWayConfigData()
    end

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
        LogError('this.advancedData', this.advancedData)
        if this.advancedData ~= nil then
            tempBaseScore = this.advancedData.diFen or 0
            tempJieSanFenShu = this.advancedData.kickNum or 0
            tempInGold = this.advancedData.enterNum or 0
            note = this.advancedData.remarkStr
            wins = this.advancedData.wins
            consts = this.advancedData.costs
        end

        if not this.advancedData then
            Toast.Show("请输入高级设置")
            return
        end

        --LogError("tempRuleDatas", tempBaseScore)
        --把数据存入到规则中
        tempRuleDatas[SDB.RuleType.TeaScore] = tempBaseScore
        --tempRuleDatas[SDB.RuleType.Bet] = tempBaseScore
        tempRuleDatas[SDB.RuleType.EnterLimit] = tempInGold
        tempRuleDatas[SDB.RuleType.KickLimit] = tempJieSanFenShu

        if not IsNumber(tempBaseScore) or tempBaseScore < 0 then
            Toast.Show("请输入正确的底分")
            return
        end
        if not IsNumber(tempInGold) then
            Toast.Show("请输入正确的准入分数")
            return
        end
        --LogError("tempInGold", type(tempInGold))
        --LogError("tempBaseScore", type(tempBaseScore))
        --LogError("tempInGold", tempInGold)
        --LogError("tempBaseScore", tempBaseScore)
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
    LogError("临时规则数据", tempRuleDatas)
    tempPlayWayType = tempRuleDatas[SDB.RuleType.PlayWayType]
    tempPlayerTotal = tempRuleDatas[SDB.RuleType.PlayerTotal]
    tempGameTotal = tempRuleDatas[SDB.RuleType.GameTotal]
    tempGps = tempRuleDatas[SDB.RuleType.Gps]

    tempCanJoin = tempRuleDatas[SDB.RuleType.CanJoin]
    tempZhuangFanBei = tempRuleDatas[SDB.RuleType.ZhuangFanBei]
    tempZhuangWin = tempRuleDatas[SDB.RuleType.PingDianZhuangWin]
    tempXiaZhuLimit = tempRuleDatas[SDB.RuleType.XiaZhuLimit]
    tempRuleDatas[SDB.RuleType.HighOption] = { [SDB.RuleType.CanJoin] = tempCanJoin, [SDB.RuleType.ZhuangFanBei] = tempZhuangFanBei,
                                               [SDB.RuleType.PingDianZhuangWin] = tempZhuangWin, [SDB.RuleType.XiaZhuLimit] = tempXiaZhuLimit, [SDB.RuleType.CanCuoPai] = 1 }
    tempConsumeId = SDB.GetConsumeConfigId(tempPlayerTotal, tempGameTotal)
    tempRenShu = SDB.PopulationConfig[tempPlayerTotal]

    if this.roomType == RoomType.Club then
        local temp = this.otherArgs[tempPlayWayType]
        local key = nil
        if temp ~= nil then
            key = temp.key
        end
        if key == nil then
            key = ""
        end
        local createType = 0
        if this.funcType == CreateRoomFuncType.OneKey then
            createType = 1
        end
        ClubData.SendCreateClubRoom(GameType.SDB, tempPlayWayType, key, tempRuleDatas, tempRenShu, SDB.GameTotalConfig[tempGameTotal], tempConsumeId, createType, tempGps)
    elseif this.roomType == RoomType.Tea then
        LogError("this.args.unionCallback", this.args.unionCallback)
        if not IsNil(this.args) then
            if not IsNil(this.args.unionCallback) then
                local data = Functions.PackGameRule(GameType.SDB, tempRuleDatas, tempPlayWayType, tempGameTotal,
                        tempPlayerTotal, tempConsumeId, tempPayType, tempBaseScore, tempInGold, tempJieSanFenShu, note, "", "", this.advancedData.keepBaseNum or 0, 2, this.advancedData.allToggle and 0 or 1, this.advancedData.expressionNum or 0, this.advancedData.bdPer)
                LogError("this.args.unionCallback", this.args.unionCallback)
                this.args.unionCallback(this.args.type, data)
            end
        end
    else
        local payType = tempRuleDatas[SDB.RuleType.Pay]
        if payType == 1 then
            tempPayType = PayType.Owner
        elseif payType == 2 then
            tempPayType = PayType.AA
        else
            tempPayType = PayType.Winner
        end
        if tempGps ~= nil and tempGps == GpsType.Force then
            if AppGlobal.isOnlyPc then
                PanelManager.Open(PanelConfig.QRCode, "强制定位功能请在手机端上使用")
            else
                Waiting.Show("检测GPS定位功能中...")
                GPSModule.CheckGpsEnabled(this.OnCheckGpsCompleted)
            end
        else
            --大厅创建房间组织ID为0
            BaseTcpApi.SendCreateRoom(GameType.SDB, tempRuleDatas, tempRenShu, SDB.GameTotalConfig[tempGameTotal], this.roomType, MoneyType.Fangka, tempConsumeId, 0, tempPayType, tempGps)
        end
    end
end

--检测定位
function CreateSDBRoomPanel.OnCheckGpsCompleted()
    if GPSModule.gpsEnabled then
        BaseTcpApi.SendCreateRoom(GameType.SDB, tempRuleDatas, tempRenShu, tempGameTotal, this.roomType, MoneyType.Fangka, tempConsumeId, 0, tempPayType, tempGps)
    else
        Waiting.Hide()
        Alert.Prompt("请开启GPS定位功能", this.OnGpsAlertCallback)
    end
end

--检测定位提示处理
function CreateSDBRoomPanel.OnGpsAlertCallback()
    AppPlatformHelper.OpenDeviceSetting()
end

--检测按钮显示
function CreateSDBRoomPanel.CheckButtonDisplay()
    local isConfig = this.funcType == CreateRoomFuncType.Config
    UIUtil.SetActive(this.createBtn, true)
    --UIUtil.SetActive(this.saveBtn, isConfig)
    --UIUtil.SetActive(this.deleteBtn, isConfig)
    UIUtil.SetActive(this.advancedBtn, this.moneyType == MoneyType.Gold)
    UIUtil.SetActive(this.tips, this.roomType == RoomType.Lobby)
end

--================================================================
--
--处理传递参数数据
function CreateSDBRoomPanel.CheckArgsData(fromType, funcType, args)
    --处理打开面板的来源
    local tempfromType = fromType
    local tempfuncType = funcType
    this.moneyType = funcType
    if this.roomType ~= tempfromType then
        this.roomType = tempfromType
    end

    this.groupId = 0
    this.args = args

    if this.roomType == RoomType.Lobby then
        --处理数据
        this.CheckLobbyPlayWayData()
        this.playWayRuleDatas = this.lobbyPlayWayData.ruleDatas
        this.funcType = CreateRoomFuncType.Normal
        this.lastPlayWayType = this.lobbyPlayWayData.lastPlayWayType
    else
        this.playWayRuleDatas = {}
        this.funcType = tempfuncType
        this.otherArgs = {}
        if args ~= nil then
            --处理参数
            if args.groupId ~= nil then
                this.groupId = args.groupId
            end
            --
            --获取十点半的规则
            local temp = args[GameType.SDB]
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

--更新配置数据，亲友圈的配置数据更新
function CreateSDBRoomPanel.CheckAndUpdateConfigData()
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
    --是否是配置数据，亲友圈的一键开房
    local isConfigData = false
    --临时变量
    local isShowPlayWayMneu = false

    if this.roomType ~= RoomType.Lobby and this.funcType ~= CreateRoomFuncType.Normal then
        isConfigData = true
    end

    local playWayMenuItems = this.playWayMenuItems
    if this.roomType == RoomType.Club and this.externalMenuItems ~= nil then
        playWayMenuItems = this.externalMenuItems
        UIUtil.SetActive(this.menu, false)
    else
        UIUtil.SetActive(this.menu, true)
    end

    --处理菜单的屏蔽
    length = #playWayMenuItems
    for i = 1, length do
        playWayMenuItem = playWayMenuItems[i]
        playWayConfigData = SDB.CreateRoomConfig[i]
        if this.roomType == RoomType.Club and playWayConfigData.playWayType == SDB.PlayWayType.OwerBanker then
            UIUtil.SetActive(playWayMenuItem.gameObject, false)
        else
            UIUtil.SetActive(playWayMenuItem.gameObject, playWayConfigData ~= nil)
        end
    end

    --激活菜单的计数
    local activeMenuCount = 0

    length = #playWayMenuItems
    for i = 1, length do
        playWayConfigData = SDB.CreateRoomConfig[i]
        --
        playWayRuleData = this.playWayRuleDatas[playWayConfigData.playWayType]
        --
        playWayMenuItem = playWayMenuItems[i]

        --玩法菜单按钮是否显示配置图标
        playWayConfigData.isConfig = playWayRuleData ~= nil and playWayRuleData.isConfig == true and isConfigData
        playWayConfigData.interactable = true

        if playWayMenuItem.configTag ~= nil then
            UIUtil.SetActive(playWayMenuItem.configTag, playWayConfigData.isConfig)
        end

        isShowPlayWayMneu = true
        --一键开房，如果没有配置，则需要屏蔽掉菜单按钮，一键开房才有屏蔽所有配置显示项不可点
        if this.funcType == CreateRoomFuncType.OneKey then
            isShowPlayWayMneu = playWayConfigData.isConfig
            --一键开房是无法修改管理员设置好的数据的
            playWayConfigData.interactable = false
        end

        if this.roomType == RoomType.Club and playWayConfigData.playWayType == SDB.PlayWayType.OwerBanker then
            UIUtil.SetActive(playWayMenuItem.gameObject, false)
        else
            UIUtil.SetActive(playWayMenuItem.gameObject, isShowPlayWayMneu)
        end

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

    ----处理选中的菜单
    --if tempSelectedPlayWayConfigData == nil then
    --    if this.roomType == RoomType.Tea and fristConfigedPlayWayConfigData ~= nil then
    --        tempSelectedPlayWayConfigData = fristConfigedPlayWayConfigData
    --    else
    --        tempSelectedPlayWayConfigData = fristPlayWayConfigData
    --    end
    --end

    --处理选中的菜单
    if tempSelectedPlayWayConfigData == nil then
        tempSelectedPlayWayConfigData = fristPlayWayConfigData
    end

    playWayMenuItem = nil
    local menuIndex = 0
    --查找玩法配置数据对应的菜单显示项
    for i = 1, length do
        playWayConfigData = SDB.CreateRoomConfig[i]
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
function CreateSDBRoomPanel.ClearDisplay()
    this.fullSixStartItem = nil
    this.handStartItem = nil
    this.fullFourStartItem = nil
    this.isSlect4Ren = false
    this.toggleGroupItems = ClearObjList(this.toggleGroupItems)
end

--更新配置数据的显示
function CreateSDBRoomPanel.UpdatePlayWayConfigDataDisplay()
    this.inited = false
    this.ClearDisplay()

    if this.playWayConfigData == nil then
        return
    end

    --处理删除按钮状态
    if this.funcType == CreateRoomFuncType.Config then
        local temp = this.playWayRuleDatas[this.lastPlayWayType]
        local isConfig = temp ~= nil and temp.isConfig == true
        if this.roomType == RoomType.Club then
            --亲友圈的删除按钮
            UIUtil.SetActive(this.deleteBtn, isConfig)
        end
    end

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
    local tempHeight = 0
    --处理规则项创建或者显示
    for i = 1, #this.playWayConfigData.ruleGroups do
        playWayRuleGroupConfigData = this.playWayConfigData.ruleGroups[i]

        isDisplayRule = false

        if playWayRuleGroupConfigData.data.type == SDB.RuleGroupConfigType.Pay then
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
            --设置高度
            UIUtil.SetAnchoredPosition(playWayRuleItem.gameObject, 0, -tempHeight)
            tempHeight = tempHeight + playWayRuleItem.height
        end
    end
    UIUtil.SetHeight(this.configContentGO, tempHeight)
    UIUtil.SetAnchoredPositionY(this.configContentGO, 0)
    --隐藏未激活的玩法规则项
    for k, v in pairs(this.playWayRuleItems) do
        if not v.isActive then
            UIUtil.SetActive(v.gameObject, false)
        end
    end
    this.inited = true
    --更新房卡消耗
    this.UpdateConsumeDisplay()
end

--创建一个规则显示项
function CreateSDBRoomPanel.CreatePlayWayRuleItem(ruleGroupIndex, playWayRuleGroupConfigData)
    local item = {}
    item.ruleGroupIndex = ruleGroupIndex
    item.isActive = false
    item.height = ITEM_HEIGHT
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
function CreateSDBRoomPanel.SetPlayWayRuleItem(playWayRuleItem, playWayRuleGroupConfigData, playWayRuleData)
    --规则配置数据
    local ruleConfigData = nil

    local ruleGroups = {}
    local ruleGroup = nil
    --组的名称
    local groupName = nil
    --规则组配置类型
    local ruleGroupConfigType = playWayRuleGroupConfigData.data.type
    if ruleGroupConfigType == SDB.RuleGroupConfigType.GameTotal then

        ruleGroup = {}
        ruleGroup.name = tostring(ruleGroupConfigType)
        table.insert(ruleGroups, ruleGroup)

        for i = 1, #playWayRuleGroupConfigData.rules do
            ruleConfigData = playWayRuleGroupConfigData.rules[i]
            ruleConfigData.order = i
            ruleConfigData.name = tostring(ruleGroupConfigType + i)
            if ruleConfigData.data.value ~= 4 then
                table.insert(ruleGroup, ruleConfigData)
            end
        end
    elseif ruleGroupConfigType == SDB.RuleGroupConfigType.DiFen then
        ruleGroup = {}
        ruleGroup.name = tostring(ruleGroupConfigType)
        table.insert(ruleGroups, ruleGroup)
        for i = 1, #playWayRuleGroupConfigData.rules do
            ruleConfigData = playWayRuleGroupConfigData.rules[i]
            ruleConfigData.order = i
            ruleConfigData.name = tostring(ruleGroupConfigType + i)
            --1/2/4/6不属于普通场，所以不加入处理
            if ruleConfigData.data.value ~= 3 then
                table.insert(ruleGroup, ruleConfigData)
            end
        end
    elseif ruleGroupConfigType == SDB.RuleGroupConfigType.PlayerTotal then
        ruleGroup = {}
        ruleGroup.name = tostring(ruleGroupConfigType)
        table.insert(ruleGroups, ruleGroup)
        for i = 1, #playWayRuleGroupConfigData.rules do
            ruleConfigData = playWayRuleGroupConfigData.rules[i]
            ruleConfigData.order = i
            ruleConfigData.name = tostring(ruleGroupConfigType + i)
            table.insert(ruleGroup, ruleConfigData)
            --人数选中
            if ruleConfigData.data.type == SDB.RuleType.PlayerTotal then
                local cacheRuleValue = playWayRuleData[ruleConfigData.data.type]
                if cacheRuleValue ~= nil and cacheRuleValue == ruleConfigData.data.value then
                    if cacheRuleValue == 1 then
                        this.isSlect4Ren = true
                    else
                        this.isSlect4Ren = false
                    end
                end
                if ruleConfigData.data.value == 1 and ruleConfigData.selected then
                    this.isSlect4Ren = true
                end
            end
        end

    else
        for i = 1, #playWayRuleGroupConfigData.rules do
            ruleConfigData = playWayRuleGroupConfigData.rules[i]
            --动态给数据设置序号，该值很重要，在查找显示对象时需要
            ruleConfigData.order = i
            ruleConfigData.name = tostring(ruleGroupConfigType + i)
            this.HandleRuleGroup(ruleGroups, ruleConfigData, ruleConfigData.data.group)
        end
    end

    local item = nil
    local desItem = nil
    --先重置标记
    for i = 1, #playWayRuleItem.items do
        item = playWayRuleItem.items[i]
        item.isActive = false
    end

    local itemMaxCol = 3
    local cellSize = nil
    -- local ruleGroupConfigType = nil
    local length = 0
    --计算高度，分组创建
    for i = 1, #ruleGroups do
        ruleGroup = ruleGroups[i]
        --计算需要显示的项
        length = #ruleGroup
        --
        ruleGroupConfigType = playWayRuleGroupConfigData.data.type
        if ruleGroupConfigType == SDB.RuleGroupConfigType.TuiZhu or ruleGroupConfigType == SDB.RuleGroupConfigType.QiangZhuang then
            itemMaxCol = 4
            cellSize = CELL_SIZE_4
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
        item.height = math.ceil(length / itemMaxCol) * ITEM_HEIGHT
        UIUtil.SetHeight(item.gameObject, item.height)
        this.SetPlayWayRuleGroupItem(item, ruleGroup, playWayRuleData)
    end
    local tempHeight = 0
    if ruleGroupConfigType == SDB.RuleGroupConfigType.GameTips then
        itemMaxCol = 1
        cellSize = CELL_SIZE_1
        if desItem == nil then
            desItem = this.CreateDesTxtItem(1, playWayRuleItem.ruleGroupTrans)
        end
        UIUtil.SetActive(desItem.gameObject, true)
        tempHeight = DES_HEIGHT
        UIUtil.SetHeight(desItem.gameObject, DES_HEIGHT)
    end
    for i = 1, #playWayRuleItem.items do
        item = playWayRuleItem.items[i]
        if item.isActive then
            tempHeight = tempHeight + item.height
        else
            UIUtil.SetActive(item.gameObject, false)
        end
    end
    UIUtil.SetHeight(playWayRuleItem.gameObject, tempHeight)
    UIUtil.SetActive(playWayRuleItem.gameObject, true)

    playWayRuleItem.height = tempHeight
end

--处理规则分组
function CreateSDBRoomPanel.HandleRuleGroup(ruleGroups, ruleConfigData, groupName)
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
function CreateSDBRoomPanel.CreatePlayWayRuleGroupItem(index, parent)
    local item = {}
    item.gameObject = CreateGO(this.ruleGroupItemPrefab, parent, tostring(index))
    item.transform = item.gameObject.transform
    item.isActive = false
    item.height = ITEM_HEIGHT
    item.gridLayoutGroup = item.gameObject:GetComponent("GridLayoutGroup")
    item.singleItems = {}
    --参数参考创建方法
    item.multiItems = {}
    return item
end

--创建文本显示项
function CreateSDBRoomPanel.CreateDesTxtItem(index, parent)
    local item = {}
    item.gameObject = this.desTextItemPrefab
    item.transform = item.gameObject.transform
    item.transform:SetParent(parent)
    item.transform.localPosition = Vector3.zero
    item.isActive = false
    item.height = DES_HEIGHT
    return item
end


--设置规则组数据
function CreateSDBRoomPanel.SetPlayWayRuleGroupItem(ruleGroupItem, ruleGroup, playWayRuleData)
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
                item = this.CreatePlayWayRuleConfigItem(this.singleItemPrefab, ruleGroupItem.transform, ruleConfigData.name)
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
        item.isActive = true
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
function CreateSDBRoomPanel.GetToggleGroupItem(type, group)
    local toggleGroupItemName = type .. "_" .. group
    local toggleGroupItem = this.toggleGroupItems[toggleGroupItemName]
    if toggleGroupItem == nil then
        toggleGroupItem = CreateGO(this.toggleGroupItemPrefab, this.toggleGroups, toggleGroupItemName)
        this.toggleGroupItems[toggleGroupItemName] = toggleGroupItem
    end
    return toggleGroupItem
end

--创建具体的一个规则
function CreateSDBRoomPanel.CreatePlayWayRuleConfigItem(prefab, parent, order)
    local item = {}
    --用于标识是否激活
    item.isActive = false
    --用于事件
    item.inited = false
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

--设置具体规则数据
function CreateSDBRoomPanel.SetPlayWayRuleConfigItem(ruleConfigItem, ruleConfigData, playWayRuleData)
    --存储数据，用于获取
    ruleConfigItem.data = ruleConfigData

    --设置显示
    UIUtil.SetActive(ruleConfigItem.gameObject, true)

    local group = ruleConfigData.data.group
    local type = ruleConfigData.data.type
    local toggle = ruleConfigItem.toggle

    local interactable = true

    if type == SDB.RuleType.GameTotal then
        if not ruleConfigItem.inited then
            UIToggleListener.AddListener(ruleConfigItem.gameObject, this.OnConsumeCardsChanged)
        end
    elseif type == SDB.RuleType.PlayerTotal then
        if ruleConfigData.data.value == 1 then
            if not ruleConfigItem.inited then
                UIToggleListener.AddListener(ruleConfigItem.gameObject, this.OnPlayerFourNumToggleChanged)
            end
        else
            if not ruleConfigItem.inited then
                UIToggleListener.AddListener(ruleConfigItem.gameObject, this.OnPlayerSixNumToggleChanged)
            end
        end
    else
        if type == SDB.RuleType.AutoStart then
            if ruleConfigData.data.value == 3 then
                interactable = not this.isSlect4Ren
                this.fullSixStartItem = ruleConfigItem
            elseif ruleConfigData.data.value == 2 then
                this.fullFourStartItem = ruleConfigItem
            else
                this.handStartItem = ruleConfigItem
            end
        end
        if not ruleConfigItem.inited then
            UIToggleListener.AddListener(ruleConfigItem.gameObject, this.OnToggleValueChanged)
        end
    end
    ruleConfigItem.inited = true

    if group ~= 0 then
        local toggleGroupItem = this.GetToggleGroupItem(type, group)
        if toggleGroupItem ~= nil then
            local toggleGroup = toggleGroupItem:GetComponent("ToggleGroup")
            toggle.group = toggleGroup
        end
    else
        toggle.group = nil
    end

    --主要是针对亲友圈一键开房时可以由玩家选择
    if type == SDB.RuleType.Gps then
        interactable = true
    else
        interactable = interactable and this.playWayConfigData.interactable and ruleConfigData.interactable
    end
    toggle.interactable = interactable

    --处理缓存配置选中
    local selected = false
    if playWayRuleData.isEmpty then
        selected = ruleConfigData.selected
    else
        local cacheRuleValue = playWayRuleData[ruleConfigData.data.type]
        if cacheRuleValue ~= nil then
            selected = cacheRuleValue == ruleConfigData.data.value
        else
            selected = false
        end
    end
    toggle.isOn = selected

    --文本显示
    local nameStr = ruleConfigData.data.name
    --特殊显示处理
    if ruleConfigData.data.desc ~= nil then
        nameStr = ruleConfigData.data.desc
    end
    ruleConfigItem.label.text = nameStr

    this.UpdateToggleStatus(ruleConfigItem, selected)
end

--处理Toggle选项的状态，比如选中、禁用等颜色
function CreateSDBRoomPanel.UpdateToggleStatus(ruleConfigItem, isOn)
    local toggle = ruleConfigItem.toggle
    if isOn == nil then
        isOn = toggle.isOn
    end
    if toggle.interactable then
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
end

--处理Toggle选项的选择状态
function CreateSDBRoomPanel.UpdateToggleSelectedStatus(toggle)
    local label = toggle.transform:Find("Label"):GetComponent(TypeText)
    if toggle.isOn then
        label.color = CreateRoomConfig.COLOR_SELECTED
    else
        label.color = CreateRoomConfig.COLOR_NORMAL
    end
end

--处理选项值改变
function CreateSDBRoomPanel.HandleToggleValueChanged(go)
    local toggle = go:GetComponent(TypeToggle)
    if toggle ~= nil then
        this.UpdateToggleSelectedStatus(toggle)
    end
end

--选项值改变
function CreateSDBRoomPanel.OnToggleValueChanged(isOn, listener)
    if not this.inited then
        return
    end
    this.HandleToggleValueChanged(listener.gameObject)
end

--局数选择
function CreateSDBRoomPanel.OnConsumeCardsChanged(isOn, listener)
    if not this.inited then
        return
    end
    this.HandleToggleValueChanged(listener.gameObject)
    this.UpdateConsumeDisplay()
end

function CreateSDBRoomPanel.OnPlayerFourNumToggleChanged(isOn, listener)
    if not this.inited then
        return
    end
    if isOn then
        Log('======OnPlayerFourNumToggleChanged=====', listener)
        this.isSlect4Ren = true
        if this.fullSixStartItem ~= nil then
            this.fullSixStartItem.toggle.interactable = false
            if this.fullFourStartItem ~= nil and this.handStartItem ~= nil then
                if not this.fullFourStartItem.toggle.isOn and not this.handStartItem.toggle.isOn then
                    this.fullFourStartItem.toggle.isOn = true
                    this.UpdateToggleStatus(this.fullFourStartItem)
                end
            end
            this.UpdateToggleStatus(this.fullSixStartItem, false)
        end
    end
    this.HandleToggleValueChanged(listener.gameObject)
    this.UpdateConsumeDisplay()
end

function CreateSDBRoomPanel.OnPlayerSixNumToggleChanged(isOn, listener)
    if not this.inited then
        return
    end
    if isOn then
        this.isSlect4Ren = false
        if this.fullSixStartItem ~= nil then
            this.fullSixStartItem.toggle.interactable = true
            this.UpdateToggleStatus(this.fullSixStartItem)
        end
    end
    this.HandleToggleValueChanged(listener.gameObject)
    this.UpdateConsumeDisplay()
end



--更新房卡消耗显示
function CreateSDBRoomPanel.UpdateConsumeDisplay()

    local ruleDatas = this.GetPlayWayRuleDataAtUI()
    local playerTotal = ruleDatas[SDB.RuleType.PlayerTotal]
    local gameTotal = ruleDatas[SDB.RuleType.GameTotal]
    local cards = SDB.GetCardsConfig(playerTotal, gameTotal)
    SendEvent(CMD.Game.UpdateCreateRoomConsume, cards)
end

--================================================================
--
--检测大厅的玩法缓存数据
function CreateSDBRoomPanel.CheckLobbyPlayWayData()
    if this.lobbyPlayWayData == nil then
        this.lobbyPlayWayData = {}
        this.lobbyPlayWayData.ruleDatas = {}

        local temp = nil
        local str = GetLocal(LocalDatas.MajongPlayWayData, nil)
        if str ~= nil then
            temp = JsonToObj(str)
        end

        if temp ~= nil then
            this.lobbyPlayWayData.lastPlayWayType = temp.lastPlayWayType
            if this.lobbyPlayWayData.lastPlayWayType == nil then
                this.lobbyPlayWayData.lastPlayWayType = SDB.PlayWayType.TakeRunBanker
            end

            if temp.ruleDatas ~= nil then
                local length = #temp.ruleDatas
                local playWayType = nil
                local ruleData = nil
                for i = 1, length do
                    ruleData = temp.ruleDatas[i]
                    if IsTable(ruleData) then
                        ruleData.isConfig = false
                        playWayType = ruleData[SDB.RuleType.PlayWayType]
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
function CreateSDBRoomPanel.SaveLobbyPlayWayConfigData()
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
        SetLocal(LocalDatas.MajongPlayWayData, str)
    end
end

--保存配置数据
function CreateSDBRoomPanel.SavePlayWayConfigData()
    if this.playWayConfigData == nil then
        return nil
    end
    if this.roomType == RoomType.Lobby or this.roomType == RoomType.Club then
        local playWayRuleData = this.GetPlayWayRuleDataAtUI()

        local temp = this.playWayRuleDatas[this.playWayConfigData.playWayType]
        if temp ~= nil and temp.isConfig == true then
            --有配置属性的认为是亲友圈已经配置的，不进行保存
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
function CreateSDBRoomPanel.GetPlayWayRuleDataAtUI()
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

    if includeRules[SDB.RuleType.QiangZhuang] == nil then
        if playWayRuleData[SDB.RuleType.QiangZhuang] == nil then
            playWayRuleData[SDB.RuleType.QiangZhuang] = 1
        end
    end

    --玩法类型
    playWayRuleData[SDB.RuleType.PlayWayType] = this.playWayConfigData.playWayType
    --房间类型
    playWayRuleData[SDB.RuleType.RoomType] = this.roomType

    --支付方式，亲友圈固定传3
    if playWayRuleData[SDB.RuleType.Pay] == nil then
        if this.roomType == RoomType.Club then
            playWayRuleData[SDB.RuleType.Pay] = 3
        end
    end

    return playWayRuleData
end

--检测规则组显示对象
function CreateSDBRoomPanel.CheckRuleGroupItem(ruleGroupItem, playWayRuleData, includeRules)
    if ruleGroupItem.isActive then
        local ruleConfigItem = nil
        local ruleConfigData = nil

        for i = 1, #ruleGroupItem.singleItems do
            ruleConfigItem = ruleGroupItem.singleItems[i]
            if ruleConfigItem.isActive then
                --LogError("规则数据", ruleConfigItem.data)
                ruleConfigData = ruleConfigItem.data
                if ruleConfigData ~= nil then
                    --处理玩法包含的规则
                    includeRules[ruleConfigData.data.type] = ruleConfigData.data.type
                    this.CheckAndSetRuleData(playWayRuleData, ruleConfigData, ruleConfigItem.toggle.isOn)
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
function CreateSDBRoomPanel.CheckAndSetRuleData(playWayRuleData, ruleConfigData, selected)
    if ruleConfigData == nil then
        return
    end

    if ruleConfigData.data.group ~= 0 then
        --单选
        if selected then
            playWayRuleData[ruleConfigData.data.type] = ruleConfigData.data.value
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