--胡牌辅助
MahjongTingHelper = {
    --所有牌数据，即每样牌取一个
    allCardDatas = nil,
    --key对应的牌数据
    keyMappingCardDatas = {},
    --
    tempLength = 0,
    tempCardData = nil,
    --
    tempCardData1 = nil,
    tempCardData2 = nil,
    tempCardData3 = nil,
    --统计听用数量
    tingNum = 0,
    --统计数据对象
    countData = nil,
    --统计数据集合
    countDatas = {},
    --胡牌数据
    tipsData = nil,
    --万数量
    wanNum = 0,
    --条数量
    tiaoNum = 0,
    --筒数量
    tongNum = 0,

}

local this = MahjongTingHelper

--所有牌的第一个牌ID
local AllCardIds = {
    101, 201, 301, 401, 501, 601, 701, 801, 901,
    1101, 1201, 1301, 1401, 1501, 1601, 1701, 1801, 1901,
    2101, 2201, 2301, 2401, 2501, 2601, 2701, 2801, 2901
}

--初始化
function MahjongTingHelper.Initialize()
    if this.allCardDatas == nil then
        this.allCardDatas = {}
        this.tempLength = #AllCardIds
        for i = 1, this.tempLength do
            this.tempCardData = MahjongHuCheckCardData.New()
            this.tempCardData:SetId(AllCardIds[i])

            if MahjongUtil.IsTingYongCard(this.tempCardData.key) then
                this.tempCardData.sort = this.tempCardData.id - 10000
                this.tempCardData.isTing = true
            else
                this.tempCardData.sort = this.tempCardData.id
                this.tempCardData.isTing = false
            end
            table.insert(this.allCardDatas, this.tempCardData)

            this.keyMappingCardDatas[this.tempCardData.key] = this.tempCardData
        end
    end
end

--================================================================
--
--拷贝牌
function MahjongTingHelper.CopyCards(cards)
    local result = {}
    for i = 1, #cards do
        table.insert(result, cards[i])
    end
    return result
end

--排序方法
function MahjongTingHelper.CardDataSort(cardData1, cardData2)
    return cardData1.sort < cardData2.sort
end

--================================================================
--
--设置检测的准备数据
function MahjongTingHelper.SetCheckPrepareData(rules, dingQueType, leftCards)
    --规则对象
    this.rules = rules
    this.dingQueType = dingQueType
    this.leftCards = leftCards

    --最大番数
    this.maxFan = 2
    --左手牌判断的番数
    this.leftFanNum = 0
    --左手牌
    this.leftCardDatas = {}
    --是否检测中张
    this.isCheckZhongZhang = false
    --左手牌的第一张牌类型
    this.firstLeftCardType = nil
    --手牌第一张牌的类型
    this.firstCardType = nil
    --是否左边牌为清一色
    this.isLeftQingYiSe = true
    --是否左边牌存在幺鸡
    this.isLeftExistYaoji = false
    --是否左边牌存在幺九
    this.isLeftExist19 = false
    --暗杠数量
    local anGangNum = 0

    --检测最大番数
    local rule = this.rules[Mahjong.RuleType.Multiple]
    if rule ~= nil then
        this.maxFan = tonumber(rule)
    end

    --处理是否检测中张规则
    rule = this.rules[Mahjong.RuleType.ZhongZhang]
    if rule ~= nil and rule == 1 then
        this.isCheckZhongZhang = true
    end

    --处理左方碰杠牌
    local leftLength = #this.leftCards
    local cardData = nil
    local temp = nil
    for i = 1, leftLength do
        temp = this.leftCards[i]
        cardData = MahjongHuCheckCardData.New()
        cardData:SetId(temp.k1)
        --MahjongOperateCode的类型
        if temp.type == 2 or temp.type == 3 then
            cardData.isGang = true
        elseif temp.type == 4 then
            cardData.isGang = true
            anGangNum = anGangNum + 1
        elseif temp.type == 15 or temp.type == 16 then
            --幺鸡杠
            cardData.isGang = true
            --存在幺鸡，就算幺鸡被换了，也可以设置不影响幺鸡是否存在的判断
            this.isLeftExistYaoji = true
        elseif temp.type == 17 then
            cardData.isGang = true
            this.isLeftExistYaoji = true
            anGangNum = anGangNum + 1
        end
        --
        this.CheckLeftQingYiSe(cardData)
        if cardData.num == 1 or cardData.num == 9 then
            this.isLeftExist19 = true
        end
        --
        table.insert(this.leftCardDatas, cardData)
    end

    --检测门清规则
    rule = this.rules[Mahjong.RuleType.MenQing]
    if rule ~= nil and rule == 1 then
        if leftLength == anGangNum then
            this.leftFanNum = this.leftFanNum + 1
            --LogError(">> MahjongTingHelper.SetCheckPrepareData > MenQing + 1 > leftFanNum = " .. this.leftFanNum)
        end
    end
end

--获取听牌提示数据
function MahjongTingHelper.GetTipsData(midCards, rightCard)
    --
    this.tipsData = {}
    --
    local handCards = this.CopyCards(midCards)
    --碰杠打牌时，右手牌是没有的，固不需要加入
    if rightCard > 0 then
        table.insert(handCards, rightCard)
    end
    --找出定缺牌，只会出现一个
    local length = #handCards
    local dingQueCardDataIndex = 0
    local isExistTingData = false
    local tempCardData = nil
    local tempCardDatas = {}
    for i = 1, length do
        tempCardData = MahjongHuCheckCardData.New()
        tempCardData:SetId(handCards[i])
        tempCardDatas[i] = tempCardData
        --
        if dingQueCardDataIndex == 0 then
            if not tempCardData.isTing and tempCardData.type == this.dingQueType then
                dingQueCardDataIndex = i
            end
        end
    end
    --
    local tempMidCardDatas = nil
    --
    if dingQueCardDataIndex ~= 0 then
        --有定缺牌，直接打定缺牌
        tempMidCardDatas = {}
        for i = 1, length do
            if dingQueCardDataIndex ~= i then
                table.insert(tempMidCardDatas, tempCardDatas[i])
            else
                tempCardData = tempCardDatas[i]
            end
        end
        --LogError(">> MahjongTingHelper.GetTipsData >> ======== > Check Card = ", tempCardData.key)
        this.SetCheckMidCardDatas(tempMidCardDatas)
        local temp = this.GetCheckDataByLoopCard(tempCardData.key)
        if #temp > 0 then
            isExistTingData = true
            this.tipsData[tempCardData.key] = temp
        end
    else
        --一个一个的牌检测
        local tempDict = {}
        for i = 1, length do
            tempCardData = tempCardDatas[i]
            --幺鸡牌和处理过的就不处理了
            if not tempCardData.isTing and tempDict[tempCardData.key] == nil then
                --LogError("<color=#ffff00> >> MahjongTingHelper.GetTipsData >> ======== > ==== > Check Card = " .. tempCardData.key .. "</color>")
                tempDict[tempCardData.key] = 1
                tempMidCardDatas = {}
                --
                for j = 1, length do
                    if i ~= j then
                        table.insert(tempMidCardDatas, tempCardDatas[j])
                    end
                end
                this.SetCheckMidCardDatas(tempMidCardDatas)
                --
                local temp = this.GetCheckDataByLoopCard(tempCardData.key)
                if #temp > 0 then
                    isExistTingData = true
                    this.tipsData[tempCardData.key] = temp
                end
            end
        end
    end
    if isExistTingData then
        return this.tipsData
    else
        return nil
    end
end

--获取无右手牌的胡数据
function MahjongTingHelper.GetHuData(midCards)
    --LogError(">> MahjongTingHelper.GetHuData > ---------------============")
    --找出定缺牌，只会出现一个
    local length = #midCards
    local tempCardData = nil
    local tempCardDatas = {}
    for i = 1, length do
        tempCardData = MahjongHuCheckCardData.New()
        tempCardData:SetId(midCards[i])
        tempCardDatas[i] = tempCardData
    end
    this.SetCheckMidCardDatas(tempCardDatas)
    local temp = this.GetCheckDataByLoopCard(0)
    if #temp > 0 then
        return temp
    else
        return nil
    end
end

--通过检测所有牌来获取听牌数据
function MahjongTingHelper.GetCheckDataByLoopCard(key)
    local data = {}
    local fanNum = 0
    for i = 1, #this.allCardDatas do
        this.tempCardData = this.allCardDatas[i]
        --幺鸡直接取最大的番数来处理
        if not this.tempCardData.isTing and this.tempCardData.type ~= this.dingQueType then
            --LogError("<color=#FF00FF> >> GetCheckDataByLoopCard >> Play Key = " .. key .. ", > Check Key = " .. this.tempCardData.key .. "</color>")
            fanNum = this.CheckYaojiFanNumBySingleCard(this.tempCardData.id)
            --LogError(">> MahjongTingHelper.GetCheckDataByLoopCard >> ======== > End > fanNum = " .. fanNum)
            if fanNum > -1 then
                table.insert(data, { key = this.tempCardData.key, fanNum = fanNum, surplus = 0 })
            end
        end
    end
    return data
end

--================================================================
--门清（没碰、没杠（暗杠除外））、中张（没有幺九）、金钩钓、
--7队（+2番），大对子（+1番），清一色（+2番)，无鸡（+1番）
--设置检测幺鸡听牌番数的固定数据，即同准备方法，需要处理定缺后的牌
function MahjongTingHelper.SetCheckMidCards(midCards)
    local length = #midCards
    local midCardDatas = {}
    local cardData = nil
    --处理手牌，不进行排序，因为插入新摸牌时需要重新排序
    for i = 1, length do
        cardData = MahjongHuCheckCardData.New()
        cardData:SetId(midCards[i])
        table.insert(midCardDatas, cardData)
    end
    this.SetCheckMidCardDatas(midCardDatas)
end

--设置中间手牌的数据
function MahjongTingHelper.SetCheckMidCardDatas(midCardDatas)
    --========初始化数据========
    --基础番
    this.baseFan = 0
    --中间牌，不包含摸的牌
    this.midCardDatas = midCardDatas
    --
    --检测金钩钓规则
    local rule = this.rules[Mahjong.RuleType.JinGouDiao]
    if rule ~= nil and rule == 1 then
        if #this.midCardDatas == 1 then
            this.baseFan = this.leftFanNum + 1
            --LogError(">> MahjongTingHelper.SetCheckMidCardDatas > JinGouDiao + 1 > baseFan = " .. this.baseFan)
        end
    end
end

--================================================================
--
--检测左边牌是否为清一色
function MahjongTingHelper.CheckLeftQingYiSe(cardData)
    if this.firstLeftCardType == nil then
        this.firstLeftCardType = cardData.type
    else
        if this.firstLeftCardType ~= cardData.type then
            this.isLeftQingYiSe = false
        end
    end
end

--检测清一色，用右边的牌检测
function MahjongTingHelper.CheckQingYiSe(cardData)
    if this.isQingYiSe == false then
        return
    end

    if cardData.isTing then
        --排除听用牌
        return
    end

    if this.firstLeftCardType ~= nil then
        if this.firstLeftCardType ~= cardData.type then
            this.isQingYiSe = false
        end
    else
        if this.firstCardType == nil then
            this.firstCardType = cardData.type
        else
            if this.firstCardType ~= cardData.type then
                this.isQingYiSe = false
            end
        end
    end
end

--统计单张牌
function MahjongTingHelper.StatisticsSingleCardData(cardData)
    if cardData.isTing then
        this.tingNum = this.tingNum + 1
    else
        this.countData = this.countDatas[cardData.key]
        if this.countData == nil then
            this.countData = { key = cardData.key, num = 0, cards = {} }
            this.countDatas[cardData.key] = this.countData
        end
        this.countData.num = this.countData.num + 1
        table.insert(this.countData.cards, cardData)

        if cardData.type == MahjongColorType.Wan then
            this.wanNum = this.wanNum + 1
        elseif cardData.type == MahjongColorType.Tiao then
            this.tiaoNum = this.tiaoNum + 1
        else
            this.tongNum = this.tongNum + 1
        end
        --
        this.CheckQingYiSe(cardData)
        if cardData.num == 1 or cardData.num == 9 then
            this.isExist19 = true
        end
    end
end

--通过单张牌检测幺鸡玩法番数，需要提前设置固定数据
function MahjongTingHelper.CheckYaojiFanNumBySingleCard(checkCard)
    local checkCardData = MahjongHuCheckCardData.New()
    checkCardData:SetId(checkCard)

    --手牌，包含了摸的牌，带幺鸡牌，排序后的牌
    this.handCardDatas = {}
    --拷贝手牌
    local length = #this.midCardDatas
    for i = 0, length do
        this.handCardDatas[i] = this.midCardDatas[i]
    end
    this.handCardDatas[length + 1] = checkCardData
    table.sort(this.handCardDatas, this.CardDataSort)
    --
    --LogError(">> MahjongTingHelper.CheckYaojiFanNumBySingleCard > ", this.handCardDatas)
    --
    --手牌听用牌数量
    this.tingNum = 0
    --手牌万数量
    this.wanNum = 0
    --手牌条数量
    this.tiaoNum = 0
    --手牌筒数量
    this.tongNum = 0
    --牌值统计，每一种值的牌集合，除去了听用牌
    this.countDatas = {}
    --手牌的第一张牌类型
    this.firstCardType = nil
    --手牌是否清一色
    this.isQingYiSe = true
    --手牌是否存在幺九
    this.isExist19 = false
    --
    length = #this.handCardDatas
    for i = 1, length do
        this.StatisticsSingleCardData(this.handCardDatas[i])
    end

    --番数
    local fanNum = this.baseFan
    --LogError(">> this.isQingYiSe and this.isLeftQingYiSe", this.isQingYiSe, this.isLeftQingYiSe)
    --清一色
    if this.isQingYiSe and this.isLeftQingYiSe then
        fanNum = fanNum + 2
    end

    --无鸡加番
    if not this.isLeftExistYaoji and this.tingNum == 0 then
        fanNum = fanNum + 1
    end

    --
    --处理7对
    local tempFanNum = this.CheckFanNumBy7Dui()
    if tempFanNum >= 0 then
        tempFanNum = tempFanNum + fanNum
        --检测中张
        if this.isCheckZhongZhang then
            --手牌不存在幺九
            if not this.isExist19 then
                tempFanNum = tempFanNum + 1
                --LogError(">> MahjongTingHelper.CheckYaojiFanNumBySingleCard > 1 > ZhongZhan + 1 > fanNum = " .. tempFanNum)
            end
        end
        --LogError(">> MahjongTingHelper.CheckYaojiFanNumBySingleCard > 7Dui > fanNum = " .. tempFanNum)
        return tempFanNum
    end

    --处理大对子
    tempFanNum = this.CheckFanNumByDaDuiZi()
    if tempFanNum >= 0 then
        tempFanNum = tempFanNum + fanNum
        --检测中张
        if this.isCheckZhongZhang then
            --左边牌和手牌都不存在幺九
            if not this.isLeftExist19 and not this.isExist19 then
                tempFanNum = tempFanNum + 1
                --LogError(">> MahjongTingHelper.CheckYaojiFanNumBySingleCard > 2 > ZhongZhan + 1 > fanNum = " .. tempFanNum)
            end
        end
        --LogError(">> MahjongTingHelper.CheckYaojiFanNumBySingleCard > DaDuiZi > fanNum = " .. tempFanNum)
        return tempFanNum
    end

    --正常牌型处理
    if this.tingNum == 0 then
        if this.CheckIsHu(this.handCardDatas) then
            tempFanNum = this.CheckFanNumByNoTing(this.leftCardDatas, this.handCardDatas)
        else
            --LogError(">> MahjongTingHelper.CheckYaojiFanNumBySingleCard > ======== Not Hu ========")
        end
    else
        tempFanNum = this.CheckFanNumByTing()
    end

    --没有叫就返回-1，否则就返回番数
    if tempFanNum == -1 then
        return -1
    else
        return tempFanNum + fanNum
    end
end

------------------------------------------------------------------
--检测7对加番，如果不是七对返回-1，否则返回正确的番数
function MahjongTingHelper.CheckFanNumBy7Dui()
    --LogError(">> MahjongTingHelper.CheckFanNumBy7Dui >> ======== > Start.")
    local length = #this.leftCardDatas
    --有左边的牌，说明就不能为7对
    if length > 0 then
        return -1
    end

    --首先7对加2番
    local fanNum = 2
    local p2Num = 0
    local tempTingNum = this.tingNum
    --再计算有没有其他的根
    for k, v in pairs(this.countDatas) do
        if v.num == 4 then
            fanNum = fanNum + 1
        elseif v.num == 3 then
            fanNum = fanNum + 1
            --消耗一个听用
            tempTingNum = tempTingNum - 1
        elseif v.num == 2 then
            p2Num = p2Num + 1
        else
            --单个牌也需要消耗一个听用
            tempTingNum = tempTingNum - 1
            p2Num = p2Num + 1
        end
    end

    --处理2+2听用
    if tempTingNum > 1 then
        if p2Num > 0 then
            p2Num = p2Num - 1
            tempTingNum = tempTingNum - 2
            fanNum = fanNum + 1
        end
    end
    --由于最多处理2次，固代码中就写了两次
    if tempTingNum > 1 then
        if p2Num > 0 then
            p2Num = p2Num - 1
            tempTingNum = tempTingNum - 2
            fanNum = fanNum + 1
        end
    end
    if tempTingNum < 0 then
        --听用数量不对，说明不能成为7对
        --LogError(">> MahjongTingHelper.CheckFanNumBy7Dui > ==== Not 7Dui ==== > tempTingNum < 0")
        return -1
    end
    tempTingNum = tempTingNum % 2
    if tempTingNum ~= 0 then
        --听用数量不对，说明不能成为7对
        --LogError(">> MahjongTingHelper.CheckFanNumBy7Dui > ==== Not 7Dui ==== > tempTingNum % 2 ~= 0")
        return -1
    end

    return fanNum
end

------------------------------------------------------------------
--检测大对子
function MahjongTingHelper.CheckFanNumByDaDuiZi()
    --LogError(">> MahjongTingHelper.CheckFanNumByDaDuiZi >> ======== > Start. ")
    local isDaDuiZi = true
    local tempTingNum = this.tingNum
    local p2Num = 0
    local cardDicts = {}
    for k, v in pairs(this.countDatas) do
        if v.num == 4 then
            cardDicts[k] = { count = 4 }
        elseif v.num == 3 then
            cardDicts[k] = { count = 3 }
        elseif v.num == 2 then
            p2Num = p2Num + 1
            cardDicts[k] = { count = 2 }
        else
            --直接把单牌使用听用设置为对子
            p2Num = p2Num + 1
            tempTingNum = tempTingNum - 1
            cardDicts[k] = { count = 2 }
        end
    end

    --是否是听用将对
    local isTingJiangDui = false
    --如果没有将对，则需要2个听用
    if p2Num == 0 then
        --LogError(">> MahjongTingHelper.CheckFanNumByDaDuiZi > isTingJiangDui == true ")
        isTingJiangDui = true
        tempTingNum = tempTingNum - 2
    else
        --除去一个将对
        p2Num = p2Num - 1
    end

    --如果听用为负，说明不能组成大对子
    if tempTingNum < 0 or tempTingNum < p2Num then
        --LogError(">> MahjongTingHelper.CheckFanNumByDaDuiZi > tempTingNum < 0 or tempTingNum < p2Num")
        isDaDuiZi = false
    else
        --需要把指定2个的对子，用听用变成3个，且手上的牌，不能出现4个的，所以不需要用听用牌处理
        for i = 1, p2Num do
            for k, v in pairs(cardDicts) do
                if v.count == 2 then
                    tempTingNum = tempTingNum - 1
                    v.count = 3
                    break
                end
            end
        end

        local remainder = tempTingNum % 3
        if remainder ~= 0 then
            --听用牌不为3的倍数，说明听用过多不能组成大对子
            isDaDuiZi = false
            --LogError(">> MahjongTingHelper.CheckFanNumByDaDuiZi > TingNum Error")
        else
            --处理左边的牌，进行牌累加，好进行根处理
            local length = #this.leftCardDatas
            local temp = nil
            local tempLeftCardData = nil
            for i = 1, length do
                tempLeftCardData = this.leftCardDatas[i]
                temp = cardDicts[tempLeftCardData.key]
                if temp == nil then
                    temp = { count = 0 }
                    cardDicts[tempLeftCardData.key] = temp
                end
                if tempLeftCardData.isGang then
                    temp.count = temp.count + 4
                else
                    temp.count = temp.count + 3
                end
            end

            --纯听用牌，变牌
            length = tempTingNum / 3
            for i = 1, length do
                for k, v in pairs(cardDicts) do
                    if v.count < 4 then
                        v.count = v.count + 3
                        break
                    end
                end
            end

            --纯听用将对变牌，如果还有牌数为3的，就将纯听用的2个牌，变为指定的牌，来增加数量，便于统计根
            if isTingJiangDui then
                for k, v in pairs(cardDicts) do
                    if v.count < 4 then
                        v.count = v.count + 2
                        break
                    end
                end
            end
        end
    end
    if isDaDuiZi then
        --大对子+1番
        local fanNum = 1
        for k, v in pairs(cardDicts) do
            if v.count > 3 then
                fanNum = fanNum + 1
                --LogError(">> MahjongTingHelper.CheckFanNumByDaDuiZi > DaDuiZi + 1 > key = " .. k)
            end
        end
        return fanNum
    else
        --LogError(">> MahjongTingHelper.CheckFanNumByDaDuiZi > ==== Not DaDuiZi ====")
        return -1
    end
end
------------------------------------------------------------------
--
--检测手牌是否可以胡牌，无听用，handCardDatas是已经排序好了的
function MahjongTingHelper.CheckIsHu(handCardDatas)
    local handCardlength = #handCardDatas
    --
    --LogError(">> MahjongTingHelper.CheckIsHu >> ======== > Start > ", handCardDatas)
    --
    --普通牌检测，先处理将对，然后再判断剩余的是否为三三一坎
    local tempCardData1 = nil
    local tempCardData2 = nil
    local lastCardKey = 0
    local length = handCardlength - 1
    for i = 1, length do
        tempCardData1 = handCardDatas[i]

        --避免相同的再次检测
        if lastCardKey ~= tempCardData1.key then
            lastCardKey = tempCardData1.key

            tempCardData2 = handCardDatas[i + 1]
            if tempCardData1.key == tempCardData2.key then
                --
                --LogError(">> MahjongTingHelper.CheckIsHu > JaingDui Key = " .. tempCardData1.key)
                --
                --1、2牌一样，直接组合为将对
                if this.CheckIsHuBy3Card(tempCardData1.key) then
                    return true
                else
                    --LogError(">> MahjongTingHelper.CheckIsHu > Can Hu > jiangDuiKey = ", tempCardData1.key)
                end
            end
        end
    end
    return false
end

--找出3同牌和其余的牌进行检测
function MahjongTingHelper.CheckIsHuBy3Card(jiangDuiKey)
    local p3Cards = {}
    local surplusCards = {}
    local temp = nil
    for k, v in pairs(this.countDatas) do
        if k == jiangDuiKey then
            --把多余的牌放入剩余牌中
            for i = 3, v.num do
                table.insert(surplusCards, v.cards[i])
            end
        else
            if v.num > 2 then
                temp = MahjongTingData.New()
                temp.card1 = v.cards[1]
                temp.card2 = v.cards[2]
                temp.card3 = v.cards[3]
                table.insert(p3Cards, temp)
                --
                for i = 4, v.num do
                    table.insert(surplusCards, v.cards[i])
                end
            else
                for i = 1, v.num do
                    table.insert(surplusCards, v.cards[i])
                end
            end
        end
    end
    return this.CheckIsHuBy3CardLoop(p3Cards, surplusCards)
end

--递归检测是否为完整的组合牌，即三三为坎
function MahjongTingHelper.CheckIsHuBy3CardLoop(p3Cards, surplusCards)
    local shunziObjs = {}
    local singleCards = {}
    this.CheckOnlyShunZi(shunziObjs, singleCards, surplusCards)
    --没有单牌，就说明全部组成坎了
    if #singleCards == 0 then
        return true
    end

    local length = #p3Cards
    local temp = nil
    local newP3Cards = nil
    local newSurplusCards = nil
    for i = 1, length do
        newP3Cards = {}
        newSurplusCards = this.CopyCards(surplusCards)
        for j = 1, length do
            if i == j then
                temp = p3Cards[j]
                table.insert(newSurplusCards, temp.card1)
                table.insert(newSurplusCards, temp.card2)
                table.insert(newSurplusCards, temp.card3)
            else
                table.insert(newP3Cards, p3Cards[j])
            end
        end
        if this.CheckIsHuBy3CardLoop(newP3Cards, newSurplusCards) then
            return true
        end
    end
    return false
end

------------------------------------------------------------------
--检测无听用牌
function MahjongTingHelper.CheckFanNumByNoTing(leftCardDatas, handCardDatas)
    --LogError(">> MahjongTingHelper.CheckFanNumByNoTing > ======================== Start.")
    local cardData = nil
    --
    local countData = nil
    local countDatas = {}
    --
    local isExist19 = false
    --
    local length = #leftCardDatas
    for i = 1, length do
        cardData = leftCardDatas[i]
        countData = countDatas[cardData.key]
        if countData == nil then
            countData = { key = cardData.key, num = 0 }
            countDatas[cardData.key] = countData
        end
        if cardData.isGang then
            countData.num = countData.num + 4
        else
            countData.num = countData.num + 3
        end
    end
    --
    length = #handCardDatas
    for i = 1, length do
        cardData = handCardDatas[i]

        countData = countDatas[cardData.key]
        if countData == nil then
            countData = { key = cardData.key, num = 0 }
            countDatas[cardData.key] = countData
        end
        countData.num = countData.num + 1

        if cardData.num == 1 or cardData.num == 9 then
            isExist19 = true
        end
    end

    local fanNum = 0
    for k, v in pairs(countDatas) do
        if v.num > 3 then
            fanNum = fanNum + 1
        end
    end

    --检测中张
    if this.isCheckZhongZhang then
        if not this.isLeftExist19 and not isExist19 then
            fanNum = fanNum + 1
            --LogError(">> MahjongTingHelper.CheckFanNumByNoTing > ZhongZhan +1 Fan")
        end
    end

    --LogError(">> MahjongTingHelper.CheckFanNumByNoTing > ====================================== End.", fanNum)
    return fanNum
end

------------------------------------------------------------------
--检测带听用的牌型
function MahjongTingHelper.CheckFanNumByTing()
    --LogError(">> MahjongTingHelper.CheckFanNumByTing > Start.")
    --听用数量
    local tingNum = this.tingNum
    --3同集合
    local p3Cards = {}
    --3同之外的其他牌
    local otherCards = {}
    --找出3同
    local temp = nil
    for k, v in pairs(this.countDatas) do
        if v.num > 2 then
            temp = MahjongTingData.New()
            temp.card1 = v.cards[1]
            temp.card2 = v.cards[2]
            temp.card3 = v.cards[3]
            --
            table.insert(p3Cards, temp)
            --
            for i = 4, v.num do
                table.insert(otherCards, v.cards[i])
            end
        else
            for i = 1, v.num do
                table.insert(otherCards, v.cards[i])
            end
        end
    end
    --
    return this.CheckMaxFanNumBy3Card(tingNum, p3Cards, otherCards)
end


--通过处理3张检测最大的番数，即算根，听用变牌，要保证能胡牌
function MahjongTingHelper.CheckMaxFanNumBy3Card(tingNum, p3Cards, otherCards)
    --LogError(">> MahjongTingHelper.CheckMaxFanNumBy3Card > ======== > Start")
    --把3同坎牌全部剔除
    local maxFaxNum = -1
    local tempNum = this.CheckMaxFanNumByJiangDui(tingNum, p3Cards, otherCards)
    if tempNum > maxFaxNum then
        maxFaxNum = tempNum
    end

    local temp = nil
    local newP3Cards = nil
    local newOtherCards = nil
    local length = #p3Cards
    --剔除一个3同，最多3个，4个就是大对子了
    for i = 1, length do
        newP3Cards = {}
        newOtherCards = this.CopyCards(otherCards)
        for j = 1, length do
            --把剔除的3同还原到其他牌中
            if i == j then
                temp = p3Cards[j]
                table.insert(newOtherCards, temp.card1)
                table.insert(newOtherCards, temp.card2)
                table.insert(newOtherCards, temp.card3)
            else
                table.insert(newP3Cards, p3Cards[j])
            end
        end
        tempNum = this.CheckMaxFanNumBy3Card(tingNum, newP3Cards, newOtherCards)
        if tempNum > maxFaxNum then
            maxFaxNum = tempNum
        end
    end
    return maxFaxNum
end

--检测番数，处理所有将对可能，即把otherCards中的所有将对都考虑
function MahjongTingHelper.CheckMaxFanNumByJiangDui(tingNum, p3Cards, otherCards)
    local maxFanNum = -1

    --排序
    table.sort(otherCards, this.CardDataSort)

    local length = #otherCards
    local jiangDuiKey = 0
    local cardData = nil
    local nextCardData = nil
    local tempFanNum = 0
    local newOtherCards = nil
    local newTingNum = 0
    local tempLength = 0
    for i = 1, length do
        cardData = otherCards[i]
        if cardData.key ~= jiangDuiKey then
            jiangDuiKey = cardData.key
            --
            --LogError("<color=#FF0000> >> MahjongTingHelper.CheckMaxFanNumByJiangDui > JiangDuiKey = " .. jiangDuiKey .. "</color>")
            --
            --如果大于2个的，直接除去2个；如果只有一个，则除去一个加听用
            --
            --首先检测当前牌+听用作为将对
            newTingNum = tingNum - 1
            tempLength = i - 1
            newOtherCards = {}
            for j = 1, tempLength do
                table.insert(newOtherCards, otherCards[j])
            end
            for j = tempLength + 2, length do
                table.insert(newOtherCards, otherCards[j])
            end
            tempFanNum = this.CheckMaxFanNumByTing3Card(newTingNum, p3Cards, cardData, newOtherCards)
            if tempFanNum > maxFanNum then
                maxFanNum = tempFanNum
            end
            --
            --如果有2个牌，就检测2个牌作为将对
            nextCardData = otherCards[i + 1]
            if nextCardData ~= nil and jiangDuiKey == nextCardData.key then
                --表示有2个相同的，即可以除去2个
                newTingNum = tingNum
                tempLength = i - 1
                newOtherCards = {}
                for j = 1, tempLength do
                    table.insert(newOtherCards, otherCards[j])
                end
                for j = tempLength + 3, length do
                    table.insert(newOtherCards, otherCards[j])
                end
                tempFanNum = this.CheckMaxFanNumByTing3Card(newTingNum, p3Cards, cardData, newOtherCards)
                if tempFanNum > maxFanNum then
                    maxFanNum = tempFanNum
                end
            end
        end
    end
    return maxFanNum
end

--================================================================
--
--处理顺子坎牌，小到大
function MahjongTingHelper.CheckShunZiKanByStL(kanObjs, cards)
    --LogError(">> MahjongTingHelper.CheckShunZiKanByStL > ======== > cards > ", cards)
    local length = #cards
    local cardData = nil
    local num = 0
    local key = 0
    local kanObj = nil
    for i = 1, length do
        cardData = cards[i]
        if key == 0 then
            num = 1
            kanObj = {}
            key = cardData.key
            table.insert(kanObj, cardData)
        else
            if key ~= cardData.key then
                if key + 1 == cardData.key then
                    num = num + 1
                else
                    num = 1
                    kanObj = {}
                end
                key = cardData.key
                table.insert(kanObj, cardData)
            end
        end
        if num == 3 then
            break
        end
    end
    if num == 3 then
        --LogError(">> MahjongTingHelper.CheckShunZiKanByStL > ======== > -------- > yi kan.")
        for i = 1, 3 do
            cardData = kanObj[i]
            cardData.isUse = true
            --LogError(">> MahjongTingHelper.CheckShunZiKanByStL > cardData id =  " .. cardData.id)
        end
        local newCards = {}
        for i = 1, length do
            cardData = cards[i]
            if not cardData.isUse then
                table.insert(newCards, cardData)
            end
        end
        table.insert(kanObjs, kanObj)
        return this.CheckShunZiKanByStL(kanObjs, newCards)
    else
        return cards
    end
end

--处理顺子坎牌，大到小
function MahjongTingHelper.CheckShunZiKanByLtS(kanObjs, cards)
    --LogError(">> MahjongTingHelper.CheckShunZiKanByLtS > ======== > cards > ", cards)
    local length = #cards
    local cardData = nil
    local num = 0
    local key = 0
    local kanObj = nil
    local index = 0
    for i = 1, length do
        index = length + 1 - i
        cardData = cards[index]
        if key == 0 then
            num = 1
            kanObj = {}
            key = cardData.key
            table.insert(kanObj, cardData)
        else
            if key ~= cardData.key then
                if key - 1 == cardData.key then
                    num = num + 1
                else
                    num = 1
                    kanObj = {}
                end
                key = cardData.key
                table.insert(kanObj, cardData)
            end
        end
        if num == 3 then
            break
        end
    end
    if num == 3 then
        --LogError(">> MahjongTingHelper.CheckShunZiKanByLtS > ======== > -------- > yi kan.")
        for i = 1, 3 do
            cardData = kanObj[i]
            cardData.isUse = true
            --LogError(">> MahjongTingHelper.CheckShunZiKanByLtS > cardData id =  " .. cardData.id)
        end
        local newCards = {}
        for i = 1, length do
            cardData = cards[i]
            if not cardData.isUse then
                table.insert(newCards, cardData)
            end
        end
        table.insert(kanObjs, kanObj)
        return this.CheckShunZiKanByLtS(kanObjs, newCards)
    else
        return cards
    end
end

--================================================================
--
--通过处理听用3同（2+1），检测最大的番数，即算根，听用变牌，要保证能胡牌
function MahjongTingHelper.CheckMaxFanNumByTing3Card(tingNum, p3Cards, jiangDui, otherCards)
    --LogError(">> MahjongTingHelper.CheckMaxFanNumByTing3Card > ======== > Start >")
    local length = #this.handCardDatas
    for i = 1, length do
        this.handCardDatas[i].isUse = false
    end

    local duiZiObjs = {}
    local surplusCards = {}

    length = #otherCards
    local index = 1
    local cardData = nil
    local nextCardData = nil
    local temp = nil
    for i = 1, length do
        if index == i then
            cardData = otherCards[i]
            nextCardData = otherCards[i + 1]
            if nextCardData ~= nil and cardData.key == nextCardData.key then
                index = index + 2
                --把对子剔除
                temp = MahjongTingData.New()
                temp.card1 = cardData
                temp.card2 = nextCardData
                table.insert(duiZiObjs, temp)
            else
                index = index + 1
                table.insert(surplusCards, cardData)
            end
        end
    end

    return this.CheckRecursionByTing3Card(tingNum, p3Cards, jiangDui, duiZiObjs, surplusCards)
end

--递归处理
function MahjongTingHelper.CheckRecursionByTing3Card(tingNum, p3Cards, jiangDui, duiZiObjs, cards)
    --把2个的对子用作3同来处理直接检测
    local maxFanNum = this.CheckMaxFanNumByShunZi(tingNum, p3Cards, jiangDui, duiZiObjs, cards)

    local length = #duiZiObjs
    local tempFanNum = -1
    local tempDuiZiObjs = nil
    local tempCards = {}
    local temp = nil
    if length > 0 then
        for i = 1, length do
            tempDuiZiObjs = {}
            for j = 1, length do
                if i ~= j then
                    table.insert(tempDuiZiObjs, duiZiObjs[j])
                end
            end
            temp = duiZiObjs[i]
            tempCards = this.CopyCards(cards)
            table.insert(tempCards, temp.card1)
            table.insert(tempCards, temp.card2)

            tempFanNum = this.CheckRecursionByTing3Card(tingNum, p3Cards, jiangDui, tempDuiZiObjs, tempCards)
            if tempFanNum > maxFanNum then
                maxFanNum = tempFanNum
            end
        end
    end

    return maxFanNum
end

--把单牌进行组合检测
function MahjongTingHelper.CheckMaxFanNumByShunZi(tingNum, p3Cards, jiangDui, duiZiObjs, cards)
    local maxFanNum = -1
    local duiziLength = #duiZiObjs
    if duiziLength > tingNum then
        --听牌数量不够
        return maxFanNum
    end
    --
    local shunziObjs = {}
    local shunziTingObjs = {}
    local singleCards = {}
    this.CheckOnlyShunZiByTing(shunziObjs, shunziTingObjs, singleCards, cards)
    local shunziTingLength = #shunziTingObjs
    local singleLength = #singleCards
    if shunziTingLength + singleLength * 2 + duiziLength ~= tingNum then
        --听牌数量不够
        return maxFanNum
    end
    --
    local handCardDatas = {}
    local temp = nil
    --添加非听用3同
    for i = 1, #p3Cards do
        temp = p3Cards[i]
        table.insert(handCardDatas, temp.card1)
        table.insert(handCardDatas, temp.card2)
        table.insert(handCardDatas, temp.card3)
    end
    --添加听用3同
    for i = 1, #duiZiObjs do
        temp = duiZiObjs[i]
        table.insert(handCardDatas, temp.card1)
        table.insert(handCardDatas, temp.card2)
        table.insert(handCardDatas, temp.card2)
    end
    --添加将对
    table.insert(handCardDatas, jiangDui)
    table.insert(handCardDatas, jiangDui)
    --添加非听用顺子
    for i = 1, #shunziObjs do
        temp = shunziObjs[i]
        table.insert(handCardDatas, temp.card1)
        table.insert(handCardDatas, temp.card2)
        table.insert(handCardDatas, temp.card3)
    end
    maxFanNum = this.CheckMaxFanNumByShunziTing(handCardDatas, shunziTingObjs, singleCards)
    return maxFanNum
end

--================================================================
--
--只检测3个顺子
function MahjongTingHelper.CheckOnlyShunZi(shunziObjs, singleCards, cards)
    --
    --LogError(">> MahjongTingHelper.CheckOnlyShunZi > ======== > cards > ", cards)
    --
    local length = #cards
    for i = 1, length do
        cards[i].isUse = false
    end

    table.sort(cards, this.CardDataSort)

    local temp = nil
    local cardData = nil
    local cardData2 = nil
    local cardData3 = nil
    local key2 = 0
    local key3 = 0
    for i = 1, length do
        temp = cards[i]
        if temp.isUse == false then
            cardData = temp
            cardData2 = nil
            cardData3 = nil
            key2 = cardData.key + 1
            key3 = cardData.key + 2
            for j = i + 1, length do
                temp = cards[j]
                if temp.isUse == false and temp.key == key2 then
                    cardData2 = temp
                    break
                end
            end
            for j = i + 1, length do
                temp = cards[j]
                if temp.isUse == false and temp.key == key3 then
                    cardData3 = temp
                    break
                end
            end

            if cardData2 ~= nil and cardData3 ~= nil then
                --组成一个非听用顺子
                temp = MahjongTingData.New()
                temp.card1 = cardData
                temp.card2 = cardData2
                temp.card3 = cardData3
                cardData.isUse = true
                cardData2.isUse = true
                cardData3.isUse = true
                table.insert(shunziObjs, temp)
            end
        end
    end

    for i = 1, length do
        cardData = cards[i]
        if not cardData.isUse then
            table.insert(singleCards, cardData)
        end
    end
end

--只检测3个顺子和2个牌+听用的顺子组合，不处理2个的对牌
function MahjongTingHelper.CheckOnlyShunZiByTing(shunziObjs, shunziTingObjs, singleCards, cards)
    --
    --LogError(">> MahjongTingHelper.CheckOnlyTingShunZi > ======== > cards > ", cards)
    --
    local length = #cards
    for i = 1, length do
        cards[i].isUse = false
    end

    table.sort(cards, this.CardDataSort)

    local temp = nil
    local cardData = nil
    local cardData2 = nil
    local cardData3 = nil
    local key2 = 0
    local key3 = 0
    for i = 1, length do
        temp = cards[i]
        if temp.isUse == false then
            cardData = temp
            cardData2 = nil
            cardData3 = nil
            key2 = cardData.key + 1
            key3 = cardData.key + 2
            for j = i + 1, length do
                temp = cards[j]
                if temp.isUse == false and temp.key == key2 then
                    cardData2 = temp
                    break
                end
            end
            for j = i + 1, length do
                temp = cards[j]
                if temp.isUse == false and temp.key == key3 then
                    cardData3 = temp
                    break
                end
            end

            if cardData2 ~= nil and cardData3 ~= nil then
                --组成一个非听用顺子
                temp = MahjongTingData.New()
                temp.card1 = cardData
                temp.card2 = cardData2
                temp.card3 = cardData3
                cardData.isUse = true
                cardData2.isUse = true
                cardData3.isUse = true
                table.insert(shunziObjs, temp)
            elseif cardData2 ~= nil then
                --和2组成连续顺子
                temp = MahjongTingData.New()
                temp.type = 1
                temp.card1 = cardData
                temp.card2 = cardData2
                cardData.isUse = true
                cardData2.isUse = true
                table.insert(shunziTingObjs, temp)
            elseif cardData3 ~= nil then
                --组3组成卡顺子
                temp = MahjongTingData.New()
                temp.type = 2
                temp.card1 = cardData
                temp.card2 = cardData3
                cardData.isUse = true
                cardData3.isUse = true
                table.insert(shunziTingObjs, temp)
            end
        end
    end

    for i = 1, length do
        cardData = cards[i]
        if not cardData.isUse then
            table.insert(singleCards, cardData)
        end
    end
end


--检测番数，处理听用顺子成坎
function MahjongTingHelper.CheckMaxFanNumByShunziTing(handCardDatas, shuziTingObjs, singleCards)
    local length = #shuziTingObjs
    --
    --LogError(">> MahjongTingHelper.CheckMaxFanNumByShunziTing > -------- > tingKanObjs length = " .. length)
    --
    if length == 0 then
        return this.CheckMaxFanNumBySingleTing(handCardDatas, singleCards)
    else
        local tempObj = shuziTingObjs[1]
        local newTingKanObjs = {}
        for i = 2, length do
            table.insert(newTingKanObjs, shuziTingObjs[i])
        end

        local newHandCardDatas = nil
        local temp = nil
        local maxFanNum = -1
        local tempFanNum = -1
        if tempObj.type == 1 then
            --两个挨着，需要处理前后
            temp = this.keyMappingCardDatas[tempObj.card1.key - 1]
            if temp ~= nil then
                newHandCardDatas = this.CopyCards(handCardDatas)
                table.insert(newHandCardDatas, temp)
                table.insert(newHandCardDatas, tempObj.card1)
                table.insert(newHandCardDatas, tempObj.card2)
                tempFanNum = this.CheckMaxFanNumByShunziTing(newHandCardDatas, newTingKanObjs, singleCards)
                if tempFanNum > maxFanNum then
                    maxFanNum = tempFanNum
                end
            end
            temp = this.keyMappingCardDatas[tempObj.card2.key + 1]
            if temp ~= nil then
                newHandCardDatas = this.CopyCards(handCardDatas)
                table.insert(newHandCardDatas, tempObj.card1)
                table.insert(newHandCardDatas, tempObj.card2)
                table.insert(newHandCardDatas, temp)
                tempFanNum = this.CheckMaxFanNumByShunziTing(newHandCardDatas, newTingKanObjs, singleCards)
                if tempFanNum > maxFanNum then
                    maxFanNum = tempFanNum
                end
            end
        else
            --卡在中间
            temp = this.keyMappingCardDatas[tempObj.card1.key + 1]
            if temp ~= nil then
                newHandCardDatas = this.CopyCards(handCardDatas)
                table.insert(newHandCardDatas, tempObj.card1)
                table.insert(newHandCardDatas, temp)
                table.insert(newHandCardDatas, tempObj.card2)
                tempFanNum = this.CheckMaxFanNumByShunziTing(newHandCardDatas, newTingKanObjs, singleCards)
                if tempFanNum > maxFanNum then
                    maxFanNum = tempFanNum
                end
            end
        end
        return maxFanNum
    end
end

--检测番数，处理单牌听用成坎
function MahjongTingHelper.CheckMaxFanNumBySingleTing(handCardDatas, singleCards)
    local length = #singleCards
    --
    --LogError(">> MahjongTingHelper.CheckMaxFanNumBySingleTing > -------- > singleCards length = " .. length)
    --
    if length == 0 then
        return this.CheckFanNumByNoTing(this.leftCardDatas, handCardDatas)
    else
        local cardData = singleCards[1]
        local newSingleCards = {}
        for i = 2, length do
            table.insert(newSingleCards, singleCards[i])
        end

        local newHandCardDatas = nil
        local maxFanNum = -1
        local tempFanNum = -1
        --当最左，需要判断+2
        if cardData.num + 2 < 10 then
            newHandCardDatas = this.CopyCards(handCardDatas)
            table.insert(newHandCardDatas, cardData)
            table.insert(newHandCardDatas, this.keyMappingCardDatas[cardData.key + 1])
            table.insert(newHandCardDatas, this.keyMappingCardDatas[cardData.key + 2])
            tempFanNum = this.CheckMaxFanNumBySingleTing(newHandCardDatas, newSingleCards)
            if tempFanNum > maxFanNum then
                maxFanNum = tempFanNum
            end
        end

        --当中间，需要判断-1，+1
        if cardData.type == MahjongColorType.Tiao then
            if cardData.num - 1 > 1 and cardData.num + 1 < 10 then
                newHandCardDatas = this.CopyCards(handCardDatas)
                table.insert(newHandCardDatas, this.keyMappingCardDatas[cardData.key - 1])
                table.insert(newHandCardDatas, cardData)
                table.insert(newHandCardDatas, this.keyMappingCardDatas[cardData.key + 1])
                tempFanNum = this.CheckMaxFanNumBySingleTing(newHandCardDatas, newSingleCards)
                if tempFanNum > maxFanNum then
                    maxFanNum = tempFanNum
                end
            end
        else
            if cardData.num - 1 > 0 and cardData.num + 1 < 10 then
                newHandCardDatas = this.CopyCards(handCardDatas)
                table.insert(newHandCardDatas, this.keyMappingCardDatas[cardData.key - 1])
                table.insert(newHandCardDatas, cardData)
                table.insert(newHandCardDatas, this.keyMappingCardDatas[cardData.key + 1])
                tempFanNum = this.CheckMaxFanNumBySingleTing(newHandCardDatas, newSingleCards)
                if tempFanNum > maxFanNum then
                    maxFanNum = tempFanNum
                end
            end
        end
        --当最右，需要判断-2
        if cardData.type == MahjongColorType.Tiao then
            if cardData.num - 2 > 1 then
                newHandCardDatas = this.CopyCards(handCardDatas)
                table.insert(newHandCardDatas, this.keyMappingCardDatas[cardData.key - 2])
                table.insert(newHandCardDatas, this.keyMappingCardDatas[cardData.key - 1])
                table.insert(newHandCardDatas, cardData)
                tempFanNum = this.CheckMaxFanNumBySingleTing(newHandCardDatas, newSingleCards)
                if tempFanNum > maxFanNum then
                    maxFanNum = tempFanNum
                end
            end
        else
            if cardData.num - 2 > 0 then
                newHandCardDatas = this.CopyCards(handCardDatas)
                table.insert(newHandCardDatas, this.keyMappingCardDatas[cardData.key - 2])
                table.insert(newHandCardDatas, this.keyMappingCardDatas[cardData.key - 1])
                table.insert(newHandCardDatas, cardData)
                tempFanNum = this.CheckMaxFanNumBySingleTing(newHandCardDatas, newSingleCards)
                if tempFanNum > maxFanNum then
                    maxFanNum = tempFanNum
                end
            end
        end
        --3同
        newHandCardDatas = this.CopyCards(handCardDatas)
        table.insert(newHandCardDatas, cardData)
        table.insert(newHandCardDatas, cardData)
        table.insert(newHandCardDatas, cardData)
        tempFanNum = this.CheckMaxFanNumBySingleTing(newHandCardDatas, newSingleCards)
        if tempFanNum > maxFanNum then
            maxFanNum = tempFanNum
        end

        return maxFanNum
    end
end