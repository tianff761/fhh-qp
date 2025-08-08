LYCRoom = {}

local this = LYCRoom
--下注timer
local betStateTimer = nil
--结算timer
local balanceTimer = nil

function LYCRoom.Initialize()
    this.InitEvents()
end

function LYCRoom.Clear()
    this.RemoveEvents()
    if balanceTimer ~= nil then
        Scheduler.unscheduleGlobal(balanceTimer)
        balanceTimer = nil
    end
    if not IsNil(betStateTimer) then
        Scheduler.unscheduleGlobal(betStateTimer)
        betStateTimer = nil
    end

    if this.SendCardTimer ~= nil then
        this.SendCardTimer:Stop()
        this.SendCardTimer = nil
    end    
    LYCContentTip.ClearCountDown()
end

-- ==========================================================================================--
-- 事件监听
function LYCRoom.InitEvents()
    -- 断线重新连接
    AddEventListener(CMD.Game.Reauthentication, this.OnInitLoginData)
    AddEventListener(CMD.Game.OnDisconnected, this.OnGameDisconnected)

    AddEventListener(LYCAction.LYC_STC_LEAVE_ROOM, this.OnLeaveRoom)
    AddEventListener(LYCAction.LYC_STC_JOIN_ROOM, this.OnJoinRoom)
    AddEventListener(CMD.Game.BatteryState, this.OnBatteryState)
    AddEventListener(CMD.Game.Ping, this.OnPing)

    AddEventListener(LYCAction.Push_SystemTips, this.OnPushSystemTips)
    ------------------------------
    AddEventListener(LYCAction.LYC_STC_JoinRoom_Info, this.OnLYCStcRoomInfo)
    AddEventListener(LYCAction.LYC_STC_Start_State, this.OnStartGame)
    AddEventListener(LYCAction.LYC_STC_RoomState, this.OnRoomState)
    AddEventListener(LYCAction.LYC_STC_Update_Player_Info, this.OnLYCStcUpdatePlayerInfo)
    AddEventListener(LYCAction.LYC_STC_READY, this.OnStcReady)
    AddEventListener(LYCAction.LYC_STC_Send_Cards, this.OnSendCards)
    AddEventListener(LYCAction.LYC_STC_B_Operate, this.OnBOperate)
    AddEventListener(LYCAction.LYC_CTS_Owner_DISSOLVE, this.OnOwnerDissolve)
    AddEventListener(LYCAction.LYC_STC_DissolveTip, this.OnDissolveTip)
    AddEventListener(LYCAction.LYC_STC_BetPoints, this.OnBBetOrRobBanker)
    AddEventListener(LYCAction.LYC_STC_B_GameStart, this.OnGameStart)
    AddEventListener(LYCAction.LYC_STC_ROB_BANKER, this.OnRobBankerEnd)
    AddEventListener(LYCAction.LYC_STC_ROOMAUTODISS, this.OnRoomAutoDiss)
    AddEventListener(LYCAction.LYC_STC_OwnerChange, this.OnOwnerChange)
    AddEventListener(LYCAction.LYC_STC_ErrorCode, this.OnGetErrorCode)
    AddEventListener(LYCAction.LYC_STC_AWARD_OPEN, this.OnOpenAwardPool)

    AddEventListener(LYCAction.LYC_STC_NoticePlayerBomb, this.OnNoticePlayerBomb)
    AddEventListener(LYCAction.LYC_STC_NoticePlayerLao, this.OnNoticePlayerLao)
    AddEventListener(LYCAction.LYC_STC_NoticeBiPai, this.OnNoticeBiPai)
    AddEventListener(LYCAction.LYC_STC_NoticeCanOp, this.OnNoticePlayerOperate)

    --获取牌型提示返回
    AddEventListener(LYCAction.LYC_STC_GetTipCard, this.OnGetTipCard)
    AddEventListener(LYCAction.LYC_STC_B_FlipCard, this.OnGetShowCard)

    AddEventListener(LYCAction.LYC_STC_B_XiaoJie, this.OnBXiaoJie)
    AddEventListener(LYCAction.LYC_STC_B_ZongJie, this.OnBZongJie)

    AddEventListener(LYCAction.LYC_STC_OFFLINE, this.OnOffline)

    AddEventListener(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
end

-- 移除监听事件
function LYCRoom.RemoveEvents()
    -- 断线重新连接
    RemoveEventListener(CMD.Game.Reauthentication, this.OnInitLoginData)
    RemoveEventListener(CMD.Game.OnDisconnected, this.OnGameDisconnected)
    RemoveEventListener(LYCAction.LYC_STC_LEAVE_ROOM, this.OnLeaveRoom)
    RemoveEventListener(LYCAction.LYC_STC_JOIN_ROOM, this.OnJoinRoom)
    RemoveEventListener(CMD.Game.BatteryState, this.OnBatteryState)
    RemoveEventListener(CMD.Game.Ping, this.OnPing)

    RemoveEventListener(LYCAction.Push_SystemTips, this.OnPushSystemTips)
    ------------------------------
    RemoveEventListener(LYCAction.LYC_STC_JoinRoom_Info, this.OnLYCStcRoomInfo)
    RemoveEventListener(LYCAction.LYC_STC_Start_State, this.OnStartGame)
    RemoveEventListener(LYCAction.LYC_STC_RoomState, this.OnRoomState)
    RemoveEventListener(LYCAction.LYC_STC_Update_Player_Info, this.OnLYCStcUpdatePlayerInfo)
    RemoveEventListener(LYCAction.LYC_STC_READY, this.OnStcReady)
    RemoveEventListener(LYCAction.LYC_STC_Send_Cards, this.OnSendCards)
    RemoveEventListener(LYCAction.LYC_STC_B_Operate, this.OnBOperate)
    RemoveEventListener(LYCAction.LYC_CTS_Owner_DISSOLVE, this.OnOwnerDissolve)
    RemoveEventListener(LYCAction.LYC_STC_DissolveTip, this.OnDissolveTip)
    RemoveEventListener(LYCAction.LYC_STC_BetPoints, this.OnBBetOrRobBanker)
    RemoveEventListener(LYCAction.LYC_STC_B_GameStart, this.OnGameStart)
    RemoveEventListener(LYCAction.LYC_STC_ROB_BANKER, this.OnRobBankerEnd)
    RemoveEventListener(LYCAction.LYC_STC_ROOMAUTODISS, this.OnRoomAutoDiss)
    RemoveEventListener(LYCAction.LYC_STC_OwnerChange, this.OnOwnerChange)
    RemoveEventListener(LYCAction.LYC_STC_ErrorCode, this.OnGetErrorCode)
    RemoveEventListener(LYCAction.LYC_STC_AWARD_OPEN, this.OnOpenAwardPool)

    --获取牌型提示返回
    RemoveEventListener(LYCAction.LYC_STC_GetTipCard, this.OnGetTipCard)
    RemoveEventListener(LYCAction.LYC_STC_B_FlipCard, this.OnGetShowCard)

    RemoveEventListener(LYCAction.LYC_STC_B_XiaoJie, this.OnBXiaoJie)
    RemoveEventListener(LYCAction.LYC_STC_B_ZongJie, this.OnBZongJie)

    RemoveEventListener(LYCAction.LYC_STC_OFFLINE, this.OnOffline)

    RemoveEventListener(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
end

-- ==========================================================================================--
-- 重连的登录数据
function LYCRoom.OnInitLoginData()
    if not LYCRoomData.isInitRoomEnd then
        return
    end
    if not LYCRoomData.isPlayback then
        LYCRoomData.isCandSend = true
        if IsTable(ChatModule) then
            ChatModule.SetIsCanSend(true)
        end
    end

    --重置操作界面
    LYCOperationPanel.ResetOperation()
    --重置桌面
    LYCDeskPanel.ResetLYCDesk()
    --关闭要牌按钮
    LYCOperationPanel.SetOperationBtnActive(false)
    --关闭解散界面
    PanelManager.Close(LYCPanelConfig.Dismiss, true)
    --重置游戏牌局
    LYCRoomPanel.Reset()
    LYCRoomData.Reset()
    LYCOperationPanel.Reset()
    --开局重置的数据
    LYCRoomData.StartGameReset()

    this.SendNetWorkData()
end

--断线
function LYCRoom.OnGameDisconnected()
    LYCRoomData.isCandSend = false
    if IsTable(ChatModule) then
        ChatModule.SetIsCanSend(false)
    end
end

-- ==========================================================================================--
-- Init初始化完Room相关网络协议再向服务器请求以下数据，否则可能请求到的协议还未注册
function LYCRoom.SendNetWorkData()
    --进入房间
    LYCApiExtend.EnterGame(UserData.GetRoomId(), LYCRoomData.mainId, LYCRoomData.roomData.line)
end

--1014002 加入房间回复
function LYCRoom.OnJoinRoom(arg)
    local data = arg.data
    if data.code ~= 0 then
        this.ShowLYCErrorMsg(data)
        this.ExitRoom()
        return
    end
    Waiting.ForceHide()
    --重置游戏牌局
    LYCRoomPanel.Reset()
    --重置操作界面
    LYCOperationPanel.ResetOperation()
    --重置桌面
    LYCDeskPanel.ResetLYCDesk()
    --关闭要牌按钮
    LYCOperationPanel.SetOperationBtnActive(false)
    --关闭解散界面
    PanelManager.Close(LYCPanelConfig.Dismiss, true)

    LYCRoomData.isCandSend = not LYCRoomData.isPlayback
    ChatModule.SetIsCanSend(not LYCRoomData.isPlayback)
end

---加入房间旁观
function LYCRoom.OnJoinRoomWatch()

end

-- 1014004 房间信息更新
function LYCRoom.OnLYCStcRoomInfo(arg)
    local data = arg.data
    LogError(">> LYCRoom.房间信息更新", data)
    LYCRoomData.JudgeIsObserver(data.playerList)
    --解析 1014004
    this.Parse101RoomInfo(data)
    --初始化UI
    this.InitRoomUI(data)
    --初始化玩家UI
    this.InitPlayerInfosUI(data)
    LogError("LYCRoomData.IsObserver()", LYCRoomData.IsObserver())
    LYCRoomPanel.ShowSitDownBtn()
    if not LYCRoomData.IsObserver() then
        --初始化主玩家界面
        LYCRoomPanel.HideSitDownBtn()
        this.InitMainUI()
    elseif not LYCRoomData.IsFullOfSeat() then
        LYCRoomPanel.ShowSitDownBtn()
    end
end

--初始化房间UI
function LYCRoom.InitRoomUI(data)
    LYCRoomCtrl.InitRoomUI(data)
    LYCContentTip.UpdateData(data.state, 0)
end

--初始化主玩家界面
function LYCRoom.InitMainUI()
    this.CheckShowReadBtn()
end



-- 解析 +++++
function LYCRoom.Parse101RoomInfo(data)
    -- --设置房间号
    LYCRoomData.roomCode = data.roomId
    --设置游戏当前局数
    LYCRoomData.gameIndex = data.juShu
    --准入
    if IsNil(data.zhunru) then
        data.zhunru = 0
    end
    LYCRoomData.zhunru = data.zhunru
    --解析规则
    LYCFuntions.PlayWay(data)
    -- 设置房主id
    LYCRoomData.owner = data.adminId
    --设置庄
    LYCRoomData.BankerPlayerId = data.zhuangId

    LYCRoomData.isFrist = data.isFrist

    --解析玩家信息列表
    for i = 1, #data.playerList do
        this.UpdatePlayerData(data.playerList[i])
    end
    --更新聊天模块
    this.UpdateChatPlayers(LYCRoomPanel.GetAllPlayerItems())

    --游戏阶段
    LYCRoomData.gameState = data.state
    if LYCRoomData.gameState == LYCGameState.ROB_ZHUANG or LYCRoomData.gameState == LYCGameState.BETTING or 
    LYCRoomData.gameState == LYCGameState.WATCH_CARD_1 or LYCRoomData.gameState == LYCGameState.WATCH_CARD_2 or LYCRoomData.gameState == LYCGameState.COMPARE_CARD then
        LYCRoomData.isGameStarted = true
        LYCRoomData.isCardGameStarted = true
    else
        LYCRoomData.isGameStarted = false
        LYCRoomData.isCardGameStarted = false
    end
end

--  玩家信息 1014004
function LYCRoom.InitPlayerInfosUI(data)
    --更新玩家数据UI
    LYCRoomCtrl.UpdatePlayersDisplay()
    --设置庄的图标
    LYCRoomCtrl.CheckZhuang()
    --显示当前抢庄倍数
    this.CheckRobBanker()
    --显示下注分
    LYCRoomPanel.ShowXiaZhuGold()
    --隐藏卡槽
    this.HideCardSlots()
    --检查显示等待中牌子
    this.CheckSelfState()
    --设置状态
    LYCRoomCtrl.ShowUIByState()
    --更新右上角的菜单栏
    LYCRoomPanel.UpdateMenuInfo()
    --更新玩家可推注以及已推注图标
    this.UpdatePlayersTuiZhu(data.playerList)
    --显示牌--显示所有手牌
    local playerData = nil
    for i = 1, #LYCRoomData.playerDatas do
        playerData = LYCRoomData.playerDatas[i]
        if not IsNil(playerData) then
            playerData:ResetPokerData()
            playerData:CheckCards()
            playerData:ShowCardsSlot()
        end
    end
    --检测所有玩家观战中状态
    this.CheckAllPlayerLookOn()
end

--显示抢庄倍数
function LYCRoom.CheckRobBanker()
    if LYCRoomData.BankerPlayerId ~= nil and LYCRoomData.BankerPlayerId ~= 0 then
        return
    end
    local playerData
    for i = 1, #LYCRoomData.playerDatas do
        playerData = LYCRoomData.playerDatas[i]
        playerData:ShowRobZhuangNum()
    end
end

-- 1014006 通知房主是否可以开始游戏
function LYCRoom.OnStartGame(arg)
    local data = arg.data
    if data.start then
        if LYCRoomData.GetSelfData().state ~= LYCPlayerState.WAITING then
            LYCRoomPanel.ShowStartBtn(true)
        else
            LYCRoomPanel.ShowStartBtn(false)
        end
    else
        LYCRoomPanel.HideStartBtn()
    end
    LYCRoomPanel.SetStartBtnInteractable(data.start)
end


--每一局开始游戏阶段、抢庄阶段判定是否刷新所有座位号
function LYCRoom.UpdatePLayerPosition()
    if LYCRoomData.isNewPlayer then
        LYCRoomData.isNewGame = true;
        LYCRoomData.isNewPlayer = false;
        LYCRoomCtrl.UpdatePlayersDisplay()
        LYCRoomData.isNewGame = false;
    end
end

-- 1040008 通知房间变化
function LYCRoom.OnRoomState(arg)
    local data = arg.data
    LYCRoomData.gameState = data.state
    -- LogError("     通知房间变化    LYCRoomData.gameState  ", LYCRoomData.gameState, LYCRoomData.isNewPlayer, LYCRoomData.isNewGame)

    ---更新奖池文字显示
    --LYCRoomData.UpdateAwardPoolCoinNum(data.reward.awardPoolNum)
    ---更新获奖记录
    --LYCRoomData.UpdateRewardRecord(data.reward.lastReward)

    local playerData = nil
    for i = 1, #data.playerList do
        playerData = LYCRoomData.GetPlayerDataById(data.playerList[i].userId)
        if playerData ~= nil then
            playerData:UpdatePlayerStates(data.playerList[i].state)
            --刷新金豆数量
            playerData.gold = math.NewToNumber(data.playerList[i].gold)
            playerData.playerScore = math.NewToNumber(data.playerList[i].score)
            playerData.isZhaKai = data.playerList[i].bao --是否炸开
            playerData.isBiPai = data.playerList[i].bi --是否比牌

            if not IsNil(playerData.item) then
                if LYCRoomData.IsGoldGame() then
                    playerData.item:SetScoreText(playerData.gold)
                else
                    playerData.item:SetScoreText(playerData.playerScore)
                end
            end
        end
    end

    --有新玩家加入，重新刷新所有座位号位置
    if LYCRoomData.gameState == LYCGameState.WAITTING then
        --加个容错，防止新一局有玩家准备加入时，LYCRoomData.isNewPlayer为false
        if not LYCRoomData.isNewPlayer then
            for i = 1, #LYCRoomData.playerDatas do
                if LYCRoomData.playerDatas[i].state == LYCPlayerState.WAITING then
                    LYCRoomData.isNewPlayer = true;
                    break;
                end
            end
        end
        this.UpdatePLayerPosition();
    end

    --游戏发牌或者抢庄阶段时，如果服务器正在游戏中的玩家和客户端显示在游戏中的玩家数量不对等，则重新刷新所有座位号位置
    if LYCRoomData.gameState == LYCGameState.FaPai or LYCRoomData.gameState == LYCGameState.ROB_ZHUANG then
        local index = 0
        for i = 1, #LYCRoomData.playerDatas do
            if LYCRoomData.playerDatas[i].state ~= LYCPlayerState.WAITING then
                index = index + 1
            end
        end
        if index ~= #LYCRoomData.playerPosDataList then
            LYCRoomData.isNewPlayer = true;
            this.UpdatePLayerPosition();
        end
    end

    --倒计时
    LYCContentTip.UpdateData(data.state, data.countDown)

    --设置局数
    if LYCRoomData.gameIndex ~= data.juShu then
        LYCRoomData.gameIndex = data.juShu
        LYCRoomPanel.SetJuShuText(LYCRoomData.gameIndex, LYCRoomData.gameTotal)
    end

    --更新右上
    LYCRoomPanel.UpdateMenuInfo()
    --设置状态
    LYCRoomCtrl.ShowUIByState()

    --更新开局提示标签
    if data.state ~= LYCGameState.WAITTING then
        if data.state == LYCGameState.OVER then
            LYCRoomData.isGameStarted = false
            LYCRoomData.isCardGameStarted = false
        else
            LYCRoomData.isGameStarted = true
        end
        LYCRoomPanel.HideReadyBtn()
    else
        LYCRoomData.isCardGameStarted = false
    end

    LYCOperationPanel.SetOperationBtnActive(false)

    --隐藏抢庄按钮
    if LYCRoomData.gameState ~= LYCGameState.ROB_ZHUANG then
        LYCOperationPanel.HideRobZhuangReslult()
    end

    --隐藏下注按钮
    if LYCRoomData.gameState ~= LYCGameState.BETTING then
        LYCOperationPanel.HideBetState()
    end
    ----隐藏搓牌按钮
    --if LYCRoomData.gameState ~= LYCGameState.WATCH_CARD then
    --    LYCOperationPanel.HideRubCard()
    --end

    --检测是否显示准备按钮
    this.CheckShowReadBtn()
end

--1014010 更新玩家信息(玩家加入)
function LYCRoom.OnLYCStcUpdatePlayerInfo(arg)
    LogError("1014010 更新玩家信息 (玩家加入) ", arg)
    local data = arg.data
    --1为加入 2为退出
    if data.type == 1 then
        if data.seatNum > 0 then
            local playerData = this.UpdatePlayerData(data)
            --更新座位
            if LYCRoomData.IsObserver() and data.userId == UserData.userId then
                LYCRoomData.JudgeSitDownPlayer(data)
                if not LYCRoomData.IsObserver() then
                    LYCRoomData.isNewPlayer = true;
                    LYCRoomPanel.HideSitDownBtn()
                    -- LYCRoomPanel.HideWatchShow()
                end
            else
                -- LYCRoomCtrl.RefreshChangeList()
                -- LYCRoomCtrl.UpdatePlayerUI(playerData)
                LYCRoomCtrl.RefreshChangeList();
                if LYCRoomData.IsGameStarted() then
                    LYCRoomCtrl.UpdatePlayerUI(playerData)
                else
                    for i = 1, #LYCRoomData.playerDatas do
                        if not LYCFuntions.IsNilOrZero(LYCRoomData.playerDatas[i].seatNumber) then
                            LYCRoomCtrl.UpdatePlayerUI(LYCRoomData.playerDatas[i])
                        end
                    end
                end
            end
        end
    elseif data.type == 2 then
        if data.seatNum > 0 then
            LYCRoomCtrl.RemovePlayerUI(data.userId)
            LYCRoomData.RemovePlayer(data.userId)
        end
    end

    --更新聊天模块
    LYCRoom.UpdateChatPlayers(LYCRoomPanel.GetAllPlayerItems())
end

-- 1040012 发牌
function LYCRoom.OnSendCards(arg)
    local data = arg.data
    --隐藏下注分
    this.HideBetStateScore()
    --发牌
    this.OnNormalSend(data)
end

-- 1014014 操作广播
function LYCRoom.OnBOperate(arg)
    local data = arg.data
    --1:抢庄 2:下注
    if data.operType == 1 then
        this.OnRobBanker(data)
    elseif data.operType == 2 then
        this.OnBetScore(data)
    end
end

--1014018 小结算
function LYCRoom.OnBXiaoJie(arg)
    local data = arg.data
    --是否第一
    LYCRoomData.isFrist = false
    --表示有结算
    LYCRoomData.isHaveJieSuan = true
    --游戏设为未进行中
    LYCRoomData.isCardGameStarted = false
    --更新玩家数据
    this.UpdateXiaoJieSuanData(data.playerList)
    --检测所有玩家观战中状态
    this.CheckAllPlayerLookOn()
    --表示当前局已经结束
    Scheduler.unscheduleGlobal(balanceTimer)
    balanceTimer = nil

    balanceTimer = Scheduler.scheduleOnceGlobal(function()
        --处理结算信息
        this.SetBalanceInfo(data)
        --比牌
        this.CompareCard(data.isBankerPassKill)
    end, 0.5)

    --如果自己是中途加入并且已经坐下则关闭观看中，等待中图标
    if not LYCRoomData.GetSelfIsNoReady() then
        LYCRoomPanel.HideWatchShow()
    end

    --隐藏操作要牌
    LYCOperationPanel.SetOperationBtnActive(false)

    LYCRoomPanel.UpdateMenuInfo()

    --隐藏自动翻牌开关
    LYCRoomPanel.HideAutoFlip()
end

--房主解散房间回复
function LYCRoom.OnOwnerDissolve(arg)
    local data = arg.data
    if data.code == 0 then
        Toast.Show("解散房间成功")
        this.ExitRoom()
    else
        Toast.Show("解散房间失败")
    end
end


--隐藏所有卡槽
function LYCRoom.HideCardSlots()
    --默认隐藏卡槽
    for i = 1, #LYCRoomData.playerDatas do
        LYCRoomData.playerDatas[i]:HideCardsSlot()
    end
end

--检查自己的状态
function LYCRoom.CheckSelfState()
    local selfData = LYCRoomData.GetSelfData()
    --中途加入显示准备与观看  游戏已经开始
    if LYCRoomData.IsObserver() then
        LYCRoomPanel.ShowWatch()
    else
        if not IsNil(selfData) and LYCRoomData.IsGameStarted() then
            local selfState = selfData.state
            if selfState == LYCPlayerState.WAITING or selfState == LYCPlayerState.NO_READY then
                LYCRoomPanel.ShowWatch()
            elseif selfState == LYCPlayerState.WAIT or selfState == LYCPlayerState.OPTION then
                LYCRoomPanel.HideWatchShow()
            elseif selfState == LYCPlayerState.WAITING_START or selfState == LYCPlayerState.READY then
                LYCRoomPanel.ShowWait()
            else
                LYCRoomPanel.HideWatchShow()
            end
        else
            LYCRoomPanel.HideWatchShow()
        end
    end
end

--设置一个玩家的信息
function LYCRoom.UpdatePlayerData(data)
    local playerData = LYCRoomData.GetPlayerDataById(data.userId)
    LogError("<color=aqua>playerData</color>", data)
    if playerData == nil then
        playerData = LYCPlayer:New()
        table.insert(LYCRoomData.playerDatas, playerData)
    end
    playerData:SetPlayerData(data)
    playerData.handCards = data.midCard
    playerData.xiaZhuScore = data.betNum
    playerData.robZhuangState = data.robNum
    playerData.gold = data.gold
    playerData.isPushBet = data.isPushBet --抢庄后是否还可以推注
    return playerData
end

function LYCRoom.ShowLYCErrorMsg(data)
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
        return false
    end
    return true
end

-- 1014025 准备返回某个玩家坐下
function LYCRoom.OnStcReady(arg)
    local data = arg.data
    if not this.ShowLYCErrorMsg(data) then
        return
    end
    this.UpdateReadState(LYCRoomData.mainId)
    local selfData = LYCRoomData.GetSelfData()

    if selfData then
        LYCRoomPanel.HideReadyBtn()

        --判断是否显示等待中
        if LYCRoomData.IsGameStarted() and selfData.state == LYCPlayerState.WAITING then
            LYCRoomPanel.ShowWait()
        end
        LYCRoomCtrl.ShowUIByState()
        LYCRoomPanel.UpdateMenuInfo()

        if not IsNil(selfData.item) then
            for i = 1, #LYCRoomData.playerDatas do
                LYCRoomData.playerDatas[i].item:ResetPlayerUI()
            end
        end
    else
        LYCRoomPanel.ShowWait()
    end

    --检查显示等待中牌子
    this.CheckSelfState()
end

function LYCRoom.UpdateReadState(playerId)
    --更新数据
    local playerData = LYCRoomData.GetPlayerDataById(playerId)
    -- 准备
    if playerData and not IsNil(playerData.item) then
        playerData.item:SetIsPlayReadyAni()
        local bool = playerData.state == LYCPlayerState.READY or playerData.state == LYCPlayerState.WAITING_START
        playerData.item:UpdatellReadyImge(bool, true)
    end
end

-- 1014032 游戏开始游戏开始
function LYCRoom.OnGameStart(arg)
    local data = arg.data

    --隐藏开始按钮
    LYCRoomPanel.HideStartBtn()

    if not LYCRoomData.IsGoldGame() then
        --更新局数
        LYCRoomPanel.SetJuShuText(LYCRoomData.gameIndex, LYCRoomData.gameTotal)
    end

    --整局游戏开始
    LYCRoomData.isGameStarted = true
    --游戏开始
    LYCRoomData.isCardGameStarted = true
    --隐藏所有玩家准备图标
    LYCRoomPanel.HideAllReadyImge()
    -- 更新菜单信息
    LYCRoomPanel.UpdateMenuInfo()
    --播放开始音效
    --LYCResourcesMgr.PlayGameSound(LYCGameEffSoundType.EFFSTART)
    --停止播放结算动画
    Scheduler.unscheduleGlobal(balanceTimer)
    balanceTimer = nil
    --结算取消
    LYCRoomData.isHaveJieSuan = false
    --重置庄家id
    LYCRoomData.BankerPlayerId = nil
    --重置操作面板界面
    LYCOperationPanel.Reset()

    --游戏开始后重置观战玩家的桌面界面
    if LYCRoomData.GetSelfIsNoReady() then
        LYCRoomPanel.ShowWatch()
    else
        LYCRoomPanel.HideWatchShow()
    end

    this.XiaoJieReset()
    --检测所有玩家观战中状态
    this.CheckAllPlayerLookOn()

    --开局后不显示准备按钮
    LYCRoomPanel.HideReadyBtn()

    --显示推注信息
    this.UpdatePlayersTuiZhu(data.playerList)

    --判断是否显示自动翻牌按钮
    if not LYCRoomData.GetSelfIsNoReady() then
        --显示自动翻牌开关
        LYCRoomPanel.ShowAutoFlip()
    end
end

-- 更新推注状态
function LYCRoom.UpdatePlayersTuiZhu(playerList)
    local playerId
    local playerData
    for i = 1, #playerList do
        playerId = playerList[i].userId
        playerData = LYCRoomData.GetPlayerDataById(playerId)
        --新加判断，所有玩家在坐下旁观时不显示
        if not IsNil(playerData) and playerData.state ~= LYCPlayerState.WAITING then
            playerData.pushBet = playerList[i].pushBet
            playerData.isPushBet = playerList[i].isPushBet
            if LYCRoomData.IsGameStarted() then
                playerData:UpdataTuiZhuState()
            else
                playerData:UpdataTuiZhuState(false, false)
            end
        end
    end
end

function LYCRoom.XiaoJieReset()
    --开局重置的数据
    LYCRoomData.StartGameReset()
    --重置游戏牌局
    LYCRoomPanel.Reset()
    LYCDeskPanel.ResetLYCDesk()
end

--==============================--
--desc: 普通发牌
--time:2018-12-20 10:51:52
--@lycDeskCtrl: 桌面的Ctrl组件
--@data: 循环列表，data.list 包含uId以及牌点数
--@return
--==============================--
function LYCRoom.OnNormalSend(data)
    local isFirst = data.first
    local firstCards = {}
    for i = 1, #data.playerList do

        LogError("普通发牌   玩家数据  ", data.playerList[i])

        local playerList = data.playerList[i]
        local playerData = LYCRoomData.GetPlayerDataById(playerList.playerId)
        local cards = playerList.nowCard
        local allCards = playerList.midCard
        local cardLen = #allCards
        local cardsTab = {}
        for i = 1, cardLen do
            --首次给玩家发两张牌的时候，index固定为1,2
            if isFirst == 1 then
                table.insert(cardsTab, { card = cards[i], index = i })
            else
                table.insert(cardsTab, { card = cards[i], index = #playerData.handCards + i })
            end
            if i == cardLen then
                if cardLen == 3 then
                    cardsTab[i].card = "-1"
                end
            end
            if isFirst == 1 and #playerData.handCards + i == 4 then
                LogError(" 4张牌 ------ 数据出错  ",cardsTab, playerData.handCards)
            end
        end

        playerData.handCards = {}
        for i = 1, #allCards do
            table.insert(playerData.handCards, allCards[i])
            if i == 3 then
                playerData.fiveCard = allCards[i]
                playerData.handCards[i] = "-1"
            end
        end

        LogError("isFirst  是否发给玩家一张牌 ", isFirst == 1, cardsTab, cards)
        if isFirst == 1 then
            -- LYCDeskPanel.SendCards(playerData, cardsTab)
            if #cardsTab > 0 then
                firstCards[playerData.id] = {playerData = playerData, cardsTab = cardsTab}
            end
            -- table.insert(firstCards, {playerData = playerData, cardsTab = cardsTab})
        elseif playerList.playerId == UserData.userId then
            if cards ~= nil and #cards > 0 then
                playerData.item:PlayFlopAllAni(cards)
                playerData:ShowCardsSlot()
            end
        end
    end

    
    if isFirst == 1 then
        this.InitSendCards(firstCards)
    end
end

--设置发牌顺序
function LYCRoom.InitSendCards(firstCards)
    local BankerList = {}
    local list_1 = {}
    local isBanker = false
    for i = 1, #LYCRoomData.playerPosDataList do
        local id = LYCRoomData.playerPosDataList[i].playData.id

        if not isBanker then
            isBanker = id == LYCRoomData.BankerPlayerId;
        end
        if firstCards[id] ~= nil then
            if isBanker then
                table.insert(BankerList, firstCards[id])
            else
                table.insert(list_1, firstCards[id])
            end
        end
    end

    for i = 1, #list_1 do
        table.insert(BankerList, list_1[i])
    end   
    this.SetSendCards(BankerList, 1)
end


--设置发牌顺序
function LYCRoom.SetSendCards(BankerList, index)
    if index <= #BankerList then
        local data = BankerList[index]
        if index == 1 then

            -- LogError(" 设置发牌顺序   ", index, data)
            LYCDeskPanel.SendCards(data.playerData, data.cardsTab)
            data.playerData:ShowCardsSlot()
            this.SetSendCards(BankerList, index + 1)

        else
            --延时0.5秒显示
            if this.SendCardTimer == nil then
                this.SendCardTimer = Timing.New(
                    function ()
                        this.SendCardTimer:Stop()
                        this.SendCardTimer = nil
                        -- LogError(" 设置发牌顺序   ", index, data)
                        LYCDeskPanel.SendCards(data.playerData, data.cardsTab)
                        data.playerData:ShowCardsSlot()
                        this.SetSendCards(BankerList, index + 1)
                    end
                , 0.3)
            end
            this.SendCardTimer:Start()
        end
    end
end




-- 通知抢庄
function LYCRoom.OnInfromRobBanker(data)
    if LYCRoomData.isGameStarted and LYCRoomData.GetSelfIsNoReady() then
        LYCRoomPanel.ShowWatch()
        return
    end

    LYCRoomPanel.HideWatchShow()

    --LogError("抢庄score", data.score)
    --local value = tonumber(data.score)
    --LogError("抢庄value", value)
    --显示抢庄按钮
    LYCOperationPanel.ShowRobZhuangReslult(data.score)
    --播放抢庄通知
    --LYCResourcesMgr.PlayGameSound(LYCGameEffSoundType.EFFCALLROB)
end

-- 抢庄信息
function LYCRoom.OnRobBanker(data)
    if data.playerId == LYCRoomData.mainId then
        --关闭抢庄界面
        LYCOperationPanel.HideRobZhuangReslult()
    end

    local playerData = LYCRoomData.GetPlayerDataById(data.playerId)
    playerData.robZhuangState = data.robNum
    --显示抢几
    playerData:ShowRobZhuangNum()
end

-- 1014034 抢庄完成
function LYCRoom.OnRobBankerEnd(arg)
    local data = arg.data
    LYCRoomData.BankerPlayerId = data.zhuangId
    local bankerData = LYCRoomData.GetPlayerDataById(LYCRoomData.BankerPlayerId)

    if data.maxRob == 0 then
        bankerData.robZhuangState = 1
    else
        bankerData.robZhuangState = data.maxRob
    end

    --隐藏所有未参与抢庄的玩家信息
    local tempPlayerData = nil
    for i = 1, #LYCRoomData.playerDatas do
        tempPlayerData = LYCRoomData.playerDatas[i]
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
    --关闭抢庄抢几
    this.CloseRobZhuangNum()
end

--1040038 房间自动解散
function LYCRoom.OnRoomAutoDiss(arg)
    local data = arg.data
    LYCRoomData.isGameOver = true
    LYCRoomData.isGameStarted = false
    --收到总结算 隐藏准备按钮
    LYCRoomPanel.HideReadyBtn()
    --收到总结算，处理提示语
    LYCContentTip.HandleZongJieSuan()
    if LYCRoomData.IsGoldGame() and LYCRoomData.IsFangKaFlow() then
        this.OpenJieSuanPanelLater()
    end
end

function LYCRoom.OnOwnerChange(arg)
    LogError("<color=aqua>OnOwnerChange</color>", arg)
    LYCRoomData.owner = arg.data.adminId
    local isOwner = LYCRoomData.MainIsOwner()
    if not LYCRoomData.isObserver then
        LYCRoomPanel.ShowStartBtn(isOwner)
    end
end

function LYCRoom.OnGetErrorCode(arg)
    local code = arg.data.code
    if code == 114 then
        Toast.Show("准备人数不足")
    end
end

---收到玩家奖池开奖
function LYCRoom.OnOpenAwardPool(arg)
    LogError("开奖", arg.data.award)
    LYCRoomPanel.ShowCoinEffect(arg.data.award)
end

---@field playerID number 选择炸开的玩家id
function LYCRoom.OnNoticePlayerBomb(arg)
    local data = arg.data
    local playerID = data.playerId
    local playerData = LYCRoomData.GetPlayerDataById(playerID)
    playerData.isZhaKai = true
    playerData.item:SetPlayerBombImgTagActive(true)
    LYCResourcesMgr.PlayLYCGameSound("zhakai")
    LYCRoomPanel.PlayBombEffect(playerID)
    if data.pai ~= nil and #data.pai > 0 then
        playerData.item:PlayFlopAllAni(data.pai)
        playerData:ShowCardsSlot()
    end
end

---@field playerId number 选择捞派玩家id
---@field lao boolean 表示玩家是否捞true/false
---@field pai number 如果捞派 捞的那张牌
function LYCRoom.OnNoticePlayerLao(arg)
    local data = arg.data
    local playerID = data.playerId
    local isLao = data.lao
    local LaoCard = data.pai
    local playerData = LYCRoomData.GetPlayerDataById(playerID)
    playerData.isLao = isLao
    playerData.item:SetPlayerLaoImgTagActive(isLao)
    if isLao then
        LYCRoomPanel.PlayLaoEffect(playerData, LaoCard)
    else
        LYCResourcesMgr.PlayLYCGameSound("bulao")
    end
    playerData.item:SetPlayerDoNotLaoImgTagActive(not isLao)
end

---@field playerId number 庄家比牌对象
---@field win number 1表示赢 0表示平 -1 表示输 (庄家输赢 闲家取反值)
---@field pai table 牌数据
function LYCRoom.OnNoticeBiPai(arg)
    local data = arg.data
    local playerID = data.palyerId
    local resultNum = -data.win
    local playerData = LYCRoomData.GetPlayerDataById(playerID)
    if playerID ~= UserData.userId then
        playerData.item:PlayFlopAllAni(data.pai)
    end
    playerData.item:SetPlayerLYCBiPaiResult(true, resultNum)
end

---@field NONE number = 0,
---@field LAO number = 1, --捞牌
---@field BI number =  2, --比牌
---@field BAO number = 3, --爆牌
function LYCRoom.OnNoticePlayerOperate(arg)
    local data = arg.data
    LogError("<color=aqua>OnNoticePlayerOperate data</color>")

    local isLao = false; --是否在捞牌阶段
    local isShowBiPai = false; --是否显示比牌
    for i = 1, #data.ops do
        if data.ops[i] == LYCOperateDefine.LaoPai then
            isLao = true
            if data.point <= 6 and data.point >= 3  then
                isShowBiPai = true;
            end
            break;
        end
    end

    for i = 1, #data.ops do
        local opIndex = data.ops[i]
        LogError("data.ops[i]", data.ops[i])
        if opIndex == LYCOperateDefine.LaoPai then
            -- LYCOperationPanel.SetLaoPaiBtnActive(true)
            if data.point ~= nil then
                --点数为8,9自动炸开
                if data.point == 8 or data.point == 9 then
                    -- LYCOperationPanel.SetBombButtonActive(true)
                elseif data.point <= 7 then
                    --点数为7只有不捞
                    if data.point == 7 then
                        LYCOperationPanel.SetLaoPaiBtnActiveShow(false, true)
                    --点数为0,1,2只有捞牌
                    elseif data.point == 0 or data.point == 1 or data.point == 2 then
                        LYCOperationPanel.SetLaoPaiBtnActiveShow(true, false)
                    else
                        LYCOperationPanel.SetLaoPaiBtnActiveShow(true, true)
                    end
                end
            end
        elseif opIndex == LYCOperateDefine.BiPai then
            --庄家捞牌、不捞同时显示时，且在比牌阶段，显示比牌按钮
            if isLao then
                LYCRoomPanel.SetAllPlayerItemsIsPlayLaoEffect(false)
            end
            --庄家只有在捞牌、不捞同时显示时，才会显示比牌按钮
            --庄家捞牌操作之后的最终比牌阶段，隐藏所有比牌按钮，
            LYCRoomPanel.SetAllPlayerItemsBiPaiBtnActive(isLao and isShowBiPai)
        elseif opIndex == LYCOperateDefine.ZhaKai then
            LYCOperationPanel.SetBombButtonActive(true)
        end
    end
end

--获取提示返回
function LYCRoom.OnGetTipCard(arg)
    local data = arg.data
    --this.OnTipOrShowCard(data, LYCRoomData.mainId, LYCOperationCardType.TipCard)
end

--广播亮牌
function LYCRoom.OnGetShowCard(arg)
    local data = arg.data
    --this.OnTipOrShowCard(data, data.playerId, LYCOperationCardType.ShowCard)
end

--亮牌或者提示牌
function LYCRoom.OnTipOrShowCard(data, playerId, state)
    local playerData = LYCRoomData.GetPlayerDataById(playerId)
    local playerItem = playerData.item
    data.point = tostring(data.point)
    playerData.handCards = data.lycCard

    --LYCResourcesMgr.PlayCardPointSound(playerData.id, data.point)
    if state == LYCOperationCardType.ShowCard then
        playerData.fiveCard = data.lastCard[1]
        if data.playerId == LYCRoomData.mainId then
            --LYCOperationPanel.SetOperationBtnActive(false)
            this.CheckIsShrink(playerItem, data.lycCard, data.point)
        end
    elseif state == LYCOperationCardType.TipCard then
        this.CheckIsShrink(playerItem, data.lycCard, data.point)
    end

    playerData:CheckCards()

    if state == LYCOperationCardType.ShowCard then
        --playerItem:UpFiveCard(true)
    end

    --播放结果音效
    playerData.cardType = data.point
    playerItem:JudgeCardTypeAniPlayHandler(LYCCardType[LYCRoomData.fanBeiRuleValue][data.point], data.point, false)
    if data.point ~= 0 then
        playerItem:PlayResultEffect(data.point)
    end
end

function LYCRoom.CheckIsShrink(playerItem, cards, type)
    type = tonumber(type)
    if type == 0 then
        --不缩进
    elseif type > 10 then
        --缩进
        playerItem:SetShrinkCards()
    else
        --if this.CheckTopThreeIsNiu(cards) then
        --    playerItem:SetThreeBinaryCards()
        --else
        playerItem:SetShrinkCards()
        --end
    end
end

--检测前三张加起来是否是10
function LYCRoom.CheckTopThreeIsNiu(cards)
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

--- = ================================================================
--比牌
function LYCRoom.CompareCard(isBankerPassKill)
    --比牌
    LYCOperationPanel.ShowCompareCard(function()
        if LYCRoomData.gameState == LYCGameState.CALCULATE then
            Log(">>>>>>>>>>>>>>>>>>>>>>>>>         比牌结束")
            ---禁用庄家通杀
            --if isBankerPassKill then
            --    LYCOperationPanel.ShowTongSha()
            --    --播放结果音效
            --    LYCResourcesMgr.PlayGameSound(LYCGameEffSoundType.EFFALLKILL)
            --end
        end
    end)
end

--更新小结算数据
function LYCRoom.UpdateXiaoJieSuanData(playerList)
    for i = 1, #playerList do
        local playerInfo = playerList[i]
        local playerId = playerInfo.playerId
        local playerData = LYCRoomData.GetPlayerDataById(playerId)
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

-- 小结算
function LYCRoom.SetBalanceInfo(data)
    --保存战局结果
    --LogError("SetBalanceInfo", data)
    local losers = {}
    local winners = {}
    local bankerIsWin = false

    -- 显示手牌
    for i = 1, #data.playerList do
        local playerInfo = data.playerList[i]
        local playerId = playerInfo.playerId
        local playerData = LYCRoomData.GetPlayerDataById(playerId)
        --LogError("playerData", playerData)
        if not IsNil(playerData) then
            local playerItem = playerData.item

            playerData.handCards = playerInfo.lycCard

            playerData:PlayFlopAllAni()

            if playerData.BankerPlayerId ~= playerId then
                local score = tonumber(playerInfo.currScore)
                local resultNum = score > 0 and 1 or (score < 0 and -1 or 0)
                playerItem:SetPlayerLYCBiPaiResult(true, resultNum)
            end
            --playerData.fiveCard = playerInfo.lastCard[1]

            --显示结算的牌
            if playerId == LYCRoomData.mainId then
                this.CheckIsShrink(playerItem, playerInfo.lycCard, playerInfo.point)
            end

            --playerItem:UpFiveCard(false)

            --显示点数 point
            local cardTypes = LYCCardType[1]--LYCCardType[tonumber(LYCRoomData.fanBeiRuleValue)]
            --LogError(string.format("牌型点数 牛%s %s倍", playerInfo.point, LYCRoomData.fanBeiRuleValue))
            local point = tostring(playerInfo.point)
            local multiply = LYCCardTypeMultiply[playerInfo.multi]
            local special = playerInfo.special
            playerItem:JudgeCardTypeAniPlayHandler(cardTypes[point], point, multiply, true, special)

            --根据输赢保存玩家
            if playerId ~= LYCRoomData.BankerPlayerId then
                if math.NewToNumber(playerInfo.currScore) < 0 then
                    table.insert(losers, playerId)
                else
                    table.insert(winners, playerId)
                end
            else
                if math.NewToNumber(playerInfo.currScore) > 0 then
                    bankerIsWin = true
                end
            end

            if not IsNil(playerItem) then
                --更新结算玩家Score
                playerItem:SetScoreText(playerData.score)
                --播放数赢分数动画
                playerItem:SetPayChangeScore(playerInfo.currScore)
            end
        end
    end

    --播放结算动画
    this.PlayBalanceAnim(data, bankerIsWin, winners, losers)
end

--播放结算动画
function LYCRoom.PlayBalanceAnim(data, bankerIsWin, winners, losers)
    --当庄赢得时候 判断是否赢得玩家只有庄 否则，没有庄家通杀
    if bankerIsWin then
        data.isBankerPassKill = this.IsBankerPassKill(winners)
    else
        data.isBankerPassKill = false
    end

    --飞金币
    local bankerItem = LYCRoomData.GetPlayerUIById(LYCRoomData.BankerPlayerId)
    if bankerItem ~= nil then
        --if bankerIsWin then
        --    bankerItem:PlayWinAni()
        --end
        --coroutine.start(this.PlayCoinAnim, bankerItem, winners, losers)
    end

    --自己在战绩中表示非中途加入 兼容使用（防止出现枪几出现）
    if LYCRoomData.GetSelfData().state ~= LYCPlayerState.WAITING then
        --关闭抢庄抢几
        this.CloseRobZhuangNum()
    end

    --处理小结算提示语
    LYCContentTip.HandleXiaoJieSuan()
end

function LYCRoom.PlayCoinAnim(bankerItem, winners, losers)
    coroutine.wait(1)
    LYCRoomAnimator.SettlementAnim(bankerItem.faceGO.transform, winners, losers, function()
        --播放结算动画结束，自己也进入未准备状态
        LYCContentTip.HandleSelfNoReady()
    end)
end

--是否是庄家通杀
function LYCRoom.IsBankerPassKill(winners)
    if #winners == 0 then
        return true
    end
    return false
end

--检测所有玩家观战中
function LYCRoom.CheckAllPlayerLookOn()
    for i, playerData in ipairs(LYCRoomData.playerDatas) do
        local playerItem = playerData.item
        if not IsNil(playerItem) then
            --显示观战中
            if LYCRoomData.isCardGameStarted and playerData.state == LYCPlayerState.WAITING then
                playerItem:SetLookOnImageActive(true)
            else
                playerItem:SetLookOnImageActive(false)
            end
        end
    end
end
---------------------------------------------------------------
-- 1040020 总结算
function LYCRoom.OnBZongJie(arg)
    LYCRoomData.isGameOver = true
    local data = arg.data
    LYCRoomData.Note = data.note
    LYCRoomData.isGameStarted = false

    --收到总结算 隐藏准备按钮
    LYCRoomPanel.HideReadyBtn()
    --收到总结算，处理提示语
    LYCContentTip.HandleZongJieSuan()

    local summarizeData = {}
    for i = 1, #data.playerList do
        local list = data.playerList[i]
        local playerData = LYCRoomData.GetPlayerDataById(list.playerId)

        local tab = {}
        tab.bankerCount = list.zhuangCount
        tab.robBankerCount = list.robZhuangCount
        tab.bolusCount = list.pushBetCount
        tab.playerId = list.playerId
        tab.score = tonumber(list.score)
        tab.name = playerData.name
        tab.headUrl = playerData.playerHead
        tab.uId = playerData.id
        table.insert(summarizeData, tab)
    end

    summarizeData.endTime = data.endTime
    summarizeData.roomCode = LYCRoomData.roomCode
    summarizeData.difen = LYCRoomData.diFen
    summarizeData.model = LYCRoomData.model
    summarizeData.jushu = LYCRoomData.gameTotal .. "局"
    summarizeData.owner = LYCRoomData.owner

    LYCRoomData.netJieSuanData = summarizeData
    this.OpenJieSuanPanelLater()
end

function LYCRoom.OpenJieSuanPanelLater()
    Scheduler.scheduleOnceGlobal(function()
        if PanelManager.IsOpened(LYCPanelConfig.Room) and not PanelManager.IsOpened(LYCPanelConfig.JieSuan) then
            PanelManager.Open(LYCPanelConfig.JieSuan)
        end
    end, 3)
end

--  1014026 操作同意与拒绝解散房间
function LYCRoom.OnDissolveTip(arg)
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
        PanelManager.Open(LYCPanelConfig.Dismiss, data)
    elseif endState == 1 then
        this.OnDismissRoomSucceed()
    else
        this.OnDismissRoomFailure(playerId)
    end
end

--  解散房间结果成功
function LYCRoom.OnDismissRoomSucceed()
    PanelManager.Close(LYCPanelConfig.Dismiss, true)
    if LYCRoomData.MainIsOwner() then
        Toast.Show("解散成功")
    else
        Toast.Show("游戏已解散")
    end
    -- this.ExitRoom()
end

--  解散房间结果失败
function LYCRoom.OnDismissRoomFailure(playerId)
    PanelManager.Close(LYCPanelConfig.Dismiss, true)
    if playerId ~= LYCRoomData.mainId then
        local playerName = LYCRoomData.GetPlayerDataById(playerId).name
        Toast.Show(playerName .. "拒绝了解散房间")
    end
end

-- 1040036 离开房间
function LYCRoom.OnLeaveRoom(arg)
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
            --LYCRoomData.isGameOver为true，则代表游戏结算，走结算面板，不直接退出房间
            --LYCRoomData.isGameOver为false，则代表游戏暂未开始，不显示结算面板，直接退出房间
            if not LYCRoomData.isGameOver then
                this.ExitRoom()
            end
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
function LYCRoom.OnBBetOrRobBanker(arg)
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
function LYCRoom.OnInformBetScore(data)
    LogError("<color=aqua>data</color>", data)
    local scores = {}
    --pushBet 不应该为true，屏蔽代码
    if data.pushBet then
        for i = 1, #data.score do
            data.tz = {}
            -- if i == #data.score then
            --     data.tz = { data.score[i] }
            -- else
            --     table.insert(scores, data.score[i])
            -- end
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
        flag = data.flag
    }
    --庄家是自己，或者自己没有坐下，表示在观战。不做处理
    if LYCRoomData.MainIsBanker() or LYCRoomData.GetSelfIsNoReady() then
        return
    end

    local time = 1
    if not LYCFuntions.isRobBanker() then
        time = 0
    end

    if not IsNil(betStateTimer) then
        Scheduler.unscheduleGlobal(betStateTimer)
        betStateTimer = nil
    end

    betStateTimer = Scheduler.scheduleOnceGlobal(HandlerArgs(this.BetStateShow, tempData), time)
end

--下注显示
function LYCRoom.BetStateShow(data)
    if LYCRoomData.gameState == LYCGameState.BETTING then
        if LYCRoomData.MainIsBanker() then
            this.HideBetStateScore()
        else
            local xiaZhuStr = data.difen
            local zuiZhuStr = data.tuizhu
            local restrictScore = data.limitXiaZhuScore
            local flag = data.flag
            LYCOperationPanel.ShowBetState(xiaZhuStr, zuiZhuStr, restrictScore, flag)
        end
        --播放下注通知
        --LYCResourcesMgr.PlayGameSound(LYCGameEffSoundType.EFFCallBET)
    else
        LYCOperationPanel.HideBetState()
    end
end

function LYCRoom.HideBetStateScore()
    if not IsNil(betStateTimer) then
        Scheduler.unscheduleGlobal(betStateTimer)
        betStateTimer = nil
    end
    LYCOperationPanel.HideBetState()
end

-- 返回下注
function LYCRoom.OnBetScore(data)
    local playerData = LYCRoomData.GetPlayerDataById(data.playerId)
    local playerItem = playerData.item

    if data.playerId == LYCRoomData.mainId then
        this.HideBetStateScore()
    end

    if not IsNil(playerData) and not IsNil(playerItem) then
        playerData.xiaZhuScore = data.betNum
        playerData:UpdataTuiZhuState(false)
        playerData:FlyGold(function()
            playerItem:ShowBetPoints(playerData.xiaZhuScore)
        end)
        --关闭可推注显示 并且检测是否已推注
    else
        LogError("玩家playerData为nil")
    end
end

--更新玩家的金豆
--type(1支付桌费2游戏盈亏3付费表情)
function LYCRoom.UpdatePlayerGold(data)
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
        local playerData = LYCRoomData.GetPlayerDataById(temp.id)
        if temp.gold ~= nil then
            if LYCRoomData.IsGoldGame() then
                playerData.playerScore = temp.gold
                if not IsNil(playerData.item) then
                    playerData.item:SetScoreText(playerData.playerScore)
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
function LYCRoom.OnBatteryState(value)
    LYCRoomPanel.UpdateEnergyValue(value)
end

local lastPing = 0
--ping值
function LYCRoom.OnPing(arg)
    if lastPing == arg then
        return
    end
    lastPing = arg
    if arg ~= "" and not IsNil(LYCRoomPanel) then
        LYCRoomPanel.UpdateNetPing(arg)
    end
end

------------------------------------------------------------------
--开始显示庄家图标，，动画
function LYCRoom.CheckRobZhuang(RobPlayerInfos)
    Log(">>>>>>>>>>>>>>>>   RobPlayerInfos = ", RobPlayerInfos)
    if LYCRoomData.BankerPlayerId == "" then
        return
    end

    Log(">>>>>>>>>>>>>>>>   LYCRoomData.isPlayRubZhuangAni = ", LYCRoomData.isPlayRubZhuangAni)
    if not LYCRoomData.isPlayback and not LYCRoomData.isPlayRubZhuangAni and LYCFuntions.isRobBanker() then
        LYCRoomData.isPlayRubZhuangAni = true
        LYCRoomAnimator.PlayRobZhuangAni(RobPlayerInfos, LYCRoomPanel.SetBankerAniActive)
    else
        --显示庄家图标
        LYCRoomPanel.ShowZhuangImage()
        local playerData = LYCRoomData.GetPlayerDataById(LYCRoomData.BankerPlayerId)
        if playerData ~= nil then
            --显示抢庄倍数
            playerData:ShowRobZhuangMultiple()
        end
    end
end

--关闭抢庄抢几
function LYCRoom.CloseRobZhuangNum()
    for _, playerData in ipairs(LYCRoomData.playerDatas) do
        playerData:HideRobZhuangNum()
    end
end

--播放语音显示聊天气泡框
function LYCRoom.OnShowChatBubble(formId, duration, text)
    local playerItem = LYCRoomData.GetPlayerUIById(formId)
    if playerItem ~= nil then
        playerItem:ShowChatText(duration, text)
    end
end
------------------------------------------------------------------
--
--初始化聊天系统
function LYCRoom.InitChatManager()
    --初始化聊天模块
    ChatModule.Init()
    --当前游戏参数
    ChatModule.SetChatCallback(this.OnShowChatBubble)
    local config = {
        audioBundle = LYCBundleName.chat,
        textChatConfig = LYCChatLabelArr,
        languageType = LanguageType.putonghua,
    }
    ChatModule.SetChatConfig(config)
end

--聊天模块
--玩家数据更新
function LYCRoom.UpdateChatPlayers(playerItems)
    local players = {}
    for k, v in pairs(playerItems) do
        if IsTable(v) and not string.IsNullOrEmpty(v.playerId) and v.playerId ~= 0 then
            local playerData = LYCRoomData.GetPlayerDataById(v.playerId)
            players[v.playerId] = {}
            players[v.playerId].emotionNode = v.faceGO.transform
            players[v.playerId].animNode = v.faceGO.transform
            players[v.playerId].gender = playerData.sex
            players[v.playerId].name = playerData.name
        end
    end
    ChatModule.SetPlayerInfos(players)
end
-------------------------------
--系统级
function LYCRoom.OnPushSystemTips(data)
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
function LYCRoom.ExitRoom()
    -- if LYCRoomData.isPlayback then
    --     LYCPlaybackMgr.Clear()
    -- end
    LYCRoomCtrl.ExitRoom()
end

--检测显示准备按钮
function LYCRoom.CheckShowReadBtn()
    if LYCRoomData.gameState == LYCGameState.WAITTING then
        local selfData = LYCRoomData.GetSelfData()
        if selfData.state == LYCPlayerState.WAITING or selfData.state == LYCPlayerState.NO_READY then
            if not LYCRoomData.IsFangKaFlow() then
                if not LYCRoomData.isCardGameStarted then
                    --金币场显示准备按钮
                    LYCRoomPanel.ShowReadyBtn(true)
                end
            else
                if LYCRoomData.MainIsOwner() and LYCRoomData.GetSelfData().state == LYCPlayerState.WAITING and not LYCRoomData.IsGameStarted() then
                    --显示准备
                    LYCRoomPanel.ShowReadyBtn(false)
                else
                    --显示准备(小局之间的准备)
                    LYCRoomPanel.ShowReadyBtn(true and not LYCRoomData.IsGameStarted())
                end
            end
        end
    end
end

--1014028 推送离线状态
function LYCRoom.OnOffline(arg)
    local data = arg.data
    if data.type == 1 then
        local playerData = LYCRoomData.GetPlayerDataById(data.arg.userId)
        if not IsNil(playerData) then
            playerData.isOffline = data.arg.isOnline
            if not IsNil(playerData.item) then
                playerData.item:SetOfflineActive(not playerData.isOffline)
            end
        end
    end
end

--检测所有玩家推注图标
function LYCRoom.CheckAllPlayerTuiZhu()
    local playerData = nil
    for i = 1, #LYCRoomData.playerDatas do
        playerData = LYCRoomData.playerDatas[i]

        if playerData.id == LYCRoomData.BankerPlayerId then
            playerData.pushBet = false
            playerData.isPushBet = false
        end

        --新加判断，所有玩家在坐下旁观时不显示
        if playerData.state ~= LYCPlayerState.WAITING then
            playerData:UpdataTuiZhuState()
        end
    end
end

-- 推送改变元宝数量
function LYCRoom.OnPushRoomDeductGold(arg)
    if arg.code == 0 then
        this.UpdatePlayerGold(arg.data)
    end
end

---隐藏所有捞腌菜玩家头像标记
function LYCRoom.HideLYCAllPlayerImgTag()
    for _, playerData in ipairs(LYCRoomData.playerDatas) do
        playerData:SetPlayerBombImgTagActive(false)
        playerData:SetPlayerLaoImgTagActive(false)
        playerData:SetPlayerDoNotLaoImgTagActive(false)
    end
end

return this