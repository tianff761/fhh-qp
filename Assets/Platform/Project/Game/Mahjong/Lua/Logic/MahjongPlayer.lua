--麻将牌局玩家
MahjongPlayer = {

    --玩家的座位序号，不需要清除
    seatIndex = 0,

    --------------------------------------------------------------------
    ----------------需要清除----------------
    --玩家的ID
    id = nil,
    --玩家的远端座位号
    seatNumber = nil,

    --操作的左手牌数据
    leftCards = nil,
    --操作牌的长度，不能使用operateCardsItems的长度来遍历
    leftCardsLength = 0,
    --手牌解析的数据
    midCards = nil,
    --新摸的牌，即右手牌
    rightCard = nil,
    --所有手牌对象，包括了手牌和摸的牌
    allHandCards = nil,
    --所有手牌数据长度，不能使用handCardsItems的长度来遍历
    allHandCardsLength = 0,

    --用于标识是否已经胡牌了
    isHu = false,
    --玩家的操作状态
    operateState = MahjongOperateState.None,
    --用于标记牌局结束后明牌的标识
    isDisplayCards = false,

    --用于标记是否初始化牌局的显示
    isInitCardDisplay = false,
    --------------------------------------------------------------------
    ----------------不需要清除----------------
    --是否是座位1的玩家
    isSeat1Player = false,
    --出牌管理
    outCard = nil,
    --是否设置显示项在排序的上方
    isSetAsFirstSibling = false,
    --配置数据
    configData = nil,
    --------------------------------------------------------------------
    ----------------显示对象----------------
    --打牌相关的跟节点
    playingCardNode = nil,
    playingCardNodeRectTrans = nil,

    --操作牌的节点
    operateCardsNode = nil,
    operateCardsNodeRectTrans = nil,
    operateCardsItemPrefab = nil,
    --操作牌节点的宽度
    operateCardsNodeWidth = 0,

    --手牌的节点
    handCardsNode = nil,
    handCardsNodeRectTrans = nil,
    handCardsCardItemPrefab = nil,
    --手牌节点的宽度
    handCardsNodeWidth = 0,
    --手牌中的胡牌对象，只针对玩家1
    handCardsHuCardGameobject = nil,

    --胡牌显示的节点
    huCardsNode = nil,
    huCardsNodeRectTrans = nil,
    huCardsItemPrefab = nil,

    --------------------------------------------------------------------
    --玩家1的打牌提示箭头相关
    playCardArrowNode = nil,
    playCardArrowNodeRectTrans = nil,
    playCardArrowContentNode = nil,
    playCardArrowItemPrefab = nil,
    playCardArrowTweener = nil,
    --------------------------------------------------------------------
    --操作项集合，不需要清除
    operateCardsItems = nil,
    --所有手牌显示集合，不需要清除
    allHandCardsItems = nil,

    --玩家1在没有明牌情况下的胡牌的显示项
    handCardsHuCardItem = nil,
    --胡牌的显示项集合，不需要清除
    huCardsItems = nil,
    --------------------------------------------------------------------
    xCardWidth = 0,
    yCardWidth = 0,
    xNewCardGap = 0,
    yNewCardGap = 0,
    xOperateWidth = 0,
    yOperateWidth = 0,
    xHuWidth = 0,
    yHuWidth = 0,
}

local meta = { __index = MahjongPlayer }

function MahjongPlayer.New()
    local o = {}
    setmetatable(o, meta)
    o:InitProperty()
    return o
end

--初始属性数据
function MahjongPlayer:InitProperty()
    self.leftCards = {}
    self.operateCardsItems = {}

    self.midCards = {}
    self.allHandCards = {}
    self.allHandCardsItems = {}

    self.huCardsItems = {}

    self.outCard = MahjongOutCard.New()
end

--数据重置，用于小局结束后处理
function MahjongPlayer:Reset()
    --Log(">> MahjongPlayer > Reset > seatIndex = " .. self.seatIndex)
    self.leftCards = {}
    self.leftCardsLength = 0
    self.midCards = {}
    self.rightCard = nil
    self.allHandCards = {}
    self.allHandCardsLength = 0

    self.isHu = false
    self.operateState = MahjongOperateState.None
    self.isDisplayCards = false
    self.isInitCardDisplay = false

    local length = #self.operateCardsItems
    --清除操作项的显示项
    local operateCardsItem = nil
    for i = 1, length do
        operateCardsItem = self.operateCardsItems[i]
        if operateCardsItem ~= nil then
            operateCardsItem:Clear()
        end
    end

    --清除手牌的显示项
    local cardItem = nil
    length = #self.allHandCardsItems
    for i = 1, length do
        cardItem = self.allHandCardsItems[i]
        if cardItem ~= nil then
            cardItem:Clear()
        end
    end
    self:ClearHuCards()

    if self.seatIndex ~= MahjongSeatIndex.Seat1 then
        self:SortHandCardsReset()
        self:SortHuCardsReset()
    end

    self.outCard:Clear()

end

--小局结算后手牌排序重置
function MahjongPlayer:SortHandCardsReset()
    local cardItem = nil
    local length = #self.allHandCardsItems
    for i = 1, length do
        cardItem = self.allHandCardsItems[i]
        if cardItem ~= nil then
            if self.seatIndex == MahjongSeatIndex.Seat2 then --正序
                UIUtil.SetSiblingIndex(cardItem.gameObject, i)
            elseif self.seatIndex == MahjongSeatIndex.Seat3 then --1-7 正序 8-13 插序
                if i <= 7 then
                    UIUtil.SetSiblingIndex(cardItem.gameObject, i)
                else
                    UIUtil.SetSiblingIndex(cardItem.gameObject, 7)
                end
            elseif self.seatIndex == MahjongSeatIndex.Seat4 then --反序
                UIUtil.SetSiblingIndex(cardItem.gameObject, length + 1 - i)
            end
        end
    end
end

--小局结算后胡牌排序重置
function MahjongPlayer:SortHuCardsReset()
    local cardItem = nil
    local length = #self.huCardsItems
    for i = 1, length do
        cardItem = self.huCardsItems[i]
        if cardItem ~= nil then
            if self.seatIndex == MahjongSeatIndex.Seat2 then --正序
                UIUtil.SetSiblingIndex(cardItem.gameObject, i)
            elseif self.seatIndex == MahjongSeatIndex.Seat3 then --1-7 正序 8-13 插序
                if i <= 7 then
                    UIUtil.SetSiblingIndex(cardItem.gameObject, i)
                else
                    UIUtil.SetSiblingIndex(cardItem.gameObject, 7)
                end
            elseif self.seatIndex == MahjongSeatIndex.Seat4 then --反序
                UIUtil.SetSiblingIndex(cardItem.gameObject, length + 1 - i)
            end
        end
    end
end

--清除，即关闭时，不对UI相关对象清除，可以重复使用
function MahjongPlayer:Clear()
    --Log(">> MahjongPlayer > Clear > seatIndex = " .. self.seatIndex)
    self.id = nil
    self.seatNumber = nil

    self:Reset()
end

--清除胡的显示项
function MahjongPlayer:ClearHuCards()
    --清除玩家1未明牌时的胡牌显示项
    if self.handCardsHuCardItem ~= nil then
        self.handCardsHuCardItem:Clear()
    end

    local cardItem = nil
    --清除胡的显示项
    local length = #self.huCardsItems
    for i = 1, length do
        cardItem = self.huCardsItems[i]
        if cardItem ~= nil then
            cardItem:Clear()
        end
    end
end

--销毁，调用该方法后，所以的数据都应该清除
function MahjongPlayer:Destoy()
    self:Clear()
    --清除UI、GameObject对象
end

--================================================================
--
--设置UI节点
function MahjongPlayer:SetNode(transform)
    --Log(">> MahjongPlayer > SetNode > " .. self.seatIndex)
    local outCardNode = transform:Find("OutCard")
    local enlargeCardNode = transform:Find("EnlargeCard")
    self.outCard:SetNode(outCardNode, enlargeCardNode)

    self.playingCardNode = transform:Find("PlayingCard")
    self.playingCardNodeRectTrans = self.playingCardNode:GetComponent("RectTransform")

    self.operateCardsNode = self.playingCardNode:Find("OperateCards")
    self.operateCardsNodeRectTrans = self.operateCardsNode:GetComponent("RectTransform")
    self.operateCardsItemPrefab = self.operateCardsNode:Find("OperateCardItem").gameObject

    self.handCardsNode = self.playingCardNode:Find("HandCards")
    self.handCardsNodeRectTrans = self.handCardsNode:GetComponent("RectTransform")
    self.handCardsCardItemPrefab = self.handCardsNode:Find("CardItem").gameObject

    self.huCardsNode = self.playingCardNode:Find("HuCards")
    self.huCardsNodeRectTrans = self.huCardsNode:GetComponent("RectTransform")
    self.huCardsCardItemPrefab = self.huCardsNode:Find("CardItem").gameObject

    if self.isSeat1Player then
        self.handCardsHuCardGameobject = self.handCardsNode:Find("HuCardItem").gameObject

        self.playCardArrowNode = self.playingCardNode:Find("PlayCardArrow")
        self.playCardArrowNodeRectTrans = self.playCardArrowNode:GetComponent("RectTransform")
        self.playCardArrowContentNode = self.playCardArrowNode:Find("Content")
        self.playCardArrowItemPrefab = self.playCardArrowContentNode:Find("ArrowItem").gameObject
        self.playCardArrowTweener = self.playCardArrowContentNode:GetComponent("TweenPosition")
    end

end

---计算宽屏适配手牌比例
function MahjongPlayer:CalcHandCardWideAdapteScale()
    if not self.MahjongHandCardWideScreenAdaptScale and self.seatIndex == MahjongSeatIndex.Seat1 then
        local referenceResolution = AppConst.ReferenceResolution
        local screenWidth = ScenemMgr.width
        local screenHeight = ScenemMgr.height

        --unity Canvas分辨率为1280x720，这里改为1560x720
        -- local SixteenToNineScale = referenceResolution.x / referenceResolution.y
        local SixteenToNineScale = 1560 / referenceResolution.y

        local CurrentScreenScale = screenWidth / screenHeight
        self.MahjongHandCardWideScreenAdaptScale = CurrentScreenScale / SixteenToNineScale
    end
    return self.MahjongHandCardWideScreenAdaptScale or 1
end

--================================================================
--设置座位索引号，根据不同来显示不同的麻将牌
function MahjongPlayer:SetSeatIndex(index)
    --Log(">> MahjongPlayer > SetSeatIndex > index = " .. index)
    self.seatIndex = index
    self.configData = MahjongCardItemInfoConfig[index]
    self.outCard:SetSeatIndex(index)
    self.isSeat1Player = self.seatIndex == MahjongSeatIndex.Seat1
    self.isSetAsFirstSibling = self.seatIndex == MahjongSeatIndex.Seat3 or self.seatIndex == MahjongSeatIndex.Seat2

    self.xCardWidth = 0
    self.yCardWidth = 0
    self.xNewCardGap = 0
    self.yNewCardGap = 0
    self.xOperateWidth = 0
    self.yOperateWidth = 0
    self.xHuWidth = 0
    self.yHuWidth = 0

    if self.seatIndex == MahjongSeatIndex.Seat1 then
        self.xCardWidth = self.configData.CardWidth * self:CalcHandCardWideAdapteScale()
        self.xNewCardGap = self.configData.NewCardGap
        self.xOperateWidth = self.configData.OperateWidth
        self.xHuWidth = self.configData.HuWidth

        -- self.xCardWidth = 89 * self:CalcHandCardWideAdapteScale()
        -- self.xHuWidth = 74

    elseif self.seatIndex == MahjongSeatIndex.Seat2 then
        self.yCardWidth = self.configData.CardWidth
        self.yNewCardGap = self.configData.NewCardGap

        -- self.yCardWidth = 22
        self.interval = 7
        self.xOperateWidth = 30
        self.yOperateWidth = 90

    elseif self.seatIndex == MahjongSeatIndex.Seat3 then
        self.xCardWidth = -self.configData.CardWidth
        self.xNewCardGap = -self.configData.NewCardGap
        self.xOperateWidth = -self.configData.OperateWidth
        self.xHuWidth = -self.configData.HuWidth

        -- self.xNewCardGap = -40
        -- self.xCardWidth = -40
        -- self.xHuWidth = -40

    elseif self.seatIndex == MahjongSeatIndex.Seat4 then
        self.yCardWidth = -self.configData.CardWidth
        self.yNewCardGap = -self.configData.NewCardGap

        -- self.yCardWidth = -22
        self.interval = 7
        self.xOperateWidth = -30
        self.yOperateWidth = -90
    end
end

--更新牌局，调用该方法，都会刷新显示，参数isDisplayCards用于牌局结束后明牌使用
function MahjongPlayer:UpdateCards(state, leftCards, midCards, rightCard, isDisplayCards)

    --Log(">> ================MahjongPlayer > UpdateCards > self.seatIndex = " .. self.seatIndex)
    --Log(midCards)
    --存储数据
    self.operateState = state
    self.isHu = self.operateState == MahjongOperateState.Hu

    self.leftCards = leftCards
    self.leftCardsLength = #self.leftCards

    self.midCards = midCards
    self.rightCard = rightCard

    --处理所有的手牌
    self.allHandCards = {}
    local length = #self.midCards
    for i = 1, length do
        table.insert(self.allHandCards, self.midCards[i])
    end
    if self:IsNewCardValid() then
        table.insert(self.allHandCards, self.rightCard)
    end
    self.allHandCardsLength = #self.allHandCards

    --处理是否为明牌显示
    if isDisplayCards ~= nil then
        self.isDisplayCards = isDisplayCards
    else
        self.isDisplayCards = false
    end

    --更新显示
    self:UpdateCardsDisplay()
    --更新标识
    self.isInitCardDisplay = true
end

--更新打出去牌
function MahjongPlayer:UpdateOutCards(pushCards)
    self.outCard:UpdateData(pushCards)
end

--更新牌的显示
function MahjongPlayer:UpdateCardsDisplay()
    --是否是躺着的牌
    local isLieCards = false

    if MahjongDataMgr.isPlayback then
        if self.isSeat1Player then
            --回放时，1号玩家的牌都是竖着的
            if self.isHu then
                self:UpdateSeat1HandCardsHuCardItems()
            else
                self:UpdateHandCardsItems()
            end
        else
            self:UpdateHandCardsHuCardItemsByDisplay(true)
            isLieCards = true
        end
    else
        if self.isDisplayCards then
            self:UpdateHandCardsHuCardItemsByDisplay(true)
            --明牌时，都是躺着的牌
            isLieCards = true
        elseif self.isHu then
            --胡牌后，1号玩家还是竖着的牌，其他玩家则是躺着的牌
            if self.isSeat1Player then
                --更新玩家1的胡牌后牌的布局
                self:UpdateSeat1HandCardsHuCardItems()
            else
                self:UpdateHandCardsHuCardItemsByDisplay(false)
                isLieCards = true
            end
        else
            --更新手牌显示项
            self:UpdateHandCardsItems()
        end
    end

    --更新布局
    self:UpdateLayout(isLieCards)

    --更新操作牌的显示项
    self:UpdateOperateCardsItems()
end

--隐藏或者清除手牌项，包括摸的牌
function MahjongPlayer:HideHandCards()
    --清除手牌的显示项
    local cardItem = nil
    local length = #self.allHandCardsItems
    for i = 1, length do
        cardItem = self.allHandCardsItems[i]
        if cardItem ~= nil then
            cardItem:Clear()
        end
    end

    if self.handCardsHuCardItem ~= nil then
        self.handCardsHuCardItem:Clear()
    end
end

------------------------------------------------------------------
--更新布局
function MahjongPlayer:UpdateLayout(isLieCards)

    --坐标设置的方向
    local sign = 1
    --是都横排列
    local isHorizontal = true
    if self.seatIndex == MahjongSeatIndex.Seat2 then
        isHorizontal = false
    elseif self.seatIndex == MahjongSeatIndex.Seat3 then
        sign = -1
    elseif self.seatIndex == MahjongSeatIndex.Seat4 then
        sign = -1
        isHorizontal = false
    end

    self.operateCardsNodeWidth = 0
    self.handCardsNodeWidth = 0

    self.operateCardsNodeWidth = self.leftCardsLength * self.configData.OperateWidth

    local cardWidth = self.configData.CardWidth * self:CalcHandCardWideAdapteScale()
    --处理胡牌的宽度，如果是明牌，则直接处理明牌的宽度
    if isLieCards then
        cardWidth = self.configData.HuWidth
    end

    self.handCardsNodeWidth = self.allHandCardsLength * cardWidth

    --摸起的牌无效，也需要占一个位置，但是self.handCardsData中没有摸起的牌，则需要加上牌的宽度
    --出牌的时候，不需要添加摸牌的宽度；不是出牌的时候，且没有摸牌，才加一个占位宽度
    local isHaveNewCard = self:IsNewCardValid()
    if isHaveNewCard == false and self.operateState ~= MahjongOperateState.Play then
        self.handCardsNodeWidth = self.handCardsNodeWidth + cardWidth
    end

    local total = self.operateCardsNodeWidth + self.handCardsNodeWidth + self.configData.NewCardGap

    --1、3号位玩家
    if isHorizontal then
        if self.seatIndex == MahjongSeatIndex.Seat3 then
            local handCardPos = MahjongTopHandCardNodePos[self.leftCardsLength]
            UIUtil.SetAnchoredPosition(self.handCardsNodeRectTrans, handCardPos[1], handCardPos[2])
        else
            --设置HandCard节点的宽度或者高度
            UIUtil.SetWidth(self.playingCardNodeRectTrans, total)
            UIUtil.SetAnchoredPositionX(self.handCardsNodeRectTrans, self.operateCardsNodeWidth * sign)
        end
        
        --设置打牌提示的箭头节点位置
        if self.isSeat1Player then
            UIUtil.SetAnchoredPositionX(self.playCardArrowNodeRectTrans, self.operateCardsNodeWidth * sign)
        end

        --设置胡牌的布局
        if isLieCards then
            if self.seatIndex == MahjongSeatIndex.Seat1 then
                UIUtil.SetAnchoredPositionX(self.huCardsNodeRectTrans, self.operateCardsNodeWidth * sign)
            else
                local type_idx = not MahjongDataMgr.isPlayback and 1 or 2
                local huCardPos = MahjongTopHuCardNodePos[type_idx][self.leftCardsLength]
                UIUtil.SetAnchoredPosition(self.huCardsNodeRectTrans, huCardPos[1], huCardPos[2])
            end
        end

    --2、4位玩家
    else
        -- UIUtil.SetHeight(self.playingCardNodeRectTrans, total)

        -- UIUtil.SetAnchoredPositionY(self.handCardsNodeRectTrans, self.operateCardsNodeWidth * sign)
        if self.seatIndex == MahjongSeatIndex.Seat2 then
            local handCardPos = MahjongRightHandCardNodePos[self.leftCardsLength]
            UIUtil.SetAnchoredPosition(self.handCardsNodeRectTrans, handCardPos[1], handCardPos[2])
        end
    
        --设置胡牌的布局
        if isLieCards then
            local huCardPos = nil
            local type_idx = not MahjongDataMgr.isPlayback and 1 or 2
            if self.seatIndex == MahjongSeatIndex.Seat2 then
                huCardPos = MahjongRightHuCardNodePos[type_idx][self.leftCardsLength]
            else
                huCardPos = MahjongLeftHuCardNodePos[type_idx][self.leftCardsLength]
            end
            UIUtil.SetAnchoredPosition(self.huCardsNodeRectTrans, huCardPos[1], huCardPos[2])

            -- UIUtil.SetAnchoredPositionY(self.huCardsNodeRectTrans, self.operateCardsNodeWidth * sign)
        end

        local rotation_z = 0
        if MahjongDataMgr.isPlayback then
            rotation_z = self.seatIndex == MahjongSeatIndex.Seat2 and 1 or -1
        end
        if self.huCardsNode ~= nil then
            UIUtil.SetRotation(self.huCardsNode, 0, 0, rotation_z)
        end        
    end

end

--更新操作牌的显示 碰牌、杠牌显示
function MahjongPlayer:UpdateOperateCardsItems()

    local itemsLength = #self.operateCardsItems
    local operateCardsItem = nil

    for i = 1, self.leftCardsLength do
        if i <= itemsLength then
            --获取当前的对象设置
            operateCardsItem = self.operateCardsItems[i]
        else
            --新创建
            operateCardsItem = self:CreateOperateCardsItem(tostring(i))
        end
        operateCardsItem:SetData(self.leftCards[i], i)
        operateCardsItem:SetPosition((i - 1) * self.xOperateWidth, (i - 1) * self.yOperateWidth)
    end

    if self.leftCardsLength < itemsLength then
        --牌的数量小于item数量，隐藏多余的Item
        for i = self.leftCardsLength + 1, itemsLength do
            operateCardsItem = self.operateCardsItems[i]
            operateCardsItem:Clear()
        end
    end
end

--创建操作牌显示项
function MahjongPlayer:CreateOperateCardsItem(name)
    local obj = CreateGO(self.operateCardsItemPrefab, self.operateCardsNode, name)
    local operateCardsItem = MahjongOperateCardItem.New()
    operateCardsItem:Init(obj, self.seatIndex)
    table.insert(self.operateCardsItems, operateCardsItem)
    if self.isSetAsFirstSibling then
        UIUtil.SetAsFirstSibling(obj)
    end
    return operateCardsItem
end

--更新手牌显示，摸的牌摸的牌也在其中
function MahjongPlayer:UpdateHandCardsItems()
    --Log(">> ================MahjongPlayer > UpdateHandCardsItems > self.seatIndex = " .. self.seatIndex)
    --隐藏清除胡牌数据
    self:ClearHuCards()

    local itemsLength = #self.allHandCardsItems
    local tempHandCardsLength = self.allHandCardsLength

    --如果该出牌，或者摸起的牌有效，则最后一张牌需要添加间隔
    local isGapLastCard = false
    --是否拥有摸起的牌
    local isHaveNewCard = self:IsNewCardValid()
    if self.operateState == MahjongOperateState.Play or isHaveNewCard then
        --手牌长度出去摸气的牌不能小于1，故不做小于的判断
        tempHandCardsLength = tempHandCardsLength - 1
        isGapLastCard = true
    end

    --Log(">> ================MahjongPlayer > " .. tempHandCardsLength, itemsLength)
    local cardItem = nil
    local itemIndex = 0
    local cardData = nil
    local isValidCardData = false
    
    --玩家手中的牌
    for i = 1, tempHandCardsLength do
        cardData = self.allHandCards[i]
        --空对象不显示，玩家1的牌为-1也不显示
        if cardData ~= nil then
            if self.isSeat1Player then
                isValidCardData = cardData.id ~= -1
            else
                isValidCardData = true
            end
        else
            isValidCardData = false
        end

        if isValidCardData then
            itemIndex = itemIndex + 1
            if itemIndex <= itemsLength then
                --获取当前的对象设置
                cardItem = self.allHandCardsItems[itemIndex]
            else
                cardItem = self:CreateHandCardsItem(tostring(itemIndex))
            end
            cardItem:SetData(cardData, nil, itemIndex)

            if self.seatIndex == MahjongSeatIndex.Seat1 or self.seatIndex == MahjongSeatIndex.Seat3 then
                local deviation = 0 --手牌偏差值
                if self.seatIndex == MahjongSeatIndex.Seat3 then --3号位预制体索引 1-6 对应坐标索引 8-13， 预制体索引 7-13 对应 坐标索引 1-7
                    local posIndex = 14 - itemIndex
                    local pos = MahjongTopHandCardPosConfig[posIndex]
                    cardItem:SetPosition(pos[1], pos[2])
                else
                    cardItem:SetPosition((itemIndex - 1) * self.xCardWidth + deviation, (itemIndex - 1) * self.yCardWidth)
                end
            else
                local posIndex = itemIndex
                --2号位1-13对应2-14索引
                if self.seatIndex == MahjongSeatIndex.Seat2 then
                    posIndex = posIndex + 1
                --4号位1-13对应13-1索引
                elseif self.seatIndex == MahjongSeatIndex.Seat4 then
                    posIndex = 14 - posIndex
                end
                local pos = MahjongLeftHandCardPosConfig[posIndex]
                cardItem:SetPosition(pos[1], pos[2])
            end
           
            cardItem:SetCardScale(self:CalcHandCardWideAdapteScale())
            cardItem:SetIsNewCard(false)
        end
    end

    if isGapLastCard then
        local i = self.allHandCardsLength
        cardData = self.allHandCards[i]
        if cardData ~= nil then
            if self.isSeat1Player then
                isValidCardData = cardData.id ~= -1
            else
                isValidCardData = true
            end
        else
            isValidCardData = false
        end

        --玩家摸到的牌
        if isValidCardData then
            itemIndex = itemIndex + 1
            if itemIndex <= itemsLength then
                --获取当前的对象设置
                cardItem = self.allHandCardsItems[itemIndex]
            else
                cardItem = self:CreateHandCardsItem(tostring(itemIndex))
            end
            if cardItem ~= nil then
                if self.seatIndex == MahjongSeatIndex.Seat2 then
                    UIUtil.SetAsFirstSibling(cardItem.gameObject) --置顶
                    cardItem:SetData(cardData, nil, itemIndex)
                    cardItem:SetCardFrameSprite(14)
                    cardItem:SetPosition(5, 14)

                elseif self.seatIndex == MahjongSeatIndex.Seat3 then
                    UIUtil.SetAsFirstSibling(cardItem.gameObject) --置顶
                    cardItem:SetData(cardData, nil, itemIndex)
                    cardItem:SetCardFrameSprite(14)
                    cardItem:SetPosition(-560, 0)

                elseif self.seatIndex == MahjongSeatIndex.Seat4 then
                    UIUtil.SetAsLastSibling(cardItem.gameObject) --置底
                    cardItem:SetData(cardData, nil, itemIndex)
                    cardItem:SetCardFrameSprite(14)
                    cardItem:SetPosition(-115, -375)
                else
                    cardItem:SetData(cardData, nil, itemIndex)
                    cardItem:SetPosition((itemIndex - 1) * self.xCardWidth + self.xNewCardGap, (itemIndex - 1) * self.yCardWidth + self.yNewCardGap)
                end

                cardItem:SetCardScale(self:CalcHandCardWideAdapteScale())
                cardItem:SetIsNewCard(isHaveNewCard)

                if self.isSeat1Player then
                    --每次更新牌的时候，处理下1号玩家的层级
                    UIUtil.SetAsLastSibling(cardItem.gameObject)
                end
            end
        end
    end

    if itemIndex < itemsLength then
        --牌的数量小于item数量，隐藏多余的Item
        for i = itemIndex + 1, itemsLength do
            cardItem = self.allHandCardsItems[i]
            cardItem:Clear()
        end
    end
end

--创建手牌显示项
function MahjongPlayer:CreateHandCardsItem(name)
    local obj = CreateGO(self.handCardsCardItemPrefab, self.handCardsNode, name)
    local cardItem = MahjongCardItem.New()
    cardItem:Init(obj, MahjongCardDisplayType.Hand, self.seatIndex)
    table.insert(self.allHandCardsItems, cardItem)
    if self.isSeat1Player then
        --EventUtil.AddClick(obj, MahjongPlayCardMgr.OnHandCardItemClick)
        local itemHelper = obj:GetComponent("UIDownUpListener")
        itemHelper.onDown = MahjongPlayCardMgr.OnHandCardItemDown
        itemHelper.onUp = MahjongPlayCardMgr.OnHandCardItemUp
    end
    self:SetHandCardItemSort(obj, tonumber(name))
    return cardItem
end

--调整手牌预制体在节点中的排序
function MahjongPlayer:SetHandCardItemSort(obj, itemIndex)    
    if self.seatIndex == MahjongSeatIndex.Seat4 then
        UIUtil.SetAsFirstSibling(obj)
    end

    --1-7为正序，7-13为反序
    if self.seatIndex == MahjongSeatIndex.Seat3 and itemIndex >= 8 then
        UIUtil.SetSiblingIndex(obj, 7)
    end
end

--================================================================
--更新手牌胡牌显示，玩家1的胡牌后显示为手牌立着，胡牌的那张牌明牌
function MahjongPlayer:UpdateSeat1HandCardsHuCardItems()
    self:UpdateHandCardsItems()
    local cardItem = self.allHandCardsItems[self.allHandCardsLength]
    cardItem:Hide()

    if self.handCardsHuCardItem == nil then
        self.handCardsHuCardItem = MahjongCardItem.New()
        self.handCardsHuCardItem:Init(self.handCardsHuCardGameobject, MahjongCardDisplayType.Hu_Operation, self.seatIndex)
    end

    if self.isSetAsFirstSibling then
        UIUtil.SetAsFirstSibling(self.handCardsHuCardGameobject)
    else
        UIUtil.SetAsLastSibling(self.handCardsHuCardGameobject)
    end

    self.handCardsHuCardItem:SetData(cardItem.cardData, MahjongCardDisplayType.Hu_Operation, self.allHandCardsLength)
    self.handCardsHuCardItem:SetPosition(cardItem.x, cardItem.y)

    local playerData = MahjongDataMgr.playerDatas[self.seatIndex]
    if playerData ~= nil and playerData.huType ~= nil and playerData.huType > 0 then
        --播放胡牌操作牌特效
        MahjongAnimMgr.PlayHuPaiAnim(self.handCardsHuCardItem.transform, self.seatIndex)
    end
end

--通过是否明牌胡牌显示胡牌显示项信息
--isDisplayCards 是否是胡牌-明牌
function MahjongPlayer:UpdateHandCardsHuCardItemsByDisplay(isDisplayCards)

    --隐藏打牌时的手牌
    self:HideHandCards()

    --Log(">> MahjongPlayer > UpdateHandCardsHuCardItemsByDisplay > isDisplayCards = " .. tostring(isDisplayCards))
    local itemsLength = #self.huCardsItems
    local huCardItem = nil
    local tempHandCardsLength = self.allHandCardsLength
   
    if self:IsNewCardValid() then
        --如果有摸的牌，则摸得牌需要添加间隔
        tempHandCardsLength = tempHandCardsLength - 1
    end

    local cardDsiplayType = MahjongCardDisplayType.Cover
    if isDisplayCards then
        --如果是显示，就使用胡牌_手牌
        cardDsiplayType = MahjongCardDisplayType.Hu_Hand
    end

    local type_idx = cardDsiplayType == MahjongCardDisplayType.Cover and 1 or 2
    local posIndex = 0
    local pos = {}
    for i = 1, tempHandCardsLength do
        if i <= itemsLength then
            huCardItem = self.huCardsItems[i]
        else
            huCardItem = self:CreateHuCardsCardItem(tostring(i))
        end
        huCardItem:SetData(self.allHandCards[i], cardDsiplayType, i)

        posIndex = i
        if self.seatIndex == MahjongSeatIndex.Seat3 then
            posIndex = 14 - i
            pos = MahjongTopHuCardItemPosConfig[type_idx][posIndex]
            huCardItem:SetPosition(pos[1], pos[2])
        elseif self.seatIndex == MahjongSeatIndex.Seat1 then
            huCardItem:SetPosition((i - 1) * self.xHuWidth, (i - 1) * self.yHuWidth)
        else
            
            if cardDsiplayType == MahjongCardDisplayType.Cover then

                --2号位1-13对应2-14索引
                if self.seatIndex == MahjongSeatIndex.Seat2 then
                    posIndex = posIndex + 1
                --4号位1-13对应13-1索引
                elseif self.seatIndex == MahjongSeatIndex.Seat4 then
                    posIndex = 14 - posIndex
                end
               
                pos = MahjongLeftHuCardItemPosConfig[type_idx][posIndex]

            elseif cardDsiplayType == MahjongCardDisplayType.Hu_Hand then
                
                --2号位1-13对应13-1索引
                if self.seatIndex == MahjongSeatIndex.Seat2 then
                    -- posIndex = 14 - posIndex
                --4号位1-13对应1-13索引
                elseif self.seatIndex == MahjongSeatIndex.Seat4 then
                    posIndex = 14 - posIndex
                end
                pos = MahjongLeftHuCardItemPosConfig[type_idx][posIndex]

            end

            huCardItem:SetPosition(pos[1], pos[2])
        end
    end

    --如果有摸的牌，则摸得牌需要添加间隔,放在第14张牌的坐标上
    if tempHandCardsLength < self.allHandCardsLength then
        local i = self.allHandCardsLength
        if i <= itemsLength then
            --获取当前的对象设置
            huCardItem = self.huCardsItems[i]
        else
            huCardItem = self:CreateHuCardsCardItem(tostring(i))
        end
        huCardItem:SetData(self.allHandCards[i], MahjongCardDisplayType.Hu_Operation, i)

        if self.seatIndex == MahjongSeatIndex.Seat2 then

            if MahjongDataMgr.isPlayback then
                huCardItem:SetPosition(-14, -23)
            else
                huCardItem:SetPosition(-22, -47)
            end
            UIUtil.SetAsFirstSibling(huCardItem.gameObject)
        elseif self.seatIndex == MahjongSeatIndex.Seat3 then
            huCardItem:SetPosition(-560, 0)
            UIUtil.SetAsLastSibling(huCardItem.gameObject)
        elseif self.seatIndex == MahjongSeatIndex.Seat4 then
           
            if MahjongDataMgr.isPlayback then
                huCardItem:SetPosition(-130, -428)
            else
                huCardItem:SetPosition(-154, -442)
            end

            UIUtil.SetAsLastSibling(huCardItem.gameObject)
        else
            huCardItem:SetPosition((i - 1) * self.xHuWidth + self.xNewCardGap, (i - 1) * self.yHuWidth + self.yNewCardGap)
        end

        local playerData = MahjongDataMgr.playerDatas[self.seatIndex]
        if playerData ~= nil and playerData.huType ~= nil and playerData.huType > 0 then
            --播放胡牌操作牌特效
            MahjongAnimMgr.PlayHuPaiAnim(huCardItem.transform, self.seatIndex)
        end
    end

    --牌的数量小于item数量，隐藏多余的Item
    if self.allHandCardsLength < itemsLength then
        for i = self.allHandCardsLength + 1, itemsLength do
            huCardItem = self.huCardsItems[i]
            huCardItem:Clear()
        end
    end
end

--创建胡牌的显示项
function MahjongPlayer:CreateHuCardsCardItem(name)
    local obj = CreateGO(self.huCardsCardItemPrefab, self.huCardsNode, name)
    local huCardItem = MahjongCardItem.New()
    huCardItem:Init(obj, MahjongCardDisplayType.Cover, self.seatIndex)
    table.insert(self.huCardsItems, huCardItem)
    -- if self.isSetAsFirstSibling then
    --     UIUtil.SetAsFirstSibling(obj)
    -- end
    self:SetHuCardItemSort(obj, tonumber(name))
    return huCardItem
end

--调整胡牌预制体在节点中的排序
function MahjongPlayer:SetHuCardItemSort(obj, itemIndex)    
    if self.seatIndex == MahjongSeatIndex.Seat4 then
        UIUtil.SetAsFirstSibling(obj)
    end
    --1-6为正序，7-13为反序
    if self.seatIndex == MahjongSeatIndex.Seat3 and itemIndex >= 7 then
        UIUtil.SetSiblingIndex(obj, 7)
    end
end

--===========================================================
--===========================================================
--摸的牌是否有效，即是否存在摸的牌
function MahjongPlayer:IsNewCardValid()
    return self.rightCard ~= nil
end

--===========================================================
--
--设置选中的牌，玩家自己提起牌寻找相同的牌
function MahjongPlayer:SetSelectedOperateCard(cardKey)
    if self.leftCardsLength < 1 then
        return
    end
    local operateCardItem = nil
    for i = 1, self.leftCardsLength do
        operateCardItem = self.operateCardsItems[i]
        if operateCardItem ~= nil then
            operateCardItem:SetSelected(operateCardItem.cardKey == cardKey)
        end
    end
end

--清除选中的牌，用于刷新牌时，或者主动清除
function MahjongPlayer:ClearSelectedOperateCard()
    if self.leftCardsLength < 1 then
        return
    end
    local operateCardItem = nil
    for i = 1, self.leftCardsLength do
        operateCardItem = self.operateCardsItems[i]
        if operateCardItem ~= nil then
            operateCardItem:SetSelected(false)
        end
    end
end

--设置胡牌的选中，针对其他3位玩家
function MahjongPlayer:SetSelectedHuCard(cardKey)
    if self.isHu then
        local huCardItem = self.huCardsItems[self.allHandCardsLength]
        if huCardItem ~= nil and huCardItem.cardData ~= nil then
            huCardItem:SetSelected(huCardItem.cardData.key == cardKey)
        end
    end
end

function MahjongPlayer:ClearSelectedHuCard()
    if self.isHu then
        local huCardItem = self.huCardsItems[self.allHandCardsLength]
        if huCardItem ~= nil then
            huCardItem:SetSelected(false)
        end
    end
end