ModifyMahjongRoomPanel = ClassLuaComponent("ModifyMahjongRoomPanel")
ModifyMahjongRoomPanel.Instance = nil

--显示项的高度
local ITEM_HEIGHT = 70
--
local CELL_SIZE_3 = Vector2(240, 70)
--
local CELL_SIZE_4 = Vector2(180, 70)

--大厅菜单
local LobbyMenus = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
--联盟菜单
local UnionMenus = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
--俱乐部菜单
local ClubMenus1 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
local ClubMenus2 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }

local this = ModifyMahjongRoomPanel

function ModifyMahjongRoomPanel:Init()
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
    --
    --是否换张选中
    this.isHuanZhangSelected = false
    --换张的规则配置显示项集合
    this.huanZhangRuleConfigItems = {}
    --换三张的规则配置显示项Toggle组件
    this.huanSanZhangRuleToggle = nil
    --换四张的规则配置显示项Toggle组件
    this.huanSiZhangRuleToggle = nil
    --ToggleGroup组件集合
    this.toggleGroupItems = {}
    --存储局数规则显示项
    this.gameTotalItems = {}
    --存储倍数
    this.multipleItems = {}
    --当前的倍数
    this.multiple = 3
    --存储四鸡报喜
    this.sjbxItems = {}
    --存储番数起胡
    this.fanShuQiHuItems = {}
    --
    --其他参数存储
    this.otherArgs = {}  --11
    --创建点击时间
    this.createClickTime = 0  --11
    --当前高级设置数据
    this.advancedData = nil
end

--UI初始化
function ModifyMahjongRoomPanel:Awake()
    this = self
    self:Init()
    -----------------------------------------------------------------------
    --玩法菜单按钮
    local menuTrans = self:Find("Content/Menu")
    this.menu = menuTrans.gameObject
    this.menuContentTrans = menuTrans:Find("ScrollView/Viewport/Content")

    this.playWayMenuItems = {}
    for i = 1, 5 do
        local playWayMenuItemTrans = this.menuContentTrans:Find(tostring(i))
        local playWayMenuItem = {}
        --LogError("playWayMenuItemTrans", playWayMenuItemTrans)
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
    --this.createBtn = buttonTrans:Find("CreateButton").gameObject
    this.ModifyButton = buttonTrans:Find("ModifyButton").gameObject
    this.saveBtn = buttonTrans:Find("SaveButton").gameObject
    this.deleteBtn = buttonTrans:Find("DeleteButton").gameObject
    this.advancedBtn = buttonTrans:Find("AdvancedButton").gameObject

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

function ModifyMahjongRoomPanel.ButtonActiveCtrl()
    LogError("this.isModify", this.isModify)
    UIUtil.SetActive(this.ModifyButton, this.isModify)
    UIUtil.SetActive(this.createBtn, not this.isModify)
end

--当面板开启开启时
function ModifyMahjongRoomPanel:OnOpened(fromType, funcType, args, isModify, playWayName, rules, advancedData)
    this.isModify = isModify or false
    this.playWayName = playWayName
    this.rules = rules
    this.advancedData = advancedData

    LogError(">> ModifyMahjongRoomPanel > OnOpened > ", fromType, funcType)
    ModifyMahjongRoomPanel.Instance = self
    this.menuTrans = self:Find("Content/Menu")
    this.scrollRect = this.menuTrans:Find("ScrollView"):GetComponent(TypeScrollRect)
    this.scrollRectContent = this.scrollRect.content
    local v3 = this.scrollRectContent.localPosition
    this.scrollRectContent.localPosition = Vector2(v3.x, 0)
    this.ButtonActiveCtrl()

    this.AddListenerEvent()

    this.CheckArgsData(fromType, funcType, args)

    --处理高级设置按钮显示
    if this.moneyType == MoneyType.Gold then
        UIUtil.SetActive(this.advancedBtn, true)
    else
        UIUtil.SetActive(this.advancedBtn, false)
    end

    this.InitExternalMenu(args.menuToggleDict)
    this.CheckButtonDisplay()
    this.CheckAndUpdateConfigData()
end

--当面板关闭时调用
function ModifyMahjongRoomPanel:OnClosed()
    ModifyMahjongRoomPanel.Instance = nil
    this.RemoveListenerEvent()
    --关闭的时候保存下配置
    this.SavePlayWayConfigData()
    --清除玩法类型
    this.lastPlayWayType = nil
    --
    this.advancedData = nil
end

------------------------------------------------------------------
--
function ModifyMahjongRoomPanel.AddListenerEvent()
    AddEventListener(CMD.Game.UpdateCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

--
function ModifyMahjongRoomPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.UpdateCreateRoomAdvanced, this.OnUpdateCreateRoomAdvanced)
end

--UI相关事件
function ModifyMahjongRoomPanel.AddUIListenerEvent()
    this:AddOnClick(this.createBtn, this.OnCreateBtnClick)
    this:AddOnClick(this.ModifyButton, this.OnCreateBtnClick)
    this:AddOnClick(this.saveBtn, this.OnSaveBtnClick)
    this:AddOnClick(this.deleteBtn, this.OnDeleteBtnClick)
    this:AddOnClick(this.advancedBtn, this.OnAdvancedBtnClick)

    local length = #this.playWayMenuItems
    for i = 1, length do
        local playWayMenuItem = this.playWayMenuItems[i]
        UIToggleListener.AddListener(playWayMenuItem.gameObject, this.OnPlayWayMenuValueChanged)
    end
end

------------------------------------------------------------------
--初始外部菜单
function ModifyMahjongRoomPanel.InitExternalMenu(menuToggleDict)
    if menuToggleDict ~= nil and this.externalMenuItems == nil then
        this.externalMenuItems = {}
        local item = menuToggleDict[GameType.Mahjong]
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
function ModifyMahjongRoomPanel.OnCreateBtnClick()
    if os.time() - this.createClickTime < 3 then
        Toast.Show("请不要频繁操作")
        return
    end
    this.createClickTime = os.time()
    if GameManager.IsCheckGame(GameType.Mahjong) then
        this.HandleCreateRoom()
    end
end

--创建房间提示处理
function ModifyMahjongRoomPanel.OnCreateAlert()
    this.HandleCreateRoom()
end

--俱乐部和茶馆的保存
function ModifyMahjongRoomPanel.OnSaveBtnClick()
    if this.roomType == RoomType.Club then
        Alert.Prompt("确定保存一键开房配置信息？", this.OnSaveAlert)
    end
end

--保存一键配置提示处理
function ModifyMahjongRoomPanel.OnSaveAlert()
    local ruleDatas = this.GetPlayWayRuleDataAtUI()
    if ruleDatas == nil then
        return
    end
    local playWayType = ruleDatas[Mahjong.RuleType.PlayWayType]
    local playerTotal = ruleDatas[Mahjong.RuleType.PlayerTotal]
    local gameTotal = ruleDatas[Mahjong.RuleType.GameTotal]
    local gps = ruleDatas[Mahjong.RuleType.Gps]
    --由于俱乐部一键配置需要保存GPS的规则用于默认选择项，故这里不清除
    if this.roomType == RoomType.Club then
        local consumeId = Mahjong.GetConsumeConfigId(playWayType, gameTotal)
        ClubData.SendSetYjpzRule(GameType.Mahjong, playWayType, ruleDatas, playerTotal, gameTotal, consumeId, gps)
    end
end

--俱乐部的删除
function ModifyMahjongRoomPanel.OnDeleteBtnClick()
    if this.roomType == RoomType.Club then
        Alert.Prompt("确定删除一键开房配置？", this.OnDeleteAlert)
    end
end

--删除配置提示处理
function ModifyMahjongRoomPanel.OnDeleteAlert()
    if this.roomType == RoomType.Club then
        if this.playWayConfigData ~= nil then
            ClubData.SendRemoveYjpzRule(GameType.Mahjong, this.playWayConfigData.playWayType)
        end
    end
end

--高级设置按钮
function ModifyMahjongRoomPanel.OnAdvancedBtnClick()
    PanelManager.Open(PanelConfig.CreateRoomAdvanced, this.advancedData, Mahjong.DiFenConfig, Mahjong.DiFenNameConfig)
end

--菜单按钮点击
function ModifyMahjongRoomPanel.OnPlayWayMenuValueChanged(isOn, listener)
    if isOn then
        this.SavePlayWayConfigData()
        local dataIndex = tonumber(listener.name)
        --local playWayConfigData = Mahjong.CreateRoomConfig[dataIndex]
        --if playWayConfigData ~= nil then
        --    this.playWayConfigData = playWayConfigData
        --end
        --this.lastPlayWayType = this.playWayConfigData.playWayType
        --this.advancedData = CreateRoomConfig.GetAdvancedData(GameType.Mahjong, this.lastPlayWayType)

        local playWayConfigData
        if not this.isModify then
            this.advancedData = CreateRoomConfig.GetAdvancedData(GameType.ErQiShi, this.lastPlayWayType)
            playWayConfigData = Mahjong.CreateRoomConfig[dataIndex]
        else
            this.ModifyRoomConfig = CopyTable(Mahjong.CreateRoomConfig, true)
            playWayConfigData = this.ModifyRoomConfig[dataIndex]
        end
        if playWayConfigData ~= nil then
            this.playWayConfigData = playWayConfigData
        end
        this.lastPlayWayType = this.playWayConfigData.playWayType

        this.UpdatePlayWayConfigDataDisplay()
    end
end

--================================================================
--
local tempPlayWayType = Mahjong.PlayWayType.YaoJiSiRen
local tempPlayerTotal = 4
local tempGameTotal = 4
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
local baoDi = 0
local bdPer = 0
--处理创建房间
function ModifyMahjongRoomPanel.HandleCreateRoom()
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
        baoDi = 0
        bdPer = 0
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
        tempRuleDatas[Mahjong.RuleType.Score] = tempBaseScore
        tempRuleDatas[Mahjong.RuleType.ZhunRu] = tempInGold
        tempRuleDatas[Mahjong.RuleType.JieSanFenShu] = tempJieSanFenShu

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
    tempPlayWayType = tempRuleDatas[Mahjong.RuleType.PlayWayType]
    tempPlayerTotal = tempRuleDatas[Mahjong.RuleType.PlayerTotal]
    tempGameTotal = tempRuleDatas[Mahjong.RuleType.GameTotal]
    tempGps = tempRuleDatas[Mahjong.RuleType.Gps]
    tempConsumeId = Mahjong.GetConsumeConfigId(tempPlayWayType, tempGameTotal)
    tempPayType = tempRuleDatas[Mahjong.RuleType.Pay]

    --两人一房特殊处理
    if tempPlayWayType == Mahjong.PlayWayType.ErRenYiFang then
        tempPlayWayType = Mahjong.PlayWayType.ErRen
        tempRuleDatas = CopyTable(tempRuleDatas)
        tempRuleDatas[Mahjong.RuleType.PlayWayType] = tempPlayWayType
    end

    if this.roomType == RoomType.Lobby then
        BaseTcpApi.SendCreateRoom(GameType.Mahjong, tempRuleDatas, tempPlayerTotal, tempGameTotal, this.roomType, this.moneyType, tempConsumeId, 0, tempPayType, tempGps)
        -- elseif this.roomType == RoomType.Club then
        --     if not IsNil(this.args) then
        --         if not IsNil(this.args.clubCallback) then
        --             local data = Functions.PackGameRule(GameType.Mahjong, tempRuleDatas, tempPlayWayType, tempGameTotal,
        --             tempPlayerTotal, tempConsumeId, tempPayType, tempBaseScore, tempInGold, tempZhuoFei, tempZhuoFeiMin, tempJieSanFenShu)
        --             this.args.clubCallback(this.args.type, data)
        --         end
        --     end
    elseif this.roomType == RoomType.Tea then
        if not IsNil(this.args) then
            if not IsNil(this.args.unionCallback) then
                local data = Functions.PackGameRule(GameType.Mahjong, tempRuleDatas, tempPlayWayType, tempGameTotal,
                        tempPlayerTotal, tempConsumeId, tempPayType, tempBaseScore, tempInGold, tempJieSanFenShu, note, wins, consts, baoDi, nil,nil,nil,bdPer)
                --LogError(data)
                this.args.unionCallback(this.args.type, data)
            end
        end
    end
end

--检测定位
function ModifyMahjongRoomPanel.OnCheckGpsCompleted()
    if GPSModule.gpsEnabled then
        BaseTcpApi.SendCreateRoom(GameType.Mahjong, tempRuleDatas, tempPlayerTotal, tempGameTotal, this.roomType, MoneyType.Fangka, tempConsumeId, 0, tempPayType, tempGps)
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
function ModifyMahjongRoomPanel.OnGpsAlertCallback()
    AppPlatformHelper.OpenDeviceSetting()
end

--检测按钮显示
function ModifyMahjongRoomPanel.CheckButtonDisplay()

end

--================================================================
--
--处理传递参数数据
function ModifyMahjongRoomPanel.CheckArgsData(fromType, moneyType, args)
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

    this.groupId = 0

    if this.roomType == RoomType.Lobby then
        this.lobbyPlayWayData = nil
        this.CheckLobbyPlayWayData()
        this.playWayRuleDatas = this.lobbyPlayWayData.ruleDatas
        this.lastPlayWayType = this.lobbyPlayWayData.lastPlayWayType
    elseif this.roomType == RoomType.Tea then
        this.lobbyPlayWayData = nil
        this.playWayRuleDatas = {}
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
            local temp = args[GameType.Mahjong]
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
function ModifyMahjongRoomPanel.CheckAndUpdateConfigData()
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

    --处理菜单的屏蔽
    if this.isModify and this.playWayName then
        length = #playWayMenuItems
        this.itemIndex = 0
        for i = 1, length do
            local item = playWayMenuItems[i]
            local labelText = UIUtil.GetText(item.transform:Find("Label"))
            item.toggle.isOn = false
            local isThatItem = labelText == this.playWayName
            item.toggle.isOn = isThatItem
            item.toggle.interactable = isThatItem
            if isThatItem then
                this.itemIndex = i
            end
        end
        Functions.RevertLastDisplay(this.ModifyRoomConfig[this.itemIndex].ruleGroups, this.rules)
    else
        length = #playWayMenuItems
        for i = 1, length do
            playWayMenuItem = playWayMenuItems[i]
            playWayConfigData = EqsRule.CreateRoomConfig[i]
            UIUtil.SetActive(playWayMenuItem.gameObject, playWayConfigData ~= nil)
        end
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
    Log(#this.externalMenuItems)
    Log(menus)
    for i = 1, #this.externalMenuItems do
        local item = this.externalMenuItems[i]
        if item ~= nil then
            if menus[i] == 0 then
                Log(i, menus[i])
                UIUtil.SetActive(item.gameObject, false)
            else
                UIUtil.SetActive(item.gameObject, true)
            end
        end
    end


    --激活菜单的计数
    local activeMenuCount = 0
    length = #Mahjong.CreateRoomConfig
    for i = 1, length do
        playWayConfigData = this.isModify and this.ModifyRoomConfig[i] or Mahjong.CreateRoomConfig[i]
        --
        playWayRuleData = this.playWayRuleDatas[playWayConfigData.playWayType]
        --
        --LogError("playWayMenuItems[i]", playWayMenuItems[i])
        playWayMenuItem = playWayMenuItems[i]

        --玩法菜单按钮是否显示配置图标
        playWayConfigData.isConfig = playWayRuleData ~= nil and playWayRuleData.isConfig == true and isConfigData
        playWayConfigData.interactable = true

        isShowPlayWayMneu = menus[i] ~= 0
        -- --一键开房，如果没有配置，则需要屏蔽掉菜单按钮，一键开房才有屏蔽所有配置显示项不可点
        -- if this.moneyType == CreateRoomFuncType.OneKey then
        --     isShowPlayWayMneu = playWayConfigData.isConfig
        --     --一键开房是无法修改管理员设置好的数据的
        --     playWayConfigData.interactable = false
        -- end
        --UIUtil.SetActive(playWayMenuItem.gameObject, isShowPlayWayMneu)
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
        playWayConfigData = Mahjong.CreateRoomConfig[i]
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

    this.menuContentTrans = this.menuTrans:Find("ScrollView/Viewport/Content")
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
function ModifyMahjongRoomPanel.ClearDisplay()
    this.isHuanZhangSelected = false
    this.huanZhangRuleConfigItems = {}
    this.huanSanZhangRuleToggle = nil
    this.huanSiZhangRuleToggle = nil
    this.gameTotalItems = {}
    this.multiple = 3
    this.multipleItems = {}
    this.sjbxItems = {}
    this.fanShuQiHuItems = {}
    this.toggleGroupItems = ClearObjList(this.toggleGroupItems)
end

--更新配置数据的显示
function ModifyMahjongRoomPanel.UpdatePlayWayConfigDataDisplay()
    this.inited = false
    this.ClearDisplay()

    if this.playWayConfigData == nil then
        return
    end

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

    local tempHeight = 0
    --处理规则项创建或者显示
    for i = 1, #this.playWayConfigData.ruleGroups do
        playWayRuleGroupConfigData = this.playWayConfigData.ruleGroups[i]

        isDisplayRule = false

        if playWayRuleGroupConfigData.data.type == Mahjong.RuleGroupConfigType.Pay then
            isDisplayRule = isDisplayPayment
        elseif playWayRuleGroupConfigData.data.type == Mahjong.RuleGroupConfigType.Score or playWayRuleGroupConfigData.data.type == Mahjong.RuleGroupConfigType.ZhunRu
                or playWayRuleGroupConfigData.data.type == Mahjong.RuleGroupConfigType.ZhuoFei or playWayRuleGroupConfigData.data.type == Mahjong.RuleGroupConfigType.ZhuoFeiMin
                or playWayRuleGroupConfigData.data.type == Mahjong.RuleGroupConfigType.JieSanFenShu then
            isDisplayRule = isDisplayScore
        else
            isDisplayRule = true
        end

        if isDisplayRule then
            playWayRuleItem = this.playWayRuleItems[playWayRuleGroupConfigData.data.type]
            --LogError("<color=aqua>this.playWayRuleItems</color>", this.playWayRuleItems)
            --LogError("<color=aqua>playWayRuleItem</color>", playWayRuleItem)
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
    --更新钻石消耗
    this.UpdateConsumeDisplay()
    --检测番数起胡
    this.CheckFanShuQiHu()
end

--创建一个规则显示项
function ModifyMahjongRoomPanel.CreatePlayWayRuleItem(ruleGroupIndex, playWayRuleGroupConfigData)
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
function ModifyMahjongRoomPanel.SetPlayWayRuleItem(playWayRuleItem, playWayRuleGroupConfigData, playWayRuleData)
    --规则配置数据
    local ruleConfigData = nil

    local ruleGroups = {}
    local ruleGroup = nil
    --组的名称
    local groupName = nil
    --是否换张选择
    this.isHuanZhangSelected = false
    --规则组配置类型
    local ruleGroupConfigType = playWayRuleGroupConfigData.data.type
    --
    --首先对数据进行处理
    if ruleGroupConfigType == Mahjong.RuleGroupConfigType.GameTotal then
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
    elseif ruleGroupConfigType == Mahjong.RuleGroupConfigType.Change then
        --换张不分组
        ruleGroup = {}
        ruleGroup.name = tostring(ruleGroupConfigType)
        table.insert(ruleGroups, ruleGroup)

        for i = 1, #playWayRuleGroupConfigData.rules do
            ruleConfigData = playWayRuleGroupConfigData.rules[i]
            ruleConfigData.order = i
            ruleConfigData.name = tostring(ruleGroupConfigType + i)
            table.insert(ruleGroup, ruleConfigData)
            --
            --换牌选择处理，主要是找出是否有换张选中
            if ruleConfigData.data.type == Mahjong.RuleType.ChangeCardTotal then
                --处理缓存中的配置
                if playWayRuleData.isEmpty == nil then
                    if ruleConfigData.selected then
                        this.isHuanZhangSelected = true
                    end
                else
                    local cacheRuleValue = playWayRuleData[ruleConfigData.data.type]
                    if cacheRuleValue ~= nil and cacheRuleValue == ruleConfigData.data.value then
                        this.isHuanZhangSelected = true
                    end
                end
            end
        end
    elseif ruleGroupConfigType == Mahjong.RuleGroupConfigType.PlayWay then
        for i = 1, #playWayRuleGroupConfigData.rules do
            ruleConfigData = playWayRuleGroupConfigData.rules[i]

            ruleConfigData.order = i
            ruleConfigData.name = tostring(ruleGroupConfigType + i)
            --托管不做处理，茶馆使用的
            if ruleConfigData.data and ruleConfigData.data.type ~= Mahjong.RuleType.Trust then
                this.HandleRuleGroup(ruleGroups, ruleConfigData, ruleConfigData.data.group)
            end
        end
    elseif ruleGroupConfigType == Mahjong.RuleGroupConfigType.Limit then
        --获取到当前选择的倍数
        for i = 1, #playWayRuleGroupConfigData.rules do
            ruleConfigData = playWayRuleGroupConfigData.rules[i]
            ruleConfigData.order = i
            ruleConfigData.name = tostring(ruleGroupConfigType + i)
            this.HandleRuleGroup(ruleGroups, ruleConfigData, ruleConfigData.data.group)

            if i == 1 then
                --先获取倍数默认值
                this.multiple = ruleConfigData.data.value
            end

            --获取缓存中的倍数
            if ruleConfigData.data.type == Mahjong.RuleType.Multiple then
                if playWayRuleData.isEmpty ~= nil then
                    local cacheRuleValue = playWayRuleData[ruleConfigData.data.type]
                    if cacheRuleValue ~= nil and cacheRuleValue == ruleConfigData.data.value then
                        this.multiple = ruleConfigData.data.value
                    end
                end
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
        ruleConfigData = ruleGroup[1]
        if ruleConfigData ~= nil and ruleConfigData.data.type == Mahjong.RuleType.FanShuQiHu then
            itemMaxCol = 3
            cellSize = CELL_SIZE_3
        else
            ruleGroupConfigType = playWayRuleGroupConfigData.data.type
            if ruleGroupConfigType == Mahjong.RuleGroupConfigType.Limit then
                itemMaxCol = 4
                cellSize = CELL_SIZE_4
            else
                itemMaxCol = 3
                cellSize = CELL_SIZE_3
            end
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
function ModifyMahjongRoomPanel.HandleRuleGroup(ruleGroups, ruleConfigData, groupName)
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
function ModifyMahjongRoomPanel.CreatePlayWayRuleGroupItem(index, parent)
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

--设置规则组数据
function ModifyMahjongRoomPanel.SetPlayWayRuleGroupItem(ruleGroupItem, ruleGroup, playWayRuleData)
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
                if ruleConfigData.data.type == Mahjong.RuleType.Score and ruleConfigData.data.value == 0 then
                    item = this.CreatePlayWayRuleConfigInputItem(this.inputSingleItemPrefab6, ruleGroupItem.transform, ruleConfigData.name)
                elseif ruleConfigData.data.type == Mahjong.RuleType.ZhunRu and ruleConfigData.data.value == 0 then
                    item = this.CreatePlayWayRuleConfigInputItem(this.inputSingleItemPrefab6, ruleGroupItem.transform, ruleConfigData.name)
                elseif ruleConfigData.data.type == Mahjong.RuleType.ZhuoFei and ruleConfigData.data.value == 0 then
                    item = this.CreatePlayWayRuleConfigInputItem(this.inputSingleItemPrefab6, ruleGroupItem.transform, ruleConfigData.name)
                elseif ruleConfigData.data.type == Mahjong.RuleType.ZhuoFeiMin and ruleConfigData.data.value == 0 then
                    item = this.CreatePlayWayRuleConfigInputItem(this.inputSingleItemPrefab6, ruleGroupItem.transform, ruleConfigData.name)
                elseif ruleConfigData.data.type == Mahjong.RuleType.JieSanFenShu and ruleConfigData.data.value == 0 then
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
        if ruleConfigData.data.type == Mahjong.RuleType.GameTotal and this.moneyType == MoneyType.Fangka and ruleConfigData.data.value == -1 then
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
function ModifyMahjongRoomPanel.GetToggleGroupItem(type, group)
    local toggleGroupItemName = type .. "_" .. group
    local toggleGroupItem = this.toggleGroupItems[toggleGroupItemName]
    if toggleGroupItem == nil then
        toggleGroupItem = CreateGO(this.toggleGroupItemPrefab, this.toggleGroups, toggleGroupItemName)
        this.toggleGroupItems[toggleGroupItemName] = toggleGroupItem
    end
    return toggleGroupItem
end

--创建具体的一个规则
function ModifyMahjongRoomPanel.CreatePlayWayRuleConfigItem(prefab, parent, order)
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
function ModifyMahjongRoomPanel.CreatePlayWayRuleConfigInputItem(prefab, parent, order)
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
function ModifyMahjongRoomPanel.SetPlayWayRuleConfigItem(ruleConfigItem, ruleConfigData, playWayRuleData)
    --存储数据，用于获取
    ruleConfigItem.data = ruleConfigData

    --设置显示
    UIUtil.SetActive(ruleConfigItem.gameObject, true)

    tempGroup = ruleConfigData.data.group
    tempType = ruleConfigData.data.type
    tempToggle = ruleConfigItem.toggle
    tempSelected = nil
    tempInteractable = true
    if tempType == Mahjong.RuleType.GameTotal then
        --选中局数，处理钻石消耗显示
        if not ruleConfigItem.inited then
            UIToggleListener.AddListener(ruleConfigItem.gameObject, this.OnConsumeCardsChanged)
        end
        table.insert(this.gameTotalItems, ruleConfigItem)
    elseif tempType == Mahjong.RuleType.ChangeCardTotal then
        --换牌类型
        if ruleConfigData.data.value == 3 then
            --换三张
            this.huanSanZhangRuleToggle = tempToggle
            if not ruleConfigItem.inited then
                UIToggleListener.AddListener(ruleConfigItem.gameObject, this.OnHuanSanZhangValueChanged)
            end
        else
            --换四张
            this.huanSiZhangRuleToggle = tempToggle
            if not ruleConfigItem.inited then
                UIToggleListener.AddListener(ruleConfigItem.gameObject, this.OnHuanSiZhangValueChanged)
            end
        end
    elseif tempType == Mahjong.RuleType.ChangeCardType then
        --换牌张数
        tempInteractable = this.isHuanZhangSelected
        table.insert(this.huanZhangRuleConfigItems, ruleConfigItem)
        if not ruleConfigItem.inited then
            UIToggleListener.AddListener(ruleConfigItem.gameObject, this.OnToggleValueChanged)
        end
    elseif tempType == Mahjong.RuleType.Multiple then
        --番数
        if not ruleConfigItem.inited then
            UIToggleListener.AddListener(ruleConfigItem.gameObject, this.OnMultipleValueChanged)
        end
        table.insert(this.multipleItems, ruleConfigItem)
    elseif tempType == Mahjong.RuleType.SiJiBaoXi then
        --四鸡报喜
        if not ruleConfigItem.inited then
            UIToggleListener.AddListener(ruleConfigItem.gameObject, this.OnToggleValueChanged)
        end
        table.insert(this.sjbxItems, ruleConfigItem)

        --四鸡特殊处理
        if ruleConfigData.data.value == 5 then
            if this.multiple < 6 then
                tempSelected = true
            end
        else
            if this.multiple < 6 then
                tempSelected = false
            end
            tempInteractable = this.multiple > 5
        end
    elseif tempType == Mahjong.RuleType.FanShuQiHu then
        --番数起胡
        if not ruleConfigItem.inited then
            UIToggleListener.AddListener(ruleConfigItem.gameObject, this.OnToggleValueChanged)
        end
        --
        table.insert(this.fanShuQiHuItems, ruleConfigItem)
        --
        if ruleConfigData.data.value <= this.multiple then
            tempInteractable = true
        else
            tempSelected = false
            tempInteractable = false
        end
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
    if tempType == Mahjong.RuleType.Gps then
        tempInteractable = true
    else
        tempInteractable = tempInteractable and this.playWayConfigData.interactable and ruleConfigData.interactable
    end
    ruleConfigItem.interactable = tempInteractable
    tempToggle.interactable = tempInteractable

    --处理缓存配置选中
    if tempSelected == nil then
        if playWayRuleData.isEmpty then
            tempSelected = ruleConfigData.selected
        else
            local cacheRuleValue = playWayRuleData[ruleConfigData.data.type]
            if cacheRuleValue ~= nil then
                tempSelected = cacheRuleValue == ruleConfigData.data.value
            else
                tempSelected = ruleConfigData.selected
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

--处理Toggle选项的状态，比如选中、禁用等颜色
function ModifyMahjongRoomPanel.UpdateToggleStatus(ruleConfigItem, isOn)
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
end

--处理Toggle选项的选择状态
function ModifyMahjongRoomPanel.UpdateToggleSelectedStatus(toggle)
    local label = toggle.transform:Find("Label"):GetComponent(TypeText)
    if toggle.isOn then
        label.color = CreateRoomConfig.COLOR_SELECTED
    else
        label.color = CreateRoomConfig.COLOR_NORMAL
    end
end

--处理选项值改变
function ModifyMahjongRoomPanel.HandleToggleValueChanged(go)
    local toggle = go:GetComponent(TypeToggle)
    if toggle ~= nil then
        this.UpdateToggleSelectedStatus(toggle)
    end
end

--倍数选择
function ModifyMahjongRoomPanel.OnMultipleValueChanged(isOn, listener)
    if not this.inited then
        return
    end
    this.HandleToggleValueChanged(listener.gameObject)

    if isOn then
        --
        local item = nil
        local length = #this.multipleItems
        for i = 1, #this.multipleItems do
            item = this.multipleItems[i]
            if item.toggle.isOn then
                if item.data ~= nil then
                    this.multiple = item.data.data.value
                end
                break
            end
        end
        this.UpdateFanShuQiHu()
        this.UpdateSjbxStatus()
        --
    end
end

--更新番数起胡
function ModifyMahjongRoomPanel.UpdateFanShuQiHu()
    local length = #this.fanShuQiHuItems
    if length > 0 then
        local item = nil
        for i = 1, length do
            item = this.fanShuQiHuItems[i]
            if item.data.data.value <= this.multiple then
                tempInteractable = true
            else
                tempInteractable = false
            end
            tempInteractable = tempInteractable and this.playWayConfigData.interactable and item.data.interactable
            item.interactable = tempInteractable
            item.toggle.interactable = tempInteractable
            if tempInteractable == false then
                item.toggle.isOn = false
                this.UpdateToggleStatus(item, false)
            else
                this.UpdateToggleStatus(item, item.toggle.isOn)
            end
        end
        this.CheckFanShuQiHu()
    end
end

--检测番数起胡
function ModifyMahjongRoomPanel.CheckFanShuQiHu()
    local length = #this.fanShuQiHuItems
    if length > 0 then
        local isExist = false
        local item = nil
        for i = 1, length do
            item = this.fanShuQiHuItems[i]
            if item.interactable and item.toggle.isOn then
                isExist = true
                break
            end
        end
        if not isExist then
            this.fanShuQiHuItems[1].toggle.isOn = true
        end
    end
end

--更新四鸡报喜
function ModifyMahjongRoomPanel.UpdateSjbxStatus()
    --处理4鸡报喜
    local length = #this.sjbxItems
    if length > 0 then
        local item = nil
        local item5 = nil
        local item6 = nil
        for i = 1, length do
            item = this.sjbxItems[i]
            if item.data.data.value == 5 then
                item5 = item
                tempInteractable = true
            else
                item6 = item
                tempInteractable = this.multiple > 5
            end
            tempInteractable = tempInteractable and this.playWayConfigData.interactable and item.data.interactable
            item.interactable = tempInteractable
            item.toggle.interactable = tempInteractable
        end

        --如果6番不能选择，就直接设置为5番
        if item6.interactable == false then
            item6.toggle.isOn = false
            item5.toggle.isOn = true
            this.UpdateToggleStatus(item6, false)
            this.UpdateToggleStatus(item5, true)
        else
            this.UpdateToggleStatus(item6)
            this.UpdateToggleStatus(item5)
        end
    end
end

--选项值改变
function ModifyMahjongRoomPanel.OnToggleValueChanged(isOn, listener)
    if not this.inited then
        return
    end
    this.HandleToggleValueChanged(listener.gameObject)
end

--局数选择
function ModifyMahjongRoomPanel.OnConsumeCardsChanged(isOn, listener)
    if not this.inited then
        return
    end
    this.HandleToggleValueChanged(listener.gameObject)
    this.UpdateConsumeDisplay()
end

--换三张选项选择
function ModifyMahjongRoomPanel.OnHuanSanZhangValueChanged(isOn, listener)
    if not this.inited then
        return
    end
    if isOn then
        if this.huanSiZhangRuleToggle ~= nil and this.huanSiZhangRuleToggle.isOn then
            this.huanSiZhangRuleToggle.isOn = false
        end
    end
    this.HandleHuanZhangToggleItems()
    this.HandleToggleValueChanged(listener.gameObject)
end

--换四张选项选择
function ModifyMahjongRoomPanel.OnHuanSiZhangValueChanged(isOn, listener)
    if not this.inited then
        return
    end
    if isOn then
        if this.huanSanZhangRuleToggle ~= nil and this.huanSanZhangRuleToggle.isOn then
            this.huanSanZhangRuleToggle.isOn = false
        end
    end
    this.HandleHuanZhangToggleItems()
    this.HandleToggleValueChanged(listener.gameObject)
end

--处理换张选项的显示
function ModifyMahjongRoomPanel.HandleHuanZhangToggleItems()
    local isDisplay = false
    if this.huanSiZhangRuleToggle ~= nil and this.huanSiZhangRuleToggle.isOn then
        isDisplay = true
    elseif this.huanSanZhangRuleToggle ~= nil and this.huanSanZhangRuleToggle.isOn then
        isDisplay = true
    end
    local item = nil
    if this.huanZhangRuleConfigItems ~= nil then
        for i = 1, #this.huanZhangRuleConfigItems do
            item = this.huanZhangRuleConfigItems[i]
            item.interactable = isDisplay
            item.toggle.interactable = isDisplay
            this.UpdateToggleStatus(item)
        end
    end
end



--更新钻石消耗显示
function ModifyMahjongRoomPanel.UpdateConsumeDisplay()
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
function ModifyMahjongRoomPanel.CheckLobbyPlayWayData()
    if this.lobbyPlayWayData == nil then
        this.lobbyPlayWayData = {}
        this.lobbyPlayWayData.ruleDatas = {}

        local temp = nil
        local str = GetLocal(LocalDatas.MahjongPlayWayData, nil)
        if str ~= nil then
            temp = JsonToObj(str)
        end

        if temp ~= nil then
            this.lobbyPlayWayData.lastPlayWayType = temp.lastPlayWayType
            if this.lobbyPlayWayData.lastPlayWayType == nil then
                this.lobbyPlayWayData.lastPlayWayType = Mahjong.PlayWayType.YaoJiErRen
            end

            if temp.ruleDatas ~= nil then
                local length = #temp.ruleDatas
                local playWayType = nil
                local ruleData = nil
                for i = 1, length do
                    ruleData = temp.ruleDatas[i]
                    if IsTable(ruleData) then
                        ruleData.isConfig = false
                        playWayType = ruleData[Mahjong.RuleType.PlayWayType]
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
function ModifyMahjongRoomPanel.SaveLobbyPlayWayConfigData()
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
        SetLocal(LocalDatas.MahjongPlayWayData, str)
    end
end

--保存配置数据
function ModifyMahjongRoomPanel.SavePlayWayConfigData()
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
function ModifyMahjongRoomPanel.GetPlayWayRuleDataAtUI()
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
    playWayRuleData[Mahjong.RuleType.PlayWayType] = this.playWayConfigData.playWayType
    --人数字段
    playWayRuleData[Mahjong.RuleType.PlayerTotal] = this.playWayConfigData.playerTotal
    --房间类型
    playWayRuleData[Mahjong.RuleType.RoomType] = this.roomType

    --默认规则配置
    local ruleConfigData = nil
    if this.playWayConfigData.defaultRuleGroups ~= nil then
        for i = 1, #this.playWayConfigData.defaultRuleGroups do
            ruleConfigData = this.playWayConfigData.defaultRuleGroups[i]
            playWayRuleData[ruleConfigData.type] = ruleConfigData.value
        end
    end

    ---飞小鸡人数修正
    if playWayRuleData[Mahjong.RuleType.FlyChickenPeopleCount] then
        playWayRuleData[Mahjong.RuleType.PlayerTotal] = playWayRuleData[Mahjong.RuleType.FlyChickenPeopleCount]
    end

    --处理房数
    local fangTotal = playWayRuleData[Mahjong.RuleType.FangTotal]
    --定缺字段，房数为3的牌局才发送定缺
    if fangTotal == nil or fangTotal == 3 then
        playWayRuleData[Mahjong.RuleType.DingQue] = 1
    else
        --没有定缺显示，故可以设置0，需要发给服务器端
        playWayRuleData[Mahjong.RuleType.DingQue] = 0
    end

    --点炮可平胡处理，没有点炮可平胡的选项，传递默认值为1
    if includeRules[Mahjong.RuleType.DianPaoPingHu] == nil then
        if playWayRuleData[Mahjong.RuleType.DianPaoPingHu] == nil then
            playWayRuleData[Mahjong.RuleType.DianPaoPingHu] = 1
        end
    end

    --支付方式，俱乐部固定传3
    if playWayRuleData[Mahjong.RuleType.Pay] == nil then
        if this.roomType == RoomType.Club or this.roomType == RoomType.Tea then
            playWayRuleData[Mahjong.RuleType.Pay] = 3
        end
    end
    --处理番数起胡
    local fanshu = playWayRuleData[Mahjong.RuleType.FanShuQiHu]
    if fanshu ~= nil then
        if fanshu == 1 then
            playWayRuleData[Mahjong.RuleType.LiangFenQiHu] = 1
        elseif fanshu == 2 then
            playWayRuleData[Mahjong.RuleType.LiangFanQiHu] = 1
        elseif fanshu == 3 then
            playWayRuleData[Mahjong.RuleType.SanFanQiHu] = 1
        elseif fanshu == 4 then
            playWayRuleData[Mahjong.RuleType.SiFanQiHu] = 1
        end
    end

    LogError(">> ModifyMahjongRoomPanel.GetPlayWayRuleDataAtUI > ", playWayRuleData)
    return playWayRuleData
end

--检测规则组显示对象
function ModifyMahjongRoomPanel.CheckRuleGroupItem(ruleGroupItem, playWayRuleData, includeRules)
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
function ModifyMahjongRoomPanel.CheckAndSetRuleData(playWayRuleData, ruleConfigData, selected, inputValue)
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
                --换牌总数不处理
                if ruleConfigData.data.type ~= Mahjong.RuleType.ChangeCardTotal then
                    playWayRuleData[ruleConfigData.data.type] = 0
                end
            end
        end
    end
end

--更新创建房间高级设置
function ModifyMahjongRoomPanel.OnUpdateCreateRoomAdvanced(data)
    this.advancedData = data
    CreateRoomConfig.SaveAdvancedData(GameType.Mahjong, this.lastPlayWayType, data)
end