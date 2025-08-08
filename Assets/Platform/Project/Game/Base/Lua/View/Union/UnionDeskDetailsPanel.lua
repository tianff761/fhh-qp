UnionDeskDetailsPanel = ClassPanel("UnionDeskDetailsPanel")

local this = UnionDeskDetailsPanel

function UnionDeskDetailsPanel:Awake()
    this = self
    this.playerItems = {}

    local content = this:Find("Content")
    this.closeBtn = content:Find("Background/CloseBtn")

    local node = content:Find("Node")

    this.playerContent = node:Find("Player")
    this.playerItemPrefab = this.playerContent:Find("Item").gameObject
    this.noPlayerGo = node:Find("NoPlayer").gameObject

    this.scrollViewRectTransform = node:Find("ScrollView"):GetComponent(TypeRectTransform)
    this.scrollViewWidth = this.scrollViewRectTransform.sizeDelta.x

    local tempContent = node:Find("ScrollView/Viewport/Content")
    this.roomIdLabel = tempContent:Find("Line1/RoomIDText"):GetComponent(TypeText)
    this.juShuLabel = tempContent:Find("Line1/JuShuText"):GetComponent(TypeText)
    this.ruleLabel = tempContent:Find("RuleText"):GetComponent(TypeText)
    this.ruleRectTransform = this.ruleLabel:GetComponent(TypeRectTransform)
    this.ruleWidth = this.ruleRectTransform.sizeDelta.x

    local btns = node:Find("Btns")
    this.removeBtn = btns:Find("RemoveBtn").gameObject
    this.dismissBtn = btns:Find("DismissBtn").gameObject
    this.ModifyBtn = btns:Find("ModifyBtn").gameObject

    this:AddOnClick(this.removeBtn, this.OnRemoveBtnClick)
    this:AddOnClick(this.dismissBtn, this.OnDismissBtnClick)
    this:AddOnClick(this.ModifyBtn, this.OnModifyBtnClick)
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

function UnionDeskDetailsPanel:OnOpened(data)
    --data.id, data.gameType, data.rules
    this.AddEventListener()

    this.tableData = data
    this.tableId = data.id
    this.gameType = data.gameType
    --LogError("data.rules", data.rules)
    this.rules = CopyTable(data.rules, true)
    --LogError("this.rules", this.rules)
    --LogError("<color=aqua>data</color>", data)
    --LogError("<color=aqua>this.rules</color>", this.rules)
    --LogError("<color=aqua>this.gameType</color>", this.gameType)
    local ruleObj = Functions.ParseGameRule(this.gameType, data.rules, nil, nil, data.advanceData.bdPer, data.advanceData.faceType)

    --LogError("<color=aqua>ruleObj</color>", ruleObj)
    this.playWayName = ruleObj.playWayName

    this.roomIdLabel.text = tostring(ruleObj.playWayName)
    this.juShuLabel.text = tostring(ruleObj.juShuTxt)
    this.ruleLabel.text = tostring(ruleObj.rule)
    this.ruleRectTransform.sizeDelta = Vector2(this.ruleWidth, this.ruleLabel.preferredHeight)

    if UnionData.IsUnionLeaderOrAdministratorOrObserver() then
        UIUtil.SetActive(this.removeBtn, true)
        UIUtil.SetActive(this.ModifyBtn, true)
        if data.userDatas ~= nil and #data.userDatas > 0 then
            UIUtil.SetActive(this.dismissBtn, true)
        else
            UIUtil.SetActive(this.dismissBtn, false)
        end
        this.scrollViewRectTransform.anchoredPosition = Vector2(0, 0)
        this.scrollViewRectTransform.sizeDelta = Vector2(this.scrollViewWidth, 360)
    else
        UIUtil.SetActive(this.removeBtn, false)
        UIUtil.SetActive(this.ModifyBtn, false)
        UIUtil.SetActive(this.dismissBtn, false)
        this.scrollViewRectTransform.anchoredPosition = Vector2(0, -30)
        this.scrollViewRectTransform.sizeDelta = Vector2(this.scrollViewWidth, 420)
    end

    -- if data.userDatas ~= nil and #data.userDatas > 0 then
    --     UIUtil.SetActive(this.noPlayerGo, false)
    --     this.UpdateDisplayPlayer(data.userDatas)
    -- else
    --     UIUtil.SetActive(this.noPlayerGo, true)
    -- end
end

function UnionDeskDetailsPanel:OnClosed()
    this.RemoveEventListener()
end

--注册事件
function UnionDeskDetailsPanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_DeleteTable, this.OnTcpDeleteTable)
    AddEventListener(CMD.Tcp.Union.S2C_DeskDismiss, this.OnDeskDismiss)
    AddEventListener(CMD.Tcp.Union.S2C_DeskKick, this.OnDeskKick)
end

--移除事件
function UnionDeskDetailsPanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_DeleteTable, this.OnTcpDeleteTable)
    RemoveEventListener(CMD.Tcp.Union.S2C_DeskDismiss, this.OnDeskDismiss)
    RemoveEventListener(CMD.Tcp.Union.S2C_DeskKick, this.OnDeskKick)
end

--================================================================
--
--关闭
function UnionDeskDetailsPanel.Close()
    PanelManager.Close(PanelConfig.UnionDeskDetails)
end
--================================================================
--
--删除桌子
function UnionDeskDetailsPanel.OnRemoveBtnClick()
    Alert.Prompt("是否删除桌子？", this.OnDeleteAlertCallback)
end

function UnionDeskDetailsPanel.OnModifyBtnClick()
    local args = {
        type = 2, -- 1创建桌子，2修改桌子
        unionCallback = this.OnDealCreateOrModifyRoom,
        playWayName = this.playWayName,
        rules = this.rules,
        advanceData = this.tableData.advanceData,
    }
    if this.gameType == GameType.SDB then
        Toast.Show("功能暂未开放")
        return
    end
    PanelManager.Open(PanelConfig.CreateRoom, this.gameType, RoomType.Tea, MoneyType.Gold, args)
end

--修改桌子回调
function UnionDeskDetailsPanel.OnDealCreateOrModifyRoom(type, args)
    if type == nil or args == nil then
        Toast.Show("参数异常")
        return
    end
    Log("OnDealCreateOrModifyRoom", this.curModifyTableId, type, args)
    if type == 2 then
        UnionManager.SendModifyTable(args.gameId, args.playType, args.rules, args.maxRoundCount, args.maxPlayerCount,
                args.baseScore, args.inGold, args.jieSanFenShu, args.note, args.wins, args.consts, args.baoDi, args.feetype, args.bigwin, args.per, this.tableId, args.bdPer, args.faceType)
    end
end

--解散房间
function UnionDeskDetailsPanel.OnDismissBtnClick()
    Alert.Prompt("是否解散房间？", this.OnDismissAlertCallback)
end

function UnionDeskDetailsPanel.OnCloseBtnClick()
    this.Close()
end

function UnionDeskDetailsPanel.OnDeleteAlertCallback()
    UnionManager.SendDeleteTable(this.gameType, this.tableId)
end

function UnionDeskDetailsPanel.OnDismissAlertCallback()
    UnionManager.SendDeskDismiss(this.tableId)
end

--================================================================
--
function UnionDeskDetailsPanel.UpdateDisplayPlayer(userDatas)
    local length = #userDatas
    local item = nil
    local data = nil
    for i = 1, length do
        data = userDatas[i]
        item = this.playerItems[i]
        if item == nil then
            item = this.CteatePlayerItem(i)
        end
        UIUtil.SetActive(item.gameObject, true)
        item.data = data
        if item.tempIcon ~= data.headIcon then
            item.tempIcon = data.headIcon
            Functions.SetHeadImage(item.headIcon, data.headIcon)
        end
        item.nameLabel.text = tostring(data.name)
        item.idLabel.text = tostring(data.uid)
        if data.isOnline then
            UIUtil.SetActive(item.offline, false)
        else
            UIUtil.SetActive(item.offline, true)
        end
    end

    for i = length + 1, #this.playerItems do
        item = this.playerItems[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

function UnionDeskDetailsPanel.CteatePlayerItem(index)
    local item = {}
    item.gameObject = CreateGO(this.playerItemPrefab, this.playerContent, tostring(index))
    item.transform = item.gameObject.transform
    item.headBg = item.transform:Find("HeadBg").gameObject
    item.headIcon = item.transform:Find("Head/Icon"):GetComponent(TypeImage)
    item.nameLabel = item.transform:Find("NameText"):GetComponent(TypeText)
    item.idLabel = item.transform:Find("IdText"):GetComponent(TypeText)
    item.offline = item.transform:Find("Offline").gameObject
    item.data = nil
    table.insert(this.playerItems, item)
    UIClickListener.Get(item.headBg).onClick = function()
        this.OnPlayerClick(item)
    end
    return item
end

function UnionDeskDetailsPanel.OnPlayerClick(item)
    this.playerId = item.data.uid
    Alert.Prompt("是否把玩家【" .. item.data.name .. "】踢出房间？", this.OnKickAlertCallback)
end

function UnionDeskDetailsPanel.OnKickAlertCallback()
    UnionManager.SendDeskKick(this.tableId, this.playerId)
end

--================================================================
--
function UnionDeskDetailsPanel.OnTcpDeleteTable(data)
    if data.code == 0 then
        Toast.Show("删除桌子成功")
        SendEvent(CMD.Game.UnionDeleteTableRefresh)
        this.Close()
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionDeskDetailsPanel.OnDeskDismiss(data)
    if data.code == 0 then
        Toast.Show("解散房间成功")
        SendEvent(CMD.Game.UnionDeleteTableRefresh)
        this.Close()
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionDeskDetailsPanel.OnDeskKick(data)
    if data.code == 0 then
        Toast.Show("踢出玩家成功")
        SendEvent(CMD.Game.UnionDeleteTableRefresh)
        this.Close()
    else
        UnionManager.ShowError(data.code)
    end
end