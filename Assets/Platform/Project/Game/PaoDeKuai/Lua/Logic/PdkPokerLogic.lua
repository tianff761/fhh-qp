PdkPokerLogic = {}
local this = PdkPokerLogic
PdkPokerLogic.curPokerType = nil

-- 是否是跑得快花色类型
function PdkPokerLogic.IsPdkColorType(color)
    if IsNumber(color) then
        for _, colorType in pairs(PdkPoker.PdkPokerColors) do
            if colorType == color then
                return true
            end
        end
    end
    return false
end

-- 是否是跑得快牌点数类型PdkCardDefine.PointType
function PdkPokerLogic.IsPdkPointType(point)
    if IsNumber(point) then
        for _, pointType in pairs(PdkPoker.PointType) do
            if pointType == point then
                return true
            end
        end
    end
    return false
end

-- 是否是跑得快牌型
function PdkPokerLogic.IsPdkPokerType(type)
    if IsNumber(type) then
        for _, pokerType in pairs(PdkPokerType) do
            if pokerType == type then
                return true
            end
        end
    end
    return false
end

-- 获取ID值的点数
function PdkPokerLogic.GetIdPoint(id)
    if IsNumber(id) then
        local p = math.floor(id / 10)
        if PdkPokerLogic.IsPdkPointType(p) then
            return p
        end
    end
    LogError("Point计算错误", id)
    return 0
end

-- 获取ID值的花色
function PdkPokerLogic.GetIdColorType(id)
    if IsNumber(id) then
        local color = math.floor(id % 10)
        if PdkPokerLogic.IsPdkColorType(color) then
            return color
        end
    end
    LogError("花色计算错误", id)
    return nil
end

-- 获取ID值的权值
function PdkPokerLogic.GetIdWeight(id)
    if IsNumber(id) then
        local p = math.floor(id / 10)
        if PdkPokerLogic.IsPdkPointType(p) then
            if p == PdkPoker.PointType.CardWang then
                if PdkPokerLogic.GetIdColorType(id) == PdkPoker.PdkPokerColors.Small then
                    return PdkPoker.PdkPokerWeight.SJoker
                else
                    return PdkPoker.PdkPokerWeight.BJoker
                end
            elseif p == PdkPoker.PointType.Card2 then
                return PdkPoker.PdkPokerWeight.Two
            elseif p == PdkPoker.PointType.CardA then
                return PdkPoker.PdkPokerWeight.One
            else
                return p
            end
        end
    end
    LogError("Weight计算错误", id)
    return 0
end

-- 获取排序字段
function PdkPokerLogic.GetRankId(id)
    if IsNumber(id) then
        local point = PdkPokerLogic.GetIdPoint(id)
        -- 王的排序，排在听用右边
        if point == PdkPoker.PointType.CardWang then
            -- 2的排序，排在王右边
            return id * 10000
        elseif point == PdkPoker.PointType.Card2 then
            -- A的排序，排在2右边
            return id * 1000
        elseif point == PdkPoker.PointType.CardA then
            -- 普通牌，按实际大小值比较排序
            return id * 100
        else
            return id
        end
    else
        return 0
    end
end

--对牌的ID进行升序排列  从小到大
function PdkPokerLogic.SortIdsShengXu(ids)
    if GetTableSize(ids) > 0 then
        table.sort(
                ids,
                function(id1, id2)
                    id1 = this.GetRankId(id1)
                    id2 = this.GetRankId(id2)
                    return id1 < id2
                end
        )
    end
end

--对牌的ID进行降序排列  从大到小
function PdkPokerLogic.SortIdsJiangXu(ids)
    if GetTableSize(ids) > 0 then
        table.sort(
                ids,
                function(id1, id2)
                    id1 = this.GetRankId(id1)
                    id2 = this.GetRankId(id2)
                    return id1 > id2
                end
        )
    end
end
---------------------------------------------------牌型判断--------------------
--判断是否是单牌
function PdkPokerLogic.IsSingle(pokers)
    return #pokers == 1
end

--判断是否是对子
function PdkPokerLogic.IsDouble(pokers)
    if #pokers == 2 then
        if PdkPokerLogic.GetIdWeight(pokers[1]) == PdkPokerLogic.GetIdWeight(pokers[2]) then
            return true
        end
    end
    return false
end

--判断是否是顺子
function PdkPokerLogic.IsStraight(pokers)
    --乐山跑得快 三张为顺子  最大5-K
    local min = 3
    local max = 10
    if PdkRoomModule.IsSCGame() or PdkRoomModule.IsLSGame() then
        min = 3
        max = 10
    elseif PdkRoomModule.IsSixteenPDKOrFifteenPDK() then
        min = 5
        max = 15
    end
    if #pokers < min or #pokers > max then
        return false
    end
    local tempWeight = nil
    for i = 2, #pokers do
        tempWeight = PdkPokerLogic.GetIdWeight(pokers[i])
        if tempWeight - PdkPokerLogic.GetIdWeight(pokers[i - 1]) ~= 1 then
            return false
        end
        if tempWeight > PdkPoker.PdkPokerWeight.One then
            return false
        end
    end
    return true
end

--判断是否是连对
function PdkPokerLogic.IsDoubleStraight(pokers)
    local min = 20
    if PdkRoomModule.IsSCGame() and PdkRoomModule.GetRule(PdkRuleType.PX) > 0 then
        min = 4
    elseif PdkRoomModule.IsLSGame() then
        min = 6
    elseif PdkRoomModule.IsSixteenPDKOrFifteenPDK() then
        min = 4
    end
    if #pokers < min or #pokers % 2 ~= 0 then
        return false
    end
    local tempWeight = nil
    for i = 2, #pokers, 2 do
        tempWeight = PdkPokerLogic.GetIdWeight(pokers[i])
        if PdkPokerLogic.GetIdWeight(pokers[i - 1]) ~= tempWeight then
            return false
        end
        if pokers[i - 2] ~= nil then
            if tempWeight - PdkPokerLogic.GetIdWeight(pokers[i - 2]) ~= 1 then
                return false
            end
        end
        -- if tempWeight > PdkPoker.PdkPokerWeight.One or PdkPokerLogic.GetIdWeight(pokers[i - 2]) > PdkPoker.PdkPokerWeight.One then
        --     return false
        -- end
    end
    return true
end

--判断是否是飞机不带
function PdkPokerLogic.IsAirplane(pokers)
    local min = 20
    if PdkRoomModule.IsSCGame() and PdkRoomModule.GetRule(PdkRuleType.FJ) > 0 then
        min = 6
    elseif PdkRoomModule.IsLSGame() then
        min = 6
    elseif PdkRoomModule.IsSixteenPDKOrFifteenPDK() then
        min = 6
    end
    if #pokers < min or #pokers % 3 ~= 0 then
        return false
    end
    local tempWeight = nil
    for i = 3, #pokers, 3 do
        tempWeight = PdkPokerLogic.GetIdWeight(pokers[i])
        if tempWeight ~= PdkPokerLogic.GetIdWeight(pokers[i - 1]) then
            return false
        end
        if PdkPokerLogic.GetIdWeight(pokers[i - 2]) ~= PdkPokerLogic.GetIdWeight(pokers[i - 1]) then
            return false
        end
        if tempWeight ~= PdkPokerLogic.GetIdWeight(pokers[i - 2]) then
            return false
        end
        -- if tempWeight > PdkPoker.PdkPokerWeight.One or pokers[i - 3].weight > PdkPoker.PdkPokerWeight.One then
        --     return false
        -- end
        if tempWeight > PdkPoker.PdkPokerWeight.One then
            return false
        end
    end
    return true
end

function PdkPokerLogic.JudgeAirPlaneBody(pokers)
    local pokerPoints = {}
    for i = 1, #pokers do
        pokerPoints[i] = this.GetIdWeight(pokers[i])
    end
    table.sort(pokerPoints, function(a, b)
        return a > b;
    end)
    local AirPlane = {}
    local last_add = 0
    for i = 1, #pokerPoints - 2 do
        if pokerPoints[i] == pokerPoints[i + 2] then
            if last_add ~= pokerPoints[i] then
                last_add = pokerPoints[i]
                table.insert(AirPlane, pokerPoints[i])
            end
        end
    end
    return AirPlane
end

--判断是否是飞机带一
function PdkPokerLogic.IsAirplaneAndNotEnough(pokers)
    LogError("判断是否是飞机带一")
    if #pokers < 7 then
        return false
    end
    local AirPlane = this.JudgeAirPlaneBody(pokers)
    local need = math.ceil(#pokers / 5)
    for i = 1, #AirPlane do
        ---判断飞机值是否连续
        if (i + need - 1) >= 1 and (i + need - 1) <= #AirPlane then
            if AirPlane[i] == AirPlane[i + need - 1] + need - 1 then
                return true
            end
        end
    end
end

--判断是否是飞机带二
function PdkPokerLogic.IsAirplaneAndTwo(pokers)
    LogError("判断是否是飞机带二")
    if #pokers < 10 or #pokers % 5 ~= 0 then
        return false
    end
    local AirPlane = this.JudgeAirPlaneBody(pokers)
    LogError("AirPlane", AirPlane)
    local need = #pokers / 5
    for i = 1, #AirPlane do
        if AirPlane[i] ~= nil and AirPlane[i + need - 1] ~= nil and AirPlane[i] == AirPlane[i + need - 1] + need - 1 then
            return true
        end
    end
end

-----是否飞机不带全
--function PdkPokerLogic.IsAirplaneAndNotEnough(pokers)
--    local singleNum, thrNum, fourNum = this.GetDuplicateCardNumTable(pokers)
--    if (#thrNum < 2) then
--        return false
--    end
--    if #singleNum == 0 and #fourNum == 0 then
--        return false
--    end
--    this.IsSerial(thrNum)
--    return true
--end

function PdkPokerLogic.GetPokerNum(pokers)
    local pokerNum = {}
    local weight = nil
    for i = 1, #pokers do
        weight = pokers[i]
        if pokerNum[weight] == nil then
            pokerNum[weight] = 1
        else
            pokerNum[weight] = pokerNum[weight] + 1
        end
    end
    return pokerNum
end

function PdkPokerLogic.GetDuplicateCardNumTable(pokers)
    local pokerNum = this.GetPokerNum(pokers)
    LogError("pokerNum", pokerNum)
    local singleNum, thrNum, fourNum = {}, {}, {}
    for i, v in pairs(pokerNum) do
        if v == 4 then
            table.insert(thrNum, v)
            table.insert(singleNum, i)
        elseif v == 3 then
            table.insert(thrNum, v)
        elseif v == 2 then
            table.insert(singleNum, i)
            table.insert(singleNum, i)
        elseif v == 1 then
            table.insert(singleNum, i)
        end
    end
    return singleNum, thrNum, fourNum
end

---判断飞机点数是否连续（连续则为飞机，不连续则为普通两个三张）
function PdkPokerLogic.IsSerial(thrNum)
    table.sort(thrNum, function(a, b)
        return a < b
    end)
    for i = 1, #thrNum do
        if thrNum[i] + 1 ~= thrNum[i + 1] then
            return false
        end
    end
    return true
end

--判断是否是三不带
function PdkPokerLogic.IsThree(pokers)
    if #pokers ~= 3 then
        return false
    end
    if PdkPokerLogic.GetIdWeight(pokers[1]) ~= PdkPokerLogic.GetIdWeight(pokers[2]) then
        return false
    end
    if PdkPokerLogic.GetIdWeight(pokers[3]) ~= PdkPokerLogic.GetIdWeight(pokers[2]) then
        return false
    end
    if PdkPokerLogic.GetIdWeight(pokers[1]) ~= PdkPokerLogic.GetIdWeight(pokers[3]) then
        return false
    end
    return true
end

--判断是否是三带一
function PdkPokerLogic.IsThreeAndOne(pokers)
    LogError("进入判断是否是三带一")
    if #pokers ~= 4 then
        return false
    end
    if PdkPokerLogic.GetIdWeight(pokers[1]) == PdkPokerLogic.GetIdWeight(pokers[2]) and PdkPokerLogic.GetIdWeight(pokers[2]) == PdkPokerLogic.GetIdWeight(pokers[3]) then
        return true
    elseif PdkPokerLogic.GetIdWeight(pokers[2]) == PdkPokerLogic.GetIdWeight(pokers[3]) and PdkPokerLogic.GetIdWeight(pokers[3]) == PdkPokerLogic.GetIdWeight(pokers[4]) then
        return true
    end
    return false
end

--判断是否是三带二
function PdkPokerLogic.IsThreeAndTwo(pokers)
    LogError("进入判断是否是三带一")
    if #pokers ~= 5 then
        return false
    end
    if PdkPokerLogic.GetIdWeight(pokers[1]) == PdkPokerLogic.GetIdWeight(pokers[2]) and PdkPokerLogic.GetIdWeight(pokers[2]) == PdkPokerLogic.GetIdWeight(pokers[3]) then
        return true
    elseif PdkPokerLogic.GetIdWeight(pokers[2]) == PdkPokerLogic.GetIdWeight(pokers[3]) and PdkPokerLogic.GetIdWeight(pokers[3]) == PdkPokerLogic.GetIdWeight(pokers[4]) then
        return true
    elseif PdkPokerLogic.GetIdWeight(pokers[3]) == PdkPokerLogic.GetIdWeight(pokers[4]) and PdkPokerLogic.GetIdWeight(pokers[4]) == PdkPokerLogic.GetIdWeight(pokers[5]) then
        return true
    end
    return false
end

--判断是否炸弹
function PdkPokerLogic.IsBomb(pokers)
    if #pokers ~= 4 then
        return false
    end
    if PdkPokerLogic.GetIdWeight(pokers[1]) ~= PdkPokerLogic.GetIdWeight(pokers[2]) then
        return false
    end
    if PdkPokerLogic.GetIdWeight(pokers[2]) ~= PdkPokerLogic.GetIdWeight(pokers[3]) then
        return false
    end
    if PdkPokerLogic.GetIdWeight(pokers[3]) ~= PdkPokerLogic.GetIdWeight(pokers[4]) then
        return false
    end
    return true
end

--判断是否是王炸
function PdkPokerLogic.IsJokerBomb(pokers)
    if #pokers ~= 2 then
        return false
    end
    if PdkPokerLogic.GetIdWeight(pokers[1]) == PdkPoker.PdkPokerWeight.SJoker and PdkPokerLogic.GetIdWeight(pokers[2]) == PdkPoker.PdkPokerWeight.BJoker then
        return true
    elseif PdkPokerLogic.GetIdWeight(pokers[1]) == PdkPoker.PdkPokerWeight.BJoker and PdkPokerLogic.GetIdWeight(pokers[2]) == PdkPoker.PdkPokerWeight.SJoker then
        return true
    end
    return false
end

--判断是否是炸弹带二
function PdkPokerLogic.IsBombAndTwo(pokers)
    LogError("判断是否是炸弹带二")
    if #pokers ~= 6 then
        return false
    end
    local pokerNum = {}
    local weight = nil
    for i = 1, #pokers do
        weight = PdkPokerLogic.GetIdWeight(pokers[i])
        if pokerNum[weight] == nil then
            pokerNum[weight] = 1
        else
            pokerNum[weight] = pokerNum[weight] + 1
        end
    end
    --单牌
    local singleNum = {}
    --三张的
    local fourNum = {}
    for i, v in pairs(pokerNum) do
        if v == 4 then
            table.insert(fourNum, i)
        elseif v == 2 then
            table.insert(singleNum, i)
            table.insert(singleNum, i)
        elseif v == 1 then
            table.insert(singleNum, i)
        end
    end
    if (#fourNum < 1) then
        return false
    end
    return true
end

--判断是否是炸弹带三
function PdkPokerLogic.IsBombAndThree(pokers)
    LogError("判断是否是炸弹带三")
    if #pokers ~= 7 then
        return false
    end
    local pokerNum = {}
    local weight = nil
    for i = 1, #pokers do
        weight = PdkPokerLogic.GetIdWeight(pokers[i])
        if pokerNum[weight] == nil then
            pokerNum[weight] = 1
        else
            pokerNum[weight] = pokerNum[weight] + 1
        end
    end
    --单牌
    local singleNum = {}
    --三张的
    local fourNum = {}
    for i, v in pairs(pokerNum) do
        if v == 4 then
            table.insert(fourNum, i)
        elseif v == 3 then
            table.insert(singleNum, i)
            table.insert(singleNum, i)
            table.insert(singleNum, i)
        elseif v == 2 then
            table.insert(singleNum, i)
            table.insert(singleNum, i)
        elseif v == 1 then
            table.insert(singleNum, i)
        end
    end
    if (#fourNum < 1) then
        return false
    end
    return true
end

--判断是否是出牌牌型
function PdkPokerLogic.CalculatePokerType(pokers)
    if this.IsSingle(pokers) then
        --单牌
        return PdkPokerType.Single
    elseif this.IsDouble(pokers) then
        --对子
        return PdkPokerType.Double
    elseif this.IsThree(pokers) and not PdkRoomModule.IsSixteenPDKOrFifteenPDK() then
        --三不带
        if PdkRoomModule.IsSCGame() and PdkRoomModule.GetRule(PdkRuleType.ZDGZ) == 1 then
            return PdkPokerType.Bomb
        end
        return PdkPokerType.Three
    elseif this.IsBomb(pokers) then
        --炸弹and王炸
        -- elseif this.IsThreeAndOne(pokers) then        --三带一
        --     return PdkPokerType.ThreeAndOne
        -- elseif this.IsThreeAndTwo(pokers) then        --三带二
        --     return PdkPokerType.ThreeAndTwo
        if PdkRoomModule.IsSCGame() and PdkRoomModule.GetRule(PdkRuleType.ZDGZ) == 3 then
            return PdkPokerType.Four
        end
        return PdkPokerType.Bomb
    elseif this.IsStraight(pokers) then
        --顺子
        return PdkPokerType.Straight
    elseif this.IsDoubleStraight(pokers) then
        --连对
        -- elseif this.IsBombAndTwo(pokers) then        --四带二
        --     return PdkPokerType.BombAndSingle
        -- elseif this.IsBombAndThree(pokers) then        --四带三
        --     return PdkPokerType.BombAndThree
        return PdkPokerType.DoubleStraight
        -- elseif this.IsAirplaneAndOne(pokers) then        --飞机带一
        --     return PdkPokerType.AirplaneAndOne
    elseif this.IsAirplaneAndTwo(pokers) then        --飞机带二
        return PdkPokerType.AirplaneAndTwo
    elseif this.IsAirplane(pokers) then
        --飞机不带
        return PdkPokerType.Airplane
    end

    if PdkRoomModule.IsSixteenPDKOrFifteenPDK() then
        LogError("进入15，16牌型判断", IsSixteenPDKOrFifteenPDK)
        if this.IsThreeA_Bomb(pokers) then
            return PdkPokerType.Bomb
        elseif this.IsThreeAndOne(pokers) then
            --三带一
            return PdkPokerType.ThreeAndOne
        elseif this.IsThreeAndTwo(pokers) then
            --三带二
            return PdkPokerType.ThreeAndTwo
        elseif this.IsAirplaneAndTwo(pokers) then
            --飞机带二
            return PdkPokerType.AirplaneAndTwo
        elseif this.IsAirplaneAndNotEnough(pokers) then
            ---飞机不带全（飞机带单）
            return PdkPokerType.AirplaneAndOne
        elseif this.IsBombAndTwo(pokers) and PdkRoomModule.GetRule(PdkRuleType.ST_42) > 0 then
            --四带二
            return PdkPokerType.BombAndSingle
        elseif this.IsBombAndThree(pokers) and PdkRoomModule.GetRule(PdkRuleType.ST_43) > 0 then
            --四带三
            return PdkPokerType.BombAndThree
        elseif this.IsThree(pokers) and PdkRoomModule.GetRule(PdkRuleType.ST_LS) > 0 and #PdkSelfHandCardCtrl.GetHandPokers() == 3 then
            return PdkPokerType.Three
        end
    end

    -- Log("+++++++++++++++++++++++++++++这是什么牌型", this.curPokerType)
    -- if this.curPokerType == nil then
    --     return false
    -- end
    return nil
end

function PdkPokerLogic.IsThreeA_Bomb(pokers)
    if this.IsThree(pokers) and PdkRoomModule.GetRule(PdkRuleType.ST_3A) == 1 then
        return this.GetIdWeight(pokers[1]) == PdkPoker.PdkPokerWeight.One
    end
end

--将牌型id转换为对象
function PdkPokerLogic.GetPokersByValue(values)
    local pokers = {}
    local value = nil
    for i = 1, #values do
        value = values[i]
        local poker = {
            value = value,
            color = PdkPoker[value].color,
            weight = PdkPoker[value].weight
        }
        table.insert(pokers, poker)
    end
    return pokers
end

local PokerWeightMax = 15

function PdkPokerLogic.GetSCBiggerPokers(tablePokerMsg, pokerBeans)
    local tableType = tablePokerMsg[1]
    if (tableType == PdkPokerType.None) then
        return
    end
    --所有的提示
    local allNotice = {}
    --炸弹的集合{炸弹值={ids}}
    local boomArr = {}
    --所有牌的值的id集合{值={ids}}
    local valueToIds = {}
    local eachIds
    for key, var in pairs(pokerBeans) do
        eachIds = valueToIds[var.weight]
        if (eachIds == nil) then
            eachIds = {}
            valueToIds[var.weight] = eachIds
        end
        table.insert(eachIds, var.value)
        if #eachIds >= this.GetZhaDanCount() then
            boomArr[var.weight] = eachIds
        end
    end

    local tempNotice = {}
    --单牌
    if (tableType == PdkPokerType.Single) then
        local minv = tablePokerMsg[2]
        for var = minv + 1, PokerWeightMax do
            eachIds = valueToIds[var]
            if (eachIds ~= nil) then
                if #eachIds >= this.GetZhaDanCount() then
                    table.insert(tempNotice, { eachIds[1] })
                else
                    table.insert(allNotice, { eachIds[1] })
                end
            end
        end
        --对子
    elseif (tableType == PdkPokerType.Double) then
        local minv = tablePokerMsg[2]
        for var = minv + 1, PokerWeightMax do
            eachIds = valueToIds[var]
            if (eachIds ~= nil and #eachIds >= 2) then
                if #eachIds >= this.GetZhaDanCount() then
                    table.insert(tempNotice, { eachIds[1], eachIds[2] })
                else
                    table.insert(allNotice, { eachIds[1], eachIds[2] })
                end
            end
        end
        --三张
    elseif (tableType == PdkPokerType.Three) then
        local minv = tablePokerMsg[2]
        for var = minv + 1, PokerWeightMax do
            eachIds = valueToIds[var]
            if (eachIds ~= nil and #eachIds >= 3) then
                if #eachIds >= this.GetZhaDanCount() then
                    table.insert(tempNotice, { eachIds[1], eachIds[2], eachIds[3] })
                else
                    table.insert(allNotice, { eachIds[1], eachIds[2], eachIds[3] })
                end
            end
        end
        --四张
    elseif (tableType == PdkPokerType.Four and PdkRoomModule.GetRule(PdkRuleType.ZDGZ) == 3) then
        local minv = tablePokerMsg[2]
        for var = minv + 1, PokerWeightMax do
            eachIds = valueToIds[var]
            if (eachIds ~= nil and #eachIds >= 4) then
                table.insert(allNotice, { eachIds[1], eachIds[2], eachIds[3], eachIds[4] })
            end
        end
        --顺子
    elseif (tableType == PdkPokerType.Straight) then
        local start = tablePokerMsg[2]
        local len = tablePokerMsg[3]
        for var = 1, (PokerWeightMax - (start + len - 1)) do
            local shunzi = {}
            for v = start + var, start + var + len - 1 do
                eachIds = valueToIds[v]
                if (eachIds == nil) then
                    break
                else
                    table.insert(shunzi, eachIds[1])
                end
            end
            if (#shunzi == len) then
                if this.IsChaiZhaDan(shunzi, boomArr) then
                    table.insert(tempNotice, shunzi)
                else
                    table.insert(allNotice, shunzi)
                end
            end
        end
        --连对
    elseif (tableType == PdkPokerType.DoubleStraight and PdkRoomModule.GetRule(PdkRuleType.PX) > 0) then
        local start = tablePokerMsg[2]
        local len = tablePokerMsg[3]
        for var = 1, (PokerWeightMax - (start + len - 1)) do
            local liandui = {}
            for v = start + var, start + var + len - 1 do
                eachIds = valueToIds[v]
                if (eachIds == nil or #eachIds < 2) then
                    break
                else
                    table.insert(liandui, eachIds[1])
                    table.insert(liandui, eachIds[2])
                end
            end
            if (#liandui == len * 2) then
                if this.IsChaiZhaDan(liandui, boomArr) then
                    table.insert(tempNotice, liandui)
                else
                    table.insert(allNotice, liandui)
                end
            end
        end
        --飞机
    elseif (tableType == PdkPokerType.Airplane and PdkRoomModule.GetRule(PdkRuleType.FJ) > 0) then
        local start = tablePokerMsg[2]
        local len = tablePokerMsg[3]
        for var = 1, (PokerWeightMax - (start + len - 1)) do
            local feiji = {}
            for v = start + var, start + var + len - 1 do
                eachIds = valueToIds[v]
                if (eachIds == nil or #eachIds < 3) then
                    break
                else
                    table.insert(feiji, eachIds[1])
                    table.insert(feiji, eachIds[2])
                    table.insert(feiji, eachIds[3])
                end
            end
            if (#feiji == len * 3) then
                if this.IsChaiZhaDan(feiji, boomArr) then
                    table.insert(tempNotice, feiji)
                else
                    table.insert(allNotice, feiji)
                end
            end
        end
    end
    --炸弹
    if (PdkRoomModule.GetRule(PdkRuleType.ZDGZ) < 3) then
        local minBoom = 0
        --炸弹等级
        local boomLevel = 3
        if (tableType == PdkPokerType.Bomb) then
            minBoom = tablePokerMsg[2]
            --炸弹等级
            boomLevel = tablePokerMsg[3]
        end
        if (PdkRoomModule.GetRule(PdkRuleType.ZDGZ) == 2) then
            boomLevel = 4
        end
        for var = 5, PokerWeightMax do
            eachIds = valueToIds[var]
            if (eachIds ~= nil) then
                if (#eachIds == boomLevel and var > minBoom) then
                    table.insert(allNotice, eachIds)
                elseif (#eachIds > boomLevel) then
                    table.insert(allNotice, eachIds)
                end
            end
        end
        --最后插入拆炸弹的牌型
        for i = 1, #tempNotice do
            table.insert(allNotice, tempNotice[i])
        end
    end
    return allNotice
end

function PdkPokerLogic.GetLSBiggerPokers(tablePokerMsg, pokerBeans)
    local tableType = tablePokerMsg[1]
    if (tableType == PdkPokerType.None) then
        return
    end
    --所有的提示
    local allNotice = {}
    --炸弹的集合{炸弹值={ids}}
    local boomArr = {}
    --所有牌的值的id集合{值={ids}}
    local valueToIds = {}
    local eachIds
    for key, var in pairs(pokerBeans) do
        eachIds = valueToIds[var.weight]
        if (eachIds == nil) then
            eachIds = {}
            valueToIds[var.weight] = eachIds
        end
        table.insert(eachIds, var.value)
        --炸弹不可拆
        if (#eachIds >= 4 and PdkRoomModule.GetRule(PdkRuleType.LS_WF) <= 0) then
            boomArr[var.weight] = eachIds
        end
    end
    --单牌
    if (tableType == PdkPokerType.Single) then
        --对子
        local minv = tablePokerMsg[2]
        for var = minv + 1, 14 do
            if (boomArr[var] == nil) then
                eachIds = valueToIds[var]
                if (eachIds ~= nil) then
                    table.insert(allNotice, { eachIds[1] })
                end
            end
        end
    elseif (tableType == PdkPokerType.Double) then
        --三张
        local minv = tablePokerMsg[2]
        for var = minv + 1, 14 do
            if (boomArr[var] == nil) then
                eachIds = valueToIds[var]
                if (eachIds ~= nil and #eachIds >= 2) then
                    table.insert(allNotice, { eachIds[1], eachIds[2] })
                end
            end
        end
    elseif (tableType == PdkPokerType.Three) then
        --顺子
        local minv = tablePokerMsg[2]
        for var = minv + 1, 14 do
            if (boomArr[var] == nil) then
                eachIds = valueToIds[var]
                if (eachIds ~= nil and #eachIds >= 3) then
                    table.insert(allNotice, { eachIds[1], eachIds[2], eachIds[3] })
                end
            end
        end
    elseif (tableType == PdkPokerType.Straight) then
        --连对
        local start = tablePokerMsg[2]
        local len = tablePokerMsg[3]
        for var = 1, (14 - (start + len - 1)) do
            local shunzi = {}
            for v = start + var, start + var + len - 1 do
                eachIds = valueToIds[v]
                if (eachIds == nil or boomArr[v] ~= nil) then
                    break
                else
                    table.insert(shunzi, eachIds[1])
                end
            end
            if (#shunzi == len) then
                table.insert(allNotice, shunzi)
            end
        end
    elseif (tableType == PdkPokerType.DoubleStraight) then
        --飞机
        local start = tablePokerMsg[2]
        local len = tablePokerMsg[3]
        for var = 1, (14 - (start + len - 1)) do
            local liandui = {}
            for v = start + var, start + var + len - 1 do
                eachIds = valueToIds[v]
                if (eachIds == nil or #eachIds < 2 or boomArr[v] ~= nil) then
                    break
                else
                    table.insert(liandui, eachIds[1])
                    table.insert(liandui, eachIds[2])
                end
            end
            if (#liandui == len * 2) then
                table.insert(allNotice, liandui)
            end
        end
    elseif (tableType == PdkPokerType.Airplane) then
        local start = tablePokerMsg[2]
        local len = tablePokerMsg[3]
        for var = 1, (14 - (start + len - 1)) do
            local feiji = {}
            for v = start + var, start + var + len - 1 do
                eachIds = valueToIds[v]
                if (eachIds == nil or #eachIds < 3 or boomArr[v] ~= nil) then
                    break
                else
                    table.insert(feiji, eachIds[1])
                    table.insert(feiji, eachIds[2])
                    table.insert(feiji, eachIds[3])
                end
            end
            if (#feiji == len * 3) then
                table.insert(allNotice, feiji)
            end
        end
    end
    --炸弹
    local minBoom = 0
    if (tableType == PdkPokerType.Bomb) then
        minBoom = tablePokerMsg[2]
    end
    for var = 5, 14 do
        eachIds = valueToIds[var]
        if (eachIds ~= nil) then
            if (#eachIds >= 4 and var > minBoom) then
                table.insert(allNotice, eachIds)
            end
        end
    end
    return allNotice
end

function PdkPokerLogic.GetCanOutPokers(pokerBeans)
    --{是否能出牌，出的牌类型，{能出的牌的推荐id}}
    local canShow = { false, PdkPokerType.None, {} }
    local pokerNum = #pokerBeans
    --所有牌的值的id集合{值={ids}}
    local valueToIds = {}
    local eachIds
    for key, var in pairs(pokerBeans) do
        eachIds = valueToIds[var.weight]
        if (eachIds == nil) then
            eachIds = {}
            valueToIds[var.weight] = eachIds
        end
        table.insert(eachIds, var.value)
    end
    --临时存放数据{是否能出牌，出的牌类型，{能出的牌的推荐id}}
    local linshi
    --先顺子
    if (pokerNum >= 3) then
        for var = 0, (pokerNum - 3) do
            linshi = this.IsHaveShunZi(valueToIds, pokerNum, 0, pokerNum - var)
            if (linshi[1]) then
                canShow = linshi
                break
            end
        end
    end
    --飞机
    if (pokerNum >= 6 and PdkRoomModule.GetRule(PdkRuleType.FJ) > 0) then
        linshi = this.IsHaveFeiJi(valueToIds, pokerNum, 0, 2)
        if (linshi[1] and #linshi[3] > #canShow[3]) then
            canShow = linshi
        end
    end
    --连对
    if (pokerNum >= 4 and PdkRoomModule.GetRule(PdkRuleType.PX) > 0) then
        local len = math.floor(pokerNum / 2)
        for var = 0, (len - 2) do
            linshi = this.IsHaveLiandui(valueToIds, pokerNum, 0, len - var)
            if (linshi[1] and #linshi[3] > #canShow[3]) then
                canShow = linshi
            end
        end
    end
    local num = #canShow[3]
    --大于7张直接返回
    if (num > 7) then
        return canShow
    end
    --4炸弹
    linshi = this.IsHaveBoom(valueToIds, pokerNum, 0, 4)
    if (linshi[1] and #linshi[3] > #canShow[3]) then
        canShow = linshi
        return canShow
    end
    --4四张
    linshi = this.IsHaveFour(valueToIds, pokerNum, 0)
    if (linshi[1] and #linshi[3] > #canShow[3]) then
        canShow = linshi
        return canShow
    end
    --3炸弹
    if (PdkRoomModule.GetRule(PdkRuleType.ZDGZ) == 1) then
        linshi = IsHaveBoom(valueToIds, pokerNum, 0, 3)
        if (linshi[1] and #linshi[3] > #canShow[3]) then
            canShow = linshi
            return canShow
        end
    end
    --三张
    if (PdkRoomModule.GetRule(PdkRuleType.ZDGZ) ~= 1) then
        linshi = this.IsHaveThr(valueToIds, pokerNum, 0)
        if (linshi[1] and #linshi[3] > #canShow[3]) then
            canShow = linshi
            return canShow
        end
    end
    --对子
    linshi = this.IsHaveDouble(valueToIds, pokerNum, 0)
    if (linshi[1] and #linshi[3] > #canShow[3]) then
        canShow = linshi
        return canShow
    end
    return canShow
end

--是否有对子
function PdkPokerLogic.IsHaveDouble(valueToIds, pokerNum, doubleValue)
    if (pokerNum >= 2) then
        for key, var in pairs(valueToIds) do
            if (key > doubleValue and #var > 1) then
                return { true, PdkPokerType.Double, { var[1], var[2] } }
            end
        end
    end
    return { false }
end
--是否有三张
function PdkPokerLogic.IsHaveThr(valueToIds, pokerNum, thrValue)
    if (pokerNum >= 3) then
        for key, var in pairs(valueToIds) do
            if (key > thrValue and #var >= 3) then
                return { true, PdkPokerType.Three, { var[1], var[2], var[3] } }
            end
        end
    end
    return { false }
end
--是否有顺子
function PdkPokerLogic.IsHaveShunZi(valueToIds, pokerNum, startValue, lenth)
    if (pokerNum >= lenth) then
        local showIds = {}
        local size = 0
        for var = startValue + 1, 14 do
            if (valueToIds[var] ~= nil and #(valueToIds[var]) > 0) then
                size = size + 1
                table.insert(showIds, valueToIds[var][1])
                if (size >= lenth) then
                    return { true, PdkPokerType.Straight, showIds }
                end
            else
                size = 0
                showIds = {}
            end
        end
    end
    return { false }
end
--是否有连对
function PdkPokerLogic.IsHaveLiandui(valueToIds, pokerNum, startValue, lenth)
    if (pokerNum >= lenth * 2 and PdkRoomModule.GetRule(PdkRuleType.PX) > 0) then
        local showIds = {}
        local size = 0
        for var = startValue + 1, 14 do
            if (valueToIds[var] ~= nil and #(valueToIds[var]) >= 2) then
                size = size + 1
                table.insert(showIds, valueToIds[var][1])
                table.insert(showIds, valueToIds[var][2])
                if (size >= lenth) then
                    return { true, PdkPokerType.DoubleStraight, showIds }
                end
            else
                size = 0
                showIds = {}
            end
        end
    end
    return { false }
end
--是否有飞机
function PdkPokerLogic.IsHaveFeiJi(valueToIds, pokerNum, startValue, lenth)
    if (pokerNum >= lenth * 3 and PdkRoomModule.GetRule(PdkRuleType.FJ) > 0) then
        local showIds = {}
        local size = 0
        for var = startValue + 1, 14 do
            if (valueToIds[var] ~= nil and #(valueToIds[var]) >= 3) then
                size = size + 1
                table.insert(showIds, valueToIds[var][1])
                table.insert(showIds, valueToIds[var][2])
                table.insert(showIds, valueToIds[var][3])
                if (size >= lenth) then
                    return { true, PdkPokerType.Airplane, showIds }
                end
            else
                size = 0
                showIds = {}
            end
        end
    end
    return { false }
end
--是否有炸弹(type可能3张4张)
function PdkPokerLogic.IsHaveBoom(valueToIds, pokerNum, value, type)
    if (pokerNum >= 3 and PdkRoomModule.GetRule(PdkRuleType.ZDGZ) < 3) then
        for key, var in pairs(valueToIds) do
            if (key > value) then
                if (#var >= type) then
                    return { true, PdkPokerType.Bomb, var, #var }
                end
            end
        end
    end
    return { false }
end
--是否有四张
function PdkPokerLogic.IsHaveFour(valueToIds, pokerNum, value)
    if (pokerNum >= 3 and PdkRoomModule.GetRule(PdkRuleType.ZDGZ) == 3) then
        for key, var in pairs(valueToIds) do
            if (key > value) then
                if (#var >= 4) then
                    return { true, PdkPokerType.Four, var }
                end
            end
        end
    end
    return { false }
end

--TODO 比较牌型大小(xiaoPokerType,小的牌型。daPokerType 大的牌型(不能不构成牌型)：均为算牌型返回的数据格式)
function PdkPokerLogic.ComparPokerType(xiaoPokerType, daPokerType)
    --小牌的牌型
    local xiaoType = xiaoPokerType[1]
    --大的牌型
    local daType = daPokerType[1]

    LogError("daPokerType", daPokerType)
    LogError("xiaoPokerType", xiaoPokerType)
    --牌型一样
    if (xiaoType == daType) then
        --单牌，对子，三不带,四张{牌型，大小}
        if (daType == PdkPokerType.Single or daType == PdkPokerType.Double or daType == PdkPokerType.Three or daType == PdkPokerType.Four) then
            --顺子，连对，飞机{牌型，起始大小，长度}
            if (daPokerType[2] > xiaoPokerType[2]) then
                return true
            end
            return false
        elseif (daType == PdkPokerType.Straight or daType == PdkPokerType.DoubleStraight or daType == PdkPokerType.Airplane or daType == PdkPokerType.AirplaneAndTwo) then
            --炸弹{牌型，大小,3三人4四人}
            if (daPokerType[2] > xiaoPokerType[2] and daPokerType[3] == xiaoPokerType[3]) then
                return true
            end
            return false
        elseif (daType == PdkPokerType.Bomb) then
            if ((daPokerType[3] > xiaoPokerType[3]) or (daPokerType[3] == xiaoPokerType[3] and daPokerType[2] > xiaoPokerType[2])) then
                return true
            end
            return false
        elseif (daType == PdkPokerType.ThreeAndTwo) then
            return (daPokerType[2] > xiaoPokerType[2])
        elseif (daType == PdkPokerType.BombAndSingle) then
            return (daPokerType[2] > xiaoPokerType[2])
        elseif (daType == PdkPokerType.BombAndThree) then
            return (daPokerType[2] > xiaoPokerType[2])
        end
    else
        if (xiaoType == PdkPokerType.None) then
            return true
        else
            if (daType == PdkPokerType.Bomb) then
                return true
            end
            return false
        end
    end
end

--table用。验证是否能拆炸弹相关功能(pokerBeans玩家牌，验证的牌)
function PdkPokerLogic.CheckChaiZhaDan(pokerBeans, checkIds)
    if (PdkRoomModule.GetRule(PdkRuleType.LS_WF) > 0) then
        return true
    end
    --本身是炸弹
    if (this.IsBomb(checkIds)) then
        return true
    end
    if (#pokerBeans < 4) then
        return true
    end
    --炸弹集合{值={ids}}
    local boomTable = nil
    --所有牌的值的id集合{值={ids}}
    local valueToIds = {}
    local eachIds
    for key, var in pairs(pokerBeans) do
        eachIds = valueToIds[var.weight]
        if (eachIds == nil) then
            eachIds = {}
            valueToIds[var.weight] = eachIds
        end
        table.insert(eachIds, var.value)
        if (#eachIds >= 4) then
            if (boomTable == nil) then
                boomTable = {}
            end
            boomTable[var.weight] = eachIds
        end
    end
    if (boomTable == nil) then
        return true
    end
    for key, var in pairs(checkIds) do
        if (boomTable[this.GetIdWeight(var)] ~= nil) then
            return false
        end
    end
    return true
end

--几张算炸弹
function PdkPokerLogic.GetZhaDanCount()
    if PdkRoomModule.GetRule(PdkRuleType.ZDGZ) == 1 then
        return 3
    elseif PdkRoomModule.GetRule(PdkRuleType.ZDGZ) == 2 then
        return 4
    end
    return 5
end

function PdkPokerLogic.IsChaiZhaDan(checkIds, pokers)
    for i = 1, #checkIds do
        if pokers[this.GetIdWeight(checkIds[i])] ~= nil then
            return true
        end
    end
    return false
end

function PdkPokerLogic.GetSixTeenBiggerPokers(tablePokerMsg, pokerBeans)
    local tableType = tablePokerMsg[1]
    LogError("tableType", tableType)
    if (tableType == PdkPokerType.None) then
        return
    end
    --所有的提示
    local allNotice = {}
    --炸弹的集合{炸弹值={ids}}
    local boomArr = {}
    --所有牌的值的id集合{值={ids}}
    local valueToIds = {}
    local eachIds
    for key, var in pairs(pokerBeans) do
        eachIds = valueToIds[var.weight]
        if (eachIds == nil) then
            eachIds = {}
            valueToIds[var.weight] = eachIds
        end
        table.insert(eachIds, var.value)
        if #eachIds >= this.GetZhaDanCount() then
            boomArr[var.weight] = eachIds
        end
    end

    local tempNotice = {}
    --单牌
    if (tableType == PdkPokerType.Single) then
        local minv = tablePokerMsg[2]
        for var = minv + 1, PokerWeightMax do
            eachIds = valueToIds[var]
            if (eachIds ~= nil) then
                if #eachIds >= this.GetZhaDanCount() then
                    table.insert(tempNotice, { eachIds[1] })
                else
                    table.insert(allNotice, { eachIds[1] })
                end
            end
        end
        --对子
    elseif (tableType == PdkPokerType.Double) then
        local minv = tablePokerMsg[2]
        for var = minv + 1, PokerWeightMax do
            eachIds = valueToIds[var]
            if (eachIds ~= nil and #eachIds >= 2) then
                if #eachIds >= this.GetZhaDanCount() then
                    table.insert(tempNotice, { eachIds[1], eachIds[2] })
                else
                    table.insert(allNotice, { eachIds[1], eachIds[2] })
                end
            end
        end
        --三张
    elseif (tableType == PdkPokerType.Three) then
        local minv = tablePokerMsg[2]
        for var = minv + 1, PokerWeightMax do
            eachIds = valueToIds[var]
            if (eachIds ~= nil and #eachIds >= 3) then
                if #eachIds >= this.GetZhaDanCount() then
                    table.insert(tempNotice, { eachIds[1], eachIds[2], eachIds[3] })
                else
                    table.insert(allNotice, { eachIds[1], eachIds[2], eachIds[3] })
                end
            end
        end
        --四张
    elseif (tableType == PdkPokerType.Four) then
        local minv = tablePokerMsg[2]
        for var = minv + 1, PokerWeightMax do
            eachIds = valueToIds[var]
            if (eachIds ~= nil and #eachIds >= 4) then
                table.insert(allNotice, { eachIds[1], eachIds[2], eachIds[3], eachIds[4] })
            end
        end
        --顺子
    elseif (tableType == PdkPokerType.Straight) then
        local start = tablePokerMsg[2]
        local len = tablePokerMsg[3]
        for var = 1, (PokerWeightMax - (start + len - 1)) do
            local shunzi = {}
            for v = start + var, start + var + len - 1 do
                eachIds = valueToIds[v]
                if (eachIds == nil) then
                    break
                else
                    table.insert(shunzi, eachIds[1])
                end
            end
            if (#shunzi == len) then
                if this.IsChaiZhaDan(shunzi, boomArr) then
                    table.insert(tempNotice, shunzi)
                else
                    table.insert(allNotice, shunzi)
                end
            end
        end
        --连对
    elseif tableType == PdkPokerType.DoubleStraight then
        local start = tablePokerMsg[2]
        local len = tablePokerMsg[3]
        for var = 1, (PokerWeightMax - (start + len - 1)) do
            local liandui = {}
            for v = start + var, start + var + len - 1 do
                eachIds = valueToIds[v]
                if (eachIds == nil or #eachIds < 2) then
                    break
                else
                    table.insert(liandui, eachIds[1])
                    table.insert(liandui, eachIds[2])
                end
            end
            if (#liandui == len * 2) then
                if this.IsChaiZhaDan(liandui, boomArr) then
                    table.insert(tempNotice, liandui)
                else
                    table.insert(allNotice, liandui)
                end
            end
        end
        ---三带二
    elseif tableType == PdkPokerType.ThreeAndTwo then
        local minv = tablePokerMsg[2]
        --LogError("valueToIds", valueToIds)
        local poker4Weight, poker4, poker5
        for var = 3, PokerWeightMax do
            eachIds = valueToIds[var]
            if eachIds and #valueToIds[var] == 1 then
                if #eachIds >= this.GetZhaDanCount() then
                    poker4 = eachIds[1]
                    poker4Weight = var
                else
                    poker4 = eachIds[1]
                    poker4Weight = var
                end
                break
            end
        end
        if poker4Weight ~= nil then
            for var = poker4Weight + 1, PokerWeightMax do
                eachIds = valueToIds[var]
                if eachIds and #valueToIds[var] == 1 then
                    if #eachIds >= this.GetZhaDanCount() then
                        poker5 = eachIds[1]
                    else
                        poker5 = eachIds[1]
                    end
                    break
                end
            end
        end
        
        for var = minv + 1, PokerWeightMax do
            eachIds = valueToIds[var]
            if (eachIds ~= nil and #eachIds >= 3) then
                if #eachIds >= this.GetZhaDanCount() then
                    table.insert(tempNotice, { eachIds[1], eachIds[2], eachIds[3], poker4, poker5 })
                else
                    table.insert(allNotice, { eachIds[1], eachIds[2], eachIds[3], poker4, poker5 })
                end
            end
        end
        --飞机
    elseif tableType == PdkPokerType.Airplane then
        local start = tablePokerMsg[2]
        local len = tablePokerMsg[3]
        for var = 1, (PokerWeightMax - (start + len - 1)) do
            local feiji = {}
            for v = start + var, start + var + len - 1 do
                eachIds = valueToIds[v]
                if (eachIds == nil or #eachIds < 3) then
                    break
                else
                    table.insert(feiji, eachIds[1])
                    table.insert(feiji, eachIds[2])
                    table.insert(feiji, eachIds[3])
                end
            end
            if (#feiji == len * 3) then
                if this.IsChaiZhaDan(feiji, boomArr) then
                    table.insert(tempNotice, feiji)
                else
                    table.insert(allNotice, feiji)
                end
            end
        end
    end
    --炸弹
    if true then
        local minBoom = 0
        --炸弹等级
        local boomLevel = 3
        if (tableType == PdkPokerType.Bomb) then
            minBoom = tablePokerMsg[2]
            --炸弹等级
            boomLevel = tablePokerMsg[3]
        end

        boomLevel = 4

        for var = 5, PokerWeightMax do
            eachIds = valueToIds[var]
            if (eachIds ~= nil) then
                if (#eachIds == boomLevel and var > minBoom) then
                    table.insert(allNotice, eachIds)
                elseif (#eachIds > boomLevel) then
                    table.insert(allNotice, eachIds)
                end
            end
        end
        --最后插入拆炸弹的牌型
        for i = 1, #tempNotice do
            table.insert(allNotice, tempNotice[i])
        end
    end
    return allNotice
end