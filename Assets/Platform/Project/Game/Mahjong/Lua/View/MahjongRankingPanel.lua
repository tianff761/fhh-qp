MahjongRankingPanel = ClassPanel("MahjongRankingPanel")
MahjongRankingPanel.Instance = nil
--
local this = nil
--
--初始属性数据
function MahjongRankingPanel:InitProperty()

end

--UI初始化
function MahjongRankingPanel:OnInitUI()
    this = self
    this:InitProperty()

    local content = self:Find("Content")

    this.closeBtn = content:Find("Background/CloseBtn").gameObject
    local nodeTrans = content:Find("Node")

    this.items = {}
    for i = 1, 4 do
        local item = {}
        item.transform = nodeTrans:Find(i)
        item.gameObject = item.transform

        item.headIcon = item.transform:Find("Head/Mask/Icon"):GetComponent(TypeImage)
        item.headFrame = item.transform:Find("Head/Frame"):GetComponent(TypeImage)
        item.nameLabel = item.transform:Find("NameText"):GetComponent(TypeText)
        item.scoreLabel = item.transform:Find("ScoreText"):GetComponent(TypeText)

        this.items[i] = item
    end

    this.AddUIListenerEvent()
end


--当面板开启开启时
function MahjongRankingPanel:OnOpened(args)
    MahjongRankingPanel.Instance = self
    this.AddListenerEvent()
    this.UpdateDisplay(args)
end

--当面板关闭时调用
function MahjongRankingPanel:OnClosed()
    MahjongRankingPanel.Instance = nil

    this.RemoveListenerEvent()
end

------------------------------------------------------------------
--
--关闭
function MahjongRankingPanel.Close()
    PanelManager.Close(MahjongPanelConfig.Ranking)
end
--
function MahjongRankingPanel.AddListenerEvent()

end
--
function MahjongRankingPanel.RemoveListenerEvent()

end

--UI相关事件
function MahjongRankingPanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

------------------------------------------------------------------
--
--更新按钮显示状态
function MahjongRankingPanel.UpdateDisplay(data)
    local list = data.list
    table.sort(list, this.Sort)
    local length = #list
    local item = nil
    local playerData = nil
    local tempData = nil
    for i = 1, length do
        tempData = list[i]
        item = this.items[i]
        UIUtil.SetActive(item.gameObject, true)
        playerData = MahjongDataMgr.GetPlayerDataById(tempData.id)
        item.nameLabel.text = playerData.name
        item.scoreLabel.text = tempData.score .. "分"

        if playerData.id ~= item.playerId then
            item.playerId = playerData.id
            local arg = { playerItem = item, playerId = item.playerId }
            Functions.SetHeadImage(item.headIcon, playerData.headUrl, this.OnHeadImageLoadCompleted, arg)

            if playerData.headFrame ~= nil then
                Functions.SetHeadFrame(item.headFrame, playerData.headFrame)
            end
        end


    end
    local itemLength = #this.items
    for i = length + 1, itemLength do
        UIUtil.SetActive(this.items[i].gameObject, false)
    end
end

function MahjongRankingPanel.Sort(data1, data2)
    return data2.score < data1.score
end


--加载头像图片完成
function MahjongRankingPanel.OnHeadImageLoadCompleted(arg)
    if arg.playerItem ~= nil and arg.playerItem.playerId == arg.playerId then
        netImageMgr:SetImage(arg.playerItem.headIcon, arg.headUrl)
    end
end
------------------------------------------------------------------
--
function MahjongRankingPanel.OnCloseBtnClick()
    this.Close()
end