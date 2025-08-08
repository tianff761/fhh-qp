UnionNoticePanel = ClassPanel("UnionNoticePanel")
UnionNoticePanel.noticeText = nil
UnionNoticePanel.closeBtn = nil

local this = UnionNoticePanel
function UnionNoticePanel:Awake()
    this = self
    this.noticeText = self:Find("Content/NoticeText")
    this.closeBtn = self:Find("Content/Background/CloseBtn")
end

function UnionNoticePanel:OnOpened()
    this:AddOnClick(this.closeBtn, this.OnClickBackBtn)
    UnionManager.SendGetUnionNotice()
end

function UnionNoticePanel.SetUnionNotice(notice)
    if string.IsNullOrEmpty(notice) then
        UIUtil.SetText(this.noticeText, "　　暂未发布任何公告")
    else
        UIUtil.SetText(this.noticeText, tostring(notice))
    end
end

function UnionNoticePanel.OnClickBackBtn()
    PanelManager.Close(PanelConfig.UnionNotice, true)
end
