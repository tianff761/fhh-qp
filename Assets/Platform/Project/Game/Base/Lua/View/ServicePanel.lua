ServicePanel = ClassPanel("ServicePanel")
ServicePanel.closeBtn = nil
ServicePanel.webchat1Text = nil
ServicePanel.webchat1CopyBtn = nil

ServicePanel.webchat2Text = nil
ServicePanel.webchat2CopyBtn = nil

ServicePanel.webchat1 = ""
ServicePanel.webchat2 = ""
local this = ServicePanel
function ServicePanel:Awake()
    this = self
    local content = this:Find("Content")
    this.closeBtn = content:Find("Bgs/CloseBtn")
    this.webchat1Text = content:Find("WechatInfo1/WechatText/Text")
    this.webchat2Text = content:Find("WechatInfo2/WechatText/Text")
    this.webchat1CopyBtn = content:Find("WechatInfo1/CopyBtn")
    this.webchat2CopyBtn = content:Find("WechatInfo2/CopyBtn")

    this:AddOnClick(this.closeBtn, this.OnClickCloseBtn)
    this:AddOnClick(this.webchat1CopyBtn, this.OnClickCopy1Btn)
    this:AddOnClick(this.webchat2CopyBtn, this.OnClickCopy2Btn)
end

function ServicePanel:OnOpened()
    if GlobalData.serviceWebchat ~= nil then
        this.webchat1 = GlobalData.serviceWebchat[1]
        -- this.webchat2 = GlobalData.serviceWebchat[2]
    end
    if not string.IsNullOrEmpty(this.webchat1) then
        UIUtil.SetText(this.webchat1Text, tostring(this.webchat1))
        UIUtil.SetActive(this.webchat1CopyBtn, true)
    else
        UIUtil.SetText(this.webchat1Text, "没有设置客服QQ号")
        UIUtil.SetActive(this.webchat1CopyBtn, false)
    end

    if not string.IsNullOrEmpty(this.webchat2) then
        UIUtil.SetText(this.webchat2Text, tostring(this.webchat2))
        UIUtil.SetActive(this.webchat2CopyBtn, true)
    else
        UIUtil.SetText(this.webchat2Text, "没有设置客服微信号")
        UIUtil.SetActive(this.webchat2CopyBtn, false)
    end
end

function ServicePanel.OnClickCloseBtn()
    PanelManager.Close(PanelConfig.Service, true)
end

function ServicePanel.OnClickCopy1Btn()
    AppPlatformHelper.CopyText(this.webchat1)
end

function ServicePanel.OnClickCopy2Btn()
    AppPlatformHelper.CopyText(this.webchat2)
end
