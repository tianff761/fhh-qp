ChiPanel = ClassPanel("ChiPanel")
ChiPanel.lineModelTran = nil --列模板
ChiPanel.listsOfCardsTran = nil --所有列
ChiPanel.targetCardTran = nil --吃牌吃的对象
ChiPanel.targetCardId = 0   --目标牌ID
ChiPanel.mode = 0   -- 0:吃牌   1 摆牌
ChiPanel.operations = nil
local this = ChiPanel

function ChiPanel:Awake()
    this = self
end

--{targetId = 0, from = 0, oper = EqsOperation.Guo, id1 = 0, id2 = 0, id3 = 0}
function ChiPanel:OnOpened(operations)
    LogError("打开吃面板：", operations)
    this.operations = operations
    this.lineModelTran = this:Find("Content/LineTemp")
    this.listsOfCardsTran = this:Find("Content/ListsOfCards")
    this.targetCardTran = this:Find("Content/TargetCardPos")

    this.lineModelTran.localPosition = Vector3(10000, 10000, 0)

    local bg = this.transform:Find("ClickBg")
    this:AddOnClick(bg.gameObject, this.OnClickBgBtn)

    local cards = {}
    local targetId = 0

    if operations ~= nil and IsTable(operations) then
        for _, oper in pairs(operations) do
            if oper.oper == EqsOperation.Chi then
                targetId = EqsTools.GetTargetId(oper)
                local lineCards = {}

                lineCards[1] = EqsTools.GetCardUid1(oper)
                lineCards[2] = EqsTools.GetCardUid2(oper)
                table.insert(cards, lineCards)
            end
        end
    end

    this.Show(cards, targetId)
end

--cards={{cardId1, cardId2}, {cardId1, cardId2, cardId3}....}, mode:nil or 0:吃牌   1 摆牌
function ChiPanel.Show(cards, targetCard)
    LogError("显示吃：", cards, targetCard)
    local tableSize = GetTableSize(cards)
    if targetCard == nil or tableSize <= 0 then
        LogError("ChiPanel.Show(cards, targetCard)", targetCard, cards)
        return
    end
    this.ClearAllCards()
    this.targetCardId = targetCard

    local cardTran = EqsCardsManager.GetCardTranById(EqsTools.GetEqsCardId(targetCard))
    cardTran.transform:SetParent(this.targetCardTran)
    cardTran.transform.anchoredPosition = Vector2(0, 0)
    cardTran.transform.localRotation = Quaternion.Euler(0, 0, 0)
    cardTran.transform.localScale = Vector2(1, 1)

    local lineName = nil
    --剔除全为不合法的行
    for _, cardLine in pairs(cards) do
        if #cardLine == 2 then
            LogError("<color=aqua>this.lineModelTran</color>", this.lineModelTran)
            local line = NewObject(this.lineModelTran.gameObject)
            UIUtil.SetActive(line, true)
            line.transform:SetParent(this.listsOfCardsTran)
            line.transform.localScale = Vector3(1, 1, 1)
            this:AddOnClick(line.gameObject, HandlerArgs(this.OnClickLineBtn, line))
            local uid1 = cardLine[1]
            local uid2 = cardLine[2]
            if IsNumber(uid1) and IsNumber(uid2) and uid1 > 0 and uid2 > 0 then
                lineName = tostring(uid1) .. "_" .. tostring(uid2)
                line.gameObject.name = lineName
                cardTran = EqsCardsManager.GetCardTranById(EqsTools.GetEqsCardId(uid1))
                if cardTran ~= nil then
                    local cell = line.transform:Find("Cell1")
                    cardTran:SetParent(cell)
                    cardTran.anchoredPosition = Vector2(0, 0)
                    cardTran.transform.localRotation = Quaternion.Euler(0, 0, 0)
                    cardTran.localScale = Vector3(1, 1, 1)
                else
                    LogError("ChiPanel.Show(cards, targetCard)11111：", uid1)
                end

                cardTran = EqsCardsManager.GetCardTranById(EqsTools.GetEqsCardId(uid2))
                if cardTran ~= nil then
                    local cell = line.transform:Find("Cell2")
                    cardTran:SetParent(cell)
                    cardTran.anchoredPosition = Vector2(0, 0)
                    cardTran.transform.localRotation = Quaternion.Euler(0, 0, 0)
                    cardTran.localScale = Vector3(1, 1, 1)
                else
                    LogError("ChiPanel.Show(cards, targetCard)22222：", uid2)
                end
            else
                LogError("ChiPanel.Show(cards, targetCard)3333", uid1, uid2)
            end
        end
    end
end

function ChiPanel.ClearAllCards()
    --清除目标牌
    ClearChildren(this.targetCardTran)
    ClearChildren(this.listsOfCardsTran)
end

function ChiPanel.OnClickLineBtn(goLine)
    local cardids = string.split(goLine.name, "_")
    for _, oper in pairs(this.operations) do
        if tostring(EqsTools.GetCardUid1(oper)) == cardids[1] and tostring(EqsTools.GetCardUid2(oper)) == cardids[2] then
            BattleModule.SendOperation(oper)
            EqsBattlePanel.HideAllOperationBtns()
            this:Close()
            break
        end
    end
end

function ChiPanel.OnClickBgBtn()
    this:Close()
end