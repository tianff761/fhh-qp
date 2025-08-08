ClubMyCardPanel = ClassPanel("ClubMyCardPanel")
ClubMyCardPanel.closeBtn = nil
ClubMyCardPanel.superiorCardBtn = nil
ClubMyCardPanel.saveCardBtn = nil
ClubMyCardPanel.copyWechatBtn = nil
ClubMyCardPanel.copyQQBtn = nil
ClubMyCardPanel.copyKeyCodeBtn = nil

ClubMyCardPanel.headImg = nil
ClubMyCardPanel.sex1Tran = nil
ClubMyCardPanel.sex0Tran = nil
ClubMyCardPanel.nameText = nil
ClubMyCardPanel.idText = nil
ClubMyCardPanel.wechatInputField = nil
ClubMyCardPanel.qqInputField = nil
ClubMyCardPanel.keyCodeText = nil
local this = ClubMyCardPanel
function ClubMyCardPanel:Awake()
    this = self
    this.closeBtn = this:Find("Content/Bgs/CloseBtn")
    this.superiorCardBtn = this:Find("Content/LastPersonBtn")
    this.saveCardBtn = this:Find("Content/SaveCardBtn")
    this.copyWechatBtn = this:Find("Content/WechatInfo/CopyBtn")
    this.copyQQBtn = this:Find("Content/QQInfo/CopyBtn")
    this.copyKeyCodeBtn = this:Find("Content/KeyCodeInfo/CopyBtn")

    this.headImg = this:Find("Content/UserInfo/Head/Mask/HeadIcon"):GetComponent(TypeImage)
    this.sex0Tran = this:Find("Content/UserInfo/Sex0")
    this.sex1Tran = this:Find("Content/UserInfo/Sex1")
    this.idText = this:Find("Content/UserInfo/IdText")
    this.nameText = this:Find("Content/UserInfo/NameText")
    this.wechatInputField = this:Find("Content/WechatInfo/WechatInputField")
    this.qqInputField = this:Find("Content/QQInfo/QQInputField")
    this.keyCodeText = this:Find("Content/KeyCodeInfo/KeyCode/Text")

    this:AddOnClick(this.closeBtn, this.OnClickCloseBtn)
    this:AddOnClick(this.saveCardBtn, this.OnClickSaveCardBtn)
    this:AddOnClick(this.superiorCardBtn, this.OnClickSuperiorCardBtn)
    this:AddOnClick(this.copyWechatBtn, this.OnClickCopyWechatBtn)
    this:AddOnClick(this.copyQQBtn, this.OnClickCopyQQBtn)
    this:AddOnClick(this.copyKeyCodeBtn, this.OnClickKeyCodeBtn)

end

function ClubMyCardPanel:OnOpened()
    UIUtil.SetActive(this.superiorCardBtn, false)
end

function ClubMyCardPanel.OnClickCloseBtn()
    PanelManager.Close(PanelConfig.ClubMyCard)
end

function ClubMyCardPanel.OnClickSuperiorCardBtn()
    PanelManager.Open(PanelConfig.ClubSuperiorCard)
end

function ClubMyCardPanel.OnClickSaveCardBtn()
    local webchat = UIUtil.GetInputText(this.wechatInputField)
    local qq = UIUtil.GetInputText(this.qqInputField)
    
    if webchat == ClubData.myWebchat and qq == ClubData.myQQ then
        Toast.Show("微信和QQ账号未改变")
        return 
    end
    ClubManager.SendSetMemberCard(webchat, qq)
end

function ClubMyCardPanel.OnClickCopyWechatBtn()
    if not string.IsNullOrEmpty(ClubData.myWebchat) then
        local copyText = tostring(ClubData.myWebchat)
        AppPlatformHelper.CopyText(copyText)
    else
        Toast.Show("暂未设置微信号")
    end
end

function ClubMyCardPanel.OnClickCopyQQBtn()
    if not string.IsNullOrEmpty(ClubData.myQQ) then
        local copyText = tostring(ClubData.myQQ)
        AppPlatformHelper.CopyText(copyText)
    else
        Toast.Show("暂未设置QQ号")
    end
end

function ClubMyCardPanel.OnClickKeyCodeBtn()
    local copyText = tostring(ClubData.myKeyCode)
    AppPlatformHelper.CopyText(copyText)
    Toast.Show("复制专属码"..copyText.."成功")
end

function ClubMyCardPanel.UpdatePanel()
    --todo:性别设置
    UIUtil.SetText(this.nameText, tostring(ClubData.myName))
    UIUtil.SetText(this.idText, tostring(ClubData.myUid))
    Functions.SetHeadImage(this.headImg, ClubData.myHeadIcon)
    
    UIUtil.SetInputText(this.wechatInputField, tostring(ClubData.myWebchat))
    UIUtil.SetInputText(this.qqInputField, tostring(ClubData.myQQ))
    
    UIUtil.SetText(this.keyCodeText, tostring(ClubData.myKeyCode))
    UIUtil.SetActive(this.superiorCardBtn, ClubData.selfRole ~= ClubRole.Boss)
end
