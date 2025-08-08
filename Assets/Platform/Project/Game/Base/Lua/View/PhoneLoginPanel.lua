PhoneLoginPanel = ClassPanel("PhoneLoginPanel")
local this = PhoneLoginPanel

function PhoneLoginPanel:OnInitUI()
    this = self
    self:InitPanel()
end

function PhoneLoginPanel:InitPanel()
    local content = self.transform:Find("Content")
    self.closeBtn = content:Find("Background/CloseBtn").gameObject

    self.okBtn = content:Find("OkBtn").gameObject
    self.registerBtn = content:Find("RegisterBtn").gameObject
    self.resetBtn = content:Find("ResetBtn").gameObject

    self.phoneObj = content:Find("Phone/Input").gameObject
    self.pwdObj = content:Find("Pwd/Input").gameObject
    self.phoneInput = self.phoneObj:GetComponent("InputField")
    self.pwdInput = self.pwdObj:GetComponent("InputField")

    this.AddUIListenerEvent()
end


function PhoneLoginPanel:OnOpened()
    this.AddListenerEvent()
end

function PhoneLoginPanel:OnClosed()
    this.RemoveListenerEvent()
end


function PhoneLoginPanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)
    this:AddOnClick(this.registerBtn, this.OnRegisterBtnClick)
    this:AddOnClick(this.resetBtn, this.OnResetBtnClick)
end

function PhoneLoginPanel.AddListenerEvent()

end

function PhoneLoginPanel.RemoveListenerEvent()

end

--================================================================
--确认
function PhoneLoginPanel.OnOkBtnClick()
    local phone = this.phoneInput.text
    if #phone ~= 11 then
        Toast.Show("请输入正确的手机号")
        return
    end
    local pwd = this.pwdInput.text
    local length = #pwd
    if length < 4 or length > 12 then
        Toast.Show("请输入4-12位的密码")
        return
    end

    local data = {
        platformType = PlatformType.PHONE,
        phone = phone,
        password = pwd
    }
    SendEvent(CMD.Game.AuthLogin, data)
end

function PhoneLoginPanel.OnCloseBtnClick()
    this.Close()
end

function PhoneLoginPanel.OnRegisterBtnClick()
    PanelManager.Open(PanelConfig.PhoneRegister, RegisterType.Register)
end

function PhoneLoginPanel.OnResetBtnClick()
    PanelManager.Open(PanelConfig.PhoneRegister, RegisterType.Reset)
end

--================================================================
--关闭
function PhoneLoginPanel.Close()
    PanelManager.Destroy(PanelConfig.PhoneLogin, true)
end