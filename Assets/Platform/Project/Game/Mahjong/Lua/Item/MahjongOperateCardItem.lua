--杠碰等
MahjongOperateCardItem = {
    enabled = false,
    gameObject = nil,
    seatIndex = 1,
    cardItems = nil,
    direction = nil,
    --杠碰牌的主Key
    cardKey = MahjongConst.INVALID_CARD_KEY,
    --牌是否选中
    isSelected = false,
}

local meta = { __index = MahjongOperateCardItem }

function MahjongOperateCardItem.New()
    local o = {}
    setmetatable(o, meta)
    o.cardItems = {}
    return o
end

function MahjongOperateCardItem:Clear()
    if self.enabled == false then
        return
    end
    self.enabled = false
    self.cardKey = MahjongConst.INVALID_CARD_KEY

    local length = #self.cardItems
    for i = 1, length do
        self.cardItems[i]:Clear()
    end
    if self.gameObject ~= nil then
        UIUtil.SetActive(self.gameObject, false)
    end

    if self.direction ~= nil then
        UIUtil.SetActive(self.direction, false)
    end
end

function MahjongOperateCardItem:Destroy()

end

--================================================================
--
function MahjongOperateCardItem:Init(gameObject, seatIndex)
    self.gameObject = gameObject
    self.seatIndex = seatIndex

    local trans = self.gameObject.transform
    local itemGo = nil
    local item = nil
    for i = 1, 4 do
        local name = "Card_" .. i
        itemGo = trans:Find(name).gameObject
        item = MahjongCardItem.New()
        item:Init(itemGo, MahjongCardDisplayType.Operate, self.seatIndex)
        table.insert(self.cardItems, item)
    end

    self.direction = trans:Find("Direction").gameObject

    UIUtil.SetActive(self.direction, false)

    self.cardItems[4]:Hide()
end

---设置桌面左手牌（碰杠吃 堆叠位）
---handIndex 第几次（碰杠吃 堆叠位）
function MahjongOperateCardItem:SetData(data, handIndex)
    local isGang = false
    local cardData = nil
    self.cardKey = MahjongConst.INVALID_CARD_KEY
    if data.type == MahjongOperateCode.PENG then
        cardData = MahjongDataMgr.GetCardData(data.k1)
        self.cardKey = cardData.key
        for i = 1, 3 do
            self.cardItems[i]:SetData(cardData, MahjongCardDisplayType.Operate, handIndex, i)
        end
        self.cardItems[4]:Hide()
    elseif data.type == MahjongOperateCode.FlyChickenChi then
        local cardData1 = MahjongDataMgr.GetCardData(data.k1)
        local cardData2 = MahjongDataMgr.GetCardData(data.k2)
        local cardData3 = MahjongDataMgr.GetCardData(data.k3)
        self.cardKey = cardData1.key
        self.cardItems[1]:SetData(cardData1, MahjongCardDisplayType.Operate, handIndex, 1)
        self.cardItems[2]:SetData(cardData2, MahjongCardDisplayType.Operate, handIndex, 2)
        self.cardItems[3]:SetData(cardData3, MahjongCardDisplayType.Operate, handIndex, 3)
        self.cardItems[4]:Hide()
    elseif data.type == MahjongOperateCode.GANG or data.type == MahjongOperateCode.GANG_IN then
        isGang = true
        cardData = MahjongDataMgr.GetCardData(data.k1)
        self.cardKey = cardData.key
        for i = 1, 4 do
            self.cardItems[i]:SetData(cardData, MahjongCardDisplayType.Operate, handIndex, i)
        end
        -- self.cardItems[4]:SetData(cardData, nil, handIndex, 4)
    elseif data.type == MahjongOperateCode.GANG_ALL_IN then
        --背面3张，明第4张
        isGang = true
        cardData = MahjongDataMgr.UnknownCardData
        for i = 1, 3 do
            --如果是盖着的牌，就直接传-1
            self.cardItems[i]:SetData(cardData, MahjongCardDisplayType.Cover, handIndex, i)
        end
        cardData = MahjongDataMgr.GetCardData(data.k1)
        self.cardKey = cardData.key
        self.cardItems[4]:SetData(cardData, nil, handIndex, 4)
    elseif data.type == MahjongOperateCode.SPC_PENG then
        --幺鸡碰
        cardData = MahjongDataMgr.GetCardData(data.k1)
        self.cardKey = cardData.key
        --
        self:SetItem(self.cardItems[1], data.k1, handIndex, 1)
        self:SetItem(self.cardItems[2], data.k2, handIndex, 2)
        self:SetItem(self.cardItems[3], data.k3, handIndex, 3)
        self.cardItems[4]:Hide()
    elseif data.type == MahjongOperateCode.SPC_GANG_ALL_IN then
        --幺鸡暗杠，幺鸡和第4张明牌
        --幺鸡玩法，第一个幺鸡放第一个位置，第二个幺鸡放第3个位置，第三个幺鸡放第2位置，主牌放第4个位置
        isGang = true
        self:HandleYaoJiGang(data, true, handIndex)
    else
        --其他幺鸡杠全是明牌
        isGang = true
        self:HandleYaoJiGang(data, false, handIndex)
    end

    if self.direction ~= nil then
        UIUtil.SetActive(self.direction, isGang)
    end

    if isGang then
        self:UpdateFromDirection(data.from)
    end

    if self.seatIndex == MahjongSeatIndex.Seat1 or self.seatIndex == MahjongSeatIndex.Seat3 then
        self:SetCardItemSiblingIndex(handIndex)
    else
        self:SetCardItemPosition(handIndex)
    end
    
    self:Show()
end

--设置 1号位、3号位第4手碰杠吃盖牌的预制体层级顺序 2314
function MahjongOperateCardItem:SetCardItemSiblingIndex(handIndex)
    if handIndex > 3 then
        UIUtil.SetSiblingIndex(self.cardItems[2].gameObject, 1)
        UIUtil.SetSiblingIndex(self.cardItems[3].gameObject, 2)
        UIUtil.SetSiblingIndex(self.cardItems[1].gameObject, 3)
        UIUtil.SetSiblingIndex(self.cardItems[4].gameObject, 4)
        UIUtil.SetSiblingIndex(self.direction, 5)
    end

    --1号位玩家杠牌，上方盖着的牌坐标会有微差
    if self.seatIndex == MahjongSeatIndex.Seat1 and handIndex > 1 then
        self.cardItems[4]:SetPosition(66 + handIndex, 32)
    end
end

--
function MahjongOperateCardItem:GetCardItemIndexByLayIndex(itemIndex)
    local layIndex = itemIndex
    if self.seatIndex == MahjongSeatIndex.Seat2 then
        if itemIndex == 1 then
            layIndex = 3
        elseif itemIndex == 2 then
            layIndex = 1
        elseif itemIndex == 3 then
            layIndex = 2
        end
    elseif self.seatIndex == MahjongSeatIndex.Seat4 then
        if itemIndex == 2 then
            layIndex = 3
        elseif itemIndex == 3 then
            layIndex = 2
        end
    end
    return layIndex
end

--设置 碰杠吃盖牌的坐标
function MahjongOperateCardItem:SetCardItemPosition(handIndex)
    --上限4手碰杠吃盖，2号位为4号位镜像翻转， 4号位玩家 碰杠吃盖 资源从小到大，2号位玩家 碰杠吃盖 资源从大到小
    handIndex = self.seatIndex == MahjongSeatIndex.Seat4 and handIndex or 5 - handIndex 
    local pos = nil
    local layIndex = 1
    for i = 1, 4, 1 do
        layIndex = self:GetCardItemIndexByLayIndex(i)
        pos = MahjongLeftOperateCardPos[handIndex][layIndex]
        self.cardItems[i]:SetPosition(pos[1], pos[2])
    end
end

--设置数据
function MahjongOperateCardItem:SetItem(item, key, handIndex, layIndex)
    if key == nil then
        key = -1
    end
    local cardData = MahjongDataMgr.GetCardData(key)
    item:SetData(cardData, MahjongCardDisplayType.Operate, handIndex, layIndex)
end

--处理幺鸡杠
function MahjongOperateCardItem:HandleYaoJiGang(data, isAnGang, handIndex)
    --临时牌数据
    local tempData = nil
    --主牌数据
    local cardData = nil
    --听用数量
    local tingYongNum = 0

    local cards = {}
    table.insert(cards, MahjongDataMgr.GetCardData(data.k1))
    table.insert(cards, MahjongDataMgr.GetCardData(data.k2))
    table.insert(cards, MahjongDataMgr.GetCardData(data.k3))
    table.insert(cards, MahjongDataMgr.GetCardData(data.k4))

    for i = 1, 4 do
        tempData = cards[i]
        if MahjongUtil.IsTingYongCard(tempData.key) then
            tempData.isTingYong = true
            tingYongNum = tingYongNum + 1
        else
            tempData.isTingYong = false
            cardData = tempData
        end
        tempData:UpdateSort()
    end
    table.sort(cards, MahjongUtil.CardDataSort)
    self.cardKey = cardData.key

    if isAnGang then
        --如果是暗杠，非幺鸡和非第4张都要盖住显示，cardKey为-1，防止换牌后设置相同的Key，不翻牌处理
        for i = 1, 3 do
            tempData = cards[i]
            if tempData.isTingYong then
                self.cardItems[i]:SetData(tempData, MahjongCardDisplayType.Operate, handIndex, i)
            else
                self.cardItems[i]:SetData(MahjongDataMgr.UnknownCardData, MahjongCardDisplayType.Cover, handIndex, i)
            end
        end
        self.cardItems[4]:SetData(cardData, MahjongCardDisplayType.Operate, handIndex, 4)
    else
        for i = 1, 4 do
            self.cardItems[i]:SetData(cards[i], MahjongCardDisplayType.Operate, handIndex, i)
        end
    end
end

function MahjongOperateCardItem:SetPosition(x, y)
    if self.gameObject ~= nil then
        UIUtil.SetAnchoredPosition(self.gameObject, x, y)
    end
end

function MahjongOperateCardItem:Show()
    if self.enabled == true then
        --如果开启了，就不用在进去处理
        return
    end
    self.enabled = true
    if self.gameObject ~= nil then
        UIUtil.SetActive(self.gameObject, true)
    end
end

function MahjongOperateCardItem:Hide()
    if self.enabled == false then
        return
    end
    self.enabled = false
    if self.gameObject ~= nil then
        UIUtil.SetActive(self.gameObject, false)
    end
end

--更新来源方向
function MahjongOperateCardItem:UpdateFromDirection(fromSeatNumber)
    local index = self.seatIndex
    if fromSeatNumber > 0 then
        index = MahjongUtil.GetIndexBySeatNumber(fromSeatNumber)
    end
    if index < 1 and index > 4 then
        index = self.seatIndex
    end
    local angle = MahjongOperateDirectionAngle[index]
    UIUtil.SetRotation(self.direction, 0, 0, angle)
end

--设置点击选中
function MahjongOperateCardItem:SetSelected(value)
    if self.enabled == false then
        return
    end
    if self.isSelected ~= value then
        self.isSelected = value
        local length = #self.cardItems
        local cardItem = nil
        for i = 1, length do
            cardItem = self.cardItems[i]
            if cardItem.cardData ~= nil and cardItem.cardData.key == self.cardKey then
                cardItem:SetSelected(value)
            end
        end
    end
end