--房间管理
TpRoomMgr = {
    --是否初始化，用于标记资源准备完成
    inited = false,
    --是否进入房间
    isEnterRoom = false,
    --是否游戏切换结束
    isGameSwitchEnd = false,
    --结算延迟Timer
    settlementDelayTimer = nil,
    --临时存储的操作数据
    tempOperateData = nil,
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

local this = TpRoomMgr

--房间初始化
function TpRoomMgr.Initialize()
    this.AddEventListener()
    this.AddCmdListener()
    --每次进房间都要初始
    this.isUploadGps = false
    --
    TpResourcesMgr.onInitCompleted = this.OnResourcesInitCompleted
    TpResourcesMgr.Initialize()
end

--用于小结后重置界面和数据
function TpRoomMgr.Reset()
    --重置房间数据
    TpDataMgr.Reset()
    --重置动画
    TpAnimMgr.Reset()
    --重置界面显示
    if TpRoomPanel.Instance ~= nil then
        TpRoomPanel.Instance.Reset()
    end
end

--退出房间时处理
function TpRoomMgr.Clear()
    this.inited = false
    this.isEnterRoom = false
    this.isGameSwitchEnd = false
    this.tempOperateData = nil
    this.isUploadGps = false
    this.RemoveEventListener()
    this.RemoveCmdListener()
    --资源清理
    TpResourcesMgr.Clear()
    --停止特效播放
    TpEffectMgr.Clear()
    --停止动画
    TpAnimMgr.Clear()
    --房间数据清理
    TpDataMgr.Clear()
    --回放清理
    TpPlaybackCardMgr.Clear()
    --停止结算延迟Timer
    this.StopSettlementDelayTimer()
    if TpRoomPanel.Instance ~= nil then
        TpRoomPanel.Instance.Clear()
    end
end

--销毁
function TpRoomMgr.Destroy()
    TpResourcesMgr.Destroy()
    TpEffectMgr.Destroy()
    TpAnimMgr.Destroy()
end

--================================================================
--添加事件监听
function TpRoomMgr.AddEventListener()
    AddEventListener(CMD.Game.Tp.DeskPanelOpened, this.OnDeskPanelOpened)
    --
    AddEventListener(CMD.Game.Reauthentication, this.OnReauthentication)
    AddEventListener(CMD.Game.OnDisconnected, this.OnDisconnected)
    AddEventListener(CMD.Game.ApplicationPause, this.OnApplicationPause)
end

--移除事件监听
function TpRoomMgr.RemoveEventListener()
    RemoveEventListener(CMD.Game.Tp.DeskPanelOpened, this.OnDeskPanelOpened)
    --
    RemoveEventListener(CMD.Game.Reauthentication, this.OnReauthentication)
    RemoveEventListener(CMD.Game.OnDisconnected, this.OnDisconnected)
    RemoveEventListener(CMD.Game.ApplicationPause, this.OnApplicationPause)
end

--添加协议监听
function TpRoomMgr.AddCmdListener()
    --注册协议超时重连
    this.AddTimeOutProtocal()
    --
    --错误提示
    AddEventListener(CMD.Tcp.Push_SystemTips, this.OnPushSystemTips)
    --扣除分数
    AddEventListener(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
    --
    --加入房间
    AddEventListener(CMD.Tcp.Tp.S2C_JoinRoom, this.OnJoinRoom)
    --退出房间
    AddEventListener(CMD.Tcp.Tp.S2C_QuitRoom, this.OnQuitRoom)
    --进入游戏推送游戏信息
    AddEventListener(CMD.Tcp.Tp.Push_Game, this.OnPushGame)
    --玩家变动
    AddEventListener(CMD.Tcp.Tp.Push_PlayerData, this.OnPushPlayerData)
    --推送游戏状态
    AddEventListener(CMD.Tcp.Tp.Push_GameStatus, this.OnPushGameStatus)
    --推送游戏开始倒计时
    AddEventListener(CMD.Tcp.Tp.Push_GameStartCountdown, this.OnPushGameStartCountdown)
    --准备推送
    AddEventListener(CMD.Tcp.Tp.Push_Ready, this.OnPushReady)
    --打牌操作推送
    AddEventListener(CMD.Tcp.Tp.Push_Operate, this.OnPushOperate)
    --推送结算信息
    AddEventListener(CMD.Tcp.Tp.Push_SingleSettlement, this.OnPushSingleSettlement)
    --退出房间
    AddEventListener(CMD.Tcp.Tp.Push_ExitRoom, this.OnPushExitRoom)
    --通知玩家操作
    AddEventListener(CMD.Tcp.Tp.Push_PlayerOperate, this.OnPushPlayerOperate)
    --通知玩家发手牌
    AddEventListener(CMD.Tcp.Tp.Push_PlayerDeal, this.OnPushPlayerDeal)
    --推送总结算信息
    AddEventListener(CMD.Tcp.Tp.Push_TotalSettlement, this.OnPushTotalSettlement)
    --玩家请求加入游戏回复
    AddEventListener(CMD.Tcp.Tp.S2C_JoinGame, this.OnJoinGame)
    --请求坐下返回
    AddEventListener(CMD.Tcp.Tp.S2C_SitDown, this.OnSitDown)
    --解散推送
    AddEventListener(CMD.Tcp.Tp.Push_Dismiss, this.OnPushDismiss)
end

--移除协议监听
function TpRoomMgr.RemoveCmdListener()
    --移除协议超时重连
    this.RemoveTimeOutProtocal()
    --
    RemoveEventListener(CMD.Tcp.Push_SystemTips, this.OnPushSystemTips)
    RemoveEventListener(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
    --
    RemoveEventListener(CMD.Tcp.Tp.S2C_JoinRoom, this.OnJoinRoom)
    RemoveEventListener(CMD.Tcp.Tp.S2C_QuitRoom, this.OnQuitRoom)
    RemoveEventListener(CMD.Tcp.Tp.Push_Game, this.OnPushGame)
    RemoveEventListener(CMD.Tcp.Tp.Push_PlayerData, this.OnPushPlayerData)
    RemoveEventListener(CMD.Tcp.Tp.Push_GameStatus, this.OnPushGameStatus)
    RemoveEventListener(CMD.Tcp.Tp.Push_GameStartCountdown, this.OnPushGameStartCountdown)
    RemoveEventListener(CMD.Tcp.Tp.Push_Ready, this.OnPushReady)
    RemoveEventListener(CMD.Tcp.Tp.Push_Operate, this.OnPushOperate)
    RemoveEventListener(CMD.Tcp.Tp.Push_SingleSettlement, this.OnPushSingleSettlement)
    RemoveEventListener(CMD.Tcp.Tp.Push_ExitRoom, this.OnPushExitRoom)
    RemoveEventListener(CMD.Tcp.Tp.Push_PlayerOperate, this.OnPushPlayerOperate)
    RemoveEventListener(CMD.Tcp.Tp.Push_PlayerDeal, this.OnPushPlayerDeal)
    RemoveEventListener(CMD.Tcp.Tp.Push_TotalSettlement, this.OnPushTotalSettlement)
    RemoveEventListener(CMD.Tcp.Tp.S2C_JoinGame, this.OnJoinGame)
    RemoveEventListener(CMD.Tcp.Tp.S2C_SitDown, this.OnSitDown)
    RemoveEventListener(CMD.Tcp.Tp.Push_Dismiss, this.OnPushDismiss)
end

--添加协议超时
function TpRoomMgr.AddTimeOutProtocal()
    Network.RegisterTimeOutProtocal(CMD.Tcp.C2S_CheckIsInRoom, CMD.Tcp.S2C_CheckIsInRoom)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_JoinRoom, CMD.Tcp.Tp.Push_Game)--请求加入房间，服务器推送的是PushGame协议
    Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_JoinGame, CMD.Tcp.Tp.S2C_JoinGame)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_Operate, CMD.Tcp.Tp.Push_Operate)
    --Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_Ready, CMD.Tcp.Tp.S2C_Ready)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_QuitRoom, CMD.Tcp.Tp.S2C_QuitRoom)
    --Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_Dismiss, CMD.Tcp.Tp.S2C_Dismiss)
    --Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_DismissOperate, CMD.Tcp.Tp.S2C_DismissOperate)
end

--移除协议超时
function TpRoomMgr.RemoveTimeOutProtocal()
    Network.RegisterTimeOutProtocal(CMD.Tcp.C2S_CheckIsInRoom, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_JoinRoom, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_JoinGame, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_Operate, nil)
    -- Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_Ready, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_QuitRoom, nil)
    -- Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_Dismiss, nil)
    -- Network.RegisterTimeOutProtocal(CMD.Tcp.Tp.C2S_DismissOperate, nil)
end

--================================================================
--资源初始化完成
function TpRoomMgr.OnResourcesInitCompleted()
    TpResourcesMgr.onInitCompleted = nil
    --播放背景音乐
    --TpAudioMgr.PlayBgMusic()
    LogError(">> TpRoomMgr.OnResourcesInitCompleted")
    PanelManager.Open(TpPanelConfig.Operation)
    PanelManager.Open(TpPanelConfig.Room)
end

--重新认证上
function TpRoomMgr.OnReauthentication()
    --回放不进行检测房间号
    if not TpDataMgr.isPlayback then
        if TpDataMgr.IsGoldRoomInfinite() then
            --分数场必须进行房间号检测
            this.HandleCheckIsInRoom()
        else
            --房卡场、比赛场房间未结束也需要进行房间号检测
            if not TpDataMgr.isRoomEnd then
                this.HandleCheckIsInRoom()
            end
        end
    end
end

--Tcp断线
function TpRoomMgr.OnDisconnected()
    TpDataMgr.isCanSend = false
    ChatModule.SetIsCanSend(false)
end

--检测是否还在房间中的返回
function TpRoomMgr.OnCheckIsInRoomCallback(data)
    if data.code == 0 and data.data.roomId > 0 then
        TpDataMgr.SetRoomId(data.data.roomId)
        TpDataMgr.gpsType = data.data.gps
        if data.data.line ~= nil then
            --如果有线路字段，就设置下线路，便于加入房间使用
            TpDataMgr.serverLine = data.data.line
            if TpRoomPanel.Instance then
                --更新线路显示
                TpRoomPanel.Instance.UpdateRoomDisplay()
            end
        end
        this.JoinRoom()
    end
end

--桌面面板打开完成
function TpRoomMgr.OnDeskPanelOpened()
    this.inited = true
    if TpDataMgr.isPlayback then
        --回放没有加入房间的过程，故直接关闭Waiting
        Waiting.Hide()
        TpPlaybackCardMgr.BeginPlayback()
        --回放模式直接切换完成
        this.SetSwitchGameSceneEnd()
    else
        this.JoinRoom()
    end
end

--应用切出去了
function TpRoomMgr.OnApplicationPause(pauseStatus)

end

--================================================================

--退出房间
function TpRoomMgr.ExitRoom()
    local args = { gameType = GameType.Tp }
    if TpDataMgr.isPlayback then
        args.openType = DefaultOpenType.Record
        args.recordType = TpDataMgr.recordType
        args.playWayType = TpDataMgr.playWayType
        if TpDataMgr.recordType == 2 then
            args.groupId = TpDataMgr.groupId
        end
    else
        args.openType = TpDataMgr.roomType
        args.groupId = TpDataMgr.groupId
        args.playWayType = TpDataMgr.playWayType
    end
    GameSceneManager.SwitchGameScene(GameSceneType.Lobby, GameType.Tp, args)
end

--设置房间结束
function TpRoomMgr.SetRoomEnd()
    TpDataMgr.isRoomEnd = true
    TpDataMgr.isCanSend = false
    ChatModule.SetIsCanSend(false)
end

--检测房间结束提示
function TpRoomMgr.HandleCheckIsInRoom()
    TpCommand.SendCheckAndJoinedRoom(this.OnCheckIsInRoomCallback, this.ExitRoom)
end

--================================================================
--发送
--加入房间，第一次加入房间或者断线重连时都需要发送该协议，在资源准备完成后发送
function TpRoomMgr.JoinRoom()
    if this.inited then
        TpCommand.SendJoinRoom()
    end
end

--组装Gps面板所使用的参数对象
function TpRoomMgr.OpenGpsPanel(countDown)
    local data = TpUtil.GetGpsPanelData(countDown, this.OnGpsReadyClickCallback, this.OnGpsQuitClickCallback)
    if TpDataMgr.IsGoldRoom() then
        if TpDataMgr.settlementDataCache ~= nil then
            data.viewCallback = this.OnGpsViewClickCallback
        end
    end
    PanelManager.Open(PanelConfig.RoomGps, data)
end

------------------------------------------------------------------
--
--Gps界面准备按钮点击处理
function TpRoomMgr.OnGpsReadyClickCallback()
    --
    Log(">> Tp > TpRoomMgr.OnGpsReadyClickCallback > Reset.")
    this.Reset()
    --
    TpDataMgr.settlementData = nil
    --
    TpCommand.SendReady()
end

--Gps界面退出解散按钮点击处理
function TpRoomMgr.OnGpsQuitClickCallback()
    if TpDataMgr.IsGoldRoom() then
        if TpDataMgr.IsGameBegin() then
            Toast.Show("牌局已经开始...")
        else
            TpCommand.SendQuitRoom()
        end
    else
        if TpDataMgr.IsRoomBegin() then
            TpCommand.SendDismiss()
        else
            TpCommand.SendQuitRoom()
        end
    end
end

--Gps查看战绩按钮点击
function TpRoomMgr.OnGpsViewClickCallback()
    if TpDataMgr.IsGoldRoom() then
        TpDataMgr.settlementData = TpDataMgr.settlementDataCache
        PanelManager.Open(TpPanelConfig.SingleSettlement)
    end
end

--================================================================
--协议处理
--系统错误处理
function TpRoomMgr.OnPushSystemTips(data)
    --游戏已经结束，未找到房间号
    if data.code == SystemTipsErrorCode.GameOver or data.code == SystemTipsErrorCode.EmptyUser then
        --设置房间已经结束，很多关键地方在使用
        this.SetRoomEnd()
        --如果2个结算面板存在，该结算数据就会存在，故用结算数据判断
        if TpDataMgr.settlementData ~= nil then
            --检测结算处理
            this.CheckSettlement()
        else
            if TpDataMgr.IsRoomBegin() then
                Alert.Show("游戏已经结束，返回大厅", this.ExitRoom)
                Waiting.Hide()
            else
                --此错误出现在网关错误
                local tipTxt = ""
                if TpDataMgr.roomType == RoomType.Tea then
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
function TpRoomMgr.OnGps(data)
    if data.code == 0 then
        this.isUploadGps = true
    end
end

--加入房间，不处理自动准备，在局数内都需要小结界面点继续
function TpRoomMgr.OnJoinRoom(data)
    LogError("加入房间返回")
end

--进入游戏推送游戏信息，就是调用JoinRoom返回
function TpRoomMgr.OnPushGame(data)
    LogError(">> TpRoomMgr.OnPushGame", data)
    if data.code == 0 then
        Waiting.ForceHide()
        this.HandleOnPushGame(data.data)
    else
        --加入房间失败，要退出房间
        Alert.Show("加入房间失败，自动返回大厅")
        --退出
        this.ExitRoom()
    end
end

--玩家数据更新推送
-- opType 	1.加入房间，
--         2.退出房间，数据只有玩家id和座位号
-- 		3.上线离线，只有玩家id和座位号和在线状态)
-- 		4.房主切换
-- pId 玩家id
-- sNum 座位号 
-- 如果opType是1，加入房间
-- 	name 名字
-- 	img   头像
-- 	sex   性别
-- 	gold   金币
-- 	isg   下的芒
-- 	itg   下注 
-- 	io   是否在线
-- 如果opType是3，上线离线
-- 	io   是否在线
-- 如果opType是4，
-- 	"isOwner", 1
function TpRoomMgr.OnPushPlayerData(data)
    LogError(">> TpRoomMgr.OnPushPlayerData", data)
    if data.code == 0 then
        this.HandleOnPushPlayerData(data.data)
    end
end

--推送游戏状态
function TpRoomMgr.OnPushGameStatus(data)
    LogError(">> TpRoomMgr.OnPushGameStatus", data)
    if data.code == 0 then
        this.HandleOnPushGameStatus(data.data)
    end
end


--准备推送
function TpRoomMgr.OnPushReady(data)
    LogError(">> TpRoomMgr.OnPushReady", data)
    if data.code == 0 then
        this.HandleOnPushReady(data.data)
    else
        TpUtil.ShowErrorTips(data.code)
    end
end


--推送游戏开始倒计时
function TpRoomMgr.OnPushGameStartCountdown(data)
    LogError(">> TpRoomMgr.OnPushGameStartCountdown", data)
    if data.code == 0 then
        TpDataMgr.gameStartCountdown = data.data.second + Time.realtimeSinceStartup
    end
end

--准备倒计时
function TpRoomMgr.OnPushReadyCountDown(data)
    if data.code == 0 then
        -- local playerData = TpDataMgr.GetMainPlayerData()
        -- if playerData.ready ~= TpReadyType.Ready then
        --     this.OpenGpsPanel(data.data.countDown)
        -- end
    end
end

--玩家数据更新返回
function TpRoomMgr.OnPlayerDataUpdate(data)
    if data.code == 0 and data.data.code == 0 then
        --todo
    end
end


--操作推送处理
function TpRoomMgr.OnPushOperate(data)
    LogError(">> TpRoomMgr.OnPushOperate", data)
    if data.code == 0 then
        this.HandleOnPushOperate(data.data)
    else
        TpUtil.ShowErrorTips(data.code)
    end
end

--推送结算信息
function TpRoomMgr.OnPushSingleSettlement(data)
    LogError(">> TpRoomMgr.OnPushSingleSettlement", data)
    if data.code == 0 then
        this.HandleOnPushSingleSettlement(data.data)
    end
end


--推送总结算信息
function TpRoomMgr.OnPushTotalSettlement(data)
    LogError(">> TpRoomMgr.OnPushTotalSettlement", data)
    if data.code == 0 then
        this.HandleOnPushTotalSettlement(data.data)
    end
end

--玩家请求加入游戏回复
function TpRoomMgr.OnJoinGame(data)
    LogError(">> TpRoomMgr.OnJoinGame", data)
    if data.code == 0 then
        TpDataMgr.UpdateJoinGame(data.data)
    else
        TpUtil.ShowErrorTips(data.code)
    end
end

--请求坐下返回
function TpRoomMgr.OnSitDown(data)
    LogError(">> TpRoomMgr.OnSitDown", data)
    if data.code == 0 then
        this.HandleSitDown(data.data)
    else
        TpUtil.ShowErrorTips(data.code)
    end
end

--退出房间
function TpRoomMgr.OnQuitRoom(data)
    LogError(">> TpRoomMgr.OnQuitRoom", data)
    if data.code == 0 then
    end
end

--被退出房间
--type 离开类型 type:1主动退出2被踢出3房间解散4金币不足被踢出5游戏结束
function TpRoomMgr.OnPushExitRoom(data)
    LogError(">> TpRoomMgr.OnPushExitRoom", data)
    if data.code == 0 then
        this.SetRoomEnd()
        local type = data.data.type
        if type == 2 then
            Alert.Show("您被踢出房间")
            this.ExitRoom()
        elseif type == 3 then
            Alert.Show("房间被解散，牌局结束")
            this.ExitRoom()
        elseif type == 4 then
            Alert.Show("由于您分数不足，被踢出房间")
            this.ExitRoom()
        elseif type == 5 then
            Alert.Show("游戏结束，退出房间")
            this.ExitRoom()
        else
            Toast.Show("已退出房间")
            this.ExitRoom()
        end
    else
        TpUtil.ShowErrorTips(data.code)
    end
end

--通知玩家操作
function TpRoomMgr.OnPushPlayerOperate(data)
    LogError(">> TpRoomMgr.OnPushPlayerOperate", data)
    if data.code == 0 then
        this.HandlePushPlayerOperate(data.data)
    end
end

--通知玩家发手牌
function TpRoomMgr.OnPushPlayerDeal(data)
    LogError(">> TpRoomMgr.OnPushPlayerDeal", data)
    if data.code == 0 then
        this.HandlePushPlayerDeal(data.data)
    end
end


--解散推送
function TpRoomMgr.OnPushDismiss(data)
    LogError(">> TpRoomMgr.OnPushDismiss", data)
    if data.code == 0 then
        PanelManager.Open(TpPanelConfig.Dismiss, data.data)
    end
end

--语音聊天功能
function TpRoomMgr.OnChatSpeech(url, from, speekTime)
    ChatVoice.PlayVoice(url, from, speekTime)
end

--处理扣分数
function TpRoomMgr.OnPushRoomDeductGold(data)
    -- if data.code == 0 then
    --     TpDataMgr.UpdatePlayerGold(data.data)
    --     if TpRoomPanel.Instance ~= nil then
    --         TpRoomPanel.Instance.UpdateDeductGold()
    --     end
    -- end
end

--================================================================
--
--处理进入游戏推送游戏信息
--{"cmd":105000,"code":0,"data":{"zhuangId":0,"startAt":0,"opId":0,"rules":
--{"BS":0.2,"NP":3,"ZOU_MANG":0,"ZR":100,"MAX_NUM":8,"XIU_MANG":1,"START_NUM":2,"JSFS":10,"WF":1,"CRT":2,
-- "SHOUSHOU_MANG":1,"GAME_TIME":20},"gameStatus":1,"ownerId":0,"needGold":"0.2","betPool":0,
-- "playerMsg":[{"pId":302060,"isg":"0","io":1,"pIds":{},"sNum":1,"ir":0,"gu":0,"sex":1,"img":"22","is":0,"pIdsX":{},"ps":0,"gold":"702380.09","itg":"0","il":0,"name":"01外","ijg":0}],
-- "totalCD":6,"mangPool":0,"countDown":4,"roomId":431153,"nowjs":1,"mang":0.4,"isStartGame":0}}
function TpRoomMgr.HandleOnPushGame(data)
    TpDataMgr.isCanSend = true
    ChatModule.SetIsCanSend(true)
    TpDataMgr.UpdateRoomDataByEnterGame(data)
    --更新UI
    if TpRoomPanel.Instance ~= nil then
        TpRoomPanel.Instance.UpdateDisplayByEnterGame()
    end
    SendEvent(CMD.Game.Tp.OperateCheck)

    if not TpDataMgr.isPlayback then
        --切换游戏场景结束
        this.SetSwitchGameSceneEnd()
    end
    --SendEvent(CMD.Game.RoomGpsPlayerUpdate, TpUtil.GetGpsPanelPlayerData())
end

--处理玩家变动推送处理
-- 1.加入房间，
-- 2.退出房间，数据只有玩家id和座位号
-- 3.上线离线，只有玩家id和座位号和在线状态)
-- 4.房主切换
-- pId 玩家id
-- sNum 座位号 
-- 如果opType是1，加入房间
-- 	name 名字
-- 	img   头像
-- 	sex   性别
-- 	gold   金币
-- 	io   是否在线

-- 如果opType是3，上线离线
-- 	io   是否在线
-- 如果opType是4，
-- 	"isOwner", 1
function TpRoomMgr.HandleOnPushPlayerData(data)
    --收到进入游戏协议后才处理玩家数据
    if TpDataMgr.isEnterGame then
        if data.opType == 1 then
            --新进玩家
            TpDataMgr.UpdatePlayerDataByAdd(data)
        elseif data.opType == 2 then
            --玩家离开
            TpDataMgr.UpdatePlayerDataByDelete(data.pId)
        elseif data.opType == 3 then
            --更新在线情况
            TpDataMgr.UpdateSinglePlayerOnline(data)
        elseif data.opType == 4 then
            --更新房主
            TpDataMgr.UpdateOwner(data)
        end
        --更新玩家显示
        if TpRoomPanel.Instance ~= nil then
            TpRoomPanel.Instance.UpdatePlayerDisplay()
        end
        SendEvent(CMD.Game.Tp.OperateCheck)
    end
end


--处理推送游戏状态
function TpRoomMgr.HandleOnPushGameStatus(data)
    TpDataMgr.UpdateRoomDataByGameStatus(data)
    if TpRoomPanel.Instance ~= nil then
        TpRoomPanel.Instance.UpdateDisplayByGameStatus()
    end
    SendEvent(CMD.Game.Tp.OperateCheck)
end

--处理准备
function TpRoomMgr.HandleOnPushReady(data)
    TpDataMgr.UpdatePlayerReady(data)
    if TpRoomPanel.Instance ~= nil then
        TpRoomPanel.Instance.UpdatePlayerReadyDisplay()
    end
    SendEvent(CMD.Game.Tp.OperateCheck)
    --SendEvent(CMD.Game.RoomGpsPlayerUpdate, TpUtil.GetGpsPanelPlayerData())
end

--处理操作
-- opType 操作类型
-- pId 玩家id
-- gold 金币  

-- opType跟注或者加注时
-- 	itg 下注
-- 	isg  下的芒果
-- 	needGold 下注最小
-- 	betPool 下注池
-- 	mangPool 芒池
-- opType 为亮牌时
-- 	pIds 牌 
--玩家操作广播
-- opType 为扯牌时  POKER_SEPT = 3
--    pIdsX 数组 分好的牌组
function TpRoomMgr.HandleOnPushOperate(data)
    TpDataMgr.UpdateDataByOperate(data)
    if TpRoomPanel.Instance ~= nil then
        TpRoomPanel.Instance.UpdateDisplayByOperate()
    end
    --SendEvent(CMD.Game.Tp.OperateCheck)--玩家操作后的数据，不需要通知操作界面
    this.CheckOperateDisplay(data)
end


--检测主玩家的操作显示
function TpRoomMgr.CheckOperateDisplay(data)
    if TpDataMgr.isPlayback then
        local opPlayerId = data.pId

        local opType = data.opType
        --Log(">> TpRoomMgr.CheckOperateDisplay > ", opPlayerId, opType)
        --弃牌不是玩家操作的，要给一个提示
        if opType == TpOperateType.GiveUp and data.isUser == 0 then
            local playerData = TpDataMgr.GetPlayerDataById(opPlayerId)
            Toast.Show("玩家【%s】超时自动弃牌", playerData.name)
        end

        --处理是否为下一步播放，上一步播放不处理手指动画
        local temp = TpPlaybackCardMgr.isPlayNextStep

        --判断操作是否是自己操作的
        temp = temp and (TpDataMgr.userId == opPlayerId)
        --
        if temp and TpPlaybackCardMgr.CheckPlaybackOperate(opType) then
            SendEvent(CMD.Game.Tp.PlaybackOperate, opType, data.ig)
        end
    end
end


--处理单个结算数据
function TpRoomMgr.HandleOnPushSingleSettlement(data)
    TpDataMgr.UpdateDataBySingleSettlement(data)
    if TpRoomPanel.Instance ~= nil then
        TpRoomPanel.Instance.UpdateDisplayBySingleSettlement()
    end
end

--处理总结算数据
function TpRoomMgr.HandleOnPushTotalSettlement(data)
    TpDataMgr.settlementData = data
    this.StartSettlementDelayTimer()
end

--处理坐下
function TpRoomMgr.HandleSitDown(data)
    PanelManager.CheckClose(TpPanelConfig.Take)
    TpDataMgr.SetSitDown(true)
    if TpRoomPanel.Instance ~= nil then
        TpRoomPanel.Instance.UpdateDisplayBySitDown()
    end
end

--处理坐下
function TpRoomMgr.HandlePushAward(data)
    PanelManager.Open(TpPanelConfig.BigWin, data)
end

--处理通知玩家操作
function TpRoomMgr.HandlePushPlayerOperate(data)
    TpDataMgr.operateId = data.pId
    TpDataMgr.opList = data.opList
    --通知操作界面
    SendEvent(CMD.Game.Tp.OperateCheck)
end

--处理通知玩家发牌
function TpRoomMgr.HandlePushPlayerDeal(data)
    TpDataMgr.UpdateDataByDeal(data)
    if TpRoomPanel.Instance ~= nil then
        TpRoomPanel.Instance.UpdateDisplayByDeal()
    end
end


--================================================================
--

--设置切换完成
function TpRoomMgr.SetSwitchGameSceneEnd()
    Log(">> TpRoomMgr.SetSwitchGameSceneEnd > this.isGameSwitchEnd = ", this.isGameSwitchEnd)
    if this.isGameSwitchEnd == false then
        this.isGameSwitchEnd = true
        --通知游戏场景管理器房间打开完成
        GameSceneManager.SwitchGameSceneEnd(GameSceneType.Room)
    end
end

--================================================================
--

--启动结算延迟计时器
function TpRoomMgr.StartSettlementDelayTimer()
    if this.settlementDelayTimer == nil then
        this.settlementDelayTimer = Timing.New(this.OnSettlementDelayTimer, 2)
    end
    this.settlementDelayTimer:Restart()
end

--停止结算延迟计时器
function TpRoomMgr.StopSettlementDelayTimer()
    if this.settlementDelayTimer ~= nil then
        this.settlementDelayTimer:Stop()
    end
end

--显示结算面板
function TpRoomMgr.OnSettlementDelayTimer()
    this.StopSettlementDelayTimer()
    PanelManager.Open(TpPanelConfig.TotalSettlement)
end

--检测结算
function TpRoomMgr.CheckSettlement()
    --如果Timer在运行，则不进行下一步检测
    if this.settlementDelayTimer ~= nil and this.settlementDelayTimer.running == true then
        return
    end
    if PanelManager.IsOpened(TpPanelConfig.TotalSettlement) then
        return
    end
    --结算数据存在
    PanelManager.Open(TpPanelConfig.TotalSettlement)
end

--================================================================
--
--启动检测GPS
function TpRoomMgr.StartCheckGpsTimer()
    --编辑器不处理GPS
    if Application.platform == RuntimePlatform.WindowsEditor then
        return
    end
    --回放不处理GPS
    if TpDataMgr.isPlayback then
        return
    end
    if this.checkGpsTimer == nil then
        this.checkGpsTimer = Timing.New(this.OnCheckGpsTimer, 1)
    end
    this.checkGpsTimer:Restart()
    this.CheckAndGetGps()
end

--停止检测GPS
function TpRoomMgr.StopCheckGpsTimer()
    if this.checkGpsTimer ~= nil then
        this.checkGpsTimer:Stop()
        this.checkGpsTimer = nil
    end
    this.checkGpsInterval = 0.9
    this.lastCheckGpsTime = 0
    this.lastCacheGps = nil
end

--处理检测GPS
function TpRoomMgr.OnCheckGpsTimer()
    if Time.realtimeSinceStartup - this.lastCheckGpsTime > this.checkGpsInterval then
        this.lastCheckGpsTime = Time.realtimeSinceStartup
        this.CheckAndGetGps()
    end
end

--获取GPS
function TpRoomMgr.CheckAndGetGps()
    GpsHelper.Check(this.OnCheckAndGetGpsCompleted)
end

--获取GPS返回
function TpRoomMgr.OnCheckAndGetGpsCompleted(lat, lng)
    Log(">> TpRoomMgr.OnCheckAndGetGpsCompleted > ", lat, lng)
    if lat ~= 0 and lng ~= 0 then
        --成功
        this.checkGpsInterval = 60
        if TpDataMgr.isCanSend then
            this.lastCacheGps = nil
            TpCommand.SendPlayerDataUpdate(lng, lat)
            local temp = { lng = lng, lat = lat }
            --更新数据
            TpDataMgr.UpdateMainPlayerGps(temp)
            --分派GPS更新事件
            SendEvent(CMD.Game.RoomGpsPlayerUpdate, TpUtil.GetGpsPanelPlayerData())
        else
            this.lastCacheGps = { lng = lng, lat = lat }
        end
    else
        if TpDataMgr.IsRoomBegin() then
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
function TpRoomMgr.OnUpdateUserGpsData()
    if not TpDataMgr.isPlayback then
        this.HandleUserGps()
    end
end

--处理检测GPS数据
function TpRoomMgr.OnUpdateUserAddress()
    if not TpDataMgr.isPlayback then
        this.HandleUserGps()
    end
end

--更新玩家的GPS信息
function TpRoomMgr.OnUpdatePlayersGpsData()
    if not TpDataMgr.isPlayback then
        SendEvent(CMD.Game.RoomGpsPlayerUpdate, TpUtil.GetGpsPanelPlayerData())
    end
end

--处理GPS数据
function TpRoomMgr.HandleUserGps()
    local location = UserData.GetLocation()

    --更新数据
    GPSModule.UpdatePlayerData(TpDataMgr.userId, location.lat, location.lng, location.address)
    --分派GPS更新事件
    SendEvent(CMD.Game.RoomGpsPlayerUpdate, TpUtil.GetGpsPanelPlayerData())
    --上传到服务器
    TpCommand.SendGps(location.lng, location.lat, location.address)

end

--================================================================
--
