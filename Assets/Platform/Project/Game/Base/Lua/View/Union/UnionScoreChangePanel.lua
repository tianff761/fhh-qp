UnionScoreChangePanel = ClassPanel("UnionScoreChangePanel")
UnionScoreChangePanel.maxLen = 0
UnionScoreChangePanel.callback = nil
UnionScoreChangePanel.gridLayout = nil
UnionScoreChangePanel.tempItem = nil
UnionScoreChangePanel.joinUnionTitle = nil
UnionScoreChangePanel.addPartnerTitle = nil
UnionScoreChangePanel.addMemberTitle = nil

local totalWidth = 500
local height = 48
local this = UnionScoreChangePanel
--UI初始化
function UnionScoreChangePanel:OnInitUI()
    this = self
    this.btnItems = {}
    this.closeBtn = self:Find("Content/Background/CloseBtn")

    --给按钮添加点击事件
    local nodeTrans = self:Find("Content/Node")
    this.tempItem = nodeTrans:Find("Item").gameObject

    this.ScoreText = this.tempItem.transform:Find("Text"):GetComponent(TypeText)

    this.input = nodeTrans:Find("InputField"):GetComponent(TypeInputField)

    --按钮
    local btnsTrans = nodeTrans:Find("Btns")
    for i = 1, 9 do
        this.btnItems[i] = btnsTrans:Find(tostring(i)).gameObject
    end
    table.insert(this.btnItems, btnsTrans:Find("0").gameObject)
    table.insert(this.btnItems, btnsTrans:Find("-").gameObject)
    table.insert(this.btnItems, btnsTrans:Find(".").gameObject)
    table.insert(this.btnItems, nodeTrans:Find("ClearBtn").gameObject)
    table.insert(this.btnItems, nodeTrans:Find("DeleteBtn").gameObject)
    table.insert(this.btnItems, nodeTrans:Find("ConfirmBtn").gameObject)

    this.AddUIListenerEvent()
    this.ConfirmCallback = function()
        UnionManager.SendSetScore(this.adjustUid, this.AdjustScore)
    end
end

function UnionScoreChangePanel:OnOpened(uid)
    --输入
    this.adjustUid = uid
    this.ClearNums()
    this.AddListenerEvent()
end

function UnionScoreChangePanel:OnClosed()
    this.RemoveListenerEvent()
    this.ClearNums()
end

--================================================================
--关闭
--
function UnionScoreChangePanel.AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_Union_SetScore, this.OnTcpSetScore)
    AddEventListener(CMD.Tcp.Union.S2C_REQUEST_PLAYER_INFO, this.ResponsePlayerInfo)
end
--
function UnionScoreChangePanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Tcp.Union.S2C_Union_SetScore, this.OnTcpSetScore)
    RemoveEventListener(CMD.Tcp.Union.S2C_REQUEST_PLAYER_INFO, this.ResponsePlayerInfo)
end

--UI相关事件
function UnionScoreChangePanel.AddUIListenerEvent()
    local length = this.btnItems
    for i = 1, #length do
        UIClickListener.Get(this.btnItems[i]).onClick = this.OnBtnClick
    end
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

--================================================================
function UnionScoreChangePanel.OnBtnClick(listener)
    Audio.PlayClickAudio()
    this.InputNumClick(listener.name)
end

function UnionScoreChangePanel:OnCloseBtnClick()
    this:Close()
end

--================================================================
function UnionScoreChangePanel.InputNumClick(name)
    if name == "ClearBtn" then
        this.ClearNums()
    elseif name == "DeleteBtn" then
        this.DeleteNum()
    elseif name == "ConfirmBtn" then
        this.OnConfirmBtnClick()
    else
        this.InputNum(name)
    end
end

function UnionScoreChangePanel.InputNum(name)
    this.ScoreText.text = this.ScoreText.text .. name
end

function UnionScoreChangePanel.OnConfirmBtnClick()
    local value = tonumber(this.input.text)
    if IsNumber(value) then
        UnionManager.RequestPlayerInfo(this.adjustUid)
        this.AdjustScore = value
    else
        Toast.Show("请输入正确的分数")
    end
end

function UnionScoreChangePanel.DeleteNum()
    local label = this.ScoreText.text
    this.ScoreText.text = string.sub(label, 1, string.len(label) - 1)
end

function UnionScoreChangePanel.ClearNums()
    this.ScoreText.text = ""
end

function UnionScoreChangePanel.OnTcpSetScore(data)
    if data.code == 0 then
        Toast.Show("分数调整成功")
        SendEvent(CMD.Game.UnionSetScoreRefresh)
        this:Close()
    else
        UnionManager.ShowError(data.code)
    end
end

--返回玩家信息
---@param data table playId  "玩家id" --name 名字 --icon 头像
function UnionScoreChangePanel.ResponsePlayerInfo(data)
    if data.code == 0 then
        PanelManager.Open(PanelConfig.UnionSetScoreNotice, data.data, this.AdjustScore, this.ConfirmCallback)
    else
        UnionManager.ShowError(data.code)
    end
end