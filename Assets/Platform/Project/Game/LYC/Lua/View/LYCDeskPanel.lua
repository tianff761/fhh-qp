
LYCDeskPanel = ClassPanel("LYCDeskPanel")
local this = LYCDeskPanel

--存入一个对象
local mSelf = nil

local isInitDeck = false
-----------------------------
function LYCDeskPanel:OnInitUI()
	mSelf = self
	self:InitPanel()
	--更新桌面背景
	self:UpdateLYCDeskBG()
	--监听事件
	self:AddMsg()

	SendMsg(LYCAction.LYCLoadEnd, 1)
	Log(">>>>>>>>>>>>>>>>>>>       加载桌子结束")
end

function LYCDeskPanel:InitPanel()
	local transform = self.transform
	--桌面1
	self.ImgDeskBg = transform:Find('DeskBg'):GetComponent("Image")
	self.deck = transform:Find("Deck"):GetComponent("Image")
	LYCConst.deckCardItem = self.deck.transform:Find("Item")
	self.deckCardItemImage = LYCConst.deckCardItem:GetComponent("Image")
	self.selfCardSlotGo = transform:Find("SelfCardSlot").gameObject
	
	UIUtil.SetBackgroundAdaptation(self.ImgDeskBg.gameObject)
end

-- 快于start
function LYCDeskPanel:OnOpened()
	--重置桌面
	this.ResetLYCDesk()
end

--监听事件
function LYCDeskPanel:AddMsg()
	Event.AddListener(LYCAction.DeskStypleType, this.UpdateLYCDesk)
	Event.AddListener(LYCAction.PokerStyleType, this.UpdateCardDeck)
end

--移除监听
function LYCDeskPanel:RemoveMsg()
	Event.RemoveListener(LYCAction.DeskStypleType, this.UpdateLYCDesk)
	Event.RemoveListener(LYCAction.PokerStyleType, this.UpdateCardDeck)
end

--更新桌面背景
function LYCDeskPanel.UpdateLYCDesk()
	if mSelf == nil then
		LogError("  LYCDeskPanel.UpdateLYCDesk  mSelf is Nil")
		return
	end
	mSelf:UpdateLYCDeskBG()
end

--更新牌堆背景
function LYCDeskPanel.UpdateCardDeck()
	if mSelf == nil then
		LogError("  LYCDeskPanel.UpdateCardDeck  mSelf is Nil")
		return
	end
	mSelf:UpdatePileSprite()
end

--设置桌面背景风格
function LYCDeskPanel:UpdateLYCDeskBG()
	local type = LYCRoomData.lycDeskColor
	if type == nil then
		type = LYCDeskImageColor.green
	end
	-- LYCResourcesMgr.LoadDesk(type, mSelf.ImgDeskBg)
end

--改变牌堆颜色
function LYCDeskPanel:UpdatePileSprite()
	local type = LYCRoomData.cardColor
	if type == nil or type == "nil" then
		type = PokerCardColor.orange
	end
	mSelf.deck.sprite = LYCResourcesMgr.GetShowPng("pile" .. type)
end

--显示出牌堆
function LYCDeskPanel:ShowCardPile()
	if not isInitDeck then
		mSelf:UpdatePileSprite()
		isInitDeck = true
	end
	UIUtil.SetActive(mSelf.deck.gameObject, true)
end

--重置桌面
function LYCDeskPanel.ResetLYCDesk()
	UIUtil.SetActive(mSelf.deck.gameObject, false)
end

function LYCDeskPanel:OnDestroy()
	mSelf:RemoveMsg()
	mSelf = nil
	isInitDeck = nil
end 
--=====================================
--发给一个玩家牌  --传入要发的牌
function LYCDeskPanel.SendCards(playerData, cardsT)
    local playerItem = LYCRoomData.GetPlayerUIById(playerData.id)
    if IsNil(playerItem) then
        return
    end
    --初始化牌背
    local poker = LYCResourcesMgr.GetCardBack()
	mSelf.deckCardItemImage.sprite = poker
    --显示牌堆
	mSelf:ShowCardPile()
	
	playerItem:SendCards(cardsT, 0.1)
end