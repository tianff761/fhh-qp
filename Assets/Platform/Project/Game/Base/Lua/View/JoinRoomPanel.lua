JoinRoomPanel = ClassPanel("JoinRoomPanel")

local this = JoinRoomPanel
local InputMax = 6

--UI初始化
function JoinRoomPanel:OnInitUI()
    this = self
    this.btnItems = {}
    this.inputItems = {}
    this.index = 0

    this.closeBtn = this:Find("Content/Background/CloseBtn").gameObject

    --给按钮添加点击事件
    local nodeTrans = this:Find("Content/Node")
    --按钮
    local btnsTrans = nodeTrans:Find("Btns")
    for i = 1, 9 do
        this.btnItems[i] = btnsTrans:Find(tostring(i)).gameObject
    end
    table.insert(this.btnItems, btnsTrans:Find("0").gameObject)
    table.insert(this.btnItems, btnsTrans:Find("ClearBtn").gameObject)
    table.insert(this.btnItems, btnsTrans:Find("DeleteBtn").gameObject)
    --输入
    local inputNumsTrans = nodeTrans:Find("InputNums")
    for i = 1, 6 do
        this.inputItems[i] = inputNumsTrans:Find("Item" .. tostring(i) .. "/Text"):GetComponent(TypeText)
    end

    this.AddUIListenerEvent()
end

function JoinRoomPanel:OnOpened()
    this.ClearNums()
    this.AddListenerEvent()
end

function JoinRoomPanel:OnClosed()
    this.RemoveListenerEvent()
end

function JoinRoomPanel:OnHide()
    this.ClearNums()
end

--================================================================
--关闭
function JoinRoomPanel.Close()
    PanelManager.Destroy(PanelConfig.JoinRoom, true)
end

--
function JoinRoomPanel.AddListenerEvent()
    AddEventListener(CMD.Game.CleanJoinRoomPanel, this.OnJoinRoomClear)
end

--
function JoinRoomPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.CleanJoinRoomPanel, this.OnJoinRoomClear)
end

--UI相关事件
function JoinRoomPanel.AddUIListenerEvent()
    local length = this.btnItems
    for i = 1, #length do
        UIClickListener.Get(this.btnItems[i]).onClick = this.OnBtnClick
    end
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

--================================================================
function JoinRoomPanel.OnBtnClick(listener)
    Audio.PlayClickAudio()
    this.InputNumClick(listener.name)
end

function JoinRoomPanel:OnCloseBtnClick()
    this.Close()
end

function JoinRoomPanel.OnJoinRoomClear()
    this.ClearNums()
end

--================================================================
function JoinRoomPanel.InputNumClick(name)
    if name == "ClearBtn" then
        this.ClearNums()
    elseif name == "DeleteBtn" then
        this.DeleteNum()
    else
        this.InputNum(name)
    end
end

function JoinRoomPanel.InputNum(name)
    if this.index < InputMax then
        this.index = this.index + 1
        this.inputItems[this.index].text = name
    end

    if this.index >= InputMax then
        local roomNum = tonumber(this.GetInputNum())
        BaseTcpApi.CheckAndJoinRoom(roomNum, false)
        this.ClearNums()
    end
end

function JoinRoomPanel.DeleteNum()
    if this.index > 0 and this.index <= InputMax then
        this.inputItems[this.index].text = ""
        this.index = this.index - 1
    end
end

function JoinRoomPanel.ClearNums()
    this.index = 0
    for i, txt in ipairs(this.inputItems) do
        txt.text = ""
    end
end

-- 返回string
function JoinRoomPanel.GetInputNum()
    local str = ""
    for i, txt in ipairs(this.inputItems) do
        str = str .. txt.text
    end
    return str
end
