BaiPanel = ClassPanel("BaiPanel")
BaiPanel.lineModelTran      = nil --列模板
BaiPanel.listsOfCardsTran   = nil --所有列
BaiPanel.targetCardTran     = nil --吃牌吃的对象
BaiPanel.mode               = 0   -- 0:吃牌   1 摆牌
BaiPanel.operations         = nil 
local this = BaiPanel

function BaiPanel:Awake()
    this = self
end

--{targetId = 0, from = 0, oper = EqsOperation.Guo, id1 = 0, id2 = 0, id3 = 0}
function BaiPanel:OnOpened(operations)
    Log("打开摆面板：", operations)
    this.operations         = operations
    this.lineModelTran      = this:Find("Content/LineTemp")
	this.listsOfCardsTran   = this:Find("Content/ListsOfCards")
    this.targetCardTran     = this:Find("Content/TargetCardPos")
    
    this.lineModelTran.localPosition = Vector3(10000, 10000, 0)
    local cards = {}
    if operations ~= nil and IsTable(operations) then
        for _, oper in pairs(operations) do
            if oper.oper == EqsOperation.BaiPai then
                local lineCards = {}
                lineCards[1] = EqsTools.GetTargetId(oper)
                lineCards[2] = EqsTools.GetCardUid1(oper)
                lineCards[3] = EqsTools.GetCardUid2(oper)
                table.insert(cards, lineCards)
            end
        end
    end

    this.Show(cards)
end

--cards={{cardId1, cardId2}, {cardId1, cardId2, cardId3}....}, mode:nil or 0:吃牌   1 摆牌
function BaiPanel.Show(cards)
    Log("显示摆：", cards)
    local tableSize = GetTableSize(cards)
    if tableSize <= 0 then
        LogError("BaiPanel.Show(cards, targetCard)", cards)
        return 
    end
	this.ClearAllCards()
    local cardTran = nil
    local lineName = nil
    --剔除全为不合法的行
    for _, cardLine in pairs(cards) do
        if #cardLine == 3 then
            local line = NewObject(this.lineModelTran.gameObject)
            line.transform:SetParent(this.listsOfCardsTran)
            line.transform.localScale = Vector3(1, 1, 1)
            this:AddOnClick(line.gameObject, HandlerArgs(this.OnClickLineBtn, line))
            local uid1 = cardLine[1]
            local uid2 = cardLine[2]
            local uid3 = cardLine[3]
            if IsNumber(uid1) and IsNumber(uid2) and IsNumber(uid3) and uid1 > 0 and uid2 > 0 and uid3 > 0 then
                lineName = tostring(uid1).."_"..tostring(uid2).."_"..tostring(uid3)
                line.gameObject.name = lineName
                cardTran = EqsCardsManager.GetCardTranById(EqsTools.GetEqsCardId(uid1))
                if cardTran ~= nil then
                    local cell = line.transform:Find("Cell1")
                    cardTran:SetParent(cell)
                    cardTran.anchoredPosition = Vector2(0, 0)
                    cardTran.transform.localRotation = Quaternion.Euler(0, 0, 0)
                    cardTran.localScale = Vector3(1, 1, 1)
                else
                    LogError("BaiPanel.Show(cards, targetCard)11111：", uid1)
                end

                cardTran = EqsCardsManager.GetCardTranById(EqsTools.GetEqsCardId(uid2))
                if cardTran ~= nil then
                    local cell = line.transform:Find("Cell2")
                    cardTran:SetParent(cell)
                    cardTran.anchoredPosition = Vector2(0, 0)
                    cardTran.transform.localRotation = Quaternion.Euler(0, 0, 0)
                    cardTran.localScale = Vector3(1, 1, 1)
                else
                    LogError("BaiPanel.Show(cards, targetCard)22222：", uid2)
                end

                cardTran = EqsCardsManager.GetCardTranById(EqsTools.GetEqsCardId(uid3))
                if cardTran ~= nil then
                    local cell = line.transform:Find("Cell3")
                    cardTran:SetParent(cell)
                    cardTran.anchoredPosition = Vector2(0, 0)
                    cardTran.transform.localRotation = Quaternion.Euler(0, 0, 0)
                    cardTran.localScale = Vector3(1, 1, 1)
                else
                    LogError("BaiPanel.Show(cards, targetCard)333：", uid3)
                end
            else
                LogError("BaiPanel.Show(cards, targetCard)3333", uid1, uid2, uid3)
            end
        end
    end
end

function BaiPanel.ClearAllCards()
    --清除目标牌
    ClearChildren(this.targetCardTran)
    ClearChildren(this.listsOfCardsTran)
end

function BaiPanel.OnClickLineBtn(goLine)
    local cardids = string.split(goLine.name, "_")
    Log("点击行。。。。。。。。", goLine, cardids, this.operations)
    for _, oper in pairs(this.operations) do
        if tostring(EqsTools.GetTargetId(oper)) == cardids[1] and tostring(EqsTools.GetCardUid1(oper)) == cardids[2] and tostring(EqsTools.GetCardUid2(oper)) == cardids[3] then
            BattleModule.SendOperation(oper)
            break
        end
    end
end