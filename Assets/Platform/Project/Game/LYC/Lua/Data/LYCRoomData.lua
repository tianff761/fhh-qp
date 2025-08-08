--================================================================
--后面取消掉key-value存储方式，使用显式变量
--房间相关数据
LYCRoomData = {
    --是否是回放
    isPlayback = false,
    --是否可以发送数据
    isCandSend = true,
    --是否初始化房间完成
    isInitRoomEnd = false,
    --房间号，是数字，用于显示，不用于标识，故不用清空
    roomCode = 0,
    --房主
    owner = nil,
    --主玩家
    mainId = 0,
    --游戏是否开始 --小局
    isCardGameStarted = false,
    --是否开始游戏 --整局
    isGameStarted = false,
    --游戏是否结束
    isGameOver = false,
    --游戏类型(明牌抢庄？)
    gameType = 0,
    --房间游戏类型名(明牌抢庄？)
    gameName = nil,
    --玩家数据
    playerDatas = {},
    --主玩家数据
    mainPlayerDatas = nil,
    --游戏阶段
    gameState = 1,
    --结算数据
    netJieSuanData = nil,
    --创建房间数据
    roomData = nil,
    --------------------------------------------  具体信息
    --推注倍数(5倍?) (存入显示信息)
    tuiZhu = "无",
    --底分倍数 -- 下注分 * 倍数
    difenBeiShu = 1,
    --总局数
    gameTotal = 0,
    --游戏当前局数
    gameIndex = 0,
    --抢庄倍率(n倍)(存入显示信息)
    multiple = 0,
    --游戏开始类型，手动，满几人开 (存入显示信息)
    showStartType = 0,
    --游戏开始类型，手动，满几人开 (int)
    startType = 0,
    --玩家人数 
    manCount = 0,
    --庄家Id
    BankerPlayerId = nil,
    --模式 (传统，癞子)(存入显示信息)
    model = nil,
    --支付方式(AA支付,房主支付)(存入显示信息)
    payType = nil,
    --底分(2/4/6/8,5/10/15/20 )(存入显示信息)
    diFen = nil,
    --高级选项(存入显示信息)
    gaoJiConfig = "",
    --完全的高级选项
    allGaoJiConfig = "",
    --是否拥有搓牌
    isRubCard = false,
    --是否拥有语音
    isSpeech = false,
    --码宝次数
    maBaoCount = nil,
    --抢庄分数
    QZFSCount = nil,
    --------------------------------------------  其他信息
    --是否播放过抢庄动画
    isPlayRubZhuangAni = false,
    --是否播放过坐下按钮移动动画
    isSitDown = false,
    --是否庄家翻倍
    isBankerDoubleWin = false,
    --是否拥有结算
    isHaveJieSuan = false,
    --是否自动翻牌
    isAutoFlipCard = false,
    --------------------------------------------  不需要清除
    --桌子颜色
    lycDeskColor = 1,
    --牌颜色
    cardColor = 1,
    --亲友圈id
    clubId = 0,
    ---奖池奖金
    awardPoolCoinNum = 0,
    ---获奖记录
    RewardRecord = {},
    ---备注
    Note = "",
    ---抢庄最低积分
    RobLimit = 0,
    --分配规则 0/1 所有人分配/赢家分配
    --faceType = 0,

    --玩家座位列表，有新玩家加入就会重新排序玩家座位
    playerPosDataList = {},
    --玩家座位号列表，有新玩家加入就会重新排序玩家座位号
    playerPosIndexList = {},

    --是否是最新一局
    isNewGame = false;
    --是否有新玩家旁观进入游戏，如果有新玩家加入，下一局则重新刷新玩家座位
    isNewPlayer = false;
}

local this = LYCRoomData


--判断是否开局了，牌局是否开始
function LYCRoomData.IsGameStarted()
    if this.IsFangKaFlow() then
        return this.isGameStarted
    end
    return this.isCardGameStarted
end

--退出房间或者关闭时调用
function LYCRoomData.Clear()
    --是否是回放
    this.isPlayback = false
    --是否可以发送数据
    this.isCandSend = true
    --是否初始化房间完成
    this.isInitRoomEnd = false
    --房间号，是数字，用于显示，不用于标识，故不用清空
    this.roomCode = 0
    --房主
    this.owner = nil
    --主玩家
    this.mainId = 0
    --游戏是否开始 --小局
    this.isCardGameStarted = false
    --是否开始游戏 --整局
    this.isGameStarted = false
    --游戏是否结束
    this.isGameOver = false
    --游戏类型(明牌抢庄？)
    this.gameType = 0
    --房间游戏类型名(明牌抢庄？)
    this.gameName = nil
    --玩家数据
    this.playerDatas = {}
    --主玩家数据
    this.mainPlayerDatas = nil
    --游戏阶段
    this.gameState = 1
    --结算数据
    this.netJieSuanData = nil
    --创建房间数据
    this.roomData = nil
    --------------------------------------------  具体信息
    --推注倍数(5倍?) (存入显示信息)
    this.tuiZhu = "无"
    --底分倍数 -- 下注分 * 倍数
    this.difenBeiShu = 1
    --总局数
    this.gameTotal = 0
    --游戏当前局数
    this.gameIndex = 0
    --抢庄倍率(n倍)(存入显示信息)
    this.multiple = 0
    --游戏开始类型，手动，满几人开 (存入显示信息)
    this.showStartType = 0
    --游戏开始类型，手动，满几人开 (int)
    this.startType = 0
    --玩家人数 
    this.manCount = 0
    --庄家Id
    this.BankerPlayerId = nil
    --模式 (传统，癞子)(存入显示信息)
    this.model = nil
    --支付方式(AA支付房主支付)(存入显示信息)
    this.payType = nil
    --底分(2/4/6/8,5/10/15/20 )(存入显示信息)
    this.diFen = nil
    --高级选项(存入显示信息)
    this.gaoJiConfig = ""
    --完全的高级选项
    this.allGaoJiConfig = ""
    --是否拥有搓牌
    this.isRubCard = false
    --是否拥有语音
    this.isSpeech = false
    --码宝次数
    this.maBaoCount = nil
    --抢庄分数
    this.QZFSCount = nil
    --------------------------------------------  其他信息
    --是否播放过抢庄动画
    this.isPlayRubZhuangAni = false
    --是否播放过坐下按钮移动动画
    this.isSitDown = false
    --是否庄家翻倍
    this.isBankerDoubleWin = false
    --是否拥有结算
    this.isHaveJieSuan = false
    ----是否自动翻牌
    --this.isAutoFlipCard = false
    this.isNewGame = false
    this.isNewPlayer = false
    this.playerPosDataList = {}
    this.playerPosIndexList = {}
end

--准备 重置的数据
function LYCRoomData.Reset()
    this.BankerPlayerId = nil
    this.isPlayRubZhuangAni = false
    --重置玩家数据
    for i = 1, #this.playerDatas do
        -- Log("   重置玩家数据   ",this.playerDatas[i],this.playerDatas[i].item ~= nil)
        if this.playerDatas[i].item ~= nil then
            this.playerDatas[i]:Reset()
            this.playerDatas[i]:HideAllCard()
        end
    end
    --清理内存
    ClearMemory()
end

--开局重置的数据
function LYCRoomData.StartGameReset()
    this.Reset()
    for i = 1, #this.playerDatas do
        this.playerDatas[i]:StartGameReset()
    end
    this.isHaveJieSuan = false
end

--获取自己的Data
function LYCRoomData.GetSelfData()
    --LogError("自己的ID", this.mainId, type(this.mainId))
    --LogError("自己的数据", this.mainPlayerDatas)
    --LogError("玩家数据", this.playerDatas)
    if not this.IsObserver() then
        for k, v in pairs(this.playerDatas) do
            if v.id == this.mainId then
                return v
            end
        end
    else
        return this.playerDatas[1]
    end
end

---检查是否有自己的座位号和数据（如果人满再加入桌子则无）
function LYCRoomData.CheckHaveSelfData()
    for _, v in pairs(this.playerDatas) do
        if v.id == this.mainId then
            return true
        end
    end
    return
end

--检测是否是自己的数据
function LYCRoomData.CheckIsSelf(id)
    return id == this.mainId
end

--获取自己的Item(不能再使用)
function LYCRoomData.GetSelfItem()
    if IsNil(this.mainPlayerDatas) then
        for k, v in pairs(this.playerDatas) do
            if v.id == this.mainId then
                this.mainPlayerDatas = v
            end
        end
    end
    return this.mainPlayerDatas.item
end

--根据玩家id移除玩家
function LYCRoomData.RemovePlayer(playerId)
    local index = this.GetPlayerIndexById(playerId)
    if index ~= nil then
        table.remove(this.playerDatas, index)
    end
end

--获取玩家第五张牌是否翻开
function LYCRoomData:GetSelfHandCardFiveFlip()
    local selfData = LYCRoomData.GetSelfData()
    return not selfData:GetHandCardFiveFlip()
end

--获取自己是否未准备
function LYCRoomData.GetSelfIsNoReady()
    if this.GetSelfData().state == LYCPlayerState.WAITING or this.GetSelfData().state == LYCPlayerState.NO_READY then
        return true
    end
    return false
end

--主玩家是否观战状态
function LYCRoomData.GetSelfIsWaiting()
    return this.GetSelfData().state == LYCPlayerState.WAITING
end

--主玩家是否可以离开房间
function LYCRoomData.GetSelfIsExitRoom()
    if this.IsGameStarted() then
        return this.GetSelfIsNoReady()
    end
    return true
end

--获取当前游戏是否在游戏中的状态
function LYCRoomData.GetIsGaming()
    if LYCRoomData.gameState == LYCGameState.ROB_ZHUANG or LYCRoomData.gameState == LYCGameState.BETTING or LYCRoomData.gameState == LYCGameState.WATCH_CARD then
        return true
    end
    return false
end

--通过玩家ID获取玩家对象，所有数据都从该处获取
function LYCRoomData.GetPlayerDataById(playerId)
    if IsNil(playerId) or playerId == 0 then
        return
    end
    local uId = tonumber(playerId)
    for i = 1, #this.playerDatas do
        local playerData = this.playerDatas[i]
        if playerData ~= nil then
            if playerData.id == uId then
                return playerData
            end
        end
    end
    Log("<<<<<<< 未找到id为" .. playerId .. "的玩家")
end

--通过玩家ID获取玩家在table中的下标位置
function LYCRoomData.GetPlayerIndexById(playerId)
    if playerId ~= nil and playerId ~= "" then
        for i = 1, #this.playerDatas do
            local playerData = this.playerDatas[i]
            if playerData ~= nil then
                if playerData.id == playerId then
                    return i
                end
            end
        end
    end
end

--获取玩家的性别
function LYCRoomData.GetPlayerGender(playerId)
    local sex = 1
    for i = 1, #this.playerDatas do
        local playerData = this.playerDatas[i]
        if playerData == nil or playerData.id == nil then
            sex = 1
        else
            if playerData.id == playerId then
                sex = playerData.sex
            end
        end
    end
    return sex
end

--获取非观战的玩家
function LYCRoomData.GetReadyPlayer()
    local tab = {}
    for i = 1, #this.playerDatas do
        if this.playerDatas[i].state ~= LYCPlayerState.LookOn then
            table.insert(tab, this.playerDatas[i])
        end
    end
    return tab
end

--根据座位号获取玩家信息
function LYCRoomData.GetPlayerBySeatNumber(seatId)
    for i = 1, #this.playerDatas do
        if this.playerDatas[i].seatNumber == seatId then
            return this.playerDatas[i]
        end
    end
end

--根据服务器座位号，获取本地座位号
function LYCRoomData.GetIndexBySeatNumber(num)
    local selfIndex = this.GetSelfData().seatNumber

    local index = num + 1
    --为nil时，表示自己没有坐下
    if selfIndex ~= -1 and selfIndex ~= nil then
        index = num - selfIndex + 1
    end

    if index > 6 then
        index = index - 6
    elseif index < 1 then
        index = index + 6
    end
    return index
end

--获取除去自己以外的玩家的座位id
function LYCRoomData.GetReadyOtherPlayerDatas()
    local tab = {}
    local playerDatas = this.GetReadyPlayer()
    for i = 1, #playerDatas do
        if playerDatas[i].id ~= this.mainId then
            table.insert(tab, playerDatas[i])
        end
    end
    return tab
end

function LYCRoomData.GetPlayerUIById(id)
    local playerData = this.GetPlayerDataById(id)
    if playerData == nil then
        LogWarn("<<<<<<<<<<<<<            playerData is nil")
        return
    end
    if playerData.item == nil then
        LogWarn("<<<<<<<<<<<<<            playerData.item is nil")
        return
    end
    return playerData.item
end

--主玩家是否是房主
function LYCRoomData.MainIsOwner()
    return this.mainId == this.owner
end

--主玩家是否是庄家
function LYCRoomData.MainIsBanker()
    return this.mainId == this.BankerPlayerId
end

--是否大厅房间
function LYCRoomData.IsLobbyRoom()
    if IsNil(this.roomData) then
        return false
    end
    local roomType = this.roomData.roomType
    if roomType == RoomType.Lobby then
        return true
    end
    return false
end

--是否俱乐部房间
function LYCRoomData.IsClubRoom()
    if IsNil(this.roomData) then
        return false
    end
    local roomType = this.roomData.roomType
    if roomType == RoomType.Club then
        return true
    end
    return false
end

--是否亲友圈大厅房间
function LYCRoomData.IsTeaRoom()
    if IsNil(this.roomData) then
        return false
    end
    local roomType = this.roomData.roomType
    if roomType == RoomType.Tea then
        return true
    end
    return false
end

--是否联盟房间
function LYCRoomData.IsUnionRoom()
    if IsNil(this.roomData) then
        return false
    end
    local roomType = this.roomData.roomType
    if roomType == RoomType.Union then
        return true
    end
    return false
end

--是否房卡场
function LYCRoomData.IsFangKaGame()
    if IsNil(this.roomData) then
        return false
    end
    local moneyType = this.roomData.moneyType
    if moneyType == MoneyType.Fangka then
        return true
    end
    return false
end

--是否是金币场
function LYCRoomData.IsGoldGame()
    if IsNil(this.roomData) then
        return false
    end
    local moneyType = this.roomData.moneyType
    if moneyType == MoneyType.Gold then
        return true
    end
    return false
end

--是否房卡流程
function LYCRoomData.IsFangKaFlow()
    if this.IsFangKaGame() or (this.IsGoldGame() and this.gameTotal > 1) then
        return true
    end
    return false
end

---更新获奖记录
function LYCRoomData.UpdateRewardRecord(lastReward)
    this.RewardRecord = lastReward
end

---更新奖池显示
function LYCRoomData.UpdateAwardPoolCoinNum(awardPoolNum)
    if LYCRoomData.awardPoolCoinNum ~= awardPoolNum then
        LYCRoomData.awardPoolCoinNum = awardPoolNum
        if LYCRoomPanel then
            LYCRoomPanel.UpdateAwardPoolText(awardPoolNum)
        end
    end
end

---判断玩家数量是否达到最大，达到最大为观战者
---@return boolean true为是玩家，false为观战者
function LYCRoomData.CheckPlayNumJudgeIsObserver()
    return #LYCRoomData.playerDatas == LYCRoomData.manCount
end

function LYCRoomData.JudgeIsObserver(playerList)
    this.isObserver = true
    for i = 1, #playerList do
        --LogError("playerList[i].userId", playerList[i].userId, type(playerList[i].userId))
        --LogError("UserData.userId", UserData.userId, type(UserData.userId))
        if playerList[i].userId == UserData.userId then
            this.isObserver = false
        end
    end
    SendMsg(LYCAction.LYCHideOperate)
    return this.isObserver
end

---判断座位是否坐满
---@return boolean true坐满，false没有
function LYCRoomData.IsFullOfSeat()
    return #LYCRoomData.playerDatas == LYCRoomData.manCount
end

---@return boolean true为观战者，false为玩家
function LYCRoomData.IsObserver()
    --LogError("Handle IsObserver", this.isObserver)
    return this.isObserver
end

function LYCRoomData.JudgeSitDownPlayer(data)
    userId = data.userId
    --LogError("<color=aqua>data</color>", data)
    if userId == UserData.userId and this.IsObserver() and data.seatNum > 0 then
        this.isObserver = false
        -- LYCRoomCtrl.ResetAllPlayerUI()

        --LogError("<color=aqua>LYCObserverSitDown</color>")
        --SendMsg(LYCAction.LYCObserverSitDown)
    end
end
