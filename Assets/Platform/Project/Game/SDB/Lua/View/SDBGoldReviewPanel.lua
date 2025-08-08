SDBGoldReviewPanel = ClassPanel("SDBGoldReviewPanel")
local this = SDBGoldReviewPanel
local transform
local smallSprite = {}
local mSelf = nil
local ReviewData = nil
local items = {}

this.isActive = false

function SDBGoldReviewPanel:OnInitUI()
    mSelf = self
    self:InitPanel()
    self:AddMsg()
end

function SDBGoldReviewPanel:InitPanel()
    transform = self.transform
    self.maskBtnGo = transform:Find("Mask")
    local content = transform:Find("Content")
    --
    self.itemContent = content:Find("Node")
    self.item = self.itemContent:Find("Item")
    --
    local LoadSprite = content:Find("LoadSprite"):GetComponent("UISpriteAtlas")
    self:SetLoadSprite(LoadSprite)
end

function SDBGoldReviewPanel:AddMsg()
    self:AddOnClick(self.maskBtnGo, this.OnClickClose)
end

function SDBGoldReviewPanel:GetItemTable(item)
    local tab = {}
    tab.transform = item.transform
    tab.gameObject = item.gameObject
    tab.otherBg = item.transform:Find("Bg/OtherBg")
    tab.selfBg = item.transform:Find("Bg/SelfBg")
    tab.nameTxt = item.transform:Find("Name"):GetComponent(TypeText)
    tab.headImage = item.transform:Find("Head"):GetComponent(TypeImage)
    tab.idTxt = item.transform:Find("ID"):GetComponent(TypeText)
    local cardsContent = item.transform:Find("Cards")
    tab.cardImages = {}
    for i = 1, 5 do
        tab.cardImages[i] = cardsContent:Find(i):GetComponent(TypeImage)
    end
    tab.cardTypeImage = item.transform:Find("CardType"):GetComponent(TypeImage)
    tab.bankerGo = item.transform:Find("Banker").gameObject
    tab.multipleImage = tab.bankerGo.transform:Find("Multiple"):GetComponent(TypeImage)
    tab.betScoreGo = item.transform:Find("BetScore").gameObject
    tab.betScoreTxt = tab.betScoreGo.transform:Find("Text"):GetComponent(TypeText)
    tab.addScoreTxt = item.transform:Find("AddScore"):GetComponent(TypeText)
    tab.subScoreTxt = item.transform:Find("SubScore"):GetComponent(TypeText)
    return tab
end

function SDBGoldReviewPanel:SetLoadSprite(LoadSprite)
    local mSprites = LoadSprite.sprites:ToTable()
    for i = 1, #mSprites do
        smallSprite[mSprites[i].name] = mSprites[i]
    end
end

function SDBGoldReviewPanel:GetLoadSprite(name)
    return smallSprite[name]
end

function SDBGoldReviewPanel:OnOpened()
    mSelf = self
    this.isActive = true
    SDBApiExtend.SendReview(SDBRoomData.roomCode, SDBRoomData.gameIndex - 1)
end

function SDBGoldReviewPanel.OnReview(data)
    ReviewData = data
    mSelf:InitData()
end

function SDBGoldReviewPanel:InitData()
    local item = nil
    local cards = nil
    --牌类型（爆牌还是点数）
    local strtab = nil
    local cardType = nil
    local point = nil
    local sprite = nil

    for i, v in ipairs(items) do
        UIUtil.SetActive(items[i].gameObject, false)
    end

    for i, playerInfo in ipairs(ReviewData.Players) do
        if items[i] == nil then
            item = CreateGO(self.item, self.itemContent, i)
            items[i] = self:GetItemTable(item)
        end
        --名字
        items[i].nameTxt.text = playerInfo.name
        --ID
        items[i].idTxt.text = playerInfo.uId
        --头像
        Functions.SetHeadImage(items[i].headImage, playerInfo.headUrl)
        --本局输赢分数
        UIUtil.SetActive(items[i].addScoreTxt.gameObject, tonumber(playerInfo.curScore) >= 0)
        UIUtil.SetActive(items[i].subScoreTxt.gameObject, tonumber(playerInfo.curScore) < 0)
        if tonumber(playerInfo.curScore) >= 0 then
            items[i].addScoreTxt.text = "+" .. playerInfo.curScore
        else
            items[i].subScoreTxt.text = playerInfo.curScore
        end

        --牌 Cards
        cards = string.split(playerInfo.Cards, ",")
        for j, cardItem in ipairs(items[i].cardImages) do
            if cards[j] ~= nil then
                cardItem.sprite = self:GetLoadSprite(cards[j])
            end
            UIUtil.SetActive(cardItem.gameObject, not IsNil(cards[j]))
        end

        --牌类型（爆牌还是点数）
        strtab = string.split(playerInfo.result, ",")
        cardType = tonumber(strtab[1])
        point = tonumber(strtab[2])
        if cardType == 2 then
            sprite = SDBResourcesMgr.GetResultSprite(SDBPointType[point])
        else
            local resultType = SDBCardType[cardType]
            if self.playerId == SDBRoomData.BankerPlayerId then
                --判断是否庄家翻倍规则
                if cardType > 2 and not SDBRoomData.isBankerDoubleWin then
                    resultType = resultType .. "_0"
                end
            end
            sprite = SDBResourcesMgr.GetResultSprite(resultType)
        end
        items[i].cardTypeImage.sprite = sprite
        items[i].cardTypeImage:SetNativeSize()

        --庄或者下注分
        UIUtil.SetActive(items[i].bankerGo, playerInfo.bet == 0)
        UIUtil.SetActive(items[i].betScoreGo, playerInfo.bet > 0)

        if playerInfo.bet > 0 then
            items[i].betScoreTxt.text = playerInfo.bet
        else
            items[i].multipleImage.sprite = SDBResourcesMgr.GetShowPng("multiple_" .. playerInfo.multiple)
        end

        UIUtil.SetActive(items[i].selfBg, SDBRoomData.mainId == playerInfo.uId)
        UIUtil.SetActive(items[i].gameObject, true)
    end
end

--手动关闭
function SDBGoldReviewPanel.OnClickClose()
    mSelf:Close()
end

function SDBGoldReviewPanel:OnClosed()
    local ReviewData = nil
    this.isActive = false
end

function SDBGoldReviewPanel:OnDestory()
    local transform
    local smallSprite = {}
    local mSelf = nil
    local items = {}
    this.isActive = false
end