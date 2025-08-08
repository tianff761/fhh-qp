--牌局玩家
Pin5Player = {
    ----------------需要清除----------------
    --玩家的ID
    id = nil,
    --玩家性别
    sex = nil,
    --玩家姓名
    name = nil,
    --下注分数
    xiaZhuScore = nil,
    --元宝
    gold = nil,
    --头像
    playerHead = nil,
    --玩家自己的状态
    state = -1,
    --玩家分数
    playerScore = nil,
    --玩家的远端座位号
    seatNumber = nil,
    --本地座位号
    seatId = nil,
    --手牌
    handCards = nil,
    --第五张牌
    fiveCard = nil,
    --玩家的操作状态
    robZhuangState = RobZhuangNumType.None,
    --玩家UI
    item = nil,
    --当前牌类型（无牛，牛几）
    cardType = nil,
    --是否推注
    pushBet = false,
    -----------------------------------
    --本局扣除分数(临时变量)
    tempbjpoint = 0,
}

--牌偏移量
local office = 20

Pin5Player.meta = { __index = Pin5Player }

function Pin5Player:New()
    local o = {}
    setmetatable(o, self.meta)
    o.handCards = {}
    return o
end

--重置，小局重置
function Pin5Player:Reset()
    self.handCards = {}
    self.fiveCard = nil
    self.xiaZhuScore = nil
    self.isHandCardFiveFlip = false
    self.robZhuangState = RobZhuangNumType.None
    self.cardType = nil
    self.thisTimeTipCard = false
    self.pushBet = false
    --处理playerItem的Reset
    if IsNil(self.item) then
        self.item:Reset()
    end
end

--开局重置的数据
function Pin5Player:StartGameReset()
    --还原扑克牌设置
    self:ResetPokerData()
end

--设置玩家的信息
function Pin5Player:SetPlayerData(data)
    -- id
    self.id = data.userId
    -- 头像
    self.playerHead = data.iCon
    -- 玩家分数
    self.playerScore = tonumber(data.score)
    -- 座位号
    self.seatNumber = data.seatNum
    -- 玩家状态
    self:UpdatePlayerStates(data.state) --状态码
    -- 性别
    self.sex = data.sex
    -- 姓名
    self.name = data.userName
    -- -- 下注分
    -- self.xiaZhuScore = data.paypoint
    --在线状态
    --LogError(data.online)
    self.isOffline = data.online == false
end
------------------------
function Pin5Player:SetHandCards(cards)
    self.handCards = cards
end

--检测手牌
function Pin5Player:CheckHandCards()
    self:ShowAllCard(self.handCards)
end

--增加一张手牌
function Pin5Player:AddHandCards(card, count)

end

--隐藏某张牌
function Pin5Player:HideOneCard(index)
    self.item:HideOneCard(index)
end

--显示显示抢庄倍数，抢庄枪几
function Pin5Player:ShowRobBankerMultiple()
    if self.item ~= nil then
        if self.robZhuangState ~= RobZhuangNumType.None then
            self.item:ShowRobBankerMultipleAnim(self.robZhuangState)
        end
    end
end

--关闭抢庄倍数
function Pin5Player:HideRobBankerMultiple()
    if self.item ~= nil then
        self.item:SetRobBankerAnimGoDisplay(false)
    end
end

--显示某个玩家的所有牌
function Pin5Player:ShowAllCard(cards)
    if not IsNil(self.item) then
        self.item:ShowAllCard(cards)
    end
end

--播放玩家的牌的翻牌动画
function Pin5Player:PlayFlopAnim(card, callback)
    if not IsNil(self.item) then
        self.item:PlayFlopAllAnim(card, callback)
    end
end

--清空扑克设置
function Pin5Player:ResetPokerData()
    if not IsNil(self.item) then
        self.item:ResetPokerData()
    end
end

--隐藏某个玩家的所有牌
function Pin5Player:HideAllCard()
    if not IsNil(self.item) then
        self.item:HideAllCard()
    end
end

--检查牌
function Pin5Player:CheckCards()
    if not IsNil(self.item) then
        self.item:CheckCards(self.handCards)
    end
end

--处理玩家状态
function Pin5Player:UpdatePlayerStates(state)
    if self.state == state then
        return
    end
    self.state = state
    if not IsNil(self.item) then
        if self.state == Pin5PlayerState.READY then
            -- 准备
            self.item:SetReadyDisplay(true)
        elseif self.state == Pin5PlayerState.WAITING_START then
            self.item:SetReadyDisplay(true)
        elseif self.state == Pin5PlayerState.WAITING then
            self.item:SetReadyDisplay(false)
        elseif self.state == Pin5PlayerState.NO_READY then
            self.item:SetReadyDisplay(false)
        end
    end
end

--飞金币动画
function Pin5Player:FlyBetGold(callback)
    if not IsNil(self.item) then
        self.item:FlyBetGold(callback)
    end
end


--获取第五张是否翻开(无论是明牌抢庄，还是其他玩法，第五张没翻开都是没有翻牌的意思)
function Pin5Player:GetHandCardFiveFlip()
    if #self.handCards < 5 then
        return false
    end
    if self.fiveCard == nil and self.fiveCard == "-1" then
        return false
    end
    return self.handCards[5] ~= "-1"
end

--更新推注状态 active:是否显示可推注  edActive:是否显示已推注
function Pin5Player:UpdataTuiZhuState(active, edActive)
    --检测是否已推注
    if self:CheckTuiZhued() then
        self.item:SetTuiZhuImageActive(false)
        self.item:SetTuiZhuAnimDisplay(true)
    else
        --LogError("Pin5Player self", self)
        self.item:SetTuiZhuAnimDisplay(false)

        local isXiaZhu = IsNumber(self.xiaZhuScore) and self.xiaZhuScore > 0
        --没有下注分表示没有下注,就去判断能否显示推注图标
        if isXiaZhu then
            self.item:SetTuiZhuImageActive(false)
        else
            --推注
            if IsBool(active) then
                self.item:SetTuiZhuImageActive(active)
            else
                if Pin5RoomData.gameState == Pin5GameState.WAITTING or Pin5RoomData.gameState == Pin5GameState.ROB_ZHUANG then
                    self.item:SetTuiZhuImageActive(self.pushBet)
                elseif Pin5RoomData.gameState == Pin5GameState.BETTING then
                    self.item:SetTuiZhuImageActive(self.isPushBet)
                else
                    self.item:SetTuiZhuImageActive(false)
                end
            end
        end
    end

    --如果为false 无视判断直接false
    if active == false or Pin5RoomData.BankerPlayerId == self.id then
        self.item:SetTuiZhuImageActive(false)
    end

    --已推注
    if IsBool(edActive) then
        self.item:SetTuiZhuAnimDisplay(edActive)
    end
end

--检测是否已推注
function Pin5Player:CheckTuiZhued()
    -- if IsNumber(self.xiaZhuScore) and self.xiaZhuScore > Pin5RoomData.maxDiFen then
    --     return true
    -- end
    --下注分数大于16就播放特效
    if IsNumber(self.xiaZhuScore) and self.xiaZhuScore >= 16 then
        return true
    end
    return false
end

--销毁，调用该方法后，所以的数据都应该清除
function Pin5Player:Destroy()
    self:Clear()
end