
--牌局玩家
SDBPlayer = {
	----------------需要清除----------------
	--玩家的ID
	id = nil,
	--玩家性别
	sex = nil,
	--玩家姓名
	name = nil,
	--下注分数
	xiaZhuScore = nil,
	--头像
	playerHead = nil,
	--玩家自己的状态
	state = - 1,
	--玩家分数
	playerScore = nil,
	--玩家的远端座位号
	seatNumber = nil,
	--手牌
	handCards = {},
	--玩家的操作状态
	robZhuangState = RobZhuangNumType.None,
	--手牌UI
	handCardsItems = {},
	--玩家UI
	item = nil,
	--本地座位号
	seatId = nil,
	--当前点数
	point = nil,
	--当前牌类型（爆牌，十点半，点数）
	cardType = nil,

	-----------------------------------
	--本局扣除分数(临时变量)
	tempbjpoint = 0,
	-----------------------------------
}

--牌偏移量
local office = 20

SDBPlayer.meta = {__index = SDBPlayer}

function SDBPlayer:New()
	local o = {}
	setmetatable(o, self.meta)
	o.handCardsItems = {}
	return o
end

--重置，小局重置
function SDBPlayer:Reset()
	self.handCards = {}
	self.xiaZhuScore = nil
	self.robZhuangState = RobZhuangNumType.None
	self.point = nil
	self.cardType = nil
	--隐藏所有手牌
	self:HideAllCard()
	--隐藏卡槽
	self:HideCardsSlot()
	--还原扑克牌设置
	self:ResetPokerData()
end

--开局重置的数据
function SDBPlayer:StartGameReset()
	--还原扑克牌设置
	self:ResetPokerData()
end

--初始化牌信息 --传入牌UI的table
function SDBPlayer:InitCards(objs)
	self.handCardsItems = {}
	for i = 1, #objs do
		local card = SDBPokerCard:New()
		card:Init(objs[i].gameObject)
		table.insert(self.handCardsItems, card)
	end
end

--设置玩家的信息
function SDBPlayer:SetPlayerData(data)
    if data.nowbs ~= nil then
        --设置抢庄倍数（是否抢庄）
        self.robZhuangState = data.nowbs
    end
    -- id
    self.id = data.uId
    -- 头像
    self.playerHead = data.headUrl
    -- 玩家分数
    self.playerScore = data.point
    -- 座位号
    self.seatNumber = data.chair
    -- 是否是房主
    if data.isfz == 1 then
        SDBRoomData.owner = self.id
    end
    -- 是否是庄家
    if data.isZj == 1 then
        SDBRoomData.BankerPlayerId = self.id
    end
    -- 玩家状态
    self:UpdatePlayerStates(data.state) --状态码
    -- 性别
    self.sex = data.sex
    -- 姓名
    self.name = data.name
    -- 下注分
    self.xiaZhuScore = data.paypoint
    --在线状态
    self.isOffline = data.isOffline == 0
end
------------------------
--检测手牌
function SDBPlayer:CheckHandCards()
	self:ShowAllCard(self.handCards)
end

--增加一张手牌
function SDBPlayer:AddHandCards(card, count)
	
end

--隐藏某张牌
function SDBPlayer:HideOneCard(index)
    self.item:HideOneCard(index)
end
----------------------
--显示牌的卡槽
function SDBPlayer:ShowCardsSlot()
	if not IsNil(self.item) then
		self.item:ShowCardsSlot()
	end
end

--隐藏牌的卡槽
function SDBPlayer:HideCardsSlot()
	if not IsNil(self.item) then
		self.item:HideCardsSlot()
	end
end

--显示显示抢庄倍数
function SDBPlayer:ShowRobZhuangMultiple()
	if self.item ~= nil then
		if self.robZhuangState > 0 then
			self.item:ShowRobZhuangMultiple(self.robZhuangState)
		end
	end
end

--关闭抢庄倍数
function SDBPlayer:HideRobZhuangMultiple()
	if self.item ~= nil then
		self.item:HideRobZhuangMultiple()
	end
end

--显示抢庄枪几
function SDBPlayer:ShowRobZhuangNum()
	if self.item ~= nil then
		if self.robZhuangState ~= RobZhuangNumType.None then
			self.item:ShowRobZhuangNum(self.robZhuangState)
		end
	end
end

--关闭抢几
function SDBPlayer:HideRobZhuangNum()
	if self.item ~= nil then
		self.item:HideRobZhuangNum()
	end
end

--显示某个玩家的所有牌
function SDBPlayer:ShowAllCard(card)
	if not IsNil(self.item) then
		self.item:ShowAllCard(card)
	end
end

--播放玩家的牌的翻牌动画
function SDBPlayer:PlayFlopAni(card)
	if not IsNil(self.item) then
		self.item:PlayFlopAni(card)
	end
end

--清空扑克设置
function SDBPlayer:ResetPokerData()
	if not IsNil(self.item) then
		self.item:ResetPokerData()
	end
end

--隐藏某个玩家的所有牌
function SDBPlayer:HideAllCard()
	if not IsNil(self.item) then
		self.item:HideAllCard()
	end
end

--检查牌
function SDBPlayer:CheckCards()
	if not IsNil(self.item) then
		self.item:CheckCards(self.handCards)
	end
end

--处理玩家状态
function SDBPlayer:UpdatePlayerStates(state)
	if self.state == state then
		return
	end
	self.state = state
	if self.state == PlayerState.Ready then
		
	elseif self.state == PlayerState.LookOn then
		if not IsNil(self.item) then
			self.item:Clear()
		end
	elseif self.state == PlayerState.Stand then
		if not IsNil(self.item) then
			self.item:UpdatellReadyImge(false, false)
		end
		if self.id == SDBRoomData.mainId  then
			if not SDBRoomData.isCardGameStarted then
				SDBRoomPanel.ShowReadyBtn()
			end
		end
    end
end

--飞金币动画
function SDBPlayer:FlyGold(callback)
	if not IsNil(self.item) then
		self.item:FlyGold(callback)
	end
end

function SDBPlayer:StopFlyGold()
	if not IsNil(self.item) then
		self.item:StopFlyGold()
	end
end

--销毁，调用该方法后，所以的数据都应该清除
function SDBPlayer:Destoy()
	self:Clear()
end
