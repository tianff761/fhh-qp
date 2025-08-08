MahjongMatchSettlementPanel = ClassPanel("MahjongMatchSettlementPanel")
MahjongMatchSettlementPanel.Instance = nil
--
local this = nil
--
--初始属性数据
function MahjongMatchSettlementPanel:InitProperty()
    this.clickTime = 0
end

--UI初始化
function MahjongMatchSettlementPanel:OnInitUI()
    this = self
    this:InitProperty()

    local content = this:Find("Content")

    local background = content:Find("Background"):GetComponent(TypeImage)
    UIUtil.SetBackgroundAdaptation(background.gameObject)

    local title = content:Find("Title")
    this.titleRectTransform = title:GetComponent(TypeRectTransform)
    this.titleLabel = title:Find("Text"):GetComponent(TypeText)

    this.backBtn = content:Find("BackButton").gameObject
    this.nextBtn = content:Find("NextButton").gameObject

    this.rewardLabel = content:Find("RewardText"):GetComponent(TypeText)

    this.AddUIListenerEvent()
end


--当面板开启开启时
function MahjongMatchSettlementPanel:OnOpened()
    MahjongMatchSettlementPanel.Instance = self
    this.AddListenerEvent()
    this.UpdateDisplay()
end

--当面板关闭时调用
function MahjongMatchSettlementPanel:OnClosed()
    MahjongMatchSettlementPanel.Instance = nil
    this.RemoveListenerEvent()
end

------------------------------------------------------------------
--
--关闭
function MahjongMatchSettlementPanel.Close()
    PanelManager.Close(MahjongPanelConfig.MatchSettlement)
end
--
function MahjongMatchSettlementPanel.AddListenerEvent()

end
--
function MahjongMatchSettlementPanel.RemoveListenerEvent()

end

--UI相关事件
function MahjongMatchSettlementPanel.AddUIListenerEvent()
    this:AddOnClick(this.backBtn, this.OnBackBtnClick)
    this:AddOnClick(this.nextBtn, this.OnNextBtnClick)
end

------------------------------------------------------------------
--
--返回大厅
function MahjongMatchSettlementPanel.OnBackBtnClick()
    MahjongRoomMgr.ExitRoom()
end

--继续游戏
function MahjongMatchSettlementPanel.OnNextBtnClick()
    if MahjongDataMgr.matchId == nil then
        MahjongRoomMgr.ExitRoom()
    else
        if Time.realtimeSinceStartup - this.clickTime < 3 then
            Toast.Show("请稍后...")
            return
        end
        this.clickTime = Time.realtimeSinceStartup
        CompetitionManager.SendStartMatch(MahjongDataMgr.matchId, MahjongDataMgr.playerTotal)
    end
end

------------------------------------------------------------------
--
--更新显示
function MahjongMatchSettlementPanel.UpdateDisplay()
    local data = MahjongDataMgr.settlementData
    local playerName = nil
    if data.firstIds ~= nil and #data.firstIds > 0 then
        for i = 1, #data.firstIds do
            local playerData = MahjongDataMgr.GetPlayerDataById(data.firstIds[i])
            if not string.IsNullOrEmpty(playerData.name) then
                if playerName == nil then
                    playerName = playerData.name
                else
                    playerName = playerName .. "、" .. playerData.name
                end
            end
        end
    end

    if playerName == nil then
        playerName = "玩家"
    end
    local matchName = CompetitionName[MahjongDataMgr.matchLevel]
    if matchName == nil then
        matchName = CompetitionName[1]
    end
    local msg = "恭喜" .. playerName .. "在【" .. matchName .. "】中获得"

    this.titleLabel.text = msg

    local width = this.titleLabel.preferredWidth + 40
    if width > 1200 then
        width = 1200
    end
    if width < 664 then
        width = 664
    end
    local temp = this.titleRectTransform.sizeDelta
    this.titleRectTransform.sizeDelta = Vector2(width, temp.y)

    local reward = data.reward
    if reward == nil then
        reward = 0
    end
    this.rewardLabel.text = reward
end