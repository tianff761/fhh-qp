LYCAwardPoolDetailPanel = ClassPanel("LYCAwardPoolDetailPanel")
local this = LYCAwardPoolDetailPanel

local transform

function LYCAwardPoolDetailPanel:OnInitUI()
    self:InitPanel()
    self:AddClickEvent()
end

function LYCAwardPoolDetailPanel:InitPanel()
    transform = self.transform
    this.closeBtn = transform:Find("Content/Bgs/CloseBtn")
    this.RecordOne = transform:Find("Content/Node/Player/item"):GetComponent(TypeText)
    this.RecordTwo = transform:Find("Content/Node/Player/item1"):GetComponent(TypeText)
    this.Player = transform:Find("Content/Node/Player")
    this.NoPlayer = transform:Find("Content/Node/NoPlayer")
    this.UpdateRecordText(LYCRoomData.RewardRecord)
end

function LYCAwardPoolDetailPanel.UpdateRecordText(rewardRecord)
    local hasRecord = rewardRecord and #rewardRecord > 0
    UIUtil.SetActive(this.Player, hasRecord)
    UIUtil.SetActive(this.NoPlayer, not hasRecord)
    if hasRecord then
        this.RecordOne.text = string.format("%s在拼十中获得%s赢得%d元奖金！", rewardRecord[1].nick, rewardRecord[1].px, rewardRecord[1].reward)
        if #rewardRecord > 1 then
            this.RecordTwo.text = string.format("%s在拼十中获得%s赢得%d元奖金！", rewardRecord[2].nick, rewardRecord[2].px, rewardRecord[2].reward)
        end
    end
end

--增加点击事件
function LYCAwardPoolDetailPanel:AddClickEvent()
    --点击离开按钮
    this:AddOnClick(this.closeBtn.gameObject, this.OnClickLeaveBtn)
end

function LYCAwardPoolDetailPanel.OnClickLeaveBtn()
    PanelManager.Close(LYCPanelConfig.AwardPool, true)
end

--当销毁时
function LYCAwardPoolDetailPanel:OnDestroy()

end
