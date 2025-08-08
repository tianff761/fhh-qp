UpdateNoticePanel = ClassPanel("UpdateNoticePanel")
local this = nil

function UpdateNoticePanel:OnInitUI()
    this = self
    this.closeBtn = this:Find("Content/Background/CloseBtn").gameObject

    this.contentTxt = this:Find("Content/ScrollView/ViewPort/Content/Text"):GetComponent("Text")

    this.AddUIListenerEvent()
end

--每次打开都调用一次
function UpdateNoticePanel:OnOpened()
    this.AddListenerEvent()
    this.contentTxt.text = NoticeConfig.UpdateContent
end

function UpdateNoticePanel:OnClosed()
    this.RemoveListenerEvent()

end

function UpdateNoticePanel:AddListenerEvent()

end

function UpdateNoticePanel:RemoveListenerEvent()

end

function UpdateNoticePanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

function UpdateNoticePanel.OnCloseBtnClick()
    PanelManager.Close(PanelConfig.UpdateNotice)
end