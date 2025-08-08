TpUtil = {}

--获取玩法规则
function TpUtil.GetPlayWayRule(rules, type, default)
    local result = rules[type]
    if result == nil then
        return default
    end
    return result
end

--排序方法
function TpUtil.CardDataSort(cardData1, cardData2)
    return cardData1.sort < cardData2.sort
end

--通过客户端索引计算出服务器座位号
function TpUtil.GetServerIndexByLocalIndex(index)
    local serverIndex = 0
    if TpDataMgr.userSeatNumber > 0 then
        serverIndex = (TpDataMgr.userSeatNumber + (index - 1) + TpDataMgr.playerTotal - 1) % TpDataMgr.playerTotal + 1
    else
        serverIndex = index
    end
    return serverIndex
end

--通过服务器座位号计算出客户端索引号
function TpUtil.GetLocalIndexByServerIndex(index)
    local localIndex = 0
    if TpDataMgr.userSeatNumber > 0 then
        localIndex = (index - TpDataMgr.userSeatNumber + TpDataMgr.playerTotal) % TpDataMgr.playerTotal + 1
    else
        localIndex = index
    end
    return localIndex
end

--检测结果分数
function TpUtil.CheckResultScore(score)
    local temp = math.abs(score)
    if score < 0 then
        return "-" .. temp
    elseif score == 0 then
        return tostring(temp)
    else
        return "+" .. temp
    end
end

--检测分数分数，如果超过指定数值单位转换
function TpUtil.CheckGoldScore(score)
    return CutNumber(score)
end


--获取Gps界面数据
function TpUtil.GetGpsPanelData(countDown, readyCallback, quitCallback)

    local isRoomBegin = false
    --分数场处理
    if TpDataMgr.IsGoldRoom() then
        isRoomBegin = TpDataMgr.IsGameBegin()
    else
        isRoomBegin = TpDataMgr.IsRoomBegin()
    end

    local data = {
        gameType = GameType.Tp,
        roomType = TpDataMgr.roomType,
        moneyType = TpDataMgr.moneyType,
        isRoomBegin = isRoomBegin, --房间是否开始，即第一局开始后，后面的处理退出都需要解散
        isRoomOwner = TpDataMgr.IsRoomOwner(), --房间拥有者，玩家自己是否是房主
        playerMaxTotal = TpDataMgr.playerTotal, --玩家最大总人数
        readyCallback = readyCallback, --准备点击回调
        quitCallback = quitCallback, --退出解散回调
        countDown = countDown, --准备倒计时，如果是非准备阶段，该值为nil，是否是GPS查看也通过该方法
        players = TpUtil.GetGpsPanelPlayerData(),
    }

    return data
end

--获取Gps界面玩家数据
function TpUtil.GetGpsPanelPlayerData()
    local players = {}
    local tempData = nil
    local playerData = nil
    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        if playerData ~= nil and playerData.id ~= nil then
            tempData = {
                id = playerData.id,
                name = playerData.name,
                headUrl = playerData.headUrl,
                headFrame = playerData.headFrame,
                ready = playerData.ready, --准备标识，0未准备、1准备
                gps = GPSModule.GetGpsDataByPlayerId(playerData.id)
            }

            --处理座位号，2人是1和3所有要把3处理成2;3人是1、2和4所有需要把4处理成3
            if playerData.seatIndex >= TpDataMgr.playerTotal then
                players[TpDataMgr.playerTotal] = tempData
            else
                players[playerData.seatIndex] = tempData
            end
        end
    end
    return players
end

--处理时间戳，单位秒
function TpUtil.GetDateByTimeStamp(timeStamp)
    return os.date("%Y-%m-%d %H:%M:%S", timeStamp)
end

--获取月天时分，单位秒
function TpUtil.GetMdhmByTimeStamp(timeStamp)
    return os.date("%m-%d %H:%M", timeStamp)
end

--获取年月天，单位秒
function TpUtil.GetYmdByTimeStamp(timeStamp)
    return os.date("%Y-%m-%d", timeStamp)
end

--检测是否在数组Table中
function TpUtil.CheckInTable(v, t)
    for i = 1, #t do
        if v == t[i] then
            return true
        end
    end
    return false
end

--获取当前桌布的ID，字符串
function TpUtil.GetTableclothId()
    local id = DataPool.GetLocal("TpTablecloth")
    if id == nil then
        id = "1"
    end
    return id
end

--设置当前桌布的ID，字符串
function TpUtil.SetTableclothId(id)
    DataPool.SetLocal("TpTablecloth", id)
end

--显示错误提示
function TpUtil.ShowErrorTips(code, type)
    local tips = TpErrorTips[code]
    if tips == nil then
        tips = "错误：" .. code
    end
    if type == 1 then
        Alert.Show(tips)
    else
        Toast.Show(tips)
    end
end

--获取时间格式 XX:XX:XX
function TpUtil.GetColonTime(time)
    local h = math.floor(time / 3600)
    local m = math.fmod(math.modf(time / 60), 60)
    local s = math.fmod(math.modf(time), 60)
	if h < 10 then
		h = "0" .. h
	end
	if m < 10 then
		m = "0" .. m
	end
	if s < 10 then
		s = "0" .. s
	end
    return GetS("%s:%s:%s", h, m, s)
end