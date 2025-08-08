--数据管理
--后面取消掉key-value存储方式，使用显式变量
TpDataMgr = {
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
    --是否进入游戏，即收到进入游戏的协议
    isEnterGame = false,
    --房间是否结束
    isRoomEnd = false,
    --房间ID
    roomId = 0,
    --主玩家的ID
    userId = nil,
    --主玩家的服务器座位号
    userSeatNumber = 0,
    --房主ID，玩家ID
    ownerId = nil,
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
    --房间Gps类型
    gpsType = nil,
    --玩法类型，解析规则获得
    playWayType = TpPlayWayType.PlayWay1,
    --总局数，解析规则获得
    gameTotal = 1,
    --房间类型，进入房间时获取
    roomType = RoomType.Lobby,
    --货币类型，进入房间时获取
    moneyType = MoneyType.Fangka,
    --人数，解析规则获得
    playerTotal = TpMaxPlayerTotal,
    --满几人开
    startTotal = 3,
    --分数场的底分
    baseScore = 0,
    --================================
    --单局生命周期
    --------------------------------
    --服务器时间戳，单位毫秒
    serverTimeStamp = nil,
    --服务器更新时间，即收到服务器的时间，单位秒
    serverUpdateTime = 0,
    --是否可以发送数据
    isCanSend = false,
    --游戏是否开始
    isStartGame = false,
    --游戏开始时间
    gameStartTime = 0,
    --当前局数
    gameIndex = 0,
    --服务器游戏状态
    gameStatus = TpGameStatus.None,
    --倒计时
    countdown = 0,
    --总共倒计时
    countdownTotal = 0,
    --庄ID
    zhuangId = 0,
    --游戏开始倒计时
    gameStartCountdown = 0,
    --------------------------------
    --当前操作玩家的ID
    operateId = 0,
    --之前操作的玩家ID
    lastOperateId = 0,
    --------------------------------
    --是否有解散申请
    isHasDismiss = false,
    --是否在解散中，解散中桌子中间的倒计时不处理
    isDismissing = false,
    --================================
    --手动清理数据，房间结束时清理
    --------------------------------
    --结算数据
    settlementData = nil,
    --结算数据查看的局数
    settlementIndex = 0,
    --================================
    --是否都准备，在推送准备时处理
    isAllReady = false,
    --比赛场等级
    matchLevel = 0,
    --比赛场ID
    matchId = 1,
    --准入
    zhunRu = 0,
    --================================
}

local this = TpDataMgr

--玩家数据，数组，房间的实际人数可能大于座位人数
TpDataMgr.playerDatas = {}
--玩家数据，字典存储，使用ID为key存储，只提供方便使用
TpDataMgr.playerDataDict = {}

--小局数据重置
function TpDataMgr.Reset()
    this.operateId = 0
    this.lastOperateId = 0
    LogError("<color=aqua> >> TpDataMgr.Reset. </color>")
    --清除玩家的单局等数据
    for i = 1, #this.playerDatas do
        this.playerDatas[i]:Reset()
    end
end

--房间数据清除，退出房间才调用
function TpDataMgr.Clear()
    this.Reset()
    this.isEnterGame = false
    this.isRoomEnd = false
    this.isCanSend = false
    this.gameStatus = TpGameStatus.None
    this.roomId = 0
    this.settlementData = nil
    this.settlementIndex = 0
    this.playerTotal = TpMaxPlayerTotal
end

--房间数据销毁
function TpDataMgr.Destroy()
    this.Clear()
    this.cardDatas = {}
end

--清除相关信息通过初始游戏的时候
function TpDataMgr.ClearByInit()
    this.gameStatus = TpGameStatus.None
    this.isEnterGame = false
    this.isRoomEnd = false
    this.settlementData = nil
    this.settlementIndex = 0
    this.operateId = 0
    this.lastOperateId = 0
end

--================================================================
--
--设置房间ID
function TpDataMgr.SetRoomId(id)
    this.roomId = id
end

--设置主玩家ID
function TpDataMgr.SetUserId(id)
    this.userId = id
end

--房间是否开始，如果游戏当前局数大于1表示房间已经开始，分数场无限局除外
function TpDataMgr.IsRoomBegin()
    return this.gameStatus > TpGameStatus.ReadyWait or this.isStartGame
end

--单局是否结束
function TpDataMgr.IsGameEnd()
    return this.gameStatus == TpGameStatus.GameEnd
end

--单局是否开始
function TpDataMgr.IsGameBegin()
    return this.gameStatus > TpGameStatus.ReadyWait
end

--是否是分数房间
function TpDataMgr.IsGoldRoom()
    return this.moneyType == MoneyType.Gold
end

--是否是分数有限房间
function TpDataMgr.IsGoldRoomFinite()
    return this.moneyType == MoneyType.Gold and this.gameTotal ~= -1
end

--是否是分数无限房间，局数为-1
function TpDataMgr.IsGoldRoomInfinite()
    return this.moneyType == MoneyType.Gold and this.gameTotal == -1
end

--是否是比赛场房间
function TpDataMgr.IsMatchRoom()
    return this.roomType == RoomType.Match
end

--是否是房主
function TpDataMgr.IsRoomOwner()
    return this.userId == this.ownerId
end

--更新GPS
function TpDataMgr.UpdateMainPlayerGps(args)
    local playerData = this.GetMainPlayerData()
    if playerData ~= nil then
        playerData:SetGps(args)
    end
end

--================================================================
--
--将上一阶段的玩家信息中的下注金额置为0
function TpDataMgr.ResetBetAmount()
    for i = 1, #this.playerDatas do
        this.playerDatas[i].betScore = 0
        
    end
end


--获取玩家1的数据
function TpDataMgr.GetMainPlayerData()
    return TpDataMgr.GetPlayerDataById(this.userId)
end

--通过玩家ID获取玩家对象，所有数据都从该处获取，不存在返回空对象
function TpDataMgr.GetPlayerDataById(playerId)
    return this.playerDataDict[playerId]
end

--通过服务器序号获取玩家对象，针对坐下的玩家，因为没坐下的玩家的座位号都是0
function TpDataMgr.GetPlayerDataBySeverIndex(index)
    local temp = nil
    for i = 1, #this.playerDatas do
        temp = this.playerDatas[i]
        if temp.seatIndex == index then
            return temp
        end
    end
    return nil
end

--通过客户端序号获取玩家对象
function TpDataMgr.GetPlayerDataByLocalIndex(index)
    local serverIndex = TpUtil.GetServerIndexByLocalIndex(index)
    return this.GetPlayerDataBySeverIndex(serverIndex)
end

--通过玩家ID获取玩家对象，没有存储就创建
function TpDataMgr.CheckGetPlayerDataById(playerId)
    local playerData = this.playerDataDict[playerId]
    if playerData == nil then
        playerData = TpPlayerData.New()
        playerData.id = playerId
        this.playerDataDict[playerId] = playerData
        table.insert(this.playerDatas, playerData)
    end
    return playerData
end

--删除玩家
function TpDataMgr.DeletePlayerDataById(playerId)
    this.playerDataDict[playerId] = nil
    local temp = nil
    for i = 1, #this.playerDatas do
        temp = this.playerDatas[i]
        if temp.id == playerId then
            table.remove(this.playerDatas, i)
            break
        end
    end
end

--检查玩家座位索引
function TpDataMgr.CheckUserSeatNumber()
    this.userSeatNumber = 0
    local temp = nil
    for i = 1, #this.playerDatas do
        temp = this.playerDatas[i]
        if temp.id == this.userId then
            this.userSeatNumber = temp.seatIndex
            break
        end
    end
end

--获取玩家的性别
function TpDataMgr.GetPlayerGender(playerId)
    local playerData = this.playerDataDict[playerId]
    --默认使用女声
    if playerData == nil or playerData.id == nil then
        return Global.GenderType.Female
    else
        return playerData.gender
    end
end

--清除玩家数据
function TpDataMgr.ClearPlayerDatas()
    this.playerDatas = {}
    this.playerDataDict = {}
end

--================================================================
--
--更新房间数据通过进入游戏
-- 进入房间的消息 
-- roomId 房间号
-- rules  房间规则
-- ownerId 创建者id
-- nowjs 当前局数
-- gameStatus 游戏状态
-- countDown 倒计时
-- totalCD 总共倒计时
-- opId 当前操作玩家id
-- isStartGame 游戏是否开始  0/1
-- startAt 游戏开始时间 毫秒
-- zhuangId 庄家id
-- betPool  主的池
-- sidePool  {}边池数组
-- public  公共牌
function TpDataMgr.UpdateRoomDataByEnterGame(data)
    this.isEnterGame = true
    this.roomId = data.roomId
    this.rules = data.rules
    this.ownerId = data.ownerId
    this.gameIndex = data.nowjs
    this.gameStatus = data.gameStatus
    this.countdown = tonumber(data.countDown) + Time.realtimeSinceStartup
    this.countdownTotal = tonumber(data.totalCD)
    this.needGold = tonumber(data.needGold)
    this.lastOperateId = 0
    this.operateId = data.opId
    this.isStartGame = data.isStartGame == 1--该值不使用
    this.gameStartTime = data.startAt / 1000
    this.zhuangId = data.zhuangId
    this.betPool = tonumber(data.betPool)
    this.sidePool = data.sidePool
    this.public = data.public

    this.UpdateServerTime(data.time)
    -- this.groupId = data.clubOrTeaId
    -- this.isHasDismiss = data.dismiss ~= nil and data.dismiss == 1

    --清除玩家数据后重新设置
    this.ClearPlayerDatas()
    --解析玩法规则
    this.ParsePlayWayRule(this.rules)
    --更新玩家数据
    this.UpdatePlayerDataByEnterGame(data.playerMsg)
end

--推送游戏状态
-- gameStatus  游戏状态
-- nowjs	当前局数
-- countDown 剩余
-- totalCD 总cd
-- zhuangId 装
-- opId   操作id
-- sidePool 边池 
-- public  公共牌
-- betPool 下注的池
-- publicPai 公共牌
-- playerMsg 玩家列表[{
-- 		id id 
--         itg 下的注
--         isg 下的芒 
--         ir  是否准备  
--         gu  是否放弃
--         ps  玩家状态 
--         ijg  是否加入游戏 
--         gold 金币
-- 		bet   当前轮下的注（round_1, round_2, round_3 三个下注轮次有效）0表示未下注
-- 		iall   是否allin  
-- lAct 上一个操作  操作枚举 0表示无
-- }]
function TpDataMgr.UpdateRoomDataByGameStatus(data)
    this.gameStatus = data.gameStatus
    this.gameIndex = data.nowjs
    this.countdown = tonumber(data.countDown) + Time.realtimeSinceStartup
    this.countdownTotal = tonumber(data.totalCD)
    this.zhuangId = data.zhuangId
    this.lastOperateId = this.operateId
    this.operateId = data.opId
    this.sidePool = data.sidePool
    this.public = data.public
    this.betPool = tonumber(data.betPool)
    --更新玩家数据
    this.UpdatePlayerDataByGameStatus(data.playerMsg)
end


--解析玩法规则
function TpDataMgr.ParsePlayWayRule(rules)
    if rules == nil then
        LogWarn(">> TpDataMgr.ParsePlayWayRule > rules == nil.")
        return
    end
    --LogError("<color=aqua>处理玩法信息</color>")
    this.playWayType = TpUtil.GetPlayWayRule(rules, TpRuleType.PlayWayType, TpPlayWayType.PlayWay1)
    this.gameTotal = TpUtil.GetPlayWayRule(rules, TpRuleType.GameTotal, 1)
    this.playerTotal = TpUtil.GetPlayWayRule(rules, TpRuleType.PlayerTotal, 4)
    this.startTotal = TpUtil.GetPlayWayRule(rules, TpRuleType.StartTotal, 2)
    this.qianZhu = TpUtil.GetPlayWayRule(rules, TpRuleType.QianZhu, 1)
    this.limit = TpUtil.GetPlayWayRule(rules, TpRuleType.Limit, 0)

    this.zhunRu = TpUtil.GetPlayWayRule(rules, TpRuleType.ZhunRu, 1)
    this.baseScore = TpUtil.GetPlayWayRule(rules, TpRuleType.DiFen, 1)

    this.playWayName = TpConfig.GetPlayWayName(this.playWayType)
end

--更新服务器时间
function TpDataMgr.UpdateServerTime(time)
    --回放使用设备时间
    if this.isPlayback then
        this.serverTimeStamp = os.time()
    else
        this.serverTimeStamp = time
    end
    this.serverUpdateTime = Time.realtimeSinceStartup
end

--更新玩家数据通过加入房间数据
function TpDataMgr.UpdatePlayerDataByEnterGame(players)
    if players == nil or not IsTable(players) then
        return
    end
    for i = 1, #players do
        this.UpdateSinglePlayerDataEnterGame(players[i])
    end
    this.CheckUserSeatNumber()
end

--更新单个玩家数据
-- pId 玩家id
-- sNum 座位号
-- name 名字
-- img   头像
-- sex   性别
-- gold   金币
-- bet   当前轮下的注（round_1, round_2, round_3 三个下注轮次有效）
-- iall   是否allin  
-- ir     是否准备
-- io   是否在线
-- ijg  是否加入游戏
-- gu   是否弃牌
-- ps    玩家状态
-- pIds  手牌
-- sPx  当前牌型
-- lAct 上一个操作  操作枚举 0表示无
function TpDataMgr.UpdateSinglePlayerDataEnterGame(data)
    local playerData = this.CheckGetPlayerDataById(data.pId)
    playerData.seatIndex = data.sNum
    playerData.name = Functions.CheckPlayerName(data.name)
    playerData.gender = Functions.CheckPlayerGender(data.sex)
    playerData.headUrl = Functions.CheckPlayerHeadUrl(data.img)
    playerData.headFrame = Functions.CheckPlayerHeadFrame(data.frame)
    playerData.gold = tonumber(data.gold)
    playerData.score = 0
    --
    playerData.isReady = data.ir == 1
    playerData.isJoinGame = data.ijg == 1
    playerData.isOnline = data.io == 1
    --
    playerData.betScore = tonumber(data.bet)
    playerData.isAllIn = data.iall == 1
    playerData.isGiveUp = data.gu == 1

    playerData.status = data.ps
    playerData.handCards = data.pIds
    playerData.px = data.sPx
    playerData.operateType = data.lAct
end


--更新玩家数据通过推送游戏状态
function TpDataMgr.UpdatePlayerDataByGameStatus(players)
    if players == nil or not IsTable(players) then
        return
    end
    for i = 1, #players do
        this.UpdateSinglePlayerDataByGameStatus(players[i])
    end
    this.CheckUserSeatNumber()
end

--更新玩家数据通过推送游戏状态
-- 		id id 
--         itg 下的注
--         isg 下的芒 
--         ir  是否准备 
--         il  是否看牌 
--         gu  是否放弃
--         ps  玩家状态 
--         ijg  是否加入游戏 
--         gold 金币
function TpDataMgr.UpdateSinglePlayerDataByGameStatus(data)
    local playerData = this.CheckGetPlayerDataById(data.id)
    --
    playerData.isReady = data.ir == 1
    playerData.isJoinGame = data.ijg == 1
    playerData.isOnline = data.io == 1
    --   
    playerData.gold = tonumber(data.gold)
    playerData.betScore = tonumber(data.bet)

    playerData.status = data.ps
    playerData.isGiveUp = data.gu == 1
    playerData.isAllIn = data.iall == 1
    playerData.operateType = data.lAct

    playerData.px = data.sPx
end

--更新玩家数据，通过增加数据
-- pId 玩家id
-- sNum 座位号 
-- 如果opType是1，加入房间
-- name 名字
-- img   头像
-- sex   性别
-- gold   金币
-- io   是否在线
function TpDataMgr.UpdatePlayerDataByAdd(data)
    local playerData = this.CheckGetPlayerDataById(data.pId)
    playerData.seatIndex = data.sNum
    playerData.name = Functions.CheckPlayerName(data.name)
    playerData.headUrl = Functions.CheckPlayerHeadUrl(data.img)
    playerData.gender = Functions.CheckPlayerGender(data.sex)
    playerData.gold = tonumber(data.gold)
    playerData.isOnline = data.io == 1
    --
    this.CheckUserSeatNumber()
end

--删除玩家数据
function TpDataMgr.UpdatePlayerDataByDelete(playerId)
    local playerData = this.GetPlayerDataById(playerId)
    if playerData ~= nil then
        -- if not this.IsGoldRoom() then
        --     --离开房间提示，分数场不提示
        --     if playerId ~= TpDataMgr.userId then
        --         if playerData.name ~= nil then
        --             Toast.Show(playerData.name .. "离开房间")
        --         end
        --     end
        -- end
        --删除玩家数据
        this.DeletePlayerDataById(playerId)
        --
        this.CheckUserSeatNumber()
    end
end

--更新单个玩家在线状态
--{"cmd":105001,"code":0,"data":{"pId":302060,"io":1,"opType":3,"sNum":1}}
function TpDataMgr.UpdateSinglePlayerOnline(data)
    local playerData = this.GetPlayerDataById(data.pId)
    if playerData ~= nil then
        playerData.isOnline = data.io == 1
    end
end

--更新房主
function TpDataMgr.UpdateOwner(data)
    if data.isOwner == 1 then
        this.ownerId = data.pId
    end
end

--通过结算数据，更新玩家信息
function TpDataMgr.GetNewPlayerDataBySettlement(data)
    local playerData = TpPlayerData.New()
    playerData.id = data.id
    playerData.seatIndex = data.seat
    playerData.name = Functions.CheckPlayerName(data.n)
    playerData.headUrl = Functions.CheckPlayerHeadUrl(data.h)
    playerData.headFrame = Functions.CheckPlayerHeadFrame(data.hf)
    return playerData
end


--================================================================
--
--游戏开始时清除数据
function TpDataMgr.ClearByGameBegin()
    this.settlementData = nil
end

--更新玩家准备状态
function TpDataMgr.UpdatePlayerReady(data)
    local playerData = this.GetPlayerDataById(data.pId)
    if playerData ~= nil then
        playerData.isReady = true
    end
end

--主玩家是否准备
function TpDataMgr.IsReady()
    local playerData = this.GetMainPlayerData()
    if playerData ~= nil then
        return playerData.isReady == true
    end
    return false
end

--更新玩家在线状态
function TpDataMgr.UpdatePlayerOnline(data)
    if data == nil or data.players == nil then
        return
    end
    local length = #data.players
    local temp = nil
    for i = 1, length do
        temp = data.players[i]
        local playerData = this.GetPlayerDataById(temp.id)
        playerData.isOnline = temp.online
    end
end


--更新加入游戏
function TpDataMgr.UpdateJoinGame(data)
    local playerData = this.GetMainPlayerData()
    if playerData ~= nil then

    end
end

--设置坐下
function TpDataMgr.SetSitDown(isSitDown)
    local playerData = this.GetMainPlayerData()
    if playerData ~= nil then
        playerData.isSitDown = isSitDown
    end
end

--================================================================
--
--通过ID获取牌数据
function TpDataMgr.GetCardData(id)
    local temp = tonumber(id)
    local cardData = this.cardDatas[temp]
    if cardData == nil then
        cardData = TpCardData.New()
        cardData:SetId(temp)
        this.cardDatas[temp] = cardData
    end
    return cardData
end

-----------------------------------------------------
--

--更新操作数据
-- pId 玩家id
-- gold 金币  

-- opType跟注或者下注时或者allin
-- 	ig 下注
function TpDataMgr.UpdateDataByOperate(data)
    local playerData = this.GetPlayerDataById(data.pId)
    if playerData ~= nil then
        playerData.gold = tonumber(data.gold)
        playerData.operateType = data.opType
        local opType = data.opType
        --
        if opType == TpOperateType.Gen or opType == TpOperateType.Bet or opType == TpOperateType.AllIn then
            playerData.betScore = tonumber(data.ig)
        end
    end
end

--================================================================
--
--更新数据通过结算数据
-- msgs 数组 每个玩家的结算信息[{
-- 	pId 玩家id
-- 	gold 金币
-- 	winGold 输赢
-- 	pIds 手牌 
-- }]
function TpDataMgr.UpdateDataBySingleSettlement(data)
    this.gameStatus = TpGameStatus.GameResult
    for i = 1, #this.playerDatas do
        this.playerDatas[i].winGold = 0
    end
    local temp = nil
    local playerData = nil
    for i = 1, #data.msgs do
        temp = data.msgs[i]
        playerData = this.GetPlayerDataById(temp.pId)
        if playerData ~= nil then
            playerData.winGold = tonumber(temp.winGold)
            if temp.gold ~= nil then
                playerData.gold = tonumber(temp.gold)
            end
            --结算的时候处理了是否弃牌操作状态，故这里可以不赋值
            if temp.pIds ~= nil then
                playerData.handCards = temp.pIds
            end
            if temp.sPx ~= nil then
                playerData.px = temp.sPx
            end
        end
    end
end

--更新玩家的分数
--type(1支付桌费2游戏盈亏3付费表情)
function TpDataMgr.UpdatePlayerGold(data)
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

--================================================================
--通过发牌更新数据
-- publicPai 数组 公共牌
-- playerMsg 玩家列表 
-- [{
--   pId  玩家id
--   pIds 数组 手牌
--   sPx  当前最大牌型
-- }]
function TpDataMgr.UpdateDataByDeal(data)
    this.public = data.publicPai
    this.UpdatePlayerDataByDeal(data.playerMsg)
end

--更新玩家数据通过推送游戏状态
function TpDataMgr.UpdatePlayerDataByDeal(players)
    if players == nil or not IsTable(players) then
        return
    end
    for i = 1, #players do
        local data = players[i]
        local playerData = this.CheckGetPlayerDataById(data.pId)
        playerData.handCards = data.pIds
        playerData.px = data.sPx
    end
end

--================================================================
--
--拼接规则文本
function TpDataMgr.JointRuleTxt(result, txt)
    if string.IsNullOrEmpty(result) then
        return txt
    else
        return result .. "/" .. txt
    end
end

--================================================================
--
function TpDataMgr.Update()

end