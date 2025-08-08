UnionMemberChangePanel = ClassPanel("UnionMemberChangePanel")
local this = UnionMemberChangePanel

function UnionMemberChangePanel:OnInitUI()
    this = self

    this.closeBtn = this:Find("Content/Background/CloseBtn").gameObject

    local content = this:Find("Content")

    this.input = content:Find("InputField"):GetComponent(TypeInputField)
    this.okBtn = content:Find("OkBtn").gameObject

    this.AddUIEventListener()
end

function UnionMemberChangePanel:OnOpened(userId)
    this.AddEventListener()
    this.userId = userId
    this.input.text = ""
end

function UnionMemberChangePanel:OnClosed()
    this.RemoveEventListener()
end

------------------------------------------------------------------
--
--注册事件
function UnionMemberChangePanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_MemberChange, this.OnMemberChange)
end

--移除事件
function UnionMemberChangePanel.RemoveEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_MemberChange, this.OnMemberChange)
end

--UI相关事件
function UnionMemberChangePanel.AddUIEventListener()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)
end

--================================================================
--
--关闭
function UnionMemberChangePanel.Close()
    PanelManager.Destroy(PanelConfig.UnionMemberChange)
end

--================================================================
--
--
function UnionMemberChangePanel.OnCloseBtnClick()
    this.Close()
end
--
--
function UnionMemberChangePanel.OnOkBtnClick()
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
    UnionManager.SendMemberChange(this.userId, temp)
end

--================================================================
--
function UnionMemberChangePanel.OnMemberChange(data)
    if data.code == 0 then
        Toast.Show("转移成员完成")
        SendEvent(CMD.Game.UnionRefreshMyMember)
        this.Close()
    else
        UnionManager.ShowError(data.code)
    end
end