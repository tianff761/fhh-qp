TpPlayCardMgr = {}

local this = TpPlayCardMgr
--
--游戏状态
this.gameStatus = nil
this.lastGameStatus = nil
--发牌的游戏状态
this.lastDealGameStatus = nil

--是否是第一轮发牌
this.isDealCardRound1 = false
--是否是第二轮发牌
this.isDealCardRound2 = false
--是否是第三轮发牌
this.isDealCardRound3 = false

--第一轮发牌步骤
this.round1DealStep = 0
--第一轮发牌时间
this.round1DealTime = 0
--第一轮是否发牌中
this.round1Dealing = false
--第一轮是否已经发牌
this.round1Dealed = false

--第一轮发牌时间
this.round2DealTime = 0
--第一轮是否发牌中
this.round2Dealing = false
--第一轮是否已经发牌
this.round2Dealed = false

--第一轮发牌时间
this.round3DealTime = 0
--第一轮是否发牌中
this.round3Dealing = false
--第一轮是否已经发牌
this.round3Dealed = false
--是否计时器运行
this.timerRunning = false

--初始化
function TpPlayCardMgr.Initialize(playerItems, cradsNode)
    --玩家显示项
    this.playerItems = playerItems
    --牌显示项
    this.cardItems = {}
    for i = 1, 5 do
        local item = TpCardItem.New()
        item:Init(i, cradsNode:Find(tostring(i)))
        item:SetDisplay(false)
        table.insert(this.cardItems, item)
    end
end

--小局重置
function TpPlayCardMgr.Reset()
    LogError(">> TpPlayCardMgr.Reset > ======== > Reset.")
    this.gameStatus = nil
    this.lastGameStatus = nil
    this.lastDealGameStatus = nil
    --
    this.round1Dealing = false
    this.round1Dealed = false
    this.round2Dealing = false
    this.round2Dealed = false
    this.round3Dealing = false
    this.round3Dealed = false
    --
    this.ClearCardsDisplay()
    this.ClearPlayerCardsDisplay()
    this.StopDealCardTimer()
end

--清除
function TpPlayCardMgr.Clear()

end

--销毁
function TpPlayCardMgr.Destroy()

end

--================================================================
--
--清除牌显示
function TpPlayCardMgr.ClearCardsDisplay()
    for i = 1, #this.cardItems do
        this.cardItems[i]:Clear()
    end
end

--清除玩家牌显示
function TpPlayCardMgr.ClearPlayerCardsDisplay()
    for i = 1, #this.playerItems do
        this.playerItems[i]:HideCardsDisplay()
    end
end

--================================================================
--通过进入游戏
function TpPlayCardMgr.CheckUpdateByEnterGame()
    this.CheckUpdateGameStatus()
end

--通过推送游戏状态
function TpPlayCardMgr.CheckUpdateByGameStatus()
    this.CheckUpdateGameStatus()
end

--通过坐下
function TpPlayCardMgr.CheckUpdateBySitDown()
    this.CheckUpdateGameStatus()
end

--通过操作
function TpPlayCardMgr.CheckUpdateByOperate()

end

--检查更新游戏状态
function TpPlayCardMgr.CheckUpdateGameStatus()
    if this.gameStatus ~= TpDataMgr.gameStatus then
        this.gameStatus = TpDataMgr.gameStatus
    end
end

--通过发牌
function TpPlayCardMgr.CheckUpdateByDeal()
    --LogError(">> TpPlayCardMgr.CheckUpdateByDeal", this.lastDealGameStatus, TpDataMgr.gameStatus)
    if this.lastDealGameStatus ~= TpDataMgr.gameStatus then
        this.lastDealGameStatus = TpDataMgr.gameStatus
        --
        if this.lastDealGameStatus == TpGameStatus.DealPoker1 then --发牌
            this.HandleRound1DealCard()
        elseif this.lastGameStatus == TpGameStatus.DealPoker2 then
            this.HandleRound2DealCard()
        elseif this.lastGameStatus == TpGameStatus.DealPoker3 then
            this.HandleRound3DealCard()
        end
    end
end

--检查更新游戏状态
function TpPlayCardMgr.CheckUpdateCardsDisplay()
    --LogError(">> TpPlayCardMgr.CheckUpdateCardsDisplay", this.lastDealGameStatus, TpDataMgr.gameStatus)
    if this.lastGameStatus ~= TpDataMgr.gameStatus then
        this.lastGameStatus = TpDataMgr.gameStatus
        --
        if this.lastGameStatus == TpGameStatus.DealPoker1 then --发牌
            this.HandleRound1DealCard()
        elseif this.lastGameStatus == TpGameStatus.Round1 then
            this.CheckRound1CardDisplay()
        elseif this.lastGameStatus == TpGameStatus.DealPoker2 then
            this.HandleRound2DealCard()
        elseif this.lastGameStatus == TpGameStatus.Round2 then
            this.CheckRound1CardDisplayAtLaterRound1()
            this.CheckRound2CardDisplay()
        elseif this.lastGameStatus == TpGameStatus.DealPoker3 then
            this.HandleRound3DealCard()
        elseif this.lastGameStatus == TpGameStatus.Round3 then
            this.CheckRound1CardDisplayAtLaterRound1()
            this.CheckRound2CardDisplay()
            this.CheckRound3CardDisplay()
        elseif this.lastGameStatus == TpGameStatus.GameResult then
            --todo
        elseif this.lastGameStatus == TpGameStatus.GameEnd then
            --todo
        end
    end
end

--处理第一轮发牌
function TpPlayCardMgr.HandleRound1DealCard()
    if this.round1Dealed or this.round1Dealing then
        return
    end
    --检查出一个玩家有手牌
    local playerDatas = TpDataMgr.playerDatas
    local handCards = nil
    local isExistHandCards = false
    for i = 1, #playerDatas do
        handCards = playerDatas[i].handCards
        if handCards ~= nil and #handCards > 1 then
            isExistHandCards = true
            break
        end
    end
    if not isExistHandCards then
        LogError(">> TpPlayCardMgr.HandleRound1DealCard > Not exist HandCards.")
        return
    end

    LogError(">> TpPlayCardMgr.HandleRound1DealCard")
    this.isDealCardRound1 = true
    this.round1Dealing = true
    this.ClearCardsDisplay()
    this.ClearPlayerCardsDisplay()
    --
    this.round1DealStep = 1
    this.round1DealTime = 0
    --启动发牌计时器开始发牌
    this.StartDealCardTimer()
end

--检测第一轮的牌显示
function TpPlayCardMgr.CheckRound1CardDisplay()
    if this.round1Dealing then
        return
    end
    this.SetCard(1)
    this.SetCard(2)
    this.SetCard(3)

    this.SetPlayerHandCards()
end

--检测第一轮的牌显示，在第一轮下注后
function TpPlayCardMgr.CheckRound1CardDisplayAtLaterRound1()
    this.isDealCardRound1 = false

    this.SetCard(1)
    this.SetCard(2)
    this.SetCard(3)

    this.SetPlayerHandCards()
end

--处理第二轮发牌
function TpPlayCardMgr.HandleRound2DealCard()
    if this.round2Dealed or this.round2Dealing then
        return
    end
    local cardIndex = 4
    if TpDataMgr.public == nil or TpDataMgr.public[cardIndex] == nil then
        LogError(">> TpPlayCardMgr.HandleRound2DealCard > Not exist card.")
        return
    end

    this.isDealCardRound2 = true
    this.round2Dealing = true

    this.round2DealTime = Time.realtimeSinceStartup + 0.1
    this.StartDealCardTimer()
    this.DealCard(cardIndex)
end

--检测第二轮的牌显示
function TpPlayCardMgr.CheckRound2CardDisplay()
    if this.round2Dealing then
        return
    end
    this.SetCard(4)
end

--处理第三轮发牌
function TpPlayCardMgr.HandleRound3DealCard()
    if this.round3Dealed or this.round3Dealing then
        return
    end
    local cardIndex = 5
    if TpDataMgr.public == nil or TpDataMgr.public[cardIndex] == nil then
        LogError(">> TpPlayCardMgr.HandleRound3DealCard > Not exist card.")
        return
    end
    this.isDealCardRound3 = true
    this.round3Dealing = true

    this.round3DealTime = Time.realtimeSinceStartup + 0.1
    this.StartDealCardTimer()
    this.DealCard(cardIndex)
end

--检测第三轮的牌显示
function TpPlayCardMgr.CheckRound3CardDisplay()
    if this.round3Dealing then
        return
    end
    this.SetCard(5)
end

--================================================================
--启动发牌计时器
function TpPlayCardMgr.StartDealCardTimer()
    if this.dealCardTimer == nil then
        this.dealCardTimer = UpdateTimer.New(this.OnDealCardTimer)
    end
    this.dealCardTimer:Start()
end

--停止发牌计时器
function TpPlayCardMgr.StopDealCardTimer()
    if this.dealCardTimer ~= nil then
        this.dealCardTimer:Stop()
    end
end

--处理发牌计时器
function TpPlayCardMgr.OnDealCardTimer()
    this.timerRunning = false

    if this.isDealCardRound1 then
        this.timerRunning = true
        if Time.realtimeSinceStartup > this.round1DealTime then
            if this.round1DealStep == 1 then
                LogError(">> TpPlayCardMgr.OnDealCardTimer > Step > 1")
                this.DealCard(1)
                this.round1DealStep = 2
                this.round1DealTime = Time.realtimeSinceStartup + 0.1
            elseif this.round1DealStep == 2 then
                LogError(">> TpPlayCardMgr.OnDealCardTimer > Step > 2")
                this.DealCard(2)
                this.round1DealStep = 3
                this.round1DealTime = Time.realtimeSinceStartup + 0.1
            elseif this.round1DealStep == 3 then
                LogError(">> TpPlayCardMgr.OnDealCardTimer > Step > 3")
                this.DealCard(3)
                this.round1DealStep = 4
                this.round1DealTime = Time.realtimeSinceStartup + 0.5
            elseif this.round1DealStep == 4 then
                LogError(">> TpPlayCardMgr.OnDealCardTimer > Step > 4")
                --第4步发玩家的牌
                this.DealPlayerHandCards()
                this.round1DealStep = 5
                this.round1DealTime = Time.realtimeSinceStartup + 0.7
            else
                LogError(">> TpPlayCardMgr.OnDealCardTimer > Step > 5")
                this.isDealCardRound1 = false
                this.round1Dealed = true
                this.round1Dealing = false
                --this.CheckRound1CardDisplay()
            end
        end
    end

    if this.isDealCardRound2 then
        this.timerRunning = true
        if Time.realtimeSinceStartup > this.round2DealTime then
            this.isDealCardRound2 = false
            this.round2Dealed = true
            this.round2Dealing = false
            this.CheckRound2CardDisplay()
        end
    end

    if this.isDealCardRound3 then
        this.timerRunning = true
        if Time.realtimeSinceStartup > this.round3DealTime then
            this.isDealCardRound3 = false
            this.round3Dealed = true
            this.round3Dealing = false
            this.CheckRound3CardDisplay()
        end
    end

    if not this.timerRunning then
        this.StopDealCardTimer()
    end
end

--发单张牌
function TpPlayCardMgr.DealCard(index)
    if TpDataMgr.public ~= nil then
        local item = this.cardItems[index]
        local card = TpDataMgr.public[index]
        if item ~= nil and card ~= nil then
            item:DealCard(card)
        end
    else
        LogError(">> TpPlayCardMgr.DealCard > not exist", index)
    end
end

--设置单张牌
function TpPlayCardMgr.SetCard(index)
    if TpDataMgr.public ~= nil then
        local item = this.cardItems[index]
        local card = TpDataMgr.public[index]
        if item ~= nil and card ~= nil then
            item:SetCard(card)
        end
    else
        LogError(">> TpPlayCardMgr.SetCard > not exist", index)
    end
end

--发玩家牌
function TpPlayCardMgr.DealPlayerHandCards()
    local playerData = nil
    local playerItem = nil
    for i = 1, TpDataMgr.playerTotal do
        playerItem = this.playerItems[i]
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(playerItem.index)
        if playerData ~= nil and playerData.handCards ~= nil and #playerData.handCards > 1 then
            playerItem:DealCard(playerData.handCards, playerData.px)
        end
    end
end

--发玩家牌
function TpPlayCardMgr.SetPlayerHandCards()
    local playerData = nil
    local playerItem = nil
    for i = 1, TpDataMgr.playerTotal do
        playerItem = this.playerItems[i]
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(playerItem.index)
        if playerData ~= nil then
            LogError(playerData.id, playerData.handCards)
        end
        if playerData ~= nil and playerData.handCards ~= nil and #playerData.handCards > 1 then
            playerItem:SetCard(playerData.handCards, playerData.px)
        end
    end
end
