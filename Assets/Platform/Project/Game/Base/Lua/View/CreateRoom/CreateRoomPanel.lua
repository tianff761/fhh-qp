CreateRoomPanel = ClassPanel("CreateRoomPanel")
local this = CreateRoomPanel

local PanelConfigs = {
    [GameType.Mahjong] = { prefab = "CreateRoomNodeMahjong", panel = "CreateMahjongRoomPanel" },
    [GameType.ErQiShi] = { prefab = "CreateRoomNodeEqs", panel = "CreateEqsRoomPanel" },
    [GameType.PaoDeKuai] = { prefab = "CreateRoomNodeLSPdk", panel = "CreateLSPdkRoomPanel" },
    [GameType.Pin5] = { prefab = "CreateRoomNodePin5", panel = "CreatePin5RoomPanel" },
    [GameType.Pin3] = { prefab = "CreateRoomNodePin3", panel = "CreatePin3RoomPanel" },
    [GameType.SDB] = { prefab = "CreateRoomNodeSDB", panel = "CreateSDBRoomPanel" },
    [GameType.LYC] = { prefab = "CreateRoomNodeLYC", panel = "CreateLYCRoomPanel" },
    [GameType.TP] = { prefab = "CreateRoomNodeCommon", panel = "CreateRoomCommonPanel" },
}

--菜单配置，这样做得目的是减少对Prefab处理
local MenuConfigs = {
    [GameType.Mahjong] = {
        { index = 1, name = "幺鸡四人", playwayType = Mahjong.PlayWayType.YaoJiSiRen },
        { index = 2, name = "幺鸡三人", playwayType = Mahjong.PlayWayType.YaoJiSanRen },
        { index = 3, name = "幺鸡二人", playwayType = Mahjong.PlayWayType.YaoJiErRen },
        { index = 4, name = "血战到底", playwayType = Mahjong.PlayWayType.XueZhanDaoDi },
        { index = 5, name = "三人两房", playwayType = Mahjong.PlayWayType.SanRenErFang },
        { index = 6, name = "四人两房", playwayType = Mahjong.PlayWayType.SiRenErFang },
        { index = 7, name = "三人三房", playwayType = Mahjong.PlayWayType.SanRenSanFang },
        { index = 8, name = "两人麻将", playwayType = Mahjong.PlayWayType.ErRen },
        { index = 9, name = "两人一房", playwayType = Mahjong.PlayWayType.ErRenYiFang },
    },
    [GameType.ErQiShi] = {
        { index = 1, name = "乐山贰柒拾" },
        { index = 2, name = "犍为贰柒拾" },
        { index = 3, name = "眉山贰柒拾" },
        { index = 4, name = "十四张两人" },
        { index = 5, name = "十四张三人" },
        { index = 6, name = "十四张四人" },
        { index = 7, name = "两人贰柒拾" },
    },
    [GameType.PaoDeKuai] = {
        { index = 1, name = "乐山三人" },
        { index = 2, name = "乐山四人" },
        { index = 3, name = "两人无四炸" },
        { index = 4, name = "三人无四炸" },
        { index = 5, name = "四人跑得快" },
        { index = 6, name = "15张跑得快" },
        { index = 7, name = "16张跑得快" },
    },
    [GameType.Pin5] = {
        { index = 1, name = "明牌抢庄" },
    },
    [GameType.Pin3] = {
        { index = 1, name = "经典模式" },
    },
    [GameType.LYC] = {
        { index = 1, name = "捞腌菜" },
    },
    [GameType.TP] = {
        { index = 1, name = "德州扑克" },
    },
}

--初始属性数据
function CreateRoomPanel:InitProperty()
    --打开创建游戏类型
    this.openGameType = GameType.Mahjong
    --房间类型 0大厅  1俱乐部 2联盟
    this.roomType = RoomType.Lobby
    --货币类型
    this.moneyType = MoneyType.Fangka
    --菜单Item数组
    this.gameTypeItems = {}
    --菜单Item字典
    this.gameTypeItemDict = {}
    --游戏面板
    this.gamePanel = nil
    --所有的面板集合
    this.gamePanels = {}
    --当前菜单的游戏类型
    this.menuGameType = nil
    --参数
    this.args = nil
end

--UI初始化
function CreateRoomPanel:OnInitUI()
    this = self
    this:InitProperty()

    local content = this:Find("Content")

    this.closeBtn = content:Find("Background/CloseBtn").gameObject

    this.gameTypeContent = content:Find("Menus/Viewport/Content")
    this.gameTypeRectTransform = this.gameTypeContent:GetComponent(TypeRectTransform)
    local menus2 = content:Find("Menus2")
    this.childMenuItemPrefab = menus2:Find("Item").gameObject
    local count = this.gameTypeContent.childCount
    local childMenu = nil
    for i = 0, count - 1 do
        local item = {}
        item.transform = this.gameTypeContent:GetChild(i)
        item.gameObject = item.transform.gameObject
        item.toggle = item.gameObject:GetComponent(TypeToggle)
        item.gameType = tonumber(item.gameObject.name)
        --
        table.insert(this.gameTypeItems, item)
        this.gameTypeItemDict[item.gameType] = item
        --处理子菜单
        item.list = {}
        childMenu = menus2:Find(item.gameType)
        if childMenu ~= nil then
            item.childMenuGameObject = childMenu.gameObject
            local childMenuContent = childMenu:Find("Viewport/Content")
            local toggleGroup = childMenuContent:GetComponent(TypeToggleGroup)
            local menuConfigList = MenuConfigs[item.gameType]
            if menuConfigList ~= nil then
                for j = 1, #menuConfigList do
                    local tempConfig = menuConfigList[j]
                    local childItem = {}
                    childItem.gameObject = CreateGO(this.childMenuItemPrefab, childMenuContent, tempConfig.index)
                    --由于有特殊处理，所以用名称来匹配
                    childItem.name = tempConfig.name
                    childItem.transform = childItem.gameObject.transform
                    childItem.toggle = childItem.gameObject:GetComponent(TypeToggle)
                    childItem.toggle.group = toggleGroup
                    childItem.tag = childItem.transform:Find("ConfigTag").gameObject
                    --设置显示文本
                    local label = childItem.transform:Find("Label"):GetComponent(TypeText)
                    label.text = tempConfig.name
                    label = childItem.transform:Find("Label2"):GetComponent(TypeText)
                    label.text = tempConfig.name
                    --
                    table.insert(item.list, childItem)
                end
            end
        end
    end
    -----------------------------------
    --游戏
    this.gameNode = content:Find("Game")

    --处理消耗
    this.consumeTrans = content:Find("Consume")
    this.consumeGO = this.consumeTrans.gameObject
    this.consumeTxt = this.consumeTrans:Find("Text"):GetComponent(TypeText)
    --
    this.AddUIListenerEvent()
end

--参数args格式
-- fromType = RoomType.Club
-- funcType = CreateRoomFuncType.OneKey
-- args = {
--     groupId = 10001,--组织ID
--     score = 100,--茶馆分数
--     isOpen = false,--茶馆开启底分场
--     menuHelper = nil, --菜单帮助
--     [GameType.Mahjong] = {
--         [7] = { option = '{"DGH":0,"NPT":4,"NP":1,"NCT":13,"NB":0,"NGT":8,"JGD":1,"NCC":0,"NM":3,"DPPH":1,"NFT":3,"NDQ":1,"HD":1,"NPWT":7}', key = "" }
--     }
-- }
--key = "", score = 100, isOpen = false
--key为玩法的，score为茶馆底分，isOpen为茶馆的配置开启状态
function CreateRoomPanel:OnOpened(gameType, roomType, moneyType, args)
    if gameType == nil then
        this.openGameType = GameType.Mahjong
    else
        this.openGameType = gameType
    end
    --Log("CreateRoomPanel:OnOpened-->", gameType, roomType, moneyType)
    if roomType == nil then
        this.roomType = RoomType.Lobby
    else
        this.roomType = roomType
    end

    if moneyType == nil then
        this.moneyType = MoneyType.Fangka
    else
        this.moneyType = moneyType
    end

    this.args = args
    if this.args == nil then
        this.args = {}
    end

    --UIUtil.SetActive(this.consumeTrans, this.moneyType == MoneyType.Fangka)
    this.consumeTxt.text = "0"
    this.AddListenerEvent()
    this.args.menuToggleDict = this.gameTypeItemDict
    this.CheckMenuDisplayByRoomType()
    this.UpdateMenu()
    --
    this.gameTypeRectTransform.anchoredPosition = Vector2(0, 0)
end

--当面板关闭时调用
function CreateRoomPanel:OnClosed()
    CreateRoomPanel.Instance = nil
    this.RemoveListenerEvent()
    this.HideCurrChildMenuList()
    this.menuGameType = nil
    this.CloseCurrGamePanel()
end

--
function CreateRoomPanel.AddListenerEvent()
    AddEventListener(CMD.Game.UpdateCreateRoomConsume, this.OnUpdateCreateRoomConsume)
end

--
function CreateRoomPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.UpdateCreateRoomConsume, this.OnUpdateCreateRoomConsume)
end

--UI相关事件
function CreateRoomPanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    --菜单按钮
    for i = 1, #this.gameTypeItems do
        local item = this.gameTypeItems[i]
        item.toggle.onValueChanged:AddListener(function(isOn) this.OnMenuClick(item, isOn) end)
    end
end

------------------------------------------------------------------
--
--关闭
function CreateRoomPanel.Close()
    PanelManager.Close(PanelConfig.CreateRoom)
end

--关闭当前游戏面板
function CreateRoomPanel.CloseCurrGamePanel()
    if this.gamePanel ~= nil then
        this.gamePanel:OnClosed()
        UIUtil.SetActive(this.gamePanel.gameObject, false)
        this.gamePanel = nil
    end
end

------------------------------------------------------------------
--
--检测菜单显示，通过房间类型
function CreateRoomPanel.CheckMenuDisplayByRoomType()
    --先标记所有菜单显示
    local item = nil
    for i = 1, #this.gameTypeItems do
        item = this.gameTypeItems[i]
        item.isActive = true
    end
    --
    if this.roomType == RoomType.Lobby then
        this.CheckHideMenu(GameType.Pin5)
        this.CheckHideMenu(GameType.Pin3)
        this.CheckHideMenu(GameType.PaoDeKuai)
        this.CheckHideMenu(GameType.ErQiShi)
        this.CheckHideMenu(GameType.TP)
        this.CheckHideMenu(GameType.LYC)
    end

    this.CheckHideMenu(GameType.TP)
end

function CreateRoomPanel.CheckHideMenu(gameType)
    local item = this.gameTypeItemDict[gameType]
    if item ~= nil then
        item.isActive = false
        UIUtil.SetActive(item.gameObject, false)
    end
end

------------------------------------------------------------------
--
function CreateRoomPanel.OnCloseBtnClick()
    this.Close()
end

--隐藏当前子菜单列表
function CreateRoomPanel.HideCurrChildMenuList()
    if this.menuGameType ~= nil then
        local item = this.gameTypeItemDict[this.menuGameType]
        if item ~= nil and item.childMenuGameObject ~= nil then
            UIUtil.SetActive(item.childMenuGameObject, false)
        end
    end
end

--显示当前子菜单列表
function CreateRoomPanel.ShowCurrChildMenuList()
    if this.menuGameType ~= nil then
        local item = this.gameTypeItemDict[this.menuGameType]
        if item ~= nil and item.childMenuGameObject ~= nil then
            UIUtil.SetActive(item.childMenuGameObject, true)
        end
    end
end

--菜单点击
function CreateRoomPanel.OnMenuClick(item, isOn)
    if isOn then
        local gameType = item.gameType
        if this.menuGameType == gameType then
            return
        end
        this.CloseCurrGamePanel()
        this.HideCurrChildMenuList()
        --
        this.menuGameType = gameType
        this.gamePanel = this.gamePanels[this.menuGameType]
        if this.gamePanel == nil then
            local config = PanelConfigs[this.menuGameType]
            if config == nil then
                Alert.Show("游戏错误")
                this.Close()
                return
            end
            config.gameType = gameType
            this.CreateNodePanel(config)
            this.gamePanel = this.gamePanels[this.menuGameType]
        end
        if this.gamePanel ~= nil then
            this.ShowCurrChildMenuList()
            UIUtil.SetActive(this.gamePanel.gameObject, true)
            this.gamePanel:OnOpened(this.roomType, this.moneyType, this.args)
        end
    end
end

--获取创建面板脚本对象
function CreateRoomPanel.GetCreatePanel(gameObject, panelName)
    local panel = GetLuaComponent(gameObject, panelName)
    if panel == nil then
        panel = AddLuaComponent(gameObject, panelName)
    end
    return panel
end

--创建面板节点
function CreateRoomPanel.CreateNodePanel(config)
    local asset = ResourcesManager.LoadPrefabBySynch(BundleName.Panel, config.prefab)
    if this.menuGameType == config.gameType then
        if this.gamePanels[this.menuGameType] == nil then
            local go = NewObject(asset, this.gameNode)
            go.name = config.panel
            local trans = go.transform
            trans.localScale = Vector3.one
            trans.localRotation = Quaternion.Euler(0, 0, 0)

            this.gamePanel = this.GetCreatePanel(go, config.panel)
            this.gamePanels[this.menuGameType] = this.gamePanel
        end
    end
end

--更新钻石
function CreateRoomPanel.OnUpdateCreateRoomConsume(consume)
    this.consumeTxt.text = tostring(consume)
end

------------------------------------------------------------------
--
--更新菜单显示
function CreateRoomPanel.UpdateMenu()
    local length = #this.gameTypeItems
    local tempItem = nil
    local item = nil
    for i = 1, length do
        item = this.gameTypeItems[i]
        if tempItem == nil then
            tempItem = item
        end
    end

    local menu = this.gameTypeItemDict[this.openGameType]
    if menu == nil then
        menu = tempItem
    end

    local type = tonumber(this.args.type)
    if IsNil(type) then
        type = 1
    end

    --1:创建房间 2:修改规则
    if type == 1 then
        for i = 1, length do
            item = this.gameTypeItems[i]
            if item.isActive then
                UIUtil.SetActive(item.gameObject, true)
            end
        end
    elseif type == 2 then
        for i = 1, length do
            item = this.gameTypeItems[i]
            if item.isActive then
                if item == menu then
                    UIUtil.SetActive(item.gameObject, true)
                else
                    UIUtil.SetActive(item.gameObject, false)
                end
            end
        end
    end

    if menu ~= nil then
        menu.toggle.isOn = false
        menu.toggle.isOn = true
    end
end
