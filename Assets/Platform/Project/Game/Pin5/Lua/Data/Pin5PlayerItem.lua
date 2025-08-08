Pin5PlayerItem = {
    ------------------UI
    gameObject = nil,
    transform = nil,
    ------------------属性
    --下标
    index = 0,
    ------------------数据
    --玩家id
    playerId = nil,
    ------------------保存缓存
    --静态数据

    ------------------ 发牌动画
    --发牌回调
    sendCardComplete = nil,
    --发牌列表
    sendCardList = nil,
    --发牌列表Timer
    sendCardListTimer = nil,
    --发牌延迟（毫秒）
    sendCardDelay = 0,
    --上次发牌时间(毫秒)
    sendCardLastTime = 0,

    --本局是否收缩过牌
    shrinkType = Pin5ShrinkType.None,
}

local meta = { __index = Pin5PlayerItem }
function Pin5PlayerItem.New(transform, index)
    local o = {}
    setmetatable(o, meta)
    o.transform = transform
    o:InitProperty(index)
    o:InitUI()
    return o
end

--初始属性数据
function Pin5PlayerItem:InitProperty(index)
    self.index = index
    self.playerId = nil
end

--初始化UI
function Pin5PlayerItem:InitUI()
    self.sendCardList = {}
    self.resultGoldItems = {}
    self.sendCardItems = {}

    self.gameObject = self.transform.gameObject

    self.emptyGo = self.transform:Find("Empty").gameObject
    local playeNode = self.transform:Find("PlayeNode")
    self.nodeGo = playeNode.gameObject

    local chat = playeNode:Find("Chat/ChatBox")
    self.chatGo = chat.gameObject
    self.chatLabel = chat:Find("Text"):GetComponent(TypeText)
    self.faceTransform = playeNode:Find("Chat/FaceImage")

    self.group = playeNode:Find("Group")

    self.headNode = self.group:Find("Head")
    self.headImage = self.group:Find("Head/Mask/Icon"):GetComponent(TypeImage)
    self.headBtn = self.group:Find("Head").gameObject
    
    self.imgBankerBox = self.group:Find("ImgBankerBox").gameObject
    self.imgLookOn = self.group:Find("ImgLookOn").gameObject
    self.imgOffline = self.group:Find("ImgOffline").gameObject
    self.imgReady = self.group:Find("ImgReady").gameObject
    self.imgBankerTag = self.group:Find("ImgBankerTag").gameObject

    
    self.nameLabel = self.group:Find("Name"):GetComponent(TypeText)
    self.idLabel = self.group:Find("ID"):GetComponent(TypeText)
    self.scoreLabel = self.group:Find("Score"):GetComponent(TypeText)

    local scoreAnimNode = self.group:Find("ScoreAnim/Node")
    self.scoreAnimNodeGo = scoreAnimNode.gameObject
    self.scoreAnimTween = self.scoreAnimNodeGo:GetComponent(TypeTweenPosition)

    self.scoreAddGo = scoreAnimNode:Find("Add").gameObject
    self.scoreAddLabel = scoreAnimNode:Find("Add/AddLabel"):GetComponent(TypeText)
    self.scoreSubGo = scoreAnimNode:Find("Sub").gameObject
    self.scoreSubLabel = scoreAnimNode:Find("Sub/SubLabel"):GetComponent(TypeText)

    self.winAnimGo = self.group:Find("WinAnim").gameObject

    ------------------------------显示------------------------------
    local show = self.group:Find("Show")
    self.imgTuiZhuAnimGo = show:Find("ImgTuiZhuAnim").gameObject
    local robBankerAnim = show:Find("RobBankerAnim")
    self.robBankerAnimGo = robBankerAnim.gameObject
    self.robBankerAnimTween = self.robBankerAnimGo:GetComponent(TypeTweenScale)
    --self.robBankerAnimTween.onFinished = function() self:OnRobBankerAnimTweenCompleted() end
    self.robBankerImage = robBankerAnim:Find("Image"):GetComponent(TypeImage)
    self.robBankerText = robBankerAnim:Find("RobText"):GetComponent(TypeText)
    
    local bankerAnim = show:Find("BankerAnim")
    self.bankerAnimGo = bankerAnim.gameObject
    self.bankerAnimTween = self.bankerAnimGo:GetComponent(TypeTweenAlpha)

    ------------------------------下注分---------------------------
    local betFlyNode = self.group:Find("BetFlyNode")
    self.betFlyNode = betFlyNode
    self.betFlyNodeGo = betFlyNode.gameObject
    self.betFlyGoldGo = betFlyNode:Find("Gold").gameObject
    self.betFlyBankerGo = betFlyNode:Find("Banker").gameObject
    self.betFlyPosition = self.betFlyNode.position
    self.betFlyNode:SetParent(Pin5Const.RoomTopNode)

    local betNode = playeNode:Find("BetNode")
    self.betNodeGo = betNode.gameObject
    self.betGoldGo = betNode:Find("Gold").gameObject
    self.betBankerGo = betNode:Find("Banker").gameObject
    self.betLabel = betNode:Find("BetLabel"):GetComponent(TypeText)
    self.betFlyToPosition = self.betGoldGo.transform.position

    ------------------------------牌-------------------------------
    self.cardItems = {}
    self.resultItems = {}
    local cards = self.transform:Find("Cards")
    self.cardsGo = cards.gameObject
    local result = self.transform:Find("Result")
    self.resultGo = result.gameObject

    local item = nil
    for i = 1, 5 do
        item = Pin5PokerCard:New()
        item:Init(cards:Find(i .. "/Card").gameObject)
        table.insert(self.cardItems, item)
    end
    for i = 1, 5 do
        item = Pin5PokerCard:New()
        item:Init(result:Find(i .. "/Card").gameObject)
        table.insert(self.resultItems, item)
    end

    self.resultType1Go = result:Find("Type/1").gameObject
    self.resultType1Image = self.resultType1Go:GetComponent(TypeImage)
    self.resultType2Go = result:Find("Type/2").gameObject
    self.resultType2Image = self.resultType2Go:GetComponent(TypeImage)
end

--清空，没有玩家的时调用
function Pin5PlayerItem:Clear()
    Log(">> Pin5PlayerItem > Clear > ", self.gameObject.name)

    self:Reset()

    self.playerId = nil
    self:SetEmptyDisplay(true)
    self:SetNodeDisplay(false)
end

--重置，每小局开始时调用
function Pin5PlayerItem:Reset()
    Log(">> Pin5PlayerItem > Reset > playerId = ", self.playerId)

    self.sendCardList = {}
    self.isRobBankerMultiplePlayed = false
    --当前正在飞行的牌
    Scheduler.unscheduleGlobal(self.sendCardListTimer)
    self.sendCardListTimer = nil

    self:StopResultGold()
    self:SetBalanceState(false)

    self:SetImgBankerBoxDisplay(false)
    self:SetImgLookOnDisplay(false)
    self:SetImgOfflineDisplay(false)
    self:SetReadyDisplay(false)
    self:SetImgBankerTagDisplay(false)
    self:SetScoreAnimDisplay(false)
    self:SetWinAnimDisplay(false)
    self:SetTuiZhuAnimDisplay(false)
    self:SetRobBankerAnimGoDisplay(false)
    self:SetBankerAnimDisplay(false)
    self:SetBetFlyNodeDisplay(false)
    self:SetBetNodeDisplay(false)
    self:SetCardsDisplay(false)
    self:SetResultDisplay(false)
    self:SetResultType1Display(false)
    self:SetResultType2Display(false)
end

--================================================================
--设置空位显示
function Pin5PlayerItem:SetEmptyDisplay(display)
    if self.lastEmptyDisplay ~= display then
        self.lastEmptyDisplay = display
        UIUtil.SetActive(self.emptyGo, display)

        UIUtil.SetActive(self.gameObject, not display)
    end
end

--设置节点显示
function Pin5PlayerItem:SetNodeDisplay(display)
    if self.lastNodeDisplay ~= display then
        self.lastNodeDisplay = display
        UIUtil.SetActive(self.nodeGo, display)
    end
end

--设置BankerBox显示
function Pin5PlayerItem:SetImgBankerBoxDisplay(display)
    if self.lastImgBankerBoxDisplay ~= display then
        self.lastImgBankerBoxDisplay = display
        UIUtil.SetActive(self.imgBankerBox, display)
    end
end

--设置观战显示
function Pin5PlayerItem:SetImgLookOnDisplay(display)
    if self.lastImgLookOnDisplay ~= display then
        self.lastImgLookOnDisplay = display
        UIUtil.SetActive(self.imgLookOn, display)
    end
end

--设置离线显示
function Pin5PlayerItem:SetImgOfflineDisplay(display)
    if self.lastImgOfflineDisplay ~= display then
        self.lastImgOfflineDisplay = display
        UIUtil.SetActive(self.imgOffline, display)
    end
end

--设置准备显示
function Pin5PlayerItem:SetReadyDisplay(display)
    if self.lastReadyDisplay ~= display then
        self.lastReadyDisplay = display
        UIUtil.SetActive(self.imgReady, display)
    end
end

--设置庄显示
function Pin5PlayerItem:SetImgBankerTagDisplay(display)
    if self.lastImgBankerTagDisplay ~= display then
        self.lastImgBankerTagDisplay = display
        UIUtil.SetActive(self.imgBankerTag, display)
    end
end

--设置分数动画显示
function Pin5PlayerItem:SetScoreAnimDisplay(display)
    if self.lastScoreAnimDisplay ~= display then
        self.lastScoreAnimDisplay = display
        UIUtil.SetActive(self.scoreAnimNodeGo, display)
    end
end

--设置分数增加显示
function Pin5PlayerItem:SetScoreAddDisplay(display)
    if self.lastScoreAddDisplay ~= display then
        self.lastScoreAddDisplay = display
        UIUtil.SetActive(self.scoreAddGo, display)
    end
end

--设置分数减少显示
function Pin5PlayerItem:SetScoreSubDisplay(display)
    if self.lastScoreSubDisplay ~= display then
        self.lastScoreSubDisplay = display
        UIUtil.SetActive(self.scoreSubGo, display)
    end
end

--设置小局获胜动画显示
function Pin5PlayerItem:SetWinAnimDisplay(display)
    if self.lastWinAnimDisplay ~= display then
        self.lastWinAnimDisplay = display
        UIUtil.SetActive(self.winAnimGo, display)
    end
end

--设置推注动画显示
function Pin5PlayerItem:SetTuiZhuAnimDisplay(display)
    if self.lastTuiZhuAnimDisplay ~= display then
        self.lastTuiZhuAnimDisplay = display
        UIUtil.SetActive(self.imgTuiZhuAnimGo, display)
    end
end

--设置抢庄倍数显示
function Pin5PlayerItem:SetRobBankerAnimGoDisplay(display)
    --LogError(">> Pin5PlayerItem:SetRobBankerAnimGoDisplay(", display)
    if self.lastRobBankerAnimGoDisplay ~= display then
        self.lastRobBankerAnimGoDisplay = display
        UIUtil.SetActive(self.robBankerAnimGo, display)
    end
end

--设置抢庄成功动画显示
function Pin5PlayerItem:SetBankerAnimDisplay(display)
    if self.lastBankerAnimDisplay ~= display then
        self.lastBankerAnimDisplay = display
        UIUtil.SetActive(self.bankerAnimGo, display)
    end
end

--设置下注飞行节点显示
function Pin5PlayerItem:SetBetFlyNodeDisplay(display)
    if self.lastBetFlyNodeDisplay ~= display then
        self.lastBetFlyNodeDisplay = display
        UIUtil.SetActive(self.betFlyNodeGo, display)
    end
end

--设置下注飞行节点中的金币显示
function Pin5PlayerItem:SetBetFlyGoldNodeDisplay(display)
    if self.lastBetFlyGoldNodeDisplay ~= display then
        self.lastBetFlyGoldNodeDisplay = display
        UIUtil.SetActive(self.betFlyGoldGo, display)
    end
end

--设置下注飞行节点中的庄显示
function Pin5PlayerItem:SetBetFlyBankerNodeDisplay(display)
    if self.lastBetFlyBankerNodeDisplay ~= display then
        self.lastBetFlyBankerNodeDisplay = display
        UIUtil.SetActive(self.betFlyBankerGo, display)
    end
end

--设置下注节点显示
function Pin5PlayerItem:SetBetNodeDisplay(display)
    if self.lastBetNodeDisplay ~= display then
        self.lastBetNodeDisplay = display
        UIUtil.SetActive(self.betNodeGo, display)
    end
end

--设置下注节点金币显示
function Pin5PlayerItem:SetBetGoldNodeDisplay(display)
    if self.lastBetGoldNodeDisplay ~= display then
        self.lastBetGoldNodeDisplay = display
        UIUtil.SetActive(self.betGoldGo, display)
    end
end

--设置下注节点庄显示
function Pin5PlayerItem:SetBetBankerNodeDisplay(display)
    if self.lastBetBankerNodeDisplay ~= display then
        self.lastBetBankerNodeDisplay = display
        UIUtil.SetActive(self.betBankerGo, display)
    end
end

--设置手牌显示
function Pin5PlayerItem:SetCardsDisplay(display)
    if self.lastCardsDisplay ~= display then
        self.lastCardsDisplay = display
        UIUtil.SetActive(self.cardsGo, display)
    end
end

--设置结果牌显示
function Pin5PlayerItem:SetResultDisplay(display)
    if self.lastResultDisplay ~= display then
        self.lastResultDisplay = display
        UIUtil.SetActive(self.resultGo, display)
    end
end

--设置结果牌类型1图片显示
function Pin5PlayerItem:SetResultType1Display(display)
    if self.lastResultType1Display ~= display then
        self.lastResultType1Display = display
        UIUtil.SetActive(self.resultType1Go, display)
    end
end

--设置结果牌类型2图片显示
function Pin5PlayerItem:SetResultType2Display(display)
    if self.lastResultType2Display ~= display then
        self.lastResultType2Display = display
        UIUtil.SetActive(self.resultType2Go, display)
    end
end

--================================================================
--设置空
function Pin5PlayerItem:SetEmpty()
    self:SetEmptyDisplay(true)
    self:SetNodeDisplay(false)
end

--设置玩家数据
function Pin5PlayerItem:SetPlayerData(playerData)
    --不把playerData存下来是因为playerData中存了playerItem，playerItem中再存playerData的话，容易出现死循环
    --所以这里存放playerId

    if playerData == nil then
        self:Clear()
        return
    end
    self:SetEmptyDisplay(false)
    self:SetNodeDisplay(true)

    --设置元宝数量 分数
    if Pin5RoomData.IsGoldGame() then
        self:SetScore(tonumber(playerData.gold))
    else
        self:SetScore(playerData.playerScore)
    end

    --更新准备状态
    self:SetReadyDisplay(playerData.state == Pin5PlayerState.READY or playerData.state == Pin5PlayerState.WAITING_START)

    --当前玩家id与要改变的玩家id不同时
    if self.playerId ~= playerData.id then
        --玩家item
        playerData.item = self
        --设置玩家id
        self.playerId = playerData.id
        --修改名字
        self:SetNameDisplay(SubStringName(playerData.name))
        --修改id
        --self:SetIdDisplay(playerData.id)
    end
    --设置头像
    self:SetHead(playerData.playerHead)
    --更新离线图标
    self:SetImgOfflineDisplay(playerData.isOffline == true)
end

--设置头像
function Pin5PlayerItem:SetHead(playerHead)
    if self.playerHead ~= playerHead then
        self.playerHead = playerHead
        Functions.SetHeadImage(self.headImage, Functions.CheckJoinPlayerHeadUrl(playerHead))
    end
end

--设置名字显示
function Pin5PlayerItem:SetNameDisplay(name)
    if string.IsNullOrEmpty(name) then
        return
    end
    self.nameLabel.text = SubStringName(name)
end

--设置id显示
function Pin5PlayerItem:SetIdDisplay(id)
    self.idLabel.text = id
end

--设置是否在结算中状态
function Pin5PlayerItem:SetBalanceState(state)
    self.isBalance = state
end

--设置分数
function Pin5PlayerItem:SetScore(score)
    if self.isBalance == true then
        return
    end
    --LogError(">> Pin5PlayerItem:SetScore > ", score)
    if IsNil(score) then
        return
    end
    if self.lastScore ~= score then
        self.lastScore = score
        score = math.NewToNumber(score)
        if Pin5RoomData.IsGoldGame() then
            self.scoreLabel.text = score--CutNumber(score)
        else
            self.scoreLabel.text = score
        end
    end
end

--隐藏庄的显示
function Pin5PlayerItem:HideBankerDisplay()
    self:SetBankerAnimDisplay(false)
    self:SetImgBankerBoxDisplay(false)
end

--显示显示抢庄倍数，即抢几
function Pin5PlayerItem:ShowRobBankerMultipleAnim(robBankerState)
    if not self.isRobBankerMultiplePlayed then
        --LogError(">> Pin5PlayerItem:ShowRobBankerMultipleAnim(robBankerState)")

        UIUtil.SetActive(self.robBankerImage.gameObject, robBankerState == 0)
        UIUtil.SetActive(self.robBankerText.gameObject, robBankerState > 0)
        
        if robBankerState == 0 then
            --自由抢庄模式
            local spriteName = "pin5-qiang-" .. robBankerState
            self.robBankerImage.sprite = Pin5ResourcesMgr.GetShowSprite(spriteName)
            self.robBankerImage:SetNativeSize()
        else
            self.robBankerText.text = "Q*"..robBankerState
        end
        self:SetRobBankerAnimGoDisplay(true)
        --
        self.robBankerAnimTween:ResetToBeginning()
        self.robBankerAnimTween:PlayForward()
        self.isRobBankerMultiplePlayed = true
    end
end

--显示显示抢庄倍数动画播放完成
function Pin5PlayerItem:OnRobBankerAnimTweenCompleted()
    self:SetRobBankerAnimGoDisplay(false)
end


--显示下注分
function Pin5PlayerItem:ShowBetPoints(betScore)
    if Pin5Funtions.IsNilOrZero(betScore) then
        self:SetBetNodeDisplay(false)
        return
    end
    self.betLabel.text = betScore * Pin5RoomData.diFen

    if self.playerId == Pin5RoomData.BankerPlayerId then
        self:SetBetGoldNodeDisplay(false)
        self:SetBetBankerNodeDisplay(true)
    else
        self:SetBetGoldNodeDisplay(true)
        self:SetBetBankerNodeDisplay(false)
    end
    self:SetBetNodeDisplay(true)
end

--显示庄倍数
function Pin5PlayerItem:ShowBankerScore(score)
    if Pin5Funtions.IsNilOrZero(score) then
        self:SetBetNodeDisplay(false)
        return
    end
    self.betLabel.text = score
    if self.playerId == Pin5RoomData.BankerPlayerId then
        self:SetBetGoldNodeDisplay(false)
        self:SetBetBankerNodeDisplay(true)
    else
        self:SetBetGoldNodeDisplay(true)
        self:SetBetBankerNodeDisplay(false)
    end
    self:SetBetNodeDisplay(true)
end

--设置可推注图标状态
function Pin5PlayerItem:SetTuiZhuImageActive(active)
end

--显示聊天内容
function Pin5PlayerItem:ShowChatText(duration, text)
    Functions.SetChatText(self.chatGo, self.chatLabel, text)
    --定时关闭
    Scheduler.scheduleOnceGlobal(function()
        UIUtil.SetActive(self.chatGo, false)
    end, duration)
end

--设置牌型
function Pin5PlayerItem:SetResultType(imgType, point, isBalance)
    self.resultPoint = point
    self.resultImgType = imgType
    self.resultSoundType = point
    self.resultIsBalance = isBalance


    --LogError(">> Pin5PlayerItem:SetResultType", imgType, point, isBalance)

    --播放音效
    Pin5ResourcesMgr.PlayCardPointFeMaleSound(self.resultSoundType)
    --显示图片
    self:SetResultType1Display(true)
    self.resultType1Image.sprite = Pin5ResourcesMgr.GetResultSprite("pin5-n-" .. point)
    self.resultType1Image:SetNativeSize()
    local tempPoint = tonumber(point)
    local imgTypeNum = tonumber(imgType)
    if tempPoint >= 10 then
        self:SetResultType2Display(true)
        --
        self.resultType2Image.sprite = Pin5ResourcesMgr.GetResultSprite("pin5-nm-r-" .. imgType)
        self.resultType2Image:SetNativeSize()
    elseif tempPoint > 1 and imgTypeNum > 1 then
        --由于一倍不用显示，所以这里需要判断下倍数
        self:SetResultType2Display(true)
        --
        self.resultType2Image.sprite = Pin5ResourcesMgr.GetResultSprite("pin5-nm-y-" .. imgType)
        self.resultType2Image:SetNativeSize()
    else
        --无牛和1倍都不显示倍数
        self:SetResultType2Display(false)
    end
end


---判断是否播放牌型动画和音效
function Pin5PlayerItem:CheckShowResultType(imgType, point, isBalance)
    --由于当前版本不播放动画，就不加变量控制，直接显示
    self:SetResultType(imgType, point, isBalance)

    --LogError("isBalance", isBalance, "self.isShowResultType", self.isShowResultType)
    -- if isBalance and self.isShowResultType then
    --     --LogError("<color=aqua>结算已播放还原</color>")
    --     self.isShowResultType = false
    -- elseif (isBalance and not self.isShowResultType) then
    --     --LogError("<color=aqua>结算播放</color>")
    --     self:SetResultType(imgType, point, isBalance)
    -- elseif not isBalance then
    --     --LogError("<color=aqua>亮牌播放</color>")
    --     self.isShowResultType = true
    --     self:SetResultType(imgType, point, isBalance)
    -- end
end


--显示输赢分数动画
function Pin5PlayerItem:ShowScoreAnim(score)
    score = tonumber(score)
    if score >= 0 then
        self.scoreAddLabel.text = "+" .. score
        self:SetScoreAddDisplay(true)
        self:SetScoreSubDisplay(false)
    else
        self.scoreSubLabel.text = score
        self:SetScoreAddDisplay(false)
        self:SetScoreSubDisplay(true)
    end
    self:SetScoreAnimDisplay(true)
    self.scoreAnimTween:ResetToBeginning()
    self.scoreAnimTween:PlayForward()
end

--播放抢庄动画，只有庄才有回调
function Pin5PlayerItem:PlayBankerAnim(callback)
    self:SetBankerAnimDisplay(true)
    self.playBankerAnimCallback = callback
    self.bankerAnimTween.onFinished = function() self:OnPlayBankerAnimCompleted() end
    self.bankerAnimTween:ResetToBeginning()
    self.bankerAnimTween:PlayForward()
    Pin5ResourcesMgr.PlayGameSound(Pin5GameEffSoundType.BecomeBanker)
end

--播放庄动画完成
function Pin5PlayerItem:OnPlayBankerAnimCompleted()
    self:SetBankerAnimDisplay(false)
    local callback = self.playBankerAnimCallback
    self.playBankerAnimCallback = nil
    if callback ~= nil then
        callback()
    end
end

--播放获胜动画
function Pin5PlayerItem:PlayWinAnim()
    self:SetWinAnimDisplay(true)
end

--================================发牌================================

--cards:{card:11,index=1,sendCardComplete}
function Pin5PlayerItem:SendCards(cards, delay)
    self:SendOtherCards(cards, delay)
end

--自己发牌
function Pin5PlayerItem:SendSelfCards(cards, delay)
    if #cards == 0 then
        return
    end

    local isHide = true
    for i = 1, #cards do
        isHide = isHide and (cards[i].card == nil or cards[i].card == -1)
    end

    for i = 1, #cards do
        table.insert(self.sendCardList, cards[i])
    end

    if IsNumber(delay) then
        self.sendCardDelay = delay * 1000
    end

    if not IsNil(self.sendCardListTimer) then
        return
    end

    local tempTime = 0

    self.sendCardListTimer = Scheduler.scheduleGlobal(function()
        tempTime = os.timems()
        if tempTime - self.sendCardLastTime > self.sendCardDelay then
            self.sendCardLastTime = tempTime
            self:SendCard(self.sendCardList[1].card, self.sendCardList[1].index, self.sendCardList[1].sendCardComplete, isHide)
            table.remove(self.sendCardList, 1)
        end

        if #self.sendCardList == 0 then
            Scheduler.unscheduleGlobal(self.sendCardListTimer)
            self.sendCardListTimer = nil
        end
    end, 0.049)
end

--其他人发牌
function Pin5PlayerItem:SendOtherCards(cards)
    local isHide = true
    for i = 1, #cards do
        isHide = isHide and (cards[i].card == nil or tonumber(cards[i].card) == -1)
    end

    coroutine.start(function()
        for i = 1, #cards do
            coroutine.wait(0.05)
            self:SendCard(cards[i].card, cards[i].index, cards[i].sendCardComplete, isHide)
        end
    end)
end

--发牌 card 牌数据 count 第几张牌, sendCardComplete 发牌完成回调
function Pin5PlayerItem:SendCard(card, count, sendCardComplete, isHide)
    --LogError("> Pin5PlayerItem > SendCard > card = ", card, " count = ", count, isHide)
    local tempCardItem = self.cardItems[count]
    local tempSendCardItem = nil
    Pin5RoomAnimator.sendCarding = true

    for i = 1, #self.sendCardItems do
        if not self.sendCardItems[i].isActive then
            tempSendCardItem = self.sendCardItems[i]
            break
        end
    end

    --设置当前的牌 
    if IsNil(tempSendCardItem) then
        local temp = CreateGO(Pin5Const.deckCardItem.gameObject, Pin5Const.deckCardItem.parent, 'FlyCard')
        tempSendCardItem = {}
        tempSendCardItem.isActive = false
        tempSendCardItem.gameObject = temp
        tempSendCardItem.transform = temp.transform
        tempSendCardItem.rectTransform = temp:GetComponent(TypeRectTransform)
        tempSendCardItem.image = temp:GetComponent(TypeImage)
        tempSendCardItem.rectTransform.sizeDelta = tempCardItem.rectTransform.sizeDelta
        table.insert(self.sendCardItems, tempSendCardItem)
    end

    tempSendCardItem.transform:DOKill()
    self:ResetFlyCardItem(tempSendCardItem)
    tempSendCardItem.isActive = true

    --初始化发的牌
    tempCardItem:SetPoints("-1", false)
    --还原牌坐标
    tempCardItem:RestoreUpPositionY()

    --local doScale = tempSendCardItem.cardItem.transform:DOScale(doScaleV3, 0.2)
    --doScale:OnComplete(function()
    --目标坐标
    local targetPosition = tempCardItem.transform.position
    ---! 放大
    local targetScale = Vector3.New(1, 1, 1)
    ---! 移动
    local tweener = DOTween.Sequence()
    local tempSendCardItemTrans = tempSendCardItem.transform
    tweener:Append(tempSendCardItemTrans:DOMove(targetPosition, 0.3, true))
    tweener:Join(tempSendCardItemTrans:DOScale(targetScale, 0.3))
    tweener:Join(tempSendCardItemTrans:DOLocalRotate(Vector3(0, 0, -360), 0.3, DG.Tweening.RotateMode.FastBeyond360))

    tweener:SetEase(DG.Tweening.Ease.Linear)--(DG.Tweening.Ease.OutSine)
    tweener:OnStart(self.PlayFaPaiGameSound)

    tweener:OnComplete(function()
        UIUtil.SetActive(tempSendCardItem.gameObject, false)
        tempSendCardItem.isActive = false

        self:SetCardsDisplay(true)
        tempCardItem:SetPoints(card, true)

        --发牌结束回调
        if sendCardComplete ~= nil then
            --检查点数
            sendCardComplete()
            sendCardComplete = nil
        end
        Pin5RoomAnimator.sendCarding = false
    end)
    --end)
end

--播放发牌音效
function Pin5PlayerItem.PlayFaPaiGameSound()
    coroutine.start(function()
        Pin5ResourcesMgr.PlayFaPaiGameSound()
    end)
end

--重置飞牌
function Pin5PlayerItem:ResetFlyCardItem(item)
    ---! 玩家手牌
    item.transform.anchoredPosition = Vector3.zero
    item.transform.anchorMax = Vector2.New(0.5, 0.5)
    item.transform.localScale = Vector3.New(0, 0, 1)
    --设置牌背
    item.image.sprite = Pin5ResourcesMgr.GetCardBack()
    UIUtil.SetActive(item.gameObject, true)
end

--飞下注金币动画
function Pin5PlayerItem:FlyBetGold(callback)
    --播放飞金币音效
    Pin5ResourcesMgr.PlayGameSound(Pin5GameEffSoundType.EFFFLYCOINS)
    if self.playerId == Pin5RoomData.BankerPlayerId then
        self:SetBetFlyGoldNodeDisplay(false)
        self:SetBetFlyBankerNodeDisplay(true)
    else
        self:SetBetFlyGoldNodeDisplay(true)
        self:SetBetFlyBankerNodeDisplay(false)
    end
    self:SetBetFlyNodeDisplay(true)
    self.betFlyNode.position = self.betFlyPosition
    local tween = self.betFlyNode:DOMove(self.betFlyToPosition, 1, false)
    tween:OnComplete(function()
        self:SetBetFlyNodeDisplay(false)
        if callback ~= nil then
            callback()
        end
    end)
end

--获取头像的世界坐标
function Pin5PlayerItem:GetHeadPosition()
    return self.headNode.position
end

--飞结果金币动画
function Pin5PlayerItem:FlyResultGold(position, score)
    --分数大于0，从目标点飞向自己；否则从自己飞行目标点
    local beginPosition = nil
    local endPosition = nil
    if score > 0 then
        beginPosition = position
        endPosition = self.headNode.position
    else
        beginPosition = self.headNode.position
        endPosition = position
    end

    --LogError(beginPosition, endPosition)

    local total = 5
    for i = 1, total do
        local item = self.resultGoldItems[i]
        if item == nil then
            item = Pin5LoadResPanel.CreateResultGoldItem()
            table.insert(self.resultGoldItems, item)
        end
        UIUtil.SetActive(item.gameObject, true)
        item.isActive = true

        --分2段动画
        local tween = nil
        item.transform.position = beginPosition + Vector3(math.random(0, 100) / 100 - 0.5, math.random(0, 100) / 100 - 0.5, 0)
        tween = item.transform:DOMove(endPosition, 0.5, false)
        
        local Ease = DG.Tweening.Ease
        tween:SetEase(Ease.Linear)
        tween:SetDelay((i - 1) * 0.1)
        tween:OnComplete(function()
            item.isActive = false
            UIUtil.SetActive(item.gameObject, false)
        end)
    end
end

--飞结果金币动画
function Pin5PlayerItem:StopResultGold()
    local item = nil
    for i = 1, #self.resultGoldItems do
        item = self.resultGoldItems[i]
        if item.isActive then
            item.isActive = false
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

-----------------------------------------------------------
--检测牌是否为结果牌
function Pin5PlayerItem:CheckIsResult(cards)
    local length = #cards
    local isResult = false
    if length >= 5 then
        isResult = true
        for i = 1, 5 do
            if tonumber(cards[i]) > 0 then
                --
            else
                isResult = false
                break
            end 
        end
    end
    return isResult
end

--设置所有牌
function Pin5PlayerItem:ShowAllCard(cards)
    if not IsTable(cards) then
        return
    end

    local isResult = self:CheckIsResult(cards)

    if isResult then
        self:SetCardsDisplay(false)
        self:SetResultDisplay(true)
        for i = 1, #cards do
            self.resultItems[i]:SetPoints(cards[i])
            self.resultItems[i]:StopTween()
        end
    else
        self:SetCardsDisplay(true)
        self:SetResultDisplay(false)
        self:SetResultType1Display(false)
        self:SetResultType2Display(false)

        --显示牌
        for i = 1, #self.cardItems do
            if cards[i] ~= nil then
                self.cardItems[i]:SetPoints(cards[i])
                self.cardItems[i]:StopTween()
            else
                self.cardItems[i]:Reset()
                self.cardItems[i]:HideCard()
            end
        end
    end
end

--播放玩家的牌的翻牌动画
function Pin5PlayerItem:PlayFlopAllAnim(cardList)
    if Pin5RoomData.isCardGameStarted == false then
        return
    end
    for i = 1, #cardList do
        self:PlayFlopAnim(i, cardList[i])
    end
end

--播放玩家的牌的翻牌动画
function Pin5PlayerItem:PlayFlopAnim(index, card, callback)
    self.cardItems[index]:PlayFlopAnim(card, function()
        local playerData = Pin5RoomData.GetPlayerDataById(self.playerId)
        playerData.handCards[index] = card

        if callback ~= nil then
            callback()
        end
    end)
end

--清空扑克设置
function Pin5PlayerItem:ResetPokerData()
    self:SetCardsDisplay(true)
    self:SetResultDisplay(false)
    self:SetResultType1Display(false)
    self:SetResultType2Display(false)
    for i = 1, #self.cardItems do
        self.cardItems[i]:Reset()
    end
end

--隐藏玩家的所有牌
function Pin5PlayerItem:HideAllCard()
    self:SetCardsDisplay(true)
    self:SetResultDisplay(false)
    self:SetResultType1Display(false)
    self:SetResultType2Display(false)
    for i = 1, #self.cardItems do
        self.cardItems[i]:HideCard()
    end
end

--检查牌
function Pin5PlayerItem:CheckCards(handCards)
    self:ShowAllCard(handCards)
end

--隐藏某张牌
function Pin5PlayerItem:HideOneCard(index)
    if not IsNil(self.cardItems[index]) then
        self.cardItems[index]:HideCard()
    end
end

--还原牌排序
function Pin5PlayerItem:SetNativeCards()
    self.shrinkType = Pin5ShrinkType.None
    if self.index == 1 then
        for i = 0, 4 do
            self.cardItems[i + 1]:RestoreUpPositionY()
            self.cardItems[i + 1]:SetParentLocalPosition(Vector2(i * Pin5MainPlayerCardInv.Normal, 0))
        end
    else
        for i = 0, 4 do
            self.cardItems[i + 1]:RestoreUpPositionY()
            self.cardItems[i + 1]:SetParentLocalPosition(Vector2(i * 28, 0))
        end
    end
end

--收缩牌排序
function Pin5PlayerItem:SetShrinkCards()
    if self.shrinkType == Pin5ShrinkType.Shrink then
        return
    end
    self.shrinkType = Pin5ShrinkType.Shrink
    if self.index == 1 then
        for i = 0, 4 do
            self.resultItems[i + 1]:SetParentLocalPosition(Vector2(i * 50, 0))
        end
    else
        for i = 0, 4 do
            self.resultItems[i + 1]:SetParentLocalPosition(Vector2(i * 24, 0))
        end
    end
end

--三二牌排序
function Pin5PlayerItem:SetThreeBinaryCards()
    if self.shrinkType == Pin5ShrinkType.ThreeBinary then
        return
    end
    self.shrinkType = Pin5ShrinkType.ThreeBinary
    local x = 0
    if self.index == 1 then
        for i = 0, 4 do
            x = i * 50
            if i > 2 then
                x = x + 22
            end
            self.resultItems[i + 1]:SetParentLocalPosition(Vector2(x, 0))
        end
    else
        for i = 0, 4 do
            x = i * 24
            if i > 2 then
                x = x + 18
            end
            self.resultItems[i + 1]:SetParentLocalPosition(Vector2(x, 0))
        end
    end
end

--提起第五张牌
function Pin5PlayerItem:UpFiveCard(isPlayAnim)
    local playerData = Pin5RoomData.GetPlayerDataById(self.playerId)
    local cardItem = nil
    for i = 1, #self.resultItems do
        cardItem = self.resultItems[i]
        if cardItem.point == playerData.fiveCard then
            if self.index == 1 then
                cardItem:DOLocalMoveUpPositionY(24, isPlayAnim)
            else
                cardItem:DOLocalMoveUpPositionY(13, isPlayAnim)
            end
            --cardItem:SetActiveFiveCardTip(true)
        else
            cardItem:RestoreUpPositionY()
        end
    end
end

return Pin5PlayerItem