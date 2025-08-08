--牌局玩家
LYCPlayer = {
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
    --玩家客户端远端座位号，服务器座位号
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
    ---是否捞牌
    isLao = false,
    ---是否炸开
    isZhaKai = false,
    -----------------------------------
    --本局扣除分数(临时变量)
    tempbjpoint = 0,
}

--牌偏移量
local office = 20

LYCPlayer.meta = { __index = LYCPlayer }

function LYCPlayer:New()
    local o = {}
    setmetatable(o, self.meta)
    o.handCards = {}
    return o
end

--重置，小局重置
function LYCPlayer:Reset()
    self.handCards = {}
    self.fiveCard = nil
    self.xiaZhuScore = nil
    self.isHandCardFiveFlip = false
    self.robZhuangState = RobZhuangNumType.None
    self.cardType = nil
    self.thisTimeTipCard = false
    self.pushBet = false
    self.isLao = false
    self.isZhaKai = false
    --隐藏所有手牌
    self:HideAllCard()
    --隐藏卡槽
    self:HideCardsSlot()
    --还原扑克牌设置
    self:ResetPokerData()
    --隐藏已推注以及可推注
    self:UpdataTuiZhuState(false, false)

    --处理playerItem的Reset
    if IsNil(self.item) then
        self.item:Reset()
    end
end

--开局重置的数据
function LYCPlayer:StartGameReset()
    --还原扑克牌设置
    self:ResetPokerData()
end

--设置玩家的信息
function LYCPlayer:SetPlayerData(data)
    -- id
    self.id = data.userId
    -- 头像
    self.playerHead = data.iCon
    -- 玩家分数
    self.playerScore = tonumber(data.score)

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
    self.isOffline = data.online
end
------------------------
function LYCPlayer:SetHandCards(cards)
    self.handCards = cards
end

--检测手牌
function LYCPlayer:CheckHandCards()
    self:ShowAllCard(self.handCards)
end

--增加一张手牌
function LYCPlayer:AddHandCards(card, count)

end

--隐藏某张牌
function LYCPlayer:HideOneCard(index)
    self.item:HideOneCard(index)
end

----------------------
--显示牌的卡槽
function LYCPlayer:ShowCardsSlot()
    if not IsNil(self.item) then
        self.item:ShowCardsSlot()
    end
end

--隐藏牌的卡槽
function LYCPlayer:HideCardsSlot()
    if not IsNil(self.item) then
        self.item:HideCardsSlot()
    end
end

--显示显示抢庄倍数
function LYCPlayer:ShowRobZhuangMultiple()
    if self.item ~= nil then
        if self.robZhuangState > 0 then
            self.item:ShowRobZhuangMultiple(self.robZhuangState)
        end
    end
end

--关闭抢庄倍数
function LYCPlayer:HideRobZhuangMultiple()
    if self.item ~= nil then
        self.item:HideRobZhuangMultiple()
    end
end

--显示抢庄枪几
function LYCPlayer:ShowRobZhuangNum()
    if self.item ~= nil then
        if self.robZhuangState ~= RobZhuangNumType.None then
            self.item:ShowRobZhuangNum(self.robZhuangState)
        end
    end
end

--关闭抢几
function LYCPlayer:HideRobZhuangNum()
    if self.item ~= nil then
        self.item:HideRobZhuangNum()
    end
end

--显示某个玩家的所有牌
function LYCPlayer:ShowAllCard(cards)
    if not IsNil(self.item) then
        self.item:ShowAllCard(cards)
    end
end

--播放玩家的牌的翻牌动画
function LYCPlayer:PlayFlopAllAni()
    --LogError("LYCPlayer PlayFlopAllAni")
    if not IsNil(self.item) then
        self.item:PlayFlopAllAni(self.handCards)
    end
end

--清空扑克设置
function LYCPlayer:ResetPokerData()
    if not IsNil(self.item) then
        self.item:ResetPokerData()
    end
end

--隐藏某个玩家的所有牌
function LYCPlayer:HideAllCard()
    if not IsNil(self.item) then
        self.item:HideAllCard()
    end
end

--检查牌
function LYCPlayer:CheckCards()
    if not IsNil(self.item) then
        self.item:CheckCards(self.handCards)
    end
end

--处理玩家状态
function LYCPlayer:UpdatePlayerStates(state)
    if self.state == state then
        return
    end
    self.state = state
    if not IsNil(self.item) then
        if self.state == LYCPlayerState.READY then
            -- 准备
            self.item:SetIsPlayReadyAni()
            self.item:UpdatellReadyImge(true, true)
        elseif self.state == LYCPlayerState.WAITING_START then
            self.item:UpdatellReadyImge(true, false)
        elseif self.state == LYCPlayerState.WAITING then
            self.item:UpdatellReadyImge(false, false)
        elseif self.state == LYCPlayerState.NO_READY then
            self.item:UpdatellReadyImge(false, false)
        end
    end
end

--飞金币动画
function LYCPlayer:FlyGold(callback)
    if not IsNil(self.item) then
        self.item:FlyGold(callback)
    end
end

function LYCPlayer:StopFlyGold()
    if not IsNil(self.item) then
        self.item:StopFlyGold()
    end
end

--获取第五张是否翻开(无论是明牌抢庄，还是其他玩法，第五张没翻开都是没有翻牌的意思)
function LYCPlayer:GetHandCardFiveFlip()
    if #self.handCards < 5 then
        return false
    end
    if self.fiveCard == nil and self.fiveCard == "-1" then
        return false
    end
    return self.handCards[5] ~= "-1"
end

--更新推注状态 active:是否显示可推注  edActive:是否显示已推注
function LYCPlayer:UpdataTuiZhuState(active, edActive)
    if self.item == nil then
        LogError("更新推注状态,当前玩家Item为空", self.id)
        return
    end
    --检测是否已推注
    if self:CheckTuiZhued() then
        self.item:SetTuiZhuImageActive(false)
        self.item:SetTuiZhuedActive(true)
    else
        --LogError("LYCPlayer self", self)
        self.item:SetTuiZhuedActive(false)

        local isXiaZhu = IsNumber(self.xiaZhuScore) and self.xiaZhuScore > 0
        --没有下注分表示没有下注,就去判断能否显示推注图标
        if isXiaZhu then
            self.item:SetTuiZhuImageActive(false)
        else
            --推注
            if IsBool(active) then
                self.item:SetTuiZhuImageActive(active)
            else
                if LYCRoomData.gameState == LYCGameState.WAITTING or LYCRoomData.gameState == LYCGameState.ROB_ZHUANG then
                    self.item:SetTuiZhuImageActive(self.pushBet)
                elseif LYCRoomData.gameState == LYCGameState.BETTING then
                    self.item:SetTuiZhuImageActive(self.isPushBet)
                else
                    self.item:SetTuiZhuImageActive(false)
                end
            end
        end
    end

    --如果为false 无视判断直接false
    if active == false or LYCRoomData.BankerPlayerId == self.id then
        self.item:SetTuiZhuImageActive(false)
    end

    --已推注
    if IsBool(edActive) then
        self.item:SetTuiZhuedActive(edActive)
    end
end

--检测是否已推注(码宝)
function LYCPlayer:CheckTuiZhued()
    if IsNumber(self.xiaZhuScore) and self.xiaZhuScore > LYCRoomData.maxDiFen then
        return true
    end
    return false
end

--销毁，调用该方法后，所以的数据都应该清除
function LYCPlayer:Destroy()
    self:Clear()
end