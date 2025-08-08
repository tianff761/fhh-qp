Pin5DeskPanel = ClassPanel("Pin5DeskPanel")
local this = Pin5DeskPanel

--存入一个对象
local mSelf = nil

local isInitDeck = false
-----------------------------
function Pin5DeskPanel:OnInitUI()
    mSelf = self
    self:InitPanel()
    --更新桌面背景
    self:UpdatePin5DeskBG()
    --监听事件
    self:AddMsg()

    SendMsg(Pin5Action.Pin5LoadEnd, 1)
    Log(">>>>>>>>>>>>>>>>>>>       加载桌子结束")
end

function Pin5DeskPanel:InitPanel()
    local transform = self.transform
    --桌面1
    self.ImgDeskBg = transform:Find('DeskBg'):GetComponent("Image")
    self.deck = transform:Find("Deck"):GetComponent("Image")
    Pin5Const.deckCardItem = self.deck.transform:Find("Item")
    self.deckCardItemImage = Pin5Const.deckCardItem:GetComponent("Image")

    UIUtil.SetBackgroundAdaptation(self.ImgDeskBg.gameObject)
end

-- 快于start
function Pin5DeskPanel:OnOpened()
    --重置桌面
    this.ResetPin5Desk()
end

--监听事件
function Pin5DeskPanel:AddMsg()
    Event.AddListener(Pin5Action.DeskStypleType, this.UpdatePin5Desk)
    Event.AddListener(Pin5Action.PokerStyleType, this.UpdateCardDeck)
end

--移除监听
function Pin5DeskPanel:RemoveMsg()
    Event.RemoveListener(Pin5Action.DeskStypleType, this.UpdatePin5Desk)
    Event.RemoveListener(Pin5Action.PokerStyleType, this.UpdateCardDeck)
end

--更新桌面背景
function Pin5DeskPanel.UpdatePin5Desk()
    if mSelf == nil then
        LogError("  Pin5DeskPanel.UpdatePin5Desk  mSelf is Nil")
        return
    end
    mSelf:UpdatePin5DeskBG()
end

--更新牌堆背景
function Pin5DeskPanel.UpdateCardDeck()
    if mSelf == nil then
        LogError("  Pin5DeskPanel.UpdateCardDeck  mSelf is Nil")
        return
    end
    mSelf:UpdatePileSprite()
end

--设置桌面背景风格
function Pin5DeskPanel:UpdatePin5DeskBG()
    local type = Pin5RoomData.pin5DeskColor
    if type == nil then
        type = Pin5DeskImageColor.green
    end
    --Pin5ResourcesMgr.LoadDesk(type, mSelf.ImgDeskBg)
end

--改变牌堆颜色
function Pin5DeskPanel:UpdatePileSprite()
    local type = Pin5RoomData.cardColor
    if type == nil or type == "nil" then
        type = PokerCardColor.orange
    end
    mSelf.deck.sprite = Pin5ResourcesMgr.GetShowSprite("pile" .. type)
end

--显示出牌堆
function Pin5DeskPanel:ShowCardPile()
    if not isInitDeck then
        mSelf:UpdatePileSprite()
        isInitDeck = true
    end
    UIUtil.SetActive(mSelf.deck.gameObject, true)
end

--重置桌面
function Pin5DeskPanel.ResetPin5Desk()
    UIUtil.SetActive(mSelf.deck.gameObject, false)
end

function Pin5DeskPanel:OnDestroy()
    mSelf:RemoveMsg()
    mSelf = nil
    isInitDeck = nil
end

--=====================================
--发给一个玩家牌  --传入要发的牌
function Pin5DeskPanel.SendCards(playerData, cardsT)
    local playerItem = Pin5RoomData.GetPlayerItemById(playerData.id)
    if IsNil(playerItem) then
        return
    end
    --初始化牌背
    local poker = Pin5ResourcesMgr.GetCardBack()
    mSelf.deckCardItemImage.sprite = poker
    --显示牌堆
    mSelf:ShowCardPile()

    playerItem:SendCards(cardsT, 0.1)
end
