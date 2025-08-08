--战绩回放时，其他玩家的手牌控制
local cellSize = 34
PlaybackOthersHandCards = Class("PlaybackOthersHandCards")
PlaybackOthersHandCards.transform = nil
PlaybackOthersHandCards.cells = {} -- 所有牌放置格子：10列，每列4个
PlaybackOthersHandCards.cardIds = {}  --所有的牌的ID
PlaybackOthersHandCards.isXiaoJia = false --是否是小家
PlaybackOthersHandCards.uid = "000000"
PlaybackOthersHandCards.uiIdx = 0
PlaybackOthersHandCards.userInfo = nil
PlaybackOthersHandCards.lOriginPos = Vector3(0,0,0)

function PlaybackOthersHandCards:Reset()
    if self.transform then
        self.transform.localPosition = self.lOriginPos
    end
end
function PlaybackOthersHandCards:Init(tran, uid, uiIdx, userInfo)
    self.transform = tran
    self.uid = uid
    self.uiIdx = uiIdx
    self.userInfo = userInfo
    if tran == nil then
        return
    end
    self.lOriginPos = tran.localPosition
    self.cells = {}
    for i = 1, 10 do
        local line = self.transform:Find("Line" .. tostring(i)):GetComponent("RectTransform")
        self.cells[i * 10 + 1] = line:Find("Cell1"):GetComponent("RectTransform")
		self.cells[i * 10 + 2] = line:Find("Cell2"):GetComponent("RectTransform")
		self.cells[i * 10 + 3] = line:Find("Cell3"):GetComponent("RectTransform")
		self.cells[i * 10 + 4] = line:Find("Cell4"):GetComponent("RectTransform")
	end
end

--处理小家牌逻辑
function PlaybackOthersHandCards:DealXiaoJiaCards( midCards )
    local serverCards = string.split(midCards, ",")
    local midCards = {}
    for _,v in pairs(serverCards) do
        table.insert( midCards, GetClientEqsCardId(v) )
    end
    local x1, x2, xMo
    if self.uiIdx == 2 then
        x1 = 6
        x2 = 7
        xMo = 4
    elseif self.uiIdx == 3 then
        x1 = 2
        x2 = 3
        xMo = 5
    elseif self.uiIdx == 4 then
        x1 = 2
        x2 = 3
        xMo = 5
    end

    local selfCardIds = {}
    local card1 = self:GetCellCard(x1, 1)
    if card1 ~= nil then
        table.insert( selfCardIds, tonumber(card1.gameObject.name) )
    end

    local card2 = self:GetCellCard(x2, 1)
    if card2 ~= nil then
        table.insert( selfCardIds, tonumber(card2.gameObject.name) )
    end

    local cardMo = self:GetCellCard(xMo, 1)
    if cardMo ~= nil then
        table.insert( selfCardIds, tonumber(cardMo.gameObject.name) )
    end
    
    -- table.sort( selfCardIds, function(card1, card2)
    --     return card1 < card2
    -- end)

    Log("小家手牌：", selfCardIds, self.uid, self.uiIdx, x1, x2, xMo)
    Log("小家Mids(若有摸牌，包含摸牌)：", midCards)
    
    local gPos = nil
    --3张牌时，最后一张为摸牌
    if #midCards == 3 then
        local card = EqsCardsManager.GetSmallCardByUid(midCards[3])
        if card then
            self:AddCardToCell(xMo, 1, card)
        end
        midCards[3] = nil
    end 

    --牌相等
    if #midCards == #selfCardIds and #midCards == 2 then
        if selfCardIds[1] ~= midCards[1] then
            EqsCardsManager.RecycleSmallCard(card1)
            card1 = EqsCardsManager.GetSmallCardByUid(midCards[1])
            if card1 then
                self:AddCardToCell(x1, 1, card1)
            end
        end

        if selfCardIds[2] ~= midCards[2] then
            EqsCardsManager.RecycleSmallCard(card2)
            card2 = EqsCardsManager.GetSmallCardByUid(midCards[2])
            if card2 then
                self:AddCardToCell(x2, 1, card2)
            end
        end
        return nil
    end

    --初始化牌
    if #midCards == 2 and #selfCardIds == 0 then
        card1 = EqsCardsManager.GetSmallCardByUid(midCards[1])
        if card1 then
            self:AddCardToCell(x1, 1, card1)
        end
        card2 = EqsCardsManager.GetSmallCardByUid(midCards[2])
        if card2 then
            self:AddCardToCell(x2, 1, card2)
        end
    end

    --出牌
    if #midCards == 2 and #selfCardIds == 3 then
        table.sort( midCards, function(card1, card2)
            return card1 < card2
        end)
        
        --出的摸牌
        if selfCardIds[1] == midCards[1] and selfCardIds[2] == midCards[2] then
            gPos = cardMo.position
            EqsCardsManager.RecycleSmallCard(cardMo)
            return
        --出的第二张牌
        elseif selfCardIds[1] == midCards[1] and selfCardIds[2] ~= midCards[2] then
            gPos = card2.position
            self:AddCardToCell(x2,1,cardMo)
            EqsCardsManager.RecycleSmallCard(card2)
        --出的第一张牌
        elseif selfCardIds[1] ~= midCards[1] then
            self:AddCardToCell(x1,1,card2)
            self:AddCardToCell(x2,1,cardMo)
            EqsCardsManager.RecycleSmallCard(card1)
        end
    end
    return gPos
end

--midCards：  小家摸牌时，在此处解析
function PlaybackOthersHandCards:AddCards(midCards)
   -- Log("初始化回放：",midCards, self.transform.parent.name, self.uid, self.isXiaoJia)
    if self.isXiaoJia then
        return self:DealXiaoJiaCards(midCards)
    end
   
    local tableCardIds = midCards
    table.sort(
        tableCardIds,
        function(card1, card2)
            return card1 < card2
        end
    )
   
    self:CancleAllEffect()
    local equal = true  -- 两副牌是否相同
    if GetTableSize(self.cardIds) == GetTableSize(tableCardIds)  then
        for k,v in pairs(self.cardIds) do
            if v ~= tableCardIds[k] then
                equal = false
                break
            end
        end
    else
        equal = false
    end
    if equal then
        return
    end

    --第一张不同牌的全局坐标，用于出牌时，牌动画开始位置
    local gPos = nil
    
    self.cardIds = tableCardIds
   
    local lists = self:CalcuLines(tableCardIds)
    --Log(self.uid, "新手牌：", lists)
    for x=1,10 do
        for y=1,4 do
            local cardTran = self:GetCellCard(x, y)
            local cardid = nil
            if lists[x] ~= nil then
                cardid = lists[x][y]
            end

            if cardid ~= nil and cardTran ~= nil then
                if cardTran.gameObject.name == cardid then
                    break
                else
                    if gPos == nil then
                      --  Log("1设置不同牌位置：", cardTran.position)
                        gPos = cardTran.position
                    end
                    EqsCardsManager.RecycleSmallCard(cardTran)
                    local card = EqsCardsManager.GetSmallCardByUid (tonumber(cardid))
                    if card ~= nil then
                        card:SetParent(self.cells[x * 10 + y])
                        card.anchoredPosition = Vector3.zero
                    end
                end
            elseif cardid ~= nil and cardTran == nil then
                local card = EqsCardsManager.GetSmallCardByUid(tonumber(cardid))
                if card ~= nil then
                    card:SetParent(self.cells[x * 10 + y])
                    card.anchoredPosition = Vector3.zero
                end
            elseif cardid == nil and cardTran ~= nil then
                if gPos == nil then
                  --  Log("2设置不同牌位置：", cardTran.position)
                    gPos = cardTran.position
                end
                EqsCardsManager.RecycleSmallCard(cardTran)
            end
        end
    end

    for i = 1, 10 do
        local cell = self:GetCell(i, 1)
        if cell ~= nil then
            if self:GetLineCardCount(i) == 0 then
                UIUtil.SetActive(cell.parent, false)
            else
                UIUtil.SetActive(cell.parent, true)
            end
        end
    end
    self:AjustPos(GetTableSize(lists))
    return gPos
end

--totalline：当前总行数
function PlaybackOthersHandCards:AjustPos(totalline)
    local move = 10 - totalline
    if BattleModule.userNum == 3 then
         if self.uiIdx == 3 then
             if move < 6 then
                 self.transform.localPosition = self.lOriginPos + Vector3(move * cellSize, 0, 0)
             end
         elseif self.uiIdx == 2 then --不移动，始终最左对齐
         end
     elseif BattleModule.userNum == 4 then
         if self.uiIdx == 2 then
             if totalline < 4 then
                 self.transform.localPosition = self.lOriginPos - Vector3(2 * cellSize, 0, 0)
             end
         elseif self.uiIdx == 3 then
            move = 0
            local user = BattleModule.GetUserInfoByUid(self.uid)
            if user ~= nil and IsNumber(user.pengPaiIdx) then
                move = user.pengPaiIdx
            end
           self.transform.localPosition = self.lOriginPos + Vector3(move * cellSize, 0, 0)
            self.transform.localPosition = self.lOriginPos + Vector3(move * cellSize, 0, 0)
         elseif self.uiIdx == 4 then
             if move < 7 then
                 self.transform.localPosition = self.lOriginPos + Vector3(move * cellSize, 0, 0)
             end
         end
     elseif BattleModule.userNum == 2 then
         if self.uiIdx == 2 then
            move = 0
            local user = BattleModule.GetUserInfoByUid(self.uid)
            if user ~= nil and IsNumber(user.pengPaiIdx) then
                move = user.pengPaiIdx
            end
           self.transform.localPosition = self.lOriginPos + Vector3(move * cellSize, 0, 0)
         end
     end
 end

function PlaybackOthersHandCards:GetCell( x, y )
    return self.cells[x * 10 + y]
end

function PlaybackOthersHandCards:AddCardToCell(x, y, cardTran)
    if cardTran then
        local cell = self:GetCell(x, y)
        if cell then
            cardTran:SetParent(cell)
            cardTran.localPosition = Vector3.zero
        end
    end
end

function PlaybackOthersHandCards:GetCellCard( x, y )
    local cell = self:GetCell(x, y)
    if cell and cell.childCount > 0 then
        return cell:GetChild(0)
    end
    return nil
end

-- 计算发牌列数(每列放4张牌)  tableCards：CardId数组,已排序
function PlaybackOthersHandCards:CalcuLines(tableCards)
	--list{列={EqsCard数组}, 列={EqsCard数组}...}
	local list = {} --定义10列
	
	--初始化20列，tableCards最多21张(三人打，庄家)
	for i = 1, 20 do
		list[i] = {}
	end
	
    local curListIdx = 1
    local count = 0
    for i, card in pairs(tableCards) do
		local listCardCount = GetTableSize(list[curListIdx])
		if listCardCount == 0 then
			table.insert(list[curListIdx], card)
		else
			if EqsTools.GetEqsCardId(list[curListIdx] [listCardCount]) == EqsTools.GetEqsCardId(card) then
				table.insert(list[curListIdx], card) --相同ID插入同一行
			else
				if EqsTools.GetEqsCardPoint(list[curListIdx] [listCardCount]) == EqsTools.GetEqsCardPoint(card) then -- 处理点数相同
					count = self:GetCountById(tableCards, card)
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
        --Log("处理牌：card",card, "listCount", listCardCount, "count", count)
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
    
    --索引变为：1,2,3,4,5.。。。。。。。。。。。。。。。
    local tempList = {}
    for k,v in pairs(list) do
        table.insert( tempList, v )
    end
	return tempList
end

function PlaybackOthersHandCards:GetCountById(tableCards, id)
    local count = 0
	for _, card in pairs(tableCards) do
		if EqsTools.GetEqsCardId(card) == EqsTools.GetEqsCardId(id) then
			count = count + 1
		end
	end
	return count
end
--type:0 选中换三张    1 替换的换三张
function PlaybackOthersHandCards:OnSelectedHsz(id1, id2, id3, type)
    id1 = tostring(id1)
    id2 = tostring(id2)
    id3 = tostring(id3)
    for _, cell in pairs(self.cells) do
        if cell.childCount > 0 then
            local cardTran = cell:GetChild(0)
            if cardTran.gameObject.name == id1 or cardTran.gameObject.name == id2 or cardTran.gameObject.name == id3 then
                if type == 0 then
                    EqsCardsManager.SetSmallCardEffect(cardTran, EqsCardDefine.SmallCardEffectType.SelectedHsz)
                elseif type == 1 then
                    EqsCardsManager.SetSmallCardEffect(cardTran, EqsCardDefine.SmallCardEffectType.ChangedHsz)
                end
            end           
        end
    end
end

function PlaybackOthersHandCards:CancleAllEffect()
    for _, cell in pairs(self.cells) do
        if cell.childCount > 0 then
            local cardTran = cell:GetChild(0)
            EqsCardsManager.SetSmallCardEffect(cardTran,EqsCardDefine.SmallCardEffectType.Null)
        end
    end
  --  Log("取消特效")
end

function PlaybackOthersHandCards:GetLineCardCount(i)
    local count = 0
    if self:GetCellCard(i,1) ~= nil then
        count = count + 1
    end
    if self:GetCellCard(i,2) ~= nil then
        count = count + 1
    end
    if self:GetCellCard(i,3) ~= nil then
        count = count + 1
    end
    if self:GetCellCard(i,4) ~= nil then
        count = count + 1
    end
    return count
end

function PlaybackOthersHandCards:GetCardByCardUid(cardUid)
    for i = 1, 10 do
        for j = 1, 4 do
            local card = self:GetCellCard(i,j)
            if card ~= nil and card.gameObject.name == tostring(cardUid) then
                return card
            end
        end
    end
    return nil
end