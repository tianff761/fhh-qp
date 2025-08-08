PdkRoomModule = {}
local this = PdkRoomModule

this.serverPort = nil

this.uid = 0 --用户ID
this.headUrl = "" --头像
this.userName = "" --名字
this.sex = 0 --性别
--游戏玩法
this.playWayType = -1
--房间ID
this.roomId = 0
--亲友圈ID
this.groupId = 0
--房间类型
this.roomType = RoomType.Lobby
--货币类型
this.moneyType = MoneyType.Fangka
--房间规则
this.rules = {}
--支付方式
this.payType = 0
--最大局数
this.maxjs = 10
--当前局数
this.nowjs = 0
--最大人数
this.maxPlayer = 3
--
this.diFen = 0
--
this.node = nil
-- 房主
this.ownerId = 0
--庄家
this.bankerSeat = 0
-- 2等待准备 3等待开始 4游戏状态
this.gameStatus = 0
--自己的座位号
this.seatIndex = 0
--玩家信息
this.players = {}
--准备倒计时
this.readyTime = 30
--是否回放
this.isPlayback = false
--是否必出
this.isBiChu = false
--单局结算
this.singleRecordIndex = 0
--总结算数据
this.totalRecordData = nil
--发送限制时间
this.lastSendTime = 0
--房间是否在解散中
this.isDisRoomIng = false
--是否可以看牌
this.isSeePoker = true
--是否准备
this.isZhunBei = false
--是否托管
this.isTuoGuan = false
--是否该自己出牌
this.isOutCard = false
--是否第一个出牌
this.isFirst = false
--桌面上的牌信息
this.pokerTypeMsg = nil

this.isDisconnected = false
--是否上传GPS
this.isUploadGps = false
--街道地址
this.lastGpsAddress = ""
--是否主动发送离开房间
this.isSendQuitRoomMsg = false

--提示牌型当前索引
this.tipIndex = 0
--提示牌型集合
this.tipPokers = {}

--战绩回放类型 1大厅战绩回放   2亲友圈战绩回放
this.recordType = 0
------------------------------------一些初始化数据的工作-----------------------------------------
--初始化数据
function PdkRoomModule.Init(args)
    this.Clear()
    this.headUrl = UserData.GetHeadUrl()
    this.userName = UserData.GetName()
    this.sex = UserData.GetGender()

    this.uid = args.userId
    this.serverPort = args.line
    this.roomId = args.roomId
    this.roomType = Functions.CheckRoomType(args.roomType)
    this.moneyType = Functions.CheckMoneyType(args.moneyType)
    this.groupId = args.groupId
    this.playbackTime = args.time

    this.recordType = args.recordType
    if this.recordType == nil then
        this.recordType = 1
    end
    if IsBool(args.isPlayback) then
        this.isPlayback = args.isPlayback
    else
        this.isPlayback = false
    end
    Log("初始化Module数据：", this.uid, this.roomId, this.headUrl, this.userName, this.sex)
    this.AddMsgs()
end

--清空数据
function PdkRoomModule.Clear()
    this.uid = 0
    this.headUrl = ""
    this.userName = ""
    this.sex = 0
    this.roomId = 0
    this.groupId = 0
    this.roomType = RoomType.Lobby
    this.moneyType = MoneyType.Fangka
    this.rules = {}
    this.payType = 0
    this.maxjs = 10
    this.nowjs = 0
    this.maxPlayer = 3
    this.diFen = 0
    this.node = nil
    this.ownerId = 0
    this.bankerSeat = 0
    this.gameStatus = 0
    this.seatIndex = 0
    this.isOutCard = false
    this.isPlayback = false
    this.singleRecordIndex = 0
    this.totalRecordData = nil
    this.isBiChu = false
    this.lastSendTime = 0
    this.isDisRoomIng = false
    this.isSeePoker = true
    this.isZhunBei = false
    this.isTuoGuan = false
    this.isFirst = false
    this.pokerTypeMsg = nil
    this.tipIndex = 0
    this.tipPokers = {}
    this.recordType = 0
    this.RemoveMsgs()
    this.players = {}
    this.isUploadGps = false
    this.lastGpsAddress = ""
    this.isSendQuitRoomMsg = false

    ChatModule.SetIsCanSend(false)
    ChatModule.UnInit()
end

function PdkRoomModule.AddMsgs()
    this.AddTimeOutProtocal()
    AddMsg(CMD.Tcp.Pdk.S2C_RoomInfo, this.CMDGetRoomData)
    AddMsg(CMD.Tcp.Pdk.S2C_UpdatePlayerInfo, this.CMDUpdatePlayerInfo)
    AddMsg(CMD.Tcp.Pdk.S2C_RoonStatus, this.CMDUpdateRoomInfo)
    AddMsg(CMD.Tcp.Pdk.S2C_RoomDissolve, this.CMDRoomDissolve)
    AddMsg(CMD.Tcp.Pdk.S2C_DissolveRoom, this.CMDDissolveRoom)
    -- AddMsg(CMD.Tcp.Pdk.S2C_GameWaitStart, this.CMDGameWaitStart)
    AddMsg(CMD.Tcp.Pdk.S2C_PlayerReady, this.CMDPlayerReady)
    AddMsg(CMD.Tcp.Pdk.S2C_DealCard, this.CMDDealCard)
    AddMsg(CMD.Tcp.Pdk.S2C_PlayerPassCard, this.CMDPlayerPassCard)
    AddMsg(CMD.Tcp.Pdk.S2C_NoticeOutCard, this.CMDNoticeOutCard)
    AddMsg(CMD.Tcp.Pdk.S2C_PlayerOutCard, this.CMDPlayerOutCard)
    -- AddMsg(CMD.Tcp.Pdk.S2C_TipOutCard, this.CMDTipOutCard)
    AddMsg(CMD.Tcp.Pdk.S2C_SingleRecord, this.CMDSingleRecord)
    AddMsg(CMD.Tcp.Pdk.S2C_TotalRecord, this.CMDTotalRecord)
    AddMsg(CMD.Tcp.Pdk.S2C_ErrorMessage, this.CMDErrorMessage)
    AddMsg(CMD.Tcp.Pdk.S2C_DeductScore, this.CMDDeductScore)
    AddMsg(CMD.Tcp.Pdk.S2C_SurplusHandCard, this.CMDSurplusHandCard)
    AddMsg(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
    AddMsg(CMD.Tcp.Pdk.S2C_PlayerGpsData, this.CMDPlayerGpsData)
    AddMsg(CMD.Tcp.Pdk.S2C_PlayerSeePoker, this.CMDPlayerSeePoker)
    AddMsg(CMD.Tcp.Pdk.S2C_PlayerOutCardResult, this.CMDPlayerOutCardResult)
    AddMsg(CMD.Tcp.Pdk.PushRoomEndStatus, this.OnPushRoomEndStatus)

    AddMsg(CMD.Game.Reauthentication, this.OnReauthentication)
    AddMsg(CMD.Game.OnDisconnected, this.OnDisconnected)
    AddMsg(CMD.Tcp.Push_SystemTips, this.OnTcpSystemTips)
    AddMsg(CMD.Game.UpdateUserGpsData, this.OnUpdateUserGpsData)
    AddMsg(CMD.Game.UpdateUserAddress, this.OnUpdateUserAddress)
    AddMsg(CMD.Game.UpdatePlayersGpsData, this.OnUpdatePlayersGpsData)

    AddMsg(CMD.Tcp.S2C_Gps, this.OnGps)
end

function PdkRoomModule.RemoveMsgs()
    this.RemoveTimeOutProtocal()
    RemoveMsg(CMD.Tcp.Pdk.S2C_RoomInfo, this.CMDGetRoomData)
    RemoveMsg(CMD.Tcp.Pdk.S2C_UpdatePlayerInfo, this.CMDUpdatePlayerInfo)
    RemoveMsg(CMD.Tcp.Pdk.S2C_RoonStatus, this.CMDUpdateRoomInfo)
    RemoveMsg(CMD.Tcp.Pdk.S2C_RoomDissolve, this.CMDRoomDissolve)
    RemoveMsg(CMD.Tcp.Pdk.S2C_DissolveRoom, this.CMDDissolveRoom)
    -- RemoveMsg(CMD.Tcp.Pdk.S2C_GameWaitStart, this.CMDGameWaitStart)
    RemoveMsg(CMD.Tcp.Pdk.S2C_PlayerReady, this.CMDPlayerReady)
    RemoveMsg(CMD.Tcp.Pdk.S2C_DealCard, this.CMDDealCard)
    RemoveMsg(CMD.Tcp.Pdk.S2C_PlayerPassCard, this.CMDPlayerPassCard)
    RemoveMsg(CMD.Tcp.Pdk.S2C_NoticeOutCard, this.CMDNoticeOutCard)
    RemoveMsg(CMD.Tcp.Pdk.S2C_PlayerOutCard, this.CMDPlayerOutCard)
    -- RemoveMsg(CMD.Tcp.Pdk.S2C_TipOutCard, this.CMDTipOutCard)
    RemoveMsg(CMD.Tcp.Pdk.S2C_SingleRecord, this.CMDSingleRecord)
    RemoveMsg(CMD.Tcp.Pdk.S2C_TotalRecord, this.CMDTotalRecord)
    RemoveMsg(CMD.Tcp.Pdk.S2C_ErrorMessage, this.CMDErrorMessage)
    RemoveMsg(CMD.Tcp.Pdk.S2C_DeductScore, this.CMDDeductScore)
    RemoveMsg(CMD.Tcp.Pdk.S2C_SurplusHandCard, this.CMDSurplusHandCard)
    RemoveMsg(CMD.Tcp.Push_RoomDeductGold, this.OnPushRoomDeductGold)
    RemoveMsg(CMD.Tcp.Pdk.S2C_PlayerGpsData, this.CMDPlayerGpsData)
    RemoveMsg(CMD.Tcp.Pdk.S2C_PlayerSeePoker, this.CMDPlayerSeePoker)
    RemoveMsg(CMD.Tcp.Pdk.S2C_PlayerOutCardResult, this.CMDPlayerOutCardResult)

    RemoveMsg(CMD.Game.Reauthentication, this.OnReauthentication)
    RemoveMsg(CMD.Game.OnDisconnected, this.OnDisconnected)
    RemoveMsg(CMD.Tcp.Push_SystemTips, this.OnTcpSystemTips)
    RemoveMsg(CMD.Game.UpdateUserGpsData, this.OnUpdateUserGpsData)
    RemoveMsg(CMD.Game.UpdateUserAddress, this.OnUpdateUserAddress)
    RemoveMsg(CMD.Game.UpdatePlayersGpsData, this.OnUpdatePlayersGpsData)
    RemoveMsg(CMD.Tcp.S2C_Gps, this.OnGps)
end

--添加协议超时
function PdkRoomModule.AddTimeOutProtocal()
    Network.RegisterTimeOutProtocal(CMD.Tcp.C2S_CheckIsInRoom, CMD.Tcp.S2C_CheckIsInRoom)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Pdk.C2S_JoinRoom, CMD.Tcp.Pdk.S2C_RoomInfo)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Pdk.C2S_PlayerReady, CMD.Tcp.Pdk.S2C_PlayerReady)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Pdk.C2S_PlayerOutCard, CMD.Tcp.Pdk.S2C_PlayerOutCardResult)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Pdk.C2S_DissolveRoom, CMD.Tcp.Pdk.S2C_DissolveRoom)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Pdk.C2S_VoteAction, CMD.Tcp.Pdk.S2C_DissolveRoom)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Pdk.C2S_PlayerPassCard, CMD.Tcp.Pdk.S2C_PlayerPassCard)
end

--移除协议超时
function PdkRoomModule.RemoveTimeOutProtocal()
    Network.RegisterTimeOutProtocal(CMD.Tcp.C2S_CheckIsInRoom, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Pdk.C2S_JoinRoom, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Pdk.C2S_PlayerReady, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Pdk.C2S_PlayerOutCard, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Pdk.C2S_DissolveRoom, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Pdk.C2S_VoteAction, nil)
    Network.RegisterTimeOutProtocal(CMD.Tcp.Pdk.C2S_PlayerPassCard, nil)
end
------------------------------------一些初始化数据的工作end-----------------------------------------

------------------------------------一些游戏需要的公共方法-----------------------------------------
function PdkRoomModule.IsInitRoom()
    return this.seatIndex ~= 0
end

--游戏是否开始
function PdkRoomModule.IsStart()
    LogError(this.gameStatus)
    if this.gameStatus == PdkGameStatus.ContendBanker or this.gameStatus == PdkGameStatus.Strat or this.gameStatus == PdkGameStatus.Result then
        return true
    end
    return false
end

--游戏是否结束
function PdkRoomModule.IsOver()
    if this.gameStatus == PdkGameStatus.Over then
        return true
    end
    return false
end

--判断自己是否是房主
function PdkRoomModule.IsOwner()
    if this.uid == this.ownerId then
        return true
    end
    return false
end

--判断自己是否是庄家
function PdkRoomModule.IsBanker()
    if this.bankerSeat == this.seatIndex then
        return true
    end
    return false
end

--根据玩家ID判断是否是自己
function PdkRoomModule.IsSelfByID(id)
    if this.uid == id then
        return true
    end
    return false
end

--根据玩家座位号判断是否是自己
function PdkRoomModule.IsSelfBySeat(seat)
    if this.seatIndex == seat then
        return true
    end
    return false
end

--分数娱乐场匹配
function PdkRoomModule.IsTeaRoom()
    return this.roomType == RoomType.Tea
end

function PdkRoomModule.IsClubRoom()
    return this.roomType == RoomType.Club
end
--大厅匹配
function PdkRoomModule.IsMatchRoom()
    return this.roomType == RoomType.Tea
end

--是否分数房间
function PdkRoomModule.IsGoldRoom()
    return this.moneyType == MoneyType.Gold
end

--是否房卡房间
function PdkRoomModule.IsFangKaRoom()
    return this.moneyType == MoneyType.Fangka
end

--是否最后一局
function PdkRoomModule.IsLastRound()
    return this.nowjs == this.maxjs
end

--是否黑桃五先出
function PdkRoomModule.IsHeiWuFirstOut()
    --庄家开始牌的张数
    local count = 10
    if this.GetRule(PdkRuleType.PlayType) == PdkPlayType.LSSanRen then
        count = 14
    else
        count = 10
    end
    if this.IsSCGame() then
        if this.GetRule(PdkRuleType.OutRule) == 1 and PdkSelfHandCardCtrl.GetHandPokerCount() == count and this.IsBanker() then
            return true
        end
    elseif this.IsLSGame() then
        if this.GetRule(PdkRuleType.LS_XC) == 1 then
            if PdkSelfHandCardCtrl.GetHandPokerCount() == count and this.IsBanker() then
                return true
            end
        else
            if PdkSelfHandCardCtrl.GetHandPokerCount() == count and this.nowjs == 1 and this.IsBanker() then
                return true
            end
        end
    end
    return false
end

--是否十五张跑得快
function PdkRoomModule.IsFifteenPDK()
    return this.GetRule(PdkRuleType.PlayType) == PdkPlayType.FifteenPDK
end

--是否十六张跑得快
function PdkRoomModule.IsSixteenPDK()
    return this.GetRule(PdkRuleType.PlayType) == PdkPlayType.SixteenPDK
end

function PdkRoomModule.IsSixteenPDKOrFifteenPDK()
    return this.IsSixteenPDK() or this.IsFifteenPDK()
end

---是否黑三先出
function PdkRoomModule.IsHeiSanFirstOut(values)
    --庄家开始牌的张数
    -- local count = this.IsFifteenPDK() and 15
    -- count = this.IsSixteenPDK() and 16
    local count=  this.IsFifteenPDK() and  15 or 16
    LogError("判断黑三先出 庄家开始牌的张数count", count)
    if this.IsSixteenPDKOrFifteenPDK() and this.GetRule(PdkRuleType.ST_SC3) == 1 and this.IsHaveHeiSan(values) then
        if PdkSelfHandCardCtrl.GetHandPokerCount() == count and this.nowjs == 1 and this.IsBanker() then
            return true
        end
    end
    return false
end

function PdkRoomModule.IsHaveHeiSan(values)
    local isHave = false
    --检测是否有黑桃三
    for i = 1, #values do
        if values[i] == 33 then
            isHave = true
            break
        end
    end
    return isHave
end

--下家是否报单
function PdkRoomModule.IsBaoDan()
    for k, v in pairs(this.players) do
        if v.seatDir == PdkSeatDirection.Right then
            if v.pokerNum == 1 then
                return true
            end
        end
    end
    return false
end

--获取跑得快的规则
function PdkRoomModule.GetRule(ruleType)
    if this.rules ~= nil then
        return tonumber(this.rules[ruleType])
    end
    return -1
end

function PdkRoomModule.SetSeatDir(index, info)
    --根据几人场 换算座位方向
    if this.maxPlayer == 2 or this.maxPlayer == 4 then
        if index == 1 then
            info.seatDir = PdkSeatDirection.Self
        elseif index == 2 then
            info.seatDir = PdkSeatDirection.Right
        elseif index == 3 then
            info.seatDir = PdkSeatDirection.Top
        elseif index == 4 then
            info.seatDir = PdkSeatDirection.Left
        end
    elseif this.maxPlayer == 3 then
        if index == 1 then
            info.seatDir = PdkSeatDirection.Self
        elseif index == 2 then
            info.seatDir = PdkSeatDirection.Right
        elseif index == 3 then
            info.seatDir = PdkSeatDirection.Left
        end
    end
end

--添加玩家 根据座位号添加
function PdkRoomModule.AddPlayer(index, info)
    this.players[index] = info
    -- table.insert(this.players, info)
end

--移除玩家
function PdkRoomModule.RemovePlayer(index)
    this.players[index] = nil
    -- table.remove(this.players, index)
end

--根据ID获取玩家信息
function PdkRoomModule.GetPlayerInfoById(id)
    for i, v in pairs(this.players) do
        if v.playerId == id then
            return v
        end
    end
    return nil
end

--根据座位号获取玩家信息(本地座位号)
function PdkRoomModule.GetPlayerInfoBySeat(seat)
    return this.players[seat]
end

-- --清除所有玩家
-- function PdkRoomModule.ClearAllPlayer()
--     for i, v in pairs(this.players) do
--         table.remove(this.players, i)
--     end
-- end

--根据玩家ID获取玩家的本地座位号
function PdkRoomModule.GetPlayerSeatById(id)
    for i, v in pairs(this.players) do
        if v.playerId == id then
            return this.GetPlayerLocalSeat(v.seatNum)
        end
    end
    return 0
end

--根据服务器发的座位号换算为本地座位号
function PdkRoomModule.GetPlayerLocalSeat(serverIndex)
    local index = ((this.maxPlayer - this.seatIndex + serverIndex) % this.maxPlayer + 1)
    if this.maxPlayer == 3 and index == 3 then
        index = 4
    end
    return index
end

--获取GPS所需数据
function PdkRoomModule.GetGpsData()
    -- local selfUser = this.GetPlayerInfoById(UserData.GetUserId())
    local countDown = nil
    if this.gameStatus == PdkPlayerStatus.Ready and not this.isZhunBei then
        countDown = this.readyTime
    else
        countDown = nil
    end
    local data = {
        gameType = GameType.PaoDeKuai,
        roomType = this.roomType,
        moneyType = this.moneyType,
        isRoomBegin = this.IsStart(), --房间是否开始，即第一局开始后，后面的处理退出都需要解散
        isRoomOwner = this.IsOwner(), --房间拥有者，玩家自己是否是房主
        playerMaxTotal = this.maxPlayer, --玩家最大总人数
        readyCallback = this.SendPlayerReady, --准备点击回调
        quitCallback = this.SendExitRoom, --退出解散回调
        countDown = countDown, --准备倒计时，如果是非准备阶段，该值为nil，是否是GPS查看也通过该方法
        players = this.GetGpsPlayerData()
    }
    return data
end

--GPS获取玩家的信息
function PdkRoomModule.GetGpsPlayerData()
    local players = {}
    local tempData = nil
    for k, v in pairs(this.players) do
        tempData = {
            id = v.playerId,
            name = v.playerName,
            headUrl = v.playerHead,
            headFrame = v.playerTxk,
            ready = Functions.TernaryOperator(v.isZhunBei > 0, 1, 0), --准备标识，0未准备、1准备
            gps = GPSModule.GetGpsDataByPlayerId(v.playerId)
        }
        -- players[k] = tempData
        table.insert(players, tempData)
    end
    return players
end

--更大牌型数据
---@param tablePokerMsg table 1 牌型 2点数 3长度 (服务端参数名： pokerTypeMsg)
function PdkRoomModule.SetBiggerPokers(tablePokerMsg, pokerBeans)
    if PdkRoomModule.IsSCGame() then
        this.tipPokers = PdkPokerLogic.GetSCBiggerPokers(tablePokerMsg, pokerBeans)
    elseif PdkRoomModule.IsLSGame() then
        this.tipPokers = PdkPokerLogic.GetLSBiggerPokers(tablePokerMsg, pokerBeans)
    elseif PdkRoomModule.IsSixteenPDKOrFifteenPDK() then
        this.tipPokers = PdkPokerLogic.GetSixTeenBiggerPokers(tablePokerMsg, pokerBeans)
    end
    this.tipIndex = 0
end

--是否是四川跑得快
function PdkRoomModule.IsSCGame()
    if this.GetGameType() == PdkGameType.SC then
        return true
    end
    return false
end

--是否是乐山跑得快
function PdkRoomModule.IsLSGame()
    if this.GetGameType() == PdkGameType.LS then
        return true
    end
    return false
end

--获取大游戏玩法类型
function PdkRoomModule.GetGameType()
    if this.playWayType == PdkPlayType.SCErRen or this.playWayType == PdkPlayType.SCSanRen or this.playWayType == PdkPlayType.SCSiRen then
        return PdkGameType.SC
    elseif this.playWayType == PdkPlayType.LSSanRen or this.playWayType == PdkPlayType.LSSiRen then
        return PdkGameType.LS
    end
end
------------------------------------一些游戏需要的公共方法end-----------------------------------------

------------------------------------更新一些数据信息-----------------------------------------
--初始化房间数据
function PdkRoomModule.InitRoomInfo(data)
    this.roomId = data.roomCode
    this.rules = data.rules
    this.nowjs = data.nowjs
    this.maxjs = data.maxjs
    this.maxPlayer = data.maxPlayer
    this.diFen = tonumber(this.rules[PdkRuleType.DiFen]) or 0
    LogError(data)

    this.playWayType = this.GetRule(PdkRuleType.PlayType)

    if this.isPlayback then
        this.isSeePoker = true
    else
        this.payType = data.payType
        this.gameStatus = data.gameStatus
        this.ownerId = data.ownerId
        this.readyTime = data.countDown
        this.isDisRoomIng = data.isDisRoomIng == 1
        --现在规则都为能出必出  所以直接设为true
        this.isBiChu = true
        if this.GetRule(PdkRuleType.SLGP) == 1 then
            this.isSeePoker = false
        end
        this.isSeePoker = data.isSeePoker == 1
        --Gps相关
        GPSModule.Check()
        --检测是否发送了Gps
        this.HandleUserGps()
    end
    -- if this.rules[PdkRuleType.YCBC] == 1 then
    --     this.isBiChu = true
    -- end
    this.players = {}
    local player = nil
    --先找到自己的座位号
    for i = 1, #data.list do
        player = data.list[i]
        if this.uid == player.playerId then
            this.seatIndex = player.seatNum
        end
    end
    --换算为本地座位号
    local index = nil
    for i = 1, #data.list do
        player = data.list[i]
        index = this.GetPlayerLocalSeat(player.seatNum)
        if this.uid == player.playerId and not this.isPlayback then
            this.isZhunBei = player.isZhunBei == 1
            this.isTuoGuan = player.isTuoGuan == 1
        end
        if player.isZhuang and player.isZhuang == 1 then
            this.bankerSeat = player.seatNum
        end
        this.SetSeatDir(index, player)
        this.AddPlayer(index, player)
    end

    if this.IsBanker() then
        this.isSeePoker = true
    end
end

--更新玩家信息
function PdkRoomModule.UpdatePlayer(data)
    local index = this.GetPlayerLocalSeat(data.seatNum)
    if data.type == 0 then
        this.RemovePlayer(index)
    elseif data.type == 1 or data.type == 2 then
        this.SetSeatDir(index, data)
        this.AddPlayer(index, data)
        if this.IsSelfByID(data.playerId) then
            this.isTuoGuan = data.isTuoGuan == 1
        end
    end
end

--更新房间状态
function PdkRoomModule.UpdateRoomInfo(data)
    this.nowjs = data.nowjs
    this.readyTime = data.countDown
    this.gameStatus = data.gameStatus
    if not IsNil(data.list) then
        -- local info = nil
        -- local player = nil
        for i = 1, #data.list do
            local info = data.list[i]
            if this.uid == info.playerId then
                this.isZhunBei = info.isZhunBei == 1
                this.isTuoGuan = info.isTuoGuan == 1
            end
            local playerData = this.GetPlayerInfoById(info.playerId)
            if not IsNil(playerData) then
                playerData.isZhunBei = info.isZhunBei
                playerData.playerStatus = info.playerStatus
                PdkRoomCtrl.PlayerReady(info)
            end
        end
    end
end
------------------------------------更新一些数据信息end-----------------------------------------

------------------------------------发送消息协议-----------------------------------------
--玩家进入房间了
function PdkRoomModule.SendJoinedRoom()
    local data = {
        userId = UserData.GetUserId(),
        roomId = UserData.GetRoomId(),
        img = UserData.GetHeadUrl(),
        username = UserData.GetName(),
        sex = UserData.GetGender(),
        frameId = UserData.GetFrameId(),
        gold = UserData.GetGold(),
        line = this.serverPort
    }
    SendTcpMsg(CMD.Tcp.Pdk.C2S_JoinRoom, data)
end

--断线重连检测房间是否还存在
function PdkRoomModule.SendCheckAndJoinedRoom()
    BaseTcpApi.SendCheckIsInRoom(UserData.GetRoomId(), PdkRoomModule.OnCheckIsInRoomCallback, GameType.PaoDeKuai, PdkPanelConfig.SingleRecord, PdkRoomCtrl.ExitRoom)
end

function PdkRoomModule.OnCheckIsInRoomCallback(data)
    if data.code == 0 then
        if data.data.roomId > 0 then
            this.roomId = data.data.roomId
            this.serverPort = data.data.line
            PdkRoomCtrl.UpdateLine()
            this.SendJoinedRoom()
        else
            Alert.Show(
                    "牌局已结束，请返回大厅", PdkRoomCtrl.ExitRoom
            )
        end
    elseif data.code == SystemErrorCode.RoomIsNotExist10003 then
        Alert.Show(
                "牌局已结束，返回大厅", PdkRoomCtrl.ExitRoom
        )
    else
        Alert.Show(
                SystemError.GetText(data.code), PdkRoomCtrl.ExitRoom
        )
    end
end

--根据游戏状态发送离开or解散
function PdkRoomModule.RoomGPSQuitBtnCallback()
    if not this.IsStart() and this.IsFangKaRoom() then
        if this.IsOwner() then
            if this.IsClubRoom() then
                this.SendExitRoom()
            else
                this.SendDissolveRoom()
            end
        else
            this.SendExitRoom()
        end
    else
        Toast.Show("游戏已经开始，不能执行操作")
    end
end

--玩家离开
function PdkRoomModule.SendExitRoom()
    if this.isDisconnected then
        Log("PdkRoomModule.isDisconnected")
        return
    end
    this.isSendQuitRoomMsg = true
    local data = {
        playerId = this.uid
    }
    SendTcpMsg(CMD.Tcp.Pdk.C2S_ExitRoom, data)
end

--玩家发起解散房间
function PdkRoomModule.SendDissolveRoom()
    if this.isDisconnected then
        Log("PdkRoomModule.isDisconnected")
        return
    end
    local data = {
        playerId = this.uid
    }
    SendTcpMsg(CMD.Tcp.Pdk.C2S_DissolveRoom, data)
end

--玩家投票
function PdkRoomModule.SendVoteAction(isAgree)
    if this.isDisconnected then
        Log("PdkRoomModule.isDisconnected")
        return
    end
    local data = {
        playerId = this.uid,
        isAgree = isAgree
    }
    SendTcpMsg(CMD.Tcp.Pdk.C2S_VoteAction, data)
end

--发送玩家GPS数据
function PdkRoomModule.SendGpsData(lng, lat, address)
    if this.isDisconnected then
        Log("PdkRoomModule.isDisconnected")
        return
    end
    if this.IsOver() then
        Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>游戏已结束")
        return
    end
    local data = {
        lng = lng,
        lat = lat,
        adr = address,
    }
    SendTcpMsg(CMD.Tcp.C2S_Gps, data)
end

--玩家准备
function PdkRoomModule.SendPlayerReady()
    if this.isDisconnected then
        Log("PdkRoomModule.isDisconnected")
        return
    end
    local data = {
        playerId = this.uid
    }
    SendTcpMsg(CMD.Tcp.Pdk.C2S_PlayerReady, data)

    if PanelManager.IsOpened(PanelConfig.RoomGps) then
        PanelManager.Close(PanelConfig.RoomGps)
    end
end

--玩家出牌
function PdkRoomModule.SendPlayerOutCard(pokerType, pokers)
    if this.isDisconnected then
        Log("PdkRoomModule.isDisconnected")
        return
    end
    local data = {
        playerId = this.uid,
        pokers = pokers,
        pokerType = pokerType
    }
    SendTcpMsg(CMD.Tcp.Pdk.C2S_PlayerOutCard, data)
end

--玩家过牌
function PdkRoomModule.SendPlayerPass()
    if this.isDisconnected then
        Log("PdkRoomModule.isDisconnected")
        return
    end
    local data = {
        playerId = this.uid
    }
    SendTcpMsg(CMD.Tcp.Pdk.C2S_PlayerPassCard, data)
end

--玩家取消托管
function PdkRoomModule.SendCancelOnHook()
    if this.isDisconnected then
        Log("PdkRoomModule.isDisconnected")
        return
    end
    local data = {
        playerId = this.uid
    }
    SendTcpMsg(CMD.Tcp.Pdk.C2S_PlayerCancelOnHook, data)
end

--提示
function PdkRoomModule.SendTipsOutCard()
    if this.isDisconnected then
        Log("PdkRoomModule.isDisconnected")
        return
    end
    local data = {
        playerId = this.uid
    }
    SendTcpMsg(CMD.Tcp.Pdk.C2S_TipOutCard, data)
end
--------------------------------------发送消息协议End----------------------------------------------

--------------------------------------接收消息协议------------------------------------------------

--获取房间信息
function PdkRoomModule.CMDGetRoomData(data)
    Log("CMDGetRoomData", data)
    if data.code == 0 then
        Waiting.ForceHide()
        this.isDisconnected = false
        ChatModule.SetIsCanSend(true)
        PdkRoomCtrl.Reset()
        this.InitRoomInfo(data.data)
        PdkRoomCtrl.InitRoom(data.data)
    else
        Log("CMDGetRoomData", SystemError.GetText(data.code))
        Waiting.Hide()
    end
end

--玩家信息更新
function PdkRoomModule.CMDUpdatePlayerInfo(data)
    Log("CMDUpdatePlayerInfo", data)
    if data.code == 0 then
        if this.IsInitRoom() then
            this.UpdatePlayer(data.data)
            PdkRoomCtrl.UpdatePlayer(data.data)
        else
            Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>房间未初始化CMDUpdatePlayerInfo")
        end
    else
        Log("CMDUpdatePlayerInfo", SystemError.GetText(data.code))
    end
end

--房间状态更新
function PdkRoomModule.CMDUpdateRoomInfo(data)
    LogError("CMDUpdateRoomInfo", data)
    if data.code == 0 then
        if this.IsInitRoom() then
            this.UpdateRoomInfo(data.data)
            PdkRoomCtrl.UpdateRoomInfo()
        else
            Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>房间未初始化CMDUpdateRoomInfo")
        end
    else
        Log("CMDUpdateRoomInfo", SystemError.GetText(data.code))
    end
end

--玩家解散信息
function PdkRoomModule.CMDDissolveRoom(data)
    Log("CMDDissolveRoom", data)
    if data.code == 0 then
        local panel = PanelManager.GetPanel(PdkPanelConfig.Dissovle)
        if panel ~= nil and panel:IsOpend() then
            panel:Update(data.data)
        else
            PanelManager.Open(PdkPanelConfig.Dissovle, data.data)
        end
        PanelManager.Close(PdkPanelConfig.Setup)
        PanelManager.Close(PanelConfig.Alert)
    else
        if not IsNil(PdkErrorMessage[data.code]) then
            Toast.Show(PdkErrorMessage[data.code])
        end
        Log("CMDDissolveRoom", SystemError.GetText(data.code))
    end
end

--房间解散
function PdkRoomModule.CMDRoomDissolve(data)
    Log("CMDRoomDissolve", data)
    if data.code == 0 then
        if data.data.isEndGame == 1 then
            if this.IsStart() then
                PanelManager.Close(PdkPanelConfig.Dissovle)
                this.gameStatus = PdkGameStatus.Over
            else
                PdkRoomCtrl.ExitRoom()
                Toast.Show("房间已解散")
            end
        end
    else
        if not IsNil(PdkErrorMessage[data.code]) then
            Toast.Show(PdkErrorMessage[data.code])
        end
        Log("CMDRoomDissolve", SystemError.GetText(data.code))
    end
end

--获取GPS数据
function PdkRoomModule.CMDPlayerGpsData(data)
    Log("CMDPlayerGpsData", data)
    if data.code == 0 then
        -- local temp = nil
        -- local playerData = nil
        for i = 1, #data.data.list do
            local temp = data.data.list[i]
            local playerData = this.GetPlayerInfoById(temp.playerId)
            if not IsNil(playerData) then
                playerData.lat = temp.lat
                playerData.lng = temp.lng
            end
        end

        if PanelManager.IsOpened(PanelConfig.RoomGps) then
            SendEvent(CMD.Game.RoomGpsPlayerUpdate, this.GetGpsPlayerData())
        end
    else
        Log("CMDPlayerGpsData", SystemError.GetText(data.code))
    end
end

--玩家准备状态
function PdkRoomModule.CMDPlayerReady(data)
    Log("CMDPlayerReady", data)
    if data.code == 0 then
        local index = PdkRoomModule.GetPlayerLocalSeat(data.data.seatNum)
        local player = this.GetPlayerInfoBySeat(index)
        if PdkRoomModule.IsSelfBySeat(data.data.seatNum) then
            this.isZhunBei = data.data.isZhunBei == 1
        end
        PdkRoomCtrl.PlayerReady(data.data)
        if PanelManager.IsOpened(PanelConfig.RoomGps) then
            SendEvent(CMD.Game.RoomGpsPlayerUpdate, this.GetGpsPlayerData())
        end
        if not IsNil(player) then
            player.isZhunBei = data.data.isZhunBei
        else
            Log("CMDPlayerReady>>>>>>>>>>>>>>>>>玩家信息不存在")
            Network.Disconnect()
        end
    else
        if not IsNil(PdkErrorMessage[data.code]) then
            Toast.Show(PdkErrorMessage[data.code])
        end
        Log("CMDPlayerReady", SystemError.GetText(data.code))
    end
end

--发牌了
function PdkRoomModule.CMDDealCard(data)
    Log("CMDDealCard", data)
    if data.code == 0 then
        this.bankerSeat = data.data.zhuangSeat
        if this.IsBanker() then
            this.isSeePoker = true
        end
        for i = 1, #data.data.list do
            local info = data.data.list[i]
            local playerData = PdkRoomModule.GetPlayerInfoById(info.playerId)
            if playerData ~= nil then
                if PdkRoomModule.IsSelfByID(info.playerId) then
                    playerData.pokerNum = GetTableSize(info.pokers)
                else
                    playerData.pokerNum = info.pokerNum
                end
            else
                LogError("玩家信息不存在：", info.playerId)
            end
        end
        PdkRoomCtrl.DealCard(data.data)
    else
        Log("CMDDealCard", SystemError.GetText(data.code))
    end
end

--通知玩家出牌
function PdkRoomModule.CMDNoticeOutCard(data)
    Log("CMDNoticeOutCard", data)
    if data.code == 0 then
        PdkRoomCtrl.NoticeOutCard(data.data)
    else
        Log("CMDNoticeOutCard", SystemError.GetText(data.code))
    end
end

--自己出牌成功或失败回复
function PdkRoomModule.CMDPlayerOutCardResult(data)
    Log("CMDPlayerOutCardResult", data)
    if data.code == 0 then

    else
        if not IsNil(PdkErrorMessage[data.code]) then
            Toast.Show(PdkErrorMessage[data.code])
        end
        Network.Disconnect()
        Log("CMDPlayerOutCardResult", SystemError.GetText(data.code))
    end
end

--房间结束状态
function PdkRoomModule.OnPushRoomEndStatus(data)
    --LogError(data)
    if data.code == 0 then
        data = data.data
        if data.type == 1 then
            --超时解散结束
        elseif data.type == 2 then
            --正常结束
        elseif data.type == 3 then
            --有人金币不足结束
            Alert.Show("由于有玩家分数不足，房间被解散")
        elseif data.type == 4 then
            --解散结束
        end
    end
end

--玩家出牌
function PdkRoomModule.CMDPlayerOutCard(data)
    Log("CMDPlayerOutCard", data)
    if data.code == 0 then
        local index = PdkRoomModule.GetPlayerLocalSeat(data.data.seatNum)
        local playerData = PdkRoomModule.GetPlayerInfoBySeat(index)
        playerData.pokerNum = data.data.pokerNum
        if this.IsSelfBySeat(data.data.seatNum) then
            if PdkSelfHandCardCtrl.VerificationIsHave(data.data.pokers) then
                Log("++++++++++++++++++++++++++在手上")
                PdkRoomCtrl.PlayerOutCard(data.data)
            else
                Log("++++++++++++++++++++++++++没有在手上")
            end
        else
            PdkRoomCtrl.PlayerOutCard(data.data)
            Log("++++++++++++++++++++++++++其他玩家打牌")
        end
        -- if this.IsSelfBySeat(data.data.seatNum) then
        --     if this.isTuoGuan then
        --         PdkRoomCtrl.PlayerOutCard(data.data)
        --     end
        -- else
        --     PdkRoomCtrl.PlayerOutCard(data.data)
        -- end
        if IsTable(data.data.selfPokers) then
            PdkSelfHandCardCtrl.SyscPdkCards(data.data.selfPokers)
        end
    else
        Log("CMDPlayerOutCard", SystemError.GetText(data.code))
    end
end

--玩家过牌
function PdkRoomModule.CMDPlayerPassCard(data)
    Log("CMDPlayerPassCard", data)
    if data.code == 0 then
        PdkRoomCtrl.PlayerPassCard(data.data)
    else
        Log("CMDPlayerPassCard", SystemError.GetText(data.code))
    end
end

-- --提示
-- function PdkRoomModule.CMDTipOutCard(data)
--     Log("CMDTipOutCard", data)
--     if data.code == 0 then
--         this.SetBiggerPoker({data.data.pokers})
--         local pokers = this.GetBiggerPoker()
--         PdkRoomCtrl.UpHandPokers(pokers)
--     else
--         Log("CMDTipOutCard", SystemError.GetText(data.code))
--     end
-- end

--单局结算
function PdkRoomModule.CMDSingleRecord(data)
    Log("CMDSingleRecord", data)
    if data.code == 0 then
        this.pokerTypeMsg = PdkPokerType.None
        if this.GetRule(PdkRuleType.SLGP) == 1 and not this.isPlayback then
            this.isSeePoker = false
        end
        -- --分数场只有一局
        -- if this.IsGoldRoom() then
        --     this.gameStatus = PdkGameStatus.Over
        -- end
        this.gameStatus = PdkGameStatus.Result
        -- local info = nil
        -- local player = nil
        for i = 1, #data.data.list do
            local info = data.data.list[i]
            local player = this.GetPlayerInfoById(info.playerId)
            if not IsNil(player) then
                player.score = tonumber(info.totalScore)
            end
        end
        PdkRoomCtrl.SingleRecord(data.data)
        --重置房间UI
        PdkRoomCtrl.Reset()
    else
        Log("CMDSingleRecord", SystemError.GetText(data.code))
    end
end

--总结算
function PdkRoomModule.CMDTotalRecord(data)
    LogError("CMDTotalRecord", data)
    if data.code == 0 then
        this.gameStatus = PdkGameStatus.Over
        -- PdkRoomCtrl.StopCheckGps()
        this.totalRecordData = data.data
        --if this.singleRecordIndex == data.data.nowjs then
            --PanelManager.Open(PdkPanelConfig.TotalRecord, data.data)
        --end

        LogError(this.singleRecordIndex, data.data.nowjs)

        if this.singleRecordIndex == 0 and data.data.nowjs == 0 then
            Toast.Show("房间解散")
        elseif this.singleRecordIndex ~= data.data.nowjs then
            Toast.Show("房间解散，牌局结束")
        end
        PanelManager.Open(PdkPanelConfig.TotalRecord, data.data)
    else
        Log("CMDTotalRecord", SystemError.GetText(data.code))
    end
end

--看牌时用
function PdkRoomModule.CMDPlayerSeePoker(data)
    Log("CMDPlayerSeePoker", data)
    if data.code == 0 then
        this.isSeePoker = data.data.isSeePoker == 1
        PdkRoomCtrl.PlayerSeePoker()
    else
        Log("CMDPlayerSeePoker", SystemError.GetText(data.code))
    end
end

--错误码
function PdkRoomModule.CMDErrorMessage(data)
    if not IsNil(PdkErrorMessage[data.data.code]) then
        Toast.Show(PdkErrorMessage[data.data.code])
    end
end

--及时结算分数
function PdkRoomModule.CMDDeductScore(data)
    Log("CMDDeductScore", data)
    if data.code == 0 then
        --玩家自己的ID，用于更新分数
        local userId = UserData.GetUserId()
        local length = #data.data.list
        -- local temp = nil
        for i = 1, length do
            local temp = data.data.list[i]
            local playerData = this.GetPlayerInfoById(temp.playerId)
            if not IsNil(playerData) then
                playerData.score = tonumber(temp.balance)
                --分数房间 更新玩家的分数
                if temp.playerId == userId and this.IsGoldRoom() then
                    UserData.SetGold(temp.balance)
                end

                if temp.change ~= nil then
                    playerData.deductGold = temp.change
                else
                    playerData.deductGold = 0
                end
            end
        end
        PdkRoomCtrl.UpdatePlayerScore()
    else
        Log("CMDDeductScore", SystemError.GetText(data.code))
    end
end

--剩余手牌
function PdkRoomModule.CMDSurplusHandCard(data)
    Log("CMDSurplusHandCard", data)
    if data.code == 0 then
        PdkRoomCtrl.CreateRemainPoker(data.data)
    else
        Log("CMDSurplusHandCard", SystemError.GetText(data.code))
    end
end

--扣分数
function PdkRoomModule.OnPushRoomDeductGold(data)
    Log("OnPushRoomDeductGold", data)
    --type(1支付桌费2游戏盈亏3付费表情)
    if data.code == 0 then
        local isHandleDeductGold = data.data.type == DeductGoldType.Game
        --玩家自己的ID，用于更新分数
        local userId = UserData.GetUserId()
        local length = #data.data.players
        -- local temp = nil
        for i = 1, length do
            local temp = data.data.players[i]
            local playerData = this.GetPlayerInfoById(temp.id)
            if not IsNil(playerData) then
                if temp.gold ~= nil then
                    playerData.score = tonumber(temp.gold)
                    --更新玩家的分数
                    if temp.id == userId then
                        UserData.SetGold(playerData.score)
                    end
                end

                if isHandleDeductGold then
                    if temp.cut ~= nil then
                        playerData.deductGold = tonumber(temp.cut)
                    else
                        playerData.deductGold = 0
                    end
                end
            end
        end
        PdkRoomCtrl.UpdatePlayerScore()
    else
        Log("OnPushRoomDeductGold", SystemError.GetText(data.code))
    end
end

--重连以后发1002
function PdkRoomModule.OnReauthentication()
    if not this.isPlayback then
        if this.IsGoldRoom() then
            --分数场必须进行房间号检测
            this.SendCheckAndJoinedRoom()
        else
            --房卡场，房间未结束也需要进行房间号检测
            if not this.IsOver() then
                this.SendCheckAndJoinedRoom()
            end
        end
    end
end

--异常掉线
function PdkRoomModule.OnDisconnected()
    this.isDisconnected = true
    ChatModule.SetIsCanSend(false)
end

--系统提示
function PdkRoomModule.OnTcpSystemTips(data)
    Log("系统提示：", data)
    if data.code == SystemErrorCode.RoomIsNotExist10003 or SystemErrorCode.GameIsEnd20008 then
        if this.gameStatus == PdkGameStatus.Result then
            --不处理，结算面板有退出游戏
        elseif data.code == SystemTipsErrorCode.GameOver or data.code == SystemTipsErrorCode.EmptyUser then
            Alert.Show(
                    "游戏已结束，返回大厅",
                    function()
                        GameSceneManager.SwitchGameScene(GameSceneType.Lobby)
                    end
            )
        end
    end
end

--处理检测GPS数据
function PdkRoomModule.OnUpdateUserGpsData()
    if not this.isPlayback then
        this.HandleUserGps()
    end
end

--处理检测GPS数据
function PdkRoomModule.OnUpdateUserAddress()
    if not this.isPlayback then
        this.HandleUserGps()
    end
end

function PdkRoomModule.HandleUserGps()
    local location = UserData.GetLocation()
    --更新数据
    GPSModule.UpdatePlayerData(this.uid, location.lat, location.lng, location.address)
    --分派GPS更新事件
    SendEvent(CMD.Game.RoomGpsPlayerUpdate, this.GetGpsPlayerData())
    --上传到服务器
    this.SendGpsData(location.lng, location.lat, location.address)
end

--更新玩家的GPS信息
function PdkRoomModule.OnUpdatePlayersGpsData()
    if not this.isPlayback then
        SendEvent(CMD.Game.RoomGpsPlayerUpdate, this.GetGpsPlayerData())
    end
end

--更新服务器广播gps地址信息
function PdkRoomModule.OnGps(data)
    if data.code == 0 then
        this.isUploadGps = true
    end
end
