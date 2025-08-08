BattleModule = {}
local this = BattleModule

BattleModule.uid = ""
BattleModule.headIcon = ""
BattleModule.userName = ""
BattleModule.sex = 0
BattleModule.isPlayback = false         --是否是回放
BattleModule.playbackData = false         --是否是回放
BattleModule.playbackAutoPlay = false         --是否自动播放回放
BattleModule.roomId = 0
BattleModule.clubId = 0
BattleModule.teaId = 0
BattleModule.roomType = RoomType.Lobby    --RoomType：定义
BattleModule.lastRulesStr = nil--服务器发来的数据转换的字符串，用于换桌
BattleModule.rules = nil           --格式{EqsRuleType = vale, ......}
BattleModule.parsedRules = nil           --格式{playWayName = "", juShu = 0, juShuTxt = "", rule = ""}
BattleModule.userInfoCtrls = nil           --EqsUserInfoCtrl对象存储
BattleModule.curUserNum = 0             --房间当前人数
BattleModule.userNum = 0             --房间总人数
BattleModule.curJuShu = 0             --当前局数
BattleModule.operations = nil           --自己能操作的所有操作项  {"id2":522,"targetId":521,"id3":0,"from":2,"id1":511,"oper":46}的数组
BattleModule.port = 0             --端口
BattleModule.yuCardUid = {}            --雨牌的唯一ID
BattleModule.isStarted = false         --游戏是否开始
BattleModule.isSelectingHsz = false         --是否是选择换三张牌过程中
BattleModule.isReinitBattle = false         --是否是重新初始化，用于区分断线重连时游戏内重连和杀死进程重连，初始化后界面设为false
BattleModule.zongJieSuanData = nil           --总结算数据(单局结算推了后，马上推总结算)
BattleModule.prepareDaoJiShi = 30            --所有玩家加入房间后的准备倒计时
BattleModule.danJuJieSuanCardPositions = nil    --单局结算所有牌的位置
BattleModule.isEnd = false                      --牌局是否结束
BattleModule.historyChat = {}                   --语音聊天历史记录(只记录本地) 里面存{type:value}  type:0 文本 此时value是string   type：1 语音 此时value是Url
BattleModule.hasChuPai = false                  --是否已经出牌
BattleModule.isDisconnect = false
BattleModule.moneyType = MoneyType.Fangka
BattleModule.curCircle = 0  --当前圈数
BattleModule.playbackTime = 0
BattleModule.isPerform772 = false
BattleModule.isUploadGps = false
BattleModule.tingPaiIds = nil
--战绩回放类型 1大厅战绩回放   2亲友圈战绩回放
BattleModule.recordType = 0
function BattleModule.Init(args)
    this.Uninit()
    this.uid = UserData.GetUserId()
    this.roomId = UserData.GetRoomId()
    this.headIcon = UserData.GetHeadUrl()
    this.userName = UserData.GetName()
    this.sex = UserData.GetGender()
    this.port = args.line
    this.isEnd = false
    this.moneyType = args.moneyType
    this.roomType = args.roomType
    this.playbackTime = args.time
    this.recordType = args.recordType
    if this.recordType == nil then
        this.recordType = 1
    end
    if IsBool(args.isPlayback) then
        this.uid = args.userId
        this.isPlayback = args.isPlayback
        this.playbackData = args.playbackData
    else
        this.isPlayback = false
        this.isPlayback = false
    end

    Log("初始化Module数据：", this.uid, this.roomId, this.headIcon, this.userName, this.sex, args)
    this.AddMsgs()

    this.InitChatManager()

    Network.RegisterTimeOutProtocal(CMD.Tcp.C2S_JoinedRoom, CMD.Tcp.S2C_GetRoomData)
    Network.RegisterTimeOutProtocal(CMD.Tcp.C2S_Operation772, CMD.Tcp.S2C_Operation772)
    Network.RegisterTimeOutProtocal(CMD.Tcp.C2S_UserPrepare, CMD.Tcp.S2C_ChangeStatus)
end

function BattleModule.Uninit()
    this.RemoveMsgs()
    this.uid = ""
    this.headIcon = ""
    this.userName = ""
    this.sex = 0
    this.isPlayback = false
    this.playbackAutoPlay = false
    this.roomId = 0
    this.clubId = 0
    this.teaId = 0
    this.roomType = RoomType.Lobby
    this.lastRulesStr = nil
    this.rules = nil
    this.userInfoCtrls = nil
    this.curUserNum = 0
    this.userNum = 0
    this.curJuShu = 0
    this.operations = nil
    this.yuCardUid = {}
    this.isStarted = false
    this.isSelectingHsz = false
    this.isReinitBattle = false
    this.zongJieSuanData = nil
    this.prepareDaoJiShi = 0
    this.isEnd = false
    this.isUploadGps = false
    this.lastGpsAddress = nil
    this.danJuJieSuanCardPositions = {}
    this.ClearYuCardUids()
    this.SetIsPerform772(false)
    ChatModule.UnInit()
    this.SetIsDisconnected(false)

    Scheduler.unscheduleGlobal(EqsBattleCtrl.autoPlaySchedule)

    Network.RegisterTimeOutProtocal(CMD.Tcp.C2S_JoinedRoom, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.C2S_Operation772, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.C2S_UserPrepare, nil)
end

function BattleModule.SetIsPerform772(is)
    this.isPerform772 = is
    --  Log(".................. SetIsPerform772", is)
end

function BattleModule.SetIsDisconnected(bool)
    this.isDisconnect = bool
    if IsTable(ChatModule) then
        ChatModule.SetIsCanSend(not this.isDisconnect)
    end
end

function BattleModule.AddMsgs()
    AddMsg(CMD.Tcp.S2C_GetRoomData, this.OnCmdGetRoomData)
    AddMsg(CMD.Tcp.S2C_Operation772, this.OnCmdOperationResult)
    AddMsg(CMD.Tcp.S2C_UserOperation773, this.OnCmdOperation)
    AddMsg(CMD.Tcp.S2C_UserCards, this.OnCmdGetUserCards)
    AddMsg(CMD.Tcp.S2C_ChangeStatus, this.OnCmdChangeStatus)
    AddMsg(CMD.Tcp.S2C_QuitRoom, this.OnCmdQuitRoom)
    AddMsg(CMD.Tcp.S2C_JieShanRoom, this.OnTcpJieShanRoom)
    AddMsg(CMD.Tcp.S2C_TouPiaoJieShanRoom, this.OnCmdTouPiaoJieShanRoom)
    AddMsg(CMD.Game.Ping, this.OnGamePing)
    AddMsg(CMD.Tcp.S2C_Broadcast, this.OnTcpBroadcast)
    AddMsg(CMD.Tcp.S2C_DanJuJieSuan, this.OnTcpDanJuJieSuan)
    AddMsg(CMD.Tcp.S2C_UpdateRoomData, this.OnTcpUpdateRoomInfoForNextJu)
    AddMsg(CMD.Tcp.S2C_ZongJieSuan, this.OnTcpZongJieSuan)
    AddMsg(CMD.Game.Reauthentication, this.OnGameConnected)
    AddMsg(CMD.Game.OnDisconnected, this.OnGameDisconnected)
    AddMsg(CMD.Tcp.Push_SystemTips, this.OnTcpSystemTips)
    AddMsg(CMD.Game.BatteryState, this.OnBatteryState)--监听语音事件
    AddMsg(CMD.Tcp.S2C_Notice, this.OnTcpNotice)
    AddMsg(CMD.Tcp.S2C_ServerJieShanRoom, this.OnTcpServerJieShanRoom)
    AddMsg(CMD.Game.ApplicationPause, this.OnGameAppPause)
    AddMsg(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
    AddMsg(CMD.Tcp.S2C_AutoPlay, this.OnTcpAutoPlay)
    AddMsg(CMD.Game.HandleQuickMatch, this.OnTeaQucikMatchError)
    AddMsg(CMD.Game.UpdateUserGpsData, this.OnUpdateUserGpsData)
    AddMsg(CMD.Game.UpdateUserAddress, this.OnUpdateUserAddress)
    AddMsg(CMD.Game.UpdatePlayersGpsData, this.OnUpdatePlayersGpsData)
    AddMsg(CMD.Tcp.S2C_Gps, this.OnGps)
end

function BattleModule.RemoveMsgs()
    RemoveMsg(CMD.Tcp.S2C_GetRoomData, this.OnCmdGetRoomData)
    RemoveMsg(CMD.Tcp.S2C_Operation772, this.OnCmdOperationResult)
    RemoveMsg(CMD.Tcp.S2C_UserOperation773, this.OnCmdOperation)
    RemoveMsg(CMD.Tcp.S2C_UserCards, this.OnCmdGetUserCards)
    RemoveMsg(CMD.Tcp.S2C_ChangeStatus, this.OnCmdChangeStatus)
    RemoveMsg(CMD.Tcp.S2C_QuitRoom, this.OnCmdQuitRoom)
    RemoveMsg(CMD.Tcp.S2C_JieShanRoom, this.OnTcpJieShanRoom)
    RemoveMsg(CMD.Tcp.S2C_TouPiaoJieShanRoom, this.OnCmdTouPiaoJieShanRoom)
    RemoveMsg(CMD.Game.Ping, this.OnGamePing)
    RemoveMsg(CMD.Tcp.S2C_Broadcast, this.OnTcpBroadcast)
    RemoveMsg(CMD.Tcp.S2C_DanJuJieSuan, this.OnTcpDanJuJieSuan)
    RemoveMsg(CMD.Tcp.S2C_UpdateRoomData, this.OnTcpUpdateRoomInfoForNextJu)
    RemoveMsg(CMD.Tcp.S2C_ZongJieSuan, this.OnTcpZongJieSuan)
    RemoveMsg(CMD.Game.OnConnected, this.OnGameConnected)
    RemoveMsg(CMD.Game.OnDisconnected, this.OnGameDisconnected)
    RemoveMsg(CMD.Tcp.Push_SystemTips, this.OnTcpSystemTips)
    RemoveMsg(CMD.Game.Reauthentication, this.OnGameConnected)
    RemoveMsg(CMD.Game.BatteryState, this.OnBatteryState)
    RemoveMsg(CMD.Tcp.S2C_Notice, this.OnTcpNotice)
    RemoveMsg(CMD.Tcp.S2C_ServerJieShanRoom, this.OnTcpServerJieShanRoom)
    RemoveMsg(CMD.Game.ApplicationPause, this.OnGameAppPause)
    RemoveMsg(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
    RemoveMsg(CMD.Game.HandleQuickMatch, this.OnTeaQucikMatchError)
    RemoveMsg(CMD.Game.UpdataAddress, this.OnGamePushAddress)
    RemoveMsg(CMD.Game.UpdateUserGpsData, this.OnUpdateUserGpsData)
    RemoveMsg(CMD.Game.UpdateUserAddress, this.OnUpdateUserAddress)
    RemoveMsg(CMD.Game.UpdatePlayersGpsData, this.OnUpdatePlayersGpsData)
    RemoveMsg(CMD.Tcp.S2C_Gps, this.OnGps)
end

function BattleModule.InitRoom(data)
    EqsConfig.CheckRules(data.rules)
    Waiting.ForceHide()
    this.roomId = data.roomId
    this.clubId = data.clubId
    this.teaId = data.teaId
    this.curJuShu = data.juShu
    this.lastRulesStr = ObjToJson(data.rules)
    this.rules = data.rules
    this.curUserNum = GetTableSize(data.users)
    this.userNum = this.GetRule(EqsRuleType.RoomNum)
    this.isStarted = data.started
    this.curCircle = data.circle

    this.parsedRules = Functions.ParseGameRule(GameType.ErQiShi, data.rules, this.rules[EqsRuleType.Gps], " ")
    if this.IsFkFlowRoom() then
        if data.isJs == false then
            PanelManager.Close(EqsPanels.JieShanRoom)
        end
    end

    if this.clubId == nil then
        this.clubId = 0
    end

    if this.teaId == nil then
        this.teaId = 0
    end
    this.isOpenTingPai = this.GetRule(EqsRuleType.TingPaiTiShi) == 1
    LogError("<color=aqua>data</color>", data)
    this.userInfoCtrls = EqsBattleCtrl.InitRoomInfo(data)
    for k, userCtrl in pairs(this.userInfoCtrls) do
        userCtrl:SetStatus(userCtrl.status)
    end
    SendEvent(CMD.Game.RoomGpsPlayerUpdate, this.GetGpsUserData())

    --获取GPS
    GPSModule.Check()
    this.HandleUserGps()
end

function BattleModule.IsRecommendCardid(id)
    if IsTable(this.tingPaiIds) then
        for _, group in pairs(this.tingPaiIds) do
            if group.pushCard == id then
                return true
            end
        end
        return false
    else
        return false
    end
end

--初始化下一局
function BattleModule.InitNextJuShu()
    this.ClearYuCardUids()
    EqsBattleCtrl.ClearChuPaiInfo()
    EqsBattlePanel.SetLeftCard(0)
    if IsTable(this.userInfoCtrls) then
        for _, userCtrl in pairs(this.userInfoCtrls) do
            userCtrl:Reset()
        end
    end
    SelfHandEqsCardsCtrl.ClearAllLocalPos()
    ClearChildren(EqsBattlePanel.GetChuPaiRect():Find('ChuPaiPos'))
    Log("初始化下一局数据")
end

function BattleModule.GetRule(eqsRuleType)
    if this.rules ~= nil then
        return tonumber(this.rules[eqsRuleType])
    end
    return -1
end

function BattleModule.GetUid()
    return this.uid
end

function BattleModule.IsCommRoom()
    return this.moneyType == MoneyType.Fangka and this.roomType == RoomType.Lobby
end

function BattleModule.GetUserInfoBySeatId(seatId)
    for _, userInfo in pairs(this.userInfoCtrls) do
        if userInfo.seatId == seatId then
            return userInfo
        end
    end
    Log("=========>GetUserInfoBySeatIdx失败：", seatId)
    return nil
end

function BattleModule.IsClubRoom()
    return this.roomType == RoomType.Club
end
--大厅匹配
function BattleModule.IsTeaRoom()
    return this.roomType == RoomType.Tea
end

function BattleModule.IsGoldRoom()
    return this.moneyType == MoneyType.Gold
end

--是否是房卡流程房间
function BattleModule.IsFkFlowRoom()
    --房卡流程：货币为房卡或者无限局(-1)分数场
    if (this.moneyType == MoneyType.Fangka) or (this.moneyType == MoneyType.Gold and this.GetRule(EqsRuleType.QuanShu) > 0) then
        return true
    end
    return false
end

function BattleModule.GetUserInfoByUid(uid)
    if IsTable(this.userInfoCtrls) then
        for _, userInfo in pairs(this.userInfoCtrls) do
            if userInfo.uid == uid then
                return userInfo
            end
        end
    else
        LogError("BattleModule.GetUserInfoByUid(uid)", uid, BattleModule)
    end
    Log("BattleModule.GetUserInfoByUid(uid)失败：", uid)
    return nil
end

function BattleModule.GetUserInfoByUiIdx(uiIdx)
    for _, userInfo in pairs(this.userInfoCtrls) do
        if userInfo.uiIdx == uiIdx then
            return userInfo
        end
    end
    Log("=========>GetUserInfoByUiIdx失败：", uiIdx)
    return nil
end

function BattleModule.IsYuCardUid(cardUid)
    for _, card in ipairs(this.yuCardUid) do
        if EqsTools.GetEqsCardId(card) == EqsTools.GetEqsCardId(cardUid) then
            return true
        end
    end
    return false
end

function BattleModule.AddYuCardUid(cardUid)
    table.insert(this.yuCardUid, cardUid)
end

function BattleModule.ClearYuCardUids()
    this.yuCardUid = {}
end

function BattleModule.SetOperations(operations)
    this.operations = operations
    Log("设置自己的操作项：", this.uid, operations)
end
--{"id2":522,"targetId":521,"id3":0,"from":2,"id1":511,"oper":46}
function BattleModule.GetOperation(operType)
    if operType == EqsOperation.Guo then
        if #this.operations > 0 then
            local oper = this.operations[1]
            return { targetId = EqsTools.GetTargetId(oper), from = EqsTools.GetFrom(oper), oper = EqsOperation.Guo, id1 = 0, id2 = 0, id3 = 0 }
        else
            return { targetId = 0, from = 0, oper = EqsOperation.Guo, id1 = 0, id2 = 0, id3 = 0 }
        end
    end

    for _, oper in pairs(this.operations) do
        if EqsTools.GetOperationType(oper) == operType then
            return oper
        end
    end
    LogError("没有操作项：", this.operations, this.uid, this.roomId)
    return nil
end

function BattleModule.StoreDanJuJieSuanCardPosition(cardPosition, uid)
    if not IsTable(this.danJuJieSuanCardPositions) then
        this.danJuJieSuanCardPositions = {}
    end
    this.danJuJieSuanCardPositions[tostring(uid)] = cardPosition

    local panel = PanelManager.GetPanel(EqsPanels.DanJuJieSuan)
    if IsTable(panel) and panel:IsOpend() then
        panel.UpdateCardPositions(uid)
    end
end

function BattleModule.GetDanJuJieSuanCardPosition(uid)
    Log("获取单局结算牌位置：", uid, this.danJuJieSuanCardPositions)
    if IsTable(this.danJuJieSuanCardPositions) then
        local pos = this.danJuJieSuanCardPositions[tostring(uid)]
        return pos
    end
    return nil
end

function BattleModule.GetGpsMapData()
    local selfUser = this.GetUserInfoByUid(UserData.GetUserId())
    local countDown = nil
    if selfUser.status == EqsUserStatus.Preparing then
        countDown = this.prepareDaoJiShi
    else
        countDown = nil
    end
    local data = {
        gameType = GameType.ErQiShi,
        roomType = this.roomType,
        moneyType = this.moneyType,
        isRoomBegin = this.isStarted, --房间是否开始，即第一局开始后，后面的处理退出都需要解散
        isRoomOwner = selfUser.isFz, --房间拥有者，玩家自己是否是房主
        playerMaxTotal = this.userNum, --玩家最大总人数
        readyCallback = this.SendPrepare, --准备点击回调
        quitCallback = this.RoomGPSQuitBtnCallback, --退出解散回调
        countDown = countDown, --准备倒计时，如果是非准备阶段，该值为nil，是否是GPS查看也通过该方法
        players = this.GetGpsUserData(),
    }
    return data
end

function BattleModule.GetGpsUserData()
    local players = {}
    local tempData = nil
    local playerData = nil
    for _, userCtrl in pairs(this.userInfoCtrls) do
        if userCtrl.gameObject.activeSelf then
            tempData = {
                id = userCtrl.uid,
                name = userCtrl.name,
                headUrl = userCtrl.headIcon,
                headFrame = userCtrl.frameId,
                ready = Functions.TernaryOperator(userCtrl.status == EqsUserStatus.Prepared, 1, 0), --准备标识，0未准备、1准备
                gps = GPSModule.GetGpsDataByPlayerId(userCtrl.uid)
            }
            players[userCtrl.uiIdx] = tempData
        end
    end
    Log("GetGpsUserData:", players)
    return players
end
------------------------------------发送消息协议--------------------------------------------
--加入房间   加入房间成功后获取房间数据  SendGetRoomData   推送房间信息，如果牌局开始，推牌信息771
function BattleModule.SendJoinedRoom()
    Log("SendJoinedRoom UserData", UserData)
    this.SetIsPerform772(false)
    if not this.isEnd then
        local obj = {
            userId = UserData.GetUserId(),
            roomId = UserData.GetRoomId(),
            img = UserData.GetHeadUrl(),
            username = UserData.GetName(),
            sex = UserData.GetGender(),
            frameId = UserData.GetFrameId(),
            gold = UserData.GetGold(),
            line = this.port
        }
        SendTcpMsg(CMD.Tcp.C2S_JoinedRoom, obj)

        LogUpload("fs" .. CMD.Tcp.C2S_JoinedRoom)
    else
        Log("Game Is End:")
    end
end

function BattleModule.SendCheckAndJoinedRoom()
    BaseTcpApi.SendCheckIsInRoom(UserData.GetRoomId(), BattleModule.OnCheckIsInRoomCallback, GameType.ErQiShi, EqsPanels.DanJuJieSuan, EqsTools.ReturnToLobby)
end


--请求进入房间后，服务器自动返回房间数据
function BattleModule.SendGetRoomData()
    local obj = {
        userId = this.uid,
        roomId = this.roomId,
    }
    if not this.isEnd then
        SendTcpMsg(CMD.Tcp.C2S_GetRoomData, obj)
        LogUpload("fs" .. CMD.Tcp.C2S_GetRoomData)
    else
        Log("Game Is End:")
    end
end

--执行操作时，禁止拖动，服务器返回时，再拖动
function BattleModule.SendOperationType(operType)
    if not this.isEnd then
        SelfHandEqsCardsCtrl.SetDraggable(false, 2)
        local oper = this.GetOperation(operType)
        this.SendOperation(oper)
    else
        Log("Game Is End:")
    end
end

--玩家执行操作
local send772Schedule = nil
function BattleModule.SendOperation(operation)
    this.SetIsPerform772(true)
    Scheduler.unscheduleGlobal(send772Schedule)
    send772Schedule = Scheduler.scheduleOnceGlobal(function()
        this.SetIsPerform772(false)
    end, 5)
    if this.isDisconnect == true then
        Log("BattleModule.isDisconnect:", this.isDisconnect)
        return
    end
    if not this.isEnd then
        SendTcpMsg(CMD.Tcp.C2S_Operation772, operation)
        LogUpload("fs" .. CMD.Tcp.C2S_Operation772)
    else
        Log("Game Is End:")
    end
end

--改变玩家状态，发送给服务器的是自己的当前状态
local lastSendPrepareTime = 0
function BattleModule.SendPrepare()
    if this.isDisconnect == true then
        Log("BattleModule.isDisconnect:", this.isDisconnect)
        return
    end
    if not this.isEnd then
        --if lastSendPrepareTime < 1000 or os.time() - lastSendPrepareTime > 3 then
        SendTcpMsg(CMD.Tcp.C2S_UserPrepare, {})
        LogUpload("fs" .. CMD.Tcp.C2S_UserPrepare)
        lastSendPrepareTime = os.time()
        --else
        --Log("准备发送太频繁", lastSendPrepareTime, os.time())
        --end
    else
        Log("Game Is End:")
    end
end

--房间GPS界面解散房间回调
function BattleModule.RoomGPSQuitBtnCallback()
    if this.isStarted then
        Toast.Show("游戏已经开始，不能执行操作")
    else
        if this.IsFkFlowRoom() then
            local selfUser = this.GetUserInfoByUid(UserData.GetUserId())
            if selfUser.isFz then
                if this.IsClubRoom() then
                    this.SendQuitRoom()
                else
                    this.SendJieShanRoom()
                end
            else
                this.SendQuitRoom()
            end
        else
            this.SendQuitRoom()
        end
    end
end

--退出房间
function BattleModule.SendQuitRoom()
    if this.isDisconnect == true then
        Log("BattleModule.isDisconnect:", this.isDisconnect)
        return
    end
    if not this.isStarted then
        SendTcpMsg(CMD.Tcp.C2S_QuitRoom, { roomId = this.roomId })
    else
        if this.IsFkFlowRoom() then
            Toast.Show("游戏中，不能退出房间")
        else
            SendTcpMsg(CMD.Tcp.C2S_QuitRoom, { roomId = this.roomId })
        end
    end
end

--解散房间
function BattleModule.SendJieShanRoom()
    if this.isDisconnect == true then
        Log("BattleModule.isDisconnect:", this.isDisconnect)
        return
    end
    if not this.isStarted then
        SendTcpMsg(CMD.Tcp.C2S_JieShanRoom, { userId = this.uid, roomId = this.roomId })
    else
        Toast.Show("游戏中，不能解散房间")
    end
end

--投票解散 status: -1 发起解散    0 拒绝解散    1 同意解散
function BattleModule.SendTouPiaoJieShanRoom(status)
    if this.isDisconnect == true then
        Log("BattleModule.isDisconnect:", this.isDisconnect)
        return
    end
    if this.isStarted then
        if not this.isEnd then
            SendTcpMsg(CMD.Tcp.C2S_TouPiaoJieShanRoom, { uid = this.uid, status = status })
            LogUpload("fs" .. CMD.Tcp.C2S_TouPiaoJieShanRoom)
        else
            Log("Game Is End:")
        end
    else
        Toast.Show("游戏未开始，不能投票解散房间")
    end
end

function BattleModule.SendBroadcast(obj)
    if this.isDisconnect == true then
        Log("BattleModule.isDisconnect:", this.isDisconnect)
        return
    end
    if IsTable(obj) and not this.isEnd then
        SendTcpMsg(CMD.Tcp.C2S_Broadcast, obj)
    else
        Log("SendBroadcast", obj)
    end
end

function BattleModule.SendAutoPlay(isAuto)
    if not this.isEnd and not this.isPlayback then
        local obj = {
            uid = this.uid,
            auto = isAuto
        }
        SendTcpMsg(CMD.Tcp.C2S_AutoPlay, obj)
    end
end
--发送取消托管
function BattleModule.SendGps(lng, lat, address)
    if not this.isEnd and not this.isPlayback then
        local data = {
            lng = lng,
            lat = lat,
            adr = address,
        }
        SendTcpMsg(CMD.Tcp.C2S_Gps, data)
    end
end
------------------------------------发送消息协议End-----------------------------------------
------------------------------------接收消息协议--------------------------------------------
--获取房间数据 结构：{"data":{"teaId":0,"roomId":100001,"rules":{"1":3,"15":1,"19":1,"5":1},"clubId":0,"users":[{"icon":"ttttt","sex":1,"status":3,"seatId":1,"ip":"192.168.0.1","online":true,"userName":"猪小乖1","userId":100004,"isOwner":true,"score":100},{"icon":"ttttt","sex":1,"status":3,"seatId":2,"ip":"192.168.0.1","online":true,"userName":"猪小乖2","userId":100005,"isOwner":false,"score":1001},{"icon":"ttttt","sex":1,"status":3,"seatId":3,"ip":"192.168.0.1","online":false,"userName":"猪小乖3","userId":100006,"isOwner":false,"score":102}]},"code":0}
function BattleModule.OnCmdGetRoomData(data)
    this.SetIsDisconnected(false)
    LogUpload("js515")
    Log("OnCmdGetRoomData：", data)
    if data.code == 0 then
        this.InitRoom(data.data)
    else
        Log("OnCmdGetRoomData", SystemError.GetText(data.code))
    end
    Waiting.ForceHide()
    this.hasChuPai = false
end

--发牌{"code":0,"data":{"userCard":[{"handCards":[111,112,311,222,213,420,621,721,722,713,821,911,1021,1022,521,522,523,1011,1012,1013,1021],"uid":100004,"status":7,"operGroup":{"id2":522,"targetId":521,"id3":0,"from":2,"id1":511,"oper":46},"chuPai":[721,722,711,822],"leftCards":[{"id2":522,"targetId":521,"id3":0,"from":2,"id1":511,"oper":46},{"id2":623,"targetId":621,"id3":624,"from":2,"id1":622,"oper":43},{"id2":723,"targetId":721,"id3":0,"from":2,"id1":722,"oper":45}]},{"handCards":[111,112,311,222,213,420,621,721,722,713,821,911,1021,1022,521,522,523,1011,1012,1013,1021],"uid":100005,"status":7,"operGroup":{"id2":522,"targetId":521,"id3":0,"from":2,"id1":511,"oper":46},"chuPai":[721,722,711,822],"leftCards":[{"id2":522,"targetId":521,"id3":0,"from":2,"id1":511,"oper":46},{"id2":623,"targetId":621,"id3":624,"from":2,"id1":622,"oper":43},{"id2":723,"targetId":721,"id3":0,"from":2,"id1":722,"oper":45}]},{"handCards":[111,112,311,222,213,420,621,721,722,713,821,911,1021,1022,521,522,523,1011,1012,1013,1021],"uid":100006,"status":7,"operGroup":{"id2":522,"targetId":521,"id3":0,"from":2,"id1":511,"oper":46},"chuPai":[721,722,711,822],"leftCards":[{"id2":522,"targetId":521,"id3":0,"from":2,"id1":511,"oper":46},{"id2":623,"targetId":621,"id3":624,"from":2,"id1":622,"oper":43},{"id2":723,"targetId":721,"id3":0,"from":2,"id1":722,"oper":45}]}],"leftCount":21}}
function BattleModule.OnCmdGetUserCards(data)
    LogUpload("js771")
    Log("OnCmdGetUserCards:", data)
    this.SetIsDisconnected(false)
    if data.code == 0 then
        this.isStarted = true
        EqsBattleCtrl.FaPai(data.data)
        EqsBattleCtrl.SetYuCards()
    else
        Log("OnCmdGetRoomData", SystemError.GetText(data.code))
    end
end

--操作成功失败回调，只返回给发起操作玩家
function BattleModule.OnCmdOperationResult(data)
    LogUpload("js772")
    Log("操作执行结果成功与否返回：", data)
    EqsBattleCtrl.OnPerformOperationResult(data)
end

--玩家操作：当OnCmdOperationResult执行成功后，返回此协议给所有玩家
function BattleModule.OnCmdOperation(data)
    LogError("OnCmdOperation")
    LogUpload("js773")
    this.SetIsDisconnected(false)
    if data.code == 0 then
        EqsBattleCtrl.OnPerformOperation(data.data)
    else
        Log("失败。。。。。。。。。。。。。。。。。。。。。。。。。。", data)
    end
    this.hasChuPai = false
end

--改变单个玩家状态
function BattleModule.OnCmdChangeStatus(data)
    LogUpload("js" .. CMD.Tcp.S2C_ChangeStatus)
    if data.code == 0 then
        local ext = data.data.extendStr
        if IsNumber(ext) and ext >= 0 then
            BattleModule.prepareDaoJiShi = ext
        end
        for _, user in pairs(data.data.users) do
            local userCtrl = this.GetUserInfoByUid(user.uid)
            if userCtrl ~= nil then
                userCtrl:SetStatus(user.status)
            end
        end

        if PanelManager.IsOpened(PanelConfig.RoomGps) then
            SendEvent(CMD.Game.RoomGpsPlayerUpdate, this.GetGpsUserData())
        end
    else
        Log("失败。。。。。。。。。。。。。。。。。。。。。。。。。。", data)
    end
end

--解散房间
function BattleModule.OnTcpJieShanRoom(data)
    LogUpload("js" .. CMD.Tcp.S2C_JieShanRoom)
    if data.code == 0 then
        if data.data.code == 0 then
            EqsTools.ReturnToLobby()
            Toast.Show("房主已解散房间")
            -- Alert.Show("房间已解散，请返回大厅！", function ()
            -- end, "确定")
        else
            Toast.Show("当前不能解散房间")
        end
    end
end

--退出房间
function BattleModule.OnCmdQuitRoom(data)
    LogUpload("js" .. CMD.Tcp.S2C_QuitRoom)
    if data.code == 0 then
        if data.data.code == 0 then
            EqsTools.ReturnToLobby()
        elseif data.data.code == 9 then
            Toast.Show("游戏中不能退出房间")
        end
    end
end

--投票解散房间
function BattleModule.OnCmdTouPiaoJieShanRoom(data)
    LogUpload("js" .. CMD.Tcp.S2C_TouPiaoJieShanRoom)
    if data.code == 0 then
        if data.data.leftTime > 0.001 then
            local panel = PanelManager.GetPanel(EqsPanels.JieShanRoom)
            if panel ~= nil and panel:IsOpend() then
                panel:Update(data.data)
            else
                PanelManager.Open(EqsPanels.JieShanRoom, data.data)
            end
        else
            Log("倒计时为0")
            PanelManager.Close(EqsPanels.JieShanRoom, true)
        end
        PanelManager.Close(EqsPanels.EqsSetting)
    else
    end
end


--Ping值
function BattleModule.OnGamePing(data)
    EqsBattlePanel.SetPing(data)
end

--广播
function BattleModule.OnTcpBroadcast(data)
    -- Log("广播：", data)
    EqsBattleCtrl.OnBroadcast(data.data)
end

--单局结算
local jieSuanDelayHandle = nil
function BattleModule.OnTcpDanJuJieSuan(data)
    lastSendPrepareTime = 0
    LogUpload("js" .. CMD.Tcp.S2C_DanJuJieSuan)
    --Log("单局结算数据：", data)
    Network.ClearProtocalSendTime()--单局结算时，去掉所有超时，理由：分数场多加有胡，同时点胡时，胡后房间已结束，不会返回772，所有去掉所有超时时间
    if data.code == 0 then
        if not PanelManager.IsOpened(EqsPanels.DanJuJieSuan) then
            Scheduler.unscheduleGlobal(jieSuanDelayHandle)
            jieSuanDelayHandle = Scheduler.scheduleOnceGlobal(function()
                PanelManager.Open(EqsPanels.DanJuJieSuan, data.data)
                SelfHandEqsCardsCtrl.SetIsSyscByTempIds(false)
            end, 1)
        end
    end
    UIUtil.SetActive(EqsBattlePanel.GetAutoPlayTran(), false)
end

--总结算   收到总结算后，断开连接，停止心跳
function BattleModule.OnTcpZongJieSuan(data)
    LogUpload("js" .. CMD.Tcp.S2C_ZongJieSuan)
    this.isEnd = true
    if data.code == 0 then
        this.zongJieSuanData = data.data
    end
end

--下一局更新房间信息
function BattleModule.OnTcpUpdateRoomInfoForNextJu(data)
    LogUpload("js" .. CMD.Tcp.S2C_UpdateRoomData)
    if data.code == 0 then
        EqsBattleCtrl.OnInitNext(data.data)
    end
end

--断线重连重新连上网络
function BattleModule.OnGameConnected()
    Log("OnGameConnected", this.isPlayback, this.isEnd)
    if not this.isPlayback then
        if not this.isEnd then
            UserData.SetIsReconnectTag(true)
            this.SendCheckAndJoinedRoom()
        end
    end
end

function BattleModule.OnGameDisconnected()
    this.SetIsDisconnected(true)
    Log("BattleModule.OnGameDisconnected")
end

function BattleModule.OnTcpSystemTips(data)
    Log("系统提示：", data, this.isEnd)
    --游戏已经结束，未找到房间号
    if data.code == SystemTipsErrorCode.GameOver or data.code == SystemTipsErrorCode.EmptyUser then
        if not this.isEnd then
            Alert.Show("游戏已结束，返回大厅", function()
                EqsTools.ReturnToLobby()
            end)
        end
    else
        if data.code == SystemErrorCode.RoomIsNotExist10003 or SystemErrorCode.GameIsEnd20008 then
            if not this.isEnd then
                Alert.Show("游戏已结束，返回大厅", function()
                    EqsTools.ReturnToLobby()
                end)
            end
        end
    end
end

function BattleModule.OnTcpNotice(data)
    if data.code == 0 then
        EqsBattleCtrl.OnServerNotice(data.data)
    end
end

function BattleModule.OnTcpServerJieShanRoom(data)
    Log("后台通知解散房间")
    this.isEnd = true
    if data.code == 0 and data.data ~= nil and data.data.type == 1 then
        EqsTools.ReturnToLobby()
        Alert.Show("房间已解散")
    end
end

--处理扣分数
function BattleModule.OnPushRoomDeductGold(arg)
    if arg.code == 0 then
        local data = arg.data
        if data.type == DeductGoldType.Expression then
            --玩家自己的ID，用于更新分数
            local userId = UserData.GetUserId()
            local length = #data.players
            local temp = nil
            for i = 1, length do
                temp = data.players[i]
                if temp.gold ~= nil then
                    --更新玩家的分数
                    if temp.id == userId then
                        UserData.SetGold(temp.gold)
                        local userCtrl = this.GetUserInfoByUid(userId)
                        userCtrl:CutGold(temp.cut, temp.gold)
                    end
                end
            end
        elseif data.type == DeductGoldType.Table then
            local length = #data.players
            local temp = nil
            for i = 1, length do
                temp = data.players[i]
                local userCtrl = this.GetUserInfoByUid(temp.id)
                if temp.cut ~= nil and temp.gold ~= nil then
                    userCtrl:SetScore(temp.gold)
                end
            end
        elseif data.type == DeductGoldType.Game then
            local length = #data.players
            local temp = nil
            for i = 1, length do
                temp = data.players[i]
                local userCtrl = this.GetUserInfoByUid(temp.id)
                if temp.cut ~= nil and temp.gold ~= nil then
                    userCtrl:CutGold(temp.cut, temp.gold)
                end
            end
        end
    end
end

function BattleModule.OnGameAppPause(isPause)
    if not BattleModule.isStarted then
        --为了在准备界面倒计时显示正确
        if isPause then
            Network.Disconnect()
        end
    end
end
------------------------------------接收消息协议End-----------------------------------------
------------------------------------自定义消息协议Start-------------------------------------
function BattleModule.OnBatteryState(value)
    if EqsBattlePanel ~= nil and IsFunction(EqsBattlePanel.SetEnergyValue) then
        EqsBattlePanel.SetEnergyValue(value)
    end
end

------------------------------------------------------------------
--初始化聊天系统
function BattleModule.InitChatManager()
    if this.isPlayback then
        return
    end

    --显示聊天气泡
    ChatModule.SetChatCallback(this.ShowChatBubble)
    --显示聊天语音气泡
    ChatModule.SetVoiceCallback(this.ShowChatVoiceBubble)
    local config = {
        audioBundle = EqsSoundManager.GetAudioBundleName(),
        textChatConfig = EqsBroadcast.TextChat,
        languageType = LanguageType.sichuan,
    }
    ChatModule.SetChatConfig(config)

    --初始化基本信息
    ChatModule.Init(PanelConfig.RoomChat, PanelConfig.RoomUserInfo)
end

--玩家数据更新
function BattleModule.UpdateChatPlayers(userCtrls)
    if this.isPlayback then
        return
    end
    local players = {}
    for k, v in pairs(userCtrls) do
        if not string.IsNullOrEmpty(v.uid) then
            players[v.uid] = {}
            players[v.uid].emotionNode = v:GetSayEmotionRoot()
            players[v.uid].animNode = v.headIconImg
            players[v.uid].gender = v.sex
            players[v.uid].name = v.name
        end
    end
    ChatModule.SetPlayerInfos(players)
end

--回调显示文本
function BattleModule.ShowChatBubble(playerId, duration, str)
    local player = BattleModule.GetUserInfoByUid(tonumber(playerId))
    player:SayText(str, duration)
end

--回调显示语音气泡
function BattleModule.ShowChatVoiceBubble(playerId, duration)
    local player = BattleModule.GetUserInfoByUid(tonumber(playerId))
    player:PlayVoiceBubble()

    Scheduler.scheduleOnceGlobal(function()
        player:StopVoiceBubble()
    end, duration)
end

function BattleModule.OnCheckIsInRoomCallback(data)
    if data.code == 0 then
        if data.data.roomId > 0 then
            this.port = data.data.line
            this.SendJoinedRoom()
            PanelManager.Close(PanelConfig.GoldMatch)
        end
    end
end

function BattleModule.OnTcpAutoPlay(data)
    if data.code == 0 then
        local userCtrl = this.GetUserInfoByUid(data.data.uid)
        if userCtrl then
            userCtrl:SetAutoPlayTagVisible(data.data.auto)
        end
    end
end

function BattleModule.OnTeaQucikMatchError()
    EqsTools.ReturnToLobby()
end

-----------------------------------------------GPS相关----------------------------------------
function BattleModule.HandleUserGps()
    local location = UserData.GetLocation()
    --更新数据
    GPSModule.UpdatePlayerData(this.uid, location.lat, location.lng, location.address)
    --分派GPS更新事件
    SendEvent(CMD.Game.RoomGpsPlayerUpdate, this.GetGpsUserData())
    this.lastGpsAddress = location.address
    this.SendGps(location.lng, location.lat, location.address)
end

--处理检测GPS数据
function BattleModule.OnUpdateUserGpsData()
    if not this.isPlayback then
        this.HandleUserGps()
    end
end

--处理检测GPS数据
function BattleModule.OnUpdateUserAddress()
    if not this.isPlayback then
        this.HandleUserGps()
    end
end

--更新玩家的GPS信息
function BattleModule.OnUpdatePlayersGpsData()
    if not this.isPlayback then
        SendEvent(CMD.Game.RoomGpsPlayerUpdate, this.GetGpsUserData())
    end
end
--更新服务器广播gps地址信息
function BattleModule.OnGps(data)
    if data.code == 0 then
        this.isUploadGps = true
    end
end

--加入房间协议收到后，检测上传GPS
function BattleModule.CheckGpsUpload()
    Log("BattleModule", this.isUploadGps)
    if not this.isUploadGps then
        this.HandleUserGps()
    end
end
------------------------------------自定义消息协议End-------------------------------------