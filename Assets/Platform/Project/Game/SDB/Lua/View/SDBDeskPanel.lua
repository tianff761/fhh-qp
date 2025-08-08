
SDBDeskPanel = ClassPanel("SDBDeskPanel")
local this = SDBDeskPanel

--存入一个对象
local mSelf = nil

local isInitDeck = false
-----------------------------
function SDBDeskPanel:OnInitUI()
	mSelf = self
	self:InitPanel()
	--更新桌面背景
	self:UpdateSdbDeskBG()
	--监听事件
	self:AddMsg()

	SendMsg(SDBAction.SDBLoadEnd, 1)
	Log(">>>>>>>>>>>>>>>>>>>       加载桌子结束")
end

function SDBDeskPanel:InitPanel()
	local transform = self.transform
	--桌面1
	self.ImgSdbDeskBg = transform:Find('SdbDeskBg'):GetComponent("Image")
	self.deck = transform:Find("Deck"):GetComponent("Image")
	self.cardNumText = self.deck.transform:Find("CardNum"):GetComponent("Text")
	SDBConst.deckCardItem = self.deck.transform:Find("Item")
	self.deckCardItemImage = SDBConst.deckCardItem:GetComponent("Image")
	self.selfCardSlotGo = transform:Find("SelfCardSlot").gameObject
	
	UIUtil.SetBackgroundAdaptation(self.ImgSdbDeskBg.gameObject)
end

-- 快于start
function SDBDeskPanel:OnOpened()
	--重置桌面
	this.ResetSdbDesk()
end

--监听事件
function SDBDeskPanel:AddMsg()
	Event.AddListener(SDBAction.DeskStypleType, this.UpdateSdbDesk)
	Event.AddListener(SDBAction.PokerStyleType, this.UpdateCardDeck)
end

--移除监听
function SDBDeskPanel:RemoveMsg()
	Event.RemoveListener(SDBAction.DeskStypleType, this.UpdateSdbDesk)
	Event.RemoveListener(SDBAction.PokerStyleType, this.UpdateCardDeck)
end

--设置牌数
function SDBDeskPanel.SetCardNumber(text)
	if mSelf == nil or string.IsNullOrEmpty(text) then
		LogError(" SDBDeskPanel.SetCardNumber  mSelf is Nil")
		return
	end
	mSelf.cardNumText.text = "剩余:" .. text .. "张"
end

--更新桌面背景
function SDBDeskPanel.UpdateSdbDesk()
	if mSelf == nil then
		LogError("  SDBDeskPanel.UpdateSdbDesk  mSelf is Nil")
		return
	end
	mSelf:UpdateSdbDeskBG()
end

--更新牌堆背景
function SDBDeskPanel.UpdateCardDeck()
	if mSelf == nil then
		LogError("  SDBDeskPanel.UpdateCardDeck  mSelf is Nil")
		return
	end
	mSelf:UpdatePileSprite()
end

--设置桌面背景风格
function SDBDeskPanel:UpdateSdbDeskBG()
	local type = SDBRoomData.sdbDeskColor
	if type == nil then
		type = SdbDeskImageColor.green
	end
	SDBResourcesMgr.LoadDesk(type, mSelf.ImgSdbDeskBg)
end

--改变牌堆颜色
function SDBDeskPanel:UpdatePileSprite()
	local type = SDBRoomData.cardColor
	if type == nil or type == "nil" then
		type = PokerCardColor.orange
	end
	mSelf.deck.sprite = SDBResourcesMgr.GetShowPng("pile" .. type)
end

--显示出牌堆
function SDBDeskPanel:ShowCardPile()
	if not isInitDeck then
		mSelf:UpdatePileSprite()
		isInitDeck = true
	end
	UIUtil.SetActive(mSelf.deck.gameObject, true)
end

--重置桌面
function SDBDeskPanel.ResetSdbDesk()
	UIUtil.SetActive(mSelf.deck.gameObject, false)
end

function SDBDeskPanel:OnDestroy()
	mSelf:RemoveMsg()
	mSelf = nil
	isInitDeck = nil
end 


--=====================================
--发给一个玩家牌  --传入要发的牌
function SDBDeskPanel.SendCards(playerData, card, count, sendCardComplete)
    local playerItem = SDBRoomData.GetPlayerUIById(playerData.id)
    if IsNil(playerItem) then
        return
    end
    --初始化牌背
    local poker = SDBResourcesMgr.GetCardBack()
	mSelf.deckCardItemImage.sprite = poker
    --显示牌堆
	mSelf:ShowCardPile()
	Log(">>>>>>>>>>  count = ",count)
	local handle = playerItem.handCardsItems[count]
	playerItem:SendCard(card, count,sendCardComplete)
end