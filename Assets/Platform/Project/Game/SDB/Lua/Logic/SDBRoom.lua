SDBRoom = {}

local this = SDBRoom
--下注timer
local betStateTimer = nil
--结算timer
local balanceTimer = nil

function SDBRoom.Initialize()
    this.InitEvents()
end

function SDBRoom.Clear()
    this.RemoveEvents()
    if balanceTimer ~= nil then
        Scheduler.unscheduleGlobal(balanceTimer)
        balanceTimer = nil
    end
    if not IsNil(betStateTimer) then
        Scheduler.unscheduleGlobal(betStateTimer)
        betStateTimer = nil
    end
    SDBContentTip.ClearCountDown()
end

-- ==========================================================================================--
-- 事件监听
function SDBRoom.InitEvents()
    -- 断线重新连接
    AddEventListener(CMD.Game.Reauthentication, this.OnInitLoginData)
    AddEventListener(CMD.Game.OnDisconnected, this.OnGameDisconnected)

    AddEventListener(SDBAction.SDB_STC_LEAVE_ROOM, this.OnLeaveRoom)
    AddEventListener(SDBAction.SDB_STC_JOIN_ROOM, this.OnJoinRoom)
    AddEventListener(SDBAction.SDB_STC_ROOM_INFO, this.OnSdbStcRoomInfo)
    AddEventListener(SDBAction.SDB_STC_UPDATE_PLAYER_INFO, this.OnSdbStcUpdatePlayerInfo)
    AddEventListener(SDBAction.SDB_STC_PLAYER_INFOS, this.OnSdbStcPlayerInfos)
    AddEventListener(SDBAction.SDB_CTS_READY, this.OnCtsReady)
    AddEventListener(SDBAction.SDB_STC_READY, this.OnStcReady)
    AddEventListener(SDBAction.SDB_STC_START_STATE, this.OnStartGame)
    AddEventListener(SDBAction.SDB_CTS_OPERATE_START_GAME, this.OnOperateStartGame)
    AddEventListener(SDBAction.SDB_STC_GAME_START, this.OnGameStart)
    AddEventListener(SDBAction.SDB_STC_SEND_CARDS, this.OnSendCards)
    AddEventListener(SDBAction.SDB_STC_INFROM_ROB_BANKER, this.OnInfromRobBanker)
    AddEventListener(SDBAction.SDB_CTS_OPERATE_ROB_BANKER, this.OnRobBanker)
    AddEventListener(SDBAction.SDB_STC_ROB_BANKER, this.OnRobBankerEnd)
    AddEventListener(SDBAction.SDB_STC_INFROM_BET_SCORE, this.OnInformBetScore)
    AddEventListener(SDBAction.SDB_CTS_OPERATE_BET_SCORE, this.OnOperateBetScore)
    AddEventListener(SDBAction.SDB_STC_BET_SCORE, this.OnBetScore)
    AddEventListener(SDBAction.SDB_STC_NOTICE_INFROM_GET_CARDS, this.OnNoticeInfromGetCards)
    AddEventListener(SDBAction.SDB_STC_INFROM_GET_CARDS, this.OnInfromGetCards)
    AddEventListener(SDBAction.SDB_CTS_OPERATE_GET_CARDS, this.OnOperateGetCards)
    AddEventListener(SDBAction.SDB_STC_UPDATE_CARDS_NUMBER, this.OnUpdateCardsNumber)
    AddEventListener(SDBAction.SDB_STC_BALANCE, this.OnBalance)
    AddEventListener(SDBAction.SDB_STC_SUMMARIZE, this.OnSummarize)
    AddEventListener(SDBAction.SDB_CTS_PORTION_PLYAER_INFO, this.OnPortionPlayerInfo)
    AddEventListener(SDBAction.SDB_CTS_LAUNCH_DISSOLVE, this.OnLaunchDissolve)
    AddEventListener(SDBAction.SDB_CTS_OPERATE_DISSOLVE, this.OnOperateDissolve)
    AddEventListener(SDBAction.SDB_STC_NOTICE_DISMISS_ROOM, this.OnNoticeDismissRoom)
    AddEventListener(SDBAction.SDB_CTS_REVIEW, this.OnReview)
    AddEventListener(SDBAction.SDB_STC_NOTICE_PLAYER_READY, this.OnNoticePlayerReady)
    AddEventListener(SDBAction.SDB_STC_IS_DISMISS_ROOM, this.OnIsDismissRoom)
    AddEventListener(SDBAction.SDB_STC_INFROM_NODEED_CARDS, this.OnPlayerNoNeedCard)
    AddEventListener(SDBAction.SDB_STC_OFFLINE, this.OnOffline)
    AddEventListener(SDBAction.SDB_GAME_PROCESS, this.OnGameProcess)
    AddEventListener(SDBAction.Push_SystemTips, this.OnPushSystemTips)

    AddEventListener(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
    AddEventListener(CMD.Game.BatteryState, this.OnBatteryState)
    AddEventListener(CMD.Game.Ping, this.OnPing)
end

-- 移除监听事件
function SDBRoom.RemoveEvents()
    -- 断线重新连接
    RemoveEventListener(CMD.Game.Reauthentication, this.OnInitLoginData)
    RemoveEventListener(CMD.Game.OnDisconnected, this.OnGameDisconnected)

    RemoveEventListener(SDBAction.SDB_STC_LEAVE_ROOM, this.OnLeaveRoom)
    RemoveEventListener(SDBAction.SDB_STC_JOIN_ROOM, this.OnJoinRoom)
    RemoveEventListener(SDBAction.SDB_STC_ROOM_INFO, this.OnSdbStcRoomInfo)
    RemoveEventListener(SDBAction.SDB_STC_UPDATE_PLAYER_INFO, this.OnSdbStcUpdatePlayerInfo)
    RemoveEventListener(SDBAction.SDB_STC_PLAYER_INFOS, this.OnSdbStcPlayerInfos)
    RemoveEventListener(SDBAction.SDB_CTS_READY, this.OnCtsReady)
    RemoveEventListener(SDBAction.SDB_STC_READY, this.OnStcReady)
    RemoveEventListener(SDBAction.SDB_STC_START_STATE, this.OnStartGame)
    RemoveEventListener(SDBAction.SDB_CTS_OPERATE_START_GAME, this.OnOperateStartGame)
    RemoveEventListener(SDBAction.SDB_STC_GAME_START, this.OnGameStart)
    RemoveEventListener(SDBAction.SDB_STC_SEND_CARDS, this.OnSendCards)
    RemoveEventListener(SDBAction.SDB_STC_INFROM_ROB_BANKER, this.OnInfromRobBanker)
    RemoveEventListener(SDBAction.SDB_CTS_OPERATE_ROB_BANKER, this.OnRobBanker)
    RemoveEventListener(SDBAction.SDB_STC_ROB_BANKER, this.OnRobBankerEnd)
    RemoveEventListener(SDBAction.SDB_STC_INFROM_BET_SCORE, this.OnInformBetScore)
    RemoveEventListener(SDBAction.SDB_CTS_OPERATE_BET_SCORE, this.OnOperateBetScore)
    RemoveEventListener(SDBAction.SDB_STC_BET_SCORE, this.OnBetScore)
    RemoveEventListener(SDBAction.SDB_STC_NOTICE_INFROM_GET_CARDS, this.OnNoticeInfromGetCards)
    RemoveEventListener(SDBAction.SDB_STC_INFROM_GET_CARDS, this.OnInfromGetCards)
    RemoveEventListener(SDBAction.SDB_CTS_OPERATE_GET_CARDS, this.OnOperateGetCards)
    RemoveEventListener(SDBAction.SDB_STC_UPDATE_CARDS_NUMBER, this.OnUpdateCardsNumber)
    RemoveEventListener(SDBAction.SDB_STC_BALANCE, this.OnBalance)
    RemoveEventListener(SDBAction.SDB_STC_SUMMARIZE, this.OnSummarize)
    RemoveEventListener(SDBAction.SDB_CTS_PORTION_PLYAER_INFO, this.OnPortionPlayerInfo)
    RemoveEventListener(SDBAction.SDB_CTS_LAUNCH_DISSOLVE, this.OnLaunchDissolve)
    RemoveEventListener(SDBAction.SDB_CTS_OPERATE_DISSOLVE, this.OnOperateDissolve)
    RemoveEventListener(SDBAction.SDB_STC_NOTICE_DISMISS_ROOM, this.OnNoticeDismissRoom)
    RemoveEventListener(SDBAction.SDB_CTS_REVIEW, this.OnReview)
    RemoveEventListener(SDBAction.SDB_STC_NOTICE_PLAYER_READY, this.OnNoticePlayerReady)
    RemoveEventListener(SDBAction.SDB_STC_IS_DISMISS_ROOM, this.OnIsDismissRoom)
    RemoveEventListener(SDBAction.SDB_STC_INFROM_NODEED_CARDS, this.OnPlayerNoNeedCard)
    RemoveEventListener(SDBAction.SDB_STC_OFFLINE, this.OnOffline)
    RemoveEventListener(SDBAction.SDB_GAME_PROCESS, this.OnGameProcess)
    RemoveEventListener(SDBAction.Push_SystemTips, this.OnPushSystemTips)
    RemoveEventListener(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
    RemoveEventListener(CMD.Game.BatteryState, this.OnBatteryState)
    RemoveEventListener(CMD.Game.Ping, this.OnPing)
end

-- ==========================================================================================--
-- 重连的登录数据
function SDBRoom.OnInitLoginData()
    if not SDBRoomData.isInitRoomEnd then
        return
    end

    if not SDBRoomData.isPlayback then
        SDBRoomData.isCandSend = true
        if IsTable(ChatModule) then
            ChatModule.SetIsCanSend(true)
        end
    end
    this.SendNetWorkData()
end

--断线
function SDBRoom.OnGameDisconnected()
    SDBRoomData.isCandSend = false
    if IsTable(ChatModule) then
        ChatModule.SetIsCanSend(false)
    end
end
-- ==========================================================================================--
-- Init初始化完Room相关网络协议再向服务器请求以下数据，否则可能请求到的协议还未注册
function SDBRoom.SendNetWorkData()
    --进入房间
    SDBApiExtend.EnterGame(UserData.GetRoomId(), SDBRoomData.mainId, SDBRoomData.roomData.line)
end

--194 加入房间回复
function SDBRoom.OnJoinRoom()
    Waiting.ForceHide()
    SDBRoomData.isGetCard = true
    -- --重置游戏牌局
    SDBRoomPanel.Reset()
    --重置操作界面
    SDBOperationCtrl.ResetOperation()
    -- --重置桌面
    SDBDeskPanel.ResetSdbDesk()
    --关闭要牌按钮
    SDBOperationPanel.SetOperationBtnActive(false)
    --关闭解散界面
    PanelManager.Close(SDBPanelConfig.Dismiss, true)

    SDBRoomData.isCandSend = not SDBRoomData.isPlayback
    ChatModule.SetIsCanSend(not SDBRoomData.isPlayback)
end

-- 101 房间信息更新
function SDBRoom.OnSdbStcRoomInfo(arg)
    local data = arg.data
    --解析 1002
    this.Parse101RoomInfo(data)
    SDBRoomCtrl.InitRoomUI(data)
end

--解析 101
function SDBRoom.Parse101RoomInfo(data)
    --设置房间号
    Log("=======Parse101RoomInfo======", data)
    SDBRoomData.roomCode = data.roomId
    --设置游戏当前局数
    SDBRoomData.gameIndex = data.pcountNow
    --设置游戏类型
    SDBRoomData.gameType = data.wanfa
    --底分倍数
    SDBRoomData.difenBeiShu = data.df
    --准入
    if IsNil(data.zhunru) then
        data.zhunru = 0
    end
    SDBRoomData.zhunru = data.zhunru
    --解析规则
    SDBFuntions.PlayWay(data)
    --游戏是否开始 -- 是否点击游戏开始   1代表准备阶段，2代表抢庄阶段，3代表下注状态，4代表要牌阶段
    SDBRoomData.isCardGameStarted = data.gamestate ~= 1 and data.gamestate ~= 0
    --设置游戏类型名
    SDBRoomData.gameName = SDBGameType_CONFIG[SDBRoomData.gameType].name
    --游戏阶段
    SDBRoomData.gameState = data.gamestate
end

--102 更新玩家信息
function SDBRoom.OnSdbStcUpdatePlayerInfo(arg)
    local data = arg.data
    if data.state == 2 then
        local playerData = this.UpdatePlayerData(data)
        --更新座位
        SDBRoomCtrl.UpdatePlayerUI(playerData)
    elseif data.state == 5 then
        SDBRoomCtrl.RemovePlayerUI(data.uId)
        SDBRoomData.RemovePlayer(data.uId)
        --请求更新当前所有玩家信息
        SDBApiExtend.SendPortionPlayerInfo()
        --更新聊天模块
        SDBRoom.UpdateChatPlayers(SDBRoomPanel.GetAllPlayerItems())
    end
end

-- 103 玩家信息
function SDBRoom.OnSdbStcPlayerInfos(arg)
    --判断房间号是否为空
    if SDBRoomData.roomCode == 0 then
        --房间信息错误，重新获取数据
        SDBRoom.SendNetWorkData()
        return
    end
    local data = arg.data
    SDBRoomData.BankerPlayerId = nil
    --更新玩家信息
    for i = 1, #data.list do
        this.UpdatePlayerData(data.list[i])
    end
    --更新玩家数据UI
    SDBRoomCtrl.UpdatePlayersDisplay()
    --设置庄的图标
    SDBRoomCtrl.CheckZhuang()
    --显示下注分
    SDBRoomPanel.ShowXiaZhuGold()
    --隐藏卡槽
    this.HideCardSlots()
    --检查显示等待中牌子
    this.CheckSelfState()
    --设置状态
    SDBRoomCtrl.ShowUIByState()
    --更新右上角的菜单栏
    SDBRoomPanel.UpdateMenuInfo()
    --检查离线状态
    this.CheckResetPlayerOfflineIcon()
    --默认房主准备
    -- this.ReadyOnOwner()
    --更新聊天模块
    this.UpdateChatPlayers(SDBRoomPanel.GetAllPlayerItems())
end

function SDBRoom.ReadyOnOwner()
    --手动开始  而且自己时房主
    if not SDBRoomData.isCardGameStarted and SDBRoomData.startType == 1 and SDBRoomData.MainIsOwner() and SDBRoomData.GetSelfIsLook() then
        --判断是否是大厅开房
        if string.IsNullOrEmpty(SDBRoomData.clubId) or SDBRoomData.clubId == 0 then
            if SDBRoomData.gameIndex == 0 then
                --自动坐下
                SDBApiExtend.SendSitDown()
            end
        end
    end
end

--检查开始后玩家座位信息
function SDBRoom.CheckIsUpadatePlayerSitDown()
    for i, v in ipairs(SDBRoomData.playerDatas) do
        if v.state == PlayerState.Gaming or v.state == PlayerState.Stand then
            local playerItem = SDBRoomData.GetPlayerUIById(v.id)
            if playerItem == nil then
                return true
            end
        end
    end
    return false
end

--检查游戏开始前玩家座位信息
function SDBRoom.CheckIsGameStartSitDown()
    if SDBRoomData.isCardGameStarted then
        return false
    end
    for i, v in ipairs(SDBRoomData.playerDatas) do
        if v.state == PlayerState.Ready then
            local playerItem = SDBRoomData.GetPlayerUIById(v.id)
            if playerItem == nil then
                return true
            end
        end
    end
    return false
end

--检查玩家离线图标设置
function SDBRoom.CheckResetPlayerOfflineIcon()
    for i, playerData in ipairs(SDBRoomData.playerDatas) do
        local playerItem = SDBRoomData.GetPlayerUIById(playerData.id)
        if playerItem ~= nil then
            playerItem:SetOfflineActive(playerData.isOffline)
        end
    end
end

--隐藏所有卡槽
function SDBRoom.HideCardSlots()
    --默认隐藏卡槽
    for i = 1, #SDBRoomData.playerDatas do
        SDBRoomData.playerDatas[i]:HideCardsSlot()
    end
end

--检查自己的状态
function SDBRoom.CheckSelfState()
    local selfState = SDBRoomData.GetSelfData().state
    --中途加入显示坐下与观看  游戏已经开始
    if SDBRoomData.isCardGameStarted then
        if selfState == PlayerState.LookOn then
            SDBRoomPanel.ShowWatch()
        elseif selfState == PlayerState.Gaming then
            SDBRoomPanel.HideWatchShow()
        elseif selfState == PlayerState.Ready then
            SDBRoomPanel.ShowWait()
        elseif selfState == PlayerState.Stand then
            SDBRoomPanel.HideWatchShow()
        end
    else
        SDBRoomPanel.HideWatchShow()
    end
end

--增加一个玩家的信息
function SDBRoom.UpdatePlayerData(data)
    if data == nil then
        return
    end
    local playerData = SDBRoomData.GetPlayerDataById(data.uId)
    if playerData == nil then
        playerData = SDBPlayer:New()
        table.insert(SDBRoomData.playerDatas, playerData)
    end
    playerData:SetPlayerData(data)
    return playerData
end

-- 104 坐下（准备）
function SDBRoom.OnCtsReady(arg)
    local data = arg.data
    if arg.code ~= 0 then
        --还原按钮
        SDBRoomPanel.ShowSitOrReadyBtn()
    else
        if data.state == 1 then
            SDBRoomPanel.HideSitDown()
            --游戏未开始时，重置数据，
            if not SDBRoomData.isCardGameStarted then
                --自己是房主的情况
                if SDBRoomData.MainIsOwner() and SDBRoomData.gameIndex == 0 then
                    SDBRoomPanel.PlayStartBtnMove()
                end
                this.XiaoJieReset()
            end
        else
            --还原按钮
            SDBRoomPanel.ShowSitOrReadyBtn()
        end

        if data.state == 113 then
            Alert.Show("元宝不足，请前往充值", function()
                --todo 退出游戏
            end)
        end
    end
end

-- 105 广播某个玩家坐下
function SDBRoom.OnStcReady(arg)
    local data = arg.data
    --更新数据
    local playerData = SDBRoomData.GetPlayerDataById(data.uId)
    playerData:UpdatePlayerStates(data.state)
    playerData.seatNumber = data.chair

    -- 0 :坐下  1：准备
    if data.type == 0 then
        this.UpdateSitDwonState(playerData)
    else
        if not IsNil(playerData.item) then
            playerData.item:SetIsPlayReadyAni()
            local bool = playerData.state == PlayerState.Ready
            playerData.item:UpdatellReadyImge(bool, true)
        end
    end

    --判断是否显示等待中
    if SDBRoomData.isCardGameStarted and SDBRoomData.GetSelfData().state == PlayerState.Ready then
        SDBRoomPanel.ShowWait()
    end

    --判断是否是自己准备     --设置状态。
    if data.uId == SDBRoomData.mainId then
        SDBRoomCtrl.ShowUIByState()
        SDBRoomPanel.UpdateMenuInfo()

        if not IsNil(playerData.item) then
            playerData.item:ResetPlayerUI()
        end
    end
end

--更新坐下状态
function SDBRoom.UpdateSitDwonState(playerData)
    if playerData.id == SDBRoomData.mainId then
        SDBRoomCtrl.UpdatePlayerUI(playerData)
    else
        if not SDBRoomData.isCardGameStarted then
            if SDBRoomData.gameIndex == 0 or not SDBRoomData.isHaveJieSuan then
                SDBRoomCtrl.UpdatePlayersDisplay()
            end
        end
    end
end

-- 106 通知房主是否可以开始游戏
function SDBRoom.OnStartGame(arg)
    local data = arg.data
    SDBRoomPanel.SetStartBtnInteractable(data.isStart == 1)
end

--107 房主点击开始游戏回复
function SDBRoom.OnOperateStartGame(arg)

end

-- 108 游戏开始游戏开始
function SDBRoom.OnGameStart(arg)
    local data = arg.data
    --隐藏开始按钮
    SDBRoomPanel.HideStartBtn()
    --更新数据
    SDBRoomData.gameIndex = data.pcountNow
    --if not SDBRoomData.IsGoldGame() then
    --更新局数
    SDBRoomPanel.SetJuShuText(SDBRoomData.gameIndex .. "/" .. SDBRoomData.gameTotal)
    --end
    --游戏开始
    SDBRoomData.isCardGameStarted = true
    --更新所有坐下的玩家的状态
    local players = SDBRoomData.GetReadyPlayer()
    for i = 1, #players do
        players[i]:UpdatePlayerStates(PlayerState.Gaming)
    end
    --隐藏所有玩家准备图标
    SDBRoomPanel.HideAllReadyImge()
    -- 更新菜单信息
    SDBRoomPanel.UpdateMenuInfo()
    --播放开始音效
    SDBResourcesMgr.PlayGameSound(SDBGameEffSoundType.EFFSTART)
    --停止播放结算动画
    Scheduler.unscheduleGlobal(balanceTimer)
    balanceTimer = nil
    --结算取消
    SDBRoomData.isHaveJieSuan = false
    --重置庄家id
    SDBRoomData.BankerPlayerId = nil
    --重置操作面板界面
    SDBOperationCtrl.Reset()
    --游戏开始后重置观战玩家的桌面界面
    if SDBRoomData.GetSelfIsLookGaming() then
        SDBRoomPanel.ShowWatch()
    else
        SDBRoomPanel.HideWatchShow()
    end

    this.XiaoJieReset()
    --检测所有玩家观战中状态
    this.CheckAllPlayerLookOn()
    if SDBRoomData.IsGoldGame() then
        --元宝场，开局后不显示准备按钮
        SDBRoomPanel.HideReadyBtn()
    end

    --显示推注信息
    SDBRoomCtrl.ShowTuiZhu(data.tzIds)
end

function SDBRoom.XiaoJieReset()
    --开局重置的数据
    SDBRoomData.StartGameReset()
    --重置游戏牌局
    SDBRoomPanel.Reset()
    SDBDeskPanel.ResetSdbDesk()
end

-- 109 发牌  --data.type ==> 需要个发牌类型
function SDBRoom.OnSendCards(arg)
    SDBRoomData.gameState = SDBGameState.SendCard
    local data = arg.data
    data.gameIndex = SDBRoomData.gameIndex
    -- --收到牌 表示可以要下一张牌
    SDBRoomData.isGetCard = true
    --隐藏下注分
    this.HideBetStateScore()
    --隐藏操作按钮
    this.HideOperationBtn(data)
    --发牌
    this.SendCards(data)

    if data.oId ~= 0 then
        --隐藏要牌中动画
        for _, playerData in ipairs(SDBRoomData.playerDatas) do
            if data.oId ~= playerData.id then
                SDBRoomAnimator.StopYaoPaiZhongAni(playerData.id)
            end
        end
        if data.oId ~= SDBRoomData.mainId then
            --隐藏要牌按钮
            SDBOperationPanel.SetOperationBtnActive(false)
        end
        --播放要牌中动画
        SDBRoomAnimator.PlayYaoPaiZhongAni(data.oId)
    end
end

--发牌
function SDBRoom.SendCards(data)
    --获取十点半桌面
    if data.state == SDBSendCardsType.Normal then
        --普通发牌
        SDBRoom.OnNormalSend(data)
    elseif data.state == SDBSendCardsType.GetCards then
        --要牌
        SDBRoom.OnGetCards(data)
        if data.oId == SDBRoomData.mainId then
            SDBResourcesMgr.PlayGameOperSound(SDBGameSoundType.DEALCARD, data.oId)
        end
    elseif data.state == SDBSendCardsType.Reconnection then
        --断线重连
        SDBRoom.OnReconnection(data)
    elseif data.state == SDBSendCardsType.SpecialCard then
        --特殊牌型
        SDBRoom.OnSpecialCard(data)
    end
end

--==============================--
--desc: 普通发牌
--time:2018-12-20 10:51:52
--@sdbDeskCtrl: 桌面的Ctrl组件
--@data: 循环列表，data.list 包含uId以及牌点数
--@return
--==============================--
function SDBRoom.OnNormalSend(data)
    for i = 1, #data.list do
        -- "str":"2,0.5","uId":100393,"card":"29"
        local playerData = SDBRoomData.GetPlayerDataById(data.list[i].uId)
        playerData.handCards = {}
        table.insert(playerData.handCards, data.list[i].card)
        --发牌动画
        SDBDeskPanel.SendCards(playerData, playerData.handCards[1], #playerData.handCards, HandlerArgs(this.ShowPoint, data))
        --显示卡槽
        playerData:ShowCardsSlot()
    end
end

--==============================--
--desc: 要牌
--time:2018-12-20 11:12:27
--@sdbDeskCtrl: 桌面的Ctrl组件
--@oId: 操作者id
--@list: 循环列表
--@return
--==============================--
function SDBRoom.OnGetCards(data)
    --要牌的情况
    local tempData = nil
    for i = 1, #data.list do
        tempData = data.list[i]
        if data.oId == tempData.uId then
            local playerData = SDBRoomData.GetPlayerDataById(data.oId)
            local strtab = string.split(tempData.card, ",")
            if playerData ~= nil then
                if IsNil(tempData.cards) then
                    if IsNil(playerData.handCards) then
                        playerData.handCards = {}
                    end
                    --判断当前发牌的数量
                    table.insert(playerData.handCards, strtab[1])
                else
                    playerData.handCards = string.split(tempData.cards, ",")
                end
                SDBDeskPanel.SendCards(playerData, strtab[1], #playerData.handCards, HandlerArgs(this.ShowPoint, data, strtab[1]))
            end
            return
        end
    end
end

--==============================--
--desc:断线重连
--time:2018-12-20 10:56:18
--@sdbDeskPanel: 桌面的Ctrl组件
--@data:  循环列表，data.list
--@return
--==============================--
function SDBRoom.OnReconnection(data)
    --断线重连回来
    for i = 1, #data.list do
        local playerData = SDBRoomData.GetPlayerDataById(data.list[i].uId)
        local cards = string.split(data.list[i].card, ",")
        playerData.handCards = cards

        playerData:ShowAllCard(playerData.handCards)

        SDBDeskPanel.ShowCardPile()

        local type = string.split(data.list[i].str, ",")
        if tonumber(type[1]) == -1 then
            if data.list[i].isOver == 1 then
                UIUtil.SetActive(playerData.item.completeImage.gameObject, true)
            else
                UIUtil.SetActive(playerData.item.completeImage.gameObject, false)
            end
        end
    end
    this.ShowPoint(data)
end

--==============================--
--desc:
--time:2018-12-20 11:11:06
--@sdbDeskCtrl:桌面的Ctrl组件
--@oId: 操作者id
--@list: 循环列表
--@return
--==============================--
function SDBRoom.OnSpecialCard(data)
    --特殊牌的情况
    for i = 1, #data.list do
        if data.oId == data.list[i].uId then
            local playerData = SDBRoomData.GetPlayerDataById(data.oId)
            local strtab = string.split(data.list[i].card, ",")
            playerData.handCards = strtab
            SDBDeskPanel.SendCards(playerData, strtab[#strtab], #playerData.handCards, function()
                if SDBRoomData.isCardGameStarted or SDBRoomData.isPlayback then
                    playerData:ShowAllCard(playerData.handCards)
                    this.ShowPoint(data)
                end
            end)
            break
        end
    end
end


--隐藏操作按钮
function SDBRoom.HideOperationBtn(data)
    if SDBRoomData.mainId == data.oId then
        for i, v in ipairs(data.list) do
            if SDBRoomData.mainId == v.uId then
                local strtab = string.split(v.str, ",")
                --自己的要牌类型不是2，隐藏操作按钮
                if tonumber(strtab[1]) ~= 2 then
                    SDBOperationPanel.SetOperationBtnActive(false)
                end
                break
            end
        end
    end
end

--显示点数
function SDBRoom.ShowPoint(data)
    if data == nil or data.gameIndex ~= SDBRoomData.gameIndex then
        data = nil
        return
    end
    if data.state ~= SDBSendCardsType.RubCards then
        --显示点数
        for i, v in ipairs(data.list) do
            local strtab = string.split(v.str, ",")
            local cards = string.split(v.card, ",")
            local temp = true
            for i = 1, #cards do
                if cards[i] == "-1" then
                    temp = false
                    break
                end
            end
            if temp then
                --点数不是-1（可以显示点数）
                if tonumber(strtab[2]) ~= -1 then
                    --显示点数 point
                    SDBRoomPanel.SetCardsPoint(v.uId, tonumber(strtab[1]), tonumber(strtab[2]), true)
                    --关闭要牌中的动画，当亮牌时
                    if tonumber(strtab[1]) ~= 2 then
                        SDBRoomAnimator.StopYaoPaiZhongAni(v.uId)
                    end
                end
            end
        end
    end
    data = nil
end

--搓牌结束回调
function SDBRoom.OnCompleteRubCardsOne()
    SDBApiExtend.SendGetCard(SDBOperationCardType.ShowCard)
end

-- 110 通知抢庄
function SDBRoom.OnInfromRobBanker(arg)
    SDBRoomData.gameState = SDBGameState.RobBanker
    local data = arg.data

    if SDBRoomData.GetSelfIsLook() then
        SDBRoomPanel.ShowWatch()
        return
    end
    SDBRoomPanel.HideWatchShow()

    local value = nil
    if not IsNil(data.qzbs) then
        value = string.split(data.qzbs, ";")
    end
    --显示抢庄按钮
    SDBOperationCtrl.ShowRobZhuangReslult(data.isQz == 1, value)
    --播放抢庄通知
    SDBResourcesMgr.PlayGameSound(SDBGameEffSoundType.EFFCALLROB)
end

-- 111 广播抢庄信息
function SDBRoom.OnRobBanker(arg)
    SDBRoomData.gameState = SDBGameState.RobBanker
    if arg.code == 0 then
        local data = arg.data
        local playerData = SDBRoomData.GetPlayerDataById(data.uId)
        if data.bs ~= -1 and data.uId == SDBRoomData.mainId then
            --关闭抢庄界面
            SDBOperationCtrl.HideRobZhuangReslult()
        end
        playerData.robZhuangState = data.bs
        --显示抢几
        playerData:ShowRobZhuangNum()
    else
        SDBOperationCtrl.HideRobZhuangReslult()
    end
end

-- 112 抢庄完成
function SDBRoom.OnRobBankerEnd(arg)
    SDBRoomData.gameState = SDBGameState.RobBanker
    local data = arg.data
    SDBRoomData.BankerPlayerId = data.uId

    --获取参与抢庄玩家id
    local playerDatas = string.split(data.str, ";")
    for i = 1, #playerDatas do
        local str = string.split(playerDatas[i], ",")
        if tonumber(str[1]) == SDBRoomData.BankerPlayerId then
            local playerData = SDBRoomData.GetPlayerDataById(SDBRoomData.BankerPlayerId)
            if tonumber(str[2]) == 0 then
                playerData.robZhuangState = 1
            else
                playerData.robZhuangState = tonumber(str[2])
            end
        end
    end

    --抢庄
    this.CheckRobZhuang(playerDatas)
    --关闭抢庄抢几
    this.CloseRobZhuangNum()

    --关闭庄家可推注显示
    SDBRoomCtrl.HideTuizhu(data.uId)
end

-- 129收到某个玩家要牌/不要牌
function SDBRoom.OnPlayerNoNeedCard(arg)
    SDBRoomData.isGetCard = true
    local data = arg.data
    local playerId = data.uId
    local type = SDBGameSoundType.PASS
    if data.state == 0 then
        SDBRoomAnimator.StopYaoPaiZhongAni(data.uId)
        if playerId == SDBRoomData.mainId then
            SDBResourcesMgr.PlayGameOperSound(SDBGameSoundType.PASS, playerId)
        end
        if SDBRoomData.BankerPlayerId ~= data.uId then
            this.PlayCompleteImageAni(data.uId, true)
        end
    end
end

--- = ================================================================
--显示完成
function SDBRoom.PlayCompleteImageAni(uId, isPlay)
    --显示完成
    local playerItem = SDBRoomData.GetPlayerUIById(uId)
    if playerItem ~= nil then
        playerItem:ShowCompleteImage(isPlay)
    else
        LogError(">>>>>>>>>>>>  不要牌的玩家没有item : " .. uId)
    end
end

-- 116 显示某个玩家要牌中
function SDBRoom.OnNoticeInfromGetCards(arg)
    SDBRoomData.gameState = SDBGameState.SendCard
    local data = arg.data
    for i = 1, #SDBRoomData.playerDatas do
        SDBRoomAnimator.StopYaoPaiZhongAni(SDBRoomData.playerDatas[i].id)
    end
    --判断操作者是否是自己
    SDBOperationPanel.SetOperationBtnActive(data.uId == SDBRoomData.mainId)
    --隐藏下注分
    this.HideBetStateScore()
    --播放要牌中动画
    SDBRoomAnimator.PlayYaoPaiZhongAni(data.uId)
end

-- 117 通知玩家要牌
function SDBRoom.OnInfromGetCards(arg)
    --隐藏下注分
    this.HideBetStateScore()
    --显示要牌，搓牌以及不要
    SDBOperationPanel.SetOperationBtnActive(true)
end

-- 118 操作要牌回复
function SDBRoom.OnOperateGetCards(arg)
    SDBRoomData.isGetCard = true
    local data = arg.data
    --要牌操作成功
    if data.status == 1 then
        if data.type == SDBSendCardsType.Normal then
            SDBOperationPanel.SetOperationBtnActive(false)
        end
    else
        --要牌失败
    end
end

-- 119 更新剩余牌数量
function SDBRoom.OnUpdateCardsNumber(arg)
    local data = arg.data
    SDBDeskPanel.SetCardNumber(data.syCard)
end

-- 120 小结算
function SDBRoom.OnBalance(arg)
    local data = arg.data
    --更新游戏状态
    SDBRoomData.gameState = SDBGameState.Ready
    --表示有结算
    SDBRoomData.isHaveJieSuan = true
    --更新局数
    SDBRoomData.gameIndex = data.pcountNow
    --游戏设为未进行中
    SDBRoomData.isCardGameStarted = false
    --隐藏所有要牌中的动画
    this.BalanceHideAllYaoPaiZhong()
    --更新玩家数据
    this.UpdateXiaoJieSuanData(data)
    --更新玩家状态
    this.BalanceHandlePlayerState()
    --检测所有玩家观战中状态
    this.CheckAllPlayerLookOn()
    --表示当前局已经结束
    Scheduler.unscheduleGlobal(balanceTimer)
    balanceTimer = nil

    local time = 0.1
    if data.isZc == 3 then
        SDBRoomPanel.ShowReadyBtn()
        SDBRoomData.BankerPlayerId = data.zhuangId
        SDBRoomCtrl.CheckZhuang()
    elseif data.isZc == 1 then
        time = 0.5
    end

    -- 1为正常结束，2为中途解散，3断线重连
    if data.isZc ~= 2 then
        balanceTimer = Scheduler.scheduleOnceGlobal(function()
            --处理结算信息
            this.SetBalanceInfo(data)
            if data.isZc == 1 then
                --比牌
                this.CompareCard(data.isBankerPassKill)
            end
        end, time)
    else
        if SDBRoomData.isPlayback then
            Toast.Show("中途解散，游戏已结束")
        end
    end

    --如果自己是中途加入并且已经坐下则关闭观看中，等待中图标
    if not SDBRoomData.GetSelfIsLookGaming() then
        SDBRoomPanel.HideWatchShow()
    end

    --隐藏操作要牌
    SDBOperationPanel.SetOperationBtnActive(false)
    SDBRoomPanel.UpdateMenuInfo()
end

--处理结算玩家状态
function SDBRoom.BalanceHandlePlayerState()
    for _, playerData in ipairs(SDBRoomData.playerDatas) do
        if playerData.state ~= PlayerState.LookOn and playerData.state ~= PlayerState.Ready then
            playerData:UpdatePlayerStates(PlayerState.Stand)
        end
    end
end

--隐藏结算时所有玩家要牌中动画
function SDBRoom.BalanceHideAllYaoPaiZhong()
    for i = 1, #SDBRoomData.playerDatas do
        SDBRoomAnimator.StopYaoPaiZhongAni(SDBRoomData.playerDatas[i].id)
    end
end

--比牌
function SDBRoom.CompareCard(isBankerPassKill)
    --比牌
    SDBOperationPanel.ShowCompareCard(function()
        if SDBRoomData.gameState ~= SDBGameState.Ready then
            return
        end
        Log(">>>>>>>>>>>>>>>>>>>>>>>>>         比牌结束")
        if isBankerPassKill then
            --SDBOperationPanel.ShowTongSha()
            ----播放结果音效
            --SDBResourcesMgr.PlayGameSound(SDBGameEffSoundType.EFFALLKILL)
            Scheduler.scheduleOnceGlobal(SDBRoomPanel.ShowReadyBtn, 1)
        else
            if not SDBRoomData.isCardGameStarted then
                SDBRoomPanel.ShowReadyBtn()
            end
        end
    end)
end

--更新小结算数据
function SDBRoom.UpdateXiaoJieSuanData(data)
    for i = 1, #data.list do
        local playerInfo = data.list[i]
        local playerId = playerInfo.uId
        local playerData = SDBRoomData.GetPlayerDataById(playerId)
        if not IsNil(playerData) then
            --更新下注分
            playerData.xiaZhuScore = playerInfo.paypoint
            --本局扣除分数
            playerData.tempbjpoint = tonumber(playerInfo.bjpoint)
            --显示点数
            local strtab = string.split(playerInfo.cardType, ",")
            local playerData = SDBRoomData.GetPlayerDataById(playerInfo.uId)
            if playerData ~= nil then
                --点数不是-1（可以显示点数）
                if tonumber(strtab[2]) ~= -1 then
                    --显示点数 point
                    playerData.cardType = tonumber(strtab[1])
                    playerData.point = tonumber(strtab[2])
                end
            end
            --更新玩家分数
            playerData.playerScore = playerInfo.point
            --更新玩家手牌
            local cards = string.split(playerInfo.cards, ",")
            playerData.handCards = cards
        end
    end
end

-- 小结算
function SDBRoom.SetBalanceInfo(data)
    --保存战局结果
    local losers = {}
    local winners = {}
    local bankerIsWin = false

    -- 显示手牌
    for i = 1, #data.list do
        local playerInfo = data.list[i]
        local playerId = playerInfo.uId
        local playerData = SDBRoomData.GetPlayerDataById(playerId)
        if not IsNil(playerData) then
            local playerItem = playerData.item
            --显示结算的牌
            playerData:ShowAllCard(playerData.handCards)

            --显示点数 point
            SDBRoomPanel.SetCardsPoint(playerId, playerData.cardType, playerData.point, false)

            --显示完成 非庄家（庄家最后一个要牌，最后一个不显示完成）
            if playerData.cardType == 2 and SDBRoomData.BankerPlayerId ~= playerId then
                this.PlayCompleteImageAni(playerId, false)
            end

            --根据输赢保存玩家
            if playerData.tempbjpoint ~= 0 then
                if playerId ~= SDBRoomData.BankerPlayerId then
                    if playerData.tempbjpoint < 0 then
                        table.insert(losers, playerId)
                    else
                        table.insert(winners, playerId)
                    end
                end
            end

            --判断是否庄家是否获胜
            if playerId == SDBRoomData.BankerPlayerId then
                if playerData.tempbjpoint > 0 then
                    bankerIsWin = true
                end
                if not IsNil(data.nowbs) then
                    --更新玩家抢庄倍数
                    playerData.robZhuangState = data.nowbs
                    playerData:ShowRobZhuangMultiple()
                end
            end

            --显示下注分
            if data.isZc == 3 then
                if playerInfo.paypoint ~= nil and playerId ~= SDBRoomData.BankerPlayerId then
                    SDBRoomPanel.ShowBetPoints(playerId, playerInfo.paypoint)
                end
            end

            if not IsNil(playerItem) then
                --更新结算玩家Score
                playerItem:SetScoreText(playerData.playerScore)
                --播放数赢分数动画
                if data.isZc == 1 then
                    playerItem:SetPayChangeScore(playerData.tempbjpoint)
                else
                    playerItem:ShowChangeScore(playerData.tempbjpoint)
                end
            end
        end
    end

    --播放结算动画
    if data.isZc == 1 then
        this.PlayBalancaAnim(data, bankerIsWin, winners, losers)
    end
end

--播放结算动画
function SDBRoom.PlayBalancaAnim(data, bankerIsWin, winners, losers)
    --当庄赢得时候 判断是否赢得玩家只有庄 否则，没有庄家通杀
    if bankerIsWin then
        data.isBankerPassKill = this.IsBankerPassKill(winners)
    else
        data.isBankerPassKill = false
    end

    --飞金币
    local bankerItem = SDBRoomData.GetPlayerUIById(SDBRoomData.BankerPlayerId)
    if bankerItem ~= nil then
        if bankerIsWin then
            bankerItem:PlayWinAni()
        end
        SDBRoomAnimator.SettlementAnim(bankerItem.faceGO.transform, winners, losers, function()
            --播放结算动画结束，自己也进入未准备状态
            SDBContentTip.HandleSelfNoReady()
        end)
    end

    --自己在战绩中表示非中途加入 兼容使用（防止出现枪几出现）
    if SDBRoomData.GetSelfData().state ~= PlayerState.LookOn then
        --关闭抢庄抢几
        SDBRoom.CloseRobZhuangNum()
    end

    --处理小结算提示语
    SDBContentTip.HandleXiaoJieSuan()
end

--是否是庄家通杀
function SDBRoom.IsBankerPassKill(winners)
    if #winners == 0 then
        return true
    end
    return false
end

--检测所以玩家观战中
function SDBRoom.CheckAllPlayerLookOn()
    for i, playerData in ipairs(SDBRoomData.playerDatas) do
        local playerItem = playerData.item
        if not IsNil(playerItem) then
            --显示观战中
            if SDBRoomData.isCardGameStarted and playerData.state == PlayerState.LookOn then
                playerItem:SetLookOnImageActive(true)
            else
                if not SDBRoomData.isPlayback then
                    playerItem:SetLookOnImageActive(false)
                end
            end
        end
    end
end
---------------------------------------------------------------
-- 121 总结算
function SDBRoom.OnSummarize(arg)
    SDBRoomData.isGameOver = true
    local data = arg.data
    SDBRoomData.Note = data.note
    --收到总结算 隐藏准备按钮
    SDBRoomPanel.HideSitDown()
    --收到总结算，处理提示语
    SDBContentTip.HandleZongJieSuan()

    local summarizeData = {}
    for i = 1, #data.list do
        local list = data.list[i]
        local playerData = SDBRoomData.GetPlayerDataById(list.uId)
        local tab = {}
        tab.bankerCount = list.zzCount
        tab.robBankerCount = list.qzCount
        tab.boomCardCount = list.bpCount
        tab.playerId = list.uId
        tab.score = list.point
        tab.name = playerData.name
        tab.headUrl = playerData.playerHead
        tab.uId = playerData.id
        table.insert(summarizeData, tab)
    end

    summarizeData.endTime = data.endTime
    summarizeData.roomCode = SDBRoomData.roomCode
    summarizeData.difen = SDBRoomData.Bet
    summarizeData.model = SDBRoomData.model
    summarizeData.jushu = SDBRoomData.gameTotal .. "局"
    summarizeData.owner = SDBRoomData.owner

    SDBRoomData.netJieSuanData = summarizeData

    --正常结束
    if data.isZc == 1 or data.isZc == 3 then
        --显示结束UI
        Scheduler.scheduleOnceGlobal(this.ShowGameOver, 3)
    end
end

function SDBRoom.ShowGameOver()
    --开启结束UI
    PanelManager.Open(SDBPanelConfig.JieSuan)
end

-- 122 请求玩家信息
function SDBRoom.OnPortionPlayerInfo(arg)
    local data = arg.data
    if arg.code == 0 then
        --局数为0 并且未在游戏中，没有开始游戏 变更玩家座位
        if not SDBRoomData.isCardGameStarted then
            for i = 1, #data.list do
                local playerInfo = data.list[i]
                local playerData = SDBRoomData.GetPlayerDataById(playerInfo.uId)
                if playerData ~= nil then
                    playerData.seatNumber = playerInfo.chair
                    playerData:UpdatePlayerStates(playerInfo.state)
                end
            end
            --0代表，主推的玩家信息(只有准备状态改为为准备状态会推送)，1代表，自己请求的数据
            if data.type == 1 then
                -- SDBRoomCtrl.UpdatePlayersDisplay()
            elseif data.type == 0 then
                Toast.Show("准备时间已过，准备人数不足，自动取消准备")
            end
        end
    else
        -- 请求失败
        LogError("1016 请求玩家信息失败," .. data.status)
    end
end

-- 123 发起解散
function SDBRoom.OnLaunchDissolve(arg)
    local data = arg.data
    if data.state == 109 then
        Toast.Show("重复申请解散...")
    elseif data.state == 110 then
        Toast.Show("已有玩家申请解散...")
    elseif data.state == 108 then
        Toast.Show("玩家未准备，不能解散房间...")
    elseif data.state == 107 then
        Toast.Show("游戏未开始，普通玩家不能解散房间...")
    end
end

-- 125 解散房间结果通知
function SDBRoom.OnNoticeDismissRoom(arg)
    local data = arg.data
    PanelManager.Close(SDBPanelConfig.Dismiss, true)
    --解散成功
    if data.state == 1 then
        PanelManager.Open(SDBPanelConfig.JieSuan)
    elseif data.state == 3 then
        if SDBRoomData.MainIsOwner() then
            Toast.Show("解散成功")
        else
            Toast.Show("游戏已解散")
        end
        this.ExitRoom()
    elseif data.state == 108 then
        Toast.Show("玩家未准备，不能解散房间...")
    elseif data.state == 110 then
        Toast.Show("已有玩家申请解散...")
    elseif data.state == 109 then
        Toast.Show("重复申请解散...")
    elseif data.state == 107 then
        Toast.Show("游戏未开始，普通玩家不能解散房间...")
    end
end

-- 124 操作同意与拒绝解散房间
function SDBRoom.OnOperateDissolve(arg)
    local data = arg.data
    --同意时
    if data.state == 1 then
        data.type = 2
        PanelManager.Open(SDBPanelConfig.Dismiss, data)
    else
        --拒绝时
        local playerData = SDBRoomData.GetPlayerDataById(data.uId)
        Alert.Show(playerData.name .. "拒绝了解散房间")
    end
end

-- 1003 离开房间
function SDBRoom.OnLeaveRoom(arg)
    if arg.code == 0 then
        local data = arg.data
        if data.state == 1 then
            this.ExitRoom()
        elseif data.state == 105 then
            Toast.Show("房主不能离开房间...")
        elseif data.state == 106 then
            Toast.Show("游戏开始后，坐下的玩家不能离开...")
        elseif data.state == 114 then
            Toast.Show("准备的玩家不能离开...")
        elseif data.state == 115 then
            Toast.Show("未及时准备，自动退出房间")
            this.ExitRoom()
        end
    end
end

--126 上局回顾
function SDBRoom.OnReview(arg)
    local data = arg.data
    if arg.code == 0 then
        if data.code == 0 then
            local panel = SDBReviewPanel
            if SDBRoomData.IsGoldGame() then
                panel = SDBGoldReviewPanel
            end
            if not IsNil(panel) then
                if panel.isActive then
                    panel.OnReview(data)
                end
            end
        elseif arg.code == 117 then
            Toast.Show("暂无上局数据")
        end
    end
end

-- 113 通知下注
function SDBRoom.OnInformBetScore(arg)
    SDBRoomData.gameState = SDBGameState.BetState
    local data = {
        difen = arg.data.df,
        tuizhu = arg.data.tz,
        limitXiaZhuScore = arg.data.xz,
        isFirst = arg.data.isOne == 0,
    }

    --庄家是自己，或者自己没有坐下，表示在观战。不做处理
    if SDBRoomData.MainIsBanker() or SDBRoomData.GetSelfIsLook() then
        return
    end

    local time = 2
    if not SDBFuntions.isRobBanker() or not data.isFirst then
        time = 0
    end

    if not IsNil(betStateTimer) then
        Scheduler.unscheduleGlobal(betStateTimer)
        betStateTimer = nil
    end

    betStateTimer = Scheduler.scheduleOnceGlobal(HandlerArgs(this.BetStateShow, data), time)
end

--下注显示
function SDBRoom.BetStateShow(data)
    if SDBRoomData.mainId == SDBRoomData.BankerPlayerId then
        this.HideBetStateScore()
    else
        local xiaZhuStr = string.split(data.difen, ";")
        local zuiZhuStr = string.split(data.tuizhu, ";")
        local restrictScore = {}
        if data.limitXiaZhuScore ~= "" then
            restrictScore = string.split(data.limitXiaZhuScore, ";")
        end
        SDBOperationCtrl.ShowBetState(xiaZhuStr, zuiZhuStr, restrictScore)
    end
    --播放下注通知
    SDBResourcesMgr.PlayGameSound(SDBGameEffSoundType.EFFCallBET)
end

function SDBRoom.HideBetStateScore()
    if not IsNil(betStateTimer) then
        Scheduler.unscheduleGlobal(betStateTimer)
        betStateTimer = nil
    end
    SDBOperationCtrl.HideBetState()
end

-- 114 操作下注回复
function SDBRoom.OnOperateBetScore(arg)
    if arg.code == 0 then
        if arg.data.state == 1 then
            this.HideBetStateScore()
        elseif arg.data.state == 116 then
            this.HideBetStateScore()
            Toast.Show("不该您操作")
        end
    else
        SDBOperationPanel.SetBetState(true)
    end
end

-- 115 广播下注
function SDBRoom.OnBetScore(arg)
    SDBRoomData.gameState = SDBGameState.BetState
    local data = arg.data
    local playerData = SDBRoomData.GetPlayerDataById(data.uId)
    local playerItem = playerData.item

    if not IsNil(playerData) and not IsNil(playerItem) then
        playerData.xiaZhuScore = data.paypoint
        playerData:FlyGold(function()
            playerItem:ShowBetPoints(playerData.xiaZhuScore)
        end)
        --关闭可推注显示
        SDBRoomCtrl.HideTuizhu(data.uId)
    else
        LogError("玩家playerData为nil")
    end
end

-- 127 通知玩家是否能够准备
function SDBRoom.OnNoticePlayerReady(arg)
    --判断房间号是否为空
    if SDBRoomData.roomCode == 0 then
        --房间信息错误，重新获取数据
        SDBRoom.SendNetWorkData()
        return
    end

    local data = arg.data
    if data.state == 0 then
        SDBRoomPanel.HideSitDown()
        if SDBRoomData.MainIsOwner() then
            SDBRoomPanel.PlayStartBtnMove()
        end
    elseif data.state == 1 then
        if SDBRoomData.IsGoldGame() then
            if not SDBRoomData.isCardGameStarted then
                --金币场不显示坐下按钮，只显示准备按钮
                SDBRoomPanel.ShowReadyBtn()
            end
        else
            if SDBRoomData.GetSelfIsLook() then
                --显示准备
                SDBRoomPanel.ShowReadyBtn()
            elseif SDBRoomData.GetSelfData().state == PlayerState.Stand then
                if not SDBRoomData.isHaveJieSuan and (SDBRoomData.gameState == SDBGameState.Ready or SDBRoomData.gameState == 0) then
                    if not SDBRoomData.isCardGameStarted then
                        SDBRoomPanel.ShowReadyBtn()
                    end
                end
            end
        end
    elseif data.state == 2 then
        --表示已准备
        SDBRoomPanel.HideSitDown()
    end
end

-- 128 是否正在解散
function SDBRoom.OnIsDismissRoom(arg)
    local data = arg.data
    --有解散
    if data.type == 1 then
        PanelManager.Open(SDBPanelConfig.Dismiss, data)
    else
        --没有解散  0没有
        PanelManager.Close(SDBPanelConfig.Dismiss, true)
    end
end

--更新离线问题
function SDBRoom.OnOffline(arg)
    local data = arg.data
    -- uId   state(0掉线，1在线
    local playerData = SDBRoomData.GetPlayerDataById(data.uId)
    playerData.isOffline = data.state == 0

    this.CheckResetPlayerOfflineIcon()
end

--  199 倒计时
function SDBRoom.OnGameProcess(arg)
    local data = arg.data
    SDBContentTip.UpdateData(data.type, data.time, data.oId)
end

-- 推送改变元宝数量
function SDBRoom.OnPushRoomDeductGold(arg)
    if arg.code == 0 then
        this.UpdatePlayerGold(arg.data)
    end
end

--更新玩家的元宝
--type(1支付桌费2游戏盈亏3付费表情)
function SDBRoom.UpdatePlayerGold(data)
    if data == nil or data.players == nil then
        return
    end

    local isHandleDeductGold = data.type == DeductGoldType.Game
    --玩家自己的ID，用于更新元宝
    local userId = UserData.GetUserId()
    local length = #data.players
    local temp = nil
    for i = 1, length do
        temp = data.players[i]
        local playerData = SDBRoomData.GetPlayerDataById(temp.id)
        if temp.gold ~= nil then
            if SDBRoomData.IsGoldGame() then
                playerData.playerScore = temp.gold
                if not IsNil(playerData.item) then
                    playerData.item:SetScoreText(playerData.playerScore)
                end
            end
            --更新玩家的元宝
            if temp.id == userId then
                UserData.SetGold(temp.gold)
            end
        end
    end
end


--电量设置
function SDBRoom.OnBatteryState(value)
    SDBRoomPanel.UpdateEnergyValue(value)
end

local lastPing = 0
--ping值
function SDBRoom.OnPing(arg)
    if lastPing == arg then
        return
    end
    lastPing = arg
    if arg ~= "" and not IsNil(SDBRoomPanel) then
        SDBRoomPanel.UpdateNetPing(arg)
    end
end

------------------------------------------------------------------
--开始显示庄家图标，，动画
function SDBRoom.CheckRobZhuang(RobPlayerInfos)
    Log(">>>>>>>>>>>>>>>>   RobPlayerInfos = ", RobPlayerInfos)
    if SDBRoomData.BankerPlayerId == "" then
        return
    end

    Log(">>>>>>>>>>>>>>>>   SDBRoomData.isPlayRubZhuangAni = ", SDBRoomData.isPlayRubZhuangAni)
    if not SDBRoomData.isPlayback and not SDBRoomData.isPlayRubZhuangAni and SDBFuntions.isRobBanker() then
        SDBRoomData.isPlayRubZhuangAni = true
        SDBRoomAnimator.PlayRobZhuangAni(RobPlayerInfos, SDBRoomPanel.SetBankerAniActive)
    else
        --显示庄家图标
        SDBRoomPanel.ShowZhuangImage()
        local playerData = SDBRoomData.GetPlayerDataById(SDBRoomData.BankerPlayerId)
        if playerData ~= nil then
            --显示抢庄倍数
            playerData:ShowRobZhuangMultiple()
        end
    end
end

--关闭抢庄抢几
function SDBRoom.CloseRobZhuangNum()
    for _, playerData in ipairs(SDBRoomData.playerDatas) do
        playerData:HideRobZhuangNum()
    end
end

--播放语音显示聊天气泡框
function SDBRoom.OnShowChatBubble(formId, duration, text)
    local playerItem = SDBRoomData.GetPlayerUIById(formId)
    if playerItem ~= nil then
        playerItem:ShowChatText(duration, text)
    end
end


------------------------------------------------------------------
--
--初始化聊天系统
function SDBRoom.InitChatManager()
    --初始化聊天模块
    ChatModule.Init()
    --当前游戏参数
    ChatModule.SetChatCallback(this.OnShowChatBubble)
    local config = {
        audioBundle = SDBBundleName.chat,
        textChatConfig = SDBChatLabelArr,
        languageType = LanguageType.putonghua,
    }
    ChatModule.SetChatConfig(config)
    --初始化基本信息
    ChatModule.Init(PanelConfig.RoomChat, PanelConfig.RoomUserInfo)
end

--聊天模块
--玩家数据更新
function SDBRoom.UpdateChatPlayers(playerItems)
    local players = {}
    for k, v in pairs(playerItems) do
        if IsTable(v) and not string.IsNullOrEmpty(v.playerId) and v.playerId ~= 0 then
            local playerData = SDBRoomData.GetPlayerDataById(v.playerId)
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
function SDBRoom.OnPushSystemTips(data)
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
function SDBRoom.ExitRoom()
    if SDBRoomData.isPlayback then
        SDBPlaybackMgr.Clear()
    end
    SDBRoomCtrl.ExitRoom()
end
return this