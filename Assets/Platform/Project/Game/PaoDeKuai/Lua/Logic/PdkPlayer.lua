PdkPlayer = ClassLuaComponent("PdkPlayer")
local this = PdkPlayer
--玩家名字
this.userName = nil
--玩家性别
this.sex = nil
--服务器座位号
this.serverIndex = nil
--本地座位号
this.seatIndex = nil
--上一次存储的在线状态
this.lastOnline = - 1
--倒计时timer
this.countdownTimer = nil
--离线时间
this.offlineTime = 0

function PdkPlayer:Awake()
    --self.gameObject:SetActive(false)
    local group = self.transform:Find("Group")
    local headGroup = group:Find("HeadGroup")
    self.headBtn = headGroup.gameObject
    self.headImage = headGroup:Find("HeadMask/HeadImage"):GetComponent("Image") --头像
    self.headBox = headGroup:Find("HeadFrame"):GetComponent("Image") --头像框
    local offlineTrans = headGroup:Find("Offline")
	self.offlineGO = offlineTrans.gameObject
    self.offlineTxt = offlineTrans:Find("OfflineText"):GetComponent("Text") --离线时间 
    self.nameText = headGroup:Find("PlayerNameText"):GetComponent("Text") --名字
    self.idText = headGroup:Find("IdBg/PlayerIDText"):GetComponent("Text") --ID
    self.scoreText = headGroup:Find("ScoreBg/ScoreText"):GetComponent("Text") --分数
    self.coinIcon = headGroup:Find("ScoreBg/Coin").gameObject --分数图标
    self.scoreIcon = headGroup:Find("ScoreBg/Score").gameObject --分数图标
    self.onHookIcon = headGroup:Find("OnHookIcon").gameObject --托管图标
    self.cardNumGO = headGroup:Find("CardNum").gameObject --牌的张数图标
    self.cardNumText = headGroup:Find("CardNum/CardNumText"):GetComponent("Text") --牌的张数
    self.bankerIcon = headGroup:Find("BankerIcon").gameObject --庄家图标
    self.readyIcon = headGroup:Find("ReadyIcon").gameObject --准备图标
    self.joingIcon = group:Find("JoingImage") --进入中图标
    self.zhaNiaoIcon = headGroup:Find("ZhaNiaoIcon") --扎鸟图标
    self.passIcon = group:Find("PassIamge").gameObject --要不起图标
    self.effNode = group:Find("EffNode") --特效节点
    self.baoDanNode = group:Find("BaoDanNode") --报单特效节点
    self.baoDanArmature = self.baoDanNode:Find("BaoDan/effect"):GetComponent(TypeSkeletonGraphic)
    self.emotionNode1 = group:Find("EmotionNode1") --表情节点
    self.emotionNode2 = group:Find("EmotionNode2") --表情节点
    self.timerNode = group:Find("TimerNode") --闹钟节点
    self.voice = group:Find("Voice").gameObject --语音显示
    self.chat = group:Find("ChatFrame").gameObject --说话文本
    self.scoreAnim = headGroup:Find("ScoreAnim") --分数动画
    self.winText = self.scoreAnim:Find("WinText"):GetComponent("Text")
    self.loseText = self.scoreAnim:Find("LoseText"):GetComponent("Text")
    self.chatText = group:Find("ChatFrame/Text"):GetComponent("Text")
    self.handCardNode = group:Find("HandCardNode")
    self.remainPokerNode = group:Find("RemainPokerNode")
    -- self.handCardCtrl = AddLuaComponent(group:Find("HandCardCtrl").gameObject, "HandCardCtrl") --手牌控制器
    -- self.handCardCtrl = AddLuaComponent(group:Find("PdkHandCardCtrl").gameObject, "PdkSelfHandCardCtrl") --手牌控制器
    self.pokerBackCtrl = AddLuaComponent(group:Find("PokerBackNode").gameObject, "PdkPokerBackCtrl")
end

--初始化玩家UI
function PdkPlayer:Init(info)
    self:Join(info)
    if not PdkRoomModule.isPlayback then
        --准备
        self:ShowReady(info.isZhunBei > 0)
    end
    --庄家
    self:ShowBanker(info.isZhuang > 0, false)
end

--玩家加入
function PdkPlayer:Join(info)
    --数据初始化
    self.userName = info.playerName --玩家名字
    self.sex = info.playerSex --玩家性别
    self.serverIndex = info.seatNum --服务器座位号
    self.seatIndex = PdkRoomModule.GetPlayerLocalSeat(info.seatNum) --本地座位号
    --UI初始化
    self.nameText.text = info.playerName
    self.idText.text = info.playerId
    self:SetScoreNum(tonumber(info.score))
    if not PdkRoomModule.isPlayback then
        --托管
        self:ShowTuoGuan(info.isTuoGuan > 0)
        --在线
        self:SetOnline(info.isOnline)
        self:UpdatePlayerStatus(info.playerStatus)
    end
    Functions.SetHeadImage(self.headImage, info.playerHead)
    --Functions.SetHeadFrame(self.headBox, info.playerTxk)
    if PdkRoomModule.roomType == PdkRoomType.Room_Coin then
        --UIUtil.SetActive(self.coinIcon, true)
        UIUtil.SetActive(self.scoreIcon, false)
    else
        UIUtil.SetActive(self.scoreIcon, true)
        --UIUtil.SetActive(self.coinIcon, false)
    end
    UIUtil.SetActive(self.gameObject, true)
end

--更新玩家状态
function PdkPlayer:UpdatePlayerStatus(playerStatus)
    -- self:ShowOffline(false)
    self:ShowJoing(false)
    --Log("玩家的状态是" .. playerStatus)
    if playerStatus == PdkPlayerStatus.Loading then
        self:ShowJoing(true)
    elseif playerStatus == PdkPlayerStatus.Leisure then
    elseif playerStatus == PdkPlayerStatus.Ready then
    elseif playerStatus == PdkPlayerStatus.Start then
    elseif playerStatus == PdkPlayerStatus.OffLine then
        -- self:ShowOffline(true)
    elseif playerStatus == PdkPlayerStatus.Result then
    elseif playerStatus == PdkPlayerStatus.Over then
    end
end

--显示进入中
function PdkPlayer:ShowJoing(isShow)
    UIUtil.SetActive(self.joingIcon, isShow)
end

--显示扎鸟
function PdkPlayer:ShowZhaNiao(isShow)
    UIUtil.SetActive(self.zhaNiaoIcon, isShow)
end

--设置玩家的准备图标
function PdkPlayer:ShowReady(isShow)
    UIUtil.SetActive(self.readyIcon, isShow)
end

--设置玩家的离线图标
function PdkPlayer:ShowOffline(isShow)
    -- UIUtil.SetActive(self.offline, isShow)
end

--设置玩家的庄家图标
function PdkPlayer:ShowBanker(isShow, isPlayAudio)
    UIUtil.SetActive(self.bankerIcon, isShow)
    if isPlayAudio then
        PdkAudioCtrl.PlayFirstOutCard(self.sex)
    end
end

--设置玩家的托管图标
function PdkPlayer:ShowTuoGuan(isShow)
    UIUtil.SetActive(self.onHookIcon, isShow)
end

--分数动画
function PdkPlayer:ScoreAnim(score, totalScore)
    local x = self.scoreAnim.transform.localPosition.x
    if score < 0 then
        self.loseText.text = tostring(score)
        UIUtil.SetActive(self.loseText.gameObject, true)
        UIUtil.SetActive(self.winText.gameObject, false)
    else
        self.winText.text = "+" .. score
        UIUtil.SetActive(self.loseText.gameObject, false)
        UIUtil.SetActive(self.winText.gameObject, true)
    end
    UIUtil.SetActive(self.scoreAnim.gameObject, true)
    self.scoreAnim.transform.localPosition = Vector3(x, -60, 0)
    local v3 = Vector3(x, 35, 0)
    self:SetScoreNum(totalScore)
    self.scoreAnim.transform:DOLocalMove(v3, 1.5):OnComplete(
        function()
            Scheduler.scheduleOnceGlobal(
                function()
                    UIUtil.SetActive(self.scoreAnim.gameObject, false)
                    -- self:SetScoreNum(totalScore)
                end,
                0.5
            )
        end
    )
end

--设置玩家的分数
function PdkPlayer:SetScoreNum(score)
    self.scoreText.text = CutNumber(score)
end

--发牌
function PdkPlayer:DealCard()
    self.pokerBackCtrl:UpdateLayout(0.5)
end

--生成手上的扑克牌
function PdkPlayer:CreateHandPoker(list)
    if IsNil(self.handPokers) then
        self.handPokers = {}
    end
    local poker = nil
    local id = nil
    for i = 1, #list do
        id = list[i]
        poker = PdkResourcesCtrl.GetPoker(PdkPrefabName.PlayerHandPoker, self.handCardNode)
        poker.transform:GetComponent("Image").sprite = PdkResourcesCtrl.pokerAtlas[id]
        self.handPokers[id] = poker
    end
end

--移除手上的牌
function PdkPlayer:RemoveHandPoker(pokers)
    if IsNil(self.handPokers) then
        return
    end
    for i = 1,#pokers do
        PdkResourcesCtrl.PutPoker(self.handPokers[pokers[i]])
    end
end

--清除手上的牌
function PdkPlayer:ClearHandPoker(pokers)
    if IsNil(self.handPokers) then
        return
    end
    for _,v in pairs(self.handPokers) do
        PdkResourcesCtrl.PutPoker(v)
    end
    self.handPokers = {}
end

--创建余下的牌
function PdkPlayer:CreateRemainPoker(list)
    if IsNil(self.remainPokers) then
        self.remainPokers = {}
    end
    local poker = nil
    local id = nil
    local length = #list
    local radian = 1.4
    local curRadian = (16 * radian - (radian / 2) * (16 - length)) / length
    if curRadian > 1.5 then
        curRadian = 1.5
    end
    local startValue = (length - 1) / 2 * curRadian
    for i = 1, length do
        Scheduler.scheduleOnceGlobal(function()
            local id = list[i]
            local poker = PdkResourcesCtrl.GetPoker(PdkPrefabName.PlayerRemainCard, self.remainPokerNode)
            -- poker.transform:GetComponent("Image").sprite = PdkResourcesCtrl.pokerAtlas[id]
            -- self.remainPokers[id] = poker
            UIUtil.SetLocalScale(poker.transform, 0.4, 0.4, 0.4)
            UIUtil.SetLocalPosition(poker,0, -1500, 0)
            poker.transform:Find("Image"):GetComponent("Image").sprite = PdkResourcesCtrl.pokerAtlas[id]
            local value = startValue - (i - 1) * curRadian
            UIUtil.SetRotation(poker.transform, 0, 0, value)
            local tween = poker.transform:Find("Image"):DOLocalRotate(Vector3(0, -360, 0), 0.3, DG.Tweening.RotateMode.Fast)
            tween:SetId(poker.transform:Find("Image"))
            tween:SetDelay(i * 0.05)
            -- self.remainPokers[id] = poker
            table.insert(self.remainPokers, poker)
        end, 0.05 * i)
    end

    UIUtil.SetActive(self.pokerBackCtrl.gameObject, false)
end

--清除余下的牌
function PdkPlayer:ClearRemainPoker()
    if IsNil(self.remainPokers) then
        return
    end
    -- for _,v in pairs(self.remainPokers) do
    --     PdkResourcesCtrl.PutPoker(v)
    -- end
    for i = 1,#self.remainPokers do
        PdkResourcesCtrl.PutPoker(self.remainPokers[i])
    end
    self.remainPokers = {}
end

--生成打出去的扑克牌
function PdkPlayer:CreateOutPoker(data)
    local weight = nil
    if data.pokerType == PdkPokerType.Single or data.pokerType == PdkPokerType.Double then
        weight = PdkPokerLogic.GetIdWeight(data.pokers[1])
    end
    PdkAudioCtrl.PlayCardSound(self.sex, data.pokerType, weight)
    -- PdkEffectCtrl.PlayEffect(data.pokerType, self.effNode)
end

--显示要不起图标
function PdkPlayer:ShowPass(isShow)
    UIUtil.SetActive(self.passIcon, isShow)
    if isShow then
        Scheduler.scheduleOnceGlobal(
            function()
                UIUtil.SetActive(self.passIcon, false)
            end,
            0.5
        )
    end
end

-- --显示特效
-- function PdkPlayer:ShowEffect(cardType)
--     PdkEffectCtrl.PlayEffect(cardType, self.effNode)
-- end

--显示玩家聊天文本
function PdkPlayer:ShowTalkText(isTalk, str)
    if isTalk then
        Functions.SetChatText(self.chat, self.chatText, str)
    -- self.chatText.text = str
    end
    UIUtil.SetActive(self.chat, isTalk)
end

--显示玩家语音说话
function PdkPlayer:ShowTalkEff(isTalk)
    UIUtil.SetActive(self.voice, isTalk)
end

--显示剩余牌图标
function PdkPlayer:ShowCardNum(isShow)
    self.pokerBackCtrl:Init()
    UIUtil.SetActive(self.pokerBackCtrl.gameObject, isShow)
    if PdkRoomModule.GetRule(PdkRuleType.LS_YP) ~= 0 then
        UIUtil.SetActive(self.cardNumGO, isShow)
    end
end

--设置玩家的牌数
function PdkPlayer:UpdateCardNum(num)
    if not IsNumber(num) then
        return
    end
    if self.seatIndex ~= 1 then
        if PdkRoomModule.GetRule(PdkRuleType.LS_YP) ~= 0 then
            self.cardNumText.text = tostring(num)
            self.pokerBackCtrl:UpdateCardNum(num)
        else
            self.pokerBackCtrl:UpdateLayout(0.1)
        end
    end
    if num == 1 then
        -- PdkEffectCtrl.PlayBaoDan(self.baoDanNode)
        self:ShowBaoDan(true)
    end
end

--显示报单
function PdkPlayer:ShowBaoDan(isShow)
    UIUtil.SetActive(self.baoDanNode, isShow)
    -- if isShow then
    --     DragonBonesUtil.Play(self.baoDanArmature, "BaoDan", 0)
    -- else
    --     DragonBonesUtil.Stop(self.baoDanArmature)
    -- end
end

--玩家退出
function PdkPlayer:Exit()
    self:Clear()
    UIUtil.SetActive(self.gameObject, false)
end

--结算后初始化
function PdkPlayer:Reset()
    if not PdkRoomModule.isPlayback then   
        UIUtil.SetActive(self.bankerIcon, false)
    end
    UIUtil.SetActive(self.zhaNiaoIcon, false)
    UIUtil.SetActive(self.scoreAnim.gameObject, false)
    self:ClearRemainPoker()
    self:ClearHandPoker()
    -- ClearChildren(self.baoDanNode)
    -- UIUtil.SetActive(self.readyIcon, false)
    UIUtil.SetActive(self.onHookIcon, false)
    -- UIUtil.SetActive(self.baoDanNode, false)
    self:ShowBaoDan(false)
    UIUtil.SetActive(self.cardNumGO, false)
    UIUtil.SetActive(self.pokerBackCtrl.gameObject, false)
end

--退出清除数据
function PdkPlayer:Clear()
    Functions.SetHeadImage(self.headImage, nil)
    Functions.SetHeadFrame(self.headBox, nil)
    self.lastOnline = - 1
    self:ClearOffline()
    -- UIUtil.SetActive(self.offline, false)
    UIUtil.SetActive(self.coinIcon, false)
    UIUtil.SetActive(self.scoreIcon, false)
    UIUtil.SetActive(self.bankerIcon, false)
    UIUtil.SetActive(self.readyIcon, false)
    UIUtil.SetActive(self.voice, false)
    UIUtil.SetActive(self.chat, false)
    UIUtil.SetActive(self.passIcon, false)
    UIUtil.SetActive(self.joingIcon, false)
    UIUtil.SetActive(self.zhaNiaoIcon, false)
    UIUtil.SetActive(self.cardNumGO, false)
    UIUtil.SetActive(self.scoreAnim.gameObject, false)
    -- ClearChildren(self.baoDanNode)
    -- UIUtil.SetActive(self.baoDanNode, false)
    self:ShowBaoDan(false)
    self:ClearRemainPoker()
    self:ClearHandPoker()
    UIUtil.SetActive(self.pokerBackCtrl.gameObject, false)
    -- self.handCardCtrl:Clear()
end

--设置在线标识，0离线、1在线
function PdkPlayer:SetOnline(online)
	if self.lastOnline ~= online then
		self.offlineTime = os.time()
	end
	self.lastOnline = online
	if online == 0 then
		UIUtil.SetActive(self.offlineGO, true)
		if self.offlineTime == 0 then
			self.offlineTime = os.time()
		end
		self:StartOfflineCountdown()
		self:OnOfflineCountdown()
	else
		self:ClearOffline()
	end
end

--清除离线相关
function PdkPlayer:ClearOffline()
	UIUtil.SetActive(self.offlineGO, false)
	self:StopOfflineCountdown()
end

--启动离线倒计时Timer
function PdkPlayer:StartOfflineCountdown()
	if self.countdownTimer == nil then
		self.countdownTimer = Timing.New(function() self:OnOfflineCountdown() end, 1)
	end
	self.countdownTimer:Start()
end

--停止离线倒计时Timer
function PdkPlayer:StopOfflineCountdown()
	if self.countdownTimer ~= nil then
		self.countdownTimer:Stop()
	end
end

--处理离线倒计时Timer
function PdkPlayer:OnOfflineCountdown()
	local temp = os.time() - self.offlineTime
	--最高为59:59
	if temp > 3599 then
		temp = 3599
		self.offlineTxt.text = "59:59"
		self:StopOfflineCountdown()
	else
		local minute = math.floor(temp / 60)
		if minute < 10 then
			minute = "0" .. minute
		end
		local second = temp % 60
		if second < 10 then
			second = "0" .. second
		end
		self.offlineTxt.text = minute .. ":" .. second
	end
end
