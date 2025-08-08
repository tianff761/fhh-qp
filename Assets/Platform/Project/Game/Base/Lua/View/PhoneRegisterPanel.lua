PhoneRegisterPanel = ClassPanel("PhoneRegisterPanel")
local this = PhoneRegisterPanel
-----------------------------
local Status = {
    [10100] = "登录的方式不对",
    [10101] = "手机号不正确",
    [10102] = "手机号没有绑定游戏账号，不能登录",
    [10103] = "验证码错误",
    [10104] = "二次验证码错误",
    [10105] = "手机号已经被注册",
    [60004] = "有效期内不能重复发送，请稍后再试",
    [60008] = "未绑定手机号",
    [60003] = "有效期内不能重复发送，请稍后再试",
}


--注册类型
this.registerType = RegisterType.Register
--是否在发送中
this.sending = false
this.getCodeTime = 0
this.timer = nil
this.lastTime = 0

function PhoneRegisterPanel:OnInitUI()
    this = self
    self:InitPanel()
end

function PhoneRegisterPanel:InitPanel()
    local content = self.transform:Find("Content")
    self.closeBtn = content:Find("Background/CloseButton").gameObject

    self.okBtn = content:Find("OkBtn").gameObject
    this.okBtnTxt = content:Find("OkBtn/Text"):GetComponent(TypeText)

    self.getCodeBtn = content:Find("GetCodeBtn").gameObject
    self.getCodeButton = self.getCodeBtn:GetComponent("Button")
    self.getCodeButtonFont = self.getCodeBtn.transform:Find("Image")
    self.timeTxt = content:Find("GetCodeBg/TimeText"):GetComponent("Text")

    local phone = content:Find("Phone/Input").gameObject
    self.phoneInput = phone:GetComponent("InputField")

    local pwd = content:Find("Pwd/Input").gameObject
    self.pwdInput = pwd:GetComponent("InputField")

    local code = content:Find("Code/Input").gameObject
    self.codeInput = code:GetComponent("InputField")

    local title = content:Find("Background/Text").gameObject
    this.titleTxt = title:GetComponent(TypeText)

    this.AddUIListenerEvent()
end

function PhoneRegisterPanel:OnOpened(args)
    this.registerType = args
    --
    this.AddListenerEvent()
    this.CheckGetCodeTime()

    if this.registerType == RegisterType.Reset then
        this.titleTxt.text = "重置密码"
        this.okBtnTxt.text = "确认重置"
    else
        this.titleTxt.text = "手机注册"
        this.okBtnTxt.text = "确认注册"
    end
end

function PhoneRegisterPanel:OnClosed()
    this.RemoveListenerEvent()
end

function PhoneRegisterPanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.getCodeBtn, this.OnGetCodeBtnClick)
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)


end

function PhoneRegisterPanel.AddListenerEvent()
    AddMsg(CMD.Http_S2C_GetLoginVerfyCode, this.OnReceiveIdentCode)
    AddMsg(CMD.Http_S2C_PhoneRegister, this.OnPhoneRegister)
end

function PhoneRegisterPanel.RemoveListenerEvent()
    RemoveMsg(CMD.Http_S2C_GetLoginVerfyCode, this.OnReceiveIdentCode)
    RemoveMsg(CMD.Http_S2C_PhoneRegister, this.OnPhoneRegister)
end

--================================================================
function PhoneRegisterPanel.OnCloseBtnClick()
    this.Close()
end

--确认
function PhoneRegisterPanel.OnOkBtnClick()
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
    local code = this.codeInput.text
    if #code ~= 6 then
        Toast.Show("请输入正确的验证码")
        return
    end

    local opType = RegisterOpType.Register
    if this.registerType == RegisterType.Reset then
        opType = RegisterOpType.Reset
    end
    BaseTcpApi.SendPhoneRegister(phone, pwd, code, SystemInfo.deviceUniqueIdentifier, opType)
end

--发送手机验证码
function PhoneRegisterPanel.OnGetCodeBtnClick()
    local time = Time.realtimeSinceStartup
    if time - this.lastTime > 60 then
        this.sending = false
    end

    if this.sending then
        Toast.Show("正在获取验证码中，请不要重复发送!")
        return
    end
    local phone = this.phoneInput.text
    if #phone ~= 11 then
        Toast.Show("请输入正确的手机号")
        return
    end
    this.sending = true
    this.lastTime = time
    local opType = RegisterOpType.Register
    if this.registerType == RegisterType.Reset then
        opType = RegisterOpType.Reset
    end
    BaseTcpApi.SendGetLoginVerifyCode(phone, opType)
end

--================================================================
--
function PhoneRegisterPanel.OnReceiveIdentCode(arg)
    this.StopTimer()
    this.sending = false
    if arg.code == 0 then
        Toast.Show("验证码获取成功")
        this.getCodeTime = Time.realtimeSinceStartup + 120
        this.CheckGetCodeTime()
    else
        local str = Status[arg.code]
        if str == nil then
            str = "获取验证码失败"
        end
        Toast.Show(str)

        if arg.code == 60003 then
            if IsNumber(arg.data.countDown) then
                this.getCodeTime = Time.realtimeSinceStartup + arg.data.countDown
            else
                this.getCodeTime = Time.realtimeSinceStartup + 120
            end
            this.CheckGetCodeTime()
        end
    end
end

--注册返回
function PhoneRegisterPanel.OnPhoneRegister(arg)
    if arg.code == 0 then
        if this.registerType == RegisterType.Reset then
            Toast.Show("重置密码成功")
        else
            Toast.Show("手机注册成功")
        end
        this.Close()
    else
        local msg = Status[arg.code]
        if msg == nil then
            if this.registerType == RegisterType.Reset then
                msg = "重置密码失败"
            else
                msg = "手机注册失败"
            end
        end
        Toast.Show(msg)
    end
end

--================================================================
--
function PhoneRegisterPanel.Close()
    this.StopTimer()
    PanelManager.Destroy(PanelConfig.PhoneRegister, true)
end

--检测按钮计时
function PhoneRegisterPanel.CheckGetCodeTime()
    local time = this.getCodeTime - Time.realtimeSinceStartup

    if time > 0 then
        this.getCodeButton.interactable = false
        UIUtil.SetActive(this.getCodeButtonFont, false)
        this.HandleCodeTime()
        this.CheckTimer()
    else
        this.getCodeButton.interactable = true
        UIUtil.SetActive(this.getCodeButtonFont, true)
        this.timeTxt.text = ""
    end
end

function PhoneRegisterPanel.CheckTimer()
    if this.timer == nil then
        this.timer = Timing.New(this.HandleCodeTime, 0.1, -1, true)
    end
    this.timer:Start()
end

function PhoneRegisterPanel.StopTimer()
    if this.timer ~= nil then
        this.timer:Stop()
    end
    this.timer = nil
end

function PhoneRegisterPanel.HandleCodeTime()
    local time = this.getCodeTime - Time.realtimeSinceStartup
    if time < 0 then
        this.StopTimer()
        this.getCodeButton.interactable = true
        UIUtil.SetActive(this.getCodeButtonFont, true)
        this.timeTxt.text = ""
    else
        local str = string.format("%d", time)
        this.timeTxt.text = str .. "S"
    end
end