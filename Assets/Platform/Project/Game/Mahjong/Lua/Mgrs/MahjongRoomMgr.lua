--麻将房间管理
MahjongRoomMgr = {
    --是否初始化，用于标记资源准备完成
    inited = false,
    --是否游戏切换结束
    isGameSwitchEnd = false,
    --结算延迟Timer
    settlementDelayTimer = nil,
    --临时存储的操作数据
    tempOperateData = nil,
    --用于检测换张动画，防止换张动画播放出错，牌局可以进行
    checkChangeCardTimer = nil,
    --检测GPS的Timer
    checkGpsTimer = nil,
    --检测GPS的间隔时间
    checkGpsInterval = 0.9,
    --上一次检测GPS时间
    lastCheckGpsTime = 0,
    --缓存的GPS对象
    lastCacheGps = nil,
    --是否上传了Gps，根据返服务器回来设置
    isUploadGps = false,
}

local this = MahjongRoomMgr

--麻将房间初始化
function MahjongRoomMgr.Initialize()
    this.AddEventListener()
    this.AddCmdListener()
    --每次进房间都要初始
    this.isUploadGps = false
    --
    --MahjongTingHelper.Initialize()
    MahjongHelper.Initialize()
    --
    MahjongResourcesMgr.onInitCompleted = this.OnResourcesInitCompleted
    MahjongResourcesMgr.Initialize()
end

--用于小结后重置界面和数据
function MahjongRoomMgr.Reset()
    --重置房间数据
    MahjongDataMgr.Reset()
    --重置牌局数据
    MahjongPlayCardMgr.Reset()
    --重置动画
    MahjongAnimMgr.Reset()
    --重置界面显示
    if MahjongRoomPanel.Instance ~= nil then
        MahjongRoomPanel.Instance.Reset()
    end
end

--退出房间时处理
function MahjongRoomMgr.Clear()
    this.isGameSwitchEnd = false
    this.tempOperateData = nil
    this.isUploadGps = false
    this.RemoveEventListener()
    this.RemoveCmdListener()
    --资源清理
    MahjongResourcesMgr.Clear()
    --停止特效播放
    MahjongEffectMgr.Clear()
    --停止动画
    MahjongAnimMgr.Clear()
    --房间数据清理
    MahjongDataMgr.Clear()
    --回放清理
    MahjongPlaybackCardMgr.Clear()
    --打牌清理
    MahjongPlayCardMgr.Clear()
    --停止结算延迟Timer
    this.StopSettlementDelayTimer()
    --停止换牌动画的检测
    this.StopCheckChangeCardTimer()
    --停止GPS检测
    this.StopCheckGpsTimer()
    if MahjongRoomPanel.Instance ~= nil then
        MahjongRoomPanel.Instance.Clear()
    end
end

--销毁
function MahjongRoomMgr.Destroy()
    MahjongResourcesMgr.Destroy()
    MahjongEffectMgr.Destroy()
    MahjongAnimMgr.Destroy()
    MahjongPlayCardMgr.Destroy()
end

--================================================================
--添加事件监听
function MahjongRoomMgr.AddEventListener()
    --
    AddEventListener(CMD.Game.Mahjong.DeskPanelOpened, this.OnDeskPanelOpened)
    AddEventListener(CMD.Game.Mahjong.ChangeCardAnimCompleted, this.OnChangeCardAnimCompleted)
    --
    AddEventListener(CMD.Game.Reauthentication, this.OnReauthentication)
    AddEventListener(CMD.Game.OnDisconnected, this.OnDisconnected)
    AddEventListener(CMD.Game.ApplicationPause, this.OnApplicationPause)
    --更新gps信息
    AddEventListener(CMD.Game.UpdateUserGpsData, this.OnUpdateUserGpsData)
    AddEventListener(CMD.Game.UpdateUserAddress, this.OnUpdateUserAddress)
    AddEventListener(CMD.Game.UpdatePlayersGpsData, this.OnUpdatePlayersGpsData)
end

--移除事件监听
function MahjongRoomMgr.RemoveEventListener()
    RemoveEventListener(CMD.Game.Mahjong.DeskPanelOpened, this.OnDeskPanelOpened)
    RemoveEventListener(CMD.Game.Mahjong.ChangeCardAnimCompleted, this.OnChangeCardAnimCompleted)

    RemoveEventListener(CMD.Game.Reauthentication, this.OnReauthentication)
    RemoveEventListener(CMD.Game.OnDisconnected, this.OnDisconnected)
    RemoveEventListener(CMD.Game.ApplicationPause, this.OnApplicationPause)
    --
    RemoveEventListener(CMD.Game.UpdateUserGpsData, this.OnUpdateUserGpsData)
    RemoveEventListener(CMD.Game.UpdateUserAddress, this.OnUpdateUserAddress)
    RemoveEventListener(CMD.Game.UpdatePlayersGpsData, this.OnUpdatePlayersGpsData)
end

--添加协议监听
function MahjongRoomMgr.AddCmdListener()
    --注册协议超时重连
    this.AddTimeOutProtocal()
    --
    --错误提示
    AddEventListener(CMD.Tcp.Push_SystemTips, this.OnPushSystemTips)
    --扣除分数
    AddEventListener(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
    --gps地址信息相关
    AddEventListener(CMD.Tcp.S2C_Gps, this.OnGps)

    --
    --加入房间返回
    AddEventListener(CMD.Tcp.Mahjong.S2C_JoinRoom, this.OnJoinRoom)
    --玩家变动
    AddEventListener(CMD.Tcp.Mahjong.Push_PlayerData, this.OnPushPlayerData)
    --玩家在线状态
    AddEventListener(CMD.Tcp.Mahjong.Push_PlayerOnline, this.OnPushPlayerOnline)
    --准备返回
    AddEventListener(CMD.Tcp.Mahjong.S2C_Ready, this.OnReady)
    --准备推送
    AddEventListener(CMD.Tcp.Mahjong.Push_Ready, this.OnPushReady)
    --准备倒计时推送
    AddEventListener(CMD.Tcp.Mahjong.Push_ReadyCountDown, this.OnPushReadyCountDown)
    --玩家数据更新返回
    AddEventListener(CMD.Tcp.Mahjong.S2C_PlayerDataUpdate, this.OnPlayerDataUpdate)
    --玩家数据更新推送
    AddEventListener(CMD.Tcp.Mahjong.Push_PlayerDataUpdate, this.OnPushPlayerDataUpdate)
    --游戏开始推送
    AddEventListener(CMD.Tcp.Mahjong.Push_GameBegin, this.OnPushGameBegin)
    --打牌操作返回
    AddEventListener(CMD.Tcp.Mahjong.S2C_Operate, this.OnOperate)
    --打牌操作推送
    AddEventListener(CMD.Tcp.Mahjong.Push_Operate, this.OnPushOperate)
    --换牌推送
    AddEventListener(CMD.Tcp.Mahjong.Push_ChangeCard, this.OnPushChangeCard)
    --换牌推送
    AddEventListener(CMD.Tcp.Mahjong.Push_GangCanChoose, this.OnPushGangCanChoose)
    --退出房间返回
    AddEventListener(CMD.Tcp.Mahjong.S2C_QuitRoom, this.OnQuitRoom)
    --被退出房间
    AddEventListener(CMD.Tcp.Mahjong.Push_ExitRoom, this.OnPushExitRoom)
    --被踢出房间
    AddEventListener(CMD.Tcp.Mahjong.Push_KickRoom, this.OnPushKickRoom)
    --中途退出房间返回大厅
    AddEventListener(CMD.Tcp.Mahjong.S2C_BackLobby, this.OnBackLobby)
    --解散房
    AddEventListener(CMD.Tcp.Mahjong.S2C_Dismiss, this.OnDismiss)
    --解散推送
    AddEventListener(CMD.Tcp.Mahjong.Push_Dismiss, this.OnPushDismiss)
    --解散操作返回
    AddEventListener(CMD.Tcp.Mahjong.S2C_DismissOperate, this.OnDismissOperate)
    --取消托管
    AddEventListener(CMD.Tcp.Mahjong.S2C_CancelTrust, this.OnCancelTrust)
    --游戏结束推送
    AddEventListener(CMD.Tcp.Mahjong.Push_GameEnd, this.OnPushGameEnd)
    --游戏胡牌的结算推送
    AddEventListener(CMD.Tcp.Mahjong.Push_HuSettlement, this.OnPushHuSettlement)
    --比赛分数
    AddEventListener(CMD.Tcp.Mahjong.S2C_MatchScore, this.OnMatchScore)
end

--移除协议监听
function MahjongRoomMgr.RemoveCmdListener()
    --移除协议超时重连
    this.RemoveTimeOutProtocal()
    --
    RemoveEventListener(CMD.Tcp.Push_SystemTips, this.OnPushSystemTips)
    RemoveEventListener(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
    RemoveEventListener(CMD.Tcp.S2C_Gps, this.OnGps)
    --
    RemoveEventListener(CMD.Tcp.Mahjong.S2C_JoinRoom, this.OnJoinRoom)
    RemoveEventListener(CMD.Tcp.Mahjong.Push_PlayerData, this.OnPushPlayerData)
    RemoveEventListener(CMD.Tcp.Mahjong.Push_PlayerOnline, this.OnPushPlayerOnline)
    RemoveEventListener(CMD.Tcp.Mahjong.S2C_Ready, this.OnReady)
    RemoveEventListener(CMD.Tcp.Mahjong.Push_Ready, this.OnPushReady)
    RemoveEventListener(CMD.Tcp.Mahjong.Push_ReadyCountDown, this.OnPushReadyCountDown)
    RemoveEventListener(CMD.Tcp.Mahjong.S2C_PlayerDataUpdate, this.OnPlayerDataUpdate)
    RemoveEventListener(CMD.Tcp.Mahjong.Push_PlayerDataUpdate, this.OnPushPlayerDataUpdate)
    RemoveEventListener(CMD.Tcp.Mahjong.Push_GameBegin, this.OnPushGameBegin)
    RemoveEventListener(CMD.Tcp.Mahjong.S2C_Operate, this.OnOperate)
    RemoveEventListener(CMD.Tcp.Mahjong.Push_Operate, this.OnPushOperate)
    RemoveEventListener(CMD.Tcp.Mahjong.Push_ChangeCard, this.OnPushChangeCard)
    RemoveEventListener(CMD.Tcp.Mahjong.S2C_QuitRoom, this.OnQuitRoom)
    RemoveEventListener(CMD.Tcp.Mahjong.Push_ExitRoom, this.OnPushExitRoom)
    RemoveEventListener(CMD.Tcp.Mahjong.Push_KickRoom, this.OnPushKickRoom)
    RemoveEventListener(CMD.Tcp.Mahjong.S2C_BackLobby, this.OnBackLobby)
    RemoveEventListener(CMD.Tcp.Mahjong.S2C_Dismiss, this.OnDismiss)
    RemoveEventListener(CMD.Tcp.Mahjong.Push_Dismiss, this.OnPushDismiss)
    RemoveEventListener(CMD.Tcp.Mahjong.S2C_DismissOperate, this.OnDismissOperate)
    RemoveEventListener(CMD.Tcp.Mahjong.S2C_CancelTrust, this.OnCancelTrust)
    RemoveEventListener(CMD.Tcp.Mahjong.Push_GameEnd, this.OnPushGameEnd)
    RemoveEventListener(CMD.Tcp.Mahjong.S2C_MatchScore, this.OnMatchScore)
end

--添加协议超时
function MahjongRoomMgr.AddTimeOutProtocal()
    Network.RegisterTimeOutProtocal(CMD.Tcp.C2S_CheckIsInRoom, CMD.Tcp.S2C_CheckIsInRoom)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_JoinRoom, CMD.Tcp.Mahjong.S2C_JoinRoom)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_Operate, CMD.Tcp.Mahjong.S2C_Operate)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_Ready, CMD.Tcp.Mahjong.S2C_Ready)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_QuitRoom, CMD.Tcp.Mahjong.S2C_QuitRoom)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_Dismiss, CMD.Tcp.Mahjong.S2C_Dismiss)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_DismissOperate, CMD.Tcp.Mahjong.S2C_DismissOperate)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_CancelTrust, CMD.Tcp.Mahjong.S2C_CancelTrust)
end

--移除协议超时
function MahjongRoomMgr.RemoveTimeOutProtocal()
    Network.RegisterTimeOutProtocal(CMD.Tcp.C2S_CheckIsInRoom, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_JoinRoom, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_Operate, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_Ready, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_QuitRoom, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_Dismiss, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_DismissOperate, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Mahjong.C2S_CancelTrust, nil)
end

--================================================================
--资源初始化完成
function MahjongRoomMgr.OnResourcesInitCompleted()
    MahjongResourcesMgr.onInitCompleted = nil

    --麻将打牌管理初始化
    MahjongPlayCardMgr.Initialize()
    --播放麻将背景音乐
    MahjongAudioMgr.PlayBgMusic()
    --LogError(">> MahjongRoomMgr.OnResourcesInitCompleted")
    PanelManager.Open(MahjongPanelConfig.Room)
end

--重新认证上
function MahjongRoomMgr.OnReauthentication()
    --回放不进行检测房间号
    if not MahjongDataMgr.isPlayback then
        if MahjongDataMgr.IsGoldRoomInfinite() then
            --分数场必须进行房间号检测
            this.HandleCheckIsInRoom()
        else
            --房卡场、比赛场房间未结束也需要进行房间号检测
            if not MahjongDataMgr.isRoomEnd then
                this.HandleCheckIsInRoom()
            end
        end
    end
end

--Tcp断线
function MahjongRoomMgr.OnDisconnected()
    MahjongDataMgr.isCandSend = false
    ChatModule.SetIsCanSend(false)
end

--检测是否还在房间中的返回
function MahjongRoomMgr.OnCheckIsInRoomCallback(data)
    if data.code == 0 and data.data.roomId > 0 then
        MahjongDataMgr.SetRoomId(data.data.roomId)
        MahjongDataMgr.gpsType = data.data.gps
        if data.data.line ~= nil then
            --如果有线路字段，就设置下线路，便于加入房间使用
            MahjongDataMgr.serverLine = data.data.line
            if MahjongRoomPanel.Instance then
                --更新线路显示
                MahjongRoomPanel.Instance.UpdateRoomDisplay()
            end
        end
        this.JoinRoom()
    end
end

--桌面面板打开完成
function MahjongRoomMgr.OnDeskPanelOpened()
    this.inited = true
    if MahjongDataMgr.isPlayback then
        --回放没有加入房间的过程，故直接关闭Waiting
        Waiting.Hide()
        MahjongPlaybackCardMgr.BeginPlayback()
        --回放模式直接切换完成
        this.SetSwitchGameSceneEnd()
    else
        this.JoinRoom()
    end
end

--应用切出去了
function MahjongRoomMgr.OnApplicationPause(pauseStatus)
    MahjongPlayCardMgr.ApplicationPause(pauseStatus)
end

--================================================================
--
--退出房间
function MahjongRoomMgr.ExitRoom()
    local args = { gameType = GameType.Mahjong }
    if MahjongDataMgr.isPlayback then
        args.openType = DefaultOpenType.Record
        args.recordType = MahjongDataMgr.recordType
        args.playWayType = MahjongDataMgr.playWayType
        if MahjongDataMgr.recordType == 2 then
            args.groupId = MahjongDataMgr.groupId
        end
    else
        args.openType = MahjongDataMgr.roomType
        args.groupId = MahjongDataMgr.groupId
        args.playWayType = MahjongDataMgr.playWayType
    end
    GameSceneManager.SwitchGameScene(GameSceneType.Lobby, GameType.Mahjong, args)
end

--设置房间结束
function MahjongRoomMgr.SetRoomEnd()
    MahjongDataMgr.isRoomEnd = true
    MahjongDataMgr.isCandSend = false
    ChatModule.SetIsCanSend(false)
end

--检测房间结束提示
function MahjongRoomMgr.HandleCheckIsInRoom()
    MahjongCommand.SendCheckAndJoinedRoom(this.OnCheckIsInRoomCallback, this.ExitRoom)
end

--================================================================
--发送
--加入房间，第一次加入房间或者断线重连时都需要发送该协议，在资源准备完成后发送
function MahjongRoomMgr.JoinRoom()
    if this.inited then
        MahjongCommand.SendJoinRoom()
    end
end

--组装Gps面板所使用的参数对象
function MahjongRoomMgr.OpenGpsPanel(countDown)
    local data = MahjongUtil.GetGpsPanelData(countDown, this.OnGpsReadyClickCallback, this.OnGpsQuitClickCallback)
    if MahjongDataMgr.IsGoldRoom() then
        if MahjongDataMgr.settlementDataCache ~= nil then
            data.viewCallback = this.OnGpsViewClickCallback
        end
    end
    PanelManager.Open(PanelConfig.RoomGps, data)
end

--通知服务器当前gps信息
function BaseTcpApi.SendGPSToServer(adr)
    local data = {
        adr = adr, --详细地址
    }
    SendTcpMsg(CMD.Tcp.C2S_Gps_Pub, data)
end

------------------------------------------------------------------
--
--Gps界面准备按钮点击处理
function MahjongRoomMgr.OnGpsReadyClickCallback()
    --
    MahjongDataMgr.SetGameState(MahjongGameStateType.Waiting)
    --
    Log(">> Mahjong > MahjongRoomMgr.OnGpsReadyClickCallback > Reset.")
    this.Reset()
    --
    MahjongDataMgr.settlementData = nil
    --
    MahjongCommand.SendReady()
end

--Gps界面退出解散按钮点击处理
function MahjongRoomMgr.OnGpsQuitClickCallback()
    if MahjongDataMgr.IsGoldRoom() then
        if MahjongDataMgr.IsGameBegin() then
            Toast.Show("牌局已经开始...")
        else
            MahjongCommand.SendQuitRoom()
        end
    else
        if MahjongDataMgr.IsRoomBegin() then
            MahjongCommand.SendDismiss()
        else
            MahjongCommand.SendQuitRoom()
        end
    end
end

--Gps查看战绩按钮点击
function MahjongRoomMgr.OnGpsViewClickCallback()
    if MahjongDataMgr.IsGoldRoom() then
        MahjongDataMgr.settlementData = MahjongDataMgr.settlementDataCache
        PanelManager.Open(MahjongPanelConfig.SingleSettlement)
    end
end

--================================================================
--协议处理
--系统错误处理
function MahjongRoomMgr.OnPushSystemTips(data)
    --游戏已经结束，未找到房间号
    if data.code == SystemTipsErrorCode.GameOver or data.code == SystemTipsErrorCode.EmptyUser then
        --设置房间已经结束，很多关键地方在使用
        this.SetRoomEnd()
        --如果2个结算面板存在，该结算数据就会存在，故用结算数据判断
        if MahjongDataMgr.settlementData ~= nil then
            --检测结算处理
            this.CheckSettlement()
        else
            if MahjongDataMgr.IsRoomBegin() then
                Alert.Show("游戏已经结束，返回大厅", this.ExitRoom)
                Waiting.Hide()
            else
                --此错误出现在网关错误
                local tipTxt = ""
                if MahjongDataMgr.roomType == RoomType.Tea then
                    tipTxt = "匹配失败，返回大厅"
                else
                    tipTxt = "游戏已经结束，返回大厅"
                end
                Waiting.Hide()
                Alert.Show(tipTxt, this.ExitRoom)
            end
        end
    end
end

--更新服务器广播gps地址信息
function MahjongRoomMgr.OnGps(data)
    if data.code == 0 then
        this.isUploadGps = true
    end
end


--加入房间，不处理自动准备，在局数内都需要小结界面点继续
function MahjongRoomMgr.OnJoinRoom(data)
    if data.code == 0 and data.data.code == 0 then
        Waiting.ForceHide()
        this.HandleOnJoinRoom(data.data)
    else
        --加入房间失败，要退出房间
        Toast.Show("加入房间失败，自动返回大厅")
        --退出
        this.ExitRoom()
    end
end

--玩家变动推送处理
function MahjongRoomMgr.OnPushPlayerData(data)
    if data.code == 0 then
        --处理玩家数据
        MahjongDataMgr.UpdatePlayerData(data.data)
        --更新玩家显示
        if MahjongRoomPanel.Instance ~= nil then
            MahjongRoomPanel.Instance.UpdatePlayerDisplay()
            MahjongRoomPanel.Instance.UpdateChatPlayers()
        end
        --玩家有变动，只传递玩家数据
        SendEvent(CMD.Game.RoomGpsPlayerUpdate, MahjongUtil.GetGpsPanelPlayerData())
    end
end

--玩家在线状态
function MahjongRoomMgr.OnPushPlayerOnline(data)
    if data.code == 0 then
        MahjongDataMgr.UpdatePlayerOnline(data.data)
        --更新玩家显示
        if MahjongRoomPanel.Instance ~= nil then
            MahjongRoomPanel.Instance.UpdatePlayerOnline()
        end
    end
end

--准备返回
function MahjongRoomMgr.OnReady(data)
    if data.code == 0 then
        local code = data.data.code
        if code == 0 then
            --准备返回成功，播放准备音效
            MahjongAudioMgr.PlayReady()
            --准备成功，通知GPS界面
            SendEvent(CMD.Game.RoomGpsReadyFinished)
            if MahjongDataMgr.IsGoldRoom() then
                PanelManager.Close(MahjongPanelConfig.GoldSettlement)
            end
        elseif code == MahjongErrorCode.Already_Ready then
            SendEvent(CMD.Game.RoomGpsReadyFinished)
            if MahjongDataMgr.IsGoldRoom() then
                PanelManager.Close(MahjongPanelConfig.GoldSettlement)
            end
        elseif code == MahjongErrorCode.Table_Not_Ready then
            Toast.Show("当前牌局不能准备")
        elseif code == MahjongErrorCode.PlayerNum_Not_Enough then
            Toast.Show("玩家尚未坐满，不能准备")
        end
    end
end

--准备推送
function MahjongRoomMgr.OnPushReady(data)
    if data.code == 0 then
        if MahjongDataMgr.IsGoldRoom() then
            if MahjongDataMgr.isAllSeat then
                MahjongDataMgr.UpdatePlayerReady(data.data)
                if MahjongRoomPanel.Instance ~= nil then
                    --更新玩家准备
                    MahjongRoomPanel.Instance.UpdatePlayerReady()
                end
            end
        else
            MahjongDataMgr.UpdatePlayerReady(data.data)
            if MahjongRoomPanel.Instance ~= nil then
                --更新玩家准备
                MahjongRoomPanel.Instance.UpdatePlayerReady()
            end
        end
        SendEvent(CMD.Game.RoomGpsPlayerUpdate, MahjongUtil.GetGpsPanelPlayerData())
    end
end

--准备倒计时
function MahjongRoomMgr.OnPushReadyCountDown(data)
    if data.code == 0 then
        MahjongDataMgr.isAllSeat = true
        MahjongDataMgr.SetGameState(MahjongGameStateType.Waiting)
        if MahjongDataMgr.IsGoldRoom() then
            PanelManager.Close(MahjongPanelConfig.GoldSettlement)
        end
        local playerData = MahjongDataMgr.GetMainPlayerData()
        if playerData.ready ~= MahjongReadyType.Ready then
            this.OpenGpsPanel(data.data.countDown)
        end
    end
end

--玩家数据更新返回
function MahjongRoomMgr.OnPlayerDataUpdate(data)
    if data.code == 0 and data.data.code == 0 then
        --todo
    end
end

--玩家数据更新推送
function MahjongRoomMgr.OnPushPlayerDataUpdate(data)
    if data.code == 0 then
        MahjongDataMgr.UpdateDataByPlayerDataUpdate(data.data)
        SendEvent(CMD.Game.RoomGpsPlayerUpdate, MahjongUtil.GetGpsPanelPlayerData())
    end
end


--游戏开始推送
function MahjongRoomMgr.OnPushGameBegin(data)
    if data.code == 0 then
        this.HandleOnPushGameBegin(data.data)
    end
end

--操作返回
function MahjongRoomMgr.OnOperate(data)
    --收到操作返回，清除操作缓存
    MahjongPlayCardHelper.Clear()
    local code = -1
    if data.code == 0 then
        code = data.data.code
    end
    if code == 0 then
        --todo
    elseif code == MahjongErrorCode.Need_Wait then
        -- Toast.Show("等待其他玩家操作")
    else
        local error = MahjongErrorCodeMap[code]
        if error ~= nil then
            Toast.Show(error)
        end
        --失败还原牌局和操作项
        MahjongPlayCardMgr.ResumeCardsDisplay()
        this.CheckOpenOperationPanel()
    end
end

--操作推送处理
function MahjongRoomMgr.OnPushOperate(data)
    if data.code == 0 then
        this.HandleOnPushOperate(data.data)
    end
end

---换张推送
function MahjongRoomMgr.OnPushChangeCard(data)
    if data.code == 0 then
        this.HandleOnPushChangeCard(data.data)
    end
end

---通知杠牌可选
function MahjongRoomMgr.OnPushGangCanChoose(data)
    --LogError("<color=aqua>OnPushGangCanChoose</color>", data)
    if data.code == 0 then
        this.HandleOnPushGangCanChoose(data.data)
    end
end

--换牌动画完成
function MahjongRoomMgr.OnChangeCardAnimCompleted()
    Log(">> MahjongRoomMgr.OnChangeCardAnimCompleted > ", this.tempOperateData)
    this.StopCheckChangeCardTimer()
    --清除换出去的牌数据
    MahjongDataMgr.ClearChangeCardsOutData()

    if this.tempOperateData ~= nil then
        this.HandleOperateData(this.tempOperateData, true)
        this.tempOperateData = nil
    end

    if MahjongDataMgr.isPlayback then
        MahjongPlayCardMgr.UpdatePlayerCardDisplay()
        MahjongPlayCardMgr.UpdateAllPlayerBackCardByChange()
    else
        MahjongPlayCardMgr.UpdateMainPlayerBackCardByChange()
    end
end

--退出房间
function MahjongRoomMgr.OnQuitRoom(data)
    if data.code == 0 then
        local code = data.data.code
        if code == 0 then
            --收到这个协议就把房间设置结束，便于设置界面好点击退出，容错处理，在麻将Init.lua文件会进行重置
            this.SetRoomEnd()
            --
            if not PanelManager.IsOpened(PanelConfig.RoomChange) then
                if MahjongDataMgr.roomType == RoomType.Lobby and MahjongDataMgr.IsRoomOwner() then
                    Toast.Show("成功解散房间")
                else
                    Toast.Show("成功退出房间")
                end
                this.ExitRoom()
            end
        elseif code == MahjongErrorCode.Table_Already_Start then
            if MahjongDataMgr.IsGoldRoom() then
                Alert.Show("牌局已经开始")
            else
                Alert.Show("牌局已经开始，请使用解散申请")
            end
            PanelManager.Close(MahjongPanelConfig.Setup)
        end
    end
end

--被退出房间
function MahjongRoomMgr.OnPushExitRoom(data)
    if data.code == 0 then
        this.SetRoomEnd()
        if data.data.type == 2 then
            Toast.Show("房间解散，牌局结束")
        elseif data.data.type == 3 then
            Alert.Show("房间被解散，牌局结束")
        elseif data.data.type == 4 then
            if MahjongDataMgr.IsMatchRoom() then
                Alert.Show("有玩家分数不符合房间要求，比赛结束")
            else
                Alert.Show("有玩家分数不符合房间要求，房间被解散")
            end
        else
            --如果是未开局房间解散
            if MahjongDataMgr.roomType == RoomType.Lobby then
                if MahjongDataMgr.IsRoomOwner() then
                    --房主不提示
                else
                    Alert.Show("房间被解散")
                end
            else
                Alert.Show("房间被解散")
            end
        end
        --this.ExitRoom()
    end
end

--被踢出房间
function MahjongRoomMgr.OnPushKickRoom(data)
    if data.code == 0 then
        if data.data.type == 1 then
            Alert.Show("由于您未准备游戏，退出房间")
        else
            Alert.Show("您被请离房间")
        end
        this.ExitRoom()
    end
end

--返回大厅
-- Table_Not_gold = 33, --不是分数场
-- Player_Not_Hu = 34, --还没胡牌
function MahjongRoomMgr.OnBackLobby(data)
    if data.code == 0 and data.data ~= nil then
        local code = data.data.code
        if code == 0 then
            --返回大厅
            Toast.Show("成功退出房间")
            this.ExitRoom()
        elseif code == 33 then
            Alert.Show("返回大厅无效")
        elseif code == 34 then
            if MahjongDataMgr.roomId == data.data.roomId then
                if data.data.isMatch == 0 then
                    Toast.Show("牌局进行中，无法返回大厅")
                else
                    Toast.Show("牌局进行中，无法继续游戏")
                end
            end
        else
            Alert.Show("操作错误：" .. code)
        end
    end
end

--解散返回，如果牌局开始了，会收到服务器结算消息，按照结算消息处理房间的退出
function MahjongRoomMgr.OnDismiss(data)
    if data.code == 0 then
        if data.data.code == 0 then
            --关闭发起解散的面板，设置面板
            PanelManager.Close(MahjongPanelConfig.Setup)
            PanelManager.Close(PanelConfig.RoomGps)
        elseif data.data.code == 36 then
            --比赛场不能解散
            PanelManager.Close(MahjongPanelConfig.Setup)
            PanelManager.Close(PanelConfig.RoomGps)
            Toast.Show("当前游戏无法解散")
        end
    end
end

--解散推送
function MahjongRoomMgr.OnPushDismiss(data)
    if data.code == 0 then
        PanelManager.Open(MahjongPanelConfig.Dismiss, data.data)
    end
end

--解散操作返回
function MahjongRoomMgr.OnDismissOperate(data)
    if data.code == 0 then
        local code = data.data.code
        if code == MahjongErrorCode.Player_Already_Oper then
            Toast.Show("已经完成操作，请等待...")
        end
    end
end

--取消托管返回
function MahjongRoomMgr.OnCancelTrust(data)
    if data.code == 0 then
        MahjongDataMgr.UpdateMainPlayerTrust(data.data)
        if MahjongRoomPanel.Instance ~= nil then
            MahjongRoomPanel.Instance.UpdateTrustByCancel()
        end
    end
end

--语音聊天功能
function MahjongRoomMgr.OnChatSpeech(url, from, speekTime)
    ChatVoice.PlayVoice(url, from, speekTime)
end

--游戏结束
function MahjongRoomMgr.OnPushGameEnd(data)
    if data.code == 0 then
        if data.data == nil or data.data.xj == nil or #data.data.xj < 1 then
            --检测是否准备
            this.CheckIsReady()
        else
            this.HandleSettlement(data.data)
        end
    else
        this.ExitRoom()
        Alert.Show("结算数据错误，请联系客服")
    end
end

--游戏胡牌的结算
function MahjongRoomMgr.OnPushHuSettlement(data)
    this.OnPushGameEnd(data)
end

--处理扣分数
function MahjongRoomMgr.OnPushRoomDeductGold(data)
    if data.code == 0 then
        MahjongDataMgr.UpdatePlayerGold(data.data)
        if MahjongRoomPanel.Instance ~= nil then
            MahjongRoomPanel.Instance.UpdateDeductGold()
        end
    end
end

--处理比赛分数
function MahjongRoomMgr.OnMatchScore(data)
    if data.code == 0 then
        local code = data.data.code
        if code == 0 then
            if data.data.list == nil or #data.data.list < 1 then
                Toast.Show("排行数据错误")
            else
                PanelManager.Open(MahjongPanelConfig.Ranking, data.data)
            end
        elseif code == 35 then
            --不是比赛场
            Toast.Show("当前游戏无法查看")
        end
    end
end


--================================================================
--
--处理进入房间
function MahjongRoomMgr.HandleOnJoinRoom(data)
    MahjongDataMgr.isCandSend = true
    ChatModule.SetIsCanSend(true)
    --
    MahjongDataMgr.SetGameState(MahjongGameStateType.Waiting)
    --
    MahjongDataMgr.SetRoomDataByJoinRoom(data)

    if data.roomState == MahjongRoomStateType.Waiting then
        --如果牌局没开始就清除下牌局
        this.Reset()
    end

    --更新UI
    if MahjongRoomPanel.Instance ~= nil then
        --更新房间信息
        MahjongRoomPanel.Instance.UpdateRoomByJoinRoom()
    end

    if not MahjongDataMgr.isPlayback then
        --Gps相关
        GPSModule.Check()
        --每次进入房间都需要上传Gps，因为服务器是广播方式，不上传，获取不到最新的数据
        this.HandleUserGps()

        if MahjongRoomPanel.Instance ~= nil then
            --更新玩家信息
            MahjongRoomPanel.Instance.UpdateChatPlayers()
        end
        --切换游戏场景结束
        this.SetSwitchGameSceneEnd()

        --处理是否有解散状态
        if not MahjongDataMgr.isHasDismiss then
            PanelManager.Close(MahjongPanelConfig.Dismiss)
        end
        --关闭比赛结算界面
        PanelManager.Close(MahjongPanelConfig.MatchSettlement)
    end
end

--处理游戏开始数据
function MahjongRoomMgr.HandleOnPushGameBegin(data)

    MahjongDataMgr.SetGameState(MahjongGameStateType.Bengin)

    --游戏开始需要清除数据
    MahjongDataMgr.ClearByGameBegin()
    --游戏开始或者重连游戏都需要清除换牌数据
    MahjongDataMgr.ClearChangeCardsByGameBegin()
    --
    MahjongDataMgr.UpdateDataByGameBegin(data)
    --
    MahjongPlayCardMgr.UpdatePlayerCardData(data)
    --
    if MahjongRoomPanel.Instance ~= nil then
        MahjongRoomPanel.Instance.UpdateRoomByGameBegin()
    end
    --关闭分数场结算
    PanelManager.Close(MahjongPanelConfig.GoldSettlement)
    --
    this.CheckCardAndOperateDisplay(true)
    --游戏开始，通知GPS界面
    SendEvent(CMD.Game.RoomGpsReadyFinished)
    --更新打牌的玩家
    MahjongRoomMgr.UpdatePlayCard(data)
    --游戏开始，通知其他界面
    SendEvent(CMD.Game.Mahjong.GameBegin)
    --
    if not MahjongDataMgr.isPlayback then
        --设置切换游戏完成
        this.SetSwitchGameSceneEnd()
        --游戏开始需要关闭的界面
        if MahjongDataMgr.IsGoldRoom() then
            PanelManager.Close(MahjongPanelConfig.SingleSettlement)
        end
    end
end

--处理操作
function MahjongRoomMgr.HandleOnPushOperate(data)
    --在播放换牌动画中，不处理数据，把数据存下来
    if MahjongAnimMgr.isPlayingHuanAnim then
        --关闭操作界面
        PanelManager.Close(MahjongPanelConfig.Operation)
        this.tempOperateData = data
        this.StartCheckChangeCardTimer()
    else
        --Log(">> MahjongRoomMgr.OnPushOperate > HandleOperateData.")
        this.HandleOperateData(data)
    end
end

--处理换牌操作
function MahjongRoomMgr.HandleOnPushChangeCard(data)
    --回放
    if MahjongDataMgr.isPlayback then

        local playerData = MahjongDataMgr.playerDatas[MahjongSeatIndex.Seat1]
        local changeCardsOut = nil
        if playerData ~= nil then
            changeCardsOut = playerData.changeCardsOut
        end
        --换出牌是否为空
        local isOutNil = changeCardsOut == nil
        Log(">> MahjongRoomMgr.HandleOnPushChangeCard > ", isOutNil, changeCardsOut)

        --处理数据
        MahjongDataMgr.UpdateDataByChangeCard(data)

        MahjongPlayCardMgr.UpdateAllPlayerOutCardByChange()
        --更新牌数据
        MahjongPlayCardMgr.UpdatePlayerCardDataByChange(data)

        if playerData ~= nil then
            changeCardsOut = playerData.changeCardsOut
        end
        --表示第一次收到选牌了
        if isOutNil and changeCardsOut ~= nil then
            --回放的时候处理换张
            MahjongDataMgr.ClearOperation()
            MahjongDataMgr.Operation.type = nil
            --临时构造换牌的操作数据
            this.CheckOperateDisplay(MahjongOperateCode.HUAN_ZHANG)
        end

        if data.dice > 0 then
            --回放换牌动画时，关闭操作界面
            PanelManager.Close(MahjongPanelConfig.Operation)
        end
    else
        MahjongDataMgr.UpdateDataByChangeCard(data)
        MahjongPlayCardMgr.UpdateMainPlayerOutCardByChange()
    end

    if data.dice > 0 then
        --播放换牌动画时需要清除换牌中等相关状态图标
        if MahjongRoomPanel.Instance ~= nil then
            MahjongRoomPanel.Instance.ClearPlayerTableState()
        end
        --播放动画
        MahjongAnimMgr.PlayHuanAnim(data.dice, MahjongDataMgr.changeCardType, MahjongDataMgr.playerTotal, MahjongDataMgr.changeCardTotal)
    end
end

---处理杠牌可选
---@field p1 number 第一张牌
---@field p2 number 第二张牌
function MahjongRoomMgr.HandleOnPushGangCanChoose(data)
    MahjongDataMgr.LastShowCard1 = MahjongDataMgr.GetCardData(data.p1)
    MahjongDataMgr.LastShowCard2 = MahjongDataMgr.GetCardData(data.p2)
    MahjongRoomPanel.Instance.UpdateLastShowCard(MahjongDataMgr.LastShowCard1.key, MahjongDataMgr.LastShowCard2.key)
end

--================================================================
--
--检测打牌玩家在线情况
function MahjongRoomMgr.CheckPlayCardOnline(data)
    if data.type ~= nil and data.type == MahjongOperateCode.CHU_PAI then
        if data.id ~= nil then
            local playerData = MahjongDataMgr.GetPlayerDataById(data.id)
            --不在托管中，且出牌了，更新下在线状态
            if playerData.trust ~= 1 then
                playerData.online = 1
                if MahjongRoomPanel.Instance ~= nil then
                    MahjongRoomPanel.Instance.UpdatePlayerOnlineByIndex(playerData.seatIndex)
                end
            end
        end
    end
end

--更新打牌的玩家和箭头
function MahjongRoomMgr.UpdatePlayCard(data)
    if MahjongRoomPanel.Instance == nil then
        return
    end

    local length = #data.players
    local playCardPlayerId = nil
    local tempData = nil
    for i = 1, length do
        tempData = data.players[i]
        --玩家有摸的牌，就为打牌的玩家，大于1的牌都表示有牌
        if tempData ~= nil and tempData.state ~= MahjongOperateState.Hu then
            if tempData.right > 0 then
                --表示该玩家有手牌
                playCardPlayerId = tempData.id
                break
            elseif tempData.state == MahjongOperateState.Play then
                --如果玩家状态是打牌，那么肯定指向他
                playCardPlayerId = tempData.id
                break
            end
        end
    end

    --LogError("playCardPlayerId",playCardPlayerId)
    --再处理打牌或者操作的玩家
    if playCardPlayerId == nil and data.id > 0 then
        playCardPlayerId = data.id
    end
    --LogError("data.id",data.id)
    --回放不要倒计时
    if MahjongDataMgr.isPlayback == false then
        if playCardPlayerId ~= nil then
            local playerData = MahjongDataMgr.GetPlayerDataById(playCardPlayerId)

            local time = 10
            --分数娱乐场使用服务器倒计时
            if MahjongDataMgr.moneyType == MoneyType.Gold then
                time = tonumber(data.opTime)
                if time == nil then
                    time = 90
                end
            end

            MahjongRoomPanel.Instance.UpdateTimePoint(playerData.seatIndex, time)
        end
    end

    MahjongRoomPanel.Instance.UpdateOutCardArrow(data.type, data.id, data.card)
end

--设置切换完成
function MahjongRoomMgr.SetSwitchGameSceneEnd()
    Log(">> MahjongRoomMgr.SetSwitchGameSceneEnd > this.isGameSwitchEnd = ", this.isGameSwitchEnd)
    if this.isGameSwitchEnd == false then
        this.isGameSwitchEnd = true
        --通知游戏场景管理器房间打开完成
        GameSceneManager.SwitchGameSceneEnd(GameSceneType.Room)
    end
end

--检测是否准备
function MahjongRoomMgr.CheckIsReady()
    --房间开始，且游戏没开始，且玩家1没准备，发送准备
    if MahjongDataMgr.IsRoomBegin() and not MahjongDataMgr.IsGameBegin() then
        local playerData = MahjongDataMgr.GetMainPlayerData()
        if playerData.ready ~= MahjongReadyType.Ready then
            MahjongCommand.SendReady()
        end
    end
end

--处理操作数据
function MahjongRoomMgr.HandleOperateData(data, isUpdateDisplay)
    --LogError("UpdateDataByOperate")
    MahjongDataMgr.UpdateDataByOperate(data)
    --LogError("UpdatePlayerCardData")
    MahjongPlayCardMgr.UpdatePlayerCardData(data)
    --
    if MahjongRoomPanel.Instance ~= nil then
        --LogError("UpdateRoomByOperate")
        MahjongRoomPanel.Instance.UpdateRoomByOperate()
    end
    --更新牌局的显示
    --LogError("CheckCardAndOperateDisplay")
    this.CheckCardAndOperateDisplay(isUpdateDisplay)
    --
    --LogError("HandleOperateEffect")
    this.HandleOperateEffect(data)
    --
    if not MahjongDataMgr.isPlayback then
        --检测打牌玩家在线
        --LogError("CheckPlayCardOnline")
        MahjongRoomMgr.CheckPlayCardOnline(data)
    end
    --更新打牌的玩家
    --LogError("UpdatePlayCard")
    MahjongRoomMgr.UpdatePlayCard(data)
end

--
--检测主玩家的操作是否打开操作面板
function MahjongRoomMgr.CheckOpenOperationPanel()
    if MahjongDataMgr.Operation.state ~= MahjongOperatePanelState.None then
        PanelManager.Open(MahjongPanelConfig.Operation)
    else
        --关闭操作界面
        PanelManager.Close(MahjongPanelConfig.Operation)
    end
end

--检测主玩家的操作显示
function MahjongRoomMgr.CheckOperateDisplay(playbackOpType)
    if MahjongDataMgr.isPlayback then
        --Log(">> MahjongRoomMgr.CheckOperateDisplay > Operation.type", MahjongDataMgr.Operation.type)
        --如果外部是换张，则直接不处理，因为换张有单独的协议处理
        if MahjongDataMgr.Operation.type == MahjongOperateCode.HUAN_ZHANG then
            this.CheckOpenOperationPanel()
        else
            --Log(">> MahjongRoomMgr.CheckOperateDisplay > ", playbackOpType)
            if playbackOpType ~= nil then
                --处理换牌操作
                MahjongDataMgr.Operation.playerId = MahjongDataMgr.userId
                MahjongDataMgr.Operation.type = playbackOpType
            end

            --处理是否为下一步播放，上一步播放不处理手指动画
            local temp = MahjongPlaybackCardMgr.isPlayNextStep
            --判断操作是否是自己操作的
            temp = temp and (MahjongDataMgr.userId == MahjongDataMgr.Operation.playerId)
            --
            if temp and MahjongPlaybackCardMgr.CheckPlaybackOperate(MahjongDataMgr.Operation.type) then
                SendEvent(CMD.Game.Mahjong.PlaybackOperate)
            else
                this.CheckOpenOperationPanel()
            end
        end
    else
        --操作检测
        if MahjongPlayCardHelper.CheckExistOperation(MahjongDataMgr.Operation.data) then
            MahjongPlayCardHelper.RepeatSendOperation()
        else
            this.CheckOpenOperationPanel()
        end
    end
end

--检测牌和操作的显示
function MahjongRoomMgr.CheckCardAndOperateDisplay(isUpdateDisplay)
    --检测主玩家的操作显示
    this.CheckOperateDisplay()

    local playerCardData = MahjongPlayCardMgr.playerCardDatas[MahjongSeatIndex.Seat1]

    if MahjongPlayCardHelper.CheckExistPlayCard(playerCardData.midCards, playerCardData.rightCard) then
        MahjongPlayCardHelper.RepeatSendPlayCard()
    else
        if isUpdateDisplay == true then
            --直接更新
            MahjongPlayCardMgr.UpdatePlayerCardDisplay()
        elseif not MahjongPlayCardMgr.IsInitCardDisplay() then
            --没有初始化显示，就直接更新
            MahjongPlayCardMgr.UpdatePlayerCardDisplay()
        else
            --状态为换张，则是回放就需要更新
            if MahjongDataMgr.gameState == MahjongGameStateType.ChangeCard then
                if MahjongDataMgr.isPlayback then
                    MahjongPlayCardMgr.UpdatePlayerCardDisplay()
                end
            else
                --如果是定缺中就不更新牌局显示，因为会刷新掉换下来的牌
                if MahjongDataMgr.tableState == MahjongPlayerTableState.DingQue then
                    --1号玩家
                    local playerData = MahjongDataMgr.playerDatas[MahjongSeatIndex.Seat1]
                    --回放才处理换牌
                    if MahjongDataMgr.isPlayback then
                        if playerData ~= nil and playerData.changeCardsBack ~= nil then
                            MahjongPlayCardMgr.UpdatePlayerCardDisplay()
                            --回放时才更新牌的换回处理，正常打牌靠动画完成处理
                            MahjongPlayCardMgr.UpdateAllPlayerBackCardByChange()
                        end
                    else
                        --容错处理，如果定缺的显示牌跟数据牌不同就需要更新，防止换牌重连的时候换出去的没有更新
                        local newCards = MahjongPlayCardMgr.CheckPlayerNewHandCards(MahjongSeatIndex.Seat1, playerCardData.midCards, playerCardData.rightCard)
                        Log(">> MahjongRoomMgr.CheckCardAndOperateDisplay > newCards > ", newCards)
                        if newCards ~= nil then
                            local length = #newCards
                            if length > 0 then
                                --有差异就更新
                                MahjongPlayCardMgr.UpdatePlayerCardDisplay()
                            end
                            if length == 3 or length == 4 then
                                --如果是换回牌，就处理显示
                                local temp = {}
                                for i = 1, length do
                                    table.insert(temp, newCards[i].id)
                                end

                                if playerData ~= nil then
                                    playerData.changeCardsBack = temp
                                end
                                MahjongPlayCardMgr.UpdateMainPlayerBackCardByChange()
                            end
                        end
                    end
                else
                    MahjongPlayCardMgr.UpdatePlayerCardDisplay()
                end
            end
        end
    end
end

--处理操作特效、音效
function MahjongRoomMgr.HandleOperateEffect(data)
    if data.type == nil then
        return
    end
    local playerId = data.id
    --出牌
    if data.type == MahjongOperateCode.CHU_PAI then
        --处理出牌音效，回放没有模拟出牌，所以需要播放音效
        if MahjongDataMgr.isPlayback or playerId ~= MahjongDataMgr.userId then
            if data.card ~= nil then
                local cardData = MahjongDataMgr.GetCardData(data.card)
                MahjongPlayCardMgr.PlayCardSound(playerId, cardData.key)
            end
        end
    elseif MahjongEffectMgr.CheckIsOperateEffect(data.type) then
        local playerData = MahjongDataMgr.GetPlayerDataById(playerId)
        --语言
        local language = nil
        --获取玩家座位
        local seatIndex = playerData.seatIndex
        --特殊处理
        local special = nil
        --是否胡牌
        local isHu = false

        local tempOperateCode = data.type
        if data.type == MahjongOperateCode.HU then
            --胡牌
            isHu = true
            --该处的胡牌类型，需要处理
            if playerData.huType ~= MahjongHuEffectsType.Hu then
                tempOperateCode = 1000 + playerData.huType
            end

            --主玩家特殊胡牌后才播放特殊胡牌特效，其他玩家不播
            if playerId == MahjongDataMgr.userId and playerData.specialHuEffect ~= nil then
                tempOperateCode = 1000 + playerData.specialHuEffect
                if tempOperateCode > 1002 and not PanelManager.IsOpened(MahjongPanelConfig.HuEffect) then
                    PanelManager.Open(MahjongPanelConfig.HuEffect)
                end
            end

            --处理自摸关3家的语音处理
            if playerData.huType == MahjongHuEffectsType.ZiMo and MahjongDataMgr.playerTotal == 4 then
                if playerData.huIndex == 1 and playerData.gender == Global.GenderType.Male then
                    special = "m_zimo_guansanjia"
                end
            end
        end
        --操作语音
        if special ~= nil then
            MahjongAudioMgr.PlayAudio(special)
        else
            MahjongAudioMgr.PlayOperateSound(playerData.gender, tempOperateCode, language, special)
        end

        --播放特效
        MahjongEffectMgr.PlayOperateEffect(tempOperateCode, seatIndex, isHu)
    end
end

--================================================================
--
--处理结算信息
function MahjongRoomMgr.HandleSettlement(data)
    --不是同一个房间的数据不处理
    if data.id ~= MahjongDataMgr.roomId then
        Alert.Show("结算数据错误，请联系客服")
        return
    end

    MahjongDataMgr.settlementData = data
    MahjongDataMgr.settlementDataCache = data
    --关闭操作界面
    PanelManager.Close(MahjongPanelConfig.Operation)

    if data.roomState == MahjongRoomStateType.Settlement or data.roomState == MahjongRoomStateType.End then
        --收到结算的数据表示小局结束
        MahjongDataMgr.SetGameState(MahjongGameStateType.End)
    end

    --如果收到结算信息为游戏结束，关闭解散界面等
    if data.roomState == MahjongRoomStateType.End then
        --关闭界面
        PanelManager.Close(MahjongPanelConfig.Setup)
        --设置房间结束
        this.SetRoomEnd()
        --单局结算时，去掉所有超时，防止最后一局，最后一手有多人同时操作，其他人操作时房间结束了，服务器无法返回协议
        Network.ClearProtocalSendTime()
    else
        MahjongDataMgr.isRoomEnd = false
    end

    --分数场直接弹出分数结算面板
    if MahjongDataMgr.IsGoldRoom() then
        if MahjongDataMgr.IsMatchRoom() then
            --LogError("<color=aqua>1111111111111</color>")
            if not MahjongDataMgr.isRoomEnd then
                --比赛场最后一局不显示分数结算面板
                PanelManager.Open(MahjongPanelConfig.GoldSettlement)
            end
        else
            --开启分数场的结算面板
            --PanelManager.Open(MahjongPanelConfig.GoldSettlement)
            --
            --LogError("<color=aqua>2222222222222</color>")
            MahjongDataMgr.settlementData = MahjongDataMgr.settlementDataCache
            PanelManager.Open(MahjongPanelConfig.SingleSettlement)
            if data.roomState == MahjongRoomStateType.Settlement then
                --牌局结束，清除准备信息，便于打开准备相关界面
                MahjongDataMgr.ClearPlayerReady()
            else
                --如果不是小局结束，就不处理后续
                return
            end
        end
    end


    --正常牌局结束才处理，打开结算面板
    if MahjongPlayCardMgr.IsInitCardDisplay() then
        --启动结算界面延迟计时器
        this.StartSettlementDelayTimer(1.2)
        --设置牌局数据
        MahjongPlayCardMgr.UpdatePlayerCardDataBySettlement(data.xj)
        --显示牌局
        MahjongPlayCardMgr.UpdatePlayerCardDisplay(true)
        --播放流局特效
        if data.endState == MahjongEndState.LiuJu then
            MahjongEffectMgr.PlayEffect(MahjongEffectMgr.EffectName.LiuJu, 0, false)
        end
    else
        --如果是重新进入APP，则等待时间不需要那么久，也不更新桌子牌局显示
        this.StartSettlementDelayTimer(0.2)
    end
end

--启动结算延迟计时器
function MahjongRoomMgr.StartSettlementDelayTimer(delayTime)
    if this.settlementDelayTimer == nil then
        this.settlementDelayTimer = Timing.New(this.OnSettlementDelayTimer, delayTime)
    end
    this.settlementDelayTimer:Restart()
end

--停止结算延迟计时器
function MahjongRoomMgr.StopSettlementDelayTimer()
    if this.settlementDelayTimer ~= nil then
        this.settlementDelayTimer:Stop()
        this.settlementDelayTimer = nil
    end
end

--显示小结面板
function MahjongRoomMgr.OnSettlementDelayTimer()
    this.StopSettlementDelayTimer()
    if MahjongDataMgr.isRoomEnd then
        PanelManager.Close(MahjongPanelConfig.Dismiss)
    end

    if MahjongDataMgr.IsGoldRoom() then
        if MahjongDataMgr.IsMatchRoom() then
            if MahjongDataMgr.isRoomEnd then
                PanelManager.Open(MahjongPanelConfig.MatchSettlement)
            end
        else
            --分数场如果小结界面打开的话刷新下，否则不处理
            if PanelManager.IsOpened(MahjongPanelConfig.SingleSettlement) then
                PanelManager.Open(MahjongPanelConfig.SingleSettlement)
            end
        end
    else
        if MahjongDataMgr.settlementIndex ~= MahjongDataMgr.settlementData.index then
            --打开过相同局数的小结，就不在打开
            PanelManager.Open(MahjongPanelConfig.SingleSettlement)
        else
            --小结面板没有打开才进行这样的处理
            if not PanelManager.IsOpened(MahjongPanelConfig.SingleSettlement) then
                --房间数据为nil或者房间结束
                if (MahjongDataMgr.settlementData == nil or MahjongDataMgr.settlementData.roomState == MahjongRoomStateType.End) and not MahjongDataMgr.isPlayback then
                    PanelManager.Open(MahjongPanelConfig.TotalSettlement)
                else
                    --检测下是否准备
                    this.CheckIsReady()
                end
            end
        end
        --更新分数
        if MahjongDataMgr.settlementData ~= nil then
            MahjongDataMgr.UpdateDataBySettlement(MahjongDataMgr.settlementData)
            if MahjongRoomPanel.Instance ~= nil then
                MahjongRoomPanel.Instance.UpdatePlayerScoreDisplay()
            end
        end
    end

    --牌局未开始，不重置，防止房间内重连，自动准备牌局开始
    if not MahjongDataMgr.IsGameBegin() then
        Log(">> Mahjong > MahjongRoomMgr.OnSettlementDelayTimer > Reset.")
        this.Reset()
    end
end

--检测结算
function MahjongRoomMgr.CheckSettlement()
    --结算数据存在
    if MahjongDataMgr.settlementData == nil then
        return
    end
    --如果Timer在运行，则不进行下一步检测
    if this.settlementDelayTimer ~= nil and this.settlementDelayTimer.running == true then
        return
    end
    if PanelManager.IsOpened(MahjongPanelConfig.TotalSettlement) then
        return
    end
    if PanelManager.IsOpened(MahjongPanelConfig.SingleSettlement) then
        return
    end

    if MahjongDataMgr.IsGoldRoom() then
        --
    else
        if MahjongDataMgr.settlementIndex ~= MahjongDataMgr.settlementData.index then
            --打开过相同局数的小结，就不在打开
            PanelManager.Open(MahjongPanelConfig.SingleSettlement)
        else
            --小结面板没有打开才进行这样的处理
            if not PanelManager.IsOpened(MahjongPanelConfig.SingleSettlement) then
                --房间数据为nil或者房间结束
                if (MahjongDataMgr.settlementData == nil or MahjongDataMgr.settlementData.roomState == MahjongRoomStateType.End) and not MahjongDataMgr.isPlayback then
                    PanelManager.Open(MahjongPanelConfig.TotalSettlement)
                else
                    --检测下是否准备
                    this.CheckIsReady()
                end
            end
        end
    end

end

--================================================================
--
--启动检测换牌动画
function MahjongRoomMgr.StartCheckChangeCardTimer()
    if this.checkChangeCardTimer == nil then
        this.checkChangeCardTimer = Timing.New(this.OnStopCheckChangeCardTimer, 6)
        this.checkChangeCardTimer:Start()
    end
end

--停止检测换牌动画
function MahjongRoomMgr.StopCheckChangeCardTimer()
    if this.checkChangeCardTimer ~= nil then
        this.checkChangeCardTimer:Stop()
        this.checkChangeCardTimer = nil
    end
end

--处理检测
function MahjongRoomMgr.OnStopCheckChangeCardTimer()
    if MahjongAnimMgr.isPlayingHuanAnim ~= false then
        MahjongAnimMgr.StopHuanAnim()
    end
    this.OnChangeCardAnimCompleted()
end

--================================================================
--
--启动检测GPS
function MahjongRoomMgr.StartCheckGpsTimer()
    --编辑器不处理GPS
    if Application.platform == RuntimePlatform.WindowsEditor then
        return
    end
    --回放不处理GPS
    if MahjongDataMgr.isPlayback then
        return
    end
    if this.checkGpsTimer == nil then
        this.checkGpsTimer = Timing.New(this.OnCheckGpsTimer, 1)
    end
    this.checkGpsTimer:Restart()
    this.CheckAndGetGps()
end

--停止检测GPS
function MahjongRoomMgr.StopCheckGpsTimer()
    if this.checkGpsTimer ~= nil then
        this.checkGpsTimer:Stop()
        this.checkGpsTimer = nil
    end
    this.checkGpsInterval = 0.9
    this.lastCheckGpsTime = 0
    this.lastCacheGps = nil
end

--处理检测GPS
function MahjongRoomMgr.OnCheckGpsTimer()
    if Time.realtimeSinceStartup - this.lastCheckGpsTime > this.checkGpsInterval then
        this.lastCheckGpsTime = Time.realtimeSinceStartup
        this.CheckAndGetGps()
    end
end

--获取GPS
function MahjongRoomMgr.CheckAndGetGps()
    GpsHelper.Check(this.OnCheckAndGetGpsCompleted)
end

--获取GPS返回
function MahjongRoomMgr.OnCheckAndGetGpsCompleted(lat, lng)
    Log(">> MahjongRoomMgr.OnCheckAndGetGpsCompleted > ", lat, lng)
    if lat ~= 0 and lng ~= 0 then
        --成功
        this.checkGpsInterval = 60
        if MahjongDataMgr.isCandSend then
            this.lastCacheGps = nil
            MahjongCommand.SendPlayerDataUpdate(lng, lat)
            local temp = { lng = lng, lat = lat }
            --更新数据
            MahjongDataMgr.UpdateMainPlayerGps(temp)
            --分派GPS更新事件
            SendEvent(CMD.Game.RoomGpsPlayerUpdate, MahjongUtil.GetGpsPanelPlayerData())
        else
            this.lastCacheGps = { lng = lng, lat = lat }
        end
    else
        if MahjongDataMgr.IsRoomBegin() then
            --房间开始后，间隔调整
            this.checkGpsInterval = 60
        else
            this.checkGpsInterval = this.checkGpsInterval + 0.5
            if this.checkGpsInterval > 4 then
                this.checkGpsInterval = 4.5
            end
        end
    end
end

--================================================================
--
--处理检测GPS数据
function MahjongRoomMgr.OnUpdateUserGpsData()
    if not MahjongDataMgr.isPlayback then
        this.HandleUserGps()
    end
end

--处理检测GPS数据
function MahjongRoomMgr.OnUpdateUserAddress()
    if not MahjongDataMgr.isPlayback then
        this.HandleUserGps()
    end
end

--更新玩家的GPS信息
function MahjongRoomMgr.OnUpdatePlayersGpsData()
    if not MahjongDataMgr.isPlayback then
        SendEvent(CMD.Game.RoomGpsPlayerUpdate, MahjongUtil.GetGpsPanelPlayerData())
    end
end

--处理GPS数据
function MahjongRoomMgr.HandleUserGps()
    local location = UserData.GetLocation()

    --更新数据
    GPSModule.UpdatePlayerData(MahjongDataMgr.userId, location.lat, location.lng, location.address)
    --分派GPS更新事件
    SendEvent(CMD.Game.RoomGpsPlayerUpdate, MahjongUtil.GetGpsPanelPlayerData())
    --上传到服务器
    MahjongCommand.SendGps(location.lng, location.lat, location.address)

end

--================================================================
--
