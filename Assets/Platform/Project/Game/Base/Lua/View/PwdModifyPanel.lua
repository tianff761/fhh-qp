PwdModifyPanel = ClassPanel("PwdModifyPanel")
local this = PwdModifyPanel

local Status = {
    [18002] = "请输入密码",
    [18003] = "密码错误",
    [60008] = "没绑定手机号"
}

function PwdModifyPanel:OnInitUI()
    this = self
    self:InitPanel()
end

function PwdModifyPanel:InitPanel()
    local content = this.transform:Find("Content")
    this.closeBtn = content:Find("Background/CloseBtn").gameObject

    this.okBtn = content:Find("OkBtn").gameObject

    this.tipsLabel = content:Find("Tips/Text"):GetComponent(TypeText)

    local oldPwd = content:Find("OldPwd/Input").gameObject
    this.oldPwdInput = oldPwd:GetComponent("InputField")

    local pwd = content:Find("Pwd/Input").gameObject
    this.pwdInput = pwd:GetComponent("InputField")

    local pwdConfirm = content:Find("PwdConfirm/Input").gameObject
    this.pwdInputConfirm = pwdConfirm:GetComponent("InputField")

    this.AddUIListenerEvent()
end

function PwdModifyPanel:OnOpened(args)
    --
    this.AddListenerEvent()
    --
    local strBegin3 = string.sub(UserData.bindPhone, 1, 3)
    local strEnd4 = string.sub(UserData.bindPhone, 8)
    this.tipsLabel.text = strBegin3 .. "****" .. strEnd4
end

function PwdModifyPanel:OnClosed()
    this.RemoveListenerEvent()
end

function PwdModifyPanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)
end

function PwdModifyPanel.AddListenerEvent()
    AddMsg(CMD.Tcp_S2C_PwdModify, this.OnPwdModify)
end

function PwdModifyPanel.RemoveListenerEvent()
    AddMsg(CMD.Tcp_S2C_PwdModify, this.OnPwdModify)
end

--================================================================
function PwdModifyPanel.OnCloseBtnClick()
    this.Close()
end

--确认
--7004 请求修改密码
--pwd 旧密码
--newPwd 新密码
function PwdModifyPanel.OnOkBtnClick()
    local oldPwd = this.oldPwdInput.text
    local length = #oldPwd
    if length < 4 or length > 12 then
        Toast.Show("请输入旧密码")
        return
    end

    local pwd = this.pwdInput.text
    length = #pwd
    if length < 4 or length > 12 then
        Toast.Show("请输入4-12位的密码")
        return
    end

    local pwdConfirm = this.pwdInputConfirm.text
    length = #pwdConfirm
    if length < 4 or length > 12 then
        Toast.Show("请输入4-12位的密码")
        return
    elseif pwd ~= pwdConfirm then
        Toast.Show("两次输入密码不一致")
        return
    end
    BaseTcpApi.SendPwdModify(oldPwd, pwd)
end
--================================================================
--
--返回
function PwdModifyPanel.OnPwdModify(arg)
    local data = arg.data
    if not data then
        return
    end
    if arg.code == 0 then
        Toast.Show("密码修改成功!")
        this.Close()
    else
        local msg = Status[arg.code]
        if msg == nil then
            Alert.Show("失败：" .. arg.code)
        else
            Alert.Show(msg)
        end
    end
end
--================================================================
--
function PwdModifyPanel.Close()
    PanelManager.Destroy(PanelConfig.PwdModify, true)
end
