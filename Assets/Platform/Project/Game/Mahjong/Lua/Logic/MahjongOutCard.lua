--麻将打出去的牌管理
MahjongOutCard = {
    gameObject = nil,
    --玩家的座位序号，不需要清除
    seatIndex = 0,

    --------------------------------------------------------------------
    --是否是横排序
    isHorizontal = true,
    --配置数据
    configData = nil,
    --牌宽，用于计算
    xWidth = 0,
    --牌高，用于计算
    yWidth = 0,
    --纵排序，横向牌间距
    interval = 0,
    --item的父节点
    cardItemParentNode = {},
    --item的Prefab
    cardItemPrefab = nil,
    --item集合
    cardItems = nil,
    --坐标
    x = 0,
    --坐标
    y = 0,

    --================
    --打出的牌对象
    outCards = nil,
    --数据长度，出牌总数
    outCardsLength = 0,

    --================  
    --第一行的最大列数
    fristRowMaxCol = 1,
    --第一行的麻将数
    row1Num = 1,
    --第二行的麻将数
    row2Num = 2,
    --第三行的麻将数
    row3Num = 3,
    --第四行的麻将数
    row4Num = 4,
}

local meta = { __index = MahjongOutCard }

function MahjongOutCard.New()
    local o = {}
    setmetatable(o, meta)
    o.outCards = {}
    o.cardItems = {}
    return o
end

function MahjongOutCard:Clear()
    self.fristRowMaxCol = 1
    self.outCards = {}
    self.outCardsLength = 0
    local length = #self.cardItems
    for i = 1, length do
        self.cardItems[i]:Clear()
    end
    self:StopEnlargeTimer()
    self:ClearEnlarge()
end

function MahjongOutCard:SetSeatIndex(seatIndex)
    self.seatIndex = seatIndex
    self.configData = MahjongCardItemInfoConfig[self.seatIndex]

    if self.seatIndex == MahjongSeatIndex.Seat1 then
        self.isHorizontal = true
        self.xWidth = self.configData.OutWidth
        self.yWidth = -self.configData.OutHeight
        -- self.xWidth = 54
        -- self.yWidth = -50
    elseif self.seatIndex == MahjongSeatIndex.Seat2 then
        self.isHorizontal = false
        self.xWidth = -self.configData.OutHeight
        self.yWidth = -self.configData.OutWidth
        -- self.xWidth = -42
        -- self.yWidth = -6
        self.interval = 58
    elseif self.seatIndex == MahjongSeatIndex.Seat3 then
        self.isHorizontal = true
        self.xWidth = -self.configData.OutWidth
        self.yWidth = self.configData.OutHeight
        -- self.xWidth = -48
        -- self.yWidth = 41
    elseif self.seatIndex == MahjongSeatIndex.Seat4 then
        self.isHorizontal = false
        self.xWidth = -self.configData.OutHeight
        self.yWidth = -self.configData.OutWidth
        -- self.xWidth = -42
        -- self.yWidth = -6
        self.interval = 58
    end
end

function MahjongOutCard:SetNode(transform, enlargeCardNode)
    -- self.cardItemParentNode = transform
    self.cardItemParentNode[self.seatIndex] = {}
    for i = 1, 4, 1 do
        self.cardItemParentNode[self.seatIndex][i] = transform:Find("OutCard_"..i)
    end

    self.enlargeCardNode = enlargeCardNode
    self.outCardrRect = transform:GetComponent("RectTransform")
    local anchoredPosition = self.outCardrRect.anchoredPosition
    self.x = anchoredPosition.x
    self.y = anchoredPosition.y
    self.cardItemPrefab = transform:Find("CardItem").gameObject
end

--初始行数的处理
function MahjongOutCard:InitRowNum()
    --二人麻将，每行出牌书为11张，三人、四人麻将则为9张
    self.fristRowMaxCol = MahjongDataMgr.playerTotal > 2 and Mahjong.OUT_CARD_FRIST_ROW_MAX_COL or 11
    self.row1Num = self.fristRowMaxCol
    self.row2Num = self.fristRowMaxCol * 2
    self.row3Num = self.fristRowMaxCol * 3
    self.row4Num = self.fristRowMaxCol * 4

    if self.seatIndex == MahjongSeatIndex.Seat1 then
        self.y = MahjongDataMgr.playerTotal == 4 and -100 or -30 
    elseif self.seatIndex == MahjongSeatIndex.Seat2 then
        self.x = MahjongDataMgr.playerTotal == 4 and 265 or 245
    elseif self.seatIndex == MahjongSeatIndex.Seat3 then
        self.y = MahjongDataMgr.playerTotal == 4 and 170 or 120

        --4人麻将，3号位出牌大小缩小为0.95
        local size = MahjongDataMgr.playerTotal == 2 and 1 or 0.95
        UIUtil.SetLocalScale(self.outCardrRect.gameObject, size, size, 1)
    elseif self.seatIndex == MahjongSeatIndex.Seat4 then
        self.x = MahjongDataMgr.playerTotal == 4 and -265 or -255
    end
    UIUtil.SetAnchoredPosition(self.outCardrRect.gameObject, self.x, self.y)
end

--设置数据
function MahjongOutCard:UpdateData(outCards)
    self.outCards = outCards
    self.outCardsLength = #self.outCards
    Log(self.seatIndex.."号位玩家出牌更新，总长度为"..self.outCardsLength)
    if self.fristRowMaxCol == 1 then
        self:InitRowNum()
    end
   
    self:UpdateOutCardsItems()
end

function MahjongOutCard:InstantiateNewOutCard(row, column)
    local obj = CreateGO(self.cardItemPrefab, self.cardItemParentNode[self.seatIndex][row], row.."_"..column)
    local cardItem = MahjongOutCardItem.New()
    cardItem:Init(obj, MahjongCardDisplayType.Display, self.seatIndex)
    table.insert(self.cardItems, cardItem)

    self:SetCardItemSort(obj, row, column)
    return cardItem
end

--调整预制体在节点中的排序
function MahjongOutCard:SetCardItemSort(obj, row, column)
    if self.seatIndex == MahjongSeatIndex.Seat1 or self.seatIndex == MahjongSeatIndex.Seat3 then
        local index = MahjongDataMgr.playerTotal == 2 and 6 or 5 --二人麻将单行11张牌，第7张牌开始倒序
        if column > index then
            UIUtil.SetAsFirstSibling(obj)
        end
    elseif self.seatIndex == MahjongSeatIndex.Seat2 then
        UIUtil.SetAsFirstSibling(obj)
    end
end

--更新打出牌的显示项
function MahjongOutCard:UpdateOutCardsItems()

    local itemsLength = #self.cardItems

    local cardItem = nil

    local column = 0 --列数
    local row = 0 --行数
    --每行的开始坐标
    local beginPosition = 0

    for i = 1, self.outCardsLength do
        local isNew = false
        row, column, beginPosition = self:GetOutCardRowCol(row, column, beginPosition, i)
        if i <= itemsLength then
            --获取当前的对象设置
            cardItem = self.cardItems[i]
        else
            --新创建
            isNew = true
            cardItem = self:InstantiateNewOutCard(row, column)
        end
        self:UpdateOutCardsPos(cardItem, row - 1, column - 1, beginPosition, isNew, i)
        cardItem:SetData(self.outCards[i], nil, row, column)
    end
    
    if self.outCardsLength < itemsLength then
        --牌的数量小于item数量，隐藏多余的Item
        for i = self.outCardsLength + 1, itemsLength do
            cardItem = self.cardItems[i]
            cardItem:Clear()
        end
    end
end

--获取当前牌对应的行数，列数
function MahjongOutCard:GetOutCardRowCol(row, column, beginPosition, i)
    if i <= self.row1Num then
        --第一行，即索引0
        row = 0
        column = i - 1
        beginPosition = -(self.xWidth * (self.row1Num - 1)) / 2
    elseif i <= self.row2Num then
        row = 1
        column = i - self.row1Num - 1
        -- beginPosition = -((self.xWidth + 2) * (self.row2Num - self.row1Num - 1)) / 2
        beginPosition = -(self.xWidth * (self.row1Num - 1)) / 2
    elseif i <= self.row3Num then
        row = 2
        column = i - self.row2Num - 1
        -- beginPosition = -((self.xWidth + 4) * (self.row3Num - self.row2Num - 1)) / 2
        beginPosition = -(self.xWidth * (self.row1Num - 1)) / 2
    elseif i <= self.row4Num then
        row = 3
        column = i - self.row3Num - 1
        -- beginPosition = -((self.xWidth + 6) * (self.row4Num - self.row3Num - 1)) / 2
        beginPosition = -(self.xWidth * (self.row1Num - 1)) / 2
    end
    return row + 1, column + 1, beginPosition
end


function MahjongOutCard:UpdateOutCardsPos(cardItem, row, column, beginPosition, isNew, i)
    if self.seatIndex ~= MahjongSeatIndex.Seat1 then
        self:SetEnlargeOutCardEffect(self, cardItem, isNew, i)
    end
    if self.isHorizontal then
        cardItem:SetPosition(beginPosition + column * self.xWidth, 0)
        -- cardItem:SetPosition(beginPosition + column * (self.xWidth + row * 2) + deviation, row * self.yWidth)
    else
        local cardPosIndex = column + 1 --2,4号位玩家为镜像设置，且2号位出牌顺序为从下往上，4号位出牌顺序为从上往下，所以4号位1->9序号牌坐标对应2号位9->1序号牌坐标
        local pos_x = 0
        if self.seatIndex == MahjongSeatIndex.Seat2 then
            cardPosIndex = 10 - cardPosIndex
            pos_x = row == 0 and column == 8 and -1 or 0 --第一行第9列X轴坐标为-1
        else
            pos_x = row == 0 and column == 0 and -1 or 0 --第一行第一列X轴坐标为-1
        end
        -- 4号位 X轴 计算 = 1->9序号牌间距 - 1 ->9序号牌底框资源从小到大的间距 - 横向牌间距
        cardItem:SetPosition((cardPosIndex - 1) * self.yWidth - row * (cardPosIndex - 1) - row * self.interval + pos_x, self:GetOutCardPosY(cardPosIndex))
    end
end

--   20  30  30 32 32 34  36  36 --1->9序号牌Y轴之间的间距，暂时没找到规律算法
--168 140 110 80 48 16 -18 -54 -90
--2,4号位玩家出牌坐标Y轴
local verticalPosY = {168, 140, 110, 80, 48, 16, -18, -54, -90}

--获取2/4号位玩家出牌的Y轴坐标
function MahjongOutCard:GetOutCardPosY(cardPosIndex)
    return verticalPosY[cardPosIndex]
end

function MahjongOutCard:SetEnlargeOutCardEffect(self, cardItem, isNew, i)
    if isNew or (i == self.outCardsLength and self.seatIndex == MahjongDataMgr.GetPlayerDataById(MahjongDataMgr.Operation.playerId).seatIndex) and MahjongDataMgr.Operation.type == MahjongOperateCode.CHU_PAI then
        if self.enlargeGo == nil then
            self.enlargeGo = CreateGO(self.cardItemPrefab, self.enlargeCardNode, "Card")
            self.enlargeTransform = self.enlargeGo.transform
            self.enlargeFrame = self.enlargeTransform:Find("CardFrame"):GetComponent("Image")
            self.enlargeIcon = self.enlargeTransform:Find("CardIcon"):GetComponent("ShapeImage")
            self.enlargeTransform.localScale = Vector3.one
        end
        
        UIUtil.SetActive(self.enlargeGo, true)
        self.enlargeFrame.sprite = MahjongResourcesMgr.GetSingleCardFrameSprite("face_1_bottom_stand") --获取其他三方玩家出牌提示资源底框
        self.enlargeIcon.sprite = MahjongResourcesMgr.GetCardSprite(self.outCards[i].key)

        self.enlargeFrame.gameObject.transform.localScale = Vector3.New(0.9, 0.9, 0.9)
        self.enlargeIcon.gameObject.transform.localScale = Vector3.one
        UIUtil.SetRotation(self.enlargeIcon.gameObject, 0, 0, 0)
        UIUtil.SetAnchoredPosition(self.enlargeIcon.gameObject, 0, -5)
        self.enlargeFrame:SetNativeSize()
        self.enlargeIcon:SetNativeSize()
        

        if self.seatIndex == MahjongSeatIndex.Seat2 then
            -- self.enlargeTransform.localPosition = Vector3.New(400, 0, 0)
            UIUtil.SetAnchoredPosition(self.enlargeTransform, 450, 48)
        elseif self.seatIndex == MahjongSeatIndex.Seat4 then
            -- self.enlargeTransform.localPosition = Vector3.New(-400, 0, 0)
            UIUtil.SetAnchoredPosition(self.enlargeTransform, -450, 48)
        elseif self.seatIndex == MahjongSeatIndex.Seat3 then
            -- self.enlargeTransform.localPosition = Vector3.New(0, 180, 0)
            UIUtil.SetAnchoredPosition(self.enlargeTransform, 0, 240)
        end

        self:StartEnlargeTimer()
    end
end

function MahjongOutCard:StartEnlargeTimer()
    if self.enlargeTimer == nil then
        self.enlargeTimer = Timing.New(function() self:OnEnlargeTimer() end, 1.5)
    end
    self.enlargeTimer:Restart()
end

function MahjongOutCard:StopEnlargeTimer()
    if self.enlargeTimer ~= nil then
        self.enlargeTimer:Stop()
    end
end

function MahjongOutCard:OnEnlargeTimer()
    self:StopEnlargeTimer()
    if self.enlargeGo ~= nil then
        UIUtil.SetActive(self.enlargeGo, false)
    end
end

function MahjongOutCard:ClearEnlarge()
    if self.enlargeGo ~= nil then
        UIUtil.SetActive(self.enlargeGo, false)
    end
end

--设置选中的牌，玩家自己提起牌寻找相同的牌
function MahjongOutCard:SetSelectedCard(cardKey)
    if self.outCardsLength < 1 then
        return
    end
    local cardItem = nil
    for i = 1, self.outCardsLength do
        cardItem = self.cardItems[i]
        if cardItem ~= nil then
            if cardItem.cardData.key == cardKey then
                cardItem:SetSelected(true)
            else
                cardItem:SetSelected(false)
            end
        end
    end
end

--清除选中的牌，用于刷新牌时，或者主动清除
function MahjongOutCard:ClearSelectedCard()
    if self.outCardsLength < 1 then
        return
    end
    local cardItem = nil
    for i = 1, self.outCardsLength do
        cardItem = self.cardItems[i]
        if cardItem ~= nil then
            cardItem:SetSelected(false)
        end
    end
end

--获取打出的最后一张牌
function MahjongOutCard:GetLastItem()
    local cardItem = nil
    if self.outCardsLength > 0 then
        cardItem = self.cardItems[self.outCardsLength]
    end
    return cardItem
end