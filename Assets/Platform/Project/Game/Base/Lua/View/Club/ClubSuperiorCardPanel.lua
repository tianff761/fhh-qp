ClubSuperiorCardPanel = ClassPanel("ClubSuperiorCardPanel")
ClubSuperiorCardPanel.closeBtn = nil
ClubSuperiorCardPanel.giveLuckyValueBtn = nil
ClubSuperiorCardPanel.copyWechatBtn = nil
ClubSuperiorCardPanel.copyQQBtn = nil
ClubSuperiorCardPanel.copyKeyCodeBtn = nil

ClubSuperiorCardPanel.headImg = nil
ClubSuperiorCardPanel.sex1Tran = nil
ClubSuperiorCardPanel.sex0Tran = nil
ClubSuperiorCardPanel.nameText = nil
ClubSuperiorCardPanel.idText = nil
ClubSuperiorCardPanel.wechatInputField = nil
ClubSuperiorCardPanel.qqInputField = nil
ClubSuperiorCardPanel.keyCodeText = nil
local this = ClubSuperiorCardPanel
function ClubSuperiorCardPanel:Awake()
    this = self
    this.closeBtn = this:Find("Content/Bgs/CloseBtn")
    this.giveLuckyValueBtn = this:Find("Content/GiveLuckyValueBtn")
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
    this:AddOnClick(this.giveLuckyValueBtn, this.OnClickGiveLuckyValueBtn)
    this:AddOnClick(this.copyWechatBtn, this.OnClickCopyWechatBtn)
    this:AddOnClick(this.copyQQBtn, this.OnClickCopyQQBtn)
    this:AddOnClick(this.copyKeyCodeBtn, this.OnClickKeyCodeBtn)

end

function ClubSuperiorCardPanel.OnClickCloseBtn()
    PanelManager.Close(PanelConfig.ClubSuperiorCard)
end

function ClubSuperiorCardPanel.OnClickGiveLuckyValueBtn()
    PanelManager.Open(PanelConfig.DonateLuckyValue, GroupType.Club, ClubData.curClubId, ClubData.superiorUid)
end

function ClubSuperiorCardPanel.OnClickCopyWechatBtn()
    if not string.IsNullOrEmpty(ClubData.superiorWebchat) then
        local copyText = tostring(ClubData.superiorWebchat)
        AppPlatformHelper.CopyText(copyText)
    else
        Toast.Show("暂未设置微信号")
    end
end

function ClubSuperiorCardPanel.OnClickCopyQQBtn()
    if not string.IsNullOrEmpty(ClubData.superiorQQ) then
        local copyText = tostring(ClubData.superiorQQ)
        AppPlatformHelper.CopyText(copyText)
    else
        Toast.Show("暂未设置QQ号")
    end
end

function ClubSuperiorCardPanel.OnClickKeyCodeBtn()
    local copyText = tostring(ClubData.superiorKeyCode)
    AppPlatformHelper.CopyText(copyText)
    Toast.Show("复制专属码"..copyText.."成功")
end

function ClubSuperiorCardPanel.UpdatePanel()
    --todo:性别设置
    UIUtil.SetText(this.nameText, tostring(ClubData.superiorName))
    UIUtil.SetText(this.idText, tostring(ClubData.superiorUid))
    Functions.SetHeadImage(this.headImg, ClubData.superiorHeadIcon)
    
    UIUtil.SetInputText(this.wechatInputField, tostring(ClubData.superiorWebchat))
    UIUtil.SetInputText(this.qqInputField, tostring(ClubData.superiorQQ))
    
    UIUtil.SetText(this.keyCodeText, tostring(ClubData.superiorKeyCode))
end
