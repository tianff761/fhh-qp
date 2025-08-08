Pin5Room = {
    --当前小结结算数据
    balanceData = nil,
    --小结的赢玩家列表
    losers = nil,
    --小结的输玩家列表
    winners = nil,
    --飞结束金币时间
    flyResultGoldEndTime = 0,
}

local this = Pin5Room
--下注timer
local betStateTimer = nil
--结算timer
local balanceTimer = nil

function Pin5Room.Initialize()
    this.InitEvents()
end

function Pin5Room.Clear()
    this.RemoveEvents()
    if balanceTimer ~= nil then
        Scheduler.unscheduleGlobal(balanceTimer)
        balanceTimer = nil
    end
    if not IsNil(betStateTimer) then
        Scheduler.unscheduleGlobal(betStateTimer)
        betStateTimer = nil
    end
    this.StopFlyResultGoldTimer()
    this.StopCloseRobBankerMultipleAnimTimer()
    Pin5ContentTip.ClearCountDown()
end

-- ==========================================================================================--
-- 事件监听
function Pin5Room.InitEvents()
    -- 断线重新连接
    AddEventListener(CMD.Game.Reauthentication, this.OnInitLoginData)
    AddEventListener(CMD.Game.OnDisconnected, this.OnGameDisconnected)

    AddEventListener(Pin5Action.Pin5_STC_LEAVE_ROOM, this.OnLeaveRoom)
    AddEventListener(Pin5Action.Pin5_STC_JOIN_ROOM, this.OnJoinRoom)
    AddEventListener(CMD.Game.BatteryState, this.OnBatteryState)
    AddEventListener(CMD.Game.Ping, this.OnPing)

    AddEventListener(Pin5Action.Push_SystemTips, this.OnPushSystemTips)
    ------------------------------
    AddEventListener(Pin5Action.Pin5_STC_JoinRoom_Info, this.OnPin5StcRoomInfo)
    AddEventListener(Pin5Action.Pin5_STC_Start_State, this.OnStartGame)
    AddEventListener(Pin5Action.Pin5_STC_RoomState, this.OnRoomState)
    AddEventListener(Pin5Action.Pin5_STC_Update_Player_Info, this.OnPin5StcUpdatePlayerInfo)
    AddEventListener(Pin5Action.Pin5_STC_READY, this.OnStcReady)
    AddEventListener(Pin5Action.Pin5_STC_Send_Cards, this.OnSendCards)
    AddEventListener(Pin5Action.Pin5_STC_B_Operate, this.OnBOperate)
    AddEventListener(Pin5Action.Pin5_CTS_Owner_DISSOLVE, this.OnOwnerDissolve)
    AddEventListener(Pin5Action.Pin5_STC_DissolveTip, this.OnDissolveTip)
    AddEventListener(Pin5Action.Pin5_STC_BetPoints, this.OnBBetOrRobBanker)
    AddEventListener(Pin5Action.Pin5_STC_B_GameStart, this.OnGameStart)
    AddEventListener(Pin5Action.Pin5_STC_ROB_BANKER, this.OnRobBankerEnd)
    AddEventListener(Pin5Action.Pin5_STC_ROOMAUTODISS, this.OnRoomAutoDiss)
    AddEventListener(Pin5Action.Pin5_STC_OwnerChange, this.OnOwnerChange)
    AddEventListener(Pin5Action.Pin5_STC_ErrorCode, this.OnGetErrorCode)
    AddEventListener(Pin5Action.Pin5_STC_AWARD_OPEN, this.OnOpenAwardPool)

    --获取牌型提示返回
    AddEventListener(Pin5Action.Pin5_STC_GetTipCard, this.OnGetTipCard)
    AddEventListener(Pin5Action.Pin5_STC_B_FlipCard, this.OnGetShowCard)

    AddEventListener(Pin5Action.Pin5_STC_B_XiaoJie, this.OnBXiaoJie)
    AddEventListener(Pin5Action.Pin5_STC_B_ZongJie, this.OnBZongJie)

    AddEventListener(Pin5Action.Pin5_STC_OFFLINE, this.OnOffline)

    AddEventListener(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
end

-- 移除监听事件
function Pin5Room.RemoveEvents()
    -- 断线重新连接
    RemoveEventListener(CMD.Game.Reauthentication, this.OnInitLoginData)
    RemoveEventListener(CMD.Game.OnDisconnected, this.OnGameDisconnected)
    RemoveEventListener(Pin5Action.Pin5_STC_LEAVE_ROOM, this.OnLeaveRoom)
    RemoveEventListener(Pin5Action.Pin5_STC_JOIN_ROOM, this.OnJoinRoom)
    RemoveEventListener(CMD.Game.BatteryState, this.OnBatteryState)
    RemoveEventListener(CMD.Game.Ping, this.OnPing)

    RemoveEventListener(Pin5Action.Push_SystemTips, this.OnPushSystemTips)
    ------------------------------
    RemoveEventListener(Pin5Action.Pin5_STC_JoinRoom_Info, this.OnPin5StcRoomInfo)
    RemoveEventListener(Pin5Action.Pin5_STC_Start_State, this.OnStartGame)
    RemoveEventListener(Pin5Action.Pin5_STC_RoomState, this.OnRoomState)
    RemoveEventListener(Pin5Action.Pin5_STC_Update_Player_Info, this.OnPin5StcUpdatePlayerInfo)
    RemoveEventListener(Pin5Action.Pin5_STC_READY, this.OnStcReady)
    RemoveEventListener(Pin5Action.Pin5_STC_Send_Cards, this.OnSendCards)
    RemoveEventListener(Pin5Action.Pin5_STC_B_Operate, this.OnBOperate)
    RemoveEventListener(Pin5Action.Pin5_CTS_Owner_DISSOLVE, this.OnOwnerDissolve)
    RemoveEventListener(Pin5Action.Pin5_STC_DissolveTip, this.OnDissolveTip)
    RemoveEventListener(Pin5Action.Pin5_STC_BetPoints, this.OnBBetOrRobBanker)
    RemoveEventListener(Pin5Action.Pin5_STC_B_GameStart, this.OnGameStart)
    RemoveEventListener(Pin5Action.Pin5_STC_ROB_BANKER, this.OnRobBankerEnd)
    RemoveEventListener(Pin5Action.Pin5_STC_ROOMAUTODISS, this.OnRoomAutoDiss)
    RemoveEventListener(Pin5Action.Pin5_STC_OwnerChange, this.OnOwnerChange)
    RemoveEventListener(Pin5Action.Pin5_STC_ErrorCode, this.OnGetErrorCode)
    RemoveEventListener(Pin5Action.Pin5_STC_AWARD_OPEN, this.OnOpenAwardPool)

    --获取牌型提示返回
    RemoveEventListener(Pin5Action.Pin5_STC_GetTipCard, this.OnGetTipCard)
    RemoveEventListener(Pin5Action.Pin5_STC_B_FlipCard, this.OnGetShowCard)

    RemoveEventListener(Pin5Action.Pin5_STC_B_XiaoJie, this.OnBXiaoJie)
    RemoveEventListener(Pin5Action.Pin5_STC_B_ZongJie, this.OnBZongJie)

    RemoveEventListener(Pin5Action.Pin5_STC_OFFLINE, this.OnOffline)

    RemoveEventListener(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
end

-- ==========================================================================================--
-- 重连的登录数据
function Pin5Room.OnInitLoginData()
    if not Pin5RoomData.isInitRoomEnd then
        return
    end
    if not Pin5RoomData.isPlayback then
        Pin5RoomData.isCandSend = true
        if IsTable(ChatModule) then
            ChatModule.SetIsCanSend(true)
        end
    end

    --重置操作界面
    Pin5OperationPanel.ResetOperation()
    --重置桌面
    Pin5DeskPanel.ResetPin5Desk()
    --关闭要牌按钮
    Pin5OperationPanel.SetOperationBtnActive(false)
    --关闭解散界面
    PanelManager.Close(Pin5PanelConfig.Dismiss, true)
    --重置游戏牌局
    Pin5RoomPanel.Reset()
    Pin5RoomData.Reset()
    Pin5OperationPanel.Reset()
    --开局重置的数据
    Pin5RoomData.StartGameReset()

    this.SendNetWorkData()
end

--断线
function Pin5Room.OnGameDisconnected()
    Pin5RoomData.isCandSend = false
    if IsTable(ChatModule) then
        ChatModule.SetIsCanSend(false)
    end
end

-- ==========================================================================================--
-- Init初始化完Room相关网络协议再向服务器请求以下数据，否则可能请求到的协议还未注册
function Pin5Room.SendNetWorkData()
    --进入房间
    Pin5ApiExtend.EnterGame(UserData.GetRoomId(), Pin5RoomData.mainId, Pin5RoomData.roomData.line)
end

--1014002 加入房间回复
function Pin5Room.OnJoinRoom(arg)
    LogError(">> Pin5Room.OnJoinRoom")
    local data = arg.data
    if data.code ~= 0 then
        this.ShowPin5ErrorMsg(data)
        this.ExitRoom()
        return
    end
    Waiting.ForceHide()
    --重置游戏牌局
    Pin5RoomPanel.Reset()
    --重置操作界面
    Pin5OperationPanel.ResetOperation()
    --重置桌面
    Pin5DeskPanel.ResetPin5Desk()
    --关闭要牌按钮
    Pin5OperationPanel.SetOperationBtnActive(false)
    --关闭解散界面
    PanelManager.Close(Pin5PanelConfig.Dismiss, true)
    --关闭结算界面
    PanelManager.Close(Pin5PanelConfig.JieSuan)

    Pin5RoomData.isCandSend = not Pin5RoomData.isPlayback
    ChatModule.SetIsCanSend(not Pin5RoomData.isPlayback)
end

---加入房间旁观
function Pin5Room.OnJoinRoomWatch()

end

-- 1014004 房间信息更新
function Pin5Room.OnPin5StcRoomInfo(arg)
    local data = arg.data
    LogError(">> Pin5Room.房间信息更新", data)
    Pin5RoomData.JudgeIsObserver(data.playerList)
    --解析 1014004
    this.Parse101RoomInfo(data)
    --初始化UI
    this.InitRoomUI(data)
    --初始化玩家UI
    this.InitPlayerInfosUI(data)
    LogError(">> Pin5Room.OnPin5StcRoomInfo > Pin5RoomData.IsObserver = ", Pin5RoomData.IsObserver())
    if not Pin5RoomData.IsObserver() then
        --初始化主玩家界面
        Pin5RoomPanel.HideSitDownBtn()
        this.InitMainUI()
    elseif not Pin5RoomData.IsFullOfSeat() then
        Pin5RoomPanel.ShowSitDownBtn()
    else
        Pin5RoomPanel.HideSitDownBtn()
    end
end

--初始化房间UI
function Pin5Room.InitRoomUI(data)
    Pin5RoomCtrl.InitRoomUI(data)
    Pin5ContentTip.UpdateData(data.state, 0)
end

--初始化主玩家界面
function Pin5Room.InitMainUI()
    this.CheckShowReadBtn()
end



-- 解析 +++++
function Pin5Room.Parse101RoomInfo(data)
    -- --设置房间号
    Pin5RoomData.roomCode = data.roomId
    --设置游戏当前局数
    Pin5RoomData.gameIndex = data.juShu
    --准入
    if IsNil(data.zhunru) then
        data.zhunru = 0
    end
    Pin5RoomData.zhunru = data.zhunru
    --解析规则
    Pin5Funtions.PlayWay(data)
    -- 设置房主id
    Pin5RoomData.owner = data.adminId
    --设置庄
    Pin5RoomData.BankerPlayerId = data.zhuangId

    Pin5RoomData.isFrist = data.isFrist

    --解析玩家信息列表
    for i = 1, #data.playerList do
        this.UpdatePlayerData(data.playerList[i])
    end
    --更新聊天模块
    this.UpdateChatPlayers(Pin5RoomPanel.GetAllPlayerItems())
    --
    --游戏阶段
    Pin5RoomData.gameState = data.state
    if Pin5RoomData.gameState == Pin5GameState.ROB_ZHUANG or Pin5RoomData.gameState == Pin5GameState.BETTING or Pin5RoomData.gameState == Pin5GameState.WATCH_CARD then
        Pin5RoomData.isGameStarted = true
        Pin5RoomData.isCardGameStarted = true
    else
        Pin5RoomData.isGameStarted = false
        Pin5RoomData.isCardGameStarted = false
    end
end

--  玩家信息 1014004
function Pin5Room.InitPlayerInfosUI(data)
    --更新玩家数据UI
    Pin5RoomCtrl.UpdatePlayersDisplay()
    --设置庄的图标和显示庄的抢庄倍数
    this.CheckBankerAndRobMultiple()
    --显示当前抢庄倍数
    this.CheckRobBanker()
    --显示下注分
    Pin5RoomPanel.ShowXiaZhuGold()
    --检查显示等待中牌子
    this.CheckSelfState()
    --设置状态
    Pin5RoomCtrl.ShowUIByState()
    --更新右上角的菜单栏
    Pin5RoomPanel.UpdateMenuInfo()
    --更新玩家可推注以及已推注图标
    this.UpdatePlayersTuiZhu(data.playerList)

    --显示牌--显示所有手牌
    local playerData = nil
    for i = 1, #Pin5RoomData.playerDatas do
        playerData = Pin5RoomData.playerDatas[i]
        if not IsNil(playerData) then
            playerData:CheckCards()
        end
    end
    --检测所有玩家观战中状态
    this.CheckAllPlayerLookOn()
end

--显示庄的抢庄倍数
function Pin5Room.CheckBankerAndRobMultiple()
    Pin5RoomPanel.CheckBankerTagByAllPlayer()
    --
    if Pin5RoomData.IsGameStarted() and Pin5RoomData.BankerPlayerId ~= nil and Pin5RoomData.BankerPlayerId ~= 0 then
        local playerData = Pin5RoomData.GetPlayerDataById(Pin5RoomData.BankerPlayerId)
        if playerData ~= nil and playerData.item ~= nil then
            playerData.item:ShowBankerScore(playerData.robZhuangState)
        end
    end
end

--显示抢庄倍数
function Pin5Room.CheckRobBanker()
    if Pin5RoomData.BankerPlayerId ~= nil and Pin5RoomData.BankerPlayerId ~= 0 then
        return
    end
    local playerData
    for i = 1, #Pin5RoomData.playerDatas do
        playerData = Pin5RoomData.playerDatas[i]
        playerData:ShowRobBankerMultiple()
    end
end

-- 1014006 通知房主是否可以开始游戏
function Pin5Room.OnStartGame(arg)
    local data = arg.data
    if data.start then
        if Pin5RoomData.GetSelfData().state ~= Pin5PlayerState.WAITING then
            Pin5RoomPanel.ShowStartBtn(true)
        else
            Pin5RoomPanel.ShowStartBtn(false)
        end
    else
        Pin5RoomPanel.HideStartBtn()
    end
    Pin5RoomPanel.SetStartBtnInteractable(data.start)
end

-- 1014008 通知房间变化
function Pin5Room.OnRoomState(arg)
    local data = arg.data
    Pin5RoomData.gameState = data.state
    --LogError(">> Pin5Room.OnRoomState" , data.state)
    ---更新奖池文字显示
    Pin5RoomData.UpdateAwardPoolCoinNum(data.reward.awardPoolNum)
    ---更新获奖记录
    Pin5RoomData.UpdateRewardRecord(data.reward.lastReward)

    local playerData = nil
    for i = 1, #data.playerList do
        playerData = Pin5RoomData.GetPlayerDataById(data.playerList[i].userId)
        if playerData ~= nil then
            playerData:UpdatePlayerStates(data.playerList[i].state)
            --刷新金豆数量
            playerData.gold = math.NewToNumber(data.playerList[i].gold)
            playerData.playerScore = math.NewToNumber(data.playerList[i].score)

            if not IsNil(playerData.item) then
                if Pin5RoomData.gameState == Pin5GameState.CALCULATE then
                    --结算中，不更新金币
                    playerData.item:SetBalanceState(true)
                else
                    if Pin5RoomData.IsGoldGame() then
                        playerData.item:SetScore(playerData.gold)
                    else
                        playerData.item:SetScore(playerData.playerScore)
                    end
                end
            end
        end
    end

    --倒计时
    Pin5ContentTip.UpdateData(data.state, data.countDown)

    --设置局数
    if Pin5RoomData.gameIndex ~= data.juShu then
        Pin5RoomData.gameIndex = data.juShu
        Pin5RoomPanel.SetJuShuText(Pin5RoomData.gameIndex, Pin5RoomData.gameTotal)
    end

    --更新右上
    Pin5RoomPanel.UpdateMenuInfo()
    --设置状态
    Pin5RoomCtrl.ShowUIByState()

    --更新开局提示标签
    if data.state ~= Pin5GameState.WAITTING then
        if data.state == Pin5GameState.OVER then
            Pin5RoomData.isGameStarted = false
            Pin5RoomData.isCardGameStarted = false
        else
            Pin5RoomData.isGameStarted = true
        end
        Pin5RoomPanel.HideReadyBtn()
    else
        Pin5RoomData.isCardGameStarted = false
    end

    --如果是看牌阶段，而且本玩家没有操作
    if Pin5RoomData.gameState == Pin5GameState.WATCH_CARD then
        if Pin5RoomData.GetSelfData().state == Pin5PlayerState.OPTION then
            Scheduler.scheduleOnceGlobal(function()
                --0.5秒后依旧是看牌阶段，玩家依旧是操作状态
                if Pin5RoomData.gameState == Pin5GameState.WATCH_CARD and Pin5RoomData.GetSelfData().state == Pin5PlayerState.OPTION then
                    --自动翻牌 + 自动亮牌  就不显示操作按钮，自动亮牌
                    if Pin5RoomData.isAutoFlipCard then
                        Pin5OperationPanel.OnClickShowCardButton()
                    else
                        Pin5OperationPanel.SetOperationBtnActive(true)
                    end
                else
                    Pin5OperationPanel.SetOperationBtnActive(false)
                end
            end, 0.5)
        else
            Pin5OperationPanel.SetOperationBtnActive(false)
        end
    else
        Pin5OperationPanel.SetOperationBtnActive(false)
    end

    --隐藏抢庄按钮
    if Pin5RoomData.gameState ~= Pin5GameState.ROB_ZHUANG then
        Pin5OperationPanel.HideRobZhuangReslult()
    end

    --隐藏下注按钮
    if Pin5RoomData.gameState ~= Pin5GameState.BETTING then
        Pin5OperationPanel.HideBetState()
    end
    --隐藏搓牌按钮
    if Pin5RoomData.gameState ~= Pin5GameState.WATCH_CARD then
        Pin5OperationPanel.HideRubCard()
    end

    --检测是否显示准备按钮
    this.CheckShowReadBtn()
end

--1014010 更新玩家信息(玩家加入)
function Pin5Room.OnPin5StcUpdatePlayerInfo(arg)
    LogError("1014010", arg)
    local data = arg.data
    --1为加入 2为退出
    if data.type == 1 then
        if data.seatNum > 0 then
            local playerData = this.UpdatePlayerData(data)
            --更新座位
            if Pin5RoomData.IsObserver() and data.userId == UserData.userId then
                Pin5RoomData.JudgeSitDownPlayer(data)
                if not Pin5RoomData.IsObserver() then
                    Pin5RoomPanel.HideSitDownBtn()
                    Pin5RoomPanel.HideWatchShow()
                end
            else
                Pin5RoomCtrl.UpdatePlayerUI(playerData)
            end
        end
    elseif data.type == 2 then
        if data.seatNum > 0 then
            Pin5RoomCtrl.RemovePlayerUI(data.userId)
            Pin5RoomData.RemovePlayer(data.userId)
        end
    end

    --更新聊天模块
    Pin5Room.UpdateChatPlayers(Pin5RoomPanel.GetAllPlayerItems())
end

-- 1014012 发牌
function Pin5Room.OnSendCards(arg)
    local data = arg.data
    --隐藏下注分
    this.HideBetStateScore()
    --发牌
    this.OnNormalSend(data)
end

-- 1014014 操作广播
function Pin5Room.OnBOperate(arg)
    local data = arg.data
    --1:抢庄 2:下注
    if data.operType == 1 then
        this.OnRobBanker(data)
    elseif data.operType == 2 then
        this.OnBetScore(data)
    end
end

--1014018 小结算
function Pin5Room.OnBXiaoJie(arg)
    --LogError(">> Pin5Room.OnBXiaoJie")
    local data = arg.data
    --是否第一
    Pin5RoomData.isFrist = false
    --表示有结算
    Pin5RoomData.isHaveJieSuan = true
    --游戏设为未进行中
    Pin5RoomData.isCardGameStarted = false
    --更新玩家数据
    this.UpdateXiaoJieSuanData(data.playerList)
    --检测所有玩家观战中状态
    this.CheckAllPlayerLookOn()
    --表示当前局已经结束
    Scheduler.unscheduleGlobal(balanceTimer)
    balanceTimer = nil

    balanceTimer = Scheduler.scheduleOnceGlobal(function()
        --处理结算信息
        this.HandleBalanceInfo(data)
        --比牌
        --this.CompareCard(data.isBankerPassKill)
    end, 0.5)

    --如果自己是中途加入并且已经坐下则关闭观看中，等待中图标
    if not Pin5RoomData.GetSelfIsNoReady() then
        Pin5RoomPanel.HideWatchShow()
    end

    --隐藏操作要牌
    Pin5OperationPanel.SetOperationBtnActive(false)

    Pin5RoomPanel.UpdateMenuInfo()

    --隐藏自动翻牌开关
    Pin5RoomPanel.HideAutoFlip()
end

--房主解散房间回复
function Pin5Room.OnOwnerDissolve(arg)
    local data = arg.data
    if data.code == 0 then
        Toast.Show("解散房间成功")
        this.ExitRoom()
    else
        Toast.Show("解散房间失败")
    end
end

--检查自己的状态
function Pin5Room.CheckSelfState()
    local selfData = Pin5RoomData.GetSelfData()
    --中途加入显示准备与观看  游戏已经开始
    if Pin5RoomData.IsObserver() then
        Pin5RoomPanel.ShowWatch()
    else
        if not IsNil(selfData) and Pin5RoomData.IsGameStarted() then
            local selfState = selfData.state
            if selfState == Pin5PlayerState.WAITING or selfState == Pin5PlayerState.NO_READY then
                Pin5RoomPanel.ShowWatch()
            elseif selfState == Pin5PlayerState.WAIT or selfState == Pin5PlayerState.OPTION then
                Pin5RoomPanel.HideWatchShow()
            elseif selfState == Pin5PlayerState.WAITING_START or selfState == Pin5PlayerState.READY then
                Pin5RoomPanel.ShowWait()
            else
                Pin5RoomPanel.HideWatchShow()
            end
        else
            Pin5RoomPanel.HideWatchShow()
        end
    end
end

--设置一个玩家的信息
function Pin5Room.UpdatePlayerData(data)
    local playerData = Pin5RoomData.GetPlayerDataById(data.userId)
    LogError("<color=aqua>playerData</color>", data)
    if playerData == nil then
        playerData = Pin5Player:New()
        table.insert(Pin5RoomData.playerDatas, playerData)
    end
    playerData:SetPlayerData(data)
    playerData.handCards = data.midCard
    playerData.xiaZhuScore = data.betNum
    playerData.robZhuangState = data.robNum
    playerData.gold = data.gold
    playerData.isPushBet = data.isPushBet --抢庄后是否还可以推注
    return playerData
end

function Pin5Room.ShowPin5ErrorMsg(data)
    if data.code ~= 0 then
        if data.code == 9 then
            Alert.Show("退出房间失败")
        elseif data.code == 10 then
            Alert.Show("游戏已开始，无法离开游戏")
        elseif data.code == 11 then
            Alert.Show("房主解散房间")
        elseif data.code == 12 then
            Alert.Show("房间被强制解散")
        elseif data.code == 101 then
            Alert.Show("抢庄倍数错误")
        elseif data.code == 102 then
            Alert.Show("下注分数错误")
        elseif data.code == 103 then
            Alert.Show("参与了抢庄不能下最低注")
        elseif data.code == 104 then
            Alert.Show("金豆不足，请前往充值")
        elseif data.code == 105 then
            Alert.Show("观战已超过三局，自动退出房间")
        elseif data.code == 106 then
            Alert.Show("不是翻牌状态下不能翻牌")
        elseif data.code == 107 then
            Alert.Show("您的元宝不足，无法继续游戏")
        elseif data.code == 108 then
            Alert.Show("未找到观战玩家")
        elseif data.code == 109 then
            Alert.Show("桌子已满")
        elseif data.code == 110 then
            Alert.Show("坐下失败")
        elseif data.code == 111 then
            Alert.Show("已经坐下")
        elseif data.code == 112 then
            Alert.Show("最后三局不能坐下")
        elseif data.code == 113 then
            Alert.Show("积分不足")
        elseif data.code == 201 then
            Alert.Show("不能操作")
        end
        return
    end
end

-- 1014025 准备返回某个玩家坐下
function Pin5Room.OnStcReady(arg)
    local data = arg.data
    this.ShowPin5ErrorMsg(data)
    this.UpdateReadyState(Pin5RoomData.mainId)
    local selfData = Pin5RoomData.GetSelfData()

    if selfData then
        Pin5RoomPanel.HideReadyBtn()

        --判断是否显示等待中
        if Pin5RoomData.IsGameStarted() and selfData.state == Pin5PlayerState.WAITING then
            Pin5RoomPanel.ShowWait()
        end
        Pin5RoomCtrl.ShowUIByState()
        Pin5RoomPanel.UpdateMenuInfo()

        if not IsNil(selfData.item) then
            local playerData = nil
            for i = 1, #Pin5RoomData.playerDatas do
                playerData = Pin5RoomData.playerDatas[i]
                if playerData.item ~= nil then
                    playerData.item:Reset()
                end
            end
        end
    else
        Pin5RoomPanel.ShowWait()
    end

    --检查显示等待中牌子
    this.CheckSelfState()
end

function Pin5Room.UpdateReadyState(playerId)
    --更新数据
    local playerData = Pin5RoomData.GetPlayerDataById(playerId)
    -- 准备
    if playerData and not IsNil(playerData.item) then
        local isReady = playerData.state == Pin5PlayerState.READY or playerData.state == Pin5PlayerState.WAITING_START
        playerData.item:SetReadyDisplay(isReady)
    end
end

-- 1014032 游戏开始游戏开始
function Pin5Room.OnGameStart(arg)
    local data = arg.data

    --隐藏开始按钮
    Pin5RoomPanel.HideStartBtn()

    if not Pin5RoomData.IsGoldGame() then
        --更新局数
        Pin5RoomPanel.SetJuShuText(Pin5RoomData.gameIndex, Pin5RoomData.gameTotal)
    end

    --整局游戏开始
    Pin5RoomData.isGameStarted = true
    --游戏开始
    Pin5RoomData.isCardGameStarted = true
    --隐藏所有玩家准备图标
    Pin5RoomPanel.HideAllReadyImge()
    -- 更新菜单信息
    Pin5RoomPanel.UpdateMenuInfo()
    --播放开始音效
    --Pin5ResourcesMgr.PlayGameSound(Pin5GameEffSoundType.EFFSTART)
    --停止播放结算动画
    Scheduler.unscheduleGlobal(balanceTimer)
    balanceTimer = nil
    this.StopFlyResultGoldTimer()
    this.StopCloseRobBankerMultipleAnimTimer()
    --结算取消
    Pin5RoomData.isHaveJieSuan = false
    --重置庄家id
    Pin5RoomData.BankerPlayerId = nil
    --重置操作面板界面
    Pin5OperationPanel.Reset()

    --游戏开始后重置观战玩家的桌面界面
    if Pin5RoomData.GetSelfIsNoReady() then
        Pin5RoomPanel.ShowWatch()
    else
        Pin5RoomPanel.HideWatchShow()
    end

    this.XiaoJieReset()
    --检测所有玩家观战中状态
    this.CheckAllPlayerLookOn()

    --开局后不显示准备按钮
    Pin5RoomPanel.HideReadyBtn()

    --显示推注信息
    this.UpdatePlayersTuiZhu(data.playerList)

    --判断是否显示自动翻牌按钮
    if not Pin5RoomData.GetSelfIsNoReady() then
        --显示自动翻牌开关
        Pin5RoomPanel.ShowAutoFlip()
    end
end

-- 更新推注状态
function Pin5Room.UpdatePlayersTuiZhu(playerList)
    local playerId
    local playerData
    for i = 1, #playerList do
        playerId = playerList[i].userId
        playerData = Pin5RoomData.GetPlayerDataById(playerId)
        if not IsNil(playerData) then
            playerData.pushBet = playerList[i].pushBet
            playerData.isPushBet = playerList[i].isPushBet
            if Pin5RoomData.IsGameStarted() then
                playerData:UpdataTuiZhuState()
            else
                playerData:UpdataTuiZhuState(false, false)
            end
        end
    end
end

function Pin5Room.XiaoJieReset()
    --开局重置的数据
    Pin5RoomData.StartGameReset()
    --重置游戏牌局
    Pin5RoomPanel.Reset()
    Pin5DeskPanel.ResetPin5Desk()
end

--==============================--
--desc: 普通发牌
--time:2018-12-20 10:51:52
--@pin5DeskCtrl: 桌面的Ctrl组件
--@data: 循环列表，data.list 包含uId以及牌点数
--@return
--==============================--
function Pin5Room.OnNormalSend(data)
    local playerList = nil
    local playerData
    local cards
    local allCards
    local cardLen
    local allcardLen
    for i = 1, #data.playerList do
        playerList = data.playerList[i]
        playerData = Pin5RoomData.GetPlayerDataById(playerList.playerId)
        cards = playerList.nowCard
        allCards = playerList.midCard
        cardLen = #cards
        allcardLen = #allCards

        local cardsTab = {}
        for i = 1, cardLen do
            table.insert(cardsTab, { card = cards[i], index = #playerData.handCards + i })
            if i == cardLen then
                if allcardLen == 5 then
                    cardsTab[i].card = "-1"
                end
            end
        end

        playerData.handCards = {}
        for i = 1, #allCards do
            table.insert(playerData.handCards, allCards[i])
            if i == 5 then
                playerData.fiveCard = allCards[i]
                playerData.handCards[i] = "-1"
            end
        end

        Pin5DeskPanel.SendCards(playerData, cardsTab)
    end
end

-- 通知抢庄
function Pin5Room.OnInfromRobBanker(data)
    if Pin5RoomData.isGameStarted and Pin5RoomData.GetSelfIsNoReady() then
        Pin5RoomPanel.ShowWatch()
        return
    end

    Pin5RoomPanel.HideWatchShow()

    --LogError("抢庄score", data.score)
    --local value = tonumber(data.score)
    --LogError("抢庄value", value)
    --显示抢庄按钮
    Pin5OperationPanel.ShowRobZhuangReslult(data.score)
    --播放抢庄通知
    --Pin5ResourcesMgr.PlayGameSound(Pin5GameEffSoundType.EFFCALLROB)
end

-- 抢庄信息
function Pin5Room.OnRobBanker(data)
    if data.playerId == Pin5RoomData.mainId then
        --关闭抢庄界面
        Pin5OperationPanel.HideRobZhuangReslult()
    end

    local playerData = Pin5RoomData.GetPlayerDataById(data.playerId)
    if playerData ~= nil then
        playerData.robZhuangState = data.robNum
        --显示抢几
        playerData:ShowRobBankerMultiple()
    end
end

-- 1014034 抢庄完成
function Pin5Room.OnRobBankerEnd(arg)
    --LogError(">> Pin5Room.OnRobBankerEnd > ", arg)
    local data = arg.data
    Pin5RoomData.BankerPlayerId = data.zhuangId
    local bankerData = Pin5RoomData.GetPlayerDataById(Pin5RoomData.BankerPlayerId)

    if data.maxRob == 0 then
        bankerData.robZhuangState = RobZhuangNumType.Rob
    else
        bankerData.robZhuangState = data.maxRob
    end

    --隐藏所有未参与抢庄的玩家信息
    local tempPlayerData = nil
    for i = 1, #Pin5RoomData.playerDatas do
        tempPlayerData = Pin5RoomData.playerDatas[i]
        tempPlayerData.isPushBet = false

        for j = 1, #data.robList do
            if tempPlayerData.pushBet and data.robList[j] == tempPlayerData.id then
                tempPlayerData.isPushBet = true
                break
            end
        end
    end

    --检测所有玩家推注状态
    this.CheckAllPlayerTuiZhu()

    --关闭庄家可推注显示
    bankerData:UpdataTuiZhuState(false)
    --抢庄
    this.CheckRobZhuang(data.robList)
    --启动关闭抢庄倍数动画
    this.StartCloseRobBankerMultipleAnimTimer()

end

--启动关闭抢庄倍数动画
function Pin5Room.StartCloseRobBankerMultipleAnimTimer()
    if this.closeRobBankerMultipleAnimTimer == nil then
        this.closeRobBankerMultipleAnimTimer = Timing.New(this.OnCloseRobBankerMultipleAnimTimer, 1.6)
    end
    this.closeRobBankerMultipleAnimTimer:Restart()
end

--停止关闭抢庄倍数动画
function Pin5Room.StopCloseRobBankerMultipleAnimTimer()
    if this.closeRobBankerMultipleAnimTimer ~= nil then
        this.closeRobBankerMultipleAnimTimer:Stop()
    end
end

--处理关闭抢庄倍数动画
function Pin5Room.OnCloseRobBankerMultipleAnimTimer()
    this.StopCloseRobBankerMultipleAnimTimer()
    --关闭抢庄抢几
    this.CloseRobZhuangNum()
end

--1014038 房间自动解散
function Pin5Room.OnRoomAutoDiss(arg)
    local data = arg.data
    Pin5RoomData.isGameOver = true
    Pin5RoomData.isGameStarted = false
    --收到总结算 隐藏准备按钮
    Pin5RoomPanel.HideReadyBtn()
    --收到总结算，处理提示语
    Pin5ContentTip.HandleZongJieSuan()
    if Pin5RoomData.IsGoldGame() and Pin5RoomData.IsFangKaFlow() then
        this.OpenJieSuanPanelLater()
    end
end

function Pin5Room.OnOwnerChange(arg)
    LogError("<color=aqua>OnOwnerChange</color>", arg)
    Pin5RoomData.owner = arg.data.adminId
    LogError("Pin5RoomData.isObserver", Pin5RoomData.isObserver)
    local isOwner = Pin5RoomData.MainIsOwner()
    if not Pin5RoomData.isObserver then
        Pin5RoomPanel.ShowStartBtn(isOwner)
    end
end

function Pin5Room.OnGetErrorCode(arg)
    local code = arg.data.code
    if code == 114 then
        Toast.Show("准备人数不足")
    end
end

---收到玩家奖池开奖
function Pin5Room.OnOpenAwardPool(arg)
    LogError("开奖", arg.data.award)
    Pin5RoomPanel.ShowCoinEffect(arg.data.award)
end

--获取提示返回
function Pin5Room.OnGetTipCard(arg)
    local data = arg.data
    this.OnTipOrShowCard(data, Pin5RoomData.mainId, Pin5OperationCardType.TipCard)
end

--广播亮牌
function Pin5Room.OnGetShowCard(arg)
    local data = arg.data
    this.OnTipOrShowCard(data, data.playerId, Pin5OperationCardType.ShowCard)
end

--亮牌或者提示牌
function Pin5Room.OnTipOrShowCard(data, playerId, state)
    local playerData = Pin5RoomData.GetPlayerDataById(playerId)
    local playerItem = playerData.item
    data.point = tostring(data.point)
    playerData.handCards = data.spellCard

    --Pin5ResourcesMgr.PlayCardPointSound(playerData.id, data.point)
    if state == Pin5OperationCardType.ShowCard then
        playerData.fiveCard = data.lastCard[1]
        if data.playerId == Pin5RoomData.mainId then
            Pin5OperationPanel.SetOperationBtnActive(false)
            this.CheckCardArrange(playerItem, data.spellCard, data.point)
        end
    elseif state == Pin5OperationCardType.TipCard then
        this.CheckCardArrange(playerItem, data.spellCard, data.point)
    end

    playerData:CheckCards()

    if state == Pin5OperationCardType.ShowCard then
        playerItem:UpFiveCard(false)
    end

    --播放结果音效
    playerData.cardType = data.point
    local point = tostring(data.point)
    playerItem:CheckShowResultType(Pin5CardTypeValue[Pin5RoomData.fanBeiRuleValue][point], data.point, false)
end

--检测牌的排列方式
function Pin5Room.CheckCardArrange(playerItem, cards, type)
    type = tonumber(type)
    if type == 0 then
        --不缩进
        playerItem:SetShrinkCards()
    elseif type > 10 then
        --缩进
        playerItem:SetShrinkCards()
    else
        if this.CheckTopThreeIsNiu(cards) then
            playerItem:SetThreeBinaryCards()
        else
            playerItem:SetShrinkCards()
        end
    end
end

--检测前三张加起来是否是10
function Pin5Room.CheckTopThreeIsNiu(cards)
    local sum = 0
    local point = 0
    for i = 1, 3 do
        point = math.floor(tonumber(cards[i]) / 100)
        if point > 10 then
            point = 10
        end
        sum = sum + point
    end
    if sum % 10 == 0 then
        return true
    end
    return false
end

---=================================================================
--比牌
function Pin5Room.CompareCard(isBankerPassKill)
    --比牌
    -- Pin5OperationPanel.ShowCompareCard(function()
    --     if Pin5RoomData.gameState == Pin5GameState.CALCULATE then
    --         Log(">>>>>>>>>>>>>>>>>>>>>>>>>         比牌结束")
    --         ---禁用庄家通杀
    --         --if isBankerPassKill then
    --         --    Pin5OperationPanel.ShowTongSha()
    --         --    --播放结果音效
    --         --    Pin5ResourcesMgr.PlayGameSound(Pin5GameEffSoundType.EFFALLKILL)
    --         --end
    --     end
    -- end)
end

--更新小结算数据
function Pin5Room.UpdateXiaoJieSuanData(playerList)
    for i = 1, #playerList do
        local playerInfo = playerList[i]
        local playerId = playerInfo.playerId
        local playerData = Pin5RoomData.GetPlayerDataById(playerId)
        if not IsNil(playerData) then
            --本局扣除分数
            playerData.tempbjpoint = math.NewToNumber(playerInfo.currScore)
            --炮类型
            playerData.cardType = playerInfo.point
            --更新玩家分数
            playerData.playerScore = math.NewToNumber(playerInfo.score)
            --更新玩家手牌
            playerData.handCards = playerInfo.midCard
        end
    end
end

-- 处理小结算信息
function Pin5Room.HandleBalanceInfo(data)
    --LogError(">> Pin5Room.HandleBalanceInfo")
    --缓存当前的结算数据
    this.balanceData = data
    --保存战局结果
    this.losers = {}
    this.winners = {}
    local bankerIsWin = false

    -- 显示手牌
    for i = 1, #data.playerList do
        local playerInfo = data.playerList[i]
        local playerId = playerInfo.playerId
        local playerData = Pin5RoomData.GetPlayerDataById(playerId)
        if not IsNil(playerData) then
            local playerItem = playerData.item

            playerData.handCards = playerInfo.spellCard

            playerData:ShowAllCard(playerInfo.spellCard)

            playerData.fiveCard = playerInfo.lastCard[1]

            --显示结算的牌
            this.CheckCardArrange(playerItem, playerInfo.spellCard, playerInfo.point)

            playerItem:UpFiveCard(false)

            --显示点数 point
            local cardTypes = Pin5CardTypeValue[tonumber(Pin5RoomData.fanBeiRuleValue)]
            --LogError(string.format("牌型点数 牛%s %s倍", playerInfo.point, Pin5RoomData.fanBeiRuleValue))
            local point = tostring(playerInfo.point)
            playerItem:CheckShowResultType(cardTypes[point], point, true)

            --统计
            --根据输赢保存玩家
            if playerId ~= Pin5RoomData.BankerPlayerId then
                if math.NewToNumber(playerInfo.currScore) < 0 then
                    table.insert(this.losers, playerInfo)
                else
                    table.insert(this.winners, playerInfo)
                end
            else
                if math.NewToNumber(playerInfo.currScore) > 0 then
                    bankerIsWin = true
                end
            end
        end
    end
    --播放结算动画
    this.PlayBalancaAnim(data, bankerIsWin, this.winners, this.losers)
    --
    this.CheckFlyResultGold()
end

--================================================================
--================================================================

--检测飞结果金币
function Pin5Room.CheckFlyResultGold()
    local winnerLength = 0
    if this.winners ~= nil then
        winnerLength = #this.winners
    end
    local loserLength = 0
    if this.losers ~= nil then
        loserLength = #this.losers
    end
    --播放飞金币，先飞庄赢，再飞庄输
    if loserLength > 0 then
        this.PlayFlyResultGoldAnim(this.losers)
        this.losers = nil
        this.flyResultGoldEndTime = Time.realtimeSinceStartup + 1.2
        this.StartFlyResultGoldTimer()
    elseif winnerLength > 0 then
        this.PlayFlyResultGoldAnim(this.winners)
        this.winners = nil
        this.flyResultGoldEndTime = Time.realtimeSinceStartup + 1
        this.StartFlyResultGoldTimer()
    else
        this.StopFlyResultGoldTimer()
        this.HandleResultDisplay()
    end
end

--启动飞金币计时器
function Pin5Room.StartFlyResultGoldTimer()
    if this.flyResultGoldTimer == nil then
        this.flyResultGoldTimer = Timing.New(this.OnFlyResultGoldTimer, 0.05)
    end
    this.flyResultGoldTimer:Start()
end

--停止飞金币计时器
function Pin5Room.StopFlyResultGoldTimer()
    if this.flyResultGoldTimer ~= nil then
        this.flyResultGoldTimer:Stop()
    end
end

--处理飞金币计时器
function Pin5Room.OnFlyResultGoldTimer()
    if Time.realtimeSinceStartup > this.flyResultGoldEndTime then
        --当前步骤结束
        this.CheckFlyResultGold()
    end
end

--播放飞结果金币
function Pin5Room.PlayFlyResultGoldAnim(list)
    local bankerPlayerItem = Pin5RoomData.GetPlayerItemById(Pin5RoomData.BankerPlayerId)
    if bankerPlayerItem ~= nil then
        local position = bankerPlayerItem:GetHeadPosition()
        for i = 1, #list do
            local playerInfo = list[i]
            local playerItem = Pin5RoomData.GetPlayerItemById(playerInfo.playerId)
            if not IsNil(playerItem) then
                --LogError(">> Pin5Room.PlayFlyResultGoldAnim > ", playerInfo.currScore, postion)
                --飞金币
                playerItem:FlyResultGold(position, math.NewToNumber(playerInfo.currScore))
            end
        end
        if #list > 0 then
            Pin5ResourcesMgr.PlayGameSound(Pin5GameEffSoundType.EFFFLYCOINS)
        end
    end
end

--处理结果显示，显示输赢分数，播放赢家动画
function Pin5Room.HandleResultDisplay()
    local list = {}
    if this.balanceData ~= nil then
        list = this.balanceData.playerList
    end
    local score = 0
    for i = 1, #list do
        local playerInfo = list[i]
        local playerItem = Pin5RoomData.GetPlayerItemById(playerInfo.playerId)
        local playerData = Pin5RoomData.GetPlayerDataById(playerInfo.playerId)
        if not IsNil(playerItem) then
            --恢复结算状态
            playerItem:SetBalanceState(false)
            if playerData ~= nil then
                --更新结算玩家Score
                if Pin5RoomData.IsGoldGame() then
                    playerItem:SetScore(playerData.gold)
                else
                    playerItem:SetScore(playerData.playerScore)
                end
            end
            --播放数赢分数动画
            score = tonumber(playerInfo.currScore)
            playerItem:ShowScoreAnim(score)
            --播放赢动画
            if score > 0 then
                playerItem:PlayWinAnim()
            end
        end
    end
end

--================================================================
--================================================================

--播放结算动画
function Pin5Room.PlayBalancaAnim(data, bankerIsWin, winners, losers)
    --当庄赢得时候 判断是否赢得玩家只有庄 否则，没有庄家通杀
    if bankerIsWin then
        data.isBankerPassKill = this.IsBankerPassKill(winners)
    else
        data.isBankerPassKill = false
    end

    --自己在战绩中表示非中途加入 兼容使用（防止出现枪几出现）
    if Pin5RoomData.GetSelfData().state ~= Pin5PlayerState.WAITING then
        --关闭抢庄抢几
        this.CloseRobZhuangNum()
    end

    --处理小结算提示语
    Pin5ContentTip.HandleXiaoJieSuan()
end


--是否是庄家通杀
function Pin5Room.IsBankerPassKill(winners)
    if #winners == 0 then
        return true
    end
    return false
end

--检测所有玩家观战中
function Pin5Room.CheckAllPlayerLookOn()
    for i, playerData in ipairs(Pin5RoomData.playerDatas) do
        local playerItem = playerData.item
        if not IsNil(playerItem) then
            --显示观战中
            if Pin5RoomData.isCardGameStarted and playerData.state == Pin5PlayerState.WAITING then
                playerItem:SetImgLookOnDisplay(true)
            else
                playerItem:SetImgLookOnDisplay(false)
            end
        end
    end
end
---------------------------------------------------------------
-- 1014020 总结算
function Pin5Room.OnBZongJie(arg)
    Pin5RoomData.isGameOver = true
    local data = arg.data
    Pin5RoomData.Note = data.note
    Pin5RoomData.isGameStarted = false

    --收到总结算 隐藏准备按钮
    Pin5RoomPanel.HideReadyBtn()
    --收到总结算，处理提示语
    Pin5ContentTip.HandleZongJieSuan()

    local summarizeData = {}
    for i = 1, #data.playerList do
        local list = data.playerList[i]
        local playerData = Pin5RoomData.GetPlayerDataById(list.playerId)

        local tab = {}
        tab.bankerCount = list.zhuangCount
        tab.robBankerCount = list.robZhuangCount
        tab.bolusCount = list.pushBetCount
        tab.playerId = list.playerId
        tab.score = tonumber(list.score)
        tab.winNum = list.winNum
        tab.loseNum = list.loseNum
        tab.tieNum = list.tieNum
        tab.name = playerData.name
        tab.headUrl = playerData.playerHead
        tab.uId = playerData.id
        table.insert(summarizeData, tab)
    end

    summarizeData.endTime = data.endTime
    summarizeData.roomCode = Pin5RoomData.roomCode
    summarizeData.difen = Pin5RoomData.diFen
    summarizeData.model = Pin5RoomData.model
    summarizeData.jushu = Pin5RoomData.gameTotal .. "局"
    summarizeData.owner = Pin5RoomData.owner
    summarizeData.gameName = Pin5RoomData.gameName
    summarizeData.manCount = Pin5RoomData.manCount

    Pin5RoomData.netJieSuanData = summarizeData
    this.OpenJieSuanPanelLater()
end

function Pin5Room.OpenJieSuanPanelLater()
    Scheduler.scheduleOnceGlobal(function()
        if PanelManager.IsOpened(Pin5PanelConfig.Room) and not PanelManager.IsOpened(Pin5PanelConfig.JieSuan) then
            PanelManager.Open(Pin5PanelConfig.JieSuan)
        end
    end, 3)
end

--  1014026 操作同意与拒绝解散房间
function Pin5Room.OnDissolveTip(arg)
    local data = arg.data
    --检测是否完成
    local endState = 1 --0未有结果 1:解散成功 2:解散失败
    local player --  -1 待操作 1 同意 0 拒绝
    local playerId = 0
    for i = 1, #data.playerList do
        player = data.playerList[i]
        if player.status == 0 then
            endState = 2
            playerId = player.userId
            break
        elseif player.status == -1 then
            endState = 0
            break
        end
    end

    if endState == 0 then
        PanelManager.Open(Pin5PanelConfig.Dismiss, data)
    elseif endState == 1 then
        this.OnDismissRoomSucceed()
    else
        this.OnDismissRoomFailure(playerId)
    end
end

--  解散房间结果成功
function Pin5Room.OnDismissRoomSucceed()
    PanelManager.Close(Pin5PanelConfig.Dismiss, true)
    if Pin5RoomData.MainIsOwner() then
        Toast.Show("解散成功")
    else
        Toast.Show("游戏已解散")
    end
    -- this.ExitRoom()
end

--  解散房间结果失败
function Pin5Room.OnDismissRoomFailure(playerId)
    PanelManager.Close(Pin5PanelConfig.Dismiss, true)
    if playerId ~= Pin5RoomData.mainId then
        local playerName = Pin5RoomData.GetPlayerDataById(playerId).name
        Toast.Show(playerName .. "拒绝了解散房间")
    end
end

-- 1014036 离开房间
function Pin5Room.OnLeaveRoom(arg)
    if arg.code == 0 then
        local data = arg.data
        if data.code == 0 then
            this.ExitRoom()
        elseif data.code == 9 then
            Toast.Show("退出房间失败")
        elseif data.code == 10 then
            Toast.Show("游戏已开始，无法离开游戏")
        elseif data.code == 11 then
            Toast.Show("房主解散房间")
            this.ExitRoom()
        elseif data.code == 12 then
            Toast.Show("房间被强制解散")
            this.ExitRoom()
        elseif data.code == 105 then
            Alert.Show("观战已超过三局，自动退出房间", function()
                this.ExitRoom()
            end)
        elseif data.code == 107 then
            Alert.Show("您的元宝不足，无法继续游戏", function()
                this.ExitRoom()
            end)
        end
    end
end

-- 1014022 通知下注或者抢庄
function Pin5Room.OnBBetOrRobBanker(arg)
    local data = arg.data
    --下注
    if data.type == 1 then
        this.OnInformBetScore(data)
    else
        --抢庄
        this.OnInfromRobBanker(data)
    end
end

-- 1014022 通知下注
function Pin5Room.OnInformBetScore(data)
    local scores = {}
    if data.pushBet then
        for i = 1, #data.score do
            if i == #data.score then
                data.tz = { data.score[i] }
            else
                table.insert(scores, data.score[i])
            end
        end
    else
        scores = data.score
        data.tz = {}
    end

    --检测所有玩家推注状态
    this.CheckAllPlayerTuiZhu()

    local tempData = {
        difen = scores,
        tuizhu = data.tz,
        limitXiaZhuScore = {},
    }

    --庄家是自己，或者自己没有坐下，表示在观战。不做处理
    if Pin5RoomData.MainIsBanker() or Pin5RoomData.GetSelfIsNoReady() or Pin5RoomData.IsObserver() then
        return
    end

    local time = 1
    if not Pin5Funtions.isRobBanker() then
        time = 0
    end

    if not IsNil(betStateTimer) then
        Scheduler.unscheduleGlobal(betStateTimer)
        betStateTimer = nil
    end

    betStateTimer = Scheduler.scheduleOnceGlobal(HandlerArgs(this.BetStateShow, tempData), time)
end

--下注显示
function Pin5Room.BetStateShow(data)
    if Pin5RoomData.gameState == Pin5GameState.BETTING then
        if Pin5RoomData.MainIsBanker() then
            this.HideBetStateScore()
        else
            local xiaZhuStr = data.difen
            local zuiZhuStr = data.tuizhu
            local restrictScore = data.limitXiaZhuScore
            Pin5OperationPanel.ShowBetState(xiaZhuStr, zuiZhuStr, restrictScore)
        end
        --播放下注通知
        --Pin5ResourcesMgr.PlayGameSound(Pin5GameEffSoundType.EFFCallBET)
    else
        Pin5OperationPanel.HideBetState()
    end
end

function Pin5Room.HideBetStateScore()
    if not IsNil(betStateTimer) then
        Scheduler.unscheduleGlobal(betStateTimer)
        betStateTimer = nil
    end
    Pin5OperationPanel.HideBetState()
end

-- 返回下注
function Pin5Room.OnBetScore(data)
    local playerData = Pin5RoomData.GetPlayerDataById(data.playerId)
    local playerItem = playerData.item

    if data.playerId == Pin5RoomData.mainId then
        this.HideBetStateScore()
    end

    if not IsNil(playerData) and not IsNil(playerItem) then
        playerData.xiaZhuScore = data.betNum
        playerData:UpdataTuiZhuState(false)
        playerData:FlyBetGold(function()
            playerItem:ShowBetPoints(playerData.xiaZhuScore)
        end)
        --关闭可推注显示 并且检测是否已推注
    else
        LogError("玩家playerData为nil")
    end
end

--更新玩家的金豆
--type(1支付桌费2游戏盈亏3付费表情)
function Pin5Room.UpdatePlayerGold(data)
    if data == nil or data.players == nil then
        return
    end

    local isHandleDeductGold = data.type == DeductGoldType.Game
    --玩家自己的ID，用于更新金豆
    local userId = UserData.GetUserId()
    local length = #data.players
    local temp = nil
    for i = 1, length do
        temp = data.players[i]
        local playerData = Pin5RoomData.GetPlayerDataById(temp.id)
        if temp.gold ~= nil then
            if Pin5RoomData.IsGoldGame() then
                playerData.playerScore = temp.gold
                if not IsNil(playerData.item) then
                    playerData.item:SetScore(playerData.playerScore)
                end
            end
            --更新玩家的金豆
            if temp.id == userId then
                UserData.SetGold(temp.gold)
            end
        end
    end
end

--电量设置
function Pin5Room.OnBatteryState(value)
    Pin5RoomPanel.UpdateEnergyValue(value)
end

local lastPing = 0
--ping值
function Pin5Room.OnPing(arg)
    if lastPing == arg then
        return
    end
    lastPing = arg
    if arg ~= "" and not IsNil(Pin5RoomPanel) then
        Pin5RoomPanel.UpdateNetPing(arg)
    end
end

------------------------------------------------------------------
--开始显示庄家图标，，动画
function Pin5Room.CheckRobZhuang(robPlayerIds)
    LogError(">> Pin5Room.CheckRobZhuang > robPlayerIds = ", robPlayerIds)
    if Pin5RoomData.BankerPlayerId == "" then
        return
    end
    LogError(">> Pin5Room.CheckRobZhuang > isPlayRubZhuangAni = ", Pin5RoomData.isPlayRubZhuangAni)
    if not Pin5RoomData.isPlayback and not Pin5RoomData.isPlayRubZhuangAni and Pin5Funtions.isRobBanker() then
        Pin5RoomData.isPlayRubZhuangAni = true
        Pin5RoomAnimator.PlayRobBankerAnim(robPlayerIds, this.OnPlayRobBankerAnimCompleted)
    else
        --显示庄家图标和播放抢庄倍数显示
        this.OnPlayRobBankerAnimCompleted()
    end
end

function Pin5Room.OnPlayRobBankerAnimCompleted()
    Pin5RoomPanel.CheckBankerTagByAllPlayer()
    local playerItem = Pin5RoomData.GetPlayerItemById(Pin5RoomData.BankerPlayerId)
    local playerData = Pin5RoomData.GetPlayerDataById(Pin5RoomData.BankerPlayerId)
    if playerItem ~= nil and playerData ~= nil then
        if Pin5RoomData.IsGameStarted() then
            playerItem:FlyBetGold(function()
                playerItem:ShowBankerScore(playerData.robZhuangState)
            end)
        end
    end
end

--关闭抢庄抢几
function Pin5Room.CloseRobZhuangNum()
    for _, playerData in ipairs(Pin5RoomData.playerDatas) do
        playerData:HideRobBankerMultiple()
    end
end

--播放语音显示聊天气泡框
function Pin5Room.OnShowChatBubble(formId, duration, text)
    local playerItem = Pin5RoomData.GetPlayerItemById(formId)
    if playerItem ~= nil then
        playerItem:ShowChatText(duration, text)
    end
end
------------------------------------------------------------------
--
--初始化聊天系统
function Pin5Room.InitChatManager()
    --初始化聊天模块
    ChatModule.Init()
    --当前游戏参数
    ChatModule.SetChatCallback(this.OnShowChatBubble)
    local config = {
        audioBundle = Pin5BundleName.chat,
        textChatConfig = Pin5ChatLabelArr,
        languageType = LanguageType.putonghua,
    }
    ChatModule.SetChatConfig(config)
end

--聊天模块
--玩家数据更新
function Pin5Room.UpdateChatPlayers(playerItems)
    local players = {}
    for k, v in pairs(playerItems) do
        if IsTable(v) and not string.IsNullOrEmpty(v.playerId) and v.playerId ~= 0 then
            local playerData = Pin5RoomData.GetPlayerDataById(v.playerId)
            if playerData ~= nil then
                players[v.playerId] = {}
                players[v.playerId].emotionNode = v.faceTransform
                players[v.playerId].animNode = v.faceTransform
                players[v.playerId].gender = playerData.sex
                players[v.playerId].name = playerData.name
            end
        end
    end
    ChatModule.SetPlayerInfos(players)
end
-------------------------------
--系统级
function Pin5Room.OnPushSystemTips(data)
    Log("系统提示：", data, this.isEnd)
    --游戏已经结束，未找到房间号
    if data.code == SystemTipsErrorCode.GameOver or data.code == SystemTipsErrorCode.EmptyUser then
        if not this.isEnd then
            Alert.Show("游戏已结束，返回大厅", function()
                this.ExitRoom()
            end)
        end
    else
        if data.code == SystemErrorCode.RoomIsNotExist10003 or SystemErrorCode.GameIsEnd20008 then
            if not this.isEnd then
                Alert.Show("游戏已结束，返回大厅", function()
                    this.ExitRoom()
                end)
            end
        end
    end
end
-------------------------------
--退出房间
function Pin5Room.ExitRoom()
    -- if Pin5RoomData.isPlayback then
    --     Pin5PlaybackMgr.Clear()
    -- end
    Pin5RoomCtrl.ExitRoom()
end

--检测显示准备按钮
function Pin5Room.CheckShowReadBtn()
    if Pin5RoomData.isObserver then
        return
    end
    if Pin5RoomData.gameState == Pin5GameState.WAITTING then
        local selfData = Pin5RoomData.GetSelfData()
        if selfData.state == Pin5PlayerState.WAITING or selfData.state == Pin5PlayerState.NO_READY then
            if not Pin5RoomData.IsFangKaFlow() then
                if not Pin5RoomData.isCardGameStarted then
                    --金币场显示准备按钮
                    Pin5RoomPanel.ShowReadyBtn(true)
                end
            else
                if Pin5RoomData.MainIsOwner() and Pin5RoomData.GetSelfData().state == Pin5PlayerState.WAITING and not Pin5RoomData.IsGameStarted() then
                    --显示准备
                    Pin5RoomPanel.ShowReadyBtn(false)
                else
                    --显示准备(小局之间的准备)
                    Pin5RoomPanel.ShowReadyBtn(true and not Pin5RoomData.IsGameStarted())
                end
            end
        end
    end
end

--1014028 推送离线状态
function Pin5Room.OnOffline(arg)
    local data = arg.data
    if data.type == 1 then
        local playerData = Pin5RoomData.GetPlayerDataById(data.arg.userId)
        if not IsNil(playerData) then
            playerData.isOffline = data.arg.isOnline == false
            if not IsNil(playerData.item) then
                playerData.item:SetImgOfflineDisplay(playerData.isOffline == true)
            end
        end
    end
end

--检测所有玩家推注图标
function Pin5Room.CheckAllPlayerTuiZhu()
    local playerData = nil
    for i = 1, #Pin5RoomData.playerDatas do
        playerData = Pin5RoomData.playerDatas[i]

        if playerData.id == Pin5RoomData.BankerPlayerId then
            playerData.pushBet = false
            playerData.isPushBet = false
        end

        playerData:UpdataTuiZhuState()
    end
end

-- 推送改变元宝数量
function Pin5Room.OnPushRoomDeductGold(arg)
    if arg.code == 0 then
        this.UpdatePlayerGold(arg.data)
    end
end

return this