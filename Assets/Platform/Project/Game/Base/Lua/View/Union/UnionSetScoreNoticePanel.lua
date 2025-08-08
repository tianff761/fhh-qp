UnionSetScoreNoticePanel = ClassPanel("UnionSetScoreNoticePanel")

local this = UnionSetScoreNoticePanel
function UnionSetScoreNoticePanel:Awake()
    this = self
    local content = self:Find("Content").transform
    this.ConfirmButton = content:Find("ConfirmButton")
    this.CancelButton = content:Find("CancelButton").gameObject
    local PlayerInfo = content:Find("PlayerInfo")
    this.HeadImg = PlayerInfo:Find("Head/Mask/Icon"):GetComponent(TypeImage)
    this.Name = PlayerInfo:Find("Name")
    this.ID = PlayerInfo:Find("ID")
    this.Text = content:Find("Text")

    this:AddOnClick(this.ConfirmButton, this.ConfirmButtonOnClick)
    this:AddOnClick(this.CancelButton, this.CancelButtonOnClick)
end

---@param data table playId  "玩家id" --name 名字 --icon 头像
---@param score number 调整的分数
---@param callback function 传入的回调方法
function UnionSetScoreNoticePanel:OnOpened(data, score, callback)
    LogError("<color=aqua>data</color>", data)
    this.PlayerID = data.playId
    this.callback = callback
    Functions.SetHeadImage(this.HeadImg, data.icon)
    UIUtil.SetText(this.Name, data.name)
    UIUtil.SetText(this.ID, "ID:" .. data.playId)
    score = score > 0 and "+" .. score or score
    UIUtil.SetText(this.Text, "确定调整此玩家<color=red>" .. score .. "</color>积分？")
end

function UnionSetScoreNoticePanel.ConfirmButtonOnClick()
    LogError("<color=aqua>this.callback</color>", this.callback)
    if this.callback then
        this.callback()
    end
    this:Close()
end

function UnionSetScoreNoticePanel.CancelButtonOnClick()
    this:Close()
end
