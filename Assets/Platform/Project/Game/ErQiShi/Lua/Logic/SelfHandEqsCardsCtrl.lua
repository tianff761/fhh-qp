-- 自己的贰柒拾手牌控制
SelfHandEqsCardsCtrl = ClassLuaComponent("SelfHandEqsCardsCtrl")
SelfHandEqsCardsCtrl.draggable = false
local this = SelfHandEqsCardsCtrl
this.lines = {} -- 所有的列： 10列
this.cells = {} -- 所有牌放置格子：10列，每列4个    24:第二行第4列
this.tableCards = nil -- 所有的牌对象 EqsCard
this.allCardsPos = {}
--是否是小家
this.isXiaoJia = false
this.xiaoJiaCard1Pos = nil
this.xiaoJiaCard2Pos = nil
this.xiaoJiaCardMoPaiPos = nil
this.isFaPaiing = false
this.isClickedCard = false
this.tempIds = {}
this.isSyscByTempIds = false

function SelfHandEqsCardsCtrl:Awake()
    this = self
end

function SelfHandEqsCardsCtrl.PrintAllCards()
  
end

local lastSyscTime = 0
-- gFpPos：发牌时的起始位置
function SelfHandEqsCardsCtrl:Init(gFpPos)
    this.gFpPos = gFpPos
    this.InitPos()
    Scheduler.unscheduleGlobal(this.checkSchedule)
    this.checkSchedule = Scheduler.scheduleGlobal(function ()
        if BattleModule.isPlayback then
            return 
        end
        if os.time() - lastSyscTime > 3 then
            lastSyscTime = os.time()
            if not BattleModule.isPerform772 and not this.isFaPaiing and not this.isClickedCard and this.isSyscByTempIds then
                this.CheckCardsByTempIds()
            end
        end
        --Log("Check Card:", this.tempIds ,BattleModule.isPerform772, this.isFaPaiing, this.isClickedCard,  this.isSyscByTempIds)
    end, 1)
end

function SelfHandEqsCardsCtrl.Reset()
    Scheduler.unscheduleGlobal(this.checkSchedule)
end

--是否通过缓存牌同步本地牌
function SelfHandEqsCardsCtrl.SetIsSyscByTempIds(is)
    this.isSyscByTempIds = is
end

function SelfHandEqsCardsCtrl.SetTempIds(ids)
    --Log("设置缓存牌：", ids)
    if IsTable(ids) then
        this.tempIds = ids
    end
end

local handle = nil
function SelfHandEqsCardsCtrl.CheckCardsByTempIds()
    if GetTableSize(this.tempIds) > 0 then
        this.SetDraggable(false, 0.1)
        this.CheckAndSyncCards(this.tempIds)
    end
end

function SelfHandEqsCardsCtrl.InitPos()
    for i = 1, 10 do
        this.lines[i] = this.transform:Find("Line" .. tostring(i)):GetComponent("RectTransform")
        this.lines[i].gameObject:SetActive(true)
        this.cells[i * 10 + 1] = this.lines[i]:Find("Cell1"):GetComponent("RectTransform")
        this.cells[i * 10 + 2] = this.lines[i]:Find("Cell2"):GetComponent("RectTransform")
        this.cells[i * 10 + 3] = this.lines[i]:Find("Cell3"):GetComponent("RectTransform")
        this.cells[i * 10 + 4] = this.lines[i]:Find("Cell4"):GetComponent("RectTransform")
    end

    this.xiaoJiaCard1Pos = this.transform:Find('XiaoJiaCards/Card1Pos')
    this.xiaoJiaCard2Pos = this.transform:Find('XiaoJiaCards/Card2Pos')
    this.xiaoJiaCardMoPaiPos = this.transform:Find('XiaoJiaCards/CardMoPai')
end

-- 添加发牌  tableCards：EqsCard数组, bFpMode:是否以发牌模式添加(以发牌模式添加时，执行发牌动画)
function SelfHandEqsCardsCtrl.AddCards(tableCards, forceNotAnim)
    this.isFaPaiing = true
    Scheduler.scheduleOnceGlobal(function ()
        this.isFaPaiing = false
    end, 4)
    this.SetDraggable(false, 0.9)
    SelfHandEqsCardsCtrl.RecycleAllCards()
    this.InitLocalPos()
    Log("位置信息:", this.allCardsPos, tableCards)
    local allCardsHasPos = GetTableSize(this.allCardsPos) == GetTableSize(tableCards)
    Log("张数不一致", allCardsHasPos)
    if allCardsHasPos then
        for _, card in pairs(tableCards) do
            local pos = this.GetLocalPos(card:GetUid())
            if pos ~= nil then
                card:SetLocation(pos.x, pos.y)
            else
                allCardsHasPos = false
                Log("不一致", card)
                break
            end
        end
    end

    table.sort(
    tableCards,
    function(card1, card2)
        return card1:GetUid() < card2:GetUid()
    end
    )
    local str = ""
    for k, v in pairs(tableCards) do
        str = str .. tostring(v:GetUid()) .. ","
    end
   -- Log("SelfHandEqsCardsCtrl.AddCards======》", str, UserData.IsReconnect())

   --发牌模式
    local faPaiMode = not allCardsHasPos
    --发牌是否执行动画
    local isFaPaiAnim = true
    if IsBool(forceNotAnim) and forceNotAnim == true then
        isFaPaiAnim = false
    end
    if UserData.IsReconnect() then
        isFaPaiAnim = false
    end
    --播放发牌声音
    if faPaiMode and not BattleModule.isPlayback then
        if isFaPaiAnim then
            if #tableCards == 2 then
                EqsSoundManager.PlayAudio(EqsAudioNames.FaPai2)
            elseif #tableCards == 14 or #tableCards == 15 then
                EqsSoundManager.PlayAudio(EqsAudioNames.FaPai14)
            elseif #tableCards >= 20 then
                EqsSoundManager.PlayAudio(EqsAudioNames.FaPai20)
            end
        end
    end

    local lists = this.CalcuLines(tableCards)
    local lineNum = GetTableSize(lists)
    if faPaiMode then
        Log("=======>发牌")
        this.ClearAllLocalPos()
        --小家(庄家后家)必定只有两张牌
        if this.isXiaoJia then
            local eqsCard1 = tableCards[1]
            local eqsCard2 = tableCards[2]
            eqsCard1:SetParent(this.xiaoJiaCard1Pos)
            eqsCard1:SetLocation(1, 1)
            eqsCard1.transform.localRotation = UnityEngine.Quaternion.Euler(0, 0, 0)

            eqsCard2:SetParent(this.xiaoJiaCard2Pos)
            eqsCard2:SetLocation(2, 2)
            eqsCard2.transform.localRotation = UnityEngine.Quaternion.Euler(0, 0, 0)

            local moveTime = 0.25
            if BattleModule.isPlayback then
                moveTime = 0
            end
            Scheduler.scheduleOnceGlobal(
            function()
                eqsCard1.transform.position = this.gFpPos
                eqsCard1.transform.localRotation = UnityEngine.Quaternion.Euler(0, 0, -90)
                eqsCard1.transform:DOLocalMove(Vector3.zero, moveTime, false)
                eqsCard1.transform:DOLocalRotate(Vector3.zero, moveTime, DG.Tweening.RotateMode.Fast)
                eqsCard1.transform.localScale = Vector3(0.4, 0.4, 0.4)
                eqsCard1.transform:DOScale(Vector3(1, 1, 1), moveTime)
            end,
            EqsTools.GetTime(0.1)
            )

            Scheduler.scheduleOnceGlobal(
            function()
                eqsCard2.transform.position = this.gFpPos
                eqsCard2.transform.localRotation = UnityEngine.Quaternion.Euler(0, 0, -90)
                eqsCard2.transform:DOLocalMove(Vector3.zero, moveTime, false)
                eqsCard2.transform:DOLocalRotate(Vector3.zero, moveTime, DG.Tweening.RotateMode.Fast)
                eqsCard2.transform.localScale = Vector3(0.4, 0.4, 0.4)
                eqsCard2.transform:DOScale(Vector3(1, 1, 1), moveTime)
            end,
            EqsTools.GetTime(0.16)
            )
        else--非小家
            local line = 1
            for _, list in pairs(lists) do
                local rowidx = 1
                for _, card in pairs(list) do
                    this.AddCardToCell(card, line, rowidx, false, faPaiMode)
                    rowidx = rowidx + 1
                    card:SetGunVisible(false)
                end
                line = line + 1

                local id = list[1]:GetId()
                if #list == 4 and id == list[2]:GetId() and id == list[3]:GetId() and id == list[4]:GetId() then
                    list[1]:SetGunVisible(true)
                end
            end

            --执行牌动画
            local moveTime = EqsTools.GetTime(0.2)
            local interval = EqsTools.GetTime(0.03)
            if BattleModule.isPlayback or not isFaPaiAnim then
                moveTime = 0
                interval = 0
            end
            Log(">>>>>>>>>>>总行数：", #lists, "  开始行数：", line, moveTime, interval)

            for i, tableCard in pairs(tableCards) do
                local card = tableCard
                Scheduler.scheduleOnceGlobal(
                function()
                    card.transform.position = this.gFpPos
                    card.transform.localRotation = Quaternion.Euler(0, 0, -90)
                    if BattleModule.isPlayback or not isFaPaiAnim  then
                        card.transform.localPosition = Vector3.zero
                        card.transform.localRotation = Quaternion.Euler(0,0,0)
                    else
                        local tween = card.transform:DOLocalMove(Vector3.zero, moveTime, false)
                        tween:SetEase(DG.Tweening.Ease.Linear)
                        tween = card.transform:DOLocalRotate(Vector3.zero, moveTime, DG.Tweening.RotateMode.Fast)
                        tween:SetEase(DG.Tweening.Ease.Linear) 
                    end
                end,
                EqsTools.GetTime(i * interval)
                )
            end

            if BattleModule.isPlayback then
                this.SetQuanTag()
                SelfHandEqsCardsCtrl.DealLinesMove()
            else
                Scheduler.scheduleOnceGlobal(function()
                    SelfHandEqsCardsCtrl.DealLinesMove()
                end, 1)
            end
        end
    else
        if this.isXiaoJia then
            local eqsCard1 = tableCards[1]
            local eqsCard2 = tableCards[2]
            eqsCard1:SetParent(this.xiaoJiaCard1Pos)
            eqsCard1:SetLocation(1, 1)
            eqsCard1.transform.localRotation = UnityEngine.Quaternion.Euler(0, 0, 0)
            eqsCard1.transform.localPosition = Vector3.zero

            eqsCard2:SetParent(this.xiaoJiaCard2Pos)
            eqsCard2:SetLocation(1, 1)
            eqsCard2.transform.localRotation = UnityEngine.Quaternion.Euler(0, 0, 0)
            eqsCard2.transform.localPosition = Vector3.zero
        else
            Log("=======>按照缓存初始化牌位置")
            for _, card in pairs(tableCards) do
                local pos = card:GetLocation()
                this.AddCardToCell(card, pos.x, pos.y, false, false)
                card:SetGunVisible(false)
            end
            --设置磙
            for i = 1, 10 do
                local num = this.GetLineCardNum(i)
                if num == 4 then
                    local card1 = this.GetEqsCard(i, 1)
                    local card2 = this.GetEqsCard(i, 2)
                    local card3 = this.GetEqsCard(i, 3)
                    local card4 = this.GetEqsCard(i, 4)
                    if card1 ~= nil and card2 ~= nil and card3 ~= nil and card4 ~= nil then
                        local id = card1:GetId()
                        if id == card2:GetId() and id == card3:GetId() and id == card4:GetId() then
                            card1:SetGunVisible(true)
                        end
                    end
                end
            end
            this.SetQuanTag()
        end
    end
end

-- eqsCard：牌对象    line：列 1开始    row：行 1开始   anim：是否动画   boolNotSetPos:是否不更新坐标
function SelfHandEqsCardsCtrl.AddCardToCell(eqsCard, line, row, anim, boolNotSetPos)
    if this.isXiaoJia then
        Log("================>小家，不允许操作")
        return
    end
    local cell = this.GetCell(line, row)
    if cell == nil then
        LogError("error cell：", line, row)
        return 
    end
    --eqsCard:SetActive(true)
    eqsCard:SetParent(cell)
    eqsCard:SetLocation(line, row)
    eqsCard.transform.localRotation = Quaternion.Euler(0, 0, 0)
    local time = EqsTools.GetTime(0.2)
    if time < 0.01 then
        anim = false
    end
    if BattleModule.isPlayback then
        anim = false
        time = 0
    end
    if boolNotSetPos == nil or boolNotSetPos == false then
        if anim ~= nil and anim == true then
            eqsCard.transform:DOLocalMove(Vector3.zero, time, false)
            eqsCard.transform:DOLocalRotate(Vector3.zero, time, DG.Tweening.RotateMode.Fast)
        else
            eqsCard.transform.localPosition = Vector3.zero
        end
    end
end

--检测和同步手牌 返回牌是否相同 
function SelfHandEqsCardsCtrl.CheckAndSyncCards(minCards)
    if this.isXiaoJia then
        return 
    end
    if GetTableSize(minCards) <= 0 then
        Log("CheckAndSyncCards.size == 0")
        return 
    end
    --服务器牌格式化
    local serverCards = {}
    for _, id in pairs(minCards) do
        serverCards[id] = id
    end
    --本地牌获取
    local logClientCards = {}
    local clientCards = {}
    local card = nil
    local childCount = 0
    local child = nil
    for key, cell in pairs(this.cells) do
        childCount = cell.childCount
        if childCount > 1 then
            LogError("错误的格子：",childCount, UserData.GetUserId(), key, cell)
            clientCards = {}
            ClearChildren(cell)
            break
        else 
            if childCount > 0 then
                child = cell:GetChild(0)
                card = GetLuaComponent(child.gameObject, "EqsCard")
                if card ~= nil then
                    if clientCards[card:GetUid()] ~= nil then
                        LogError("牌已经存在", card:GetUid())
                        clientCards = {}
                        break
                    else   
                        clientCards[card:GetUid()] = card
                    end
                    logClientCards[key] = card:GetUid()
                else
                    LogError("错误的格子：",childCount, UserData.GetUserId(), key, child)
                    clientCards = {}
                    ClearChildren(cell)
                    break
                end
            end   
        end
    end

    --todo:test  ceshi
    local tempSCards = {}
    for k, v in pairs(serverCards) do
        table.insert(tempSCards, k)
    end
    --Log("本地牌：SetIsPerform772", GetTableSize(logClientCards),logClientCards, "服务器牌：", GetTableSize(tempSCards), tempSCards)
    --end

    local equals = true
    --后端牌比前端牌多2张及以上，重置牌局
    if GetTableSize(serverCards) - GetTableSize(clientCards) > 1 then
        this.RecycleAllCards()
        local cards = {}
        for _, cardId in pairs(minCards) do
            table.insert(cards, EqsCardsManager.GetCardByUid(cardId))
        end
        equals = false
        SelfHandEqsCardsCtrl.AddCards(cards, true)
    else --后端牌比前端牌少(吃、开、对)或者多一张(上吐下泻出牌失败)
        --循环当前手牌clientCards，如果当前手牌未在serverCards中，则回收当前牌
        for id, eqsCard in pairs(clientCards) do
            if serverCards[id] == nil then
                clientCards[id] = nil
                EqsCardsManager.RecycleCard(eqsCard, false)
                equals = false
            end
        end
        
        --循环serverCards，如果serverCards未在当前clientCards手牌中，则添加到当前牌(只会有一张不一致)
        for id, _ in pairs(serverCards) do
            if clientCards[id] == nil then
                card = EqsCardsManager.GetCardByUid(id)
                this.AddCard(card)
                equals = false
            end
        end
    end
    --todo:test
    -- clientCards = {}
    -- for key, cell in pairs(this.cells) do
    --     childCount = cell.childCount
    --     if childCount > 1 then
    --         LogError("错误的格子：",childCount, UserData.GetUserId(), key, cell)
    --         ClearChildren(cell.gameObject)
    --     else 
    --         if childCount > 0 then
    --             child = cell:GetChild(0)
    --             card = GetLuaComponent(child.gameObject, "EqsCard")
    --             if card ~= nil then
    --                 table.insert(clientCards, card:GetUid())
    --             else
    --                 LogError("错误的格子：",childCount, UserData.GetUserId(), key)
    --             end
    --         end   
    --     end
    -- end
    --Log("本地牌 同步后：",equals, GetTableSize(clientCards) ,clientCards)
    --end
    if not equals then
        this.DealAllLineCards()
        this.DealLinesMove()
    end
end

function SelfHandEqsCardsCtrl.DealAllLineCards()
   -- Log("整理所有")
    for i = 1, 10 do
        this.DealLineCards(i)
    end
end

-- 处理列牌：将牌下落
function SelfHandEqsCardsCtrl.DealLineCards(lineIdx)
    if this.isXiaoJia then
        Log("================>小家，不允许操作")
        return false
    end
    if lineIdx <= 0 then
        Log("================>SelfHandEqsCardsCtrl.DealLineCards(lineIdx)：", lineIdx)
        return false
    end
    local emptyCellY = 0
    -- 获取空列索引
    for i = 1, 4 do
        local card = this.GetEqsCard(lineIdx, i)
        if card == nil then
            emptyCellY = i
            break
        end
    end
    if emptyCellY >= 4 then
        return false
    end
    local beginDownCellY = 0
    for i = emptyCellY + 1, 4 do
        local card = this.GetEqsCard(lineIdx, i)
        if card ~= nil then
            beginDownCellY = i
            break
        end
    end

    local hasDeal = false
    -- Log("DealLineCards：", beginDownCellY, emptyCellY, "   x:",lineIdx)
    if emptyCellY < beginDownCellY and emptyCellY > 0 and beginDownCellY > 0 then
        -- 将空列上面的下移
        for i = beginDownCellY, 4 do
            local card = this.GetEqsCard(lineIdx, i)
            if card ~= nil then
                hasDeal = true
                this.AddCardToCell(card, lineIdx, emptyCellY + i - beginDownCellY, true)
            end
        end
    end
    return hasDeal
end

function SelfHandEqsCardsCtrl.DealLinesMove()
    local leftHasCardLineIdx = 0
    --计算左边有牌的起始行
    for i = 1, 10 do
        if this.GetLineCardNum(i) > 0 then
            leftHasCardLineIdx = i
            break
        end
    end

    local funMove = function()
        local card = nil
        for i = leftHasCardLineIdx, 10 do
            if this.GetLineCardNum(i) == 0 then
                for x = i, 9 do
                    for y = 1, 4 do
                        card = this.GetEqsCard(x + 1, y)
                        if card ~= nil then
                            this.AddCardToCell(card, x, y, true)
                        end
                    end
                end
            end
        end
    end

    TryCatchCall(function ()
        --执行3遍理由：放置相邻的3个空格，不能移动的情况
        funMove()
        funMove()
        funMove()
    end)
    

    local leftEmptyLines = leftHasCardLineIdx - 1
    local rightEmptyLines = 0
    for i = 10, 1, -1 do
        if this.GetLineCardNum(i) > 0 then
            rightEmptyLines = 10 - i
            break
        end
    end
    --计算当左边或者右边空行不均匀时，移动情况
    local moveLines = math.abs(math.floor((rightEmptyLines - leftEmptyLines) / 2))
    local card = nil
    -- Log("++++++++++++++++++++>", leftEmptyLines, rightEmptyLines, moveLines)
    if moveLines > 0 then
        if leftEmptyLines > rightEmptyLines then -- 左边空行更多，全体左移
            for i = 1, 10 do
                for y = 1, 4 do
                    card = this.GetEqsCard(i, y)
                    if card ~= nil then
                        this.AddCardToCell(card, i - moveLines, y, true)
                    end
                end
            end
        else-- 右边空行更多，全体右移
            for i = 10, 1, -1 do
                for y = 1, 4 do
                    card = this.GetEqsCard(i, y)
                    if card ~= nil then
                        --  Log(card:GetId(), i, moveLines)
                        this.AddCardToCell(card, i + moveLines, y, true)
                    else
                        -- Log("没有找到牌：", i, y)
                    end
                end
            end
        end
    end
end

-- line：列 1开始    row：行 1开始
function SelfHandEqsCardsCtrl.GetCell(line, row)
    local cell = this.cells[line * 10 + row]
    if cell == nil then
        Log("SelfHandEqsCardsCtrl.GetCell--->没有找到Cell:", line, row)
    end
    return cell
end

function SelfHandEqsCardsCtrl.GetEqsCard(line, row)
    if this.isXiaoJia then
        Log("================>小家，不允许操作")
        return
    end
 
    local cell = this.GetCell(line, row)
    if cell == nil then
        LogError("ERROR:cell", line, row)
        return 
    end
    local count = cell.childCount
    if count > 1 then
        LogError("ERROR, 该cell牌张数大于1:", line, row)
    end

    if count > 0 then
        local tran = cell:GetChild(0)
        if tran ~= nil then
            local card = GetLuaComponent(tran.gameObject, "EqsCard")
            if card == nil then
                DestroyObj(tran.gameObject)
            else
                return card
            end
        end
    end
end

function SelfHandEqsCardsCtrl.GetEqsCardById(cardid)
    for i = 1, 10 do
        for j = 4, 1, -1 do
            local card = this.GetEqsCard(i, j)
            if card ~= nil then
                if card:GetUid() == cardid then
                    return card
                end
            end
        end
    end
    return nil
end

function SelfHandEqsCardsCtrl.GetEqsCardByUId(cardUid)
    for i = 1, 10 do
        for j = 4, 1, -1 do
            local card = this.GetEqsCard(i, j)
            if card ~= nil then
                if  card:GetUid() == cardUid  then
                    return card
                end
            end
        end
    end
    return nil
end

-- 获取每行放置牌的数量
function SelfHandEqsCardsCtrl.GetLineCardNum(lineNum)
    if this.isXiaoJia then
        Log("================>小家，不允许操作")
        return
    end
    local num = 0
    if this.GetCell(lineNum, 1).childCount >= 1 then
        num = num + 1
    end

    if this.GetCell(lineNum, 2).childCount >= 1 then
        num = num + 1
    end

    if this.GetCell(lineNum, 3).childCount >= 1 then
        num = num + 1
    end

    if this.GetCell(lineNum, 4).childCount >= 1 then
        num = num + 1
    end
    return num
end

function SelfHandEqsCardsCtrl.GetCountById(tableCards, id)
    local count = 0
    for _, card in pairs(tableCards) do
        if card:GetId() == id then
            count = count + 1
        end
    end
    return count
end

-- 计算发牌列数(每列放4张牌)  tableCards：EqsCard数组,已排序
function SelfHandEqsCardsCtrl.CalcuLines(tableCards)
    -- 设置牌的激活属性
    local len = #tableCards
    for _, card in pairs(tableCards) do
        card:SetActive(true)
    end
    if this.isXiaoJia then
        Log("================>小家，不允许操作")
        return
    end
    for i = 1, len - 2 do
        local id0 = tableCards[i]
        local id1 = tableCards[i + 1]
        local id2 = tableCards[i + 2]
        --三张相同牌禁止点击
        if id0:GetId() == id1:GetId() and id0:GetId() == id2:GetId() then
            id0:SetActive(false)
            id1:SetActive(false)
            id2:SetActive(false)

            --4张牌，禁止点击
            local id3 = tableCards[i + 3]
            if id3 ~= nil and id3:GetId() == id2:GetId() then
                id3:SetActive(false)
            end
        end
    end
    --list{列={EqsCard数组}, 列={EqsCard数组}...}
    local list = {} --定义10列

    --初始化20列，tableCards最多21张(三人打，庄家)
    for i = 1, 20 do
        list[i] = {}
    end

    local curListIdx = 1
    for i, card in ipairs(tableCards) do
        local listCardCount = #list[curListIdx]
        if listCardCount == 0 then
            table.insert(list[curListIdx], card)
        else
            if list[curListIdx][listCardCount]:GetId() == card:GetId() then
                table.insert(list[curListIdx], card) --相同ID插入同一行
            else
                if list[curListIdx][listCardCount]:GetPoint() == card:GetPoint() then -- 处理点数相同
                    local count = this.GetCountById(tableCards, card:GetId())
                    if listCardCount + count < 5 then
                        table.insert(list[curListIdx], card) --相同ID插入同一行
                    else
                        curListIdx = curListIdx + 1
                        table.insert(list[curListIdx], card) --相同ID插入同一行
                    end
                else
                    curListIdx = curListIdx + 1
                    table.insert(list[curListIdx], card) --相同ID插入同一行
                end
            end
        end
    end

    --删除空列
    for idx, cards in pairs(list) do
        if #cards == 0 then
            list[idx] = nil
        end
    end

    -- 处理多余的列:由于牌面只能显示10列，将相邻的只有一张牌的列放在一起(21张牌最多12列)
    --将相邻的只有一张牌的行合并
    local listNum = GetTableSize(list)
    if listNum == 12 then
        for i = 1, 12 do
            if list[i] ~= nil and list[i + 1] ~= nil then
                if #list[i] < 4 and #list[i + 1] == 1 then
                    table.insert(list[i], list[i + 1][1])
                    list[i + 1] = nil
                    break
                end
            end
        end
    end

    --将只有一张牌的行插入到左边不满4张牌的行
    if GetTableSize(list) > 10 then
        for i = 1, 12 do
            if list[i] ~= nil and list[i + 1] ~= nil then
                if #list[i] < 4 and #list[i + 1] == 1 then
                    table.insert(list[i], list[i + 1][1])
                    list[i + 1] = nil
                    break
                end
            end
        end
    end
    return list
end

--添加一张牌，添加到最右边的空Cell:EqsCard对象
function SelfHandEqsCardsCtrl.AddCard(card)
    card:SetActive(true)
    if this.isXiaoJia then --小家时添加到摸牌位置
        if this.xiaoJiaCardMoPaiPos.childCount > 0 then
            local existCard = this.xiaoJiaCardMoPaiPos:GetChild(0)
            Log('===================================>', existCard.name, card.transform.gameObject.name)
            if existCard.gameObject.name == card.transform.gameObject.name then
                return
            end
        end
        card:SetParent(this.xiaoJiaCardMoPaiPos)
        card.transform.anchoredPosition = Vector3.zero
        card.transform.localRotation = Quaternion.Euler(0, 0, 0)
        UIUtil.DOFade(card.transform, 1, 0.15)
        Log("添加小家摸牌：", card:GetId())
        return
    end
    local cardNum = 0
    local nextLineNum = 0
    local getCard = nil
    Log("添加牌")
    for i = 10, 1, -1 do
        cardNum = this.GetLineCardNum(i)
        if cardNum > 0 then
            if cardNum < 4 then
                for j = 1, 4 do
                    getCard = this.GetEqsCard(i, j)
                    if getCard == nil then
                        this.AddCardToCell(card, i, j, true)
                        return
                    end
                end
            else
                if i - 1 > 0 then
                    nextLineNum = this.GetLineCardNum(i - 1)
                    for j = 1, 4 do
                        local getCard = this.GetEqsCard(i - 1, j)
                        if getCard == nil then
                            this.AddCardToCell(card, i - 1, j, true)
                            return
                        end
                    end
                elseif i + 1 <= 10 then
                    nextLineNum = this.GetLineCardNum(i + 1)
                    for j = 1, 4 do
                        local getCard = this.GetEqsCard(i + 1, j)
                        if getCard == nil then
                            this.AddCardToCell(card, i + 1, j, true)
                            return
                        end
                    end
                end
            end
        end
    end
end

--添加自己的出牌
function SelfHandEqsCardsCtrl.AddChuPaiToChuPaiRect(eqsCard)
    local time = EqsTools.GetTime(0.3)
   -- Log("出牌前。。。。。。。。。。。。。。。")
    this.PrintAllCards()
   
    local x = eqsCard:GetLocation().x
    eqsCard:SetParent(EqsBattlePanel.GetChuPaiRect():Find('ChuPaiPos'))
    local t1 = eqsCard.transform:DOLocalMove(Vector3.zero, time, false)
    local t2 = eqsCard.transform:DOLocalRotate(Vector3(0, 0, 90), time, DG.Tweening.RotateMode.Fast)
    t1:SetId(eqsCard.transform)
    t2:SetId(eqsCard.transform)
    eqsCard:SetLocation(0, 0)
    eqsCard.isActive = false

 --   Log("出牌后。。。。。。。。。。。。。。。")
    this.PrintAllCards()
    Scheduler.scheduleOnceGlobal(function()
        SelfHandEqsCardsCtrl.DealLineCards(x)
    end, time + 0.05)
end

--添加自己的翻牌
function SelfHandEqsCardsCtrl.AddFanPaiToChuPaiRect(eqsCard)
    Log("=========添加牌到出牌区域", eqsCard.transform.name)
    local card = eqsCard
    local fromGpos = EqsBattlePanel.GetFanPaiGPos()
    local time = EqsTools.GetTime(0.3)
    card.transform.position = fromGpos
    card.transform:SetParent(EqsBattlePanel.GetChuPaiRect():Find('ChuPaiPos'))
    card.transform.localRotation = Quaternion.Euler(0, 0, 0)
    card.transform.localScale = Vector3(0.2, 0.2, 0.2)

    card.transform:DOScale(Vector3(1, 1, 1), time)
    card.transform:DOLocalMove(Vector3.zero, time, false)
    card.transform:DOLocalRotate(Vector3(0, 0, 90), time, DG.Tweening.RotateMode.Fast)
    eqsCard.isActive = false
end

function SelfHandEqsCardsCtrl.RecycleCardByUid(uid)
    local card = nil
    for i = 1, 10 do
        for j = 1, 4 do
            card = this.GetEqsCard(i, j)
            if card ~= nil then
                if card:GetUid() == uid then
                    local loc = card:GetLocation()
                    EqsCardsManager.RecycleCard(card)
                    return loc
                end
            end
        end
    end
    return Vector2.zero
end

function SelfHandEqsCardsCtrl.RecycleAllCards()
   -- Log("回收所有牌")
    local card = nil
    for i = 1, 10 do
        for j = 1, 4 do
            card = this.GetEqsCard(i, j)
            if card ~= nil then
                EqsCardsManager.RecycleCard(card, false)
            end
        end
    end

    --清理所有小家
    this.ClearAllXiaoJiaCard()

    --清理所有cell
    for i = 10, 1, -1 do
        for j = 1, 4 do
            local cell = this.GetCell(i, j)
            if cell then
                ClearChildren(cell)
            end
        end
    end
end

function SelfHandEqsCardsCtrl.GetKeyOfPos(x, y)
    return BattleModule.uid .. "_Card_Pos_" .. tostring(x * 10 + y)
end

function SelfHandEqsCardsCtrl.SetLocalPos(cardid, newVec2)
    SetLocal(this.GetKeyOfPos(newVec2.x, newVec2.y), tostring(cardid))
end

function SelfHandEqsCardsCtrl.ClearAllLocalPos()
    if this.isXiaoJia then
        Log("================>小家，不允许操作")
        return
    end
    this.allCardsPos = {}
    for x = 1, 10 do
        for y = 1, 4 do
            local key = this.GetKeyOfPos(x, y)
            SetLocal(key, "0")
        end
    end
end

function SelfHandEqsCardsCtrl.SaveAllLocalPos()
    if this.isXiaoJia then
        Log("================>小家，不允许操作")
        return
    end
    this.ClearAllLocalPos()
   -- Log("保存Pos")
    local card = nil
    for i = 1, 10 do
        for j = 1, 4 do
            card = this.GetEqsCard(i,j)
            if card ~= nil then
                this.SetLocalPos(card:GetUid(), card:GetLocation())
                card.isChuPai = false
            end
        end
    end
end

function SelfHandEqsCardsCtrl.InitLocalPos()
    if this.isXiaoJia then
        Log("================>小家，不允许操作")
        return
    end
    this.allCardsPos = {}
    for x = 1, 10 do
        for y = 1, 4 do
            local key = this.GetKeyOfPos(x, y)
            local val = GetLocal(key, "")
            if val and val ~= "0" then
                this.allCardsPos[key] = val
            end
        end
    end
    Log("位置初始化:", this.allCardsPos)
end

function SelfHandEqsCardsCtrl.GetLocalPos(eqsCardid)
    if this.isXiaoJia then
        Log("================>小家，不允许操作")
        return
    end
    for k, cardid in pairs(this.allCardsPos) do
        if cardid == tostring(eqsCardid) then
           -- Log("找到Pos", k, cardid, eqsCardid)
            this.allCardsPos[k] = ""
            local num = string.split(k, "_")[4]
            if num == nil then
                return nil
            else        
                return Vector2(math.floor(tonumber(num) / 10), tonumber(num) % 10)
            end
        end
    end
    return nil
end

function SelfHandEqsCardsCtrl.GetFollowCards(eqsCard)
    if this.isXiaoJia then
        Log("================>小家，不允许操作")
        return
    end
    local follows = {}
    local x = eqsCard:GetLocation().x
    if x > 0 then
        for y = 1, 4 do
            local card = this.GetEqsCard(x,y)
            if card ~= nil then
                if card:GetUid() ~= eqsCard:GetUid() then
                    if card:GetId() == eqsCard:GetId() then
                        follows[card] = eqsCard.transform.position - card.transform.position
                    end
                end
            end
        end
    end
    if GetTableSize(follows) > 1 then
        return follows
    end
    return nil
end

function SelfHandEqsCardsCtrl.ClearAllXiaoJiaCard()
end

--整理小家的牌
function SelfHandEqsCardsCtrl.SortXiaoJiaCards()
    local cardTrans = {}
    if this.xiaoJiaCard1Pos.childCount > 0 then
        table.insert(cardTrans, this.xiaoJiaCard1Pos:GetChild(0))
    end

    if this.xiaoJiaCard2Pos.childCount > 0 then
        table.insert(cardTrans, this.xiaoJiaCard2Pos:GetChild(0))
    end

    if this.xiaoJiaCardMoPaiPos.childCount > 0 then
        table.insert(cardTrans, this.xiaoJiaCardMoPaiPos:GetChild(0))
    end

    if #cardTrans == 2 then
        local max = nil
        local min = nil
        if GetEqsCardPoint(cardTrans[1].gameObject.name) > GetEqsCardPoint(cardTrans[2].gameObject.name) then
            max = cardTrans[1]
            min = cardTrans[2]
        else
            max = cardTrans[2]
            min = cardTrans[1]
        end
        Log("SortXiaoJiaCards:", max.name, min.name)
        max:SetParent(this.xiaoJiaCard2Pos)
        min:SetParent(this.xiaoJiaCard1Pos)

        max:DOLocalMove(Vector3.zero, 0.3, false)
        min:DOLocalMove(Vector3.zero, 0.3, false)
    end
end

--初始化回放过程中，战斗时的牌
function SelfHandEqsCardsCtrl.InitPlaybackCardsInBattle(cardIds)
    this.OnPlaybackCancelAllEffect()
    local selfCardIds = {}
    table.sort(selfCardIds, function(card1, card2) return card1 < card2 end)
    table.sort(cardIds, function(card1, card2) return card1 < card2 end)
    --  Log( "手牌ID：", selfCardIds)
    --  Log("解析牌ID：", cardIds)
    if this.isXiaoJia == true then
        local equal = false  --当前小家手牌是否相同
        if #cardIds == #selfCardIds then
            if selfCardIds[1] == cardIds[1] and selfCardIds[2] == cardIds[2] and selfCardIds[3] == cardIds[3] then
                equal = true
            end
        end
        if not equal then
            this.ClearAllXiaoJiaCard()
            local tableCards = {}
            for k, v in pairs(cardIds) do
                table.insert(tableCards, EqsCardsManager.GetCardByUid(v))
            end
            this.AddCards(tableCards)
        else
            this.SortXiaoJiaCards()
        end
        return
    end

    local gPos = Vector3.zero
    if #cardIds == #selfCardIds then
        local len = #cardIds
        local equals = true
        for i = 1, len do
            if cardIds[i] ~= selfCardIds[i] then
                equals = false
                break
            end
        end
        if equals then
            --   Log("牌相同。。。。。。。。。。。。。。。。。")
            this.DealAllLineCards()
            return
        end
    end
    --下一步
    if #cardIds < #selfCardIds then
        --    Log("下一步。。。。。。。。。。。。。。。。")
        for _, id in pairs(cardIds) do
            for key, selfId in pairs(selfCardIds) do
                if selfId == id then
                    selfCardIds[key] = nil
                    break
                end
            end
        end

        for k, card in pairs(this.tableCards) do
            for key, selfId in pairs(selfCardIds) do
                if selfId == card:GetId() then
                    selfCardIds[key] = nil
                    local x = card:GetLocation().x
                    gPos = card.transform.position
                    this.RecycleCardById(card:GetId())
                    this.DealLineCards(x)
                    break
                end
            end
        end
        this.DealLinesMove()
        return gPos
    end

    --上一步
    -- Log("上一步。。。。。。。。。。。。。。。。")
    this.RecycleAllCards()

    local tableCards = {}
    for k, v in pairs(cardIds) do
        table.insert(tableCards, EqsCardsManager.GetCardByUid(v))
    end

    table.sort(tableCards, function(card1, card2) return card1:GetUid() < card2:GetUid() end)
    local str = ""
    for k, v in pairs(tableCards) do
        str = str .. tostring(v:GetUid()) .. ","
    end

    this.tableCards = tableCards

    local lists = this.CalcuLines(tableCards)

    --获取当前有Card的行
    local beginLine = 0
    for i = 1, 10 do
        if this.GetLineCardNum(i) > 0 then
            beginLine = i
            break
        end
    end

    local endLine = beginLine + #lists - 1
    --	Log("初始行号开始结尾：", beginLine, endLine)
    --行数左移计算
    local leftMove = math.floor((beginLine - 1 - (10 - endLine)) / 2)
    endLine = endLine - leftMove
    beginLine = beginLine - leftMove
    --	Log("格式化后开始结尾：", beginLine, endLine)
    --	Log("打印列牌：")
    for k, cards in pairs(lists) do
        local lie = tostring(k) .. ":"
        for _, cardid in pairs(cards) do
            lie = lie .. tostring(cardid:GetId()) .. ','
        end
        Log(lie)
    end
    --Log("打印列牌结束")
    for i = beginLine, endLine do
        local lineCards = lists[i - beginLine + 1]
        if lineCards ~= nil then
            for j = 1, #lineCards do
                if lineCards[j] then
                    --Log("添加牌：", i, j, lineCards[j]:GetId())
                    this.AddCardToCell(lineCards[j], i, j, false, false)
                else
                    --	Log("=========================ERROR:", i, j)
                end
            end
        end
    end

    --处理显示磙
    for x = 1, 10 do
        local card1 = this.GetEqsCard(x, 1)
        local card2 = this.GetEqsCard(x, 2)
        local card3 = this.GetEqsCard(x, 3)
        local card4 = this.GetEqsCard(x, 4)
        if card1 ~= nil and card2 ~= nil and card3 ~= nil and card4 ~= nil then
            local id = card1:GetId()
            if id == card2:GetId() and id == card3:GetId() and id == card4:GetId() then
                card1:SetGunVisible(true)
            end
        end
    end
end


function SelfHandEqsCardsCtrl.OnPlaybackChangedHsz(userExternal)
    local splits = string.split(userExternal, ";")
    for _, split in pairs(splits) do
        local splits2 = string.split(split, ",")
        if splits2[1] ~= nil then
            if splits2[1] == "3" then   --替换的换三张牌
                this.OnHszEffect(GetClientEqsCardId(splits2[2]), GetClientEqsCardId(splits2[3]), GetClientEqsCardId(splits2[4]), 1)
            elseif splits2[1] == "2" then  --选中换三张牌
                this.OnHszEffect(GetClientEqsCardId(splits2[2]), GetClientEqsCardId(splits2[3]), GetClientEqsCardId(splits2[4]), 0)
            end
        end
    end
end


function SelfHandEqsCardsCtrl.OnPlaybackCancelAllEffect()
    for x = 1, 10 do
        for y = 1, 4 do
            local eqsCard = this.GetEqsCard(x,y)
            if eqsCard ~= nil then
                eqsCard:CancelAllEffect(false)
            end
        end
    end
    Log("取消自己牌特效")
end

--type:0 选中换三张    1 替换的换三张
function SelfHandEqsCardsCtrl.OnHszEffect(id1, id2, id3, type)
  --  Log("设置自己牌特效：", id1, id2, id3, type)
    for x = 1, 10 do
        for y = 1, 4 do
            local eqsCard = this.GetEqsCard(x,y)
            if eqsCard ~= nil then
                if eqsCard:GetUid() == tonumber(id1) or eqsCard:GetUid() == tonumber(id2) or eqsCard:GetUid() == tonumber(id3)  then
                   -- Log("  设置特效：", eqsCard:GetUid(), type)
                    if type == 0 then
                        eqsCard:SetHuanVisible(true)
                    elseif type == 1 then
                        eqsCard:SetChangedHuanVisible(true)
                    end
                end
            end
        end
    end
end

function SelfHandEqsCardsCtrl.SetDraggable(draggable, time)
    --Log("设置拖动", draggable, time)
    this.draggable = draggable
    if draggable == false and IsNumber(time) then
        Scheduler.unscheduleGlobal(this.draggleHandle)
        this.draggleHandle = Scheduler.scheduleOnceGlobal(function() 
            this.draggable = true
        end,time)
    end
end

function SelfHandEqsCardsCtrl.GetDraggable()
    return this.draggable == true
end

function SelfHandEqsCardsCtrl.GetAllCardPositions()
    local postions = {}
    local card = nil
    for x = 1, 10 do
        for y = 1, 4 do
            card = this.GetEqsCard(x,y)
            if card ~= nil then
                postions[tostring(card:GetUid())] = {x = x, y = y}
            end
        end
    end
    return postions
end

function SelfHandEqsCardsCtrl.SetQuanTag()
    local card = nil
    for i = 1, 10 do
        for j = 1, 4 do
            card = this.GetEqsCard(i,j)
            if card ~= nil then
                card:SetQuanTag()
            end
        end
    end
end