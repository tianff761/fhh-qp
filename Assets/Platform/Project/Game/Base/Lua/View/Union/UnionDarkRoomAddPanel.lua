UnionDarkRoomAddPanel = ClassPanel("UnionDarkRoomAddPanel")
local this = UnionDarkRoomAddPanel

function UnionDarkRoomAddPanel:Awake()
    this = self
    this.sendTime = 0
    --
    local content = this:Find("Content")
    this.closeBtn = content:Find("Background/CloseBtn")
    this.input = content:Find("InputField"):GetComponent(TypeInputField)
    this.addPlayerBtn = content:Find("AddPlayerBtn").gameObject
    this.addGroupBtn = content:Find("AddGroupBtn").gameObject

    this.AddUIListenerEvent()
end

function UnionDarkRoomAddPanel:OnOpened(args)
    this.AddListenerEvent()
    this.groupId = args
end

function UnionDarkRoomAddPanel:OnClosed()
    this.RemoveListenerEvent()

end

function UnionDarkRoomAddPanel.AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_UNION_ADD_BLACK_HOUSE, this.OnAddBlackHousePlayer)
    AddEventListener(CMD.Tcp.Union.S2C_UNION_ADD_BLACK_HOUSE_ALL, this.OnAddBlackHousePlayerAll)
end

--
function UnionDarkRoomAddPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_ADD_BLACK_HOUSE, this.OnAddBlackHousePlayer)
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_ADD_BLACK_HOUSE_ALL, this.OnAddBlackHousePlayerAll)
end

function UnionDarkRoomAddPanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.addPlayerBtn, this.OnAddPlayerBtnClick)
    this:AddOnClick(this.addGroupBtn, this.OnAddGroupBtnClick)
end

--================================================================
--
function UnionDarkRoomAddPanel.OnCloseBtnClick()
    this.Close()
end

--
function UnionDarkRoomAddPanel.OnAddPlayerBtnClick()
    local userId = tonumber(this.input.text)
    if string.IsNullOrEmpty(userId) then
        Alert.Show("请输入正确的玩家ID")
        return
    end
    if this.sendTime > Time.realtimeSinceStartup then
        Toast.Show("请稍后...")
        return
    end
    this.sendTime = Time.realtimeSinceStartup + 2
    UnionManager.SendAddBlackHousePlayer(this.groupId, 0, userId)
end

--
function UnionDarkRoomAddPanel.OnAddGroupBtnClick()
    local userId = tonumber(this.input.text)
    if string.IsNullOrEmpty(userId) then
        Alert.Show("请输入正确的玩家ID")
        return
    end
    if this.sendTime > Time.realtimeSinceStartup then
        Toast.Show("请稍后...")
        return
    end
    this.sendTime = Time.realtimeSinceStartup + 2
    UnionManager.SendAddBlackHousePlayerAll(this.groupId, 0, userId)
end

--================================================================
--
--
function UnionDarkRoomAddPanel.OnAddBlackHousePlayer(msgObj)
    --LogError(msgObj)
    this.sendTime = 0
    if msgObj.code == 0 then
        --直接关闭，因为小黑屋关系组界面已经监听处理
        this.Close()
    else
        UnionManager.ShowError(msgObj.code)
    end
end

--
function UnionDarkRoomAddPanel.OnAddBlackHousePlayerAll(msgObj)
    --LogError(msgObj)
    this.sendTime = 0
    if msgObj.code == 0 then
        SendEvent(CMD.Game.UnionUpdateBlackHouseGroup)
        this.Close()
    else
        UnionManager.ShowError(msgObj.code)
    end
end
--================================================================
--
--
function UnionDarkRoomAddPanel.Close()
    PanelManager.Close(PanelConfig.UnionDarkRoomAdd)
end

--================================================================
--