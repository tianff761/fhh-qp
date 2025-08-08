UnionInvitePlayerNoticePanel = ClassPanel("UnionInvitePlayerNoticePanel")

local this = UnionInvitePlayerNoticePanel
function UnionInvitePlayerNoticePanel:Awake()
    this = self
    local content = self:Find("Content").transform
    this.ConfirmButton = content:Find("ConfirmButton")
    this.CancelButton = content:Find("CancelButton").gameObject
    local PlayerInfo = content:Find("PlayerInfo")
    this.HeadImg = PlayerInfo:Find("Head/Mask/Icon"):GetComponent(TypeImage)
    this.Name = PlayerInfo:Find("Name")
    this.ID = PlayerInfo:Find("ID")

    this:AddOnClick(this.ConfirmButton, this.ConfirmButtonOnClick)
    this:AddOnClick(this.CancelButton, this.CancelButtonOnClick)
end

---@param data table playId  "玩家id" --name 名字 --icon 头像
function UnionInvitePlayerNoticePanel:OnOpened(data, invitePlayerType)
    LogError("<color=aqua>data</color>", data)
    this.PlayerID = data.playId
    this.invitePlayerType = invitePlayerType
    Functions.SetHeadImage(this.HeadImg, data.icon)
    UIUtil.SetText(this.Name, data.name)
    UIUtil.SetText(this.ID, "ID:" .. data.playId)
end

function UnionInvitePlayerNoticePanel.ConfirmButtonOnClick()
    if this.invitePlayerType == UnionRole.Partner then
        UnionManager.SendAddPartnerMember(this.PlayerID)
    elseif this.invitePlayerType == UnionRole.Common then
        UnionManager.SendAddCommonMember(this.PlayerID)
    end
    this:Close()
end

function UnionInvitePlayerNoticePanel.CancelButtonOnClick()
    this:Close()
end
