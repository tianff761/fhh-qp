MahjongUtil = {}

--获取玩法规则
function MahjongUtil.GetPlayWayRule(rules, type, default)
    local result = rules[type]
    if result == nil then
        return default
    end
    return result
end

--检测是否是幺鸡玩法
function MahjongUtil.CheckYaoJiPlayWayType(playWayType)
    if playWayType == Mahjong.PlayWayType.YaoJiErRen or playWayType == Mahjong.PlayWayType.YaoJiSanRen or playWayType == Mahjong.PlayWayType.YaoJiSiRen then
        return true
    else
        return false
    end
end

--排序方法
function MahjongUtil.CardDataSort(cardData1, cardData2)
    return cardData1.sort < cardData2.sort
end

--通过远程座位号计算出当前位置索引号
function MahjongUtil.GetIndexBySeatNumber(seatNumber)
    if seatNumber == nil or seatNumber == "" then
        Log(">> MahjongUtil.GetIndexBySeatNumber > seatNumber == nil")
        return -1
    end

    local userSeatNumber = MahjongDataMgr.userSeatNumber
    local playerNum = MahjongDataMgr.playerTotal

    local index = (seatNumber + playerNum - userSeatNumber) % playerNum + 1
    if index == 3 and playerNum == 3 then --三家人，第三位在第4号坐
        index = 4
    end
    if index == 2 and playerNum == 2 then --两家人，对方在对面坐
        index = 3
    end

    return index
end

--============================================= 旧版本资源，已弃用
-- --获取麻将牌资源的名称
-- function MahjongUtil.GetCardName(type, seatIndex, cardKey)
--     local result = ""
--     if type == MahjongCardDisplayType.Hand then--手牌、摸的牌
--         if seatIndex == MahjongSeatIndex.Seat1 then--玩家自己的牌、要进行幺鸡判断
--             result = "hp_" .. seatIndex .. "_" .. cardKey
--         else
--             result = "p_" .. seatIndex .. "_-1"
--         end
--     elseif type == MahjongCardDisplayType.Cover then--盖的牌，不进行幺鸡判断
--         result = "p_" .. seatIndex .. "_0"
--     elseif type == MahjongCardDisplayType.Display then--打出牌，也进行一下幺鸡的判断
--         result = "p_" .. seatIndex .. "_" .. cardKey
--     elseif type == MahjongCardDisplayType.Operate then--碰杠吃的牌，要进行幺鸡判断
--         if seatIndex == MahjongSeatIndex.Seat1 then
--             result = "op_" .. seatIndex .. "_" .. cardKey
--         else
--             result = "p_" .. seatIndex .. "_" .. cardKey
--         end
--     end
--     return result
-- end

--获取麻将牌底框资源的名称
function MahjongUtil.GetCardFrameName(type, seatIndex, row, index, layIndex)
    local result = ""
    local column_idx = index
    if type == MahjongCardDisplayType.Hand then--手牌、摸的牌
        if seatIndex == MahjongSeatIndex.Seat1 then--玩家自己的牌，固定资源
            result = "face_1_bottom_stand"
        elseif seatIndex == MahjongSeatIndex.Seat2 then --2号位玩家手牌底框用的是4号位玩家手牌底框资源镜像翻转
            if index == 14 then
                column_idx = 1 
            else
                column_idx = index + 1  
            end
            result = "face_1_left_stand_"..column_idx
        elseif seatIndex == MahjongSeatIndex.Seat4  then
            if index < 14 then
                column_idx = 14 - index
            end
            result = "face_1_left_stand_"..column_idx
        elseif seatIndex == MahjongSeatIndex.Seat3 then --1号位和3号位玩家手牌1-7序号和9-15序号底框资源为镜像翻转
            
            if index < 7 then
                column_idx = index + 2
            else
                if index == 14 then
                    column_idx = 2
                else
                    column_idx = 14 - index
                end
            end
            result = "face_1_top_stand_"..column_idx
        end

    elseif type == MahjongCardDisplayType.Cover then--盖的牌，不进行幺鸡判断，杠牌和胡牌都是盖牌

        --1,3,4号位玩家碰杠吃的牌 预制体顺序为 1324 ， 2号位玩家碰杠吃的牌 预制体顺序为 2314
        if seatIndex == MahjongSeatIndex.Seat1 then
            --layIndex 为nil时，为胡牌
            if layIndex == nil then
                layIndex = index
            else
                if layIndex == 2 then
                    layIndex = 3
                elseif layIndex == 3 or layIndex == 4 then
                    layIndex = 2
                end
                layIndex = (index - 1) * 3 + layIndex
                if layIndex > 9 then
                    layIndex = 19 - layIndex
                end
                result = "face_1_bottom_cover_".. layIndex
            end
           
        elseif seatIndex == MahjongSeatIndex.Seat2 then
            
            if layIndex == nil then
                layIndex = index + 1
            else
                if layIndex == 1 then
                    layIndex = 3
                elseif layIndex == 2 then
                    layIndex = 1
                elseif layIndex == 3 or layIndex == 4 then
                    layIndex = 2
                end
                layIndex = (4 - index) * 3 + layIndex
            end
            result = "face_1_left_cover_".. layIndex

        elseif seatIndex == MahjongSeatIndex.Seat3 then

            if layIndex == nil then
                if index <=5 then
                    layIndex = index + 3
                else
                    layIndex = 14 - index
                end
            else
                if layIndex == 2 then
                    layIndex = 3
                elseif layIndex == 3 or layIndex == 4 then
                    layIndex = 2
                end
                layIndex = (index - 1) * 3 + layIndex
                layIndex = layIndex > 8 and 16 - layIndex or layIndex
            end
            result = "face_1_top_cover_".. layIndex

        elseif seatIndex == MahjongSeatIndex.Seat4 then
            
            if layIndex == nil then
                layIndex = 14 - index
            else
                if layIndex == 2 then
                    layIndex = 3
                elseif layIndex == 3 or layIndex == 4 then
                    layIndex = 2
                end
                layIndex = (index - 1) * 3 + layIndex
            end
            result = "face_1_left_cover_".. layIndex
        end

    elseif type == MahjongCardDisplayType.Display then--打出的牌

        row = row > 2 and 2 or row
        if seatIndex == MahjongSeatIndex.Seat1 or seatIndex == MahjongSeatIndex.Seat3 then --1号位和3号位玩家出牌1-4序号和6-9序号底框资源为镜像翻转
            --1号位，3号位出牌父节点修改了大小，按照第一行出牌资源原比例进行缩放
            row = 1
            --二人麻将单行11张牌
            if MahjongDataMgr.playerTotal == 2 then
                if index <= 6 then
                    column_idx = index == 1 and 1 or index - 1
                else
                    column_idx = index == 11 and 1 or 11 - index
                end
            else
                if index > 5 then
                    column_idx = 10 - index
                end
            end

            if seatIndex == MahjongSeatIndex.Seat1 then
                result = "face_1_bottom_discard_"..row..column_idx
            else
                result = "face_1_top_discard_"..row..column_idx
            end
        
        elseif seatIndex == MahjongSeatIndex.Seat2 or seatIndex == MahjongSeatIndex.Seat4 then --2号位、4号位出牌底框资源通用
            if seatIndex == MahjongSeatIndex.Seat2 then --2号位出牌底框资源为从大到小，4号位出牌底框资源为从小到大
                column_idx = 10 - index
            end
            result = "face_1_left_discard_"..row..column_idx
        end

    elseif type == MahjongCardDisplayType.Operate then--碰杠吃的牌
        --1,3,4号位玩家碰杠吃的牌 预制体顺序为 1324 ， 2号位玩家碰杠吃的牌 预制体顺序为 2314
        if seatIndex == MahjongSeatIndex.Seat1 then

            if layIndex ~= nil then
                if layIndex == 2 then
                    layIndex = 3
                elseif layIndex == 3 or layIndex == 4 then
                    layIndex = 2
                end
                local layIndex = (index - 1) * 3 + layIndex
                if layIndex > 9 then
                    layIndex = 19 - layIndex
                end
                result = "face_1_bottom_lay_".. layIndex
            end
          
        elseif seatIndex == MahjongSeatIndex.Seat2 then

            if layIndex ~= nil then
                if layIndex == 1 then
                    layIndex = 3
                elseif layIndex == 2 then
                    layIndex = 1
                elseif layIndex == 3 or layIndex == 4 then
                    layIndex = 2
                end
                layIndex = (4 - index) * 3 + layIndex
                result = "face_1_left_lay_".. layIndex
            end
           
        elseif seatIndex == MahjongSeatIndex.Seat3 then

            if layIndex ~= nil then
                if layIndex == 2 then
                    layIndex = 3
                elseif layIndex == 3 or layIndex == 4 then
                    layIndex = 2
                end
                layIndex = (index - 1) * 3 + layIndex
                layIndex = layIndex > 8 and 16 - layIndex or layIndex
                result = "face_1_top_lay_".. layIndex
            end
           
        elseif seatIndex == MahjongSeatIndex.Seat4 then
            
            if layIndex ~= nil then
                if layIndex == 2 then
                    layIndex = 3
                elseif layIndex == 3 or layIndex == 4 then
                    layIndex = 2
                end
                layIndex = (index - 1) * 3 + layIndex
                result = "face_1_left_lay_".. layIndex
            end
        end

    elseif type == MahjongCardDisplayType.Hu_Hand then--胡牌_手牌明牌，回放时显示

        if seatIndex == MahjongSeatIndex.Seat1 then
            result = "face_1_bottom_lay_8"
        elseif seatIndex == MahjongSeatIndex.Seat2 then
            index = index >= 13 and 12 or index
            result = "face_1_right_hu_"..index
        elseif seatIndex == MahjongSeatIndex.Seat3 then --美术胡牌资源只出12张，还和盖牌大小不一样，有毒吧
            index = index >= 13 and 12 or index
            result = "face_1_top_hu_"..index
        elseif seatIndex == MahjongSeatIndex.Seat4 then --美术胡牌资源只出12张，还和盖牌大小不一样，有毒吧
            local _idx = 14 - index
            _idx = _idx >= 13 and 12 or _idx
            result = "face_1_right_hu_".._idx
        end
        
    elseif type == MahjongCardDisplayType.Hu_Operation then--胡牌_操作牌
        if seatIndex == MahjongSeatIndex.Seat1 then
            result = "face_1_bottom_lay_8"
        elseif seatIndex == MahjongSeatIndex.Seat2 then
            result = "face_1_right_hu_1"
        elseif seatIndex == MahjongSeatIndex.Seat3 then
            result = "face_1_top_hu_1"
        elseif seatIndex == MahjongSeatIndex.Seat4 then --美术胡牌资源只出12张，还和盖牌大小不一样，有毒吧
            result = "face_1_right_hu_12"
        end
    
    end
    return result
end


--是否是听用牌
function MahjongUtil.IsTingYongCard(cardKey)
    if MahjongDataMgr.isYaoJiPlayWay and MahjongDataMgr.tingYongCardDict[cardKey] == true then
        return true
    else
        return false
    end
end

--设置牌的遮罩颜色
function MahjongUtil.SetMaskColor(image, maskColorType)
    if maskColorType == MahjongMaskColorType.None then
        UIUtil.SetImageColor(image, 1, 1, 1)
    elseif maskColorType == MahjongMaskColorType.Gray then
        -- UIUtil.SetImageColor(image, 0.392, 0.392, 0.392)
        UIUtil.SetImageColor(image, 0.66, 0.66, 0.66)
    elseif maskColorType == MahjongMaskColorType.ChangeCard then
        UIUtil.SetImageColor(image, 1, 0.706, 0.706)
    elseif maskColorType == MahjongMaskColorType.Selected then
        UIUtil.SetImageColor(image, 1, 0.549, 0.549)
    elseif maskColorType == MahjongMaskColorType.TingYong then
        UIUtil.SetImageColor(image, 1, 0.274, 1)
    else
        UIUtil.SetImageColor(image, 1, 1, 1)
    end
end

--获取麻将牌显示牌资源的名称
function MahjongUtil.GetDisplayCardName(index, cardKey)
    return "p_" .. index .. "_" .. cardKey
end

--检测结果分数
function MahjongUtil.CheckResultScore(score)
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
function MahjongUtil.CheckGoldScore(score)
    return CutNumber(score)
end

--检测定缺
function MahjongUtil.CheckDingQueType(value)
    --2房固定定缺
    if MahjongDataMgr.fangTotal == 2 then
        return MahjongColorType.Wan
    end
    if value == MahjongColorType.Tiao or value == MahjongColorType.Tong or value == MahjongColorType.Wan then
        return value
    else
        return 0
    end
end

--操作数据是否相同
function MahjongUtil.EqualsOperationData(data1, data2)
    if data1 == nil or data2 == nil then
        return false
    end

    if data1.type ~= data2.type then
        return false
    end
    --定缺不需要深度判断
    if data1.type == MahjongOperateCode.DING_QUE then
        return true
    end

    if data1.from ~= data2.from then
        return false
    end

    if data1.k1 ~= data2.k1 then
        return false
    end

    if data1.k2 ~= data2.k2 then
        return false
    end

    if data1.k3 ~= data2.k3 then
        return false
    end

    if data1.k4 ~= data2.k4 then
        return false
    end

    return true
end

--检测托管
function MahjongUtil.CheckTrust(trust)
    if trust == nil then
        return 0
    else
        return trust
    end
end

--获取Gps界面数据
function MahjongUtil.GetGpsPanelData(countDown, readyCallback, quitCallback)

    local isRoomBegin = false
    --分数场处理
    if MahjongDataMgr.IsGoldRoom() then
        isRoomBegin = MahjongDataMgr.IsGameBegin()
    else
        isRoomBegin = MahjongDataMgr.IsRoomBegin()
    end

    local data = {
        gameType = GameType.Mahjong,
        roomType = MahjongDataMgr.roomType,
        moneyType = MahjongDataMgr.moneyType,
        isRoomBegin = isRoomBegin, --房间是否开始，即第一局开始后，后面的处理退出都需要解散
        isRoomOwner = MahjongDataMgr.IsRoomOwner(), --房间拥有者，玩家自己是否是房主
        playerMaxTotal = MahjongDataMgr.playerTotal, --玩家最大总人数
        readyCallback = readyCallback, --准备点击回调
        quitCallback = quitCallback, --退出解散回调
        countDown = countDown, --准备倒计时，如果是非准备阶段，该值为nil，是否是GPS查看也通过该方法
        players = MahjongUtil.GetGpsPanelPlayerData(),
    }

    return data
end

--获取Gps界面玩家数据
function MahjongUtil.GetGpsPanelPlayerData()
    local players = {}
    local tempData = nil
    local playerData = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
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
            if playerData.seatIndex >= MahjongDataMgr.playerTotal then
                players[MahjongDataMgr.playerTotal] = tempData
            else
                players[playerData.seatIndex] = tempData
            end
        end
    end
    return players
end

--处理时间戳，单位秒
function MahjongUtil.GetDateByTimeStamp(timeStamp)
    return os.date("%Y-%m-%d %H:%M:%S", timeStamp)
end

--检测是否在数组Table中
function MahjongUtil.CheckInTable(v, t)
    for i = 1, #t do
        if v == t[i] then
            return true
        end
    end
    return false
end

--获取当前桌布的ID，字符串
function MahjongUtil.GetTableclothId()
    local id = DataPool.GetLocal("MahjongTablecloth")
    if id == nil then
        id = "1"
    end
    return id
end

--设置当前桌布的ID，字符串
function MahjongUtil.SetTableclothId(id)
    DataPool.SetLocal("MahjongTablecloth", id)
end

--获取当前听牌选项
function MahjongUtil.GetTingPaiTiShi()
    return GetLocal("MajongTingPai", "1") == "1"
end

--设置当前听牌选项
function MahjongUtil.SetTingPaiTiShi(isOpen)
    if isOpen then
        SetLocal("MajongTingPai", "1")
    else
        SetLocal("MajongTingPai", "0")
    end
end
