--麻将数据管理
--后面取消掉key-value存储方式，使用显式变量
MahjongDataMgr = {
    --================================
    --整个游戏生命周期
    --------------------------------
    --牌数据
    cardDatas = {},
    --================================
    --整个房间生命周期
    --------------------------------
    --是否回放
    isPlayback = false,
    --房间是否结束
    isRoomEnd = false,
    --房间ID
    roomId = 0,
    --座位号1玩家的ID
    userId = nil,
    --座位号1玩家的服务器座位号
    userSeatNumber = 1,
    --房主，玩家ID
    owner = nil,
    --组织Id，亲友圈或者分数娱乐场
    groupId = nil,
    --显示服务器站点线路
    serverLine = 0,
    --1大厅战绩回放，2是亲友圈战绩回放
    recordType = 1,
    --------------------------------
    --以下为规则解析的固定数据，不主动清除，直接设置使用
    --玩法规则对象
    rules = nil,
    --规则字符串
    ruleKey = nil,
    --房间Gps类型
    gpsType = nil,
    --玩法类型，解析规则获得
    playWayType = Mahjong.PlayWayType.YaoJiSiRen,
    --总局数，解析规则获得
    gameTotal = 1,
    --房间类型，进入房间时获取
    roomType = RoomType.Lobby,
    --货币类型，进入房间时获取
    moneyType = MoneyType.Fangka,
    --麻将人数，解析规则获得
    playerTotal = 4,
    --麻将牌数，解析规则获得
    cardTotal = 13,
    --房牌数量，解析规则获得
    fangTotal = 3,
    --番数，解析规则获得
    multiple = 2,
    --牌局是否需要定缺，解析规则获得
    isNeedDingQue = false,
    --是否显示胡牌提示，属于配置
    isConfigTingTips = false,
    --换牌数量，解析规则获得
    changeCardTotal = 0,
    --换牌类型，单色换，任意换，解析规则获得
    changeCardType = MahjongChangeCardType.SingleColor,
    --是否是幺鸡玩法
    isYaoJiPlayWay = false,
    --分数场的底分
    baseScore = 0,
    --是否对对胡2番
    isDuiDuiHuLiangFan = false,
    --是否检测中张
    isCheckZhongZhang = false,
    --是否检测门清
    isCheckMenQing = false,
    --是否检测金钩钓
    isCheckJinGouDiao = false,
    --是否检查幺九
    isCheckYaoJiu = false,
    --是否检查将对
    isCheckJiangDui = false,
    --听用牌
    tingYongCardDict = {},
    --================================
    --单局生命周期
    --------------------------------
    --游戏状态
    gameState = MahjongGameStateType.Waiting,
    --服务器时间戳，单位毫秒
    serverTimeStamp = nil,
    --服务器更新时间，即收到服务器的时间，单位秒
    serverUpdateTime = 0,
    --是否可以发送数据
    isCandSend = false,
    --当前局数
    gameIndex = 0,
    --当前局的庄家，玩家ID
    zhuang = nil,
    --骰子
    touzi = 0,
    --当前局剩余牌数
    surplusCards = 0,
    --------------------------------
    --玩家1的数据
    --操作状态
    operateState = -1,
    --桌子状态
    tableState = 0,
    --------------------------------
    --所有玩家定缺标识
    isAllDingQue = false,
    --所有玩家坐齐
    isAllSeat = false,
    --是否有解散申请
    isHasDismiss = false,
    --是否在解散中，解散中桌子中间的倒计时不处理
    isDismissing = false,
    --================================
    --手动清理数据，房间结束时清理
    --------------------------------
    --结算数据
    settlementData = nil,
    --结算数据备份
    settlementDataCache = nil,
    --结算数据查看的局数
    settlementIndex = 0,
    --================================
    --是否听牌提示选项，通过设置面板设置
    isTingTips = false,
    --是否都准备，在推送准备时处理
    isAllReady = false,
    --比赛场等级
    matchLevel = 0,
    --比赛场ID
    matchId = 1,
    --准入
    zhunru = 0,
    --================================
    ---宽屏手牌适配
    MahjongHandCardWideScreenAdaptScale = 0,
    ---杠选牌
    LastShowCard1 = 0,
    LastShowCard2 = 0,
}

local this = MahjongDataMgr

--小局数据重置
function MahjongDataMgr.Reset()
    --LogError("<color=aqua>MahjongDataMgr.Reset()</color>")
    this.ClearChangeCards()
    this.ClearHuTips()
    this.ClearOperation()
    this.surplusCards = 0
    this.operateState = -1
    this.isAllDingQue = false

    local playerData = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = this.playerDatas[i]
        if playerData ~= nil then
            playerData:Reset()
        end
    end
end

--房间数据清除，退出房间才调用
function MahjongDataMgr.Clear()
    this.Reset()
    this.isRoomEnd = false
    this.isCandSend = false
    this.gameState = MahjongGameStateType.Waiting
    this.roomId = 0
    this.settlementData = nil
    this.settlementDataCache = nil
    this.settlementIndex = 0
    this.isAllSeat = false
    this.isTingTips = false
end

--房间数据销毁
function MahjongDataMgr.Destroy()
    this.Clear()
    this.cardDatas = {}
end

--清除相关信息通过初始游戏的时候
function MahjongDataMgr.ClearByInit()
    this.gameState = MahjongGameStateType.Waiting
    this.isRoomEnd = false
    this.settlementData = nil
    this.settlementDataCache = nil
    this.settlementIndex = 0
end

-----------------------------------------------------
--
--玩家数据，房间数据
MahjongDataMgr.playerDatas = {}
--主玩家数据，房间数据，外部不能直接调用该数据，可以封装方法调用
MahjongDataMgr.mainPlayerData = nil

--清除玩家数据
function MahjongDataMgr.ClearPlayerDatas()
    this.playerDatas = {}
    this.mainPlayerData = nil
end

--================================================================
--
--设置房间ID
function MahjongDataMgr.SetRoomId(id)
    this.roomId = id
end

--设置主玩家ID
function MahjongDataMgr.SetUserId(id)
    this.userId = id
end

--设置房间状态
function MahjongDataMgr.SetGameState(gameState)
    this.gameState = gameState
end

--设置庄
function MahjongDataMgr.SetZhuang(id)
    this.zhuang = id
end

--房间是否开始，如果游戏局数大于1表示房间已经开始，分数场无限局除外
function MahjongDataMgr.IsRoomBegin()
    if this.IsGoldRoomInfinite() then
        return MahjongDataMgr.IsGameBegin()
    else
        return this.gameIndex > 0
    end
end

--单局是否结束
function MahjongDataMgr.IsGameEnd()
    return this.gameState == MahjongGameStateType.End
end

--单局是否开始
function MahjongDataMgr.IsGameBegin()
    return this.gameState > MahjongGameStateType.End
end

--是否是分数房间
function MahjongDataMgr.IsGoldRoom()
    return this.moneyType == MoneyType.Gold
end

--是否是分数有限房间
function MahjongDataMgr.IsGoldRoomFinite()
    return this.moneyType == MoneyType.Gold and this.gameTotal ~= -1
end

--是否是分数无限房间，局数为-1
function MahjongDataMgr.IsGoldRoomInfinite()
    return this.moneyType == MoneyType.Gold and this.gameTotal == -1
end

--是否是比赛场房间
function MahjongDataMgr.IsMatchRoom()
    return this.roomType == RoomType.Match
end

--是否是房主
function MahjongDataMgr.IsRoomOwner()
    return this.userId == this.owner
end

--更新GPS
function MahjongDataMgr.UpdateMainPlayerGps(args)
    local playerData = this.playerDatas[1]
    if playerData ~= nil then
        playerData:SetGps(args)
    end
end

--设置是否听牌
function MahjongDataMgr.IsTingTips()
    return this.isTingTips and this.isConfigTingTips
end

--================================================================
--
--设置玩家数据通过进入房间数据
function MahjongDataMgr.SetRoomDataByJoinRoom(data)
    this.roomId = data.id
    this.rules = data.rules
    this.UpdateServerTime(data.time)
    this.groupId = data.clubOrTeaId
    this.gameIndex = data.index
    this.owner = data.owner
    this.isHasDismiss = data.dismiss ~= nil and data.dismiss == 1
    this.matchLevel = data.mLv
    this.matchId = data.mId
    this.zhunru = data.zr
    --清除玩家数据后重新设置
    this.playerDatas = {}
    this.mainPlayerData = nil
    --解析玩法规则
    this.ParsePlayWayRule(this.rules)
    --设置听用，当前听用固定
    this.tingYongCardDict = {}
    if this.isYaoJiPlayWay then
        local tingYongList = MahjongConst.YaoJiTingYong[this.tingYongNum]
        if tingYongList == nil then
            tingYongList = MahjongConst.YaoJiTingYong[4]
        end
        for i = 1, #tingYongList do
            this.tingYongCardDict[tingYongList[i]] = true
        end
        MahjongHelper.SetTingYong(tingYongList)
        --
        this.SetTingTipsRuleType()
    end
    
    --更新玩家数据
    this.UpdatePlayerDataByJoinRoom(data.players)

end

--设置听牌提示的规则类型
function MahjongDataMgr.SetTingTipsRuleType()
    --设置听牌提示的规则类型
    local types = {}
    local fanNums = {}

    table.insert(types, MahjongRuleType.DuiDuiHu)
    if this.isDuiDuiHuLiangFan then
        table.insert(fanNums, 2)
    else
        table.insert(fanNums, 1)
    end

    table.insert(types, MahjongRuleType.ZhongZhang)
    if this.isCheckZhongZhang then
        table.insert(fanNums, 1)
    else
        table.insert(fanNums, 0)
    end

    table.insert(types, MahjongRuleType.MengQing)
    if this.isCheckMenQing then
        table.insert(fanNums, 1)
    else
        table.insert(fanNums, 0)
    end

    table.insert(types, MahjongRuleType.JinGouDiao)
    if this.isCheckJinGouDiao then
        table.insert(fanNums, 1)
    else
        table.insert(fanNums, 0)
    end

    table.insert(types, MahjongRuleType.YaoJiu)
    if this.isCheckYaoJiu then
        table.insert(fanNums, 1)
    else
        table.insert(fanNums, 0)
    end

    table.insert(types, MahjongRuleType.JiangDui)
    if this.isCheckJiangDui then
        table.insert(fanNums, 1)
    else
        table.insert(fanNums, 0)
    end
    MahjongHelper.ClearRuleFanNum()
    MahjongHelper.SetRuleFanNums(types, fanNums)
end

--解析玩法规则
function MahjongDataMgr.ParsePlayWayRule(rules)
    if rules == nil then
        LogWarn(">> MahjongDataMgr.ParsePlayWayRule > rules == nil.")
        return
    end

    --LogError("<color=aqua>处理玩法信息</color>")
    this.playWayType = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.PlayWayType, Mahjong.PlayWayType.YaoJiSiRen)
    this.gameTotal = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.GameTotal, 1)
    this.playerTotal = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.PlayerTotal, 4)
    this.cardTotal = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.CardTotal, 13)
    this.fangTotal = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.FangTotal, 3)
    this.isNeedDingQue = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.DingQue, 0) == 1
    this.changeCardTotal = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.ChangeCardTotal, 0)
    this.changeCardType = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.ChangeCardType, MahjongChangeCardType.SingleColor)
    this.multiple = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.Multiple, 2)
    this.baseScore = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.Score, 50)
    this.ruleKey = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.Key, nil)

    this.isDuiDuiHuLiangFan = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.DuiDuiHuLiangFan, 0) == 1
    this.isCheckZhongZhang = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.ZhongZhang, 0) == 1
    this.isCheckMenQing = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.MenQing, 0) == 1
    this.isCheckJinGouDiao = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.JinGouDiao, 0) == 1

    local temp = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.YaoJiuJiangDui, 0) == 1
    this.isCheckYaoJiu = temp or MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.YaoJiu, 0) == 1
    this.isCheckJiangDui = temp or MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.JiangDui, 0) == 1

    --处理是否为幺鸡玩法
    this.isYaoJiPlayWay = MahjongUtil.CheckYaoJiPlayWayType(this.playWayType)
    --听用数量
    this.tingYongNum = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.TingTotal, 4)
    --处理听牌提示
    this.isConfigTingTips = MahjongUtil.GetPlayWayRule(rules, Mahjong.RuleType.TingPaiTiShi, 0) == 1
    this.isConfigTingTips = this.isConfigTingTips and (not this.isPlayback)
end

--更新服务器时间
function MahjongDataMgr.UpdateServerTime(time)
    --回放使用设备时间
    if this.isPlayback then
        this.serverTimeStamp = os.time()
    else
        this.serverTimeStamp = time
    end
    this.serverUpdateTime = Time.realtimeSinceStartup
end

--更新玩家数据通过加入房间数据
function MahjongDataMgr.UpdatePlayerDataByJoinRoom(players)
    if players == nil or not IsTable(players) then
        return
    end

    --更新主玩家数据
    local tempPlayerData = nil
    local length = #players
    for i = 1, length do
        tempPlayerData = players[i]
        if tempPlayerData ~= nil and tempPlayerData.id == this.userId then
            this.userSeatNumber = tempPlayerData.seat
            break
        end
    end
    --处理是否全部坐齐
    MahjongDataMgr.isAllSeat = length == MahjongDataMgr.playerTotal
    local playerData = nil
    for i = 1, length do
        tempPlayerData = players[i]
        this.InternalUpdatePlayerData(tempPlayerData)
    end
end

--内部更新玩家数据
function MahjongDataMgr.InternalUpdatePlayerData(data)
    local playerData = this.GetPlayerDataById(data.id)
    playerData.id = data.id
    playerData.seat = data.seat
    playerData.seatIndex = MahjongUtil.GetIndexBySeatNumber(playerData.seat)
    playerData.name = Functions.CheckPlayerName(data.name)
    playerData.gender = Functions.CheckPlayerGender(data.gender)
    playerData.headUrl = Functions.CheckPlayerHeadUrl(data.head)
    playerData.headFrame = Functions.CheckPlayerHeadFrame(data.frame)
    if this.moneyType == MoneyType.Gold then
        playerData.gold = tonumber(data.score)
    else
        playerData.score = tonumber(data.score)
    end
    playerData.ip = data.ip
    playerData:SetGps(data.gps)
    playerData.online = data.online
    playerData.entrance = data.entrance
    playerData.ready = data.ready
    playerData.join = data.join
    --根据座位号设置玩家
    this.playerDatas[playerData.seatIndex] = playerData
end

--内部更新玩家数据，通过增加数据
function MahjongDataMgr.InternalUpdatePlayerDataByAdd(data)
    local name = Functions.CheckPlayerName(data.name)
    local playerData = this.GetPlayerDataById(data.id)
    if not this.IsGoldRoom() then
        --进入提示处理，分数场不提示，join为彻底进入
        if data.id ~= MahjongDataMgr.userId and (playerData.id == nil or playerData.id ~= data.id) and data.join == 1 then
            Toast.Show(name .. "进入房间")
        end
    end

    this.InternalUpdatePlayerData(data)
end

--内部删除玩家数据
function MahjongDataMgr.InternalDeletePlayerData(playerId)
    local playerData = this.playerDatas[playerId]
    if playerData ~= nil then
        if not this.IsGoldRoom() then
            --离开房间提示，分数场不提示
            if playerId ~= MahjongDataMgr.userId then
                if playerData.name ~= nil then
                    Toast.Show(playerData.name .. "离开房间")
                end
            end
        end
        --删除玩家数据
        this.playerDatas[playerData.seatIndex] = nil
        this.playerDatas[playerData.id] = nil
    end
end

--更新变更玩家数据
function MahjongDataMgr.UpdatePlayerData(data)
    --新增玩家
    if data.add ~= nil then
        this.InternalUpdatePlayerDataByAdd(data.add)
    end
    --移除玩家
    if data.delete ~= nil then
        --有玩家移除，就需要清除所有现在的玩家的准备状态
        this.ClearPlayerReady()
        this.InternalDeletePlayerData(data.delete)
    end

    --检测人数，人数不对，就清除isAllSeat变量
    local playerNum = 0
    for i = 1, MahjongDataMgr.playerTotal do
        if this.playerDatas[i] ~= nil then
            playerNum = playerNum + 1
        end
    end
    if playerNum ~= MahjongDataMgr.playerTotal then
        MahjongDataMgr.isAllSeat = false
    end
end

--通过结算数据，更新玩家信息
function MahjongDataMgr.GetNewPlayerDataBySettlement(data)
    local playerData = MahjongPlayerData.New()
    playerData.id = data.id
    playerData.seat = data.seat
    playerData.seatIndex = MahjongUtil.GetIndexBySeatNumber(playerData.seat)
    playerData.name = Functions.CheckPlayerName(data.n)
    playerData.headUrl = Functions.CheckPlayerHeadUrl(data.h)
    playerData.headFrame = Functions.CheckPlayerHeadFrame(data.hf)
    playerData.dingQue = MahjongUtil.CheckDingQueType(data.dq)
    return playerData
end

--获取玩家1的数据
function MahjongDataMgr.GetMainPlayerData()
    if this.mainPlayerData == nil then
        this.mainPlayerData = MahjongDataMgr.GetPlayerDataById(this.userId)
    end
    return this.mainPlayerData
end

--获取当前房间中玩家人数
function MahjongDataMgr.GetPlayerCount()
    local count = 0
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        local playerData = this.playerDatas[i]
        if playerData ~= nil and playerData.id ~= nil then
            count = count + 1
        end
    end
    return count
end

--通过玩家ID获取玩家对象，所有数据都从该处获取
function MahjongDataMgr.GetPlayerDataById(playerId)
    local playerData = this.playerDatas[playerId]
    if playerData == nil then
        playerData = MahjongPlayerData.New()
        this.playerDatas[playerId] = playerData
    end
    return playerData
end

--获取玩家的性别
function MahjongDataMgr.GetPlayerGender(playerId)
    local playerData = this.playerDatas[playerId]

    --默认使用女声
    if playerData == nil or playerData.id == nil then
        return Global.GenderType.Female
    else
        return playerData.gender
    end
end

--检测是否存在玩家数据
function MahjongDataMgr.CheckExistPlayerData()
    local playerData = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = this.playerDatas[i]
        if playerData ~= nil then
            return true
        end
    end
    return false
end

--================================================================
--
--游戏开始时清除数据
function MahjongDataMgr.ClearByGameBegin()
    this.settlementData = nil
    this.settlementDataCache = nil
end

--游戏开始更新数据，操作状态会单独处理
function MahjongDataMgr.UpdateDataByGameBegin(data)
    this.gameIndex = data.index
    this.touzi = data.touzi
    this.zhuang = data.zhuang
    this.surplusCards = data.cards
    this.UpdateServerTime(data.time)

    --更新打牌操作相关
    this.Operation.type = data.type
    this.Operation.playerId = data.id
    this.Operation.card = data.card

    if data.players ~= nil then
        local length = #data.players
        local tempData = nil
        for i = 1, length do
            tempData = data.players[i]
            if tempData.id == MahjongDataMgr.userId then
                this.UpdateMainPlayerOperateData(tempData)
            end

            if tempData ~= nil then
                this.InternalUpdatePlayerDataByGameBegin(tempData)
            end
        end
    end

end

--内部游戏开始更新玩家数据
function MahjongDataMgr.InternalUpdatePlayerDataByGameBegin(data)
    local playerData = this.GetPlayerDataById(data.id)
    playerData.id = data.id
    playerData.seat = data.seat
    playerData.seatIndex = MahjongUtil.GetIndexBySeatNumber(playerData.seat)
    playerData.score = tonumber(data.score)
    if this.moneyType == MoneyType.Gold then
        playerData.gold = tonumber(data.score)
    else
        playerData.score = tonumber(data.score)
    end

    playerData.state = data.state
    playerData.tState = data.tState
    playerData.huType = data.huType --胡牌类型
    playerData.specialHuEffect = data.specialHuEffect --特殊胡牌特效类型
    playerData.huIndex = data.huIndex
    playerData.huFan = data.huFan
    playerData.dingQue = MahjongUtil.CheckDingQueType(data.dq)
    playerData.trust = MahjongUtil.CheckTrust(data.trust)
    --
    playerData.ready = MahjongReadyType.Ready
    playerData.join = MahjongJoinType.Join
    --根据座位号设置玩家，在游戏开始中再设置一次，用于容错
    this.playerDatas[playerData.seatIndex] = playerData
end

--更新玩家准备状态
function MahjongDataMgr.UpdatePlayerReady(data)
    if data == nil or data.players == nil then
        return
    end
    this.isAllReady = true
    local length = #data.players
    local temp = nil
    for i = 1, length do
        temp = data.players[i]
        local playerData = this.GetPlayerDataById(temp.id)
        playerData.ready = temp.ready
        this.isAllReady = this.isAllReady and playerData.ready == MahjongReadyType.Ready
    end
end

--清除现有玩家的准备状态
function MahjongDataMgr.ClearPlayerReady()
    this.isAllReady = false
    local playerData = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = this.playerDatas[i]
        if playerData ~= nil then
            playerData.ready = MahjongReadyType.No
        end
    end
end

--主玩家是否准备
function MahjongDataMgr.IsReady()
    return this.GetMainPlayerData().ready == ReadyType.Ready
end

--更新玩家在线状态
function MahjongDataMgr.UpdatePlayerOnline(data)
    if data == nil or data.players == nil then
        return
    end
    local length = #data.players
    local temp = nil
    for i = 1, length do
        temp = data.players[i]
        local playerData = this.GetPlayerDataById(temp.id)
        playerData.online = temp.online
    end
end

--玩家数据更新推送
function MahjongDataMgr.UpdateDataByPlayerDataUpdate(data)
    if data == nil or data.players == nil then
        return
    end
    local length = #data.players
    local temp = nil
    for i = 1, length do
        temp = data.players[i]
        local playerData = this.GetPlayerDataById(temp.id)
        playerData:SetGps(temp.gps)
    end
end

--更新主玩家的托管状态
function MahjongDataMgr.UpdateMainPlayerTrust(data)
    local playerData = this.playerDatas[1]
    if playerData ~= nil then
        playerData.trust = 0
    end
end

--更新玩家的分数
--type(1支付桌费2游戏盈亏3付费表情)
function MahjongDataMgr.UpdatePlayerGold(data)
    if data == nil or data.players == nil then
        return
    end
    local isHandleDeductGold = data.type == DeductGoldType.Game
    --玩家自己的ID，用于更新分数
    local userId = UserData.GetUserId()
    local length = #data.players
    local temp = nil
    for i = 1, length do
        temp = data.players[i]
        local playerData = this.GetPlayerDataById(temp.id)

        if temp.gold ~= nil then
            playerData.gold = tonumber(temp.gold)
            --更新玩家的分数
            if temp.id == userId then
                UserData.SetGold(playerData.gold)
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

--更新换张相关数据
function MahjongDataMgr.UpdateDataByChangeCard(data)
    Log("-------------------------------MahjongDataMgr.UpdateDataByChangeCard")
    if data == nil or data.players == nil then
        return
    end
    local length = #data.players
    local temp = nil
    for i = 1, length do
        temp = data.players[i]
        local playerData = this.GetPlayerDataById(temp.id)
        if temp.out == nil or #temp.out < 1 then
            playerData.changeCardsOut = nil
        else
            playerData.changeCardsOut = temp.out
        end
        if temp.back == nil or #temp.back < 1 then
            playerData.changeCardsBack = nil
        else
            playerData.changeCardsBack = temp.back
        end
    end
end



--================================================================
--
--通过ID获取牌数据
function MahjongDataMgr.GetCardData(id)
    local temp = tonumber(id)
    local cardData = this.cardDatas[temp]
    if cardData == nil then
        cardData = MahjongCardData.New()
        cardData:SetId(temp)
        this.cardDatas[temp] = cardData
    end
    return cardData
end

--未知牌，-1牌
MahjongDataMgr.UnknownCardData = MahjongDataMgr.GetCardData(-1)

--================================================================
--
--清除换张数据
function MahjongDataMgr.ClearChangeCards()
    local playerData = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = this.playerDatas[i]
        if playerData ~= nil then
            playerData.changeCardsOut = nil
            playerData.changeCardsBack = nil
        end
    end
end

--清除换张数据，在游戏开始协议
function MahjongDataMgr.ClearChangeCardsByGameBegin()
    if MahjongAnimMgr.isPlayingHuanAnim == false then
        local playerData = nil
        for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
            playerData = this.playerDatas[i]
            if playerData ~= nil then
                playerData.changeCardsBack = nil
            end
        end
    end
end

--清除换张，换出牌数据
function MahjongDataMgr.ClearChangeCardsOutData()
    local playerData = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = this.playerDatas[i]
        if playerData ~= nil then
            playerData.changeCardsOut = nil
        end
    end
end

-----------------------------------------------------
--
--胡牌提示数据，单局数据
MahjongDataMgr.HuTips = {
    --提示数据
    tipsData = nil,
    --胡牌数据，通过打的牌解析出来的，即只有打了牌才更新按钮和该数据
    huData = nil,
    --缓存的中间牌
    midCards = nil,
}

--设置胡牌提示数据
function MahjongDataMgr.SetHuTips(huTips)
    if huTips == nil or #huTips < 1 then
        this.HuTips.tipsData = nil
    else
        this.HuTips.tipsData = {}
        local temp = nil
        for i = 1, #huTips do
            temp = huTips[i]
            this.HuTips.tipsData[temp.key] = temp.hu
        end
    end
end

--根据打出牌更新
function MahjongDataMgr.UpdateHuTips(cardKey)
    if this.HuTips.tipsData ~= nil then
        --字符串25,4;28,4；key+剩余数量
        this.HuTips.huData = this.HuTips.tipsData[cardKey]
    else
        this.HuTips.huData = nil
    end
end

--清理提示数据
function MahjongDataMgr.ClearHuTips()
    this.HuTips.tipsData = nil
    this.HuTips.huData = nil
    this.HuTips.midCards = nil
end

--设置胡牌听牌时的牌张数据
function MahjongDataMgr.SetHuTingCardData(mid)
    this.HuTips.midCards = mid
end

--设置听牌提示的缓存牌数据
function MahjongDataMgr.SetHuTingCardByCardData(midCards)
    this.HuTips.midCards = {}
    local length = #midCards
    for i = 1, length do
        if midCards[i] ~= nil then
            table.insert(this.HuTips.midCards, midCards[i].id)
        end
    end
end

--检测听牌提示相关的牌张是否改变，改变会处理听牌相关
function MahjongDataMgr.CheckHuTingCardIsChanged(mid)
    if this.HuTips.midCards ~= nil then
        if mid ~= nil then
            local midLength = #mid
            local midCardsLength = #this.HuTips.midCards
            --长度不相等
            if midCardsLength ~= midLength then
                return true
            end
            --对比ID
            local id = 0
            local isExist = false
            local isChanged = false
            for i = 1, midLength do
                id = mid[i]
                isExist = false
                for j = 1, midCardsLength do
                    if this.HuTips.midCards[j] == id then
                        isExist = true
                        break
                    end
                end
                if not isExist then
                    isChanged = true
                    break
                end
            end
            return isChanged
        else
            if #this.HuTips.midCards > 0 then
                return true
            end
        end
    else
        if mid ~= nil and #mid > 0 then
            return true
        end
    end

    return false
end

-----------------------------------------------------
--
--操作数据相关，单局数据
MahjongDataMgr.Operation = {
    --操作类型
    type = nil,
    --打牌或者操作玩家ID
    playerId = nil,
    --操作的关键值
    card = nil,

    --状态
    state = MahjongOperatePanelState.None,
    --缓存的操作数据
    data = nil,
    --胡数据
    huData = nil,
    --换数据列表
    huanDatas = {},
    --碰数据列表
    pengDatas = {},
    --杠数据列表
    gangDatas = {},
    ---飞小鸡吃牌
    chiDatas = {},
    ---杠选牌
    buPaiDatas = {},
    --定缺数据
    dingQueData = nil,
    --换牌数据
    changeCardData = nil,
}

--清空操作相关数据
function MahjongDataMgr.ClearOperation()
    this.Operation.state = MahjongOperatePanelState.None
    this.Operation.data = nil
    this.Operation.huData = nil
    this.Operation.huanDatas = {}
    this.Operation.pengDatas = {}
    this.Operation.gangDatas = {}
    this.Operation.dingQueData = nil
    this.Operation.changeCardData = nil
    this.Operation.chiDatas = {}
    this.Operation.buPaiDatas = {}
end

--更新操作数据
function MahjongDataMgr.UpdateDataByOperate(data)
    this.surplusCards = data.cards
    this.UpdateServerTime(data.time)

    --更新打牌操作相关
    this.Operation.type = data.type
    this.Operation.playerId = data.id
    this.Operation.card = data.card
    --Log(">> this.Operation.type", this.Operation.type)
    local players = data.players
    local tempData = nil
    for i = 1, #players do
        tempData = players[i]
        if tempData.id == MahjongDataMgr.userId then
            this.UpdateMainPlayerOperateData(tempData)
        end
        --更新玩家定缺
        local playerData = this.GetPlayerDataById(tempData.id)
        playerData.state = tempData.state
        playerData.tState = tempData.tState
        playerData.huType = tempData.huType --胡牌特效类型
        playerData.specialHuEffect = tempData.specialHuEffect --特殊胡牌特效类型
        playerData.huIndex = tempData.huIndex 
        playerData.huFan = tempData.huFan
        playerData.dingQue = MahjongUtil.CheckDingQueType(tempData.dq)
        playerData.trust = MahjongUtil.CheckTrust(tempData.trust)
    end
end

--更新主玩家的操作数据，游戏开始和有操作都需要更新
function MahjongDataMgr.UpdateMainPlayerOperateData(data)

    --Log("MahjongDataMgr.UpdateMainPlayerOperateData > ", data)
    this.ClearOperation()

    --处理操作
    this.operateState = data.state

    if this.isConfigTingTips then
        if not this.isYaoJiPlayWay then
            --存储胡牌提示，由于幺鸡为客户端处理，固只需要存储非幺鸡的
            this.SetHuTips(data.huTips)
        end
    end

    --桌子状态
    local tTable = data.tState
    if tTable == nil or not IsNumber(tTable) then
        tTable = MahjongPlayerTableState.None
    end
    this.tableState = tTable

    --处理房间状态
    if this.gameState > MahjongGameStateType.End then
        if this.tableState == MahjongPlayerTableState.ChangingCard then
            this.SetGameState(MahjongGameStateType.ChangeCard)
        elseif this.tableState == MahjongPlayerTableState.ChangedCard then
            this.SetGameState(MahjongGameStateType.ChangeCard)
        elseif this.tableState == MahjongPlayerTableState.DingQue then
            this.SetGameState(MahjongGameStateType.DingQue)
        elseif this.tableState == MahjongPlayerTableState.DingQueEnd then
            this.SetGameState(MahjongGameStateType.DingQue)
        else
            this.SetGameState(MahjongGameStateType.Play)
        end
    end
    --保存操作项
    this.Operation.data = data.operation
    if data.operation == nil or #data.operation < 1 then
        return
    end
    local operationDatas = data.operation
    local length = #operationDatas
    local operationData = nil

    for i = 1, length do
        operationData = operationDatas[i]

        if operationData.type == MahjongOperateCode.HUAN_ZHANG then
            --如果有换牌，就不处理其他的
            this.Operation.state = MahjongOperatePanelState.Change
            this.Operation.changeCardsData = operationData
            break
        elseif operationData.type == MahjongOperateCode.DING_QUE then
            --如果有定缺，就不处理其他的
            this.Operation.state = MahjongOperatePanelState.DingQue
            this.Operation.dingQueData = operationData
            break
        elseif operationData.type == MahjongOperateCode.HU or this.IsFlyChickenHuCardType(operationData.type) then
            --胡牌
            this.Operation.state = MahjongOperatePanelState.Operation
            this.Operation.huData = operationData
        elseif operationData.type == MahjongOperateCode.HUAN_PAI then
            --换牌
            this.Operation.state = MahjongOperatePanelState.Operation
            table.insert(this.Operation.huanDatas, operationData)
        elseif operationData.type == MahjongOperateCode.PENG
                or operationData.type == MahjongOperateCode.SPC_PENG then
            --碰
            this.Operation.state = MahjongOperatePanelState.Operation
            table.insert(this.Operation.pengDatas, operationData)
        elseif operationData.type == MahjongOperateCode.GANG
                or operationData.type == MahjongOperateCode.GANG_IN
                or operationData.type == MahjongOperateCode.GANG_ALL_IN then
            --普通杠
            this.Operation.state = MahjongOperatePanelState.Operation
            table.insert(this.Operation.gangDatas, operationData)
        elseif operationData.type == MahjongOperateCode.SPC_GANG
                or operationData.type == MahjongOperateCode.SPC_GANG_IN
                or operationData.type == MahjongOperateCode.SPC_GANG_ALL_IN then
            --幺鸡杠
            this.Operation.state = MahjongOperatePanelState.Operation
            table.insert(this.Operation.gangDatas, operationData)
        elseif operationData.type == MahjongOperateCode.BU_PAI then
            this.Operation.state = MahjongOperatePanelState.Operation
            table.insert(this.Operation.buPaiDatas, operationData)
        elseif operationData.type == MahjongOperateCode.FlyChickenChi then
            this.Operation.state = MahjongOperatePanelState.Operation
            table.insert(this.Operation.chiDatas, operationData)
        end
    end
end

function MahjongDataMgr.IsFlyChickenHuCardType(type)
    return type == MahjongOperateCode.QuanQiuRen
    or type == MahjongOperateCode.LanPai
    or type == MahjongOperateCode.QiXingLanPai
    or type == MahjongOperateCode.LongZhuaBei
    or type == MahjongOperateCode.ShiFeng
    or type == MahjongOperateCode.ShiSanYao
    or type == MahjongOperateCode.SiXiaoJi
    or type == MahjongOperateCode.HunYiSe
    or type == MahjongOperateCode.ZiYiSe
    or type == MahjongOperateCode.Gang5MeiHua
    or type == MahjongOperateCode.XiaoJiGuiWei
    or type == MahjongOperateCode.DaSanYuan
    or type == MahjongOperateCode.DaSiXi
end

--是否全部定缺，只有需要定缺的牌局才需要处理
function MahjongDataMgr.CheckIsAllDingQue()
    local isAllDingQue = true
    local playerData = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = this.playerDatas[i]
        if playerData ~= nil then
            if playerData.dingQue < MahjongColorType.Wan then
                isAllDingQue = false
                break
            end
        end
    end
    return isAllDingQue
end

--================================================================
--
--更新数据通过结算数据
function MahjongDataMgr.UpdateDataBySettlement(data)
    if data == nil or data.xj == nil then
        return
    end
    local length = #data.xj
    local tempData = nil
    local playerData = nil
    for i = 1, length do
        tempData = data.xj[i]
        playerData = this.GetPlayerDataById(tempData.id)
        if this.moneyType == MoneyType.Gold then
            --playerData.gold = tempData.total--由于总分是当前房间的输赢总分，不是玩家当前身上的分数，所有此处不在更新分数
        else
            playerData.score = tonumber(tempData.total)
        end
    end
end