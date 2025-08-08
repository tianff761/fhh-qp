--麻将打牌的辅助类
MahjongPlayCardHelper = {
    --打出牌的ID
    playCardId = nil,
    --发送的操作数据
    operationData = nil,
}

local this = MahjongPlayCardHelper

--打牌
function MahjongPlayCardHelper.PlayCard(clickCardItem)
    if clickCardItem == nil or clickCardItem.cardData == nil then
        return
    end
    --记录打牌ID，用于重复处理
    this.playCardId = clickCardItem.cardData.id
    --清除发送的操作数据
    this.operationData = nil
    --处理打牌
    local cardKey = clickCardItem.cardData.key
    MahjongDataMgr.operateState = MahjongOperateState.Waiting

    --清除打的牌，位置不变，然后飞牌，移动
    clickCardItem:Clear()

    --发送打牌
    this.SendPlayCard(this.playCardId)
    --更新胡牌提示
    MahjongDataMgr.UpdateHuTips(cardKey)
    --更新模拟打牌
    this.UpdateSimulatePlayCardDisplay()
    
    --播放音效
    MahjongPlayCardMgr.PlayCardSound(MahjongDataMgr.userId, cardKey)
    --关闭操作界面
    PanelManager.Close(MahjongPanelConfig.Operation)
    --关闭听牌提示界面
    PanelManager.Close(MahjongPanelConfig.HuTips)
end

--清除打牌信息，跟飞牌数据是两部分，清除打牌数据，主要是停止重复发送打牌
function MahjongPlayCardHelper.Clear()
    Log(">> MahjongPlayCardHelper > Clear")
    this.playCardId = nil
    this.operationData = nil
end

--发送打牌
function MahjongPlayCardHelper.SendPlayCard(cardId)
    --Log(">> MahjongPlayCardHelper.SendPlayCard > cardId = " .. cardId)
    MahjongCommand.SendPlayCard(cardId)
end

--================================================================
--模拟打牌
function MahjongPlayCardHelper.UpdateSimulatePlayCardDisplay()

    if this.playCardId == nil then
        return
    end

    local mainPlayer = MahjongPlayCardMgr.GetMainPlayer()

    local length = 0
    local cardData = nil
    local playerCardData = MahjongPlayCardMgr.playerCardDatas[1]

    local leftCards = {}
    local pushCards = {}
    local midCards = {}

    --处理左手牌
    length = #playerCardData.leftCards
    for i = 1, length do
        table.insert(leftCards, playerCardData.leftCards[i])
    end

    --拷贝打出去的牌
    length = #playerCardData.pushCards
    for i = 1, length do
        table.insert(pushCards, playerCardData.pushCards[i])
    end

    if this.playCardId ~= 0 then
        --添加到打出去的牌中
        table.insert(pushCards, MahjongDataMgr.GetCardData(this.playCardId))
    end

    --先对比右手牌，如果打的是右手牌，就不需要插入到中间牌去排序
    if playerCardData.rightCard ~= nil and this.playCardId == playerCardData.rightCard.id then
        length = #playerCardData.midCards
        for i = 1, length do
            cardData = playerCardData.midCards[i]
            table.insert(midCards, cardData)
        end
    else
        length = #playerCardData.midCards
        for i = 1, length do
            cardData = playerCardData.midCards[i]
            if this.playCardId ~= cardData.id then
                table.insert(midCards, cardData)
            end
        end
        if playerCardData.rightCard ~= nil then
            table.insert(midCards, playerCardData.rightCard)
        end
        --Log(midCards)
        --Log("===========================================================================1")
        --排序
        table.sort(midCards, MahjongUtil.CardDataSort)
        --Log("===========================================================================2")
        --Log(midCards)
    end

    MahjongPlayCardMgr.UpdateSimulateData(this.playCardId, leftCards, midCards, nil, pushCards)
end
--================================================================
--
--检测是否存在打了的牌
function MahjongPlayCardHelper.CheckExistPlayCard(midCards, rightCard)
    if this.playCardId == nil then
        return false
    end
    if rightCard ~= nil and rightCard.id == this.playCardId then
        return true
    end

    local length = #midCards
    local cardData = nil
    for i = 1, length do
        cardData = midCards[i]
        if cardData ~= nil and cardData.id == this.playCardId then
            return true
        end
    end

    --没有对比到数据，则直接情况当前数据
    this.playCardId = nil
    return false
end

--重发打牌
function MahjongPlayCardHelper.RepeatSendPlayCard()
    if this.playCardId ~= nil then
        this.SendPlayCard(this.playCardId)
    end
end

--缓存发送的操作
function MahjongPlayCardHelper.CacheSendOperation(operationData)
    this.operationData = operationData
end

--检测是否存在发送了的操作
function MahjongPlayCardHelper.CheckExistOperation(operation)
    if this.operationData == nil then
        return false
    end

    if operation ~= nil and IsTable(operation) then
        local length = #operation
        local tempData = nil
        for i = 1, length do
            if MahjongUtil.EqualsOperationData(tempData, this.operationData) then
                return true
            end
        end
    end
    this.operationData = nil
    return false
end

--重发操作
function MahjongPlayCardHelper.RepeatSendOperation()
    if this.operationData ~= nil then
        local data = this.operationData
        MahjongCommand.SendOperate(data.type, data.from, data.k1, data.k2, data.k3, data.k4)
    end
end