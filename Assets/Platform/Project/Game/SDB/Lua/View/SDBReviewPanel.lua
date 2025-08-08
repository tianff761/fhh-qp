SDBReviewPanel = ClassPanel("SDBReviewPanel")
local this = SDBReviewPanel
local transform
local smallSprite = {}
local mSelf = nil
local items = {}
local curPage = 0
local reviewData = {}

this.isActive = false

function SDBReviewPanel:OnInitUI()
    mSelf = self
    self:InitPanel()
    self:AddMsg()
end

function SDBReviewPanel:InitPanel()
    transform = self.transform
    local content = transform:Find("Content")
    --
    self.closeBtn = content:Find("Background/CloseButton")
    --
    self.itemContent = content:Find("Node/PlayerItems")
    self.item = self.itemContent:Find("Item")
    --
    self.indexContent = content:Find("Node/Index")
    self.rightBtn = self.indexContent:Find("RightBtn")
    self.leftBtn = self.indexContent:Find("LeftBtn")
    self.indexText = self.indexContent:Find("Text"):GetComponent(TypeText)
    --
    local LoadSprite = content:Find("LoadSprite"):GetComponent("UISpriteAtlas")
    self:SetLoadSprite(LoadSprite)
end

function SDBReviewPanel:AddMsg()
    self:AddOnClick(self.rightBtn, this.OnClickRightBtn)
    self:AddOnClick(self.leftBtn, this.OnClickLeftBtn)
    self:AddOnClick(self.closeBtn, this.OnClickClose)
end

function SDBReviewPanel:GetItemTable(item)
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

function SDBReviewPanel:SetLoadSprite(LoadSprite)
    local mSprites = LoadSprite.sprites:ToTable()
    for i = 1, #mSprites do
        smallSprite[mSprites[i].name] = mSprites[i]
    end
end

function SDBReviewPanel:GetLoadSprite(name)
    return smallSprite[name]
end

--[[    curPage:3
    Players:table: 0x4874c968
    1:table: 0x4874c9b0
    bet:0
    Cards:"20"
    curScore:60
    multiple:1
    result:"2,4"
    totalScore:60
    uId:124320
    2:table: 0x4874c7f8
    bet:6
    Cards:"11"
    curScore:-60
    multiple:0
    result:"2,0.5"
    totalScore:-60
    uId:124289
]]
function SDBReviewPanel:OnOpened()
    mSelf = self
    this.isActive = true
    curPage = SDBRoomData.gameIndex
    this.SendReview(curPage - 1)
end

--请求上局回顾信息
function SDBReviewPanel.SendReview(gameIndex)
    if reviewData[gameIndex] == nil then
        SDBApiExtend.SendReview(SDBRoomData.roomCode, gameIndex)
    else
        this.OnReview(reviewData[gameIndex])
    end
end

function SDBReviewPanel.OnReview(data)
    curPage = data.curPage
    reviewData[data.curPage] = data
    mSelf:InitData(data)
end

function SDBReviewPanel:InitData(data)
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

    for i, playerInfo in ipairs(data.Players) do
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
        UIUtil.SetActive(items[i].addScoreTxt.gameObject, playerInfo.curScore >= 0)
        UIUtil.SetActive(items[i].subScoreTxt.gameObject, playerInfo.curScore < 0)
        if playerInfo.curScore >= 0 then
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

    --更新下面的页数
    self.indexText.text = curPage .. "/" .. SDBRoomData.gameIndex - 1 .. "局"
end

--手动关闭
function SDBReviewPanel.OnClickClose()
    mSelf:Close()
end

--点击向右翻页
function SDBReviewPanel.OnClickRightBtn()
    if curPage >= SDBRoomData.gameIndex - 1 then
        Toast.Show("没有下一页了")
    else
        this.SendReview(curPage + 1)
    end
end

--点击向左翻页
function SDBReviewPanel.OnClickLeftBtn()
    if curPage <= 1 then
        Toast.Show("没有上一页了")
    else
        this.SendReview(curPage - 1)
    end
end

function SDBReviewPanel:OnClosed()
    this.isActive = false
end

function SDBReviewPanel:OnDestory()
    local transform
    local smallSprite = {}
    local mSelf = nil
    local items = {}
    this.isActive = false
end