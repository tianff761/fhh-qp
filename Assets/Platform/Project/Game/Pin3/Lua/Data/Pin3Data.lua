Pin3Data = {}
local this = Pin3Data
---------------当前主玩家信息-----------------
Pin3Data.uid = ""
Pin3Data.headIcon = ""
Pin3Data.userName = ""
Pin3Data.sex = 0
Pin3Data.frameId = 0
Pin3Data.goldNum = 0
---------------------------------------------
---------------回放信息-----------------------
Pin3Data.isPlayback = false --是否是回放
---------------------------------------------
---------------房间信息-----------------------
Pin3Data.roomId = 0
Pin3Data.groupId = 0
--RoomType：定义
Pin3Data.roomType = RoomType.Lobby
--格式{Pin3RuleType = vale, ......}
Pin3Data.rules = nil
--格式{playWayName = "", juShu = 0, juShuTxt = "", rule = ""}
Pin3Data.parsedRules = nil
--房间当前人数
Pin3Data.curUserNum = 0
--房间总人数
Pin3Data.totalUserNum = 0
--当前局数
Pin3Data.curJuShu = 0
--当前轮数
Pin3Data.curLunShu = 0
--端口
Pin3Data.port = 0
--当前房主
Pin3Data.ownerId = 0
--是否房主
Pin3Data.isOwner = 0
--当前房间状态
Pin3Data.gameStatus = Pin3GameStatus.WaitingPrepare
--当前倒计时
Pin3Data.curDaoJiShi = 0
--总倒计时
Pin3Data.totalDaoJiShi = 0
--当前单注分：以暗注为准，若自己看牌，跟注加倍
Pin3Data.curDanZhuGold = 0
--当前庄家Id
Pin3Data.curZhuangId = 0
--是否已经发牌
Pin3Data.isFaPai = false
Pin3Data.isStartGame = false
--是否是孤注一掷
Pin3Data.isGuZhuYiZhi = false
Pin3Data.gzyzAnimTimes = 0
-------------------------------------------------------
---------------------玩家操作执行------------------------
--当前执行操作的玩家Id
Pin3Data.operUid = 0
--当前执行操作玩家押注
Pin3Data.curYz = 0
--当前玩家执行成功的操作
Pin3Data.operType = Pin3UserOperType.NONE
--当前操作玩家比牌玩家id
Pin3Data.fightIds = nil
--当前赢的所有玩家Id
Pin3Data.winIds = nil
--当前桌面总押注
Pin3Data.curTotalYzGold = 0
------------------------------------------------------

--玩家数据
Pin3Data.userDatas = {}

--牌背类型 默认1
Pin3Data.cardBackType = 2
--桌面背景颜色 默认1
Pin3Data.tableBackType = 1
--------------------------------------------------------
--房卡场解散房间数据
Pin3Data.requestDissolveUid = 0 --发起解散玩家Id
Pin3Data.dissolveStatus = 0 --解散状态 0解散房间失败  1解散中  2解散成功
Pin3Data.dissolveLeftTime = 0 --解散剩余时间
--------------------------------------------------------

Pin3Data.Note = ""

--刚进入房间时数据初始化
function Pin3Data.Init(args)
    LogError(">> Pin3Data.Init > ", args)
    this.Uninit()
    --房间信息
    this.roomId = UserData.GetRoomId()
    this.port = args.line
    this.moneyType = Functions.CheckMoneyType(args.moneyType)
    this.roomType = Functions.CheckRoomType(args.roomType)
    this.groupId = args.groupId
    this.playbackTime = args.time
    this.recordType = args.recordType
    this.totalUserNum = 6
    if this.recordType == nil then
        this.recordType = 1
    end
    if IsBool(args.isPlayback) then
        this.uid = args.userId
        this.isPlayback = args.isPlayback
        Pin3PlaybackManager.Initialize(args.playbackData)
    else
        this.uid = UserData.GetUserId()
        this.isPlayback = false
    end

    this.cardBackType = 2
    this.tableBackType = 1
end

function Pin3Data.Uninit()
    this.uid = ""
    this.headIcon = ""
    this.userName = ""
    this.sex = 0
    this.frameId = 0
    this.goldNum = 0
    this.isPlayback = false --是否是回放
    Pin3PlaybackManager.Clear()
    this.roomId = 0
    this.groupId = 0
    this.roomType = RoomType.Lobby
    this.rules = nil
    this.parsedRules = nil
    this.curUserNum = 0
    this.totalUserNum = 0
    this.curJuShu = 0
    this.curLunShu = 0
    this.port = 0
    this.ownerId = 0
    this.gameStatus = Pin3GameStatus.WaitingPrepare
    this.curDaoJiShi = 0
    this.totalDaoJiShi = 0
    this.curDanZhuGold = 0
    this.curZhuangId = 0
    this.operUid = 0
    this.curYz = 0
    this.operType = Pin3UserOperType.NONE
    this.fightIds = nil
    this.winIds = nil
    this.curTotalYzGold = 0
    this.isFaPai = false
    this.isStartGame = false
    this.gameStatus = Pin3GameStatus.WaitingPrepare
    this.userDatas = {}
    this.isGuZhuYiZhi = false
    this.gzyzAnimTimes = 0
    this.cardBackType = 2
    this.tableBackType = 1
end

function Pin3Data.GetRule(ruleType)
    if ruleType ~= nil and this.rules ~= nil and this.rules[ruleType] ~= nil then
        return this.rules[ruleType]
    end
    return 0
end

--是否是房卡流程
function Pin3Data.IsFkFlowRoom()
    if this.moneyType == MoneyType.Fangka or (this.moneyType == MoneyType.Gold and this.GetRule(Pin3RuleType.juShu) >= 1) then
        return true
    else
        return false
    end
end

--是否是房卡房间
function Pin3Data.IsFkRoom()
    return this.moneyType == MoneyType.Fangka
end


--解析房间数据
function Pin3Data.ParseRoomData(roomData)
    this.roomId = roomData.roomId
    this.curJuShu = roomData.nowjs
    this.curLunShu = roomData.nowCount
    this.ownerId = roomData.ownerId
    this.curDaoJiShi = roomData.countDown
    this.totalDaoJiShi = roomData.totalCD
    this.curDanZhuGold = roomData.needGold
    this.curZhuangId = roomData.zhuangId
    this.isStartGame = roomData.isStartGame ~= nil and roomData.isStartGame == 1
    this.SetGameStatus(roomData.gameStatus)

    this.rules = roomData.rules
    this.parsedRules = Functions.ParseGameRule(GameType.Pin3, roomData.rules, this.GetRule(Pin3RuleType.GPS), " ")
    this.BaseScore = this.parsedRules.baseScore
    this.JudgeIsObserver(roomData.playerMsg)
    --LogError("this.IsObserver", this.IsObserver)
    for _, userInfo in pairs(roomData.playerMsg) do
        --LogError("userInfo", userInfo.pId)
        this.ParseUserData(userInfo)
        this.SetIsAgreeDissolveRoom(userInfo.pId, false)
    end
end

---判断是否为旁观者
function Pin3Data.JudgeIsObserver(playerMsg)
    local isObserver = true
    for i = 1, #playerMsg do
        if i == 1 then
            this.DefaultObservedPlayerID = playerMsg[1].pId
        end
        if Pin3Data.uid == playerMsg[i].pId then
            isObserver = false
        end
    end
    this.SetIsObserver(isObserver)
end

function Pin3Data.SetIsObserver(bool)
    if this.IsObserver and not bool then
        Pin3Manager.ResetAllUserCtrl()
    end
    this.IsObserver = bool
    Pin3BattlePanel.SetObserverTipActive(bool)
end

function Pin3Data.GetSelfUidInGame()
    return this.IsObserver and (this.DefaultObservedPlayerID or playerMsg[1].pId) or this.uid
end

function Pin3Data.SetGameStatus(gameStatus)
    this.gameStatus = gameStatus
    if this.gameStatus == Pin3GameStatus.RoomEnd or this.gameStatus == Pin3GameStatus.JieSuan or this.gameStatus == Pin3GameStatus.WaitingPrepare then
        this.isFaPai = false
    elseif this.gameStatus == Pin3GameStatus.FaPaiBaDi or this.gameStatus == Pin3GameStatus.WaitingUserPerform then
        this.isFaPai = true
        this.isStartGame = true
    end
end
----------------------------------------玩家数据解析---------------------------------------
--解析玩家数据
function Pin3Data.ParseUserData(userData)
    local uid = userData.pId
    this.SetUserId(uid)

    if userData.name ~= nil then
        this.SetUserName(uid, userData.name)
    end
    if userData.img ~= nil then
        this.SetHeadIcon(uid, userData.img)
    end
    if userData.sex ~= nil then
        this.SetSex(uid, userData.sex)
    end
    if userData.sNum ~= nil then
        this.SetSeatNum(uid, userData.sNum)
    end
    this.SetUINum(uid, 0)
    if userData.gold ~= nil then
        this.SetGoldNum(uid, userData.gold)
    end
    if userData.itg ~= nil then
        this.SetYzGold(uid, userData.itg)
    end
    if userData.ir ~= nil then
        this.SetIsPrepare(uid, userData.ir == 1)
    end
    if userData.io ~= nil then
        this.SetIsOnline(uid, userData.io)
    end
    if userData.il ~= nil then
        this.SetIsKanPai(uid, userData.il == 1)
    end
    if userData.gu ~= nil then
        this.SetShuStatus(uid, userData.gu)
    end
    if userData.is ~= nil then
        this.SetIsLiangPai(uid, userData.is == 1)
    end
    if userData.ps ~= nil then
        this.SetOperStatus(uid, userData.ps)
    end
    if userData.pT ~= nil then
        this.SetPaiXing(uid, userData.pT)
    end
    if userData.pIds ~= nil then
        this.SetCardIds(uid, userData.pIds)
    end
    if userData.ijg ~= nil then
        this.SetIsJoinGame(uid, userData.ijg ~= nil and userData.ijg == 1)
    end

    --是否可以看牌处理
    this.SetIsCanKanPai(uid, userData.icl)

    if userData.opType ~= nil then
        this.isOwner = false
        if userData.opType == 1 then
            this.SetIsInRoom(uid, true)
        elseif userData.opType == 2 then
            this.JudgePlayerStandUpBecomeObserver(uid)
            this.SetIsInRoom(uid, false)
        elseif userData.opType == 3 then
            this.SetIsOnline(uid, true)
        elseif userData.opType == 4 then
            if userData.pId ~= nil and userData.isOwner ~= nil and userData.isOwner == 1 then
                this.isOwner = true
                this.ownerId = userData.pId
            end
        end
    else
        this.SetIsInRoom(uid, true)
    end
end

---判断玩家是否站起来变成了旁观者
function Pin3Data.JudgePlayerStandUpBecomeObserver(uid)
    LogError("<color=aqua>JudgePlayerStandUpBecomeObserver</color>", uid)
    if uid == Pin3Data.uid then
        if not this.IsObserver then
            this.SetStandUp(true)
        end
        Pin3Manager.ResetAllUserCtrl()
        Pin3BattlePanel.SetPrepareBtnVisible(false)
        this.SetIsObserver(true)
    end
end

function Pin3Data.SetStandUp(bool)
    this.StandUp = bool
end

function Pin3Data.GetStandUp()
    return this.StandUp
end

function Pin3Data.RemoveUserData(uid)
    this.userDatas[uid] = nil
end

--获取所有的玩家Id
function Pin3Data.GetAllUserIds()
    local ids = {}
    for _, userData in pairs(this.userDatas) do
        table.insert(ids, userData.uid)
    end
    return ids
end

--重置所有玩家数据以便于下一局游戏
function Pin3Data.ResetAllUserData()
    this.isFaPai = false
    this.curTotalYzGold = 0
    this.isGuZhuYiZhi = false
    this.gzyzAnimTimes = 0
    for uid, _ in pairs(this.userDatas) do
        this.SetCardIds(uid, {})
        this.SetYzGold(uid, 0)
        this.SetShuStatus(uid, 0)
        this.SetOperStatus(uid, 0, false)
        this.SetPaiXing(uid, -1)
        this.SetJieSuanGold(uid, 0)
        this.SetOperType(uid, Pin3UserOperType.NONE)
        this.SetIsAgreeDissolveRoom(uid, false)
        this.SetIsCanKanPai(uid, 1)
    end
end

function Pin3Data.SetUserId(id)
    LogError("SetUserId", id)
    if this.userDatas[id] == nil then
        this.userDatas[id] = {isCanKanPai = true}
    end
    this.userDatas[id].uid = id
end

function Pin3Data.SetUserName(id, name)
    this.userDatas[id].name = name
end

function Pin3Data.GetUserName(id)
    return this.userDatas[id].name
end

function Pin3Data.SetHeadIcon(id, headIcon)
    this.userDatas[id].headIcon = headIcon
end

function Pin3Data.GetHeadIcon(id)
    return this.userDatas[id].headIcon
end

function Pin3Data.SetFrameId(id, frameId)
    this.userDatas[id].frameId = frameId
end

function Pin3Data.GetFrameId(id)
    return this.userDatas[id].frameId
end

function Pin3Data.SetSex(id, sex)
    this.userDatas[id].sex = sex
end

function Pin3Data.GetSex(id)
    return this.userDatas[id].sex
end

function Pin3Data.SetSeatNum(id, seatNum)
    this.userDatas[id].seatNum = seatNum
end

function Pin3Data.GetSeatNum(id)
    return this.userDatas[id].seatNum
end

function Pin3Data.SetUINum(id, uiNum)
    this.userDatas[id].uiNum = uiNum
end

function Pin3Data.GetUINum(id)
    return this.userDatas[id].uiNum
end

function Pin3Data.SetGoldNum(id, num)
    this.userDatas[id].goldNum = num
end

function Pin3Data.GetGoldNum(id)
    --LogError("this.userDatas[id]", this.userDatas[id])
    return this.userDatas[id].goldNum
end

function Pin3Data.SetYzGold(id, num)
    this.userDatas[id].touRuGold = num
end

function Pin3Data.GetYzGold(id)
    return this.userDatas[id].touRuGold
end

function Pin3Data.SetIsPrepare(id, bool)
    this.userDatas[id].isPrepare = bool
end

function Pin3Data.GetIsPrepare(id)
    return this.userDatas[id] and this.userDatas[id].isPrepare or false
end

function Pin3Data.SetIsOnline(id, bool)
    this.userDatas[id].isOnline = bool
end

function Pin3Data.GetIsOnline(id)
    return this.userDatas[id].isOnline
end

--玩家是否在房间中
function Pin3Data.SetIsInRoom(id, bool)
    this.userDatas[id].isInRoom = bool
end

function Pin3Data.GetIsInRoom(id)
    local userData = this.userDatas[id]
    if userData ~= nil then
        return userData.isInRoom
    end
    return false
end

function Pin3Data.SetIsKanPai(id, bool)
    this.userDatas[id].isKanPai = bool
end

function Pin3Data.GetIsKanPai(id)
    local userData = this.userDatas[id]
    if userData ~= nil then
        return userData.isKanPai == true
    end
    return false
end

function Pin3Data.GetSelfIsKanPai()
    local userData = this.userDatas[this.uid]
    if userData ~= nil then
        return userData.isKanPai == true
    end
    return false
end

--0否   1弃牌   2输
function Pin3Data.SetShuStatus(id, status)
    this.userDatas[id].shuStatus = status
end

--0否   1弃牌   2输
function Pin3Data.GetShuStatus(id)
    return this.userDatas[id].shuStatus
end

--增加字段 isUser  0 表示不是玩家主动弃牌（系统弃牌，比如超时），1 表示玩家主动弃牌 
function Pin3Data.SetQiPaiType(id, qiPaiType)
    this.userDatas[id].qiPaiType = qiPaiType
end

--0为系统弃牌，否则显示玩家主动弃牌
function Pin3Data.GetQiPaiType(id)
    return this.userDatas[id].qiPaiType
end


function Pin3Data.SetIsLiangPai(id, bool)
    this.userDatas[id].isLiangPai = bool
end

function Pin3Data.GetIsLiangPai(id)
    return this.userDatas[id].isLiangPai
end

--status:0等待操作  1操作中
function Pin3Data.SetOperStatus(id, status)
    Log("设置操作状态", id, status)
    this.userDatas[id].operStatus = status
end

function Pin3Data.GetOperStatus(id)
    return this.userDatas[id].operStatus
end

function Pin3Data.SetPaiXing(id, px)
    this.userDatas[id].paiXing = px
end

function Pin3Data.GetPaiXing(id)
    return this.userDatas[id].paiXing
end

function Pin3Data.SetCardIds(id, ids)
    this.userDatas[id].cardIds = ids
end

function Pin3Data.GetCardIds(id)
    return this.userDatas[id].cardIds
end

--设置结算分数
function Pin3Data.SetJieSuanGold(id, gold)
    this.userDatas[id].jieSuanGold = gold
end

function Pin3Data.GetJieSuanGold(id)
    return this.userDatas[id].jieSuanGold
end

function Pin3Data.SetIsAutoYaZhu(id, isAuto)
    this.userDatas[id].isAutoYz = isAuto
end

function Pin3Data.GetIsAutoYaZhu(id)
    return this.userDatas[id] and this.userDatas[id].isAutoYz or false
end

function Pin3Data.SetOperType(id, operType)
    this.userDatas[id].operType = operType
end

function Pin3Data.GetOperType(id)
    return this.userDatas[id].operType
end

--是否加入游戏(房卡场)
function Pin3Data.SetIsJoinGame(id, bool)
    this.userDatas[id].isJoinGame = bool
end

--
function Pin3Data.SetIsCanKanPai(id, value)
    local playerData = this.userDatas[id]
    if playerData ~= nil then
        if value ~= nil and value == 0 then
            playerData.isCanKanPai = false
        else
            playerData.isCanKanPai = true
        end
    end
end

function Pin3Data.GetIsCanKanPai(id)
    local playerData = this.userDatas[id]
    if playerData ~= nil then
        return playerData.isCanKanPai
    end
    return true
end

function Pin3Data.GetIsJoinGame(id)
    return this.userDatas[id].isJoinGame
end

function Pin3Data.SetIsAgreeDissolveRoom(id, bool)
    this.userDatas[id].isAgreeDissolveRoom = bool
end

function Pin3Data.GetIsAgreeDissolveRoom(id, bool)
    return this.userDatas[id].isAgreeDissolveRoom
end
-------------------------------------------------------------------------------------------
-------------------------------------玩家操作状态解析----------------------------------------
function Pin3Data.ParseUserOper(data)
    this.operUid = data.pId
    this.operType = data.opType
    --LogError("<color=aqua>SetCurYZ</color>", data.ig)
    this.curYz = data.ig or this.curYz
    Pin3BattlePanel.UpdateBtnsText(this.operUid)
    this.curDanZhuGold = this.operUid == Pin3Data.uid and (data.needGold or this.curDanZhuGold) or this.curDanZhuGold
    this.fightIds = data.fightIds
    this.winIds = data.winIds
    this.isGuZhuYiZhi = data.isGuZhuYiZhi ~= nil and data.isGuZhuYiZhi == 1
    if this.isGuZhuYiZhi == false then
        this.gzyzAnimTimes = 0
    end
    if data.poolNum ~= nil then
        this.curTotalYzGold = data.poolNum
    end
    --服务器主推强制比牌时，没有this.operUid字段
    if this.operUid ~= nil and this.operUid > 0 and this.userDatas[this.operUid] ~= nil then
        this.SetOperType(this.operUid, this.operType)
        this.SetCardIds(this.operUid, data.pIds)
        this.SetPaiXing(this.operUid, data.pT)
        this.SetGoldNum(this.operUid, data.gold)
        if data.itg ~= nil and tonumber(data.itg) > 0 then
            this.SetYzGold(this.operUid, data.itg)
        end

        --设置弃牌状态
        if this.operType == Pin3UserOperType.QiPai then
            this.SetShuStatus(this.operUid, 1)
            --增加字段 isUser  0 表示不是玩家主动弃牌，1 表示玩家主动弃牌 
            this.SetQiPaiType(this.operUid, data.isUser)
        elseif this.operType == Pin3UserOperType.KanPai then
            this.SetIsKanPai(this.operUid, true)
        end
    end


    --设置比牌输状态
    if GetTableSize(this.fightIds) > 0 and GetTableSize(this.winIds) > 0 then
        local isWin = false
        for _, fightId in pairs(this.fightIds) do
            isWin = false
            for _, winId in pairs(this.winIds) do
                if fightId == winId then
                    isWin = true
                    break
                end
            end
            if not isWin then
                this.SetShuStatus(fightId, 2)
            end
        end
    end
end
--------------------------------------------------------------------------------------------
-------------------------------------桌面操作状态解析----------------------------------------
function Pin3Data.ParseTableOperStatus(data)
    this.SetGameStatus(data.gameStatus)
    this.curDaoJiShi = data.countDown
    this.totalDaoJiShi = data.totalCD
    this.curJuShu = data.nowjs
    this.curLunShu = data.nowCount
    this.curZhuangId = data.zhuangId
    this.operUid = data.opId
    this.curDanZhuGold = data.needGold
    this.curTotalYzGold = data.poolNum
    this.RevertCurrentYz(data.gameStatus)
    if GetTableSize(data.playerMsg) > 0 then
        for _, item in pairs(data.playerMsg) do
            this.SetYzGold(item.id, item.itg)
            this.SetIsPrepare(item.id, item.ir == 1)
            this.SetIsKanPai(item.id, item.il == 1)
            this.SetShuStatus(item.id, item.gu)
            this.SetOperStatus(item.id, item.ps)
            this.SetIsAutoYaZhu(item.id, item.iaa == 1)
            this.SetGoldNum(item.id, item.gold)
            this.SetIsJoinGame(item.id, item.ijg ~= nil and item.ijg == 1)
            this.SetIsCanKanPai(item.id, item.icl)
        end
    end
end

---还原当前押注（还原为底分）
function Pin3Data.RevertCurrentYz(gameStatus)
    if gameStatus == Pin3GameStatus.JieSuan then
        --LogError("<color=aqua>RevertCurrentYz</color>")
        this.curYz = Pin3Data.BaseScore
    end
end

--------------------------------------------------------------------------------------------
-------------------------------------结算信息解析----------------------------------------
function Pin3Data.ParseJieSuanInfo(data)
    if GetTableSize(data.msgs) > 0 then
        for _, itemData in pairs(data.msgs) do
            Pin3Data.SetGoldNum(itemData.pId, itemData.gold)
            Pin3Data.SetJieSuanGold(itemData.pId, itemData.winGold)
            Pin3Data.SetCardIds(itemData.pId, itemData.pIds)
            Pin3Data.SetPaiXing(itemData.pId, itemData.pT)
            Pin3Data.SetOperType(itemData.pId, Pin3UserOperType.NONE)
        end
    end
end

--解析回放的单结算数据
function Pin3Data.ParseJieSuanInfoByPlayback(data)
    if GetTableSize(data.msgs) > 0 then
        for _, itemData in pairs(data.msgs) do
            Pin3Data.SetGoldNum(itemData.pId, itemData.gold)
            Pin3Data.SetJieSuanGold(itemData.pId, itemData.winGold)
            Pin3Data.SetCardIds(itemData.pId, itemData.pIds)
            Pin3Data.SetPaiXing(itemData.pId, itemData.pT)
            Pin3Data.SetOperType(itemData.pId, Pin3UserOperType.NONE)
        end
    end
end
--------------------------------------------------------------------------------------------

