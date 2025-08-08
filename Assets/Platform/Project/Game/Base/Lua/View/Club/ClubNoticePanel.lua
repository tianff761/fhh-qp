ClubNoticePanel = ClassPanel("ClubNoticePanel")
ClubNoticePanel.noticeText = nil
ClubNoticePanel.closeBtn = nil

local this = ClubNoticePanel
function ClubNoticePanel:Awake()
    this = self
    this.noticeText = self:Find("NoticeText")
    this.closeBtn = self:Find("Bgs/CloseBtn")
end

function ClubNoticePanel:OnOpened()
    this:AddOnClick(this.closeBtn, this.OnClickBackBtn)
    this.SetClubNotice()
end

function ClubNoticePanel.SetClubNotice()
    if string.IsNullOrEmpty(ClubData.clubNotice) then
        UIUtil.SetText(this.noticeText, "    暂未发布任何公告")
    else
        UIUtil.SetText(this.noticeText, "    "..ClubData.clubNotice)
    end
end

function ClubNoticePanel.OnClickBackBtn()
    PanelManager.Close(PanelConfig.ClubNotice, true)
end

