UnionPartnerChangePanel = ClassPanel("UnionPartnerChangePanel")
local this = UnionPartnerChangePanel

function UnionPartnerChangePanel:OnInitUI()
    this = self

    this.closeBtn = this:Find("Content/Background/CloseBtn").gameObject

    local content = this:Find("Content")

    this.input = content:Find("InputField"):GetComponent(TypeInputField)
    this.okBtn = content:Find("OkBtn").gameObject

    this.AddUIEventListener()
end

function UnionPartnerChangePanel:OnOpened(userId)
    this.AddEventListener()
    this.userId = userId
    this.input.text = ""
end

function UnionPartnerChangePanel:OnClosed()
    this.RemoveEventListener()
end

------------------------------------------------------------------
--
--注册事件
function UnionPartnerChangePanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_PartnerChange, this.OnPartnerChange)
end

--移除事件
function UnionPartnerChangePanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_PartnerChange, this.OnPartnerChange)
end

--UI相关事件
function UnionPartnerChangePanel.AddUIEventListener()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)
end

--================================================================
--
--关闭
function UnionPartnerChangePanel.Close()
    PanelManager.Destroy(PanelConfig.UnionPartnerChange)
end

--================================================================
--
--
function UnionPartnerChangePanel.OnCloseBtnClick()
    this.Close()
end
--
--
function UnionPartnerChangePanel.OnOkBtnClick()
    local temp = this.input.text
    if string.IsNullOrEmpty(temp) then
        Toast.Show("请输入接收人ID")
        return
    end
    temp = tonumber(temp)
    if temp == nil then
        Toast.Show("请输入正确的接收人ID")
        return
    end
    UnionManager.SendPartnerChange(this.userId, temp)
end

--================================================================
--
function UnionPartnerChangePanel.OnPartnerChange(data)
    if data.code == 0 then
        Toast.Show("转移小队完成")
        SendEvent(CMD.Game.UnionRefreshMyPartner)
        this.Close()
    else
        UnionManager.ShowError(data.code)
    end
end