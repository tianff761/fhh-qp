---------------------------------------------------------------------------------------------
SDBPlaybackMgr = {
    --事件
    msgs = {},
    -------------
    --回放数据
    playbackData = nil,
    -------------
    --步数
    steps = {},
    --最大步数
    maxStep = 0,
    --当前步数
    curStep = 0,
    --------------
    --开始执行的步数(兼容房间信息，玩家信息，以及开始)
    startStep = 3,
    --------------
    --是否自动回放
    isAuto = false,
    --自动回放速度(秒)多久调用一次下一步
    speed = 1,
    --回放timer
    autoTimer = nil,

    --是否是下一步
    isNext = true,
    --------------
    tempData = nil,
    tempId = nil,
}
local this = SDBPlaybackMgr

--初始化回放数据   
function SDBPlaybackMgr.Init(data)
    if IsNil(data) then
        return
    end
    this.playbackData = data
    --初始化事件
    this.InitMsg()
    --初始化数据
    this.InitData()
    --初始化房间信息
    this.InitRoomInfo()
    --初始化玩家信息
    this.InitPlayerInfo()
    --初始化开局信息
    this.InitStartGame()
    if #this.steps > 0 then
        this.isNext = true
        this.curStep = 3
        this.isAuto = false
    end
end

--重新播放
function SDBPlaybackMgr.Replay()
    --初始化房间信息
    this.InitRoomInfo()
    --初始化玩家信息
    this.InitPlayerInfo()
    --初始化开局信息
    this.InitStartGame()
    if #this.steps > 0 then
        this.isNext = true
        this.curStep = 3
    end
end

--自动回放
function SDBPlaybackMgr.AutoPlayback()
    this.isAuto = true
    if IsNil(this.autoTimer) then
        this.autoTimer = Scheduler.scheduleGlobal(function()
            if this.isAuto and this.curStep < this.maxStep then
                Log("<<<<<<<<<<<<<<< ", this.curStep, this.maxStep)
                this.NextPlayback()
            end
        end, this.speed)
    end
end

--暂停自动回放
function SDBPlaybackMgr.StopAutoPlayback()
    this.isAuto = false
end

--下一步回放
function SDBPlaybackMgr.NextPlayback()
    if this.curStep < this.maxStep and not IsNil(this.steps[this.curStep]) then
        this.curStep = this.curStep + 1
        this.isNext = true
        this.tempId = tostring(this.steps[this.curStep].cmdId)
        if not IsNil(this.msgs[this.tempId]) then
            Log(">>>>>>>>>>>>  ", this.tempId, this.steps[this.curStep])
            this.msgs[this.tempId]()
        else
            Log(">>>>>>>>>>>>  ", this.tempId, " is nil ")
        end
    else
        Toast.Show("牌局已经结束")
    end
end

--上一步回放
function SDBPlaybackMgr.LastPlayback()
    if this.curStep > this.startStep and not IsNil(this.steps[this.curStep]) then
        this.curStep = this.curStep - 1
        this.isNext = false
        this.tempId = tostring(this.steps[this.curStep].cmdId)
        if not IsNil(this.msgs[this.tempId]) then
            Log(">>>>>>>>>>>>  ", this.tempId, this.steps[this.curStep])
            this.msgs[this.tempId]()
        else
            Log(">>>>>>>>>>>>  ", this.tempId, " is nil ")
        end
    else
        Toast.Show("已经是回放开始数据")
    end
end

--清除数据
function SDBPlaybackMgr.Clear()
    Log(">>>>>>>>>>>>>> 清除数据")
    this.isNext = true
    this.isAuto = false
    this.curStep = 0
    this.steps = {}
    Scheduler.unscheduleGlobal(this.autoTimer)
    this.autoTimer = nil
end

-------------------------
--初始化事件
function SDBPlaybackMgr.InitMsg()
    this.msgs[SDBAction.SDB_STC_SEND_CARDS] = this.HandleSendCard
    this.msgs[SDBAction.SDB_STC_INFROM_ROB_BANKER] = this.HandleNoticeRobBanker
    this.msgs[SDBAction.SDB_CTS_OPERATE_ROB_BANKER] = this.HandleOnRobBanker
    this.msgs[SDBAction.SDB_STC_ROB_BANKER] = this.HandleRobBankerResult
    this.msgs[SDBAction.SDB_STC_INFROM_BET_SCORE] = this.HandleNoticeBetScore
    this.msgs[SDBAction.SDB_CTS_OPERATE_BET_SCORE] = this.HandleBetScoreRevert
    this.msgs[SDBAction.SDB_STC_BET_SCORE] = this.HandleBetScore
    this.msgs[SDBAction.SDB_STC_NOTICE_INFROM_GET_CARDS] = this.HandleNoticeCard
    this.msgs[SDBAction.SDB_STC_INFROM_NODEED_CARDS] = this.HandleNoticeNoNeedCard
    this.msgs[SDBAction.SDB_STC_BALANCE] = this.HandleBalance
end

--移除事件
function SDBPlaybackMgr.RemoveAllMsg()
    this.msgs = {}
end

--获取事件的结构
function SDBPlaybackMgr.GetMsgData()
    return { code = 0, data = this.tempData }
end
-------------------------
--初始化数据
function SDBPlaybackMgr.InitData()
    --初始化步数
    for _, v in ipairs(this.playbackData.step) do
        table.insert(this.steps, JsonToObj(v))
    end
    this.maxStep = #this.steps
end

--初始化房间信息
function SDBPlaybackMgr.InitRoomInfo()
    this.HandleRoomInfo()
end

--初始化玩家信息
function SDBPlaybackMgr.InitPlayerInfo()
    this.HandlePlayerInfo()
end

--开局
function SDBPlaybackMgr.InitStartGame()
    this.HandleStartGame()
end

---------------------------------具体处理-------------------------------------
--处理房间信息
function SDBPlaybackMgr.HandleRoomInfo()
    this.tempData = this.steps[1]
    SDBRoom.OnSdbStcRoomInfo(this.GetMsgData())
    this.CheckPlayerInfos()
end

--处理玩家信息
function SDBPlaybackMgr.HandlePlayerInfo()
    this.tempData = this.steps[2]
    SDBRoom.OnSdbStcPlayerInfos(this.GetMsgData())
    this.CheckPlayerInfos()
end

--处理开局
function SDBPlaybackMgr.HandleStartGame()
    this.tempData = this.steps[3]
    SDBRoom.OnGameStart(this.GetMsgData())
    this.CheckPlayerInfos()
end

--处理发牌
function SDBPlaybackMgr.HandleSendCard()
    this.tempData = this.steps[this.curStep]
    if this.isNext then
        SDBRoom.OnSendCards(this.GetMsgData())
    end

    this.CheckPlayerInfos()

    --这里因为执行顺序问题，不能移动到上面去
    if this.isNext then
        local tempPlayerData = nil
        for _, playerInfo in ipairs(this.tempData.synData.playerInfos) do
            tempPlayerData = SDBRoomData.GetPlayerDataById(playerInfo.uId)
            if playerInfo.uId == this.tempData.oId or this.tempData.oId == 0 then
                --隐藏最后一张牌
                tempPlayerData:HideOneCard(#tempPlayerData.handCards)
            end
        end
    end

    --隐藏抢庄操作
    SDBOperationCtrl.HideRobZhuangReslult()
end

--处理通知抢庄
function SDBPlaybackMgr.HandleNoticeRobBanker()
    this.tempData = this.steps[this.curStep]
    SDBRoom.OnInfromRobBanker(this.GetMsgData())
    this.CheckPlayerInfos()
end

--处理抢庄回复
function SDBPlaybackMgr.HandleOnRobBanker()
    this.tempData = this.steps[this.curStep]
    SDBRoom.OnRobBanker(this.GetMsgData())
    this.CheckPlayerInfos()
end

--处理抢庄结果
function SDBPlaybackMgr.HandleRobBankerResult()
    this.tempData = this.steps[this.curStep]
    SDBRoom.OnRobBankerEnd(this.GetMsgData())
    this.CheckPlayerInfos()
end

--处理下注通知
function SDBPlaybackMgr.HandleNoticeBetScore()
    this.tempData = this.steps[this.curStep]
    for i, v in ipairs(this.tempData.list) do
        if v.uId == SDBRoomData.mainId then
            SDBRoom.OnInformBetScore({ code = 0, data = v })
        end
    end
    this.CheckPlayerInfos()
    --如果主玩家是庄家，直接下一步
    if this.tempData.synData.zjId == SDBRoomData.mainId then
        if this.isNext then
            this.NextPlayback()
        else
            this.LastPlayback()
        end
    end
end

--处理下注回复
function SDBPlaybackMgr.HandleBetScoreRevert()
    this.tempData = this.steps[this.curStep]
    SDBRoom.OnOperateBetScore(this.GetMsgData())
    this.CheckPlayerInfos()
end

--处理下注广播
function SDBPlaybackMgr.HandleBetScore()
    this.tempData = this.steps[this.curStep]
    SDBRoom.OnBetScore(this.GetMsgData())
    this.CheckPlayerInfos()
end

--处理广播某个玩家要牌
function SDBPlaybackMgr.HandleNoticeCard()
    this.tempData = this.steps[this.curStep]
    SDBRoom.OnNoticeInfromGetCards(this.GetMsgData())
    this.CheckPlayerInfos()
    -- --如果不是通知主玩家要牌，直接下一步
    -- if this.tempData.uId ~= SDBRoomData.mainId then
    --     if this.isNext then
    --         this.NextPlayback()
    --     else
    --         this.LastPlayback()
    --     end
    -- end
end

--广播某个玩家不要牌
function SDBPlaybackMgr.HandleNoticeNoNeedCard()
    this.tempData = this.steps[this.curStep]
    SDBRoom.OnPlayerNoNeedCard(this.GetMsgData())
    this.CheckPlayerInfos()
    -- --如果主玩家是庄家，直接下一步
    -- if this.tempData.synData.zjId == SDBRoomData.mainId then
    --     if this.isNext then
    --         this.NextPlayback()
    --     else
    --         this.LastPlayback()
    --     end
    -- end
end

--广播结算信息
function SDBPlaybackMgr.HandleBalance()
    this.tempData = this.steps[this.curStep]
    SDBRoom.OnBalance(this.GetMsgData())
    this.CheckPlayerInfos()
end

--------------------------------------------------
--检测玩家信息
function SDBPlaybackMgr.CheckPlayerInfos()
    local tempPlayerData = nil
    --同步牌张数量
    SDBDeskPanel.SetCardNumber(this.tempData.synData.syCard)
    --同步庄家
    SDBRoomData.BankerPlayerId = this.tempData.synData.zjId
    --显示推注信息
    SDBRoomCtrl.ShowTuiZhu(this.tempData.tzIds)
    if IsNil(this.tempData.tzIds) then
        this.tempData.tzIds = ""
    end

    local tuiZhuIds = string.split(this.tempData.tzIds, ",")
    for _, playerData in ipairs(SDBRoomData.playerDatas) do
        for _, playerId in ipairs(tuiZhuIds) do
            playerData.item:SetTuiZhuImageActive(false)
            if playerId == playerData.id then
                if not IsNil(playerData.item) then
                    playerData.item:SetTuiZhuImageActive(true)
                end
            end
        end
    end

    --检测玩家信息
    for _, playerInfo in ipairs(this.tempData.synData.playerInfos) do
        tempPlayerData = SDBRoomData.GetPlayerDataById(playerInfo.uId)
        --更新状态
        tempPlayerData:UpdatePlayerStates(playerInfo.state)

        --更新下注分
        tempPlayerData.xiaZhuScore = playerInfo.paypoint
        if not SDBFuntions.IsNilOrZero(tempPlayerData.xiaZhuScore) then
            tempPlayerData.item:ShowBetPoints(tempPlayerData.xiaZhuScore)
        else
            tempPlayerData.item:HideBetPoints()
        end

        if tempPlayerData.id == SDBRoomData.mainId then
            if not SDBFuntions.IsNilOrZero(tempPlayerData.xiaZhuScore) then
                SDBOperationPanel.SetBetState(false)
            end
        end

        --更新手牌
        if not IsNil(playerInfo.cards) then
            tempPlayerData.handCards = string.split(playerInfo.cards, ",")
            tempPlayerData:CheckHandCards()
        end

        --更新手牌点数
        if not IsNil(playerInfo.str) then
            --显示点数
            local strtab = string.split(playerInfo.str, ",")
            --点数不是-1（可以显示点数）
            if tonumber(strtab[2]) ~= -1 then
                --显示点数
                tempPlayerData.cardType = tonumber(strtab[1])
                tempPlayerData.point = tonumber(strtab[2])
            end
            --显示点数
            SDBRoomPanel.SetCardsPoint(playerInfo.uId, tempPlayerData.cardType, tempPlayerData.point, false)
        end

        --更新玩家分数
        if not IsNil(playerInfo.point) then
            tempPlayerData.playerScore = playerInfo.point
            tempPlayerData.item:SetScoreText(tempPlayerData.playerScore)
        end

        --更新玩家抢庄倍数以及庄
        tempPlayerData.robZhuangState = playerInfo.nowbs

        if SDBFuntions.IsNilOrZero(tonumber(SDBRoomData.BankerPlayerId)) then
            if playerInfo.nowbs ~= RobZhuangNumType.None then
                tempPlayerData:ShowRobZhuangNum()
            else
                tempPlayerData:HideRobZhuangNum()
            end
            tempPlayerData:HideRobZhuangMultiple()
        else
            if SDBRoomData.BankerPlayerId == playerInfo.uId then
                tempPlayerData:ShowRobZhuangMultiple()
            else
                tempPlayerData:HideRobZhuangMultiple()
            end
            tempPlayerData:HideRobZhuangNum()
        end
        tempPlayerData.item:SetZhuangImageActive(SDBRoomData.BankerPlayerId == playerInfo.uId)


        --更新牌结果状态（爆牌，失败，幸运）(1:结束要牌，0:还未要牌或者正在要牌)
        if playerInfo.isOver == 0 then
            tempPlayerData.item:HideAllCardTypeState()
        end
    end

    --不是要牌阶段隐藏要牌中
    if SDBRoomData.gameState ~= SDBGameState.SendCard then
        for _, playerData in ipairs(SDBRoomData.playerDatas) do
            SDBRoomAnimator.StopYaoPaiZhongAni(playerData.id)
        end
        --隐藏要牌操作按钮
        SDBOperationPanel.SetOperationBtnActive(false)
    end

    --不是准备阶段隐藏结算界面的所有数据
    if SDBRoomData.gameState ~= SDBGameState.Ready then
        for _, playerItem in ipairs(SDBRoomPanel.GetAllPlayerItems()) do
            playerItem:HideBalanceUI()
        end
    end

    --不是下注阶段，不显示下注按钮
    if SDBRoomData.gameState ~= SDBGameState.BetState then
        SDBRoom.HideBetStateScore()
    end

    --不是抢庄阶段，不显示抢庄按钮
    if SDBRoomData.gameState ~= SDBGameState.RobBanker then
        SDBOperationCtrl.HideRobZhuangReslult()
    end
end
return SDBPlaybackMgr