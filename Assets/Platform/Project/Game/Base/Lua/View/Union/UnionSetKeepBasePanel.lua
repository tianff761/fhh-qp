--设置比例
UnionSetKeepBasePanel = ClassPanel("UnionSetKeepBasePanel")
--调整的玩家Id
UnionSetKeepBasePanel.adjustUid = 0

local this = UnionSetKeepBasePanel
--
function UnionSetKeepBasePanel:Awake()
    this = self
    this.closeBtn = this:Find("Content/Background/CloseBtn")

    this.okBtn = this:Find("Content/Content/OkBtn")
    this.input = this:Find("Content/Content/InputField"):GetComponent(TypeInputField)

    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)
end

function UnionSetKeepBasePanel:OnOpened(uid, gameId, key)
    this.AddEventListener()
    this.adjustUid = uid
    this.gameId = gameId
    this.input.text = key
end

function UnionSetKeepBasePanel:OnClosed()
    this.RemoveEventListener()
end

--注册事件
function UnionSetKeepBasePanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_AdjustKeepBasePercent, this.OnTcpAdjustKeepBase)
end

--移除事件
function UnionSetKeepBasePanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_AdjustKeepBasePercent, this.OnTcpAdjustKeepBase)
end

--================================================================
--
--关闭
function UnionSetKeepBasePanel.Close()
    PanelManager.Close(PanelConfig.UnionSetKeepBase)
end
--================================================================
--
function UnionSetKeepBasePanel.OnCloseBtnClick()
    this.Close()
end

function UnionSetKeepBasePanel.OnOkBtnClick()
    local value = tonumber(this.input.text)
    if IsNumber(value) then
        UnionManager.SendSetKeepBase(this.adjustUid, this.gameId, value)
    else
        Toast.Show("请输入正确的比例")
    end
end


--================================================================
--
--
function UnionSetKeepBasePanel.OnTcpAdjustKeepBase(data)
    if data.code == 0 then
        Toast.Show("比例调整成功")
        SendEvent(CMD.Game.UnionSetRatioRefresh)
        this.Close()
    else
        UnionManager.ShowError(data.code)
    end
end