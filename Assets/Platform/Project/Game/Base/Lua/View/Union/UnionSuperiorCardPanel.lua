UnionSuperiorCardPanel = ClassPanel("UnionSuperiorCardPanel")
UnionSuperiorCardPanel.closeBtn = nil
UnionSuperiorCardPanel.giveLuckyValueBtn = nil
UnionSuperiorCardPanel.copyWechatBtn = nil
UnionSuperiorCardPanel.copyQQBtn = nil
UnionSuperiorCardPanel.copyKeyCodeBtn = nil

UnionSuperiorCardPanel.headImg = nil
UnionSuperiorCardPanel.sex1Tran = nil
UnionSuperiorCardPanel.sex0Tran = nil
UnionSuperiorCardPanel.nameText = nil
UnionSuperiorCardPanel.idText = nil
UnionSuperiorCardPanel.wechatInputField = nil
UnionSuperiorCardPanel.qqInputField = nil
UnionSuperiorCardPanel.keyCodeText = nil
local this = UnionSuperiorCardPanel
function UnionSuperiorCardPanel:Awake()
    this = self
    this.closeBtn = this:Find("Content/Background/CloseBtn")
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

--uid：打开的uid的名片界面
function UnionSuperiorCardPanel:OnOpened()
    UnionManager.SendGetMemberCard(2)
end

function UnionSuperiorCardPanel.OnClickCloseBtn()
    PanelManager.Close(PanelConfig.UnionSuperiorCard)
end

function UnionSuperiorCardPanel.OnClickGiveLuckyValueBtn()
    PanelManager.Open(PanelConfig.DonateLuckyValue, GroupType.Union, UnionData.curUnionId, UnionData.superiorUid)
end

function UnionSuperiorCardPanel.OnClickCopyWechatBtn()
    if not string.IsNullOrEmpty(UnionData.superiorWebchat) then
        local copyText = tostring(UnionData.superiorWebchat)
        AppPlatformHelper.CopyText(copyText)
    else
        Toast.Show("暂未设置微信号")
    end
end

function UnionSuperiorCardPanel.OnClickCopyQQBtn()
    if not string.IsNullOrEmpty(UnionData.superiorQQ) then
        local copyText = tostring(UnionData.superiorQQ)
        AppPlatformHelper.CopyText(copyText)
    else
        Toast.Show("暂未设置QQ号")
    end
end

function UnionSuperiorCardPanel.OnClickKeyCodeBtn()
    local copyText = tostring(UnionData.superiorKeyCode)
    AppPlatformHelper.CopyText(copyText)
    Toast.Show("复制专属码"..copyText.."成功")
end

function UnionSuperiorCardPanel.UpdatePanel()
    --todo:性别设置
    UIUtil.SetText(this.nameText, tostring(UnionData.superiorName))
    UIUtil.SetText(this.idText, tostring(UnionData.superiorUid))
    Functions.SetHeadImage(this.headImg, UnionData.superiorHeadIcon)

    local txt = UnionData.superiorWebchat
    if txt == nil then
        txt = ""
    else
        txt = tostring(UnionData.superiorWebchat)
    end
    UIUtil.SetInputText(this.wechatInputField, txt)

    txt = UnionData.superiorQQ
    if txt == nil then
        txt = ""
    else
        txt = tostring(UnionData.superiorQQ)
    end
    UIUtil.SetInputText(this.qqInputField, txt)
    
    UIUtil.SetText(this.keyCodeText, tostring(UnionData.superiorKeyCode))
end
