--麻将玩家打牌数据
MahjongPlayerCardData = {
    --玩家ID
    playerId = nil,
    --玩家远端座位号
    seatNumber = 0,
    --玩家座位索引号
    seatIndex = 0,
    --是否激活，没激活的不需要处理显示更新
    isActive = false,
    --是否为听用牌
    isTingYong = false,
    --是否为定缺牌
    isDingQue = false,
    --定缺牌类型，用于排序
    dingQue = 0,
    --id形式的数据
    left = nil,
    --id形式的数据
    mid = nil,
    --id形式的数据
    right = nil,
    --左手牌
    leftCards = nil,
    --中间牌
    midCards = nil,
    --右手牌
    rightCard = nil,
    --打出去的牌
    pushCards = nil,
    --操作状态
    operateState = MahjongOperateState.None,
}

local meta = { __index = MahjongPlayerCardData }

function MahjongPlayerCardData.New()
    local o = {}
    setmetatable(o, meta)
    return o
end

--=============================================================================
--
--清除数据
function MahjongPlayerCardData:Clear()
    self.playerId = nil
    self.seatNumber = 0
    self.seatIndex = 0
    self.isActive = false
    self.isTingYong = false
    self.isDingQue = false
    self.dingQue = 0
    self.leftCards = nil
    self.midCards = nil
    self.rightCard = nil
    self.pushCards = nil
    self.operateState = MahjongOperateState.None
end

--=============================================================================
--
--设置玩家信息
function MahjongPlayerCardData:SetPlayer(id, seatNumber, seatIndex)
    self.playerId = id
    self.seatNumber = seatNumber
    self.seatIndex = seatIndex
end
--
--设置定缺牌
function MahjongPlayerCardData:SetDingQue(type)
    self.dingQue = type
end
--
--设置操作状态
function MahjongPlayerCardData:SetOperateState(state)
    self.operateState = state
end
--
--检测和更新玩家牌数据
function MahjongPlayerCardData:UpdateCards(left, mid, right, push)
    --设置激活标识
    self.isActive = true
    
    self.left = left
    self.mid = mid
    self.right = right
    self:UpdateHandCards(left, mid, right)

    if push == nil or not IsTable(push) then
        self.pushCards = {}
    else
        self.pushCards = self:CheckPushCards(push)
    end
end

--更新手上牌、包括左手，中间，右手牌
function MahjongPlayerCardData:UpdateHandCards(left, mid, right)
    --左手牌
    if left == nil or not IsTable(left) then
        self.leftCards = {}
    else
        self.leftCards = left
    end

    --中间牌直接使用牌对象
    if mid == nil then
        self.midCards = {}
    else
        if IsNumber(mid) then
            self.midCards = {}
            local cardData = MahjongDataMgr.UnknownCardData
            for i = 1, mid do
                table.insert(self.midCards, cardData)
            end
        else
            --排序
            self.midCards = self:CheckMidCards(mid)
        end
    end

    --0表示没有牌，所以也需要判断
    if right == nil or not IsNumber(right) or right == 0 then
        self.rightCard = nil
    else
        --转换下
        if self.rightCard == 1 then
            self.rightCard = MahjongDataMgr.UnknownCardData
        else
            self.rightCard = self:GetHandCardData(right)
        end
    end
end

--处理和排序中间牌
function MahjongPlayerCardData:CheckMidCards(mid)
    --Log(mid)
    local result = {}
    for i = 1, #mid do
        table.insert(result, self:GetHandCardData(mid[i]))
    end

    table.sort(result, MahjongUtil.CardDataSort)
    return result
end

--处理打出的牌
function MahjongPlayerCardData:CheckPushCards(push)
    local result = {}
    for i = 1, #push do
        table.insert(result, MahjongDataMgr.GetCardData(push[i]))
    end
    return result
end

--获取牌对象
function MahjongPlayerCardData:GetHandCardData(id)
    local cardData = MahjongDataMgr.GetCardData(id)
    --处理是否是定缺牌，处理排序字段
    cardData.isDingQue = false
    cardData.isTingYong = false
    if MahjongUtil.IsTingYongCard(cardData.key) then
        cardData.isTingYong = true
        cardData.sort = cardData.id - 10000
    elseif cardData.type == self.dingQue then
        cardData.isDingQue = true
        cardData.sort = cardData.id + 10000
    else
        cardData.sort = cardData.id
    end
    return cardData
end