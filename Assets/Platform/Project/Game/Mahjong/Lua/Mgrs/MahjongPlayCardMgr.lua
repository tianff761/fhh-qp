--打牌管理
MahjongPlayCardMgr = {
    --
    --------------------------------------------------------------------
    --玩家
    players = nil,
    --玩家牌对象
    playerCardDatas = {},
    --玩家1，即主玩家
    mainPlayer = nil,
    --当前选中的牌，即提起的牌
    selectedCardItem = nil,
    --检测当前选中的牌，处理定时放下牌
    checkSelectedCardItemTimer = nil,
    --万的数量
    wanCardNum = 0,
    --条的数量，幺鸡牌时，不算条
    tiaoCardNum = 0,
    --筒的数量
    tongCardNum = 0,
    --听用牌数量，用于统计
    tingYongCardNum = 0,
    --万牌禁用标识
    wanCardForbidden = false,
    --条牌禁用标识
    tiaoCardForbidden = false,
    --筒牌禁用标识
    tongCardForbidden = false,

    --胡牌打牌的提示箭头是否显示
    isHuTipsArrowDisplay = false,
    --胡牌打牌的提示箭头项
    huTipsArrowItems = {},
    --明牌的数量集合
    mingCardNumDict = {},
    --明牌的数量对象
    mingCardNumObj = nil,
    --胡牌提示缓存的中间牌
    huTipsMidCards = nil,
    --胡牌提示缓存的摸的牌
    huTipsRight = 0,
    --------------------------------------------------------------------
    --以下数据在重设置的时候需要设置
    --是否已经处理了第一次定缺
    isHandledFristDingQue = false,
    --换张时存储提升的Item项
    changeCardUpItems = {},

    --------------------------------------------------------------------
    --按下的Item，即点击的牌
    downCardItem = nil,
    --按下的Item的Timer
    downCardItemTimer = nil,
    --鼠标按下的坐标
    mouseDownPositionX = 0,
    --鼠标按下的坐标
    mouseDownPositionY = 0,
    --记录鼠标位置
    lastMousePositionX = -10000,
    --记录鼠标位置
    lastMousePositionY = -10000,
    --鼠标按下于牌的坐标差，屏幕坐标
    downCardDifferX = 0,
    --鼠标按下于牌的坐标差，屏幕坐标
    downCardDifferY = 0,
    --是否开始拖牌移动
    isStartDargMove = false,
    --上一次鼠标弹起事件
    lastMouseUpTime = 0,
    --------------------------------------------------------------------
    --操作打牌的类型，即操作的类型
    opType = 0,
    --操作打牌的牌ID
    opCardId = 0,
    --操作打牌的玩家ID
    opPlayerId = "",
    --定缺牌数量
    dingQueCardNum = 0,
}

local this = MahjongPlayCardMgr

--屏幕坐标
local MinMovePositionY = 0

local mouseDownDifferX = 0
local mouseDownDifferY = 0
local mouseDownPosition = nil

local WanMax = 10
local TiaoMax = 20
local TongMax = 30

--初始化方法，调用其他方法前必须先初始化
function MahjongPlayCardMgr.Initialize()
    this.ResetChangeCardUpItems()
    this.InitPlayerCardDatas()
    this.InitPlayers()
end

--重置，用于小局结束调用
function MahjongPlayCardMgr.Reset()
    Log(">> MahjongPlayCardMgr > Reset > ................ > Reset.")

    ------------------------------------------------------
    this.ClearPlayerCardDatas()

    this.isHandledFristDingQue = false
    this.ResetChangeCardUpItems()

    this.ClearPlayers()

    this.selectedCardItem = nil
    this.StopCheckSelectedCardItemTimer()

    this.HideHuTipsArrow()
    ------------------------------------------------------
    --拖动相关
    this.StopDownCardItemTimer()
    this.downCardItem = nil
    this.isStartDargMove = false

    this.huTipsMidCards = nil
    this.huTipsRight = 0
end

--清除，用于退出房间
function MahjongPlayCardMgr.Clear()
    Log(">> MahjongPlayCardMgr > Clear > ................ > Clear.")

    ------------------------------------------------------
    this.ClearPlayerCardDatas()

    this.ClearPlayers()

    this.selectedCardItem = nil
    this.StopCheckSelectedCardItemTimer()

    this.HideHuTipsArrow()
    ------------------------------------------------------
    --拖动相关
    this.StopDownCardItemTimer()
    this.downCardItem = nil
    this.isStartDargMove = false
end

--销毁，用于完全卸载
function MahjongPlayCardMgr.Destroy()
    --Log(">> MahjongPlayCardMgr > Destroy > ................ > Destroy.")
    --销毁玩家，直接清除玩家
    this.players = nil
    this.huTipsArrowItems = {}
end

--================================================================
--牌局开始时清除处理，清除胡牌的显示项，清除牌局中间的出牌箭头
function MahjongPlayCardMgr.GameStartClean()
    --Log(">> MahjongPlayCardMgr > GameStartClean ... > GameStartClean.")
    --清除牌局的胡牌显示项
    if this.players ~= nil then
        for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
            this.players[i]:ClearHuCards()
        end
    end
    --清除出牌的箭头
    if MahjongRoomPanel.Instance ~= nil then
        MahjongRoomPanel.HideOutCardArrow()
    end
end

--================================================================
--
--初始化玩家牌数据
function MahjongPlayCardMgr.InitPlayerCardDatas()
    this.playerCardDatas = {}
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        this.playerCardDatas[i] = MahjongPlayerCardData.New()
    end
end

--清除玩家牌数据
function MahjongPlayCardMgr.ClearPlayerCardDatas()
    local length = #this.playerCardDatas
    for i = 1, length do
        this.playerCardDatas[i]:Clear()
    end
end

--获取玩家牌数据
function MahjongPlayCardMgr.GetPlayerCardDataByIndex(index)
    return this.playerCardDatas[index]
end

--初始化玩家方法，设定没有被销毁可以重复调用，应该只初始化一次
function MahjongPlayCardMgr.InitPlayers()
    if this.players ~= nil then
        return
    end
    this.players = {}
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        this.players[i] = MahjongPlayer.New()
        this.players[i]:SetSeatIndex(i)
    end
    this.mainPlayer = this.players[1]
end

--清除玩家显示相关
function MahjongPlayCardMgr.ClearPlayers()
    if this.players ~= nil then
        for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
            this.players[i]:Reset()
        end
    end
end

--获取打牌玩家对象
function MahjongPlayCardMgr.GetPlayerByIndex(index)
    if this.players ~= nil then
        return this.players[index]
    end
end

--重置换牌存储的Item
function MahjongPlayCardMgr.ResetChangeCardUpItems()
    this.changeCardUpItems = {}
end

--================================================================
--
--设置根Root
function MahjongPlayCardMgr.SetRoot(transform)
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        local node = transform:Find("Seat_" .. i)
        this.players[i]:SetNode(node)
    end
end

--================================================================
--
--通过ID获取玩家牌数据
function MahjongPlayCardMgr.GetPlayerCardDataById(id)
    local playerData = MahjongDataMgr.GetPlayerDataById(id)
    local playerCardData = this.playerCardDatas[playerData.seatIndex]
    return playerCardData
end

--更新玩家牌数据
function MahjongPlayCardMgr.UpdatePlayerCardData(data)
    TryCatchCall(this.InternalUpdatePlayerCardData, data)
end

--内部更新玩家牌数据
function MahjongPlayCardMgr.InternalUpdatePlayerCardData(data)
    local playerCards = data.players
    --临时玩家牌数据
    local tempData = nil
    --玩家数据
    local playerData = nil
    --玩家牌数据
    local playerCardData = nil

    for i = 1, #playerCards do
        tempData = playerCards[i]

        playerData = MahjongDataMgr.GetPlayerDataById(tempData.id)
        playerCardData = this.playerCardDatas[playerData.seatIndex]

        if playerCardData ~= nil then
            --设置玩家
            playerCardData:SetPlayer(tempData.id, tempData.seat, playerData.seatIndex)
            --设置定缺
            playerCardData:SetDingQue(playerData.dingQue)
            --更新状态
            playerCardData:SetOperateState(tempData.state)

            Log(i.." 号位玩家更新出牌数据，服务器推送数据长度为  "..#tempData.push)

            --更新牌数据
            playerCardData:UpdateCards(tempData.left, tempData.mid, tempData.right, tempData.push)
        end
    end
    --统计手牌
    this.UpdateHandCardsCount()
    --存储数据
    this.opType = data.type
    this.opPlayerId = data.id
    this.opCardId = data.card
end

--更新换张时玩家牌数据，只有手牌和右手牌，针对回放使用
function MahjongPlayCardMgr.UpdatePlayerCardDataByChange(data)
    TryCatchCall(this.InternalUpdatePlayerCardDataByChange, data)
end

--内部更新换张时玩家牌数据
function MahjongPlayCardMgr.InternalUpdatePlayerCardDataByChange(data)
    local playerCards = data.players
    --临时玩家牌数据
    local tempData = nil
    --玩家数据
    local playerData = nil
    --玩家牌数据
    local playerCardData = nil

    for i = 1, #playerCards do
        tempData = playerCards[i]
        playerData = MahjongDataMgr.GetPlayerDataById(tempData.id)
        playerCardData = this.playerCardDatas[playerData.seatIndex]
        if playerCardData ~= nil then
            --更新牌数据
            playerCardData:UpdateHandCards(nil, tempData.mid, tempData.right)
        end
    end
    --统计手牌
    this.UpdateHandCardsCount()
end

--更新玩家牌局显示，外部调用接口
function MahjongPlayCardMgr.UpdatePlayerCardDisplay(isDisplayCards)
    local tempIsDisplayCards = false
    if isDisplayCards ~= nil then
        tempIsDisplayCards = isDisplayCards
    end
    TryCatchCall(this.InternalUpdatePlayerCardDisplay, MahjongDataMgr.isPlayback or tempIsDisplayCards)
end

--内部更新玩家牌局显示
function MahjongPlayCardMgr.InternalUpdatePlayerCardDisplay(isDisplayCards)
    local playerCardData = nil
    local player = nil
    local length = #this.playerCardDatas
    for i = 1, length do
        playerCardData = this.playerCardDatas[i]
        if playerCardData.isActive then
            --更新玩家牌局显示
            player = this.players[playerCardData.seatIndex]
            if player ~= nil then
                player.seatNumber = playerCardData.seatNumber
                player.id = playerCardData.playerId

                player:UpdateCards(playerCardData.operateState, playerCardData.leftCards, playerCardData.midCards,
                    playerCardData.rightCard, isDisplayCards)

                player:UpdateOutCards(playerCardData.pushCards)
            end
        end
    end

    if MahjongDataMgr.isPlayback then
        this.UpdateAllPlayerOutCardByChange()
        this.UpdateAllPlayerDingQueCards()
    else
        this.UpdateMainPlayerOutCardByChange()
        this.UpdateMainPlayerDingQueCards()

        local state = MahjongDataMgr.Operation.state
        if state ~= MahjongOperatePanelState.Change and state ~= MahjongOperatePanelState.DingQue then
            this.CheckHuTips()
        end
    end
end

--检测胡牌提示相关
function MahjongPlayCardMgr.CheckHuTips()
    TryCatchCall(this.InternalCheckHuTips)
    --
    if MahjongRoomPanel.Instance ~= nil then
        MahjongRoomPanel.Instance.CheckHuTipsBtnDisplay()
    end
    --
    this.UpdateHuTips()
end

--检测胡牌提示相关
function MahjongPlayCardMgr.InternalCheckHuTips()
    if MahjongDataMgr.IsTingTips() then
        if MahjongDataMgr.isYaoJiPlayWay then
            --需要处理反复检测，比如连续断线重连的时候，牌型没改变就不需要检测
            local playerCardData = this.playerCardDatas[MahjongSeatIndex.Seat1]
            if this.IsHandCardsChanged(playerCardData.midCards, playerCardData.right) then
                --测试
                --LogError("Test ===================================================================Start.")
                -- local time = os.timems()
                -- local dingQue = MahjongColorType.Tiao
                -- local left = {
                --     -- {
                --     --     type = MahjongOperateCode.PENG,
                --     --     from = 0,
                --     --     k1 = 1801,
                --     --     k2 = 1802,
                --     --     k3 = 1803,
                --     --     k4 = 0,
                --     -- },
                --     -- {
                --     --     type = MahjongOperateCode.PENG,
                --     --     from = 0,
                --     --     k1 = 1901,
                --     --     k2 = 1902,
                --     --     k3 = 1903,
                --     --     k4 = 0,
                --     -- }
                -- }
                -- local mid = { 101, 201, 202, 301, 302, 303, 401, 402, 501, 701, 702, 801, 901 }
                --local right = 201
                --local mid = { 1101, 1102, 1103, 1601, 501, 602, 703 }
                -- local right = 902
                -- MahjongTingHelper.SetCheckPrepareData(MahjongDataMgr.rules, dingQue, left)
                -- local temp = MahjongTingHelper.GetTipsData(mid, right)
                -- if temp ~= nil then
                --     for k, v in pairs(temp) do
                --         LogError(k, v)
                --     end
                -- else
                --     LogError("Test == nil")
                -- end
                --LogError("Test ===================================================================End.", os.timems() - time)
                --
                --先清除数据
                MahjongDataMgr.HuTips.tipsData = nil

                --LogError( this.dingQueCardNum )
                --2张以上就不处理胡，因为注定不能胡
                if this.dingQueCardNum < 2 then
                    --LogError(">> MahjongPlayCardMgr.InternalCheckHuTips > 5")

                    local total = #playerCardData.leftCards * 3 + #playerCardData.midCards
                    --牌张数量正确才进行处理
                    if playerCardData.rightCard ~= nil then
                        total = total + 1
                    end

                    --LogError(total , MahjongDataMgr.cardTotal, this.dingQueCardNum )

                    if total > MahjongDataMgr.cardTotal then
                        --LogError(">> MahjongPlayCardMgr.InternalCheckHuTips > 6")
                        --local temp = os.timems()
                        MahjongHelper.SetRules(MahjongDataMgr.cardTotal, playerCardData.dingQue, MahjongDataMgr.multiple,
                            MahjongDataMgr.isCheckZhongZhang, MahjongDataMgr.isCheckMenQing,
                            MahjongDataMgr.isCheckJinGouDiao, MahjongDataMgr.isCheckYaoJiu,
                            MahjongDataMgr.isCheckJiangDui)
                        MahjongHelper.SetLeftCards(this.GetLeftCardData(playerCardData.left))
                        --MahjongTingHelper.SetCheckPrepareData(MahjongDataMgr.rules, playerCardData.dingQue, playerCardData.left)
                        --MahjongDataMgr.HuTips.tipsData = MahjongTingHelper.GetTipsData(playerCardData.mid, playerCardData.right)
                        local tempResult = MahjongHelper.Check(playerCardData.mid or {}, playerCardData.right or 0)
                        MahjongDataMgr.HuTips.tipsData = this.GetTingResult(tempResult)
                        --LogWarn(">> MahjongPlayCardMgr.CheckHuTips =======================================", os.timems() - temp)
                    elseif this.dingQueCardNum == 0 then
                        --LogError(">> MahjongPlayCardMgr.InternalCheckHuTips > 7")
                        --零听用的手牌时也进行一次检测
                        MahjongHelper.SetRules(MahjongDataMgr.cardTotal, playerCardData.dingQue, MahjongDataMgr.multiple,
                            MahjongDataMgr.isCheckZhongZhang, MahjongDataMgr.isCheckMenQing,
                            MahjongDataMgr.isCheckJinGouDiao, MahjongDataMgr.isCheckYaoJiu,
                            MahjongDataMgr.isCheckJiangDui)
                        MahjongHelper.SetLeftCards(this.GetLeftCardData(playerCardData.left))
                        --MahjongTingHelper.SetCheckPrepareData(MahjongDataMgr.rules, playerCardData.dingQue, playerCardData.left)
                        local tempResult = MahjongHelper.Check(playerCardData.mid or {}, 0)
                        --MahjongDataMgr.HuTips.huData = MahjongTingHelper.GetHuData(playerCardData.mid)
                        MahjongDataMgr.HuTips.huData = this.GetHuResult(tempResult)
                    end
                end
            end
        end
        --处理胡牌数据的清除
        if MahjongDataMgr.operateState == MahjongOperateState.Play then
            MahjongDataMgr.HuTips.huData = nil
        elseif MahjongDataMgr.operateState == MahjongOperateState.Operate then
            local playerCardData = this.playerCardDatas[MahjongSeatIndex.Seat1]
            if playerCardData ~= nil then
                --有右手摸牌的操作
                if playerCardData.right ~= nil and playerCardData.right > 0 then
                    MahjongDataMgr.HuTips.huData = nil
                else
                    --碰杠胡等没有右手摸牌的操作
                    local isChanged = MahjongDataMgr.CheckHuTingCardIsChanged(playerCardData.mid)
                    if isChanged then
                        MahjongDataMgr.HuTips.huData = nil
                    end
                end
                MahjongDataMgr.SetHuTingCardData(playerCardData.mid)
            else
                MahjongDataMgr.HuTips.huData = nil
            end
        end
    end
end

--获取C#层的数据
function MahjongPlayCardMgr.GetLeftCardData(left)
    local list = {}
    if left ~= nil then
        local temp = nil
        local data = nil
        for i = 1, #left do
            temp = left[i]
            data = MahjongLeftData.New(temp.k1, temp.type)
            table.insert(list, data)
        end
    end
    return list
end

function MahjongPlayCardMgr.GetTingResult(list)
    if list ~= nil then
        local result = {}
        local datas = list:ToTable()
        local data = nil
        local tempDatas = nil
        local tempData = nil
        local newDatas = nil
        for i = 1, #datas do
            data = datas[i]
            newDatas = {}
            if data.list ~= nil then
                tempDatas = data.list:ToTable()
                for j = 1, #tempDatas do
                    tempData = tempDatas[j]
                    table.insert(newDatas, { key = tempData.key, fanNum = tempData.fanNum, surplus = 0 })
                end
            end
            result[data.key] = newDatas
        end
        return result
    end

    return nil
end

function MahjongPlayCardMgr.GetHuResult(list)
    if list ~= nil then
        local datas = list:ToTable()
        local data = nil
        local tempDatas = nil
        local tempData = nil
        local newDatas = nil
        if #datas > 0 then
            data = datas[1]
            newDatas = {}
            if data.list ~= nil then
                tempDatas = data.list:ToTable()
                for j = 1, #tempDatas do
                    tempData = tempDatas[j]
                    table.insert(newDatas, { key = tempData.key, fanNum = tempData.fanNum, surplus = 0 })
                end
            end
        end
        return newDatas
    end

    return nil
end

--设置手牌数据
function MahjongPlayCardMgr.SetHandCards(midCards, right)
    if right == nil or not IsNumber(right) then
        right = 0
    end
    this.huTipsMidCards = midCards
    this.huTipsRight = right
    if MahjongDataMgr.isYaoJiPlayWay then
        MahjongDataMgr.HuTips.tipsData = nil
    end
end

--是否手牌改变
function MahjongPlayCardMgr.IsHandCardsChanged(midCards, right)
    local result = false
    if midCards ~= nil then
        if this.huTipsMidCards == nil or #midCards ~= #this.huTipsMidCards then
            result = true
        else
            for i = 1, #midCards do
                if midCards[i].id ~= this.huTipsMidCards[i].id then
                    result = true
                    break
                end
            end
        end

        if right == nil or not IsNumber(right) then
            right = 0
        end
        if this.huTipsRight ~= right then
            result = true
        end
    end

    if result then
        this.huTipsMidCards = midCards
        this.huTipsRight = right
    end

    return result
end

--更新玩家牌数据通过结算
function MahjongPlayCardMgr.UpdatePlayerCardDataBySettlement(data)
    TryCatchCall(this.InternalUpdatePlayerCardDataBySettlement, data)
end

--内部更新玩家牌数据通过结算
function MahjongPlayCardMgr.InternalUpdatePlayerCardDataBySettlement(data)
    local playerCards = data
    --临时玩家牌数据
    local tempData = nil
    --玩家数据
    local playerData = nil
    --玩家牌数据
    local playerCardData = nil

    for i = 1, #playerCards do
        tempData = playerCards[i]

        playerData = MahjongDataMgr.GetPlayerDataById(tempData.id)
        playerCardData = this.playerCardDatas[playerData.seatIndex]

        if playerCardData ~= nil then
            --更新状态
            if tempData.state ~= nil then
                playerCardData:SetOperateState(tempData.state)
            end
            --更新牌数据
            playerCardData:UpdateHandCards(tempData.left, tempData.mid, tempData.right)
        end
    end
    --统计手牌
    this.UpdateHandCardsCount()
end

--获取玩家的牌局数，通过结算数据
function MahjongPlayCardMgr.GetNewPlayerCardDataBySettlement(seatIndex, data)
    local playerCardData = MahjongPlayerCardData.New()
    playerCardData:SetPlayer(data.id, data.seat, seatIndex)
    if data.state ~= nil then
        playerCardData:SetOperateState(data.state)
    end
    playerCardData:UpdateHandCards(data.left, data.mid, data.right)
    return playerCardData
end

--================================================================
--恢复牌局显示
function MahjongPlayCardMgr.ResumeCardsDisplay()
    --Log(">> MahjongPlayCardMgr > ResumeCardsDisplay.")
    local playerCardData = this.playerCardDatas[MahjongSeatIndex.Seat1]
    if playerCardData ~= nil then
        MahjongDataMgr.operateState = playerCardData.operateState
        Log(">> MahjongPlayCardMgr > ResumeCardsDisplay > operateState = " .. tostring(MahjongDataMgr.operateState))
        this.mainPlayer:UpdateCards(playerCardData.operateState, playerCardData.leftCards, playerCardData.midCards,
            playerCardData.rightCard, false)

        this.mainPlayer:UpdateOutCards(playerCardData.pushCards)

        --更新定缺牌
        this.UpdateMainPlayerDingQueCards()
        --恢复胡牌提示箭头
        this.UpdateHuTips()
        --清除打出牌的选中项
        this.CheckClearOutCardsSelected()

        if MahjongRoomPanel.Instance ~= nil then
            MahjongRoomPanel.Instance.UpdateOutCardArrow(this.opType, this.opPlayerId, this.opCardId)
        end
    end
end

----------------------------------------------------------------
--
--更新模拟打牌后的数据
function MahjongPlayCardMgr.UpdateSimulateData(playCardId, leftCards, midCards, rightCard, pushCards)
    Log(">> MahjongPlayCardMgr > UpdateSimulateData > operateState = ", MahjongDataMgr.operateState)
    --Log(midCards, rightCard)
    this.mainPlayer:UpdateCards(MahjongDataMgr.operateState, leftCards, midCards, rightCard, false)
    this.mainPlayer:UpdateOutCards(pushCards)

    this.UpdateMainPlayerDingQueCards()
    this.CheckClearOutCardsSelected()

    --隐藏胡牌提示箭头
    this.HideHuTipsArrow()
    --设置检测听用牌，主要是给幺鸡玩法使用
    this.SetHandCards(midCards, rightCard)
    --设置听牌提示的缓存牌数据，主要是给服务器的听牌使用
    MahjongDataMgr.SetHuTingCardByCardData(midCards)

    if MahjongRoomPanel.Instance ~= nil then
        MahjongRoomPanel.Instance.CheckHuTipsBtnDisplay()
        MahjongRoomPanel.Instance.UpdateOutCardArrow(MahjongOperateCode.CHU_PAI, this.mainPlayer.id, playCardId)
    end
end

----------------------------------------------------------------
--
--获取主玩家的最后一个牌
function MahjongPlayCardMgr.GetMainPlayerLastCardItem()
    local tempHandCardsLength = this.mainPlayer.allHandCardsLength
    local cardItem = this.mainPlayer.allHandCardsItems[tempHandCardsLength]
    return cardItem
end

--获取主玩家
function MahjongPlayCardMgr.GetMainPlayer()
    return this.mainPlayer
end

--是否有摸的牌
function MahjongPlayCardMgr.IsNewCardValid()
    if this.mainPlayer ~= nil then
        return this.mainPlayer:IsNewCardValid()
    end
    return false
end

--是否初始化了牌局显示
function MahjongPlayCardMgr.IsInitCardDisplay()
    if this.mainPlayer ~= nil then
        return this.mainPlayer.isInitCardDisplay
    end
    return false
end

--检测主玩家的手牌，并按顺序检测，相同返回true，否则返回flase
function MahjongPlayCardMgr.CheckMainPlayerHandCards(midCards, rightCard)
    if this.mainPlayer == nil then
        return false
    end

    if this.mainPlayer.allHandCards == nil or midCards == nil then
        return false
    end

    local length = #midCards
    local allHandCards = this.mainPlayer.allHandCards

    for i = 1, length do
        if midCards[i] ~= allHandCards[i] then
            return false
        end
    end

    if rightCard ~= nil and rightCard ~= allHandCards[length + 1] then
        return false
    end
    return true
end

--检测玩家新的手牌，返回玩家新手牌数据中不在老手牌数据中的牌
function MahjongPlayCardMgr.CheckPlayerNewHandCards(seatIndex, midCards, rightCard)
    local player = this.players[seatIndex]
    if player == nil then
        return nil
    end

    if player.allHandCards == nil or midCards == nil then
        return nil
    end

    Log(">> MahjongPlayCardMgr.CheckPlayerHandCards > 检测手牌", seatIndex)

    local result = {}
    local length = #midCards
    local card = nil
    for i = 1, length do
        card = midCards[i]
        if card ~= nil and not this.CheckInHandCards(card, player.allHandCards) then
            table.insert(result, card)
        end
    end

    if rightCard ~= nil and not this.CheckInHandCards(rightCard, player.allHandCards) then
        table.insert(result, rightCard)
    end
    return result
end

--检测牌是否存在手牌中
function MahjongPlayCardMgr.CheckInHandCards(card, allHandCards)
    local length = #allHandCards
    local temp = nil
    for i = 1, length do
        temp = allHandCards[i]
        if temp ~= nil and card.id == temp.id then
            return true
        end
    end
    return false
end

--================================================================
--
--------------------处理点击拖动--------------------
--
--是可以操作手牌项
function MahjongPlayCardMgr.IsClickCardItem()
    --回放时不能操作
    if MahjongDataMgr.isPlayback then
        Log(">> MahjongPlayCardMgr.IsClickCardItem > isPlayback")
        return false
    end

    --换牌选牌后，不能点击牌，定缺2个状态也不能点击牌
    if MahjongDataMgr.tableState > MahjongPlayerTableState.ChangingCard then
        Log(">> MahjongPlayCardMgr.IsClickCardItem > MahjongPlayerTableState.ChangingCard > Over.",
            MahjongDataMgr.tableState)
        return false
    end

    --胡牌后不操作
    if this.mainPlayer.isHu then
        Log(">> MahjongPlayCardMgr.IsClickCardItem > isHu")
        return false
    end

    return true
end

--是否可以出牌
function MahjongPlayCardMgr.IsCanPlayCard()
    Log(">> MahjongPlayCardMgr.IsCanPlayCard > MahjongDataMgr.operateState = ", MahjongDataMgr.operateState)
    if MahjongDataMgr.operateState == MahjongOperateState.Play then
        return true
    end

    if MahjongDataMgr.operateState == MahjongOperateState.Operate and this.mainPlayer:IsNewCardValid() then
        return true
    end

    return false
end

--启动拖动的Timer
function MahjongPlayCardMgr.StartDownCardItemTimer()
    if this.downCardItemTimer == nil then
        this.downCardItemTimer = UpdateTimer.New(this.OnDownCardItemTimer)
    end
    this.lastMousePositionX = -10000
    this.lastMousePositionY = -10000
    this.downCardItemTimer:Start()
end

--停止拖动的Timer
function MahjongPlayCardMgr.StopDownCardItemTimer()
    if this.downCardItemTimer ~= nil then
        this.downCardItemTimer:Stop()
    end
end

--帧调用，判断处理鼠标移动
function MahjongPlayCardMgr.OnDownCardItemTimer()
    mouseDownPosition = Input.mousePosition
    mouseDownDifferY = math.abs(mouseDownPosition.y - this.lastMousePositionY)
    --大于1像素才处理拖动
    if mouseDownDifferY > 1 then
        this.HandleMouseMove(mouseDownPosition)
    else
        mouseDownDifferX = math.abs(mouseDownPosition.x - this.lastMousePositionX)
        if mouseDownDifferX > 1 then
            this.HandleMouseMove(mouseDownPosition)
        end
    end
end

--处理鼠标移动
function MahjongPlayCardMgr.HandleMouseMove(mouseDownPosition)
    this.OnHandCardItemMove(mouseDownPosition)
    this.lastMousePositionX = mouseDownPosition.x
    this.lastMousePositionY = mouseDownPosition.y
end

----------------------------------------------------------------
--
--按下
function MahjongPlayCardMgr.OnHandCardItemDown(listener, eventData)
    Log(">> MahjongPlayCardMgr > OnHandCardItemDown > index = " .. listener.name)

    --当前有拖的项就不再处理
    if this.downCardItem ~= nil and this.downCardItem:IsActive() then
        if this.downCardItemTimer ~= nil and this.downCardItemTimer.running then
            --如果显示项存在，且是显示的牌，且Timer在运行，说明该显示项在处理，故不在进行第二次处理
            return
        end
        --还原该麻将
        this.ResetCardItem(this.downCardItem)
    end

    this.downCardItem = nil

    --------------------------------
    if this.IsClickCardItem() == false then
        Log(">> MahjongPlayCardMgr > OnHandCardItemDown > this.IsClickCardItem() == false.")
        return
    end

    local index = tonumber(listener.name)
    local cardItem = this.mainPlayer.allHandCardsItems[index]
    if cardItem == nil or cardItem.clickEnabled == false then
        Log(">> MahjongPlayCardMgr > OnHandCardItemDown > cardItem == nil or cardItem.clickEnabled == false.")
        return
    end

    --------------------------------
    local mousePosition = Input.mousePosition

    this.mouseDownPositionX = mousePosition.x
    this.mouseDownPositionY = mousePosition.y

    this.lastMousePositionX = mousePosition.x
    this.lastMousePositionY = mousePosition.y

    local rectTransform = listener:GetRectTransform()

    local itemScreenPosition = RectTransformUtility.WorldToScreenPoint(UIConst.uiCamera, rectTransform.position)

    this.downCardDifferX = mousePosition.x - itemScreenPosition.x
    this.downCardDifferY = mousePosition.y - itemScreenPosition.y

    --Log("this.downCardDifferX = ", this.downCardDifferX)
    --Log("this.downCardDifferY = ", this.downCardDifferY)
    cardItem.rectTransform = rectTransform

    --有换牌状态则进行换牌处理，换牌时不拖动，就不需要启动Timer
    if MahjongDataMgr.tableState == MahjongPlayerTableState.ChangingCard then
        this.HandleChangeCardsItemDown(cardItem)
    else
        this.downCardItem = cardItem
        this.HandleCardItemDown(cardItem)
    end
end

--松开
function MahjongPlayCardMgr.OnHandCardItemUp(listener, eventData)
    Log(">> MahjongPlayCardMgr > OnHandCardItemUp > index = " .. listener.name)

    local index = tonumber(listener.name)
    local cardItem = this.mainPlayer.allHandCardsItems[index]
    if cardItem == nil then
        Toast.Show("错误操作")
        --重新刷新下主玩家的牌
        this.ResumeCardsDisplay()
        Log(">> MahjongPlayCardMgr > OnHandCardItemUp > cardItem == nil")
        return
    end

    --如果拖的项为nil或者和放开的项是同一个需要处理拖动
    if this.downCardItem == nil or this.downCardItem == cardItem then
        this.StopDownCardItemTimer()
        this.isStartDargMove = false
    end

    if this.IsClickCardItem() == false then
        Log(">> MahjongPlayCardMgr > OnHandCardItemUp > this.IsClickCardItem() == false.")
        return
    end

    if cardItem.clickEnabled == false then
        --放开时，该牌不能打就还原
        cardItem:PlayMoveResetPosition()
        Log(">> MahjongPlayCardMgr > OnHandCardItemUp > cardItem.clickEnabled == false.")
        return
    end

    --点击牌的音效
    MahjongAudioMgr.ClickCard()
    --
    if MahjongDataMgr.tableState == MahjongPlayerTableState.ChangingCard then
        this.HandleChangeCardsItemUp(cardItem)
    else
        --如果当前放开的牌，是当前按下的牌，才把按下的设置nil
        if this.downCardItem ~= nil and this.downCardItem == cardItem then
            this.downCardItem = nil
        end
        this.HandleCardItemUp(cardItem)
    end
end

--移动
function MahjongPlayCardMgr.OnHandCardItemMove(mousePosition)
    --如果没有按下项则不处理
    if this.downCardItem == nil then
        this.StopDownCardItemTimer()
        return
    end

    if this.isStartDargMove == false then
        local tx = math.abs(mousePosition.x - this.mouseDownPositionX)
        local ty = math.abs(mousePosition.y - this.mouseDownPositionY)
        --如果移动的坐标于按下的坐标大于5，判断为拖动，否则不算拖动
        if tx < 5 and ty < 5 then
            return
        end

        this.isStartDargMove = true
        --Log(">> MahjongPlayCardMgr > OnHandCardItemMove > mousePosition")
        --开始移动的时候，停止牌的动画
        this.downCardItem:StopMoveTweener()
        this.downCardItem:SaveSiblingIndex()
        this.downCardItem:SetAsLastSibling()

        --开始拖动的时候处理标记
        this.SetSelectedCard(this.downCardItem.cardKey)
    end

    --------------------------------
    --牌无法往下拖
    local newPositionX = mousePosition.x - this.downCardDifferX
    local newPositionY = mousePosition.y - this.downCardDifferY
    if newPositionY < MinMovePositionY then
        newPositionY = MinMovePositionY
    end
    --Log(">> MahjongPlayCardMgr > newPositionX = " .. newPositionX)
    --Log(">> MahjongPlayCardMgr > newPositionY = " .. newPositionY)
    local newPosition = UIUtil.ScreenToPosition(this.downCardItem.rectTransform, Vector2(newPositionX, newPositionY),
        UIConst.uiCamera)
    local position = this.downCardItem.rectTransform.position
    UIUtil.SetPosition(this.downCardItem.gameObject, newPosition.x, newPosition.y, position.z)
end

--重置的拖动显示对象
function MahjongPlayCardMgr.ResetDownCardItem()
    this.StopDownCardItemTimer()

    if this.isStartDargMove then
        this.ClearSelectedCard()
        this.isStartDargMove = false
    end

    if this.downCardItem ~= nil then
        this.ResetCardItem(this.downCardItem)
        this.downCardItem = nil
    end
end

--重置显示对象
function MahjongPlayCardMgr.ResetCardItem(cardItem)
    --位置还原
    cardItem:ResetPosition()

    --颜色还原，如果不是定缺如果是定缺则需要设置成定缺牌
    cardItem:UpdateMaskColor()
end

--设置选中的牌
function MahjongPlayCardMgr.SetSelectedCardItem(cardItem)
    this.selectedCardItem = cardItem
    this.StartCheckSelectedCardItemTimer()
end

--检测和取消提起来的牌
function MahjongPlayCardMgr.CheckAndCancelSelectedCardItem()
    if MahjongDataMgr.isPlayback then
        return
    end
    this.CancelSelectedCardItem()
end

--取消选中的牌
function MahjongPlayCardMgr.CancelSelectedCardItem()
    this.StopCheckSelectedCardItemTimer()
    --重置取消掉双击时间处理
    this.lastMouseUpTime = 0
    if this.selectedCardItem ~= nil then
        this.selectedCardItem:PlayMoveReset()
    end
    this.ClearSelectedCard()
    this.selectedCardItem = nil
end

--启动选中牌的放下检测
function MahjongPlayCardMgr.StartCheckSelectedCardItemTimer()
    --Log(">> MahjongPlayCardMgr.StartCheckSelectedCardItemTimer")
    if this.checkSelectedCardItemTimer == nil then
        this.checkSelectedCardItemTimer = Timing.New(this.OnCheckSelectedCardItemTimer, 4, 1, true)
    end
    this.checkSelectedCardItemTimer:Restart()
end

--停止选中牌的放下检测
function MahjongPlayCardMgr.StopCheckSelectedCardItemTimer()
    --Log(">> MahjongPlayCardMgr.StopCheckSelectedCardItemTimer")
    if this.checkSelectedCardItemTimer ~= nil then
        this.checkSelectedCardItemTimer:Stop()
    end
end

--选中牌的放下检测处理
function MahjongPlayCardMgr.OnCheckSelectedCardItemTimer()
    --Log(">> MahjongPlayCardMgr.OnCheckSelectedCardItemTimer")
    if this.downCardItem == nil or this.downCardItem ~= this.selectedCardItem then
        this.CancelSelectedCardItem()
    else
        this.StopCheckSelectedCardItemTimer()
    end
end

--================================================================
--处理手牌按下
function MahjongPlayCardMgr.HandleCardItemDown(clickCardItem)
    --如果该打牌或者操作时有手牌都可以拖牌，否则就不能拖牌
    --幺鸡玩法，幺鸡牌也可以拖动，但是不能打出
    if this.IsCanPlayCard() then
        this.StartDownCardItemTimer()
    end

    clickCardItem.isPressLastUp = clickCardItem:IsUp()
    clickCardItem:PlayMovePressDownPosition()

    --幺鸡玩法，听用牌拖动时，不处理当前提起的牌
    if MahjongUtil.IsTingYongCard(clickCardItem.cardKey) then
        return
    end

    --如果有提起的牌，且不是同一个，则需要放下
    if this.selectedCardItem ~= clickCardItem then
        this.CancelSelectedCardItem()
    end
end

--处理手牌放开
function MahjongPlayCardMgr.HandleCardItemUp(clickCardItem)
    local time = Time.realtimeSinceStartup
    local isDoubleClick = time - this.lastMouseUpTime < 0.5
    this.lastMouseUpTime = time

    local position = clickCardItem.rectTransform.anchoredPosition
    --Y值大于一定距离，则判断是可以打牌的；或者牌是提起的
    if isDoubleClick or position.y > MahjongConst.HandCardPressDownY then
        if MahjongUtil.IsTingYongCard(clickCardItem.cardKey) then
            Toast.Show("幺鸡玩法，听用牌不能被打出")
            clickCardItem:PlayMoveResetPosition()
        end

        if this.IsCanPlayCard() then
            this.PlayCard(clickCardItem)
            if MahjongDataMgr.isYaoJiPlayWay == false then
                PanelManager.Close(MahjongPanelConfig.HuTips)
            end
            return
        end
    end

    --处理不打牌
    if MahjongUtil.IsTingYongCard(clickCardItem.cardKey) then
        Toast.Show("幺鸡玩法，听用牌不能被打出")
        clickCardItem:PlayMoveResetPosition()
    end

    --表示放开该牌的时候是提升的才处理
    if clickCardItem:IsUp() then
        --如果按下之前是提起的，则认为是第二次点击，需要判断打牌
        if clickCardItem.isPressLastUp then
            local isSendCard = false
            --等于的意图是牌被提起的高度，也可以打牌
            if position.y > MahjongConst.PlayCardUpY then
                if this.IsCanPlayCard() then
                    isSendCard = true
                    this.PlayCard(clickCardItem)
                end
            end

            if isSendCard == false then
                clickCardItem:PlayMoveResetPosition()
                this.ClearSelectedCard()
            end
            if MahjongDataMgr.isYaoJiPlayWay == false then
                --每次都要处理该界面
                PanelManager.Close(MahjongPanelConfig.HuTips)
            end
        else
            --按下之前是未提起的牌，则需要提起该牌，放下其他所有牌
            local length = #this.mainPlayer.allHandCardsItems
            local cardItem = nil
            for i = 1, length do
                cardItem = this.mainPlayer.allHandCardsItems[i]
                if cardItem ~= nil and cardItem ~= clickCardItem then
                    cardItem:PlayMoveReset()
                end
            end
            --处理放开的牌
            this.SetSelectedCardItem(clickCardItem)
            clickCardItem:PlayMoveUpPosition()
            this.SetSelectedCard(clickCardItem.cardKey)

            --处理胡牌面板提示
            if MahjongDataMgr.IsTingTips() and MahjongDataMgr.HuTips.tipsData ~= nil then
                local huTipsData = MahjongDataMgr.HuTips.tipsData[clickCardItem.cardKey]
                if huTipsData ~= nil then
                    PanelManager.Open(MahjongPanelConfig.HuTips, huTipsData)
                else
                    PanelManager.Close(MahjongPanelConfig.HuTips)
                end
            end
            --
        end
    else
        clickCardItem:PlayMoveResetPosition()
    end
    --
end

--打牌
function MahjongPlayCardMgr.PlayCard(clickCardItem)
    MahjongPlayCardHelper.PlayCard(clickCardItem)
end

--清除打牌信息
function MahjongPlayCardMgr.ClearPlayCard()
    MahjongPlayCardHelper.Clear()
end

--================================================================
--
------------------换牌处理------------------
--
--处理换牌鼠标按下
function MahjongPlayCardMgr.HandleChangeCardsItemDown(clickCardItem)
    --Log(">> MahjongPlayCardMgr > HandleChangeCardsItemDown >", clickCardItem.cardData)
    --幺鸡玩法，换牌时，幺鸡牌可以升起，放开时，落下
    if MahjongUtil.IsTingYongCard(clickCardItem.cardKey) then
        clickCardItem:PlayMovePressDownPosition()
        return
    end

    --如果点击牌是提起的状态，则放下
    if clickCardItem:IsUp() then
        --存储处理前的状态
        clickCardItem.isPressLastUp = true
        clickCardItem:UpdateMaskColor()
        clickCardItem:PlayMovePressDownPosition()
        --放下一张牌，牌数不够，设置换牌按钮状态
        SendEvent(CMD.Game.Mahjong.UpdateChangeCardButton, false)
    else
        clickCardItem.isPressLastUp = false
        --检测提起的换牌
        this.CheckChangeCardsItemByDown(clickCardItem)
    end
end

--处理换牌鼠标放开，只是处理牌的位置
function MahjongPlayCardMgr.HandleChangeCardsItemUp(clickCardItem)
    --Log(">> MahjongPlayCardMgr > HandleChangeCardsItemUp > cardKey = ", clickCardItem.cardKey)
    --幺鸡玩法，换牌时，幺鸡牌可以升起，放开时，落下
    if MahjongUtil.IsTingYongCard(clickCardItem.cardKey) then
        clickCardItem:PlayMoveResetPosition()
        return
    end
    --Log(">> MahjongPlayCardMgr > HandleChangeCardsItemUp > IsUp = ", clickCardItem:IsUp())
    --Log(">> MahjongPlayCardMgr > HandleChangeCardsItemUp > isPressLastUp = ", clickCardItem.isPressLastUp)
    --放开时，如果当前牌提起的，才进行处理
    if clickCardItem:IsUp() then
        if clickCardItem.isPressLastUp then
            clickCardItem:PlayMoveResetPosition()
            this.RemoveChangeCardsItem(clickCardItem)
        else
            clickCardItem:PlayMoveUpPosition()
            this.CheckChangeCardsItemByUp(clickCardItem)
        end
    else
        clickCardItem:PlayMoveResetPosition()
    end
end

--排序，生成新的对象
function MahjongPlayCardMgr.SortChangeCardsItem(newCardItem)
    local tempIndex = 0
    local tempItems = {}

    local cardItem = nil
    for i = 1, 4 do
        cardItem = this.changeCardUpItems[i]
        if cardItem ~= nil and cardItem ~= newCardItem and cardItem:IsValid() and cardItem:IsUp() then
            tempIndex = tempIndex + 1
            tempItems[tempIndex] = cardItem
        end
    end
    if newCardItem ~= nil and newCardItem:IsUp() then
        tempIndex = tempIndex + 1
        tempItems[tempIndex] = newCardItem
    end

    this.changeCardUpItems = tempItems
    return tempIndex
end

--删除
function MahjongPlayCardMgr.RemoveChangeCardsItem(clickCardItem)
    local cardItem = nil
    local isFound = false
    for i = 1, 4 do
        cardItem = this.changeCardUpItems[i]
        if cardItem ~= nil and cardItem.cardData ~= nil and cardItem.cardData.id == clickCardItem.cardData.id then
            this.changeCardUpItems[i] = nil
            isFound = true
            break
        end
    end

    if isFound then
        local upCardCount = this.SortChangeCardsItem()
        --检测是否可以发送换牌，设置换牌按钮的状态
        SendEvent(CMD.Game.Mahjong.UpdateChangeCardButton, upCardCount >= MahjongDataMgr.changeCardTotal)
    end
end

--检测换张的提起项
function MahjongPlayCardMgr.CheckChangeCardsUpItems(clickCardItem)
    --检测同一花色牌张使用
    local tempType = clickCardItem.cardData.type
    --当前提升的牌是否跟已经提升的牌是同一花色标识
    local isSameColorCard = true
    --
    local cardItem = nil
    local length = this.mainPlayer.allHandCardsLength
    if MahjongDataMgr.changeCardType == MahjongChangeCardType.SingleColor then
        for i = 1, length do
            cardItem = this.mainPlayer.allHandCardsItems[i]
            --找到第一个提起的牌
            if cardItem ~= nil and cardItem:IsUp() then
                isSameColorCard = tempType == cardItem.cardData.type
                break
            end
        end
    end

    --提起新牌，需要判断其他不同花色牌的放下
    local upCardCount = 0
    for i = 1, length do
        cardItem = this.mainPlayer.allHandCardsItems[i]
        if cardItem ~= nil and cardItem ~= clickCardItem and cardItem:IsUp() then
            --Log(cardItem.cardData.key)
            if isSameColorCard then
                upCardCount = upCardCount + 1
            else
                --Log(">> MahjongPlayCardMgr.CheckChangeCardsUpItems > key = ", cardItem.cardData.key)
                --不是同一花色的，需要下落牌
                cardItem:PlayMoveResetPosition()
                cardItem:UpdateMaskColor()
            end
        end
    end

    --如果提起的牌数大于等于换张数，则降下最早提升的牌
    if upCardCount >= MahjongDataMgr.changeCardTotal then
        for i = 1, 4 do
            cardItem = this.changeCardUpItems[i]
            if cardItem ~= nil and cardItem:IsValid() and cardItem:IsUp() then
                cardItem:PlayMoveResetPosition()
                cardItem:UpdateMaskColor()
                this.changeCardUpItems[i] = nil
                break
            end
        end
    end
end

--检测换牌的提起的显示项
function MahjongPlayCardMgr.CheckChangeCardsItemByDown(clickCardItem)
    this.CheckChangeCardsUpItems(clickCardItem)

    --提起新按下的牌
    clickCardItem:SetMaskColor(MahjongMaskColorType.Gray)
    clickCardItem:PlayMovePressDownPosition()
    --排序
    local upCardCount = this.SortChangeCardsItem(clickCardItem)
    --检测是否可以发送换牌，设置换牌按钮的状态
    SendEvent(CMD.Game.Mahjong.UpdateChangeCardButton, upCardCount >= MahjongDataMgr.changeCardTotal)
end

--放开牌张时检测换张的牌张
function MahjongPlayCardMgr.CheckChangeCardsItemByUp(clickCardItem)
    local cardItem = nil
    for i = 1, 4 do
        cardItem = this.changeCardUpItems[i]
        if cardItem == clickCardItem then
            return
        end
    end
    this.CheckChangeCardsUpItems(clickCardItem)
    --排序
    local upCardCount = this.SortChangeCardsItem(clickCardItem)
    --检测是否可以发送换牌，设置换牌按钮的状态
    SendEvent(CMD.Game.Mahjong.UpdateChangeCardButton, upCardCount >= MahjongDataMgr.changeCardTotal)
end

--检测换牌的数量
function MahjongPlayCardMgr.CheckChangeCardsNum()
    local length = this.mainPlayer.allHandCardsLength

    if length < 1 then
        return false
    end

    local upCardCount = 0
    local cardItem = nil

    for i = 1, length do
        cardItem = this.mainPlayer.allHandCardsItems[i]
        if cardItem ~= nil and cardItem.cardData ~= nil and cardItem:IsUp() then
            upCardCount = upCardCount + 1
        end
    end

    if upCardCount < MahjongDataMgr.changeCardTotal then
        return false
    end
    return true
end

--发送换牌数据
function MahjongPlayCardMgr.SendChangeCards()
    if MahjongDataMgr.tableState ~= MahjongPlayerTableState.ChangingCard then
        return false
    end

    local length = this.mainPlayer.allHandCardsLength

    if length < 1 then
        return false
    end

    local upCardCount = 0
    local cardItem = nil
    local cardIds = { 0, 0, 0, 0 }

    for i = 1, length do
        cardItem = this.mainPlayer.allHandCardsItems[i]
        if cardItem ~= nil and cardItem.cardData ~= nil and cardItem:IsUp() then
            upCardCount = upCardCount + 1
            cardIds[upCardCount] = cardItem.cardData.id
        end
    end

    if upCardCount < MahjongDataMgr.changeCardTotal then
        Toast.Show("请选择" .. MahjongDataMgr.changeCardTotal .. "张需要换的牌")
        return false
    end
    local data = {
        type = MahjongOperateCode.HUAN_ZHANG,
        from = -1,
        k1 = cardIds[1],
        k2 = cardIds[2],
        k3 = cardIds[3],
        k4 = cardIds[4]
    }
    MahjongCommand.SendOperate(data.type, data.from, data.k1, data.k2, data.k3, data.k4)
    --临时设置，如果失败了，需要还原
    MahjongDataMgr.tableState = MahjongPlayerTableState.ChangedCard
    return
end

--检测判断换牌时，手牌、摸牌的点击状态
function MahjongPlayCardMgr.CheckChangeCardsClickEnabled(cardItem)
    if cardItem == nil or cardItem.cardKey == 0 then
        return
    end
    --首先幺鸡玩法的幺鸡牌不能被换
    if MahjongUtil.IsTingYongCard(cardItem.cardKey) then
        cardItem:SetClickEnabled(false)
    elseif cardItem.cardKey < WanMax then
        if this.wanCardForbidden then
            cardItem:SetClickEnabled(false)
        end
    elseif cardItem.cardKey < TiaoMax then
        if this.tiaoCardForbidden then
            cardItem:SetClickEnabled(false)
        end
    else
        if this.tongCardForbidden then
            cardItem:SetClickEnabled(false)
        end
    end
end

------------------换出牌显示------------------
--
--检测更新主玩家的换张选中
function MahjongPlayCardMgr.UpdateMainPlayerOutCardByChange()
    this.InternalUpdateOutCardByChange(MahjongSeatIndex.Seat1)
end

--检测更新所有玩家的换张选中
function MahjongPlayCardMgr.UpdateAllPlayerOutCardByChange()
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        this.InternalUpdateOutCardByChange(i)
    end
end

--检测更新换牌中选牌的处理，即标记颜色和提起牌
function MahjongPlayCardMgr.InternalUpdateOutCardByChange(seatIndex)
    local playerData = MahjongDataMgr.playerDatas[seatIndex]
    local player = this.players[seatIndex]

    if playerData == nil or player == nil then
        return
    end

    local cards = playerData.changeCardsOut
    playerData.changeCardsOut = nil
    if cards == nil then
        return
    end

    local length = #cards
    if length < 1 then
        return
    end

    local isExistCard = false
    local tempCards = {}
    local cardId = nil
    for i = 1, length do
        cardId = cards[i]
        if cardId > 0 then
            isExistCard = true
            tempCards[cardId] = cardId
        end
    end

    if isExistCard == false then
        return
    end

    local length = player.allHandCardsLength
    local cardItem = nil
    if seatIndex == MahjongSeatIndex.Seat1 then
        for i = 1, length do
            cardItem = player.allHandCardsItems[i]
            if cardItem ~= nil then
                if cardItem.cardData ~= nil and tempCards[cardItem.cardData.id] ~= nil then
                    cardItem:SetUpPosition()
                    cardItem:SetMaskColor(MahjongMaskColorType.Gray)
                else
                    --如果不是选中的牌，则重置下牌，解决选中牌后，自动托管
                    cardItem:PlayMoveReset()
                    cardItem:UpdateMaskColor()
                end
            end
        end
    else
        for i = 1, length do
            cardItem = player.huCardsItems[i]
            if cardItem ~= nil and cardItem.cardData ~= nil and tempCards[cardItem.cardData.id] ~= nil then
                cardItem:SetMaskColor(MahjongMaskColorType.Gray)
            end
        end
    end
end

------------------换回牌显示------------------
--
--更新主玩家显示换回来的牌
function MahjongPlayCardMgr.UpdateMainPlayerBackCardByChange()
    local maskColorType = MahjongMaskColorType.Gray
    if MahjongDataMgr.isPlayback then
        maskColorType = MahjongMaskColorType.ChangeCard
    end
    this.InternalUpdateBackCardByChange(MahjongSeatIndex.Seat1, maskColorType)
end

--更新所有玩家显示换回来的牌
function MahjongPlayCardMgr.UpdateAllPlayerBackCardByChange()
    local maskColorType = MahjongMaskColorType.Gray
    if MahjongDataMgr.isPlayback then
        maskColorType = MahjongMaskColorType.ChangeCard
    end

    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        this.InternalUpdateBackCardByChange(i, maskColorType)
    end
end

--检测更新换牌后换回来的牌处理，即标记颜色和落下动画，颜色标记下次牌刷新后就没有了
function MahjongPlayCardMgr.InternalUpdateBackCardByChange(seatIndex, maskColorType)
    local playerData = MahjongDataMgr.playerDatas[seatIndex]
    local player = this.players[seatIndex]

    if playerData == nil or player == nil then
        return
    end


    local cards = playerData.changeCardsBack
    playerData.changeCardsBack = nil
    if cards == nil then
        return
    end

    local length = #cards
    if length < 1 then
        return
    end

    local isExistCard = false
    local tempCards = {}
    local cardId = nil
    for i = 1, length do
        cardId = cards[i]
        if cardId > 0 then
            isExistCard = true
            tempCards[cardId] = cardId
        end
    end

    if isExistCard == false then
        return
    end

    local length = player.allHandCardsLength
    local cardItem = nil
    if seatIndex == MahjongSeatIndex.Seat1 then
        for i = 1, length do
            cardItem = player.allHandCardsItems[i]
            if cardItem ~= nil and cardItem.cardData ~= nil and tempCards[cardItem.cardData.id] ~= nil then
                cardItem:SetMaskColor(maskColorType)
                cardItem:PlayChangeCard()
            end
        end
    else
        for i = 1, length do
            cardItem = player.huCardsItems[i] --非1号玩家使用胡牌项
            if cardItem ~= nil and cardItem.cardData ~= nil and tempCards[cardItem.cardData.id] ~= nil then
                cardItem:SetMaskColor(maskColorType)
            end
        end
    end
end

--================================================================
--
--更新手牌的统计，每次有数据设置都需要更新一次
function MahjongPlayCardMgr.UpdateHandCardsCount()
    this.wanCardNum = 0
    this.tiaoCardNum = 0
    this.tongCardNum = 0
    this.tingYongCardNum = 0

    local playerCardData = this.playerCardDatas[MahjongSeatIndex.Seat1]

    if playerCardData ~= nil then
        this.CountCardNum(playerCardData.rightCard)

        local length = #playerCardData.midCards
        for i = 1, length do
            this.CountCardNum(playerCardData.midCards[i])
        end
    end

    this.wanCardForbidden = this.wanCardNum < MahjongDataMgr.changeCardTotal
    this.tiaoCardForbidden = this.tiaoCardNum < MahjongDataMgr.changeCardTotal
    this.tongCardForbidden = this.tongCardNum < MahjongDataMgr.changeCardTotal
end

--统计牌的数量
function MahjongPlayCardMgr.CountCardNum(cardData)
    if cardData == nil then
        return
    end
    if MahjongUtil.IsTingYongCard(cardData.key) then
        this.tingYongCardNum = this.tingYongCardNum + 1
    elseif cardData.type == MahjongColorType.Wan then
        this.wanCardNum = this.wanCardNum + 1
    elseif cardData.type == MahjongColorType.Tiao then
        this.tiaoCardNum = this.tiaoCardNum + 1
    else
        this.tongCardNum = this.tongCardNum + 1
    end
end

---------------------------------------------------------------------------
--
------------------定缺处理------------------
--
--更新主玩家定缺
function MahjongPlayCardMgr.UpdateMainPlayerDingQueCards()
    local playerData = MahjongDataMgr.playerDatas[1]
    local dingQueCardType = 0
    if playerData ~= nil then
        dingQueCardType = playerData.dingQue
    end
    this.UpdateDingQueCards(1, this.mainPlayer, dingQueCardType)
end

--更新所有玩家定缺
function MahjongPlayCardMgr.UpdateAllPlayerDingQueCards()
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        local playerData = MahjongDataMgr.playerDatas[i]
        if playerData ~= nil then
            this.UpdateDingQueCards(i, this.players[i], playerData.dingQue)
        end
    end
end

--处理定缺，如果还有定缺的未出牌，屏蔽非定缺牌
function MahjongPlayCardMgr.UpdateDingQueCards(index, player, dingQueCardType)
    if player == nil or dingQueCardType < MahjongColorType.Wan then
        --由于现在的所有麻将都需要定缺，固没定缺之前，设置该数量，防止未定缺前检测听牌提示
        this.dingQueCardNum = MahjongDataMgr.cardTotal
        return
    end

    local dataLength = player.allHandCardsLength
    local items = nil
    --1号玩家为主玩家，使用手牌，其他玩家使用胡牌，即明牌显示
    if index == 1 then
        items = player.allHandCardsItems
    else
        items = player.huCardsItems
    end
    local itemLength = #items

    --数据不一致，不处理
    if itemLength < dataLength then
        return
    end

    local cardItem = nil
    this.dingQueCardNum = 0
    for i = 1, dataLength do
        cardItem = items[i]
        if cardItem ~= nil and cardItem.cardData ~= nil then
            if not MahjongUtil.IsTingYongCard(cardItem.cardData.key) then
                if dingQueCardType == cardItem.cardData.type then
                    this.dingQueCardNum = this.dingQueCardNum + 1
                    cardItem.isDingQueCard = true
                else
                    cardItem.isDingQueCard = false
                end
            else
                cardItem.isDingQueCard = false
            end
        else
            LogWarn(">> MahjongPlayCardMgr.UpdateDingQueCards > i = ", i)
        end
    end

    if this.dingQueCardNum > 0 then --有定缺，屏蔽非定缺
        for i = 1, dataLength do
            cardItem = items[i]
            if cardItem ~= nil then
                --定缺的牌可以打
                cardItem:SetClickEnabled(cardItem.isDingQueCard == true)
                --可以打的牌设置灰色
                cardItem:UpdateMaskColor()
            end
        end
    else
        for i = 1, dataLength do
            cardItem = items[i]
            if cardItem ~= nil then
                cardItem:SetClickEnabled(true)
                cardItem:UpdateMaskColor()
            end
        end
    end
end

--处理明牌张数，用于统计出某种牌还剩余多少
function MahjongPlayCardMgr.HandleMingCardNum()
    --先清除重置数据
    for k, v in pairs(this.mingCardNumDict) do
        v.num = 0
    end
    local playerCardData = nil
    local length = #this.playerCardDatas
    local tempCards = nil
    local tempCard = nil
    local tempCardData = MahjongCardData.New()
    for i = 1, length do
        playerCardData = this.playerCardDatas[i]
        if playerCardData.isActive then
            --先处理左边牌
            tempCards = playerCardData.leftCards
            for j = 1, #tempCards do
                tempCard = tempCards[j]
                this.HandleMingCardNumById(tempCardData, tempCard.k1)
                this.HandleMingCardNumById(tempCardData, tempCard.k2)
                this.HandleMingCardNumById(tempCardData, tempCard.k3)
                this.HandleMingCardNumById(tempCardData, tempCard.k4)
            end

            --处理打出去的牌
            tempCards = playerCardData.pushCards
            for j = 1, #tempCards do
                this.HandleMingCardNumByCardData(tempCards[j])
            end

            --处理中间手牌
            tempCards = playerCardData.midCards
            for j = 1, #tempCards do
                this.HandleMingCardNumByCardData(tempCards[j])
            end

            --处理右手牌
            if playerCardData.rightCard ~= nil then
                this.HandleMingCardNumByCardData(playerCardData.rightCard)
            end
        end
    end
end

--处理明牌张数
function MahjongPlayCardMgr.HandleMingCardNumById(cardData, id)
    if id ~= nil and id > 0 then
        cardData:SetId(id)
        this.HandleMingCardNumByCardData(cardData)
    end
end

--处理明牌张数
function MahjongPlayCardMgr.HandleMingCardNumByCardData(cardData)
    this.mingCardNumObj = this.mingCardNumDict[cardData.key]
    if this.mingCardNumObj == nil then
        this.mingCardNumObj = { num = 0 }
        this.mingCardNumDict[cardData.key] = this.mingCardNumObj
    end
    this.mingCardNumObj.num = this.mingCardNumObj.num + 1
end

---------------------------------------------------------------------------
--
--检测清除打出牌被选中的显示项，出牌后会调用该方法，清除选中数据
function MahjongPlayCardMgr.CheckClearOutCardsSelected()
    this.ClearSelectedCard()
end

--设置打出去的牌的选中状态
function MahjongPlayCardMgr.SetSelectedCard(cardKey)
    local player = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        player = this.players[i]
        if player ~= nil then
            player.outCard:SetSelectedCard(cardKey)
            player:SetSelectedOperateCard(cardKey)
            if i > 1 then
                player:SetSelectedHuCard(cardKey)
            end
        end
    end
end

--清除打出去的牌的选中状态
function MahjongPlayCardMgr.ClearSelectedCard()
    local player = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        player = this.players[i]
        if player ~= nil then
            player.outCard:ClearSelectedCard()
            player:ClearSelectedOperateCard()
            if i > 1 then
                player:ClearSelectedHuCard()
            end
        end
    end
end

--================================================================
--
--更新胡牌提示箭头
function MahjongPlayCardMgr.UpdateHuTips()
    --胡牌后，不显示提示箭头
    if MahjongDataMgr.IsTingTips() and this.mainPlayer.isHu == false then
        if MahjongDataMgr.HuTips.tipsData ~= nil then
            this.ShowHuTipsArrow()
        else
            this.HideHuTipsArrow()
        end
    else
        this.HideHuTipsArrow()
    end
end

--显示打牌提示的箭头
function MahjongPlayCardMgr.ShowHuTipsArrow()
    --LogError(">> ====================== Mahjong > MahjongPlayCardMgr > ShowHuTipsArrow. ====================== ")
    this.isHuTipsArrowDisplay = true

    local length = this.mainPlayer.allHandCardsLength
    local itemsLength = #this.huTipsArrowItems
    local cardItem = nil
    local huTipsArrowItem = nil
    local index = 1
    for i = 1, length do
        cardItem = this.mainPlayer.allHandCardsItems[i]
        --表示可以提示
        if cardItem ~= nil and MahjongDataMgr.HuTips.tipsData[cardItem.cardKey] ~= nil then
            if index <= itemsLength then --获取当前的对象设置
                huTipsArrowItem = this.huTipsArrowItems[index]
            else
                huTipsArrowItem = this.CreateHuTipsArrowItem(index)
            end
            index = index + 1
            huTipsArrowItem:SetPosition(cardItem.x, cardItem.y)
            huTipsArrowItem:Show()
        end
    end

    --隐藏多余的显示项
    if index < itemsLength then
        for i = index, itemsLength do
            huTipsArrowItem = this.huTipsArrowItems[i]
            huTipsArrowItem:Clear()
        end
    end

    this.PlayHuTipsArrowTween()
end

--创建提示箭头
function MahjongPlayCardMgr.CreateHuTipsArrowItem(index)
    local obj = CreateGO(this.mainPlayer.playCardArrowItemPrefab, this.mainPlayer.playCardArrowContentNode,
        "Arrow" .. index)
    local huTipsArrowItem = MahjongPlayCardArrowItem.New()
    huTipsArrowItem:Init(obj)
    table.insert(this.huTipsArrowItems, huTipsArrowItem)
    return huTipsArrowItem
end

--隐藏打牌提示的箭头
function MahjongPlayCardMgr.HideHuTipsArrow()
    --如果已经是隐藏了的，就不再处理
    if this.isHuTipsArrowDisplay == false then
        return
    end
    this.isHuTipsArrowDisplay = false

    local length = #this.huTipsArrowItems
    local item = nil
    for i = 1, length do
        item = this.huTipsArrowItems[i]
        item:Hide()
    end
    --停止Tween动画
    this.StopHuTipsArrowTween()
end

--播放打牌提示箭头动画，重新播放
function MahjongPlayCardMgr.PlayHuTipsArrowTween()
    if this.mainPlayer == nil or this.mainPlayer.playCardArrowTweener == nil then
        return
    end
    --player.playCardArrowTweener:ResetToBeginning()
    this.mainPlayer.playCardArrowTweener:PlayForward()
end

function MahjongPlayCardMgr.StopHuTipsArrowTween()
    if this.mainPlayer == nil or this.mainPlayer.playCardArrowTweener == nil then
        return
    end
    this.mainPlayer.playCardArrowTweener.enabled = false
end

--================================================================
--
--应用切出去了
function MahjongPlayCardMgr.ApplicationPause(pauseStatus)
    if pauseStatus == false then
        return
    end
    this.ResetDownCardItem()
end

--================================================================
--
--播放出牌语音音效
function MahjongPlayCardMgr.PlayCardSound(playerId, cardKey)
    --语言
    local language = nil
    local gender = MahjongDataMgr.GetPlayerGender(playerId)
    MahjongAudioMgr.PlayCard()
    --播放出牌语音
    MahjongAudioMgr.PlayCardSound(gender, cardKey, language)
end
