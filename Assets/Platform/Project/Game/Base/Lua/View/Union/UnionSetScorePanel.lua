--调整分数
UnionSetScorePanel = ClassPanel("UnionSetScorePanel")
--调整的玩家Id
UnionSetScorePanel.adjustUid = 0

local this = UnionSetScorePanel
--
function UnionSetScorePanel:Awake()
    this = self
    this.closeBtn = this:Find("Content/Background/CloseBtn")
    this.okBtn = this:Find("Content/Content/OkBtn")
    this.input = this:Find("Content/Content/InputField"):GetComponent(TypeInputField)
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)
end

function UnionSetScorePanel:OnOpened(uid)
    this.AddEventListener()
    this.adjustUid = uid
    this.input.text = ""
end

function UnionSetScorePanel:OnClosed()
    this.RemoveEventListener()
end

--注册事件
function UnionSetScorePanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_Union_SetScore, this.OnTcpSetScore)
end

--移除事件
function UnionSetScorePanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_Union_SetScore, this.OnTcpSetScore)
end

--================================================================
--
--关闭
function UnionSetScorePanel.Close()
    PanelManager.Close(PanelConfig.UnionSetScore)
end
--================================================================
--
function UnionSetScorePanel.OnCloseBtnClick()
    this.Close()
end

function UnionSetScorePanel.OnOkBtnClick()
    local value = tonumber(this.input.text)
    if IsNumber(value) then
        UnionManager.SendSetScore(this.adjustUid, value)
    else
        Toast.Show("请输入正确的分数")
    end
end

--================================================================
--
function UnionSetScorePanel.OnTcpSetScore(data)
    if data.code == 0 then
        Toast.Show("分数调整成功")
        SendEvent(CMD.Game.UnionSetScoreRefresh)
        this.Close()
    else
        UnionManager.ShowError(data.code)
    end
end