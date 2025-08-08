InviteCodePanel = ClassPanel("InviteCodePanel")
InviteCodePanel.inviteCodeInputField = nil
InviteCodePanel.okBtn = nil
InviteCodePanel.cancelBtn = nil
InviteCodePanel.closeBtn = nil
InviteCodeErrorConfig = {
    [40009] = "邀请码已失效",
    [40010] = "邀请码对应大联盟不存在",
    [40030] = "邀请码对应大联盟不是默认联盟",
    [40031] = "邀请码使用失败",
    [40032] = "邀请码使用失败。",
}
local this = InviteCodePanel
--UI初始化
function InviteCodePanel:OnInitUI()
    this = self
    this.inviteCodeInputField = this:Find("Content/InviteCodeInputField")
    this.okBtn = this:Find("Content/OkBtn")
    this.cancelBtn = this:Find("Content/CancelBtn")
    this.closeBtn = this:Find("Content/Bgs/CloseBtn")
end

function InviteCodePanel:OnOpened()
    this:AddOnClick(this.okBtn, this.OnClickInviteBtn)
    this:AddOnClick(this.cancelBtn, this.OnClickCloseBtn)
    this:AddOnClick(this.closeBtn, this.OnClickCloseBtn)
    AddMsg(CMD.Tcp.S2C_InviteCode, this.OnTcpInviteCode)
end

function InviteCodePanel.OnClickInviteBtn()
    local numText = UIUtil.GetInputText(this.inviteCodeInputField)
    local num = tonumber(numText)

    if string.IsNullOrEmpty(numText) or numText == nil or num <= 0 then
        Toast.Show("邀请码输入错误")
        return 
    end
    SendTcpMsg(CMD.Tcp.C2S_InviteCode, {exclusiveKey = num})
end

function InviteCodePanel.OnTcpInviteCode(data)
    if data.code == 0 then
        Toast.Show("操作成功")
    else
        local tip = InviteCodeErrorConfig[data.code]
        if string.IsNullOrEmpty(tip) then
            tip = "操作失败"
        end
        Toast.Show(tip)
    end
end

--关闭
function InviteCodePanel.OnClickCloseBtn()
    PanelManager.Destroy(PanelConfig.InviteCode, true)
end