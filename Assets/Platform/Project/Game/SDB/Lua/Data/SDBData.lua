--================================================================
--后面取消掉key-value存储方式，使用显式变量
--房间相关数据
SDBRoomData = {
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
    tuiZhu = 0,
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
    Bet = nil,
    --茶馆底分
    diFen = 0,
    --高级选项(存入显示信息)
    gaoJiConfig = "",
    --完全的高级选项
    allGaoJiConfig = "",
    --------------------------------------------  其他信息
    --是否播放过抢庄动画
    isPlayRubZhuangAni = false,
    --是否播放过坐下按钮移动动画
    isSitDown = false,
    --是否庄家翻倍
    isBankerDoubleWin = false,
    --是否拥有结算
    isHaveJieSuan = false,
    --------------------------------------------  不需要清除
    --桌子颜色
    sdbDeskColor = 1,
    --牌颜色
    cardColor = 1,
    --亲友圈id
    clubId = 0,
    --------------------------------------------  全局变量
    --是否可以要牌
    isGetCard = true,
    ---备注
    Note = "",
}

local this = SDBRoomData

--判断是否开局了，牌局是否开始，或者不是首局
function SDBRoomData.IsGameStarted()
    return this.isCardGameStarted or (not this.GetIsFristGame())
end

--退出房间或者关闭时调用
function SDBRoomData.Clear()
    --是否是回放
    this.isPlayback = false
    this.isInitRoomEnd = false
    --重置开局数据
    this.StartGameReset()
    --房间唯一id
    this.roomId = nil
    --主玩家
    this.mainId = 0
    --房主
    this.owner = nil
    --游戏是否开始
    this.isCardGameStarted = false
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
    --结算
    this.netJieSuanData = nil
    --创建房间数据
    this.roomData = nil
    --------------------------------------------  具体信息
    --推注分
    this.tuiZhu = 0
    --底分倍数 -- 下注分 * 倍数
    this.difenBeiShu = 1
    --总局数
    this.gameTotal = 0
    --游戏当前局数
    this.gameIndex = 0
    --抢庄倍率
    this.multiple = 0
    --游戏开始类型，手动，满几人开
    this.showStartType = 1
    --玩家人数
    this.manCount = 0
    --模式
    this.model = nil
    --支付方式(AA支付,房主支付)
    this.payType = nil
    --底分
    this.bet = nil
    --高级选项
    this.gaoJiConfig = ""
    --完全的高级选项
    this.allGaoJiConfig = ""
    --------------------------------------------  其他信息
    --是否播放过坐下按钮移动动画
    this.isSitDown = false
    --是否庄家翻倍
    this.isBankerDoubleWin = false
    --亲友圈id
    this.clubId = 0
    ------------------------------------------------------------
    --是否可以要牌
    this.isGetCard = true
end

--准备 重置的数据
function SDBRoomData.Reset()
    this.BankerPlayerId = nil
    this.isPlayRubZhuangAni = false
    --是否可以要牌
    this.isGetCard = true
    --重置玩家数据
    for i = 1, #this.playerDatas do
        this.playerDatas[i]:Reset()
        this.playerDatas[i]:HideAllCard()
    end
end

--开局重置的数据
function SDBRoomData.StartGameReset()
    this.Reset()
    for i = 1, #this.playerDatas do
        this.playerDatas[i]:StartGameReset()
    end
    this.isHaveJieSuan = false
end

--获取自己的Data
function SDBRoomData.GetSelfData()
    if IsNil(this.mainPlayerDatas) then
        for k, v in pairs(this.playerDatas) do
            if v.id == this.mainId then
                this.mainPlayerDatas = v
            end
        end
    end
    return this.mainPlayerDatas
end

--根据玩家id移除玩家
function SDBRoomData.RemovePlayer(playerId)
    local index = this.GetPlayerIndexById(playerId)
    if index ~= nil then
        table.remove(this.playerDatas, index)
    end
end

--获取自己是否在观战
function SDBRoomData.GetSelfIsLookGaming()
    if this.GetSelfIsLook() and this.gameIndex > 0 then
        return true
    end
    return false
end

--获取自己是否未坐下
function SDBRoomData.GetSelfIsLook()
    if this.GetSelfData().state == PlayerState.LookOn then
        return true
    end
    return false
end

--通过玩家ID获取玩家对象，所有数据都从该处获取
function SDBRoomData.GetPlayerDataById(playerId)
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
function SDBRoomData.GetPlayerIndexById(playerId)
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
function SDBRoomData.GetPlayerGender(playerId)
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
function SDBRoomData.GetReadyPlayer()
    local tab = {}
    for i = 1, #this.playerDatas do
        if this.playerDatas[i].state ~= PlayerState.LookOn then
            table.insert(tab, this.playerDatas[i])
        end
    end
    return tab
end

--根据座位号获取玩家信息
function SDBRoomData.GetPlayerBySeatNumber(seatId)
    for i = 1, #this.playerDatas do
        if this.playerDatas[i].seatNumber == seatId then
            return this.playerDatas[i]
        end
    end
end

--根据服务器座位号，获取本地座位号
function SDBRoomData.GetIndexBySeatNumber(num)
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

--是否是首局
function SDBRoomData.GetIsFristGame()
    if this.gameIndex == nil then
        return false
    end
    return this.gameIndex <= 1
end

--获取除去自己以外的玩家的座位id
function SDBRoomData.GetReadyOtherPlayerDatas()
    local tab = {}
    local playerDatas = this.GetReadyPlayer()
    for i = 1, #playerDatas do
        if playerDatas[i].id ~= this.mainId then
            table.insert(tab, playerDatas[i])
        end
    end
    return tab
end

function SDBRoomData.GetPlayerUIById(id)
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
function SDBRoomData.MainIsOwner()
    return this.mainId == this.owner
end

--主玩家是否是庄家
function SDBRoomData.MainIsBanker()
    return this.mainId == this.BankerPlayerId
end

--是否是金币场
function SDBRoomData.IsGoldGame()
    if IsNil(this.roomData) then
        return false
    end
    local moneyType = this.roomData.moneyType
    if moneyType == MoneyType.Gold then
        return true
    end
    return false
end