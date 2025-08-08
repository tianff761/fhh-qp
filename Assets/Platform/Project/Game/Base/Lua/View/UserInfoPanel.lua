UserInfoPanel = ClassPanel("UserInfoPanel")
local this = UserInfoPanel

function UserInfoPanel:OnInitUI()
    this = self

    local content = this:Find("Content")
    this.closeBtn = content:Find("Background/CloseBtn")

    this.modifyNameBtn = content:Find("Name/ModifyNameBtn")

    this.headImage = content:Find("Head/Mask/Icon"):GetComponent(TypeImage)

    this.nameInput = content:Find("Name")
    this.male = content:Find("Name/Male").gameObject
    this.female = content:Find("Name/Female").gameObject
    this.idTxt = content:Find("Id/Text"):GetComponent(TypeText)
    this.phoneText = content:Find("Phone/Text"):GetComponent(TypeText)
    this.phoneBindBtn = content:Find("BindButton").gameObject
    this.phoneRebindBtn = content:Find("RebindButton").gameObject
    this.quitBtn = content:Find("QuitButton").gameObject
    this.modifyBtn = content:Find("ModifyButton").gameObject
    this.copyBtn = content:Find("CopyButton").gameObject

    this.modifyHeadIconBtn = content:Find("Head/ModifyHeadIconBtn")
    this.diamondTxt = content:Find("Diamond/Text"):GetComponent(TypeText)

    this.AddUIListenerEvent()
    AddEventListener(CMD.Game.UpdateUserInfo, this.UpdateUserInfo)
end

function UserInfoPanel:OnOpened(option)
    this:AddOnClick(this.modifyHeadIconBtn, function ()
        PanelManager.Open(PanelConfig.ModifyHeadIcon)
    end)
    this.UpdateUserInfo()
end

function UserInfoPanel:OnClosed()
    RemoveEventListener(CMD.Game.UpdateUserInfo, this.UpdateUserInfo)
end


function UserInfoPanel:AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.phoneBindBtn, this.OnPhoneBindBtnClick)
    this:AddOnClick(this.phoneRebindBtn, this.OnPhoneRebindBtnClick)
    this:AddOnClick(this.modifyNameBtn, this.OnClickModifyNameBtn)
    this:AddOnClick(this.quitBtn, this.OnQuitBtnClick)
    this:AddOnClick(this.modifyBtn, this.OnModifyBtnClick)
    this:AddOnClick(this.copyBtn, this.OnCopyBtnClick)
end

function UserInfoPanel.OnCloseBtnClick()
    PanelManager.Destroy(PanelConfig.UserInfo, true)
end

--
function UserInfoPanel.OnPhoneBindBtnClick()
    PanelManager.Open(PanelConfig.BindPhone, RegisterType.Register)
end

function UserInfoPanel.OnPhoneRebindBtnClick()
    Toast.Show("已绑定手机")
    --PanelManager.Open(PanelConfig.BindPhone, RegisterType.Reset)
end

function UserInfoPanel.OnClickModifyNameBtn()
    local name = UIUtil.GetInputText(this.nameInput)
    if string.IsNullOrEmpty(name) then
        Toast.Show("请输入昵称")
    elseif name == UserData.GetName() then
        Toast.Show("当前昵称没有改变")
    else
        SendTcpMsg(CMD.Tcp.C2S_PlayerName, {newName = name})
    end
end

function UserInfoPanel.OnQuitBtnClick()
    Alert.Prompt("确定切换账号，返回到登录界面？", function()
        SendEvent(CMD.Game.LogoutAndOpenLogin)
    end)
end

function UserInfoPanel.OnModifyBtnClick()
    PanelManager.Open(PanelConfig.PwdModify)
end


function UserInfoPanel.OnCopyBtnClick()
    AppPlatformHelper.CopyText("" .. UserData.GetUserId())
end

------------------------------------------------------------------
--
-- 玩家信息
function UserInfoPanel.UpdateUserInfo()
    UIUtil.SetInputText(this.nameInput, UserData.GetName())--SubStringName(
    this.idTxt.text = UserData.GetUserId()
    if UserData.gender == Global.GenderType.Male then
        UIUtil.SetActive(this.male, true)
        UIUtil.SetActive(this.female, false)
    else
        UIUtil.SetActive(this.male, false)
        UIUtil.SetActive(this.female, true)
    end
    Functions.SetHeadImage(this.headImage, UserData.GetHeadUrl())
    --屏蔽所有绑定手机按钮，因为只有手机验证码登录
    if string.IsNullOrEmpty(UserData.bindPhone) or string.len(UserData.bindPhone) < 7 then
        this.phoneText.text = ""
        UIUtil.SetActive(this.phoneBindBtn, true)
        UIUtil.SetActive(this.phoneRebindBtn, false)
        UIUtil.SetActive(this.modifyBtn, false)
    else
        local strBegin3 = string.sub(UserData.bindPhone, 1, 3)
        local strEnd4 = string.sub(UserData.bindPhone, 8)
        this.phoneText.text = strBegin3 .. "****" .. strEnd4
        UIUtil.SetActive(this.phoneBindBtn, false)
        UIUtil.SetActive(this.phoneRebindBtn, false)
        UIUtil.SetActive(this.modifyBtn, true)
    end

    this.diamondTxt.text = UserData.GetRoomCard()
end