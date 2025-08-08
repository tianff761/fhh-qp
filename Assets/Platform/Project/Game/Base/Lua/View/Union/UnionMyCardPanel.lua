UnionMyCardPanel = ClassPanel("UnionMyCardPanel")
UnionMyCardPanel.closeBtn = nil
UnionMyCardPanel.superiorCardBtn = nil
UnionMyCardPanel.saveCardBtn = nil
UnionMyCardPanel.copyWechatBtn = nil
UnionMyCardPanel.copyQQBtn = nil
UnionMyCardPanel.copyKeyCodeBtn = nil

UnionMyCardPanel.headImg = nil
UnionMyCardPanel.sex1Tran = nil
UnionMyCardPanel.sex0Tran = nil
UnionMyCardPanel.nameText = nil
UnionMyCardPanel.idText = nil
UnionMyCardPanel.wechatInputField = nil
UnionMyCardPanel.qqInputField = nil
UnionMyCardPanel.keyCodeText = nil
local this = UnionMyCardPanel
function UnionMyCardPanel:Awake()
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

function UnionMyCardPanel:OnOpened()
    UnionManager.SendGetMemberCard(1)
    UIUtil.SetActive(this.superiorCardBtn, false)
end

function UnionMyCardPanel.OnClickCloseBtn()
    PanelManager.Close(PanelConfig.UnionMyCard)
end

function UnionMyCardPanel.OnClickSuperiorCardBtn()
    PanelManager.Open(PanelConfig.UnionSuperiorCard)
end

function UnionMyCardPanel.OnClickSaveCardBtn()
    local webchat = UIUtil.GetInputText(this.wechatInputField)
    local qq = UIUtil.GetInputText(this.qqInputField)
    
    if webchat == UnionData.myWebchat and qq == UnionData.myQQ then
        Toast.Show("微信和QQ账号未改变")
        return 
    end
    UnionManager.SendSetMemberCard(webchat, qq)
end

function UnionMyCardPanel.OnClickCopyWechatBtn()
    if not string.IsNullOrEmpty(UnionData.myWebchat) then
        local copyText = tostring(UnionData.myWebchat)
        AppPlatformHelper.CopyText(copyText)
    else
        Toast.Show("暂未设置微信号")
    end
end

function UnionMyCardPanel.OnClickCopyQQBtn()
    if not string.IsNullOrEmpty(UnionData.myQQ) then
        local copyText = tostring(UnionData.myQQ)
        AppPlatformHelper.CopyText(copyText)
    else
        Toast.Show("暂未设置QQ号")
    end
end

function UnionMyCardPanel.OnClickKeyCodeBtn()
    local copyText = tostring(UnionData.myKeyCode)
    AppPlatformHelper.CopyText(copyText)
    Toast.Show("复制专属码"..copyText.."成功")
end

function UnionMyCardPanel.UpdatePanel()
    --todo:性别设置
    UIUtil.SetText(this.nameText, tostring(UnionData.myName))
    UIUtil.SetText(this.idText, tostring(UnionData.myUid))
    Functions.SetHeadImage(this.headImg, UnionData.myHeadIcon)
    if string.IsNullOrEmpty(UnionData.myWebchat) then
        UIUtil.SetInputText(this.wechatInputField, "")
    else 
        UIUtil.SetInputText(this.wechatInputField, tostring(UnionData.myWebchat))
    end
    if string.IsNullOrEmpty(UnionData.myQQ) then
        UIUtil.SetInputText(this.qqInputField, "")
    else
        UIUtil.SetInputText(this.qqInputField, tostring(UnionData.myQQ))
    end
    
    UIUtil.SetText(this.keyCodeText, tostring(UnionData.myKeyCode))
    UIUtil.SetActive(this.superiorCardBtn, UnionData.selfRole ~= UnionRole.Leader)
end
