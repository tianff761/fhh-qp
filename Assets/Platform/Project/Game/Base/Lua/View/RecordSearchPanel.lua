RecordSearchPanel = ClassPanel("RecordSearchPanel")

local this = RecordSearchPanel

function RecordSearchPanel:Awake()
    this = self

    local node = this:Find("Node")

    this.closeBtn = node:Find("Background/CloseBtn").gameObject

    this.inputField = node:Find("InputField"):GetComponent(TypeInputField)

    this.roomIdToggle = node:Find("RoomID"):GetComponent(TypeToggle)
    this.playerIdToggle = node:Find("PlayerID"):GetComponent(TypeToggle)

    this.clearBtn = node:Find("ClearBtn").gameObject
    this.okBtn = node:Find("OkBtn").gameObject

    this:AddOnClick(this.closeBtn, this.OnClickCloseBtn)
    this:AddOnClick(this.clearBtn, this.OnClearBtnClick)
    this:AddOnClick(this.okBtn, this.OnClickOkBtn)
    UIToggleListener.AddListener(this.roomIdToggle.gameObject, this.OnRoomIdToggleValueChanged)
    UIToggleListener.AddListener(this.playerIdToggle.gameObject, this.OnPlayerIdToggleValueChanged)
end

function RecordSearchPanel:OnOpened(args)
    if UnionData.searchType == 1 then
        this.roomIdToggle.isOn = true
    else
        this.playerIdToggle.isOn = true
    end
    this.inputField.text = UnionData.searchId
end

function RecordSearchPanel:OnClosed()

end

function RecordSearchPanel.OnClickCloseBtn()
    this.Close()
end

function RecordSearchPanel.Close()
    PanelManager.Close(PanelConfig.RecordSearch)
end

function RecordSearchPanel.OnClearBtnClick()
    if this.roomIdToggle.isOn then
        UnionData.searchType = 1
    else
        UnionData.searchType = 2
    end
    UnionData.searchId = ""
    SendEvent(CMD.Game.UnionUpdateSearchRecord)
    this.Close()
end

function RecordSearchPanel.OnClickOkBtn()
    local inputValue = this.inputField.text
    local value = tonumber(inputValue)
    if value ~= nil then
        if this.roomIdToggle.isOn then
            UnionData.searchType = 1
        else
            UnionData.searchType = 2
        end
        UnionData.searchId = inputValue
        SendEvent(CMD.Game.UnionUpdateSearchRecord)
        this.Close()
    else
        Toast.Show("请输入正确的房间号或玩家ID")
    end
end

function RecordSearchPanel.OnRoomIdToggleValueChanged(isOn, listener)
    if isOn then

    end
end

function RecordSearchPanel.OnPlayerIdToggleValueChanged(isOn, listener)
    if isOn then

    end
end