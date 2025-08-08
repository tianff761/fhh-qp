ModifyRoomPanel = ClassPanel("ModifyRoomPanel")
local this = ModifyRoomPanel

local PanelConfigs = {
    [GameType.Mahjong] = { prefab = "ModifyRoomNodeMahjong", panel = "ModifyMahjongRoomPanel" },
    [GameType.ErQiShi] = { prefab = "ModifyRoomNodeEqs", panel = "ModifyEqsRoomPanel" },
    [GameType.PaoDeKuai] = { prefab = "ModifyRoomNodeLSPdk", panel = "ModifyLSPdkRoomPanel" },
    [GameType.Pin5] = { prefab = "ModifyRoomNodePin5", panel = "ModifyPin5RoomPanel" },
    [GameType.Pin3] = { prefab = "ModifyRoomNodePin3", panel = "ModifyPin3RoomPanel" },
    [GameType.SDB] = { prefab = "ModifyRoomNodeSDB", panel = "ModifySDBRoomPanel" },
    [GameType.LYC] = { prefab = "ModifyRoomNodeLYC", panel = "ModifyLYCRoomPanel" },
}

--初始属性数据
function ModifyRoomPanel:InitProperty()
    --打开创建游戏类型
    this.openGameType = GameType.Mahjong
    --房间类型 0大厅  1俱乐部 2联盟
    this.roomType = RoomType.Lobby
    --货币类型
    this.moneyType = MoneyType.Fangka
    --菜单Toggle
    this.menuToggleDict = {}
    --游戏面板
    this.gamePanel = nil
    --所有的面板集合
    this.gamePanels = {}
    --当前菜单的游戏类型
    this.menuGameType = nil
    --菜单辅助
    this.menuHelper = nil
    --参数
    this.args = nil
end

--UI初始化
function ModifyRoomPanel:OnInitUI()
    this = self
    this:InitProperty()

    local content = this:Find("Content")

    this.closeBtn = content:Find("Background/CloseBtn").gameObject

    this.gameTypeToggleList = content:Find("Menus/Viewport/ToggleList")
    this.menuHelper = UIToggleMenu:New()
    LogError("ModifyRoomPanel this.menuHelper", this.menuHelper)
    this.menuHelper:Init(this.gameTypeToggleList, 204, 90)
    -----------------------------------
    this.scrollRect = content:Find("Menus"):GetComponent(TypeScrollRect)
    this.scrollRectContent = this.scrollRect.content
    this.downImage = this.scrollRect.transform:Find("DownImage")
    ScrollRectHelper.New(this.scrollRect, this.downImage)
    -----------------------------------


    local length = #this.menuHelper.items
    local gameType = 0
    for i = 1, length do
        gameType = tonumber(this.menuHelper.items[i].gameObject.name)
        this.menuToggleDict[gameType] = this.menuHelper.items[i]
    end

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
function ModifyRoomPanel:OnOpened(gameType, roomType, moneyType, playWayName, args, rules, advanceData)
    if gameType == nil then
        this.openGameType = GameType.Mahjong
    else
        this.openGameType = gameType
    end
    --Log("ModifyRoomPanel:OnOpened-->", gameType, roomType, moneyType)
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

    this.playWayName = playWayName
    LogError("<color=aqua>this.playWayName</color>", this.playWayName)
    this.rules = rules
    LogError("rules", rules)
    this.advanceData = advanceData

    this.args = args
    if this.args == nil then
        this.args = {}
    end
    --UIUtil.SetActive(this.consumeTrans, this.moneyType == MoneyType.Fangka)
    this.consumeTxt.text = "0"
    this.AddListenerEvent()
    this.args.menuHelper = this.menuHelper
    this.args.menuToggleDict = this.menuToggleDict
    this.UpdateMenu()
    --this.HidePin5Pin3SDBByRoomType()

    local v3 = this.scrollRectContent.localPosition
    this.scrollRectContent.localPosition = Vector2(v3.x, 0)
end

function ModifyRoomPanel.HidePin5Pin3SDBByRoomType()
    if this.roomType == RoomType.Lobby then
        UIUtil.SetActive(this.menuToggleDict[GameType.Pin5].gameObject, false)
        UIUtil.SetActive(this.menuToggleDict[GameType.Pin3].gameObject, false)
        UIUtil.SetActive(this.menuToggleDict[GameType.SDB].gameObject, false)
    end
end

--当面板关闭时调用
function ModifyRoomPanel:OnClosed()
    ModifyRoomPanel.Instance = nil
    this.RemoveListenerEvent()
    this.menuGameType = nil
    this.CloseCurrGamePanel()
end


--关闭当前游戏面板
function ModifyRoomPanel.CloseCurrGamePanel()
    if this.gamePanel ~= nil then
        this.gamePanel:OnClosed()
        DestroyObj(this.gamePanel.gameObject)
        --UIUtil.SetActive(this.gamePanel.gameObject, false)
        this.gamePanel = nil
    end
end

--
function ModifyRoomPanel.AddListenerEvent()
    AddEventListener(CMD.Game.UpdateCreateRoomConsume, this.OnUpdateCreateRoomConsume)
end

--
function ModifyRoomPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.UpdateCreateRoomConsume, this.OnUpdateCreateRoomConsume)
end

--UI相关事件
function ModifyRoomPanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    --菜单按钮
    local item = nil
    local gameType = 0
    for i = 1, #this.menuHelper.items do
        item = this.menuHelper.items[i]
        gameType = tonumber(item.gameObject.name)
        item.toggle.onValueChanged:AddListener(HandlerByStaticArg1(this, this.OnMenuClick, i, gameType, item))
    end
end

------------------------------------------------------------------
--
function ModifyRoomPanel.OnCloseBtnClick()
    this:Close()
end

--菜单点击
function ModifyRoomPanel.OnMenuClick(panel, isOn, index, gameType, item)
    LogError("isOn", isOn)
    if isOn then
        --if this.menuGameType == gameType then
        --    return
        --end
        --this.CloseCurrGamePanel()
        --this.menuGameType = gameType
        --this.gamePanel = this.gamePanels[this.menuGameType]
        --if this.gamePanel == nil then
        local config = PanelConfigs[gameType]
        LogError("config.panel", config.panel)
        --    if config == nil then
        --        Alert.Show("游戏错误")
        --        this:Close()
        --        return
        --    end
        --    config.gameType = gameType
        this.CreateNodePanel(config)
        --else
        --    UIUtil.SetActive(this.gamePanel.gameObject, true)
        --    this.gamePanel:OnOpened(this.roomType, this.moneyType, this.args, true, this.playWayName, this.rules)
        --end
    end
    this.menuHelper:PlayAnim(isOn, item)
end

--获取创建面板脚本对象
function ModifyRoomPanel.GetCreatePanel(gameObject, panelName)
    local panel = GetLuaComponent(gameObject, panelName)
    if panel == nil then
        panel = AddLuaComponent(gameObject, panelName)
    end
    return panel
end

--创建面板节点
function ModifyRoomPanel.CreateNodePanel(config)
    local asset = ResourcesManager.LoadPrefabBySynch(BundleName.CreateRoom, config.prefab)
    --if this.menuGameType == config.gameType then
    --    if this.gamePanels[this.menuGameType] == nil then
    local go = NewObject(asset, this.gameNode)
    go.name = config.panel
    UIUtil.SetActive(go, true)
    local trans = go.transform
    trans.localScale = Vector3.one
    trans.localRotation = Quaternion.Euler(0, 0, 0)

    this.gamePanel = this.GetCreatePanel(go, config.panel)
    --this.gamePanels[this.menuGameType] = this.gamePanel
    --LogError("this.args", this.args)
    this.gamePanel:OnOpened(this.roomType, this.moneyType, this.args, true, this.playWayName, this.rules, this.advanceData)
    --end
    --end
end

--更新钻石
function ModifyRoomPanel.OnUpdateCreateRoomConsume(consume)
    this.consumeTxt.text = tostring(consume)
end

------------------------------------------------------------------
--
--更新菜单显示
function ModifyRoomPanel.UpdateMenu()
    local length = #this.menuHelper.items
    local tempItem = nil
    local item = nil
    --for i = 1, length do
    --    item = this.menuHelper.items[i]
    --    if item.isActive then
    --        item.toggle.isOn = false
    --        if tempItem == nil then
    --            tempItem = item
    --        end
    --    end
    --end

    local menu = this.menuToggleDict[this.openGameType]
    if menu == nil then
        menu = tempItem
    end

    local type = this.args.type
    if IsNil(type) then
        type = 1
    end
    --1:创建房间 2:修改规则
    if type == 1 then
        for i = 1, length do
            item = this.menuHelper.items[i]
            if item.isActive then
                UIUtil.SetActive(item.gameObject, true)
            end
        end
    elseif type == 2 then
        for i = 1, length do
            item = this.menuHelper.items[i]
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