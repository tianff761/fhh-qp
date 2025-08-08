PdkSelfHandCardCtrl = ClassLuaComponent("PdkSelfHandCardCtrl")
local this = PdkSelfHandCardCtrl
PdkSelfHandCardCtrl.handPokers = {} --手牌
PdkSelfHandCardCtrl.handCardPrefab = nil --手牌预制体

PdkSelfHandCardCtrl.radian = 1.4 --角度
PdkSelfHandCardCtrl.height = 3 --牌的落差
PdkSelfHandCardCtrl.maxCount = 16
PdkSelfHandCardCtrl.curCardIndex = -1

PdkSelfHandCardCtrl.updateLayoutTime = 0.3

function PdkSelfHandCardCtrl:Awake()
    this = self
    -- this.transform = self.transform
    this.handCardPrefab = self.transform:Find("Card")
end

--发牌
function PdkSelfHandCardCtrl.DealCard(list)
    local length = GetTableSize(list)
    if length <= 0 then
        LogError("玩家手牌为空:", list)
        return
    end
    local poker = nil
    local mid = math.ceil(length / 2)
    local curRadian = (this.maxCount * this.radian - (this.radian / 2) * (this.maxCount - length)) / length
    if curRadian > 2.8 then
        curRadian = 2.8
    end
    local startValue = (length - 1) / 2 * curRadian
    PdkAudioCtrl.PlayDealCard()
    for i = 1, length do
        -- poker = CreateGO(this.handCardPrefab, this.transform, list[i])
        poker = PdkResourcesCtrl.GetPoker(PdkPrefabName.SelfHandPoker, this.transform)
        -- local comp = AddLuaComponent(poker, "PdkHandCard")
        local comp = GetLuaComponent(poker, "PdkHandCard")
        if IsNil(comp) then
            comp = AddLuaComponent(poker, "PdkHandCard")
        end
        comp:Init(list[i], i)
        table.insert(this.handPokers, comp)
        --设置初始位置
        UIUtil.SetLocalPosition(comp.rectTransform, -100 + (1 + i), -2100 + (1 - i), 0)
        UIUtil.SetLocalPosition(comp.rectTransform, comp.rectTransform.position.x + (1 + i), comp.rectTransform.position.y + (1 - i), 0)
        --local posY = -2500
        --if i < mid then
        --    posY = -2500 - (mid - i) * this.height
        --elseif i > mid + 1 then
        --    posY = -2500 - (i - mid - 1) * this.height
        --end
        --local move = comp.transform:DOLocalMove(Vector3(0, posY, 0), 0.05, false)

        local move = comp.transform:DOLocalMove(Vector3(this.GetLocalPosX(i, mid), -2500, 0), 0.05, false)
        local value = startValue - (i - 1) * curRadian
        --local rotate = comp.transform:DOLocalRotate(Vector3(0, 0, value), 0.05, DG.Tweening.RotateMode.Fast)
        move:SetId(comp.transform)
        --rotate:SetDelay(i * 0.04)
        move:SetDelay(i * 0.04)
        if i == length then
            move:OnComplete(
                    function()
                        if PdkRoomModule.isSeePoker then
                            this.ShowPoker()
                        end
                        SendMsg(CMD.Game.Pdk.DealCardEnd)
                    end
            )
        end
    end
end

function PdkSelfHandCardCtrl.GetLocalPosX(i, mid)
    local offsetX = 60
    local posX = -60
    posX = (i - mid) * offsetX
    return posX
end

--翻转扑克
function PdkSelfHandCardCtrl.ShowPoker()
    PdkAudioCtrl.PlayShowCard()
    local length = #this.handPokers
    for i = 1, length do
        local comp = this.handPokers[i]
        local tween = comp.pokerImage.transform:DOLocalRotate(Vector3(0, 180, 0), 0.1, DG.Tweening.RotateMode.Fast)
        tween:SetId(comp.pokerImage.transform)
        tween:SetDelay(i * 0.05)
        if i == length then
            tween:OnComplete(
                    function()
                        -- UIUtil.SetRotation(comp.pokerImage.transform,0,0,comp.pokerImage.transform.rotation.z)
                        comp.pokerImage.transform:DOLocalRotate(Vector3(0, 360, 0), 0.1, DG.Tweening.RotateMode.Fast)
                        comp:SetSprite(comp.value)
                        comp:SetIsClick(true)
                    end
            )
        else
            tween:OnComplete(
                    function()
                        comp.pokerImage.transform:DOLocalRotate(Vector3(0, 360, 0), 0.1, DG.Tweening.RotateMode.Fast)
                        -- UIUtil.SetRotation(comp.pokerImage.transform,0,0,comp.pokerImage.transform.rotation.z)
                        comp:SetSprite(comp.value)
                        comp:SetIsClick(true)
                    end
            )
        end
    end
end

--初始化手上的牌 生成手牌
function PdkSelfHandCardCtrl.CreateHandPoker(list)
    local poker = nil
    for i = 1, #list do
        -- poker = CreateGO(this.handCardPrefab, this.transform, list[i])
        -- local comp = AddLuaComponent(poker, "PdkHandCard")
        poker = PdkResourcesCtrl.GetPoker(PdkPrefabName.SelfHandPoker, this.transform)
        local comp = GetLuaComponent(poker, "PdkHandCard")
        if IsNil(comp) then
            comp = AddLuaComponent(poker, "PdkHandCard")
        end
        comp:Init(list[i], i)
        if PdkRoomModule.isSeePoker then
            comp:SetSprite(list[i])
        end
        comp:SetIsClick(true)
        table.insert(this.handPokers, comp)
    end
    this.UpdateCtrl(false)
end

--更新布局
function PdkSelfHandCardCtrl.UpdateCtrl(isAnim)
    local length = this.GetHandPokerCount()
    local mid = math.ceil(length / 2)
    local curRadian = (this.maxCount * this.radian - (this.radian / 2) * (this.maxCount - length)) / length
    if curRadian > 2.4 then
        curRadian = 2.4
    end
    local startValue = (length - 1) / 2 * curRadian
    local comp = nil
    for i = 1, length do
        comp = this.handPokers[i]
        comp.transform:DOKill()
        -- UIUtil.SetLocalPosition(comp.rectTransform, 0, -2500, 0)
        --local posY = -2500
        --if i < mid then
        --    posY = -2500 - (mid - i) * this.height
        --elseif i > mid + 1 then
        --    posY = -2500 - (i - mid - 1) * this.height
        --end
        --local value = startValue - (i - 1) * curRadian
        if isAnim then
            --LogError("<color=aqua>1111111111111</color>")
            local move = comp.transform:DOLocalMove(Vector3(this.GetLocalPosX(i, mid), -2500, 0), this.updateLayoutTime, false)
            --local rotate = comp.transform:DOLocalRotate(Vector3(0, 0, value), this.updateLayoutTime, DG.Tweening.RotateMode.Fast)
        else
            UIUtil.SetLocalPosition(comp.transform, this.GetLocalPosX(i, mid), -2500, 0)
            --UIUtil.SetLocalPosition(comp.transform, 0, posY, 0)
            --UIUtil.SetRotation(comp.transform, 0, 0, value)
            --UIUtil.SetRotation(comp.transform, 0, 0, 0)
        end
        comp:SetIndex(i)
    end
end

--进入某张牌时
function PdkSelfHandCardCtrl.OnClickEnter(index)
    if PdkRoomModule.isPlayback then
        return
    end
    if this.curCardIndex ~= -1 then
        this.CheckPokerStatus(index)
    end
end

--点击某张牌时
function PdkSelfHandCardCtrl.OnClickDown(index)
    if PdkRoomModule.isPlayback then
        return
    end
    this.curCardIndex = index
    this.handPokers[index]:SetIsSelect(true)
end

--鼠标抬起时
function PdkSelfHandCardCtrl.OnClickUp()
    if PdkRoomModule.isPlayback then
        return
    end
    this.HandleUpCards()
    -- this.CheckUpCards()
    -- this.curCardIndex = -1
    -- PdkAudioCtrl.PlaySelectCard()
end

--检测扑克的状态
function PdkSelfHandCardCtrl.CheckPokerStatus(index)
    local isLeft = index > this.curCardIndex
    for i = 1, #this.handPokers do
        this.ChangePokerStatus(this.handPokers[i], false)
    end
    local max = Functions.TernaryOperator(isLeft, index, this.curCardIndex)
    local min = Functions.TernaryOperator(isLeft, this.curCardIndex, index)
    for i = min, max do
        this.ChangePokerStatus(this.handPokers[i], true)
    end
end

--改变扑克的状态
function PdkSelfHandCardCtrl.ChangePokerStatus(poker, isSelect)
    if not IsNil(poker) then
        poker:SetIsSelect(isSelect)
        poker:ChangePokerColor()
    end
end

--检测是否弹起
function PdkSelfHandCardCtrl.CheckUpCards()
    local comp = nil
    for i = 1, #this.handPokers do
        comp = this.handPokers[i]
        if comp.isSelect then
            comp:SetPokerPosY()
        end
        this.ChangePokerStatus(comp, false)
    end
end

--获取所有弹起的牌
function PdkSelfHandCardCtrl.GetAllUpPoker()
    local pokers = {}
    local comp = nil
    for i = 1, #this.handPokers do
        comp = this.handPokers[i]
        if comp.isUp then
            table.insert(pokers, comp)
        end
    end
    return pokers
end

--获取所有手牌的ID
function PdkSelfHandCardCtrl.GetAllPokerId()
    local pokers = {}
    local comp = nil
    for i = 1, #this.handPokers do
        comp = this.handPokers[i]
        table.insert(pokers, comp.value)
    end
    return pokers
end

--弹起扑克
function PdkSelfHandCardCtrl.UpHandPokers(pokers)
    local comp = nil
    for i = 1, #this.handPokers do
        comp = this.handPokers[i]
        for j = 1, #pokers do
            if comp.value == pokers[j] then
                comp:UpPoker(false)
            end
        end
    end
end

--放下所有扑克
function PdkSelfHandCardCtrl.DownHandPokers()
    for i = 1, #this.handPokers do
        this.handPokers[i]:DownPoker(false)
    end
end

--获取手上的牌
function PdkSelfHandCardCtrl.GetHandPokers()
    -- local pokers = {}
    -- for i = 1,#this.handPokers do
    --     table.insert(pokers, this.handPokers[i].value)
    -- end
    return this.handPokers
end

--打出去的牌
function PdkSelfHandCardCtrl.OutPoker(list, parent)
    UIUtil.SetLocalScale(parent, 1, 1, 1)
    UIUtil.SetLocalPosition(parent, this.transform.localPosition.x, this.transform.localPosition.y, 0)
    local pokers = {}
    local poker = nil
    for i = 1, #list do
        poker = this.RemovePoker(list[i])
        if poker ~= nil then
            poker:UpPoker(false)
            table.insert(pokers, poker)
        end
        -- PdkResourcesCtrl.PutHandPoker(poker.transform.gameObject)
    end

    local length = GetTableSize(pokers)
    local curRadian = (this.maxCount * this.radian - (this.radian / 2) * (this.maxCount - length)) / length
    if curRadian > 1.5 then
        curRadian = 1.5
    end
    local startValue = (length - 1) / 2 * curRadian
    local comp = nil
    for i = 1, length do
        comp = pokers[i]
        UIUtil.SetLocalPosition(comp.rectTransform, 0, -2500, 0)
        comp.transform:SetParent(parent)
        comp:SetIsClick(false)
        comp:ChangePokerStatus(false)
        local value = startValue - (i - 1) * curRadian
        local rotate = comp.transform:DOLocalRotate(Vector3(0, 0, value), 0.3, DG.Tweening.RotateMode.Fast)
    end
    parent:DOLocalMove(Vector3(0, 50, 0), 0.3, false)
    local scale = parent:DOScale(Vector3(0.58, 0.58, 0), 0.3)
end

--获取打出去的牌
function PdkSelfHandCardCtrl.GetOutPokerId(list)
    local pokers = {}
    local comp = nil
    for i = 1, #list do
        for j = 1, #this.handPokers do
            comp = this.handPokers[j]
            if list[i] == comp.value then
                table.insert(pokers, comp.value)
                break
            end
        end
    end
    return pokers
end

--验证服务器发的打牌手上是否有
function PdkSelfHandCardCtrl.VerificationIsHave(list)
    local pokers = this.GetOutPokerId(list)
    PdkPokerLogic.SortIdsJiangXu(list)
    PdkPokerLogic.SortIdsJiangXu(pokers)
    local isEqual = true
    if GetTableSize(list) ~= GetTableSize(pokers) then
        isEqual = false
    else
        for idx, id in pairs(list) do
            if pokers[idx] ~= id then
                isEqual = false
                break
            end
        end
    end
    return isEqual
end

--根据牌的id移除一张牌
function PdkSelfHandCardCtrl.RemovePoker(poker)
    local comp = nil
    for i = 1, #this.handPokers do
        local comp = this.handPokers[i]
        if poker == comp.value then
            table.remove(this.handPokers, i)
            return comp
        end
    end
    return nil
end

--验证自己的手牌
function PdkSelfHandCardCtrl.SyscPdkCards(ids)
    local pokers = this.GetAllPokerId()

    local isEqual = true
    PdkPokerLogic.SortIdsJiangXu(ids)
    PdkPokerLogic.SortIdsJiangXu(pokers)
    if GetTableSize(ids) ~= GetTableSize(pokers) then
        isEqual = false
    else
        for idx, id in pairs(ids) do
            if pokers[idx] ~= id then
                isEqual = false
                break
            end
        end
    end
    Log("同步跑得快牌，本地牌：", ObjToJson(pokers), " 服务器牌：", ObjToJson(ids), " ", isEqual)

    if not isEqual then
        this.Clear()
        this.CreateHandPoker(ids)
    end
end

--获取手牌数量
function PdkSelfHandCardCtrl.GetHandPokerCount()
    return GetTableSize(this.handPokers)
end

--是否是最大的单牌
function PdkSelfHandCardCtrl.IsSelfMaxSinglePoker(value)
    return PdkPokerLogic.GetIdWeight(value) == this.handPokers[1].weight
end

--清空所有手牌
function PdkSelfHandCardCtrl.Clear()
    for i = 1, #this.handPokers do
        -- destroy(this.handPokers[i].gameObject)
        -- PdkResourcesCtrl.PutHandPoker(this.handPokers[i].transform.gameObject)
        PdkResourcesCtrl.PutPoker(this.handPokers[i].transform.gameObject)
    end
    this.handPokers = {}
end


--新需求 当玩家连续滑动5张牌以及5张以上时会帮玩家自动筛选出顺子牌或者连对牌
function PdkSelfHandCardCtrl.HandleUpCards()
    local comp = nil
    local num = 0
    local selectCards = {}
    for i = 1, #this.handPokers do
        comp = this.handPokers[i]
        if comp.isSelect then
            num = num + 1
            table.insert(selectCards, comp.value)
        end
    end
    if num >= 5 then
        table.sort(selectCards, function(a, b)
            return a < b
        end)

        local result = this.isConsecutivePairs(selectCards)
        if result ~= nil and (#result % 2 ~= 0 or #result < 4) then
            result = this.CheckUpCardsSun(selectCards)
            if #result < 3 then
                result = {}
            end
        end

        -- local result = this.CheckUpCardsSun(selectCards)
        -- if #result < 3 then
        --     result = this.isConsecutivePairs(selectCards)
        --     if #result % 2 ~= 0 or #result < 4 then
        --         result = {}
        --     end
        -- end
        if result ~= nil and #result > 0 then
            local isHave = false
            for i = 1, #this.handPokers do
                comp = this.handPokers[i]
                isHave = false
                if comp.isSelect then
                    for _, value in pairs(result) do
                        if value == comp.value then
                            isHave = true
                            break
                        end
                    end
                end
                if not isHave then
                    comp:ChangePokerStatus(false)
                end
            end
        end
    end
    this.CheckUpCards()
    this.curCardIndex = -1
    PdkAudioCtrl.PlaySelectCard()
end

--检测是否为顺子
function PdkSelfHandCardCtrl.CheckUpCardsSun(cards)
    cards = cards or {}
    local count = GetTableSize(cards)
    local validSequences = {}
    local currentSequence = {cards[1]}
    local current = math.floor(currentSequence[1] / 10)
    for i = 2, count do
        if math.floor(cards[i] / 10) == 20 then
            current = current + 1
            table.insert(currentSequence, cards[i])
        elseif math.floor(cards[i] / 10) == current + 1 then -- 检查是否连续
            current = current + 1
            table.insert(currentSequence, cards[i])
            if #currentSequence >= 3 and #currentSequence > #validSequences then -- 当达到3张或以上时记录
                validSequences = currentSequence
            end
        elseif math.floor(cards[i] / 10) ~= current then -- 如果不连续且不是重复值，则重置
            currentSequence = {cards[i]}
            current = math.floor(cards[i] / 10)
        end
    end
    
    return validSequences
end

-- 检查连续的连对
function PdkSelfHandCardCtrl.isConsecutivePairs(cards)
    cards = cards or {}
    
    local longestPairs = {}
    local currentPair = {}
    local lastCard = 0
    local wildCount = 0
    local temp = 0

    local wild = {}
    for _, card in ipairs(cards) do
        if math.floor(card / 10) == 20 then
            wildCount = wildCount + 1
            table.insert(currentPair, card)
            table.insert(wild, card)
        elseif math.floor(card / 10) == math.floor(lastCard / 10) then
            table.insert(currentPair, card)
            --如果有3张一样的就不管了
            if #currentPair >= 3 then
                return nil
            end
            if #currentPair == 2 and (temp == 0 or temp + 1 == math.floor(card / 10)) then
                temp = math.floor(card / 10)
                for i = 1, 2 do
                    table.insert(longestPairs, currentPair[i])
                end
                --currentPair = {card} -- 重置当前对
            end
        else
            if math.floor(lastCard / 10) + 1 ~= math.floor(card / 10) then
                if #longestPairs < 4 then
                    longestPairs = {}
                else
                    return longestPairs
                end
            end
            currentPair = {card}
            wildCount = 0
        end
        lastCard = card
    end
    
    -- 使用大小王填补空缺
    if #longestPairs >= 2 and wildCount > 0 then
        for i = 1, wild do
            table.insert(longestPairs, wild[i])
        end
    end
    
    return longestPairs
end
