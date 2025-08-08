--玩家UI显示对象
TpPlayerItem = {
    ------------------UI
    gameObject = nil,
    transform = nil,
    ------------------属性
    --序号
    index = 0,
    --玩家ID，用于判断是否为同一玩家，避免重复处理UI
    playerId = 0,
    --托管状态
    trust = nil,
    --
    --在线状态
    lastOnline = true,
    --离线时间
    offlineTime = 0,
    --离线时间Timer
    offlineTimer = nil,
    --分数分数动画Timer
    goldScoreTimer = nil,
    --
    lastCountdown = false,
    --倒计时总时间
    countdownTotal = 1,
    --倒计时时间
    countdownTime = 0,
    --倒计时Timer
    countdownTimer = nil,
    --
    --操作类型
    lastOperateType = nil,
    --下注筹码
    lastChip = nil,
    --手牌
    lastHandCards = nil,
    --是否了播放弃牌动画
    isGiveUpAnimPlayed = false,
}

--分数动画起点坐标
local ScoreBeginPosition = Vector3.New(0, 0, 0)
--分数动画终点坐标
local ScoreEndPosition = Vector3.New(0, 60, 0)

local meta = { __index = TpPlayerItem }

function TpPlayerItem.New()
    local obj = {}
    setmetatable(obj, meta)
    return obj
end

--设置初始化
function TpPlayerItem:Init(index, gameObject)
    self.index = index
    self.transform = gameObject.transform
    self.rectTransform = self.transform:GetComponent(TypeRectTransform)
    self.gameObject = gameObject
    self.transform.localPosition = Vector3(5000, 0, 0)

    local info = self.transform:Find("Info")
    self.infoRectTransform = info:GetComponent(TypeRectTransform)
    self.infoGo = info.gameObject

    self.headBtn = info:Find("Head").gameObject
    self.headImage = info:Find("Head/Mask/Image"):GetComponent(TypeImage)
    --#region
    self.stateImgGo = info:Find("StateImg").gameObject
    self.stateImg = info:Find("StateImg"):GetComponent(TypeImage)
    --
    local offline = info:Find("Offline")
    self.offlineGo = offline.gameObject
    self.offlineLabel = offline:Find("Text"):GetComponent(TypeText)
    --
    self.nameLabel = info:Find("NameText"):GetComponent(TypeText)
    self.idLabel = info:Find("IDText"):GetComponent(TypeText)
    self.scoreLabel = info:Find("ScoreText"):GetComponent(TypeText)

    self.masterGo = info:Find("IconMaster").gameObject
    --

    local countdown = info:Find("Countdown")
    self.countdownGo = countdown.gameObject
    self.countdownImage = countdown:GetComponent(TypeImage)
    self.countdownLabel = countdown:Find("Text"):GetComponent(TypeText)

    --筹码
    local betChip = info:Find("BetChip")
    self.betChipGo = betChip.gameObject
    self.betChipRectTransform = betChip:GetComponent(TypeRectTransform)
    self.betChipLabel = betChip:Find("Text"):GetComponent(TypeText)

    --赢的分数
    local scoreChange = info:Find("ScoreChange")
    self.scoreAddGo = scoreChange:Find("Add").gameObject
    self.scoreAddTransform = self.scoreAddGo.transform
    self.scoreAddLabel = scoreChange:Find("Add/Text"):GetComponent(TypeText)
    self.scoreSubGo = scoreChange:Find("Sub").gameObject
    self.scoreSubTransform = self.scoreSubGo.transform
    self.scoreSubLabel = scoreChange:Find("Sub/Text"):GetComponent(TypeText)

    --牌
    local cards = nil
    if self.index == 1 then
        cards = info:Find("Cards1")
    else
        cards = info:Find("Cards2")
    end
    self.handCardItem = TpHandCardItem.New()
    self.handCardItem:Init(self.index, cards, self.infoRectTransform)

    --结算牌
    local settlement = info:Find("Settlement")
    self.settlementGo = settlement.gameObject
    self.settlementRectTransform = self.settlementGo:GetComponent(TypeRectTransform)
    self.settlementTweener = self.settlementGo:GetComponent(TypeTweenPosition)
    self.settlementTweener.onFinished = function() self:OnSettlementTweenFinished() end
    self.settlementCards = {}
    for i = 1, 2 do
        local item = {}
        item.transform = settlement:Find(tostring(i))
        item.gameObject = item.transform.gameObject
        item.image = item.gameObject:GetComponent(TypeImage)
        table.insert(self.settlementCards, item)
    end
    self.settlementResultGo = settlement:Find("Result").gameObject
    self.settlementResultLabel = settlement:Find("Result/Text"):GetComponent(TypeText)

    self.faceAnimNode = info:Find("FaceAnimNode")
    self.faceAnimRectTransform = self.faceAnimNode:GetComponent(TypeRectTransform)
    self.headAnimNode = info:Find("HeadAnimNode")
    self.effectNode = info:Find("EffectNode")
    --
    self.chipScreenPosition = Vector2.zero--筹码原始位置的屏幕坐标
    self.chipPosition = Vector3.zero--筹码原始位置
    self.chipBetPosition = Vector3.zero--筹码下注的位置
    self.chipPoolPosition = Vector3.zero--筹码池的位置
    --
    self.flyChipGo = info:Find("FlyChip").gameObject
    self.flyChipTweener = self.flyChipGo:GetComponent(TypeTweenPosition)
    self.flyChipTweener.onFinished = function() self:OnFlyChipTweenFinished() end
    --
    self.chatFrameGo = nil
    self.chatLabel = nil
    self.chatFrameRightGo = info:Find("ChatFrameRight").gameObject
    self.chatLabelRight = info:Find("ChatFrameRight/Text"):GetComponent(TypeText)
    self.chatFrameLeftGo = info:Find("ChatFrameLeft").gameObject
    self.chatLabelLeft = info:Find("ChatFrameLeft/Text"):GetComponent(TypeText)

    self.maskHeadGo = info:Find("MaskHead").gameObject
    self.maskNameGo = info:Find("MaskName").gameObject

    self:Reset()
    self:SetInfoDisplay(false)
end

--隐藏，不处理逻辑，即计时器之类的都不会停止
function TpPlayerItem:Hide()
    UIUtil.SetActive(self.gameObject, false)
end

--显示
function TpPlayerItem:Show()
    UIUtil.SetActive(self.gameObject, true)
end

--重置，用于小结结束或者新的局开始
function TpPlayerItem:Reset()
    --
    self:SetMasterDisplay(false)
    self:SetReadyDisplay(false)
    self:HideSettlement()

    self:SetFlyChipDisplay(false)
    self.isChipFlying = false
    self:SetBetChipDisplay(false)

    self:SetChatRightDisplay(false)
    self:SetChatLeftDisplay(false)
    self:SetMaskDisplay(false)
    --
    self:StopPlayScoreAnim()
    --
    self:SetOnline(true)
    self:UpdateCountdown(0, 0)
    --
    self:UpdateOperateType(TpOperateType.None)
    --
    self:UpdateBetChip(0)
    self.lastChip = nil
    self.lastOperateType = nil
    self.isInOperate = nil
    self.isGiveUpAnimPlayed = false
    --
    self.handCardItem:Clear()
end

--清除，用于退出
function TpPlayerItem:Clear()
    --LogError(">> TpPlayerItem:Clear", self.index, self.playerId)
    if self.playerId ~= 0 then
        self.playerId = 0
        self:Reset()
    end
    self:SetInfoDisplay(false)
end

--窗口变化调用的
function TpPlayerItem:Resize()
    self:CheckAnimPosition()
end

--================================================================
--
function TpPlayerItem:SetParent(transform)
    self.transform:SetParent(transform)
    self.transform.localPosition = Vector3.zero
end

--传入世界坐标
function TpPlayerItem:SetPosition(position)
    self.transform.position = position
end

--更新位置显示，需要设置坐标后调用
function TpPlayerItem:UpdatePositionDisplay()
    local positionDict = TpPositionDict[TpDataMgr.playerTotal]
    if positionDict == nil then
        LogError(">> TpPlayerItem:UpdatePositionDisplay > positionDict == nil.")
        return
    end
    local positionType = positionDict[self.index]
    if positionType == nil then
        LogError(">> TpPlayerItem:UpdatePositionDisplay > positionType == nil.")
        return
    end

    self:SetPositionDisplay(positionType)
end

--设置位置显示
function TpPlayerItem:SetPositionDisplay(positionType)
    if self.lastPositionType ~= positionType then
        self.lastPositionType = positionType

        self.betChipRectTransform.anchoredPosition = TpBetChipPositionValue[positionType]
        self.faceAnimRectTransform.anchoredPosition = TpFaceAnimPositionValue[positionType]

        if positionType == TpPositionType.Right or positionType == TpPositionType.RightDown or positionType == TpPositionType.RightUp then
            self.chatFrameGo = self.chatFrameLeftGo
            self.chatLabel = self.chatLabelLeft
        else
            self.chatFrameGo = self.chatFrameRightGo
            self.chatLabel = self.chatLabelRight
        end

        self:CheckAnimPosition()
    end
end

--检查更新动画坐标
function TpPlayerItem:CheckAnimPosition()
    self.chipScreenPosition = RectTransformUtility.WorldToScreenPoint(UIConst.uiCamera, self.effectNode.position)
    self.chipPosition = Vector3.zero
    local temp = self.betChipRectTransform.anchoredPosition
    self.chipBetPosition = Vector3(temp.x, temp.y, 0)
    temp = UIUtil.ScreenToLocalPosition(self.infoRectTransform, TpAnimMgr.dealCardPosition, UIConst.uiCamera)
    self.chipPoolPosition = Vector3(temp.x, temp.y, 0)
end

--================================================================
--
--设置信息显示
function TpPlayerItem:SetInfoDisplay(display)
    if self.lastInfoDisplay ~= display then
        self.lastInfoDisplay = display
        UIUtil.SetActive(self.infoGo, display)
    end
end

--设置庄显示
function TpPlayerItem:SetMasterDisplay(display)
    if self.lastMasterDisplay ~= display then
        self.lastMasterDisplay = display
        UIUtil.SetActive(self.masterGo, display)
    end
end

--设置准备显示
function TpPlayerItem:SetReadyDisplay(display)
    if self.lastReadyDisplay ~= display then
        self.lastReadyDisplay = display
        UIUtil.SetActive(self.readyGo, display)
    end
end

--设置下注筹码显示
function TpPlayerItem:SetFlyChipDisplay(display)
    if self.lastFlyChipDisplay ~= display then
        self.lastFlyChipDisplay = display
        UIUtil.SetActive(self.flyChipGo, display)
    end
end

--设置下注筹码显示
function TpPlayerItem:SetBetChipDisplay(display)
    -- LogError(">> TpPlayerItem:SetBetChipDisplay", display)
    if self.lastBetChipDisplay ~= display then
        self.lastBetChipDisplay = display
        UIUtil.SetActive(self.betChipGo, display)
    end

    if not display then
        self.lastChip = nil
    end
end

--设置倒计时显示
function TpPlayerItem:SetCountdownDisplay(display)
    if self.lastCountdownDisplay ~= display then
        self.lastCountdownDisplay = display
        UIUtil.SetActive(self.countdownGo, display)
    end
end

--设置离线显示
function TpPlayerItem:SetOfflineDisplay(display)
    if self.lastOfflineDisplay ~= display then
        self.lastOfflineDisplay = display
        UIUtil.SetActive(self.offlineGo, display)
    end
end

--设置分数增加显示
function TpPlayerItem:SetScoreAddDisplay(display)
    if self.lastScoreAddDisplay ~= display then
        self.lastScoreAddDisplay = display
        UIUtil.SetActive(self.scoreAddGo, display)
    end
end

--设置分数减少显示
function TpPlayerItem:SetScoreSubDisplay(display)
    if self.lastScoreSubDisplay ~= display then
        self.lastScoreSubDisplay = display
        UIUtil.SetActive(self.scoreSubGo, display)
    end
end

--设置结算显示
function TpPlayerItem:SetSettlementDisplay(display)
    if self.lastSettlementDisplay ~= display then
        self.lastSettlementDisplay = display
        UIUtil.SetActive(self.settlementGo, display)
    end
end

--设置结算结果显示
function TpPlayerItem:SetSettlementResultDisplay(display)
    if self.lastSettlementResultDisplay ~= display then
        self.lastSettlementResultDisplay = display
        UIUtil.SetActive(self.settlementResultGo, display)
    end
end

--设置聊天Right显示
function TpPlayerItem:SetChatRightDisplay(display)
    if self.lastChatRightDisplay ~= display then
        self.lastChatRightDisplay = display
        UIUtil.SetActive(self.chatFrameRightGo, display)
    end
end

--设置聊天Left显示
function TpPlayerItem:SetChatLeftDisplay(display)
    if self.lastChatLeftDisplay ~= display then
        self.lastChatLeftDisplay = display
        UIUtil.SetActive(self.chatFrameLeftGo, display)
    end
end

--设置遮罩显示
function TpPlayerItem:SetMaskDisplay(display)
    if self.lastMaskDisplay ~= display then
        self.lastMaskDisplay = display
        UIUtil.SetActive(self.maskHeadGo, display)
        UIUtil.SetActive(self.maskNameGo, display)
    end
end

--隐藏玩家的牌
function TpPlayerItem:HideCardsDisplay()
    self.handCardItem:Clear()
end

--================================================================
--
--设置玩家基本信息
function TpPlayerItem:SetPlayerInfo(id, name)
    --LogError(">. TpPlayerItem:SetPlayerInfo", id, name)
    self.playerId = id
    self.playerName = name or ""
    self.handCardItem:SetIsMainPlayer(self.playerId == TpDataMgr.userId)
    self:UpdateOperateTypeDisplay()
end

--更新已经操作类型
function TpPlayerItem:UpdateOperateType(type, isInOperate)
    --LogError(">> TpPlayerItem:UpdateOperateType", self.index, type, isInOperate)
    if self.lastOperateType ~= type or self.isInOperate ~= isInOperate then
        self.lastOperateType = type
        self.isInOperate = isInOperate
        --LogError(">> TpPlayerItem:UpdateOperateType")
        self:UpdateOperateTypeDisplay()
    end
end

--更新操作类型显示，该方法调用需要在更新手牌之前
function TpPlayerItem:UpdateOperateTypeDisplay()
    if self.isInOperate then
        UIUtil.SetActive(self.stateImgGo, true)
        self.stateImg.sprite = TpResourcesMgr.GetStatusSprite(1)
        --self.nameLabel.text = TpOperateTypeTxt.Thinking
        self:SetMaskDisplay(false)
        --添加容错处理
        self.isGiveUpAnimPlayed = false
    else
        if self.lastOperateType == TpOperateType.Bet then
            UIUtil.SetActive(self.stateImgGo, true)
            self.stateImg.sprite = TpResourcesMgr.GetStatusSprite(3)
            --self.nameLabel.text = TpOperateTypeTxt.Bet
            self:SetMaskDisplay(false)
        elseif self.lastOperateType == TpOperateType.Gen then
            UIUtil.SetActive(self.stateImgGo, true)
            self.stateImg.sprite = TpResourcesMgr.GetStatusSprite(4)
            --self.nameLabel.text = TpOperateTypeTxt.Gen
            self:SetMaskDisplay(false)
        elseif self.lastOperateType == TpOperateType.AllIn then
            UIUtil.SetActive(self.stateImgGo, true)
            self.stateImg.sprite = TpResourcesMgr.GetStatusSprite(6)
            --self.nameLabel.text = TpOperateTypeTxt.AllIn
            self:SetMaskDisplay(false)
        elseif self.lastOperateType == TpOperateType.GiveUp then
            UIUtil.SetActive(self.stateImgGo, true)
            self.stateImg.sprite = TpResourcesMgr.GetStatusSprite(5)
            --self.nameLabel.text = TpOperateTypeTxt.GiveUp
            self:SetMaskDisplay(true)
            --LogError(TpDataMgr.lastOperateId, self.playerId, self.isGiveUpAnimPlayed)
            if TpDataMgr.lastOperateId == self.playerId and not self.isGiveUpAnimPlayed then
                self.isGiveUpAnimPlayed = true
                self.handCardItem:PlayGiveUpAnim()
            else
                --弃牌操作需要先播放弃牌动画，主玩家弃牌一直显示
                if self.playerId ~= TpDataMgr.userId then
                    self:HideCardsDisplay()
                end
            end
        elseif self.lastOperateType == TpOperateType.Check then
            UIUtil.SetActive(self.stateImgGo, true)
            self.stateImg.sprite = TpResourcesMgr.GetStatusSprite(2)
            --self.nameLabel.text = TpOperateTypeTxt.Check
            self:SetMaskDisplay(false)
        else
            UIUtil.SetActive(self.stateImgGo, false)
            self.nameLabel.text = self.playerName
            self:SetMaskDisplay(false)
        end
    end
end

--更新下注筹码显示
function TpPlayerItem:UpdateBetChip(value)
    if self.lastChip ~= value then
        self.lastChip = value
        if value > 0 then
            if self.betChipLabel ~= nil then
                self.betChipLabel.text = value
            end
            if self.isChipFlying then
                return
            end
            self:SetBetChipDisplay(true)
        else
            self:SetBetChipDisplay(false)
        end
    end
end


--播放下注筹码显示
function TpPlayerItem:PlayBetChip(value)
    if self.lastChip ~= value then
        self.lastChip = value
        if value > 0 then
            if self.betChipLabel ~= nil then
                self.betChipLabel.text = value
            end
            if self.isChipFlying then
                return
            end
            self:PlayBetChipAnim()
        else
            self:SetBetChipDisplay(false)
        end
    else
        if not self.lastBetChipDisplay and value > 0 then
            if self.betChipLabel ~= nil then
                self.betChipLabel.text = value
            end
            if self.isChipFlying then
                return
            end
            self:PlayBetChipAnim()
        end
    end
end

--是否有下注筹码
function TpPlayerItem:IsBetChip()
    if self.lastChip ~= nil and self.lastChip > 0 then
        return true
    end
    return false
end

--播放结算筹码动画
function TpPlayerItem:PlaySettlementChip(value)
    if self.lastChip ~= nil and self.lastChip > 0 then
        self:SetBetChipDisplay(false)
        if self.isChipFlying then
            return
        end
        self:PlayBetPoolAnim()
    end

    self.lastChip = value
    if value == 0 then
        self:SetBetChipDisplay(false)
    end
end

--================================================================
--更新倒计时显示
function TpPlayerItem:UpdateCountdown(value, total)
    local isCountdown = false
    if value > 0 then
        isCountdown = true
        --
        self.countdownTotal = total or 1
        if self.countdownTotal < 1 then
            self.countdownTotal = 1
        end
        local temp = value - Time.realtimeSinceStartup
        self.countdownTime = value
    end
    if self.lastCountdown ~= isCountdown then
        self.lastCountdown = isCountdown
        if self.lastCountdown then
            self:SetCountdownDisplay(true)
            self:StartCountdownTimer()
            self:UpdateCountdownTextDisplay()
        else
            self:ClearCountdownDisplay()
        end
    end
end

--清除倒计时显示
function TpPlayerItem:ClearCountdownDisplay()
    self:SetCountdownDisplay(false)
    self:StopCountdownTimer()
end

--启动倒计时Timer
function TpPlayerItem:StartCountdownTimer()
    if self.countdownTimer == nil then
        self.countdownTimer = UpdateTimer.New(function() self:OnCountdownTimer() end)
    end
    self.countdownTimer:Start()
end

--停止倒计时Timer
function TpPlayerItem:StopCountdownTimer()
    if self.countdownTimer ~= nil then
        self.countdownTimer:Stop()
    end
end

--处理倒计时Timer
function TpPlayerItem:OnCountdownTimer()
    self:UpdateCountdownTextDisplay()
end

--更新倒计时显示
function TpPlayerItem:UpdateCountdownTextDisplay()
    local temp = self.countdownTime - Time.realtimeSinceStartup
    if temp < 0 then
        self.lastCountdown = nil
        self:ClearCountdownDisplay()
        return
    end
    self.countdownImage.fillAmount = temp / self.countdownTotal
    self.countdownLabel.text = math.ceil(temp)
end

--================================================================
--
--设置在线标识
function TpPlayerItem:SetOnline(online, force)
    if self.lastOnline ~= online or force == true then
        self.lastOnline = online
        --
        if self.lastOnline == true then
            self:ClearOfflineDisplay()
        else
            self.offlineTime = os.time()
            self:SetOfflineDisplay(true)
            self:StartOfflineTimer()
            self:UpdateOfflineTextDisplay()
        end
    end
end

--清除离线相关
function TpPlayerItem:ClearOfflineDisplay()
    self.lastOnline = true
    self:SetOfflineDisplay(false)
    self:StopOfflineTimer()
end

--启动离线倒计时Timer
function TpPlayerItem:StartOfflineTimer()
    if self.offlineTimer == nil then
        self.offlineTimer = Timing.New(function() self:OnOfflineTimer() end, 1)
    end
    self.offlineTimer:Start()
end

--停止离线倒计时Timer
function TpPlayerItem:StopOfflineTimer()
    if self.offlineTimer ~= nil then
        self.offlineTimer:Stop()
    end
end

--处理离线倒计时Timer
function TpPlayerItem:OnOfflineTimer()
    self:UpdateOfflineTextDisplay()
end

--更新倒计时显示
function TpPlayerItem:UpdateOfflineTextDisplay()
    local temp = os.time() - self.offlineTime
    --最高为59:59
    if temp > 3599 then
        temp = 3599
        self.offlineLabel.text = "59:59"
        self:StopOfflineTimer()
    else
        local minute = math.floor(temp / 60)
        if minute < 10 then
            minute = "0" .. minute
        end
        local second = temp % 60
        if second < 10 then
            second = "0" .. second
        end
        self.offlineLabel.text = minute .. ":" .. second
    end
end

--================================================================
--更新金币显示
function TpPlayerItem:UpdateGold(gold)
    self.scoreLabel.text = gold
end

--播放输赢分数动画
function TpPlayerItem:PlayScoreAnim(score)
    --这里先只处理赢的动画
    if tonumber(score) >= 0 then
        self:SetScoreAddDisplay(true)
        self:SetScoreSubDisplay(false)
        --
        self.scoreAddLabel.text = "+" .. score
        self.scoreAddTransform.localPosition = ScoreBeginPosition
        self.scoreAddTransform:DOLocalMove(ScoreEndPosition, 1, false)
        --飞筹码
        TpAnimMgr.PlayWinChipAnim(score, self.chipScreenPosition)
        -- else
        --     self:SetScoreAddDisplay(false)
        --     self:SetScoreSubDisplay(true)
        --     --
        --     self.scoreSubLabel.text = score
        --     self.scoreSubTransform.localPosition = ScoreBeginPosition
        --     self.scoreSubTransform:DOLocalMove(ScoreEndPosition, 2, false)
    end
    self:StartPlayScoreAnimTimer()
end

--停止播放分数动画
function TpPlayerItem:StopPlayScoreAnim()
    self:SetScoreAddDisplay(false)
    self:SetScoreSubDisplay(false)
    self:StopPlayScoreAnimTimer()
end

--开始分数动画Timer
function TpPlayerItem:StartPlayScoreAnimTimer()
    if self.goldScoreTimer == nil then
        self.goldScoreTimer = Timing.New(function() self:OnPlayScoreAnimTimer() end, 2)
    end
    self.goldScoreTimer:Restart()
end

--停止分数动画Timer
function TpPlayerItem:StopPlayScoreAnimTimer()
    if self.goldScoreTimer ~= nil then
        self.goldScoreTimer:Stop()
    end
end

--处理分数动画Timer
function TpPlayerItem:OnPlayScoreAnimTimer()
    self:StopPlayScoreAnim()
end

--================================================================
--
--播放下注筹码动画
function TpPlayerItem:PlayBetChipAnim()
    self.isChipFlying = true
    self.flyChipType = 1
    self:SetFlyChipDisplay(true)
    self.flyChipTweener.from = self.chipPosition
    self.flyChipTweener.to = self.chipBetPosition
    self.flyChipTweener:ResetToBeginning()
    self.flyChipTweener:PlayForward()
end

--播放下注筹码池动画
function TpPlayerItem:PlayBetPoolAnim()
    self.isChipFlying = true
    self.flyChipType = 2
    self:SetBetChipDisplay(false)
    self:SetFlyChipDisplay(true)
    self.flyChipTweener.from = self.chipBetPosition
    self.flyChipTweener.to = self.chipPoolPosition
    self.flyChipTweener:ResetToBeginning()
    self.flyChipTweener:PlayForward()
end


--筹码动画完成
function TpPlayerItem:OnFlyChipTweenFinished()
    self.isChipFlying = false
    if self.flyChipType == 1 then
        self:SetFlyChipDisplay(false)
        self:SetBetChipDisplay(true)
    elseif self.flyChipType == 2 then
        self:SetFlyChipDisplay(false)
    end
end

--================================================================
--
--设置牌，播放发牌动画
function TpPlayerItem:DealCard(handCards, px)
    self.handCardItem:DealCard(handCards, px)
end

--设置牌，不播放动画
function TpPlayerItem:SetCard(handCards, px)
    if self.lastOperateType == TpOperateType.GiveUp and self.playerId ~= TpDataMgr.userId then
        self:HideCardsDisplay()
    else
        self.handCardItem:SetCard(handCards, px)
    end
end

--================================================================

--隐藏结算
function TpPlayerItem:HideSettlement()
    self:StopSettlementTimer()
    self:SetSettlementDisplay(false)
end

--结算Tween动画完成
function TpPlayerItem:OnSettlementTweenFinished()
    self:SetSettlementResultDisplay(true)
    self:StartSettlementTimer()
end

--更新牌显示
function TpPlayerItem:UpdateCardDisplay(image, id)
    local resKey = -1
    if id ~= nil and id ~= 0 and id ~= -1 then
        resKey = TpDataMgr.GetCardData(id).resKey
    end
    local sprite = TpResourcesMgr.GetCardSprite(resKey)
    if sprite == nil then
        sprite = TpResourcesMgr.GetCardSprite(-1)
    end
    image.sprite = sprite
end

--更新结算结果显示
function TpPlayerItem:UpdateSettlementResultDisplay(px)
    LogError(">> TpPlayerItem:UpdateSettlementResultDisplay > ", px)
    self.settlementResultLabel.text = TpConfig.GetPokerTypeName(px)
end

--设置结算牌
function TpPlayerItem:SetSettlementCards(handCards, px)
    --1号玩家直接用手牌显示
    if self.index == 1 then
        self:SetSettlementDisplay(false)
        self:SetCard(handCards, px)
    else
        self:HideCardsDisplay()
        if handCards ~= nil then
            self:StopSettlementTimer()
            self:SetSettlementDisplay(true)
            self:SetSettlementResultDisplay(false)
            self:UpdateCardDisplay(self.settlementCards[1].image, handCards[1])
            self:UpdateCardDisplay(self.settlementCards[2].image, handCards[2])
            self:UpdateSettlementResultDisplay(px)
            self.settlementTweener:ResetToBeginning()
            self.settlementTweener:PlayForward()
        else
            self:StopSettlementTimer()
            self:SetSettlementDisplay(false)
        end
    end
end

--启动结算计时器
function TpPlayerItem:StartSettlementTimer()
    if self.settlementTimer == nil then
        self.settlementTimer = Timing.New(function() self:OnSettlementTimer() end, 5)
    end
    self.settlementTimer:Restart()
end

--停止结算计时器
function TpPlayerItem:StopSettlementTimer()
    if self.settlementTimer ~= nil then
        self.settlementTimer:Stop()
    end
end

--处理结算计时器
function TpPlayerItem:OnSettlementTimer()
    self:StopSettlementTimer()
    self:SetSettlementDisplay(false)
end

--设置结算金币相关，比如播放动画
function TpPlayerItem:SetSettlementGold(gold, winGold)
    if winGold > 0 then
        --播放分数分数动画
        self:PlayScoreAnim(winGold)
        self:UpdateGold(gold)
    end
end


--================================================================
--
