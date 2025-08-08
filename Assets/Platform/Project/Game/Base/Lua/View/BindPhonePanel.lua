BindPhonePanel = ClassPanel("BindPhonePanel")
local this = BindPhonePanel
-----------------------------
local Status = {
    [60001] = "请输入手机号",
    [60002] = "已经绑定过手机，无法重复绑定",
    [60003] = "验证码有效期内无法重复发送",
    [60004] = "验证码有效期内无法重复发送",
    [60005] = "请输入验证码",
    [60006] = "验证码不匹配",
    [60007] = "验证码已失效",
}

--注册类型
this.registerType = RegisterType.Register
--是否在发送中
this.sending = false
this.getCodeTime = 0
this.timer = nil
this.lastTime = 0

function BindPhonePanel:OnInitUI()
    this = self
    self:InitPanel()
end

function BindPhonePanel:InitPanel()
    local content = this.transform:Find("Content")
    this.closeBtn = content:Find("Background/CloseBtn").gameObject

    this.okBtn = content:Find("OkBtn").gameObject

    this.getCodeBtn = content:Find("GetCodeBtn").gameObject
    this.getCodeButton = this.getCodeBtn:GetComponent("Button")
    this.getCodeButtonFont = this.getCodeBtn.transform:Find("Image")
    this.timeTxt = content:Find("GetCodeBg/TimeText"):GetComponent("Text")

    local phone = content:Find("Phone/Input").gameObject
    this.phoneInput = phone:GetComponent("InputField")

    local pwd = content:Find("Pwd/Input").gameObject
    this.pwdInput = pwd:GetComponent("InputField")

    local pwdConfirm = content:Find("PwdConfirm/Input").gameObject
    this.pwdInputConfirm = pwdConfirm:GetComponent("InputField")

    local code = content:Find("Code/Input").gameObject
    this.codeInput = code:GetComponent("InputField")
    
    this.bindingTips = content:Find("BindTips").gameObject
    this.rebindingTips = content:Find("RebindTips").gameObject

    this.AddUIListenerEvent()
end

function BindPhonePanel:OnOpened(args)
    this.registerType = args
    --
    this.AddListenerEvent()
    this.CheckGetCodeTime()

    if this.registerType == RegisterType.Reset then
        --this.titleTxt.text = "重新绑定"
        UIUtil.SetActive(this.bindingTips, false)
        --UIUtil.SetActive(this.rebindingTips, true)
    else
        --this.titleTxt.text = "手机绑定"
        --UIUtil.SetActive(this.bindingTips, true)
        UIUtil.SetActive(this.rebindingTips, false)
    end
end

function BindPhonePanel:OnClosed()
    this.RemoveListenerEvent()
end

function BindPhonePanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.getCodeBtn, this.OnGetCodeBtnClick)
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)


end

function BindPhonePanel.AddListenerEvent()
    AddMsg(CMD.Tcp_S2C_GetBindVerfyCode, this.OnReceiveIdentCode)
    AddMsg(CMD.Tcp_S2C_BindPhone, this.OnReceiveValidate)
end

function BindPhonePanel.RemoveListenerEvent()
    RemoveMsg(CMD.Tcp_S2C_GetBindVerfyCode, this.OnReceiveIdentCode)
    RemoveMsg(CMD.Tcp_S2C_BindPhone, this.OnReceiveValidate)
end

--================================================================
function BindPhonePanel.OnCloseBtnClick()
    this.Close()
end

--确认
function BindPhonePanel.OnOkBtnClick()
    local phone = this.phoneInput.text
    if #phone ~= 11 then
        Toast.Show("请输入正确的手机号")
        return
    end

    --local code = this.codeInput.text
    --if #code ~= 6 then
    --    Toast.Show("请输入正确的验证码")
    --    return
    --end

    local pwd = this.pwdInput.text
    local length = #pwd
    if length < 4 or length > 12 then
        Toast.Show("请输入4-12位的密码")
        return
    end

    local pwdConfirm = this.pwdInputConfirm.text
    local ConfirmLength = #pwdConfirm
    if ConfirmLength < 4 or ConfirmLength > 12 then
        Toast.Show("请输入4-12位的密码")
        return
    elseif pwd ~= pwdConfirm then
        Toast.Show("两次输入密码不一致")
        return
    end

    BaseTcpApi.SendBindPhone(phone, pwd, code)
end

--发送手机验证码
function BindPhonePanel.OnGetCodeBtnClick()
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
    BaseTcpApi.SendGetBindVerfyCode(phone)
end

--================================================================
--
function BindPhonePanel.OnReceiveIdentCode(arg)
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

--返回
function BindPhonePanel.OnReceiveValidate(arg)
    local data = arg.data
    if not data then
        return
    end

    if arg.code == 0 then
        if this.registerType == RegisterType.Reset then
            Toast.Show("重新绑定成功!")
        else
            Toast.Show("手机绑定成功!")
        end
        --需要清除手机号登录的缓存数据
        local data = GetLocal(LocalDatas.UserInfoData)--检查是否存储玩家信息
        if not string.IsNullOrEmpty(data) then
            local userInfo = JsonToObj(data)
            if userInfo ~= nil then
                if userInfo.platformType == PlatformType.PHONE then
                    --直接清除用手机号登录的数据，防止下次自动登录
                    SetLocal(LocalDatas.UserInfoData, "")
                end
            end
        end

        local phoneNumber = this.phoneInput.text
        this.HandlePhoneBound(phoneNumber)
        this.Close()
    else
        local msg = Status[arg.code]
        if msg == nil then
            if this.registerType == RegisterType.Reset then
                msg = "重新绑定失败，请稍后重试"
            else
                msg = "手机绑定失败，请稍后重试"
            end
        end
        Alert.Show(msg)
    end
end

--================================================================
--
function BindPhonePanel.Close()
    this.StopTimer()
    PanelManager.Destroy(PanelConfig.BindPhone, true)
end

--检测按钮计时
function BindPhonePanel.CheckGetCodeTime()
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

function BindPhonePanel.CheckTimer()
    if this.timer == nil then
        this.timer = Timing.New(this.HandleCodeTime, 0.1, -1, true)
    end
    this.timer:Start()
end

function BindPhonePanel.StopTimer()
    if this.timer ~= nil then
        this.timer:Stop()
    end
    this.timer = nil
end

function BindPhonePanel.HandleCodeTime()
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

--处理手机绑定
function BindPhonePanel.HandlePhoneBound(phoneNumber)
    if not string.IsNullOrEmpty(phoneNumber) then
        UserData.SetBindPhone(phoneNumber)
    end
    if PanelManager.IsOpened(PanelConfig.UserInfo) then
        UserInfoPanel.UpdateUserInfo()
    end
end